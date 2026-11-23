#!/usr/bin/env python3
"""The alias table — the one hand-written surface of the layer, parsed and checked.

    aliases.py --repo <path>            print each row as `words<TAB>folder<TAB>then`
    aliases.py --repo <path> --check    resolve every folder and document, exit 1 on a bad row

**Why it is authored and everything else generated.** Spontaneous word choice for the
same object agrees between two people under 20% of the time (Furnas, Landauer, Gomez and
Dumais, "The vocabulary problem in human-system communication", Communications of the ACM
30(11), 1987), so a question's words are routinely absent from the records that answer
it — and no generator can invent a synonym. The table buys exactly that reach, which is
also the only thing an embedding index would have bought over a ranked grep.

**An omission under-routes and a wrong row mis-routes, and those are not the same cost.**
Under-routing is recovered from by the ranked grep the entry point puts ahead of this
table; mis-routing sends a reader to a folder that will not answer and looks like an
answer. So a row exists only where the folder is certain, and `--check` resolves every
path a row names rather than trusting it: a row naming a folder that has been renamed is
the failure this check exists to catch, and nothing else in the layer would notice.
"""
import re
import sys

import scan

BEGIN = "<!-- BEGIN ALIASES -->"
END = "<!-- END ALIASES -->"
NONE = "—"


def block(text):
    """The table's rows, between the markers. Empty where there is no table."""
    m = re.search(re.escape(BEGIN) + r"(.*?)" + re.escape(END), text, flags=re.S)
    return m.group(1) if m else ""


def rows(text):
    """(words, folder, then) per data row, with the cells' own markup removed."""
    out = []
    for line in block(text).split("\n"):
        line = line.strip()
        if not line.startswith("|") or set(line) <= set("|-: "):
            continue
        cells = [c.strip().strip("`").strip() for c in line.strip("|").split("|")]
        if len(cells) < 2 or cells[0].lower().startswith("a question saying"):
            continue
        out.append((cells[0], cells[1], cells[2] if len(cells) > 2 else NONE))
    return out


def resolve(tree, folder, then):
    """What a row points at, as paths that must be tracked. Empty where it points nowhere."""
    want = []
    folder = folder.rstrip("/")
    if folder:
        want.append(folder)
    if then and then != NONE:
        want.append(f"{folder}/{then}".lstrip("/").rstrip("/"))
    return want


def check(tree, entry):
    """Every row's paths, resolved against the tree. Returns a list of complaints."""
    text = tree.read(entry)
    if text is None:
        return [f"{entry}: not tracked, so there is no alias table to check"]
    table = rows(text)
    if not table:
        return [f"{entry}: no alias table between {BEGIN} and {END}"]
    tracked = tree.paths(scope=("*",))
    dirs = {p.rsplit("/", 1)[0] for p in tracked if "/" in p}
    for p in list(dirs):
        parts = p.split("/")
        for n in range(1, len(parts)):
            dirs.add("/".join(parts[:n]))
    bad = []
    for words, folder, then in table:
        for path in resolve(tree, folder, then):
            if path in dirs or path in set(tracked):
                continue
            bad.append(f"{entry}: row {words!r} names {path!r}, which is neither a tracked "
                       "path nor a directory holding one")
    return bad


def main(argv):
    if "--repo" not in argv:
        print(__doc__.split("\n\n")[1].rstrip(), file=sys.stderr)
        return 2
    i = argv.index("--repo")
    repo = argv[i + 1]
    import config
    cfg = config.read(repo)
    tree = scan.Tree(repo, ref=None)
    if "--check" in argv:
        bad = check(tree, cfg["entry"])
        for line in bad:
            print(line, file=sys.stderr)
        n = len(rows(tree.read(cfg["entry"]) or ""))
        print(f"{cfg['entry']}: {n} alias rows, {len(bad)} unresolved")
        return 1 if bad else 0
    for row in rows(tree.read(cfg["entry"]) or ""):
        print("\t".join(row))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
