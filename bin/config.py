#!/usr/bin/env python3
"""A repository's retrieval declarations, read from `.retrieval/config`.

    config.py --repo <path>              print every key, resolved
    config.py --repo <path> <key>        print one key, resolved, exit 1 if it has no value

`key = value`, one per line, `#` to end of line is a comment. Four keys, each with a
default, so a repository that declares nothing still has an answer:

| Key | Default | What it decides |
|---|---|---|
| `entry` | `AGENTS.md` | the document a question is routed from |
| `out` | `HEADINGS.md` | where the heading projection is written |
| `scope` | `*.md` | which documents the layer covers, comma-separated |
| `quote` | `line` | what a retrieval hit may return: `line`, `heading` or `none` |

**`quote` is the one key whose default is the permissive answer, and that is deliberate
rather than an oversight.** A repository holding records that must not be transcribed
declares `quote = heading` and is then held to it by the service; a repository that has
not thought about it is code, where a matched line is the useful part of the answer. The
fail-closed direction lives one level up instead, in which repositories a router may
read at all — a repository that the declaration a router resolves its corpus from does
not mark as retrievable is not reachable, so an undeclared repository is unreachable
rather than quotable.
"""
import pathlib
import sys

PATH = ".retrieval/config"
DEFAULTS = {"entry": "AGENTS.md", "out": "HEADINGS.md", "scope": "*.md", "quote": "line"}
QUOTE_VALUES = ("line", "heading", "none")


def parse(text, where=PATH):
    """Every key, from the file's text: the declarations over the defaults.

    Separate from `read` for the reason `exclude.py`'s own split records: a reader that
    already holds the bytes -- the router, which reads a repository at a ref because
    `CONTRACT.md` § 5 says a declaration is read from a commit and not from whatever
    branch a checkout was left on -- parses the same text with the same refusals, rather
    than a second parser that agrees today. `where` is what a complaint names, so a
    refusal still says which repository and which ref the bad line came from.
    """
    cfg = dict(DEFAULTS)
    for n, raw in enumerate(text.split("\n"), 1):
        line = raw.split("#", 1)[0].strip()
        if not line:
            continue
        if "=" not in line:
            raise SystemExit(f"{where}:{n}: not `key = value`: {raw.strip()!r}")
        k, v = (s.strip() for s in line.split("=", 1))
        if k not in DEFAULTS:
            raise SystemExit(f"{where}:{n}: unknown key {k!r}, expected one of {', '.join(DEFAULTS)}")
        cfg[k] = v
    if cfg["quote"] not in QUOTE_VALUES:
        raise SystemExit(f"{where}: quote = {cfg['quote']!r}, expected one of {', '.join(QUOTE_VALUES)}")
    return cfg


def read(repo):
    """Every key for this repository, read off the working copy."""
    p = pathlib.Path(repo) / PATH
    return parse(p.read_text() if p.exists() else "", where=str(p))


def split_scope(value):
    """The comma-separated `scope` value as globs, stripped.

    One function because there are three callers and they used to disagree: `gen_headings.py`
    split its own `--scope` string without stripping, so a value written with a space after the
    comma — the way anybody writes a list — handed the generator a glob beginning with a space,
    which `fnmatch` matches against nothing. The projection then indexed the first glob's
    documents alone while `verify-retrieval.sh`, which reads the same value through `scope()`
    below, had the whole corpus in mind and reported the projection stale with no clue why.
    """
    return tuple(s.strip() for s in value.split(",") if s.strip())


def scope(cfg):
    return split_scope(cfg["scope"])


def main(argv):
    if "--repo" not in argv:
        print(__doc__.split("\n\n")[1].rstrip(), file=sys.stderr)
        return 2
    i = argv.index("--repo")
    repo = argv[i + 1]
    keys = [a for a in argv if a not in ("--repo", repo)]
    cfg = read(repo)
    if not keys:
        for k in DEFAULTS:
            print(f"{k} = {cfg[k]}")
        return 0
    for k in keys:
        if k not in cfg:
            print(f"unknown key {k!r}", file=sys.stderr)
            return 1
        print(cfg[k])
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
