#!/usr/bin/env python3
"""`.retrieval/exclude` — the paths a retrieval layer may not open or quote.

    exclude.py --repo <path>            print each rule as `glob<TAB>reason`
    exclude.py --repo <path> --check    every glob must match a tracked path, exit 1 otherwise
    exclude.py --repo <path> --match <path>   say whether one path is excluded, exit 0 if it is
    exclude.py --repo <path> --cited    no generated surface may offer an excluded path, exit 1

`<glob>` TAB `<reason>`, one per line, `#` comments. The glob is matched against a
repository-relative path with `fnmatch`, where `*` crosses a `/` — deliberately, so
`tax/records/*` names a whole subtree without a second syntax for it.

**Why a file at all, when the rule is already written in prose.** A reading rule that
says no analyte value, score, reference range, diagnosis, weight or dose is ever
transcribed, and names the files that are never opened, is addressed to a reader with a
human in the loop. A server has no reader. So the rule is written once in a form a
process can enforce, and the prose becomes a projection of it rather than a second copy
— which is the same test every other generated surface here is held to.

**What `--cited` refuses is a *surface*, and not a mention.** The contract asks that no
excluded path be cited as readable, and the first reading of that — no markdown link may
resolve to an excluded path — was measured against the vault that owns the first exclude
file and found 28 such links in 5 documents, every one of them a records document naming
the record that holds an answer. That is the repository answering at class level, which is
the thing its own reading rule explicitly permits and the only way a question like "is
there a 2019 return" gets answered at all; a check failing it would be refusing the
correct behaviour, and the predictable repair is somebody deleting the citation. So the
subject is narrowed to what this layer itself *generates and routes with*: the heading
projection's corpus, the links inside generated Contents blocks, the whole of the
generated index, and the alias table's own rows. A hand-written sentence citing a record
is not a retrieval surface. The rule stays "never opened and never quoted", enforced where
the layer does the offering, and prose stays the author's.

**A rule that matches nothing is the failure mode this file is designed against**, which
is why `--check` exists and why the repository's verify script runs it: a typo or a
renamed subject leaves the rule being enforced against nothing, reading as protection,
with the file it was written for now readable. Nothing else notices.
"""
import fnmatch
import pathlib
import posixpath
import re
import sys

import aliases
import config
import scan

PATH = ".retrieval/exclude"


def parse(text, where=PATH):
    """(glob, reason) per rule, from the file's text. `where` is what a complaint names.

    Separate from `rules` so a reader that already holds the bytes -- the projection
    generator, which reads the file through a tree so a `--ref` run is one tree -- parses
    the same text with the same refusals rather than a second parser that agrees today.
    """
    out = []
    for n, raw in enumerate(text.split("\n"), 1):
        line = raw.split("#", 1)[0].rstrip()
        if not line.strip():
            continue
        parts = line.split("\t", 1)
        if len(parts) != 2 or not parts[1].strip():
            raise SystemExit(f"{where}:{n}: expected `<glob>\\t<reason>`, got {raw.strip()!r} — "
                             "a rule with no reason is a rule nobody can review")
        out.append((parts[0].strip(), parts[1].strip()))
    return out


def rules(repo):
    """(glob, reason) per rule. Empty where the repository declares none."""
    p = pathlib.Path(repo) / PATH
    if not p.exists():
        return []
    return parse(p.read_text(), where=str(p))


def excluded(repo_rules, path):
    """True where a repository-relative path is named by any rule."""
    return any(fnmatch.fnmatchcase(path, g) for g, _ in repo_rules)


def check(repo, tree=None):
    """Complaints about rules that match no tracked path, and the counts."""
    rs = rules(repo)
    tree = tree or scan.Tree(repo)
    tracked = tree.paths(scope=("*",))
    bad, hit = [], 0
    for glob, reason in rs:
        n = sum(1 for p in tracked if fnmatch.fnmatchcase(p, glob))
        hit += n
        if n == 0:
            bad.append(f"{PATH}: {glob!r} matches no tracked path ({reason})")
    return rs, hit, bad


LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")


def links(doc, text):
    """Every repository-relative path a markdown link in `text` resolves to.

    An anchor, a URL and a mail link resolve to no path in this repository and are
    dropped; a relative href is resolved against the linking document's own directory,
    which is what makes a `../` link from a subfolder comparable to a rule's glob.
    """
    out = []
    base = posixpath.dirname(doc)
    for href in LINK.findall(text):
        href = href.split("#", 1)[0].strip()
        if not href or ":" in href.split("/", 1)[0]:
            continue
        out.append(posixpath.normpath(posixpath.join(base, href)).lstrip("/"))
    return out


def cited(tree, cfg=None, repo_rules=None):
    """Complaints: a generated surface offering an excluded path. See the note above.

    Four subjects, which together are everything this layer routes with. Anything else in
    a document is prose, and prose is the author's.
    """
    cfg = cfg or config.read(tree.repo)
    repo_rules = repo_rules if repo_rules is not None else rules(tree.repo)
    if not repo_rules:
        return []
    bad = []
    scope = config.scope(cfg)
    corpus = tree.paths(scope=scope, exclude=(cfg["out"],))

    for path in corpus:
        if excluded(repo_rules, path):
            bad.append(f"{path}: in scope for the heading projection and excluded — the "
                       f"projection would quote its headings. Narrow `scope` in "
                       f"{config.PATH} or drop the rule")

    for doc in corpus:
        text = tree.read(doc) or ""
        for m in re.finditer(scan.BEGIN_RE + r".*?" + scan.END_RE, text, flags=re.S):
            for path in links(doc, m.group(0)):
                if excluded(repo_rules, path):
                    bad.append(f"{doc}: its generated Contents block links {path!r}, "
                               "which is excluded")

    out_text = tree.read_optional(cfg["out"])
    if out_text:
        for path in links(cfg["out"], out_text):
            if excluded(repo_rules, path):
                bad.append(f"{cfg['out']}: the generated index links {path!r}, which is excluded")

    entry_text = tree.read_optional(cfg["entry"]) or ""
    for words, folder, then in aliases.rows(entry_text):
        for path in aliases.resolve(tree, folder, then):
            if excluded(repo_rules, path):
                bad.append(f"{cfg['entry']}: alias row {words!r} routes to {path!r}, "
                           "which is excluded")
    return bad


def main(argv):
    if "--repo" not in argv:
        print(__doc__.split("\n\n")[1].rstrip(), file=sys.stderr)
        return 2
    repo = argv[argv.index("--repo") + 1]
    if "--match" in argv:
        path = argv[argv.index("--match") + 1]
        hit = excluded(rules(repo), path)
        print(f"{path}: {'excluded' if hit else 'not excluded'}")
        return 0 if hit else 1
    if "--cited" in argv:
        tree = scan.Tree(repo)
        bad = cited(tree)
        for line in bad:
            print(line, file=sys.stderr)
        print(f"{len(rules(repo))} exclude rules, {len(bad)} cited by a generated surface")
        return 1 if bad else 0
    if "--check" in argv:
        rs, hit, bad = check(repo)
        for line in bad:
            print(line, file=sys.stderr)
        print(f"{len(rs)} exclude rules covering {hit} tracked paths, {len(bad)} matching nothing")
        return 1 if bad else 0
    for glob, reason in rules(repo):
        print(f"{glob}\t{reason}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
