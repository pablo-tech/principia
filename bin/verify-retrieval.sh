#!/usr/bin/env bash
#
# Every mechanical claim the retrieval contract makes about one repository.
#
#   bash verify-retrieval.sh <repo>        default: the repository this file sits in
#
# `CONTRACT.md` beside this file is what it checks: five surfaces, of which one is
# authored and the rest are projections of the prose they index. A projection nothing
# re-derives is a staleness source wearing a marker that promises otherwise, so this is
# the one command that says whether a repository's layer is still true of its tree.
#
# **A check whose subject does not exist reports SKIP and does not fail the run**, which
# is what lets this land in a repository before its layer does, and what lets one script
# serve a records vault and a code repository without a mode flag. A SKIP is printed
# precisely so it cannot be mistaken for a pass.
#
# It judges a **working copy**, deliberately, because it is run by the author of a change
# before that change is a commit. The router and the service read `origin/main` instead,
# for the reason `scan.py` states: a checkout is whatever branch somebody left it on.
set -uo pipefail

R="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="${1:-$R}"
# Asked of git rather than by testing for a `.git` directory, because in a worktree `.git`
# is a *file* holding a pointer — so the directory test refused every worktree, which is
# the one place this is run from: a change is verified before it is a commit, and nothing
# is edited in a standing checkout. `--show-toplevel` is compared to the argument so a
# subdirectory is still refused rather than silently verified against relative paths that
# resolve from somewhere else.
top="$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null || true)"
repo="$(cd "$repo" 2>/dev/null && pwd -P)" || repo=''
if [ -z "$repo" ] || [ "$top" != "$repo" ]; then
  printf -- '-- %s is not the root of a git repository or worktree\n' "${1:-$R}" >&2; exit 2
fi

fail=0
pass() { printf '  PASS  %s\n' "$1"; }
skip() { printf '  SKIP  %s\n' "$1"; }
bad()  { printf '  FAIL  %s\n' "$1"; fail=1; }
head2() { printf '\n%s\n' "$1"; }
cfg() { python3 "$R/config.py" --repo "$repo" "$1"; }

printf -- '-- retrieval verify, %s, %s at tree %s\n' \
  "$(date +%Y-%m-%d)" "$(basename "$repo")" \
  "$(git -C "$repo" rev-parse --short HEAD 2>/dev/null || echo unknown)"

entry="$(cfg entry)"; out="$(cfg out)"; scope="$(cfg scope)"; quote="$(cfg quote)"
printf '   entry %s, out %s, scope %s, quote %s\n' "$entry" "$out" "$scope" "$quote"

head2 '1. There is one entry point and it stays short enough to be read whole'
# The ceiling is the point of the document rather than a style rule: an entry point is
# read in full by every session that opens the repository, so a routing file that grows
# into a second README has stopped being a route and become another thing to search.
CEIL=12000
if [ ! -f "$repo/$entry" ]; then
  skip "$entry does not exist yet — the layer has not landed in this repository"
else
  n=$(wc -c <"$repo/$entry" | tr -d ' ')
  if [ "$n" -le "$CEIL" ]; then pass "$entry is $n B, under the $CEIL B ceiling"
  else bad "$entry is $n B, over the $CEIL B ceiling — move prose into the documents it describes"; fi
fi

head2 '2. Every alias row routes somewhere that exists'
# The one authored surface, so the only one a generator cannot keep true. A row naming a
# folder that has since been renamed is the failure this check exists to catch, and
# nothing else in the layer would notice: the table still renders, and the route still
# reads as an answer.
if [ ! -f "$repo/$entry" ]; then
  skip "no $entry, so no alias table"
elif ! grep -q 'BEGIN ALIASES' "$repo/$entry"; then
  skip "$entry carries no alias table yet"
else
  if o=$(python3 "$R/aliases.py" --repo "$repo" --check 2>&1); then pass "$o"
  else printf '%s\n' "$o" | sed 's/^/  /'; bad 'an alias row names a path that does not exist'; fi
fi

head2 '3. The heading projection is current'
if [ ! -f "$repo/$out" ]; then
  skip "$out does not exist yet"
else
  if o=$(python3 "$R/gen_headings.py" --repo "$repo" --out "$out" --scope "$scope" --check 2>&1); then
    pass "$o"
  elif [ ! -f "$repo/.retrieval/headings.title" ]; then
    # Distinguished rather than merged into the stale case, because the repair differs and
    # the diff will usually be the title block alone: a repository that carries a
    # projection either adopts the generator's default title or declares its own prose at
    # `.retrieval/headings.title`. Until it does, the generator would rewrite what the
    # repository says about itself, which is the one thing the generator does not own.
    printf '  %s\n' "$o"
    bad "$out differs and this repository declares no .retrieval/headings.title — \
declare its title block, or rerun gen_headings.py to adopt the default"
  else printf '  %s\n' "$o"; bad "$out is stale — rerun gen_headings.py"; fi
fi

head2 '4. Every generated Contents block is current'
# The subject is the documents that already carry a block, and the predicate's set is
# reported beside it rather than checked: a document the predicate selects and nobody has
# indexed yet is a plan item, not a defect, and checking the predicate would report it as
# stale. The gap is the figure somebody actually wants, so it is printed as one.
indexed=$(git -C "$repo" grep -l '^<!-- BEGIN CONTENTS' -- '*.md' 2>/dev/null || true)
have=$(printf '%s' "$indexed" | grep -c . || true)
sel=$(python3 "$R/gen_toc.py" --repo "$repo" --list 2>/dev/null | tail -1)
printf '   predicate selects %s; %s carry a generated block\n' "${sel:-unknown}" "$have"
if [ "$have" = 0 ]; then
  skip 'no document carries a generated Contents block'
else
  # One array element per path rather than one word per space: a markdown path holding a
  # space would otherwise arrive as two arguments and the check would report staleness
  # against a file that does not exist. A `read` loop rather than bash 4's builtin for
  # reading a file into an array, whose name this comment deliberately does not spell:
  # infra/desktop/grid/test.sh's portability gate greps whole file text with no awareness
  # of `#`, so the word inside a comment explaining the decision not to use it is
  # indistinguishable from a call. BASH.md puts the floor at 3.2.
  paths=()
  while IFS= read -r line; do
    if [ -n "$line" ]; then paths+=("$line"); fi
  done <<EOF
$indexed
EOF
  if o=$(python3 "$R/gen_toc.py" --repo "$repo" --check "${paths[@]}" 2>&1); then
    pass "$have generated blocks all current"
  else printf '%s\n' "$o" | grep -i stale | sed 's/^/  /'; bad 'a generated block is stale — rerun gen_toc.py --all'; fi
fi

head2 '5. Every exclude rule matches something'
# An exclude rule matching zero tracked paths is either a typo or a file that moved, and
# both are silent: the rule goes on being enforced against nothing while reading as
# protection. This is the check that makes the exclude file worth being the canonical
# form of a reading rule a human would otherwise hold in prose.
ex="$repo/.retrieval/exclude"
if [ ! -f "$ex" ]; then
  skip 'no .retrieval/exclude in this repository'
else
  if dead=$(python3 "$R/exclude.py" --repo "$repo" --check 2>&1); then pass "$dead"
  else printf '%s\n' "$dead" | sed 's/^/  /'; bad 'an exclude rule matches no tracked path'; fi
fi

head2 '6. The exclude projection is current'
# The projection direction of check 5: the file is canonical and the entry point's bullet
# list is generated from it, so a rule edited in one place and not regenerated leaves the
# document every session reads stating a narrower rule than the one being enforced. The
# repair is a command, which is why this is a check and not a convention.
if [ ! -f "$repo/.retrieval/exclude" ]; then
  skip 'no .retrieval/exclude, so there is nothing to project'
elif ! grep -q 'BEGIN EXCLUDE' "$repo/$entry" 2>/dev/null; then
  skip "$entry carries no generated exclude block"
else
  if o=$(python3 "$R/gen_exclude.py" --repo "$repo" --check 2>&1); then pass "$o"
  else printf '%s\n' "$o" | sed 's/^/  /'; bad "the exclude block in $entry is stale — rerun gen_exclude.py"; fi
fi

head2 '7. No generated surface offers an excluded path'
# The check `CONTRACT.md` §4 named and did not have until an exclude file existed to design
# it against. **Its subject is a surface and not a mention**: measured against the first
# repository to carry one, 28 markdown links in 5 documents resolved to an excluded path,
# every one of them a records document naming the record that holds an answer — which is
# the repository answering at class level, the thing its own reading rule permits. So what
# is checked is what this layer generates and routes with: the projection's corpus, the
# links inside generated blocks, the generated index, and the alias table's rows. Prose
# stays the author's, and `exclude.py`'s own note carries the reasoning.
if [ ! -f "$repo/.retrieval/exclude" ]; then
  skip 'no .retrieval/exclude, so no path is excluded'
else
  if o=$(python3 "$R/exclude.py" --repo "$repo" --cited 2>&1); then pass "$o"
  else printf '%s\n' "$o" | sed 's/^/  /'; bad 'a generated surface offers a path the exclude file forbids opening'; fi
fi

head2 '8. A declared gap is spelled the one way a question can ask for'
# `## Known gaps` is how a session asks what a repository knows it does not hold, and
# that only works while the heading is one string. **A trailing clause is not a second
# spelling and must not be refused**: the contract's own rule is that a heading says what
# its section holds, and a citation matches a heading sentence as a prefix — so
# `## Known gaps — the missing originals` is the convention working, and a sweep that
# flattened those clauses would take information out of the index to make a check green.
# What is refused is a *prefix* that differs: `## Known Gaps`, `## Gaps`, `## Open gaps`.
# A leading section number is allowed because a numbered document numbers every heading.
all_gaps=$(git -C "$repo" grep -hnE '^#{2,3} .*[Gg]aps' -- '*.md' 2>/dev/null || true)
ok=$(printf '%s' "$all_gaps" | grep -cE '^[0-9]+:#{2,3} ([0-9]+[a-z]?\. )?Known gaps( —.*)?$' || true)
odd=$(printf '%s' "$all_gaps" | grep -vE '^[0-9]+:#{2,3} ([0-9]+[a-z]?\. )?Known gaps( —.*)?$' || true)
if [ -z "$all_gaps" ]; then
  skip 'no document declares its gaps yet'
elif [ -z "$odd" ]; then
  pass "$ok gaps headings, every one of them prefixed 'Known gaps'"
else
  printf '%s\n' "$odd" | sed 's/^/  /'
  bad 'a gaps heading is prefixed a second way — a question asking for "Known gaps" misses it'
fi

printf '\n'
if [ "$fail" = 0 ]; then printf -- '-- all checks passed\n'; else printf -- '-- checks failed\n'; fi
exit "$fail"
