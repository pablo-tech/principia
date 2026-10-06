#!/usr/bin/env bash
# Every doctrine document names the principle it instantiates and cites the work — asked of the
# documents, of README.md and of INDUCTION.md's register.
#   bash bin/induction.test.sh
#
# INDUCTION.md admits a rule only when it can be named in the strongest form the wider field states
# it and attributed to a specific prior work, and only when that citation is printed where the rule
# is stated rather than filed at the foot of one page. A declaration with nothing holding it is the
# reminder the doctrine is written against, so this suite is the holding: a document added to
# `doctrine/` without a `Named:` line, without a row in README's table of the doctrine, or without a
# register row is refused here rather than by whichever reviewer happens to remember.
#
# Two questions per place, and the second is the one worth having. That a line or a row exists is
# cheap to satisfy. That it carries a *dated work* is what distinguishes citing a principle from
# asserting one — a practice area has no author to disagree with and no year to date it from — and
# the escape hatch is explicit: a document may declare that no prior work was found, which is a
# falsifiable claim a reader with a citation can refute. Either way it says which it is.
#
# What a script cannot ask is whether the work cited is the right one, or the one the field
# recognizes. That half of the condition is review's, and INDUCTION.md says so in as many words.
#
# `doctrine/README.md` is exempt from all of it: ARCHITECTURE.md §1 and §7 make the index beside the
# documents not itself doctrine, so there is no rule in it to name.
# shellcheck disable=SC2034  # ROOT and FIX are read inside the eval'd check conditions below.
# shellcheck disable=SC2016  # a check's condition is eval'd by the harness, so those expand there
# and not here; the register pattern is single-quoted for the same reason a regex always is.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$DIR/check.sh"

ROOT="$DIR/.."

# A dated work, or the one sentence that stands in for having looked and found none. A year is the
# cheapest available evidence that something was published rather than asserted. The range reaches
# back past the twentieth century on purpose: the register already cites 1869 and 1898, and a pattern
# that quietly refuses the oldest work in the file would be read as that work being uncited.
DATED='(^|[^0-9])(1[5-9]|20)[0-9][0-9]([^0-9]|$)|no prior work was found'

# A row about a doctrine document, as opposed to a row of any other table in the same file: it opens
# with a link whose text is a doctrine file name and whose target is that file. INDUCTION.md's
# register and README.md's table of the doctrine are both read with this.
rows() { grep -E '^\| \[`[a-z][a-z-]*\.md`\]\(doctrine/[a-z][a-z-]*\.md\)' "$1"; }
# The file a row is about, read out of the row's first cell. The last link in a row may well be to
# another doctrine document — several rows cite one — so this anchors at the start of the line rather
# than searching for `doctrine/`, which would silently credit the row to whatever it cites.
named() { rows "$1" | sed -e 's@^| \[`@@' -e 's@`\].*@@'; }

# Every doctrine document, the index beside them excepted.
docs() {
  local f base
  for f in "$1"/*.md; do
    base=${f##*/}
    [ "$base" = "README.md" ] && continue
    [ -f "$f" ] && printf '%s\n' "$f"
  done
}

# The `Named:` paragraph of a document: the line and whatever it wraps onto, since a citation is
# longer than one line of prose and the year is as likely to be on the second.
named_block() { awk '/^\*\*Named:\*\*/{f=1} f && NF==0{exit} f' "$1"; }

# Every doctrine document has a row in the file asked. The judgement prints the names and the file,
# because the fix is to write one there.
unlisted() {
  local doc=$1 src=$2 f base out=""
  while IFS= read -r f; do
    base=${f##*/}
    named "$src" | grep -qxF "$base" || out="$out $base"
  done < <(docs "$doc")
  [ -z "$out" ] || { printf '        %s has no row for:%s\n' "${src##*/}" "$out"; return 1; }
}

# And every row is about a document that exists — a table naming a deleted file is a table nobody
# has read since, which is the failure in the other direction.
dangling() {
  local doc=$1 src=$2 base out=""
  while IFS= read -r base; do
    [ -n "$base" ] || continue
    [ -f "$doc/$base" ] || out="$out $base"
  done < <(named "$src")
  [ -z "$out" ] || { printf '        %s names a document that is gone:%s\n' "${src##*/}" "$out"; return 1; }
}

# Each row carries a dated work, or says in as many words that none was found.
uncited() {
  local src=$1 line base out=""
  while IFS= read -r line; do
    base=$(printf '%s' "$line" | sed -e 's@^| \[`@@' -e 's@`\].*@@')
    printf '%s' "$line" | grep -qE "$DATED" || out="$out $base"
  done < <(rows "$src")
  [ -z "$out" ] || { printf '        %s names no dated work for:%s\n' "${src##*/}" "$out"; return 1; }
}

# The document itself states the citation, under the line that states the discipline. This is the
# copy with the reader who is about to apply the rule, and so the one that cannot be skipped.
unnamed() {
  local f out=""
  while IFS= read -r f; do
    [ -n "$(named_block "$f")" ] || out="$out ${f##*/}"
  done < <(docs "$1")
  [ -z "$out" ] || { printf '        no `Named:` line in:%s\n' "$out"; return 1; }
}

# And that line carries a work rather than a practice area. A document with no line at all is left
# to the judgement above, so that one defect is reported once.
undated_name() {
  local f block out=""
  while IFS= read -r f; do
    block=$(named_block "$f")
    [ -n "$block" ] || continue
    printf '%s' "$block" | grep -qE "$DATED" || out="$out ${f##*/}"
  done < <(docs "$1")
  [ -z "$out" ] || { printf '        `Named:` line carries no dated work:%s\n' "$out"; return 1; }
}

check "every doctrine document carries a \`Named:\` line" 'unnamed "$ROOT/doctrine"'
check "every \`Named:\` line cites a dated work or declares there is none" 'undated_name "$ROOT/doctrine"'
check "every doctrine document has a row in README's table of the doctrine" \
  'unlisted "$ROOT/doctrine" "$ROOT/README.md"'
check "every row of that table cites a dated work" 'uncited "$ROOT/README.md"'
check "every doctrine document has a register row" 'unlisted "$ROOT/doctrine" "$ROOT/INDUCTION.md"'
check "every register row names a document that exists" 'dangling "$ROOT/doctrine" "$ROOT/INDUCTION.md"'
check "every register row cites a dated work or declares there is none" 'uncited "$ROOT/INDUCTION.md"'
check "the register is found at all, so the judgements over it are not passing on an empty set" \
  '[ "$(rows "$ROOT/INDUCTION.md" | grep -c .)" -ge 2 ]'
check "README's table is found at all, for the same reason" \
  '[ "$(rows "$ROOT/README.md" | grep -c .)" -ge 2 ]'

# The controls. Each judgement above is run against a tree built to fail it, because a matcher that
# finds no rows at all would pass every one of them in silence.
FIX=$(mktemp -d)
trap 'rm -rf "$FIX"' EXIT
mkdir -p "$FIX/doctrine"
: >"$FIX/doctrine/kept.md"
: >"$FIX/doctrine/README.md"
cat >"$FIX/doctrine/undated.md" <<'FIXTURE'
# Undated

*The discipline, stated.*

**Named:** shift left — the standard term in software quality, and nobody attached to it.
FIXTURE
cat >"$FIX/INDUCTION.md" <<'FIXTURE'
| Document | Named in its best-known form, and the prior work it is named from | Where this repository departs |
|---|---|---|
| [`gone.md`](doctrine/gone.md) | **Something** — asserted, with nobody attached to it | none |
FIXTURE
cp "$FIX/INDUCTION.md" "$FIX/README.md"

check "a document with no row is caught" '! unlisted "$FIX/doctrine" "$FIX/INDUCTION.md" >/dev/null'
check "a document missing from README's table is caught" \
  '! unlisted "$FIX/doctrine" "$FIX/README.md" >/dev/null'
check "a row for a deleted document is caught" '! dangling "$FIX/doctrine" "$FIX/INDUCTION.md" >/dev/null'
check "a row with no dated work is caught" '! uncited "$FIX/INDUCTION.md" >/dev/null'
check "a document with no \`Named:\` line is caught" '! unnamed "$FIX/doctrine" >/dev/null'
check "a \`Named:\` line naming a practice and no work is caught" '! undated_name "$FIX/doctrine" >/dev/null'
# The exemption is a judgement about which file, so it is asserted over what each failure names.
exempts_index() {
  local out
  out=$({ unlisted "$FIX/doctrine" "$FIX/INDUCTION.md"; unnamed "$FIX/doctrine"; } 2>&1 || true)
  printf '%s' "$out" | grep -q 'kept\.md' && ! printf '%s' "$out" | grep -q 'README\.md'
}
check "the index beside the documents is exempt, and the document beside it is not" 'exempts_index'

finish
