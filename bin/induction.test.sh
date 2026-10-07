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

# A dated work, or the one sentence that stands in for having looked and found no objection. The
# register's escape hatch is `no prior work was found`; a lineage entry's is its own sentence,
# because the two claims are different ones — nobody wrote the principle down, against nobody has
# written against it — and a reader holding a citation refutes either.
OBJECTED='(^|[^0-9])(1[5-9]|20)[0-9][0-9]([^0-9]|$)|no serious objection was found'

LINEAGE="$ROOT/LINEAGE.md"

# GitHub's anchor for a heading: lowercase, drop every character that is not a letter, digit, space
# or hyphen, then spaces to hyphens. Byte-wise on purpose — an em dash is dropped a byte at a time
# and the two spaces around it survive as the doubled hyphen the anchors actually carry, which is
# the same answer on either platform's sed rather than whichever one has a UTF-8 locale.
slug() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | LC_ALL=C sed -e 's/[^a-z0-9 -]//g' -e 's/ /-/g'
  echo
}

# Every entry in the lineage, as the anchor a link to it has to carry.
entry_slugs() {
  local h
  while IFS= read -r h; do slug "${h#\#\#\# }"; done < <(grep -E '^### ' "$1" 2>/dev/null)
}

# Every anchor into the lineage that some other file asks for.
lineage_links() {
  grep -o '](LINEAGE\.md#[a-z0-9-]*)' "$1" 2>/dev/null | sed -e 's/.*#//' -e 's/)$//'
}

# One labelled paragraph of each entry, rejoined onto a line: the label through the blank line that
# ends it. A citation wraps, and the year is as likely to be on the second line as the first.
para() {
  awk -v lab="$1" '
    function flush() { if (h != "" && buf != "") printf "%s|%s\n", h, buf; buf=""; inpara=0 }
    index($0, "### ") == 1 { flush(); h=substr($0, 5); next }
    index($0, "#") == 1 { flush(); h=""; next }
    h == "" { next }
    index($0, lab) == 1 { flush(); inpara=1; buf=$0; next }
    inpara && NF == 0 { flush(); next }
    inpara { buf = buf " " $0; next }
    END { flush() }
  ' "$2"
}

# Every row of the register reaches the lineage. A new document cannot be admitted with its works
# described only in the cell, which is the arrangement this page was made to end.
unlinked() {
  local src=$1 line base out=""
  while IFS= read -r line; do
    base=$(printf '%s' "$line" | sed -e 's@^| \[`@@' -e 's@`\].*@@')
    printf '%s' "$line" | grep -q '](LINEAGE\.md#' || out="$out $base"
  done < <(rows "$src")
  [ -z "$out" ] || { printf '        no link into the lineage from the row for:%s\n' "$out"; return 1; }
}

# And every anchor asked for is one the lineage has. A link to a heading that was renamed is the
# failure GitHub reports as silence: the page opens at the top and the reader never knows.
dangling_anchor() {
  local src=$1 lin=$2 a slugs out=""
  slugs=$(entry_slugs "$lin")
  while IFS= read -r a; do
    [ -n "$a" ] || continue
    printf '%s\n' "$slugs" | grep -qxF "$a" || out="$out $a"
  done < <(lineage_links "$src" | sort -u)
  [ -z "$out" ] || { printf '        %s asks the lineage for an entry it has not got:%s\n' "${src##*/}" "$out"; return 1; }
}

# Every entry is reached from the register. This is the whole difference between a lineage and the
# reading list INDUCTION.md refuses: an entry exists because a rule here leans on the work, and an
# entry nothing leans on is scholarship this repository has no standing to keep.
orphan() {
  local src=$1 lin=$2 s used out=""
  used=$(lineage_links "$src" | sort -u)
  while IFS= read -r s; do
    [ -n "$s" ] || continue
    printf '%s\n' "$used" | grep -qxF "$s" || out="$out $s"
  done < <(entry_slugs "$lin")
  [ -z "$out" ] || { printf '        no register row reaches:%s\n' "$out"; return 1; }
}

# Each entry carries all four labels. A thin entry is the failure mode of a page like this — a
# heading, a citation and nothing a reader could disagree with.
thin() {
  local out
  [ -f "$1" ] || { printf '        there is no lineage page at all: %s\n' "${1##*/}"; return 1; }
  out=$(awk '
    function report() {
      if (h == "") return
      miss=""
      if (!w) miss=miss " the work"
      if (!c) miss=miss " what it claims"
      if (!a) miss=miss " what the field says against it"
      if (!t) miss=miss " taken here"
      if (miss != "") printf "        %s is missing:%s\n", h, miss
    }
    index($0, "### ") == 1 { report(); h=substr($0, 5); w=0; c=0; a=0; t=0; next }
    index($0, "#") == 1 { report(); h=""; next }
    h == "" { next }
    index($0, "**The work**") == 1 { w=1; next }
    index($0, "**What it claims**") == 1 { c=1; next }
    index($0, "**What the field says against it**") == 1 { a=1; next }
    index($0, "**Taken here**") == 1 { t=1; next }
    END { report() }
  ' "$1")
  [ -z "$out" ] || { printf '%s\n' "$out"; return 1; }
}

# The work is dated. The page exists so a reader can go and get it, and a citation with no year is
# the practice area INDUCTION.md already refuses in the register.
undated_entry() {
  local lin=$1 line out=""
  [ -f "$lin" ] || { printf '        there is no lineage page at all: %s\n' "${lin##*/}"; return 1; }
  while IFS= read -r line; do
    printf '%s' "${line#*|}" | grep -qE "$DATED" || out="$out
        ${line%%|*}"
  done < <(para '**The work**' "$lin")
  [ -z "$out" ] || { printf '        no dated work cited by:%s\n' "$out"; return 1; }
}

# And the objection is cited, or its absence is claimed in as many words. This is the judgement the
# page was built for: INDUCTION.md admits a rule because the name imports the counter-arguments, and
# before this page the repository printed one objection for forty-one names.
unobjected() {
  local lin=$1 line out=""
  [ -f "$lin" ] || { printf '        there is no lineage page at all: %s\n' "${lin##*/}"; return 1; }
  while IFS= read -r line; do
    printf '%s' "${line#*|}" | grep -qE "$OBJECTED" || out="$out
        ${line%%|*}"
  done < <(para '**What the field says against it**' "$lin")
  [ -z "$out" ] || { printf '        no dated objection and no claim that none was found:%s\n' "$out"; return 1; }

# The `Named:` line itself carries the way out to the origin, which the register's rows already do.
# This is the copy standing where the rule is applied, the one INDUCTION.md says cannot be skipped,
# so the reader most likely to want to argue with a rule was, before this link, the one who could
# not reach the work it was named from. A link that resolves nowhere is worse than none, because
# GitHub reports a renamed heading as silence, so both halves are one judgement.
unlineaged() {
  local doc=$1 lin=$2 f block a slugs none="" bad=""
  [ -f "$lin" ] || { printf '        there is no lineage page at all: %s\n' "${lin##*/}"; return 1; }
  slugs=$(entry_slugs "$lin")
  while IFS= read -r f; do
    block=$(named_block "$f")
    [ -n "$block" ] || continue
    if ! printf '%s' "$block" | grep -q '](\.\./LINEAGE\.md#'; then
      none="$none ${f##*/}"
      continue
    fi
    while IFS= read -r a; do
      [ -n "$a" ] || continue
      printf '%s\n' "$slugs" | grep -qxF "$a" || bad="$bad ${f##*/}#$a"
    done < <(printf '%s' "$block" | grep -o '](\.\./LINEAGE\.md#[a-z0-9-]*)' | sed -e 's/.*#//' -e 's/)$//')
  done < <(docs "$doc")
  [ -z "$none" ] || printf '        no lineage link on the `Named:` line of:%s\n' "$none"
  [ -z "$bad" ] || printf '        a `Named:` line asks the lineage for an entry it has not got:%s\n' "$bad"
  [ -z "$none$bad" ] || return 1
}
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

check "every register row reaches the lineage" 'unlinked "$ROOT/INDUCTION.md"'
check "every anchor the register asks the lineage for exists" \
  'dangling_anchor "$ROOT/INDUCTION.md" "$LINEAGE"'
check "every lineage entry is reached from the register" 'orphan "$ROOT/INDUCTION.md" "$LINEAGE"'
check "every lineage entry carries all four labels" 'thin "$LINEAGE"'
check "every lineage entry cites a dated work" 'undated_entry "$LINEAGE"'
check "every lineage entry carries a dated objection or claims there is none" 'unobjected "$LINEAGE"'
check "the lineage is found at all, so the judgements over it are not passing on an empty set" \
  '[ "$(entry_slugs "$LINEAGE" | grep -c .)" -ge 20 ]'
check "every \`Named:\` line reaches the lineage, and reaches an entry that is there" \
  'unlineaged "$ROOT/doctrine" "$LINEAGE"'

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
mkdir -p "$FIX"
cat >"$FIX/LINEAGE.md" <<'FIXTURE'
## A literature

### Thin — Somebody, 1970

**The work** — Somebody, *A Title*, 1970.

**What it claims** — that something is the case.

### Undated — nobody attached to it

**The work** — standard practice, as everyone knows.

**What it claims** — that something is the case.

**What the field says against it** — nothing anybody has written down, and this entry does not say
so either.

**Taken here** — nowhere.
FIXTURE
cat >"$FIX/REGISTER.md" <<'FIXTURE'
| Document | Named in its best-known form, and the prior work it is named from | Where this repository departs |
|---|---|---|
| [`gone.md`](doctrine/gone.md) | **Something** ([Somebody, 1970](LINEAGE.md#renamed-since--somebody-1970)) | none |
| [`kept.md`](doctrine/kept.md) | **Something else** — asserted, with no link to the lineage | none |
FIXTURE

# A document whose `Named:` line links to a heading the lineage has not got. `undated.md` above is
# the other half — a `Named:` line with no link at all — so the two causes are controlled apart.
cat >"$FIX/doctrine/renamed.md" <<'FIXTURE'
# Renamed

*The discipline, stated.*

**Named:** something — Somebody, *A Title*, 1970.
[Lineage](../LINEAGE.md#renamed-since--somebody-1970).
FIXTURE
# One accumulator reports two causes, so the control is asserted over what the failure names.
names_both_causes() {
  local out
  out=$(unlineaged "$FIX/doctrine" "$FIX/LINEAGE.md" 2>&1 || true)
  printf '%s' "$out" | grep -q 'no lineage link on the `Named:` line of: undated\.md' &&
    printf '%s' "$out" | grep -q 'has not got: renamed\.md#renamed-since--somebody-1970'
}

check "a row that does not reach the lineage is caught" '! unlinked "$FIX/REGISTER.md" >/dev/null'
check "an anchor the lineage has not got is caught" \
  '! dangling_anchor "$FIX/REGISTER.md" "$FIX/LINEAGE.md" >/dev/null'
check "an entry no row reaches is caught" '! orphan "$FIX/REGISTER.md" "$FIX/LINEAGE.md" >/dev/null'
check "an entry missing a label is caught" '! thin "$FIX/LINEAGE.md" >/dev/null'
check "an entry citing no dated work is caught" '! undated_entry "$FIX/LINEAGE.md" >/dev/null'
check "an objection with neither a year nor the sentence that stands in for one is caught" \
  '! unobjected "$FIX/LINEAGE.md" >/dev/null'
check "a \`Named:\` line with no link is caught, and so is one whose link resolves nowhere" \
  'names_both_causes'
# The anchor is the one thing here a human eye gets wrong, so the rule for building it is asserted
# rather than left to whichever platform's sed ran it.
check "an em dash and a comma leave the doubled hyphen the anchors carry" \
  '[ "$(slug "Falsifiability — Popper, 1934")" = falsifiability--popper-1934 ]'
check "a dash inside a word closes it up, as GitHub does" \
  '[ "$(slug "The principal–agent problem — Ross, 1973")" = the-principalagent-problem--ross-1973 ]'

check "the index beside the documents is exempt, and the document beside it is not" 'exempts_index'

finish
