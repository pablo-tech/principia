#!/usr/bin/env bash
# The retrieval layer's own suite: the generators, the readers they share, and the refusals.
#   bash bin/retrieval.test.sh
#
# `doctrine/retrieval.md` says that every surface of a route which can be derived is generated from
# the prose it describes, and that a projection is repairable by hand from what it projects or else
# it is a second copy. These files are the mechanism for that half of the document: the heading
# index, the in-file Contents block and the readable form of a refusal, each derived, plus the
# readers they are built on and the verifier an author runs before a change is a commit.
#
# **Every fixture is a scratch repository this file builds**, and that is a condition of the layer
# living here rather than in the tenant that first needed it: a suite that read a real corpus to
# prove a generator works would make the generator's correctness a property of one tree, and the
# tenant whose tree it was could not then be told apart from the generator. Nothing below reads
# anything outside `mktemp -d`.
#
# **Several of these checks are positive controls, and they are the reason to trust the rest.** A
# verifier that has never refused anything is not known to refuse (`doctrine/testing.md`): so an
# alias row pointing at a renamed folder, an exclude rule matching nothing, an exclude rule with no
# reason, a hand-written Contents block and a misspelled config key each get a check asserting the
# non-zero exit rather than the zero.
#
# The python-level assertions run out of `probes.py`, written into the scratch directory rather than
# inlined as `python3 -c` strings: a check's condition is `eval`'d, so an inlined program is quoted
# three deep, and the failure mode is a SyntaxError that reports a defect in the suite as a defect
# in the subject.
#
# `check()` eval's its argument, so every condition below is a single-quoted expression on purpose —
# the expansion is meant to happen at eval time, inside the scratch directory the check is about,
# and double-quoting one here would resolve `$T` and `$DIR` while this file is being read rather
# than while the check runs.
# shellcheck disable=SC2016,SC2034
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$DIR/check.sh"

T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
export PYTHONPATH="$DIR"
G() { git -c user.name=t -c user.email=t@t "$@"; }
py() { python3 "$DIR/$1" "${@:2}"; }
probe() { python3 "$T/probes.py" "$@"; }
filler() { head -c 2500 /dev/zero | tr '\0' 'x'; }
commit_all() { G -C "$1" add -A; G -C "$1" commit -q -m x; }

cat > "$T/probes.py" <<'PROBES'
"""One printed value per named probe, so a shell check compares strings and nothing else."""
import sys

import scan
from slugify import Slugger, gh_slug

name, args = sys.argv[1], sys.argv[2:]
if name == "slug":
    print(gh_slug(args[0]))
elif name == "slug-repeat":
    s = Slugger()
    print(" ".join(s(a) for a in args))
elif name == "headings":
    print(len(scan.headings(args[0].replace("\\n", "\n"))))
elif name == "headings-stripped":
    print(len(scan.headings(scan.strip_block(args[0].replace("\\n", "\n")))))
elif name == "strip":
    print(scan.strip_block(args[0].replace("\\n", "\n")).strip())
elif name == "anchor":
    print(scan.anchor_text(args[0]))
elif name == "paths":
    print(",".join(scan.Tree(args[0]).paths()))
elif name == "paths-excluding":
    print(",".join(scan.Tree(args[0]).paths(exclude=(args[1],))))
elif name == "ref-agrees":
    w = scan.Tree(args[0]).paths()
    r = scan.Tree(args[0], ref="HEAD").paths()
    print(len(w) if w == r else f"disagree {w} != {r}")
else:
    raise SystemExit(f"unknown probe {name!r}")
PROBES

# ---------------------------------------------------------------- the layer is here at all
# The files are beside this suite and the four run as commands are executable. A suite that
# imported the modules and asserted nothing about the mode would pass on a layer nobody can invoke.
for f in slugify.py scan.py config.py aliases.py exclude.py; do
  check "$f is beside this suite" '[ -f "$DIR/$f" ]'
done
for f in gen_headings.py gen_toc.py gen_exclude.py verify-retrieval.sh; do
  check "$f is here and executable" '[ -x "$DIR/$f" ]'
done

# ---------------------------------------------------------------- slugify
check "a heading slugs the way GitHub slugs it" \
  '[ "$(probe slug "1. The procedure")" = "1-the-procedure" ]'
check "punctuation is dropped and spaces become hyphens" \
  '[ "$(probe slug "What may be read, and what may be written?")" = "what-may-be-read-and-what-may-be-written" ]'
check "a repeated heading gets GitHub's numeric suffix rather than colliding" \
  '[ "$(probe slug-repeat "Known gaps" "Known gaps" "Known gaps")" = "known-gaps known-gaps-1 known-gaps-2" ]'

# ---------------------------------------------------------------- scan
check "a heading inside a fenced block is not a heading" \
  '[ "$(probe headings "## a\n\`\`\`\n## b\n\`\`\`\n### c\n")" = 2 ]'
check "a generated Contents block is stripped before headings are read" \
  '[ "$(probe headings-stripped "<!-- BEGIN CONTENTS x -->\n## in\n<!-- END CONTENTS -->\n## out\n")" = 1 ]'
# A repository's marker names the generator that writes it, and a scanner insisting on one
# spelling would stop stripping the block the day that name changed — which does not fail:
# it adds one phantom "Contents" heading per document to the index.
check "a marker naming another generator is still stripped" \
  '[ -z "$(probe strip "<!-- BEGIN CONTENTS — generated by somebody_else.py -->\nx\n<!-- END CONTENTS -->\n")" ]'
check "a heading that is a link slugs to its text and not to the href" \
  '[ "$(probe anchor "[The plan](PLAN.md) for 2026")" = "The plan for 2026" ]'

scratch_repo "$T/r" a.md docs/b.md docs/c.txt
G -C "$T/r" commit -q -m one
check "the scope selects by glob across directories, as ls-files does" \
  '[ "$(probe paths "$T/r")" = "a.md,docs/b.md" ]'
# The defect this pins is silent and total: `git ls-tree -r -- "*.md"` matches a path
# prefix where `ls-files` globs, so a ref-mode generator asked that way reads an empty
# corpus and reports success. One `fnmatch` in Python is what makes the two agree.
check "a ref selects exactly what the working copy selects" \
  '[ "$(probe ref-agrees "$T/r")" = 2 ]'
check "an excluded path is not selected" \
  '[ "$(probe paths-excluding "$T/r" a.md)" = "docs/b.md" ]'

# ---------------------------------------------------------------- config
mkdir -p "$T/r/.retrieval"
check "a repository declaring nothing still has four answers" \
  '[ "$(py config.py --repo "$T/r" | wc -l)" = 4 ]'
check "quote defaults to line, the permissive answer, for a repository that has not thought about it" \
  '[ "$(py config.py --repo "$T/r" quote)" = line ]'
check "a declaration overrides the default" \
  'printf "quote = heading\nout = INDEX.md  # a comment\n" > "$T/r/.retrieval/config"; [ "$(py config.py --repo "$T/r" quote)" = heading ]'
check "a trailing comment is not part of the value" '[ "$(py config.py --repo "$T/r" out)" = INDEX.md ]'
check "an undeclarable quote policy is refused rather than defaulted" \
  'printf "quote = sometimes\n" > "$T/r/.retrieval/config"; ! py config.py --repo "$T/r" quote >/dev/null 2>&1'
check "a misspelled key is refused by name rather than ignored" \
  'printf "qoute = heading\n" > "$T/r/.retrieval/config"; py config.py --repo "$T/r" >/dev/null 2>"$T/err"; grep -q "unknown key" "$T/err"'
rm -f "$T/r/.retrieval/config"

# ---------------------------------------------------------------- gen_headings
rm -rf "$T/h"; G init -q "$T/h"; mkdir -p "$T/h/.retrieval"
printf '# One\n## Alpha\n### Alpha detail\n## Known gaps — what this does not hold\n' > "$T/h/one.md"
printf '# Two\n## Beta\n' > "$T/h/two.md"
printf '# Entry\n<!-- BEGIN ALIASES -->\n\n| A question saying | Folder | Then |\n|---|---|---|\n| beta, second | `` | two.md |\n\n<!-- END ALIASES -->\n' > "$T/h/AGENTS.md"
commit_all "$T/h"
check "the index is written and counts what it wrote" \
  'py gen_headings.py --repo "$T/h" | grep -q "4 headings in 2 documents"'
check "a second run reports up to date and rewrites nothing" \
  'py gen_headings.py --repo "$T/h" --check | grep -q "up to date"'
# The index carries no `##` heading of its own, so it adds nothing to the ranked heading
# grep it is a fallback to, and the TOC predicate can never select it.
check "the index is not itself in the corpus it indexes" \
  '! grep -qE "^#{2,3} " "$T/h/HEADINGS.md"'
check "the index names no date, so a staleness signal carries information" \
  '! grep -qE "202[0-9]-[0-9]{2}-[0-9]{2}" "$T/h/HEADINGS.md"'
check "the index does not index itself" '! grep -q "HEADINGS.md#" "$T/h/HEADINGS.md"'
check "a new heading makes the index stale, and --check says so without writing" \
  'printf "## Gamma\n" >> "$T/h/two.md"; ! py gen_headings.py --repo "$T/h" --check >/dev/null 2>&1 && ! grep -q Gamma "$T/h/HEADINGS.md"'
check "a ref reads the commit and not the edited checkout" \
  '! py gen_headings.py --repo "$T/h" --ref HEAD --print | grep -q Gamma'
check "the repository owns what its index says about itself" \
  'printf "# Mine\n\n**{headings} headings, {docs} documents, in {out}**\n" > "$T/h/.retrieval/headings.title"; py gen_headings.py --repo "$T/h" >/dev/null; head -1 "$T/h/HEADINGS.md" | grep -q "^# Mine$"'
check "only the three declared tokens are substituted" \
  'grep -q "5 headings, 2 documents, in HEADINGS.md" "$T/h/HEADINGS.md"'
check "a brace the generator does not own is left alone rather than raising" \
  'printf "# Braces\n\nA literal {not_a_token} and {headings}\n" > "$T/h/.retrieval/headings.title"; py gen_headings.py --repo "$T/h" >/dev/null; grep -q "A literal {not_a_token} and 5" "$T/h/HEADINGS.md"'
rm -f "$T/h/.retrieval/headings.title"

# The title is read through the tree like every other document, which is a separate claim
# from the body's above and so a separate check. Read off the working copy instead -- which
# it was until a gate run against a real repository measured it -- a `--ref` run takes its
# body from the commit and its title from whatever branch the checkout happens to sit on,
# and one file is assembled from two trees with nothing saying so.
rm -rf "$T/ht"; G init -q "$T/ht"; mkdir -p "$T/ht/.retrieval"
printf '# Doc\n## Alpha\n' > "$T/ht/one.md"
printf '# Committed title\n\n{headings} in {out}\n' > "$T/ht/.retrieval/headings.title"
commit_all "$T/ht"
printf '# Edited title\n' > "$T/ht/.retrieval/headings.title"
check "a ref reads the committed title, so one file is not assembled from two trees" \
  'py gen_headings.py --repo "$T/ht" --ref HEAD --print | head -1 | grep -q "^# Committed title$"'
check "and with no ref it reads the checkout, which is what an author is editing" \
  'py gen_headings.py --repo "$T/ht" --print | head -1 | grep -q "^# Edited title$"'
check "a ref holding no declaration falls back to the default rather than raising" \
  'rm -f "$T/ht/.retrieval/headings.title"; commit_all "$T/ht"; py gen_headings.py --repo "$T/ht" --ref HEAD --print | head -1 | grep -q "^# HEADINGS.md$"'

# The generator split `--scope` on the comma and did not strip the pieces, while `config.py`
# -- which `verify-retrieval.sh` reads the same value through -- did. So a list written the way
# anybody writes one indexed the first glob's documents alone, and the verifier, holding the
# whole corpus in mind, reported the projection stale and named no cause. `pablo-tech/pilos`
# met it and its `.retrieval/config` carries a comment saying the repair belongs in the hub.
# `config.split_scope` is now the one splitter for all three callers, and this is what pins it.
rm -rf "$T/hs"; G init -q "$T/hs"; mkdir -p "$T/hs/docs"
printf '# Root\n## Alpha\n' > "$T/hs/one.md"
printf '# Nested\n## Beta\n' > "$T/hs/docs/two.md"
commit_all "$T/hs"
check "a scope written with a space after the comma selects every glob in it" \
  'py gen_headings.py --repo "$T/hs" --scope "one.md, docs/*.md" | grep -q "2 headings in 2 documents"'

# ---------------------------------------------------------------- gen_toc
{ printf '# Title\n\nSome prose.\n\n---\n\n'; for i in $(seq 9); do printf '## Section %s\n\n%s\n\n' "$i" "$(filler)"; done; } > "$T/h/long.md"
commit_all "$T/h"
check "the predicate selects a long document with enough headings" \
  '[ "$(py gen_toc.py --repo "$T/h" --list)" = 1 ]'
check "a short document is not selected" \
  '! py gen_toc.py --repo "$T/h" --all | grep -q "^one.md"'
check "the block is inserted above the rule that introduces the first heading, not below it" \
  'py gen_toc.py --repo "$T/h" --all >/dev/null; [ "$(grep -n "BEGIN CONTENTS" "$T/h/long.md" | cut -d: -f1)" -lt "$(grep -n "^---$" "$T/h/long.md" | head -1 | cut -d: -f1)" ]'
check "a second run is idempotent" 'py gen_toc.py --repo "$T/h" --all --check | grep -q "up to date"'
check "every heading of the document is in its block, and the block's own is not" \
  '[ "$(grep -c "(#section-" "$T/h/long.md")" = 9 ]'
# A question-keyed Contents, or a table whose first column is the section, is a better
# artefact than a heading list, and generating over one destroys information.
check "a hand-written Contents is refused loudly and not overwritten" \
  '{ printf "# T\n\n## Contents\n\n- by hand\n\n---\n\n"; for i in $(seq 9); do printf "## S%s\n\n%s\n\n" "$i" "$(filler)"; done; } > "$T/h/hand.md"; commit_all "$T/h"; ! py gen_toc.py --repo "$T/h" hand.md >/dev/null 2>&1 && grep -q "by hand" "$T/h/hand.md"'
check "and the predicate does not select it either" \
  '[ "$(py gen_toc.py --repo "$T/h" --list)" = 1 ]'
rm -f "$T/h/hand.md"

# ---------------------------------------------------------------- aliases
check "the alias table's rows are read without its header or its rule line" \
  '[ "$(py aliases.py --repo "$T/h" | wc -l)" = 1 ]'
check "a row resolving to a tracked document passes" \
  'py aliases.py --repo "$T/h" --check | grep -q "1 alias rows, 0 unresolved"'
# A renamed folder is the failure the table cannot survive and nothing else in the layer
# notices: the table still renders, and the route still reads as an answer.
check "a row naming a folder that does not exist is refused" \
  'printf "# Entry\n<!-- BEGIN ALIASES -->\n\n| A question saying | Folder | Then |\n|---|---|---|\n| beta | \`gone/\` | two.md |\n\n<!-- END ALIASES -->\n" > "$T/h/AGENTS.md"; ! py aliases.py --repo "$T/h" --check >/dev/null 2>&1'
check "an entry point carrying no table at all is reported rather than passing" \
  'printf "# Entry\n" > "$T/h/AGENTS.md"; ! py aliases.py --repo "$T/h" --check >/dev/null 2>&1'

# ---------------------------------------------------------------- exclude
check "an exclude rule naming a tracked path checks out" \
  'printf "two.md\ta reason\n" > "$T/h/.retrieval/exclude"; py exclude.py --repo "$T/h" --check | grep -q "1 exclude rules covering 1 tracked paths, 0 matching nothing"'
check "an excluded path answers excluded" \
  'py exclude.py --repo "$T/h" --match two.md | grep -q ": excluded"'
check "a path no rule names answers not excluded, with a non-zero exit" \
  '! py exclude.py --repo "$T/h" --match one.md >/dev/null 2>&1'
check "a glob crosses a directory separator, so a subtree needs no second syntax" \
  'printf "docs/*\tsubtree\n" > "$T/r/.retrieval/exclude"; py exclude.py --repo "$T/r" --match docs/b.md | grep -q ": excluded"'
# A rule matching nothing is enforced against nothing while reading as protection, and
# the file it was written for is readable. Nothing else notices.
check "a rule matching no tracked path is refused" \
  'printf "records/*\tnothing here\n" > "$T/h/.retrieval/exclude"; ! py exclude.py --repo "$T/h" --check >/dev/null 2>&1'
check "a rule with no reason is refused — a rule nobody can review is not a rule" \
  'printf "two.md\n" > "$T/h/.retrieval/exclude"; ! py exclude.py --repo "$T/h" >/dev/null 2>&1'
check "a comment and a blank line are not rules" \
  'printf "# why\n\ntwo.md\ta reason\n" > "$T/h/.retrieval/exclude"; [ "$(py exclude.py --repo "$T/h" | wc -l)" = 1 ]'

# ---------------------------------------------------------------- gen_exclude
# A separate repository, because every check here is about the pair `.retrieval/exclude`
# and the entry point form, and the fixtures above have spent their entry point proving
# the alias refusals.
rm -rf "$T/e"; G init -q "$T/e"; mkdir -p "$T/e/.retrieval"
printf '# One\n## Alpha\n' > "$T/e/one.md"
printf 'an identifier\n' > "$T/e/secret.txt"
printf 'another\n' > "$T/e/also.txt"
printf 'secret.txt\twhole content is the identifier\nalso*.txt\tthe same, by glob\n' > "$T/e/.retrieval/exclude"
printf '# Entry\n\n<!-- BEGIN EXCLUDE — generated by gen_exclude.py, do not edit by hand -->\n<!-- END EXCLUDE -->\n' > "$T/e/AGENTS.md"
commit_all "$T/e"
check "the block is written between the markers, one bullet per rule" \
  'py gen_exclude.py --repo "$T/e" >/dev/null; [ "$(grep -c "^- \`" "$T/e/AGENTS.md")" = 2 ]'
check "each bullet carries the rule's reason, so the projection is reviewable where it is read" \
  'grep -qF "whole content is the identifier" "$T/e/AGENTS.md"'
# A count of matched paths would make the entry point stale the first time anybody
# committed a record under an already-excluded subtree, which is a projection that goes
# stale on a change it is not about.
check "the block carries no count, so a new file under an excluded subtree does not stale it" \
  'printf "x\n" > "$T/e/also-2.txt"; commit_all "$T/e"; py gen_exclude.py --repo "$T/e" --check | grep -q "up to date"'
check "a second run reports up to date and rewrites nothing" \
  'py gen_exclude.py --repo "$T/e" --check | grep -q "up to date"'
check "--print writes nothing, so the block can be read before it is adopted" \
  'cp "$T/e/AGENTS.md" "$T/e/before"; py gen_exclude.py --repo "$T/e" --print >/dev/null; cmp -s "$T/e/before" "$T/e/AGENTS.md"'
# The Verify row's positive control: a generated block nothing checks is prose wearing a
# marker that promises otherwise.
check "a bullet removed by hand makes --check exit non-zero rather than being rewritten" \
  'cp "$T/e/AGENTS.md" "$T/e/entry.bak"; grep -v "whole content is the identifier" "$T/e/entry.bak" > "$T/e/AGENTS.md"; ! py gen_exclude.py --repo "$T/e" --check >/dev/null 2>&1'
check "and the rewrite restores it, so the repair is the generator and not an edit" \
  'py gen_exclude.py --repo "$T/e" >/dev/null; cmp -s "$T/e/entry.bak" "$T/e/AGENTS.md"'
# Inserting the markers is the author's act. A generator that inserted them would decide
# where in a document the owner reads a refusal.
check "an entry point carrying no markers is refused, and the refusal names the repair" \
  'printf "# Entry\n" > "$T/e/AGENTS.md"; ! py gen_exclude.py --repo "$T/e" >/dev/null 2>"$T/e/err"; grep -q "BEGIN EXCLUDE" "$T/e/err"'
check "a ref reads the commit and not the edited checkout" \
  'py gen_exclude.py --repo "$T/e" --ref HEAD --print | grep -qF "whole content is the identifier"'
check "another document can carry the block, so the refusal is not tied to the entry point" \
  'printf "# Other\n<!-- BEGIN EXCLUDE — generated by gen_exclude.py, do not edit by hand -->\n<!-- END EXCLUDE -->\n" > "$T/e/OTHER.md"; py gen_exclude.py --repo "$T/e" --entry OTHER.md >/dev/null; [ "$(grep -c "^- \`" "$T/e/OTHER.md")" = 2 ]'

# ---------------------------------------------------------------- exclude --cited
# **What `--cited` refuses is a surface and not a mention**, which is the design decision
# this section is the record of. Measured against the first repository to carry an exclude
# file: 28 markdown links in 5 documents resolved to an excluded path, and every one was a
# records document naming the record that holds an answer — the corpus answering at class
# level, which its own reading rule permits. A check failing those would refuse correct
# behaviour, and the predictable repair would be somebody deleting the citation. So the
# subject is narrowed to what this layer generates and routes with, and the three checks
# below are that narrowing in both directions.
rm -rf "$T/x"; G init -q "$T/x"; mkdir -p "$T/x/.retrieval"
printf '# One\n## Alpha\n\nThe answer is in [the record](secret.txt), read at class level.\n' > "$T/x/one.md"
printf 'an identifier\n' > "$T/x/secret.txt"
printf 'secret.txt\twhole content is the identifier\n' > "$T/x/.retrieval/exclude"
printf '# Entry\n<!-- BEGIN ALIASES -->\n\n| A question saying | Folder | Then |\n|---|---|---|\n| alpha | `` | one.md |\n\n<!-- END ALIASES -->\n' > "$T/x/AGENTS.md"
commit_all "$T/x"
check "prose citing an excluded record at class level is the author's, and passes" \
  'py exclude.py --repo "$T/x" --cited | grep -q "1 exclude rules, 0 cited by a generated surface"'
check "an excluded path inside the heading projection's corpus is refused" \
  'printf "one.md\tin scope and excluded\n" > "$T/x/.retrieval/exclude"; ! py exclude.py --repo "$T/x" --cited >/dev/null 2>&1'
check "an alias row routing to an excluded path is refused" \
  'printf "secret.txt\twhole content is the identifier\n" > "$T/x/.retrieval/exclude"; printf "# Entry\n<!-- BEGIN ALIASES -->\n\n| A question saying | Folder | Then |\n|---|---|---|\n| the card | \`\` | secret.txt |\n\n<!-- END ALIASES -->\n" > "$T/x/AGENTS.md"; ! py exclude.py --repo "$T/x" --cited >/dev/null 2>&1'


# ---------------------------------------------------------------- the dependency claim
# Stdlib only, enumerated rather than asserted in a comment. This layer is run by whatever python3
# the machine has and by nothing it had to install, which is what makes installing it a path change
# rather than an environment — and an enumeration is the only form of that claim a check can hold. A
# new import is meant to fail here and be argued for in the list.
check "nothing in this layer imports outside the standard library" \
  '! grep -rhE "^(import|from) " "$DIR"/*.py | grep -vE "^(import|from) (fnmatch|json|os|pathlib|posixpath|re|subprocess|sys|unicodedata|aliases|config|exclude|scan|slugify)" | grep -q .'

finish
