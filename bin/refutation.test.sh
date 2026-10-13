#!/usr/bin/env bash
# Every refutation entry is a receipt a reader can go and read — asked of REFUTATION.md itself.
#   bash bin/refutation.test.sh
#
# INDUCTION.md's fourth condition admits a rule only if its breach is observable and cheap to
# observe, and REFUTATION.md is where a breach that was observed goes. A page of claims that the
# doctrine has failed, held by nothing, is the exact shape that condition refuses: an entry naming
# no commit, or naming one that does not exist, is indistinguishable from a sound entry to every
# reader who does not go and check — and the page's whole value is that its claims are checkable.
#
# Separate from bin/induction.test.sh, which judges the admission gate itself: the register, the
# lineage, and the four places a citation is printed. This judges the page that records the gate
# having let something through, and the two share no matcher.
#
# What no check here holds is the part that matters most — that an entry gets WRITTEN when a rule
# fails. Nothing a script can read tells a rule that has never failed from one whose failure nobody
# recorded, so the page states that in its own words rather than leaving a reader to infer it from
# the length. Recorded as unenforced with the decision attached, which is doctrine/as-built.md's
# form, and the alternative — a check demanding an entry per doctrine document — buys coverage by
# inviting the one thing that would make the page worthless, an entry written to satisfy it.
# shellcheck disable=SC2034  # ROOT, PAGE and FIX are read inside the eval'd conditions below.
# shellcheck disable=SC2016  # a check's condition is eval'd by the harness, so those expand there
# and not here.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bin/check.sh
source "$DIR/check.sh"

ROOT="$DIR/.."
PAGE="$ROOT/REFUTATION.md"

# A year in the heading, which is the only date an entry carries. No interval expression: macOS
# ships a 2007 awk with no support for one, and this suite runs there (see .github/workflows/ci.yml).
DATED='(1[5-9]|20)[0-9][0-9]'

# entries file: how many entries the page has. A matcher over no rows at all passes every judgement
# below in silence, so the count is asserted before anything is asserted about it.
entries() { grep -cE '^### ' "$1" 2>/dev/null; }

# One line per entry: its heading, a tab, and each commit it names — or nothing, where it names
# none. A receipt is a backticked, all-hex, nine-characters-or-more word, possibly carrying the
# punctuation that follows it in a sentence; the length is what stands in for an interval, and the
# backticks are what keep a word like `defaced` out.
receipts() {
  awk '
    function flush() {
      if (h == "") return
      if (n == 0) { printf "%s\t\n", h; return }
      for (i = 1; i <= n; i++) printf "%s\t%s\n", h, r[i]
    }
    index($0, "### ") == 1 { flush(); h = substr($0, 5); n = 0; next }
    index($0, "#") == 1 { flush(); h = ""; next }
    h == "" { next }
    {
      for (f = 1; f <= NF; f++) {
        w = $f
        if (w !~ /^`[0-9a-f]+`[.,:;)]?$/) continue
        gsub(/[^0-9a-f]/, "", w)
        if (length(w) < 7) continue
        r[++n] = w
      }
    }
    END { flush() }
  ' "$1"
}

# The four slots, which are LINEAGE.md's shape applied to a failure rather than to a work.
thin() {
  local out
  [ -f "$1" ] || { printf '        there is no refutation page at all: %s\n' "${1##*/}"; return 1; }
  out=$(awk '
    function report() {
      if (h == "") return
      miss = ""
      if (!r) miss = miss " the rule"
      if (!w) miss = miss " what happened"
      if (!c) miss = miss " what caught it"
      if (!s) miss = miss " what it says about the rule"
      if (miss != "") printf "        %s is missing:%s\n", h, miss
    }
    index($0, "### ") == 1 { report(); h = substr($0, 5); r = 0; w = 0; c = 0; s = 0; next }
    index($0, "#") == 1 { report(); h = ""; next }
    h == "" { next }
    index($0, "**The rule**") == 1 { r = 1; next }
    index($0, "**What happened**") == 1 { w = 1; next }
    index($0, "**What caught it**") == 1 { c = 1; next }
    index($0, "**What it says about the rule**") == 1 { s = 1; next }
    END { report() }
  ' "$1")
  [ -z "$out" ] || { printf '%s\n' "$out"; return 1; }
}

# When it happened, in the heading, because a rule is refuted against the doctrine as it stood.
undated() {
  local out
  out=$(grep -E '^### ' "$1" | grep -vE "$DATED" || true)
  [ -z "$out" ] || { printf '        no date in the heading: %s\n' "${out#\#\#\# }"; return 1; }
}

# An entry with no commit is an assertion. The claim this page makes is that its claims are
# checkable, and a reader with nowhere to go cannot check one.
unreceipted() {
  local out
  out=$(receipts "$1" | awk -F'\t' '$2 == "" { printf "        names no commit: %s\n", $1 }')
  [ -z "$out" ] || { printf '%s\n' "$out"; return 1; }
}

# And the commit exists in this repository. A mistyped or rebased-away hash reads exactly like a
# sound one, which is the failure a reader pays for and the only one worth a script.
dangling() {
  local repo=$1 page=$2 heading sha out=""
  case $(git -C "$repo" rev-parse --is-shallow-repository 2>/dev/null) in
    true)
      printf '        this is a shallow clone, so no commit here resolves: git fetch --unshallow\n'
      return 1 ;;
  esac
  while IFS=$'\t' read -r heading sha; do
    [ -n "$sha" ] || continue
    git -C "$repo" cat-file -e "$sha^{commit}" 2>/dev/null && continue
    out="$out        no such commit in this repository: $sha, in $heading"$'\n'
  done < <(receipts "$page")
  [ -z "$out" ] || { printf '%s' "$out"; return 1; }
}

# The page is reachable, which is the part of it a refactor drops silently. Condition 4 names it as
# where a showing goes, and a condition pointing at a page nobody is told about is back to being
# satisfied in writing alone.
unreferenced() {
  local file out=""
  for file in "$@"; do
    grep -q 'REFUTATION\.md' "$file" || out="$out        does not reach the page: ${file##*/}"$'\n'
  done
  [ -z "$out" ] || { printf '%s' "$out"; return 1; }
}

echo "refutation:"
check "the page has entries at all, which every judgement below assumes" '[ "$(entries "$PAGE")" -ge 1 ]'
check "every entry says what the rule is, what happened, what caught it, and what that says about the rule" \
  'thin "$PAGE"'
check "every entry is dated in its heading" 'undated "$PAGE"'
check "every entry names a commit" 'unreceipted "$PAGE"'
check "every commit an entry names is one this repository contains" 'dangling "$ROOT" "$PAGE"'
check "the documents that describe this repository reach the page" \
  'unreferenced "$ROOT/README.md" "$ROOT/START-HERE.md" "$ROOT/ARCHITECTURE.md" "$ROOT/INDUCTION.md" "$ROOT/CONTRIBUTING.md"'

# The controls. Each judgement above is run against a page built to fail it, because a matcher that
# finds no entries at all would pass every one of them in silence — which is this page's own second
# entry, and the reason that one is in it.
FIX=$(mktemp -d)
trap 'rm -rf "$FIX"' EXIT
cat >"$FIX/REFUTATION.md" <<'FIXTURE'
# Refutation

### Thin, and undated

**The rule** — something.

**What happened** — it failed, in `aaaaaaa`.

### Receiptless — 2026-10-07

**The rule** — something else.

**What happened** — it failed, and this entry says where to look nowhere.

**What caught it** — nothing.

**What it says about the rule** — nothing.
FIXTURE
: >"$FIX/silent.md"

check "an entry missing a slot is caught" '! thin "$FIX/REFUTATION.md" >/dev/null'
check "an undated heading is caught" '! undated "$FIX/REFUTATION.md" >/dev/null'
check "an entry naming no commit is caught" '! unreceipted "$FIX/REFUTATION.md" >/dev/null'
check "a commit this repository does not contain is caught" '! dangling "$ROOT" "$FIX/REFUTATION.md" >/dev/null'
check "a document that does not reach the page is caught" '! unreferenced "$FIX/silent.md" >/dev/null'
# The receipt matcher is what the two judgements above share, so what it matches is asserted rather
# than inferred from their passing: a hash in backticks is a receipt, and a hex-shaped English word
# beside it is not.
check "a backticked hash is read as a receipt, and a bare hex-shaped word is not" \
  '[ "$(printf "### E — 2026-10-07\nIt was \`f88b650\`, not defaced.\n" | receipts /dev/stdin | cut -f2 | grep -c .)" = 1 ]'
finish
