"""Reading a repository's markdown: which documents, their text, and their headings.

One scanner, because a second one eventually disagrees with the one that writes the
generated blocks and the first symptom is a dead link in whichever artefact nobody
checked.

**A tree is read at a ref by default, not off the working copy.** A checkout is whatever
branch somebody left it on, and an unattended reader answering off a stale or
half-edited tree reports what nobody merged. `Tree(repo)` reads the working copy, which
is what a generator run by hand wants; `Tree(repo, ref="origin/main")` reads the commit,
which is what a service wants.
"""
import fnmatch
import pathlib
import re
import subprocess

# The markers a generated Contents block is written between. The BEGIN pattern is
# deliberately tolerant of what follows "CONTENTS" — a repository's marker names the
# generator that writes it, and a scanner that insisted on one spelling would silently
# stop stripping the block the day that name changed, which does not fail: it adds one
# phantom "Contents" heading per document to the index.
BEGIN_RE = r"<!--\s*BEGIN CONTENTS\b.*?-->"
END_RE = r"<!--\s*END CONTENTS\s*-->"


def strip_block(t):
    """Remove a generated Contents block, so headings inside it are never scanned."""
    return re.sub(BEGIN_RE + r".*?" + END_RE + r"\n*", "", t, flags=re.S)


def headings(t):
    """Every `##`/`###` heading, as (level, text), skipping fenced code."""
    items = []
    in_fence = False
    for ln in t.split("\n"):
        if ln.lstrip().startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        m = re.match(r"^(#{2,3}) (.+?)\s*$", ln)
        if m:
            items.append((len(m.group(1)), m.group(2)))
    return items


def anchor_text(text):
    """The heading text GitHub derives its anchor from.

    A heading that points at another document carries a markdown link, and a link left
    intact nests brackets inside the entry — which renders as literal text and slugs to
    the href rather than to the heading. GitHub slugs what it renders, so the link is
    unwrapped to its own text before the slug is taken. A checker that slugs the raw
    heading reports every such anchor as dead while the committed one resolves.
    """
    return re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)


def label(text):
    """The visible text of an index entry: the heading with its own emphasis removed."""
    return re.sub(r"\*\*|`", "", text)


class Tree:
    """A repository's tracked markdown, read off the working copy or off a ref."""

    def __init__(self, repo, ref=None):
        self.repo = pathlib.Path(repo).resolve()
        self.ref = ref

    def _git(self, *args):
        return subprocess.run(
            ["git", "-C", str(self.repo), *args],
            capture_output=True, text=True, check=True,
        ).stdout

    def paths(self, scope=("*.md",), exclude=()):
        """Tracked paths matching the scope patterns, in `git ls-files` order.

        **The matching is done here rather than handed to git, because the two backends
        do not agree on a pathspec.** `git ls-files -- '*.md'` globs across directories;
        `git ls-tree -r -- '*.md'` matches a path prefix and answers with nothing at all,
        silently, which is a generator that reads an empty corpus and reports success.
        So each backend is asked only for the names it holds and one `fnmatch` decides,
        which also makes a `--ref` run and a working-copy run select the same documents by
        construction rather than by coincidence.

        The sort is explicit for the same reason: `ls-files` sorts by full path and
        `ls-tree` in tree order, which differ, and the index's line order is part of its
        bytes.
        """
        if self.ref:
            out = self._git("ls-tree", "-r", "-z", "--name-only", self.ref)
        else:
            out = self._git("ls-files", "-z")
        drop = set(exclude)
        names = [
            n for n in filter(None, out.split("\0"))
            if n not in drop and any(fnmatch.fnmatchcase(n, pat) for pat in scope)
        ]
        return sorted(names)

    def read(self, path):
        """A document's text, or None where it is tracked but absent from the working copy."""
        if self.ref:
            return self._git("show", f"{self.ref}:{path}")
        p = self.repo / path
        return p.read_text() if p.exists() else None

    def read_optional(self, path):
        """The text at `path`, or None where this tree does not hold it at all.

        Separate from `read` rather than folded into it. `read`'s callers take their paths
        from `paths()`, so a path missing there is a genuine failure and a tolerant `read`
        would swallow it; this one is for a path that may legitimately not exist -- a
        declaration a repository has not made yet. `git show` exits non-zero for a path a
        ref does not hold, where the working-copy branch already answers None.
        """
        try:
            return self.read(path)
        except subprocess.CalledProcessError:
            return None

    def describe(self):
        return f"{self.repo}@{self.ref}" if self.ref else str(self.repo)
