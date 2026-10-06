#!/usr/bin/env bash
# Every doctrine document names the principle it instantiates — asked of INDUCTION.md's register.
#   bash bin/induction.test.sh
#
# INDUCTION.md admits a rule only when it can be named in the strongest form the wider field states
# it, and the register is where that naming is recorded. A declaration with nothing holding it is
# the reminder the doctrine is written against, so this suite is the holding: a document added to
# `doctrine/` without a row is refused here rather than by whichever reviewer happens to remember.
#
# Three questions, and the third is the one worth having. That a row exists is cheap to satisfy. That
# it carries a *dated source* is what distinguishes naming a principle from asserting one, and the
# escape hatch is explicit — a document may declare that no prior form was found, which is a
# falsifiable claim a reader with a citation can refute. Either way the row says which it is.
#
# `doctrine/README.md` is exempt: ARCHITECTURE.md §1 and §7 make the index beside the documents not
# itself doctrine, so there is no rule in it to name.
# shellcheck disable=SC2034  # ROOT and FIX are read inside the eval'd check conditions below.
# shellcheck disable=SC2016  # a check's condition is eval'd by the harness, so those expand there
# and not here; the register pattern is single-quoted for the same reason a regex always is.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$DIR/check.sh"

ROOT="$DIR/.."

# A register row, as opposed to a row of either other table in the file: it opens with a link whose
# text is a doctrine file name and whose target is that file.
rows() { grep -E '^\| \[`[a-z][a-z-]*\.md`\]\(doctrine/[a-z][a-z-]*\.md\)' "$1"; }
# The file each row is about, read out of the row's first cell. The last link in a row may well be
# to another doctrine document — several rows cite one — so this anchors at the start of the line
# rather than searching for `doctrine/`, which would silently credit the row to whatever it cites.
named() { rows "$1" | sed -e 's@^| \[`@@' -e 's@`\].*@@'; }

# Every doctrine document has a row. The judgement prints the names, because the fix is to write one.
unregistered() {
  local doc=$1 induction=$2 f base out=""
  for f in "$doc"/*.md; do
    base=${f##*/}
    [ "$base" = "README.md" ] && continue
    named "$induction" | grep -qxF "$base" || out="$out $base"
  done
  [ -z "$out" ] || { printf '        no register row for:%s\n' "$out"; return 1; }
}

# And every row is about a document that exists — a register naming a deleted file is a register
# nobody has read since, which is the failure in the other direction.
dangling() {
  local doc=$1 induction=$2 base out=""
  while IFS= read -r base; do
    [ -n "$base" ] || continue
    [ -f "$doc/$base" ] || out="$out $base"
  done < <(named "$induction")
  [ -z "$out" ] || { printf '        register row names a document that is gone:%s\n' "$out"; return 1; }
}

# Each row carries a dated source, or says in as many words that none was found.
uncited() {
  local induction=$1 line base out=""
  while IFS= read -r line; do
    base=$(printf '%s' "$line" | sed -e 's@^| \[`@@' -e 's@`\].*@@')
    printf '%s' "$line" |
      grep -qE '(^|[^0-9])(19|20)[0-9][0-9]([^0-9]|$)|no prior form was found' ||
      out="$out $base"
  done < <(rows "$induction")
  [ -z "$out" ] || { printf '        register row names no dated source:%s\n' "$out"; return 1; }
}

check "every doctrine document has a register row" 'unregistered "$ROOT/doctrine" "$ROOT/INDUCTION.md"'
check "every register row names a document that exists" 'dangling "$ROOT/doctrine" "$ROOT/INDUCTION.md"'
check "every register row names a dated source or declares there is none" 'uncited "$ROOT/INDUCTION.md"'
check "the register is found at all, so the three above are not passing on an empty set" \
  '[ "$(rows "$ROOT/INDUCTION.md" | grep -c .)" -ge 2 ]'

# The controls. Each judgement above is run against a tree built to fail it, because a matcher that
# finds no rows at all would pass every one of them in silence.
FIX=$(mktemp -d)
trap 'rm -rf "$FIX"' EXIT
mkdir -p "$FIX/doctrine"
: >"$FIX/doctrine/kept.md"
: >"$FIX/doctrine/README.md"
cat >"$FIX/INDUCTION.md" <<'FIXTURE'
| Document | Named in its best-known form | Where this repository departs |
|---|---|---|
| [`gone.md`](doctrine/gone.md) | **Something** — asserted, with nobody attached to it | none |
FIXTURE

check "a document with no row is caught" '! unregistered "$FIX/doctrine" "$FIX/INDUCTION.md" >/dev/null'
check "a row for a deleted document is caught" '! dangling "$FIX/doctrine" "$FIX/INDUCTION.md" >/dev/null'
check "a row with no dated source is caught" '! uncited "$FIX/INDUCTION.md" >/dev/null'
# The exemption is a judgement about which file, so it is asserted over what the failure names.
exempts_index() {
  local out
  out=$(unregistered "$FIX/doctrine" "$FIX/INDUCTION.md" 2>&1 || true)
  printf '%s' "$out" | grep -q 'kept\.md' && ! printf '%s' "$out" | grep -q 'README\.md'
}
check "the index beside the documents is exempt, and the document beside it is not" 'exempts_index'

finish
