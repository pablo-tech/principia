#!/usr/bin/env python3
"""Generate a repository's heading index — every `##`/`###` heading, grouped by document.

    gen_headings.py --repo <path>                       write HEADINGS.md
    gen_headings.py --repo <path> --check               say whether it is stale, exit 1
    gen_headings.py --repo <path> --ref origin/main     read the commit, not the checkout
    gen_headings.py --repo <path> --scope 'planning/*.md' --out planning/HEADINGS.md

**It is the fallback for a question whose subject is unknown, not the first move.** The
entry point puts three ranked commands ahead of it, because a ranked body grep answers
the question this index cannot — a word that appears in no heading at all — and a heading
sweep over 21 MB of markdown costs 31 ms, which is less than reading one file whose
relevance has not yet been established.

Three shapes here are deliberate rather than incidental.

**The index carries no `##` heading of its own.** Every line is a list item, so the index
of a repository's headings is not itself in that repository's headings: the TOC
generator's predicate cannot select it, and `git grep -nE '^#{2,3} '` returns exactly
what it returned before the file existed. An index that doubled the output of the router
it is a fallback to would cost the router to buy itself.

**The title block is the repository's prose, not the generator's.** It is read from
`.retrieval/headings.title` where there is one -- through the tree, so at the ref like
every other document here -- and so the generator owns the mechanism while the repository
owns what it says about itself — which is also what lets one generator
serve repositories whose corpora argue for different things. Only three tokens are
substituted (`{headings}`, `{docs}`, `{out}`), by replacement rather than by `format`, so
a title carrying a brace for any other reason is left alone.

**No date and no tree ref is written into the file.** A tree ref embedded in a generated
file changes the file on every commit, so `--check` would report it stale always and the
staleness signal would carry no information. `git log -1 --format='%h %ad' <out>` answers
when it was taken, off the tree rather than out of the text, and cannot drift from it.
"""
import pathlib
import sys

import config
import scan
from slugify import Slugger

DEFAULT_OUT = "HEADINGS.md"
DEFAULT_TITLE = """\
# {out}

**Every `##` and `###` heading here, grouped by document — the fallback for a question whose
subject is unknown.** It is a projection and not a source: a generator writes it whole and nothing
in it is edited by hand. The ranked commands in this repository's entry point come first, and
answer a word that appears in no heading at all, which this cannot.

**{headings} headings across {docs} documents**, a measurement of the commit this file was last
generated in — `git log -1 --format='%h %ad' {out}` is its date, read off the tree rather than
typed into the text, where it could not drift from the tree because nothing would rewrite it.
"""


TITLE_FILE = ".retrieval/headings.title"


def title_for(tree, template=None):
    """The title block: an explicit file, the repository's own, or the default.

    **The repository's own is read through the tree, and so at the ref**, like every
    other document. Read off the working copy instead -- which it was until a gate run
    measured it -- a `--ref origin/main` run takes its body from the commit and its title
    from whatever branch the checkout sits on, so one file is assembled from two trees and
    nothing says so. An explicit `--title` is a path the caller named and is read off
    disk, which is the whole point of the flag.
    """
    if template is not None:
        return pathlib.Path(template).read_text()
    own = tree.read_optional(TITLE_FILE)
    return own if own is not None else DEFAULT_TITLE


def render(tree, out=DEFAULT_OUT, scope=("*.md",), template=None):
    """The index as it should be, plus the two counts its title block states."""
    body, docs, total = [], 0, 0
    for name in tree.paths(scope=scope, exclude=(out,)):
        text = tree.read(name)
        if text is None:
            continue
        items = scan.headings(scan.strip_block(text))
        if not items:
            continue
        docs += 1
        slug = Slugger()
        body.append(f"- **[{name}]({name})**")
        for level, raw in items:
            anchor = scan.anchor_text(raw)
            indent = "    " if level == 2 else "        "
            body.append(f"{indent}- [{scan.label(anchor)}]({name}#{slug(anchor)})")
            total += 1
    title = (title_for(tree, template)
             .replace("{headings}", str(total))
             .replace("{docs}", str(docs))
             .replace("{out}", out))
    return title + "\n" + "\n".join(body) + "\n", total, docs


def usage():
    print(__doc__.split("\n\n")[0].strip(), file=sys.stderr)
    print(__doc__.split("\n\n")[1].rstrip(), file=sys.stderr)
    return 2


def main(argv):
    opts, rest, i = {}, [], 0
    flags = ("--repo", "--out", "--ref", "--scope", "--title", "--print")
    while i < len(argv):
        a = argv[i]
        if a == "--check":
            opts["check"] = True
        elif a == "--print":
            opts["print"] = True
        elif a in flags and i + 1 < len(argv):
            opts[a.lstrip("-")] = argv[i + 1]
            i += 1
        else:
            rest.append(a)
        i += 1
    if rest or "repo" not in opts:
        return usage()

    out = opts.get("out", DEFAULT_OUT)
    scope = config.split_scope(opts["scope"]) if "scope" in opts else ("*.md",)
    tree = scan.Tree(opts["repo"], ref=opts.get("ref"))
    new, total, docs = render(tree, out=out, scope=scope, template=opts.get("title"))
    counted = f"{total} headings in {docs} documents"

    if opts.get("print"):
        sys.stdout.write(new)
        return 0

    p = pathlib.Path(tree.repo) / out
    old = p.read_text() if p.exists() else None
    if new == old:
        print(f"{out}: up to date, {counted}")
        return 0
    if opts.get("check"):
        print(f"{out}: STALE, {counted}", file=sys.stderr)
        return 1
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(new)
    print(f"{out}: {'rewritten' if old else 'written'}, {counted}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
