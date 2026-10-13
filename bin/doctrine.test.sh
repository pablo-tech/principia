#!/usr/bin/env bash
# Doctrine makes no claim about a model — asked of the documents themselves.
#   bash bin/doctrine.test.sh
#
# ARCHITECTURE.md §1 admits a rule only if it would still be true if every model on the machine were
# replaced tomorrow, and §10 lists the measurement of a model as out of scope. This suite is that
# sentence as a check, because the mixture it forbids is invisible to a reader: a claim with a
# two-month half-life filed in `doctrine/` inherits the authority of one with a twenty-year
# half-life, and nothing about the file's shape tells them apart. Two documents had drifted that way
# before this existed, and it took reading all nine to find them.
#
# What it looks for is narrow on purpose: a vendor, a model family, a version string beside a family
# name, a price, and the tuning vocabulary a measurement needs and a rule does not. The generic noun
# `model` is deliberately in none of the patterns — `tenancy.md` needs it to say that a rule telling
# a model what not to read is not a control against a file being readable, which is a claim about
# controls. A bare version number is out for the same reason: `1.0` is evidence of nothing without
# the family beside it, and the family is what the second pattern already refuses.
#
# Every pattern is also run against one sample of what it exists to refuse. A pattern that compiles
# and matches nothing passes a whole directory in silence, which is what a rule that never fires
# looks like, and an interval bound over RE_DUP_MAX is how this repository last produced one.
# shellcheck disable=SC2034  # each pattern is used inside an eval'd check condition below.
# shellcheck disable=SC2016  # a check's condition is eval'd by the harness, so $VENDORS
# expands there and not here.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$DIR/check.sh"

# `\b` is a GNU extension the BSD engine does not promise, and a boundary that silently becomes a
# literal widens the pattern rather than breaking it, so the controls below would not catch it.
B='(^|[^a-zA-Z])'
E='([^a-zA-Z]|$)'

VENDORS="anthropic|openai|deepmind|mistral ai|cohere|${B}xai${E}|${B}meta ai${E}"

FAMILIES="claude|chatgpt|${B}gpt${E}|${B}o[1-9]${E}|opus|sonnet|haiku|gemini"
FAMILIES="$FAMILIES|llama|mixtral|qwen|deepseek|grok|copilot"

VERSIONS='(claude|gpt|gemini|llama|opus|sonnet|haiku|qwen|grok)[ ._-]?[0-9]'

PRICES='\$[0-9]|[0-9]+ ?cents?|per (million|thousand) tokens?'
PRICES="$PRICES|per-token|(cost|price) per (turn|call|token)"

TUNING='temperature|top[_-]?[pk]|max.tokens|reasoning effort|extended thinking'
TUNING="$TUNING|thinking (mode|budget)|(token|context|attention) budget|context window"
TUNING="$TUNING|tokens? (per|a|every) (turn|call)"
TUNING="$TUNING|few.?shot|chain.of.thought|fine.?tun|(cheaper|smaller|frontier) model"
TUNING="$TUNING|model (swap|tier|family|version|generation)"

# The judgement, over `doctrine/` alone. Every match prints, because the fix is to read the line.
scan() {
  local hits
  hits=$(grep -niE "$1" "$DIR"/../doctrine/*.md) || return 0
  printf '%s\n' "$hits" | sed 's|.*/doctrine/|        doctrine/|'
  return 1
}
# The control: one sample of the thing the pattern exists to refuse.
fires() { printf '%s\n' "$2" | grep -qiE "$1"; }

check "no doctrine document names a vendor" 'scan "$VENDORS"'
check "no doctrine document names a model family" 'scan "$FAMILIES"'
check "no doctrine document carries a model version" 'scan "$VERSIONS"'
check "no doctrine document carries a price" 'scan "$PRICES"'
check "no doctrine document carries a tuning knob" 'scan "$TUNING"'

check "the vendor pattern can fail" 'fires "$VENDORS" "measured against the Anthropic API"'
check "the family pattern can fail" 'fires "$FAMILIES" "it held for Opus and not for Haiku"'
check "the version pattern can fail" 'fires "$VERSIONS" "unchanged since Sonnet 4.5"'
check "the price pattern can fail" 'fires "$PRICES" "the cross-check costs 4 cents a turn"'
check "the tuning pattern can fail" 'fires "$TUNING" "extended thinking widens a tight frame"'

# Every guard the chain dispatches is named by a doctrine document.
#
# A guard with no document above it is the mirror image of the refusal `INDUCTION.md` is built to
# make: a mechanism enforcing a rule nobody wrote down, which an agent reading the doctrine has no
# way to anticipate and meets for the first time as a refused commit. `credentials-guard.sh` was
# exactly that until `git.md` gained its section — the most unrecoverable moment in the repository,
# enforced in the chain and named in no document.
#
# The list is read off the dispatcher rather than restated here, because a copy of it is the drift
# `clean-code.md` names and the copy would still pass on the day a fifth guard was added.
guard_names() { sed -n 's/^for g in \(.*\); do$/\1/p' "$DIR/../guards/guards.sh"; }
named_in_doctrine() { grep -qF -- "guards/$1" "$DIR"/../doctrine/*.md; }
undocumented() {
  local g missing=""
  for g in $(guard_names); do
    named_in_doctrine "$g" || missing="$missing $g"
  done
  [ -z "$missing" ] && return 0
  printf '        named by no doctrine document:%s\n' "$missing"
  return 1
}

# The dispatch list being unreadable is the fail-open case rather than a broken test: `guard_names`
# answers with nothing, the loop below runs zero times, and the check passes a chain it never read.
check "the dispatch list is readable from guards.sh" '[ -n "$(guard_names)" ]'
check "every dispatched guard is named by a doctrine document" 'undocumented'
check "the coverage check can fail" '! named_in_doctrine not-a-guard.sh'

# ---- claims a document makes about a mechanism, checked against the mechanism -------------------
#
# `as-built.md` requires that a claim about a mechanism be derived from the mechanism or cut back to
# what can be checked, for the reason the unenforced-rule rule gives: a false claim leaves no trace
# either, so the sentence asserting it is the only evidence there is and it reads as coverage. These
# three are the ones whose mechanism is in this repository and can therefore be asked. Each is
# written to go red when the MECHANISM changes — a guard added, a variable read, a script written
# with no suite — which is the direction that matters: the document is what goes stale.
#
# All three were false when this was written. The guard count said two where the chain ran four, §6
# called five variables the complete set where six are read, and §9 said every script had a suite
# beside it where ten do not.

# One: the count of commit-enforced rules in doctrine/README.md, against the dispatch list above.
word_for() { # n — the number as that sentence spells it
  case "$1" in 1) echo One ;; 2) echo Two ;; 3) echo Three ;; 4) echo Four ;; 5) echo Five ;;
    6) echo Six ;; 7) echo Seven ;; 8) echo Eight ;; *) echo "$1" ;; esac
}
guard_count_agrees() {
  local n word
  n="$(guard_names | wc -w | tr -d ' ')"
  word="$(word_for "$n")"
  grep -q "^$word of the rules in these documents are enforced at commit time" \
    "$DIR/../doctrine/README.md" && return 0
  printf '        guards.sh dispatches %s; doctrine/README.md does not say "%s"\n' "$n" "$word"
  return 1
}
check "doctrine/README.md's count of commit-enforced rules is the dispatch list's" 'guard_count_agrees'
check "and that count can fail" '! grep -q "^$(word_for 7) of the rules in these documents" "$DIR/../doctrine/README.md"'

# Two: ARCHITECTURE.md §6 calls its table every PROTOCOL_* variable anything here reads. Read off
# the scripts, not the suites: a variable a suite exports to drive a script is that script's, and a
# variable only a suite invents is not this protocol's to document.
vars_read() {
  local f
  for f in $(cd "$DIR/.." && git ls-files); do
    case "$f" in *.md|*.test.sh|*.json|*.yml) continue ;; esac
    head -c 64 "$DIR/../$f" 2>/dev/null | grep -qE '^#!.*\b(bash|sh)\b' ||
      case "$f" in *.sh) ;; *) continue ;; esac
    grep -ohE 'PROTOCOL_[A-Z_]+' "$DIR/../$f" 2>/dev/null
  done | sort -u
}
vars_documented() { grep -ohE '^\| `PROTOCOL_[A-Z_]+`' "$DIR/../ARCHITECTURE.md" | tr -d '|` ' | sort -u; }
vars_agree() {
  local missing
  missing="$(comm -23 <(vars_read) <(vars_documented) | tr '\n' ' ')"
  [ -z "${missing// /}" ] && return 0
  printf '        read by a script and absent from ARCHITECTURE.md §6: %s\n' "$missing"
  return 1
}
check "§6's table is readable, which is the fail-open case" '[ -n "$(vars_documented)" ]'
check "every PROTOCOL_* variable a script reads is in it" 'vars_agree'
check "and the completeness check can fail" \
  'printf "%s\n" PROTOCOL_NOT_A_VARIABLE | comm -23 - <(vars_documented) | grep -q .'

# Three: ARCHITECTURE.md §9 names the scripts with no suite beside them. The selection is the one
# CI's own static-analysis sweep makes, verbatim in shape — one definition of "a script here"
# rather than two that drift — and the direction that matters is a script ARRIVING with no suite,
# which lands as a decision to write down rather than as a silent enlargement of the exception.
scripts_without_suite() {
  local f
  for f in $(cd "$DIR/.." && { git ls-files '*.sh' 'bin/*'
      git ls-files | while read -r g; do
        head -c 64 "$g" | grep -qE '^#!.*\b(bash|sh)\b' && printf '%s\n' "$g"; done; } | sort -u); do
    case "$f" in *.test.sh) continue ;; esac
    [ -f "$DIR/../${f%.sh}.test.sh" ] || printf '%s\n' "$f"
  done | sort -u
}
# The §9 table alone: scoped to the section, because other sections carry tables whose first cell is
# also a backticked path.
scripts_excused() {
  sed -n '/^## 9\. Testing/,/^## 10\./p' "$DIR/../ARCHITECTURE.md" |
    grep -ohE '^\| `[^`]+` \|' | tr -d '|` ' | sort -u
}
suite_exceptions_agree() {
  local unrecorded stale
  unrecorded="$(comm -23 <(scripts_without_suite) <(scripts_excused) | tr '\n' ' ')"
  stale="$(comm -13 <(scripts_without_suite) <(scripts_excused) | tr '\n' ' ')"
  [ -z "${unrecorded// /}" ] && [ -z "${stale// /}" ] && return 0
  [ -z "${unrecorded// /}" ] || printf '        no suite and no decision recorded: %s\n' "$unrecorded"
  [ -z "${stale// /}" ] || printf '        excused in §9 and no longer needs it: %s\n' "$stale"
  return 1
}
check "§9's list of scripts with no suite is readable, the fail-open case again" \
  '[ -n "$(scripts_excused)" ] && [ -n "$(scripts_without_suite)" ]'
check "every script with no suite beside it is one §9 records a decision for" 'suite_exceptions_agree'
check "and §9 excuses nothing that has since got a suite" \
  '! comm -13 <(scripts_without_suite) <(scripts_excused) | grep -q .'

# Four: §3 records that this repository carries no `.protocol/identity`, and names what is enforced
# in its place. Both halves are claims about mechanisms in this same repository, which is the case
# doctrine/as-built.md is explicit about — so both are derived, and the paragraph goes red from
# either direction. Adding the allowlist makes the decision stale; deleting the sign-off walk leaves
# the decision resting on a control that is gone, which is the quieter of the two and the reason
# there are two checks rather than one.
tracks() { (cd "$DIR/.." && git ls-files --error-unmatch -- "$1" >/dev/null 2>&1); }
signoff_walk() {   # the CI step the §3 paragraph names, scoped to it rather than to the file
  sed -n '/Developer Certificate of Origin sign-off/,/^  [a-z]/p' "$DIR/../.github/workflows/ci.yml"
}
check "§3's record that no identity allowlist is tracked here agrees with the index" \
  '! tracks .protocol/identity'
check "and the policy files it says ARE tracked are, which is the fail-open case" \
  'tracks .protocol/tenant && tracks .protocol/credentials-allow-content'
check "the sign-off walk §3 names in place of it is in continuous integration" \
  '[ -n "$(signoff_walk)" ] && signoff_walk | grep -q "Signed-off-by"'
check "and it walks every commit of the pull request rather than its head alone" \
  'signoff_walk | grep -q "git log .*BASE\.\.\$HEAD"'

finish
