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
    6) echo Six ;; 7) echo Seven ;; 8) echo Eight ;; 9) echo Nine ;; 10) echo Ten ;;
    11) echo Eleven ;; 12) echo Twelve ;; 13) echo Thirteen ;; *) echo "$1" ;; esac
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

# Five: §6's table is held to the tree above, and the paragraph below it — the variables read here
# that this protocol does not define — was not. It said two where three are read and named one
# adapter where two hold them, in the sentence immediately under the table the check above derives,
# which is what a check stopping at a table's edge looks like. So the paragraph is derived too, and
# by set equality in both directions: a variable arriving goes red, and a variable leaving goes red
# as well, because a name listed here that nothing reads is the same false claim pointing the other
# way.
#
# What makes "foreign" decidable is subtraction rather than a list. A name this tree ASSIGNS
# anywhere, suites included, is this tree's own — a variable a suite exports to drive a script is
# that script's input. What is left is read and never set here, less this protocol's own PROTOCOL_*
# namespace, which the table above covers, and less the shell's. That last exclusion is a hand
# list and is the one place this check carries one: it is a property of bash and of POSIX rather
# than of this repository, so it cannot go stale when the tree changes, and a bash variable
# arriving in a script here reds this check until somebody adds the name deliberately.
SHELL_OWN='^(BASH[A-Z_]*|PIPESTATUS|PWD|OLDPWD|IFS|PATH|HOME|SHELL|TMPDIR|RANDOM|SECONDS'
SHELL_OWN="$SHELL_OWN"'|LINENO|FUNCNAME|REPLY|OPTARG|OPTIND|UID|EUID|PPID|HOSTNAME|OSTYPE|LANG'
SHELL_OWN="$SHELL_OWN"'|LC_[A-Z]+|TERM|COLUMNS|LINES|EDITOR|VISUAL|PAGER)$'
script_files() {   # the selection vars_read makes, named so two checks cannot drift apart
  local f
  for f in $(cd "$DIR/.." && git ls-files); do
    case "$f" in *.md|*.json|*.yml) continue ;; esac
    head -c 64 "$DIR/../$f" 2>/dev/null | grep -qE '^#!.*\b(bash|sh)\b' ||
      case "$f" in *.sh) ;; *) continue ;; esac
    printf '%s\n' "$f"
  done
}
# Comment lines go first, because a variable named in a comment is not read; `\$` escapes go with
# them, because a dollar a script prints is not one it expands. Both were false positives when this
# was written.
vars_expanded() {
  local f
  for f in $(script_files); do
    case "$f" in *.test.sh) continue ;; esac
    sed -e 's/^[[:space:]]*#.*//' -e 's/\\\$/ /g' "$DIR/../$f" |
      grep -ohE '\$\{?[A-Z][A-Z0-9_]*' | tr -d '${'
  done | sort -u
}
vars_assigned() {
  local f
  for f in $(script_files); do
    sed -e 's/^[[:space:]]*#.*//' "$DIR/../$f" |
      grep -ohE '[A-Z][A-Z0-9_]*=' | tr -d '='
  done | sort -u
}
foreign_vars() {
  comm -23 <(vars_expanded) <(vars_assigned) |
    grep -vE "$SHELL_OWN" | grep -v '^PROTOCOL_' | sort -u
}
# §6's prose, which is the section less its table rows and less its own PROTOCOL_* heading line.
foreign_documented() {
  sed -n '/^## 6\. Environment variables/,/^## 7\./p' "$DIR/../ARCHITECTURE.md" |
    grep -v '^|' | grep -ohE '`[A-Z][A-Z0-9_]*`' | tr -d '`' | grep -v '^PROTOCOL_' | sort -u
}
foreign_agree() {
  local missing stale
  missing="$(comm -23 <(foreign_vars) <(foreign_documented) | tr '\n' ' ')"
  stale="$(comm -13 <(foreign_vars) <(foreign_documented) | tr '\n' ' ')"
  [ -z "${missing// /}" ] && [ -z "${stale// /}" ] && return 0
  [ -z "${missing// /}" ] || printf '        read here and not named in §6: %s\n' "$missing"
  [ -z "${stale// /}" ] || printf '        named in §6 and read by nothing here: %s\n' "$stale"
  return 1
}
check "§6's paragraph of variables this protocol does not define is readable, the fail-open case" \
  '[ -n "$(foreign_documented)" ] && [ -n "$(foreign_vars)" ]'
check "it names every variable a script here reads and nothing here sets, and nothing else" \
  'foreign_agree'
check "and it can fail from a variable arriving" \
  'printf "%s\n" ZZ_NOT_A_VARIABLE | comm -23 - <(foreign_documented) | grep -q .'
check "and from one leaving, which is the direction a list goes stale in" \
  'comm -13 <(printf "%s\n" ZZ_NOT_A_VARIABLE) <(foreign_documented) | grep -q .'

# Six: §4 says what else can change what the chain does without being typed per commit and without
# appearing in the commit. The list was three bullets and one of them was not a variable at all, so
# what is derived is the variable half: every PROTOCOL_* the shim or a guard expands IS such a
# bypass, by construction — the shim's two decide which guards run and a guard's decide what it
# refuses, and in each case a commit records nothing. §6's table is the superset and is already
# derived; this is the subset §4 has to account for, which is why the two adapter variables are
# outside it. They bind one agent's hooks rather than the commit, and §1 says an adapter is
# deletable.
#
# Written before this check, the list named PROTOCOL_GUARDS and not PROTOCOL_DIR, which differ only
# in precedence — step 1 of §5 against step 4.
chain_bypass_vars() {
  local f
  for f in "$DIR/../.githooks/pre-commit" "$DIR"/../guards/*.sh; do
    [ -f "$f" ] || continue
    sed 's/^[[:space:]]*#.*//' "$f" | grep -ohE '\$\{?PROTOCOL_[A-Z_]+' | tr -d '${'
  done | sort -u
}
# §4's bullets, each opening with the variable in bold backticks. Scoped to the section so §6's
# table rows are not read as bullets of it.
chain_bypass_listed() {
  sed -n '/^\*\*The sanctioned bypass is/,/^## /p' "$DIR/../ARCHITECTURE.md" |
    grep -ohE '^- \*\*`PROTOCOL_[A-Z_]+`' | grep -ohE 'PROTOCOL_[A-Z_]+' | sort -u
}
chain_bypass_agree() {
  local missing stale
  missing="$(comm -23 <(chain_bypass_vars) <(chain_bypass_listed) | tr '\n' ' ')"
  stale="$(comm -13 <(chain_bypass_vars) <(chain_bypass_listed) | tr '\n' ' ')"
  [ -z "${missing// /}" ] && [ -z "${stale// /}" ] && return 0
  [ -z "${missing// /}" ] ||
    printf '        changes the chain and §4 does not name it: %s\n' "$missing"
  [ -z "${stale// /}" ] || printf '        named in §4 and the chain never reads it: %s\n' "$stale"
  return 1
}
check "§4's list of quieter bypasses is readable, the fail-open case" \
  '[ -n "$(chain_bypass_listed)" ] && [ -n "$(chain_bypass_vars)" ]'
check "every PROTOCOL_* the shim or a guard expands is one §4 names" 'chain_bypass_agree'
check "and the list can fail" \
  'printf "%s\n" PROTOCOL_NOT_A_BYPASS | comm -23 - <(chain_bypass_listed) | grep -q .'

# Seven: §3 counts the policy files and counts the guards that read one, in two sentences twenty
# lines apart, and the first of them read "it is not the same in all four" directly after a clause
# about guards — four being the policy files and three being the guards, which is a sentence that
# is right on one reading and wrong on the other. Both numbers are the guards' own, so both are
# asked of them, and the sentence says which it is counting.
policy_reads() {   # guard<TAB>the policy file it reads by name, one row each
  local f
  for f in "$DIR"/../guards/*-guard.sh; do
    sed 's/^[[:space:]]*#.*//' "$f" |
      grep -ohE '(policy|exemptions) [a-z][a-z-]+' |
      awk -v g="${f##*/}" '{ print g "\t" $2 }'
  done | sort -u
}
# The sentences are matched against the document with its line breaks flattened to spaces, because
# a claim that happens to wrap is the same claim and a literal search for it is not.
flat() { tr '\n' ' ' < "$1" | tr -s ' '; }
word_lc() { word_for "$1" | tr '[:upper:]' '[:lower:]'; }
counts_as() {   # a sentence with {} where the number goes, and the number the mechanism says
  local sentence
  sentence="${1/\{\}/$(word_lc "$2")}"
  grep -qF "$sentence" <<<"$(flat "$DIR/../ARCHITECTURE.md")" && return 0
  printf '        the mechanism says %s; ARCHITECTURE.md does not say "%s"\n' "$2" "$sentence"
  return 1
}
POLICY_FILES_SAYS='and it is not the same for each of the {} policy files'
POLICY_READERS_SAYS='which means something different for each of the {} rules that read one'
check "the guards read a policy at all, which is the fail-open case for both counts below" \
  '[ "$(policy_reads | grep -c .)" -ge 2 ]'
check "§3's count of the policy files is the number the guards read by name" \
  'counts_as "$POLICY_FILES_SAYS" "$(policy_reads | cut -f2 | sort -u | grep -c .)"'
check "§3's count of the guards that read one is the number that do" \
  'counts_as "$POLICY_READERS_SAYS" "$(policy_reads | cut -f1 | sort -u | grep -c .)"'
check "and both can fail, which is what a sentence found by a literal has to prove" \
  '! counts_as "$POLICY_FILES_SAYS" 9 && ! counts_as "$POLICY_READERS_SAYS" 9'

# Eight: README's front page says how many refutation entries demonstrate a breach. It said four
# the day a fifth was added by the audit that added it, which is the cleanest instance in the tree
# of the rule this block exists for: the page asserting coverage was the only evidence of it.
entry_count_agrees() {
  local n word
  n="$(grep -cE '^### ' "$DIR/../REFUTATION.md")"
  word="$(word_lc "$n")"
  grep -qF "and $word of them are demonstrated there" <<<"$(flat "$DIR/../README.md")" && return 0
  printf '        REFUTATION.md has %s entries; README.md does not say "and %s of them"\n' \
    "$n" "$word"
  return 1
}
check "REFUTATION.md has entries at all, the fail-open case" \
  '[ "$(grep -cE "^### " "$DIR/../REFUTATION.md")" -ge 1 ]'
check "README's count of the entries that demonstrate a breach is the page's own" \
  'entry_count_agrees'
check "and that count can fail" \
  '! grep -qF "and $(word_lc 9) of them are demonstrated there" <<<"$(flat "$DIR/../README.md")"'

# Nine: the one tenant path `bin/adapt` rewrites whether or not it is already there. Every other
# installed path is copied if absent and skipped if present, and both ARCHITECTURE.md's Seeded row
# and CONTRIBUTING.md's bullet stated that as a rule with no exception until 2026-10-13 — which is
# the same defect twice, in the two documents a tenant reads before running the installer. The path
# is read out of `record()` rather than written here, so a second one arriving in that function
# reds both documents at once instead of quietly joining the exception nobody names.
rewritten_path() {
  sed -n '/^record()/,/^}/p' "$DIR/../bin/adapt" |
    grep -ohE '\brel=[A-Za-z0-9_./-]+' | sed 's/^rel=//' | sort -u
}
names_rewritten() {   # file: does it name every path the installer rewrites
  local f=$1 doc path out=""
  doc="$(flat "$f")"
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    grep -qF "\`$path\`" <<<"$doc" ||
      out="$out        ${f##*/} does not name the path bin/adapt rewrites: $path"$'\n'
  done < <(rewritten_path)
  [ -z "$out" ] || { printf '%s' "$out"; return 1; }
}
check "bin/adapt rewrites a tenant path at all, which is the fail-open case for the two below" \
  '[ "$(rewritten_path | grep -c .)" -ge 1 ]'
check "ARCHITECTURE.md names every path the installer rewrites, not all of them seeded" \
  'names_rewritten "$DIR/../ARCHITECTURE.md"'
check "and CONTRIBUTING.md names it too, where the never-edits bullet is" \
  'names_rewritten "$DIR/../CONTRIBUTING.md"'
check "and a path neither document names is caught" \
  '! names_rewritten /dev/null'

# Ten: README's worked refusal is a transcript of what `size-guard.sh` prints, and it was missing
# the bypass line — a page showing a refusal with no way past it, which is the opposite of the
# chain's own claim that the remedy travels with the refusal. Read out of the guard rather than
# compared by eye: the ceiling is substituted from the guard's default too, so a change to either
# the lines or the number reds this instead of leaving the front page quoting a run that no
# longer happens.
refusal_lines() {   # what size-guard.sh says when it refuses a file over the ceiling
  local max
  max="$(sed -n 's/^DEFAULT_MAX_MB=\([0-9]*\)$/\1/p' "$DIR/../guards/size-guard.sh")"
  sed -n '/^if \[ -n "\$toobig" \]/,/^fi$/p' "$DIR/../guards/size-guard.sh" |
    grep -ohE 'echo "pre-commit:[^"]*"' |
    sed -e 's/^echo "//' -e 's/"$//' -e "s/\${MAX_MB}/$max/g"
}
quotes_refusal() {   # file: does it carry every line of that refusal, in the guard's own words
  local f=$1 line doc out=""
  doc="$(flat "$f")"
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    # Squeezed on both sides: `flat` squeezes the document, and these lines indent their remedies
    # with runs of spaces that the flattening collapses. Matching the run would fail on a
    # difference nobody can see.
    line="$(tr -s ' ' <<<"$line")"
    grep -qF "$line" <<<"$doc" || out="$out        ${f##*/} does not quote: $line"$'\n'
  done < <(refusal_lines)
  [ -z "$out" ] || { printf '%s' "$out"; return 1; }
}
check "size-guard.sh prints a refusal at all, the fail-open case for the two below" \
  '[ "$(refusal_lines | grep -c .)" -ge 3 ]'
check "README's worked refusal is the one the guard prints, bypass line included" \
  'quotes_refusal "$DIR/../README.md"'
check "and a page missing one of those lines is caught" \
  '! quotes_refusal /dev/null'

# Eleven: the four remaining count sentences that are load-bearing — a reader counts the thing
# they name and would notice a disagreement, which is the test for deriving one rather than
# cutting it. The decorative ones went instead of being mechanized; a marker list naming which
# sentences carry a count would be this same defect one level up.
says_count() {   # file, a sentence with {} where the number goes, the word to put there
  local sentence=${2/\{\}/$3}
  grep -qF "$sentence" <<<"$(flat "$1")" && return 0
  printf '        %s does not say "%s"\n' "${1##*/}" "$sentence"
  return 1
}
doctrine_docs() {   # the doctrine documents, which is that directory less its own index
  local f n=0
  for f in "$DIR"/../doctrine/*.md; do
    case "${f##*/}" in README.md) continue ;; esac
    n=$((n + 1))
  done
  printf '%s\n' "$n"
}
shim_steps() {   # the numbered steps under §5's heading, which that heading counts
  sed -n '/^## 5\./,/^## 6\./p' "$DIR/../ARCHITECTURE.md" | grep -cE '^[0-9]+\. '
}
verdict_definers() {
  grep -rlE '^verdict\(\)' --include='*.test.sh' "$DIR/.." | sort -u | grep -c .
}
adapter_contract_rows() {   # the files adapters/README.md's contract table requires of an adapter
  sed -n '/^## The contract/,/^## /p' "$DIR/../adapters/README.md" |
    grep -cE '^\| `[a-zA-Z.-]+` \|'
}
DOCS_SAYS='{} documents is not a target and neither is seventy'
STEPS_SAYS='A shim resolves the guards in {} steps, in this order'
VERDICT_SAYS='{} suites here define a `verdict()` of their own'
ADAPTER_SAYS='Then write the {} files'
check "each of the four counted sets is readable, which is the fail-open case for the four below" \
  '[ "$(doctrine_docs)" -ge 1 ] && [ "$(shim_steps)" -ge 1 ] &&
   [ "$(verdict_definers)" -ge 1 ] && [ "$(adapter_contract_rows)" -ge 1 ]'
check "INDUCTION's count of the doctrine documents is the directory's" \
  'says_count "$DIR/../INDUCTION.md" "$DOCS_SAYS" "$(word_for "$(doctrine_docs)")"'
check "§5's heading counts the steps §5 lists" \
  'says_count "$DIR/../ARCHITECTURE.md" "$STEPS_SAYS" "$(word_lc "$(shim_steps)")"'
check "§9's count of the suites defining their own verdict() is the number that do" \
  'says_count "$DIR/../ARCHITECTURE.md" "$VERDICT_SAYS" "$(word_lc "$(verdict_definers)")"'
check "CONTRIBUTING's count of an adapter's files is the adapters contract's" \
  'says_count "$DIR/../CONTRIBUTING.md" "$ADAPTER_SAYS" "$(word_lc "$(adapter_contract_rows)")"'
check "and each of the four can fail" \
  '! says_count "$DIR/../INDUCTION.md" "$DOCS_SAYS" "$(word_for 9)" &&
   ! says_count "$DIR/../ARCHITECTURE.md" "$STEPS_SAYS" "$(word_lc 9)" &&
   ! says_count "$DIR/../ARCHITECTURE.md" "$VERDICT_SAYS" "$(word_lc 9)" &&
   ! says_count "$DIR/../CONTRIBUTING.md" "$ADAPTER_SAYS" "$(word_lc 9)"'

# Twelve: three more of the same kind, each naming a set a mechanism defines rather than a set the
# page lists beside the sentence — which is the line between deriving a count and leaving it to be
# read off the table above it. The scan modes are the guards' own; the adapter variables are §6's
# table minus the chain set Check Six derives; the adapter contract is the table in
# `adapters/README.md`, which that file counts twice in its own prose.
scan_tree_guards() {   # the guards that take --scan-tree, asked of the guards
  grep -lE '^\s+"" \| --scan-tree\)' "$DIR"/../guards/*-guard.sh | sort -u | grep -c .
}
adapter_only_vars() {   # the PROTOCOL_* in §6's table that no chain script expands
  comm -23 <(vars_documented) <(chain_bypass_vars) | grep -c .
}
SCAN_SAYS='{} guards take `--scan-tree`'
ADAPTER_VARS_SAYS='The {} adapter variables in §6'"'"'s table are deliberately outside it'
ADAPTER_DIR_SAYS='A directory under `adapters/` with {} files'
ADAPTER_WRITE_SAYS='Then write the {} files and add nothing to `bin/adapt`'
check "the scan modes and the adapter-only variables are both readable, the fail-open case" \
  '[ "$(scan_tree_guards)" -ge 1 ] && [ "$(adapter_only_vars)" -ge 1 ]'
check "§4's count of the guards taking --scan-tree is the number that do" \
  'says_count "$DIR/../ARCHITECTURE.md" "$SCAN_SAYS" "$(word_for "$(scan_tree_guards)")"'
check "§4's count of the adapter-only variables is §6's table minus the chain set" \
  'says_count "$DIR/../ARCHITECTURE.md" "$ADAPTER_VARS_SAYS" "$(word_lc "$(adapter_only_vars)")"'
check "adapters/README.md counts its own contract table, in both places it states the number" \
  'n="$(word_lc "$(adapter_contract_rows)")"
   says_count "$DIR/../adapters/README.md" "$ADAPTER_DIR_SAYS" "$n" &&
   says_count "$DIR/../adapters/README.md" "$ADAPTER_WRITE_SAYS" "$n"'
check "and each of those can fail" \
  '! says_count "$DIR/../ARCHITECTURE.md" "$SCAN_SAYS" "$(word_for 9)" &&
   ! says_count "$DIR/../ARCHITECTURE.md" "$ADAPTER_VARS_SAYS" "$(word_lc 9)" &&
   ! says_count "$DIR/../adapters/README.md" "$ADAPTER_DIR_SAYS" "$(word_lc 9)"'

finish
