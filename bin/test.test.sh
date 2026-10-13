#!/usr/bin/env bash
# What bin/test.sh does with a suite that did not say what it ran.
#
# The runner had no suite of its own, which is how it came to read a suite's exit status alone: a
# truncated suite, one with a debugging `exit 0` left in, one with a syntax error after its last
# check and one running no checks at all all exit 0, and all four were reported as passes.
# doctrine/testing.md:57 is the rule that forbids that — a passing run is evidence about what it
# executed — and this file is what holds the runner to it.
#
# RECURSION IS IMPOSSIBLE HERE, STRUCTURALLY RATHER THAN BY CARE. Every case builds a root under
# `mktemp -d`, copies bin/test.sh and bin/check.sh into it, writes deliberately-wrong suites beside
# them, and runs THE COPY — which `cd`s to its own parent, so its `find` reaches the fixture's
# suites and never this repository's. Nothing here invokes the runner that is running it.
# shellcheck disable=SC2016  # a check's condition is eval'd by the harness, so $t and the helpers
# named in one expand there and not here.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$DIR/.." && pwd)"
# shellcheck source-path=SCRIPTDIR source=check.sh
. "$DIR/check.sh"

t="$(mktemp -d)"
trap 'rm -rf "$t"' EXIT

# ---- the verdict a suite ends with --------------------------------------------------------------
#
# `verdict_line` is the one home of that shape: `finish` prints it and bin/test.sh rebuilds it from
# the lines a suite printed, so the string is asserted here against literals rather than against
# either caller. The two counts either side of that comparison stay independent; the format does not
# have to.
# Every helper in this file is invoked through `check`'s `eval` rather than by a call shellcheck
# can see, which is SC2329's own "ignored if invoked indirectly" — and it is the idiom of every
# suite here. The directive sits above each one rather than at the top of the file, so a helper that
# really is dead still reports.
#
# Two codes, because the two shellchecks that read this tree do not agree on one. 0.11.0 reports the
# function as SC2329; the runner's preinstalled copy reports every command inside it as SC2317, so a
# directive naming only the code the author's own shellcheck printed passes by hand and fails in
# continuous integration. Naming both is what makes the sweep answer the same way in both places,
# and an unknown code in a `disable` list is ignored rather than an error, which is what lets one
# line serve both.
# shellcheck disable=SC2329,SC2317
extends() { # prefix line — the old line is a character-for-character prefix of the new one
  case "$2" in "$1"*) return 0 ;; esac
  return 1
}
check "a passing verdict carries the number of checks the suite executed" \
  "[ \"\$(verdict_line suite 19 0)\" = 'suite: all passed (19 checks)' ]"
check "a failing one carries the failures and the total, in that order" \
  "[ \"\$(verdict_line suite 16 3)\" = 'suite: 3 failed (19 checks)' ]"
check "the count is checks executed, so passes and failures sum to it" \
  "[ \"\$(verdict_line suite 0 4)\" = 'suite: 4 failed (4 checks)' ]"
# The compatibility contract, and the reason the count is appended rather than inserted: 104 suites
# in two repositories print this line, and a consumer runner reading its first words keeps reading
# them. ~/.claude's grid runner is the measured case.
check "a passing verdict extends the line this harness printed before, character for character" \
  "extends 'suite: all passed' \"\$(verdict_line suite 19 0)\""
check "and a failing one extends its own old line too" \
  "extends 'suite: 3 failed' \"\$(verdict_line suite 16 3)\""
# Zero checks gets its own sentence rather than `all passed (0 checks)`, which is the verdict this
# whole mechanism exists to stop being printable.
check "a suite that executed nothing says so, rather than passing with a count of zero" \
  "[ \"\$(verdict_line suite 0 0)\" = 'suite: no checks ran' ]"

# ---- the names this harness owns ----------------------------------------------------------------
#
# A suite defining `check`, `finish`, `verdict_line` or `scratch_repo` replaces the harness's for
# every call made after the definition — including the call `finish` makes — and nothing announces
# the substitution. This is not hypothetical and not cheap: three suites here define `verdict()` of
# their own, so a harness formatter named `verdict` would have had `finish` print `deny` or `ask` as
# a suite's verdict. That collision was available inside the fix for the verdict defect, which is
# why the rule is a check rather than a sentence advising care.
OWNED='check finish verdict_line scratch_repo'
# shellcheck disable=SC2329,SC2317
shadowed_names() { # file -> each harness name this file defines
  local name
  for name in $OWNED; do
    grep -qE "^[[:space:]]*${name}[[:space:]]*\(\)" "$1" && printf '%s\n' "$name"
  done
  return 0
}
# shellcheck disable=SC2329,SC2317
suites_here() { (cd "$ROOT" && git ls-files '*.test.sh'); }
# shellcheck disable=SC2329,SC2317
shadowing_suites() {
  local suite names found=""
  while IFS= read -r suite; do
    names="$(shadowed_names "$ROOT/$suite" | tr '\n' ' ')"
    [ -z "${names// /}" ] || found="$found
        $suite: ${names% }"
  done < <(suites_here)
  [ -z "$found" ] && return 0
  printf '        a suite defines a name bin/check.sh owns:%s\n' "$found"
  return 1
}
printf 'verdict_line() { echo nope; }\n' >"$t/shadows.test.sh"
check "the suite list is readable, which is the fail-open case" '[ -n "$(suites_here)" ]'
check "no suite in this repository defines a name the harness owns" 'shadowing_suites'
check "and the detector can tell, given a file that does define one" \
  "[ \"\$(shadowed_names \"$t/shadows.test.sh\")\" = verdict_line ]"

# ---- what the runner does with a suite that did not say what it ran ----------------------------
#
# Every case below runs a COPY of bin/test.sh over a root of deliberately-wrong suites. The copy
# `cd`s to its own parent, so its `find` reaches the fixture's suites and never this repository's:
# there is no recursion to avoid because there is none available.
#
# The payoff of the copy is that red-first is mechanical rather than disciplined. Written against
# the runner as it was, these checks are red for the right reason the moment they exist, instead of
# being appended to a suite that is already green — which is what REFUTATION.md:70 records as the
# thing that went missing last time.
fixture() { # name -> a root holding the runner, the harness, and nothing else
  local root="$t/$1"
  rm -rf "$root" && mkdir -p "$root/bin"
  cp "$DIR/test.sh" "$DIR/check.sh" "$root/bin/"
  printf '%s' "$root"
}
# suite <root> <name> <line>...: a fixture suite, sourcing the copied harness the way a real suite
# sources the real one.
suite() {
  local root=$1 name=$2
  shift 2
  { printf '#!/usr/bin/env bash\nset -uo pipefail\n'
    printf 'D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"\n'
    printf '. "$D/bin/check.sh"\n'
    printf '%s\n' "$@"
  } >"$root/$name.test.sh"
}
# The status is captured into a variable before anything else reads it. `$?` is the status of the
# last command, and a `$(basename …)` in the line that reads it has already replaced it — which is
# how a consumer's own runner, reading this harness through a symlink, once read a crashing suite
# as `ok`.
#
# `out` and `rc` are read only inside the conditions `check` evals, which shellcheck does not look
# into, so every assignment to either needs the directive rather than only their declarations.
# shellcheck disable=SC2034
out=""
# shellcheck disable=SC2034
rc=0
ran() { # root
  # shellcheck disable=SC2034
  out="$( (cd "$1" && bash bin/test.sh) 2>&1 )"
  # shellcheck disable=SC2034
  rc=$?
}

# The fail-open control for every case after it: this root is correct, so a rule that refuses it
# refuses everything and the reds below would mean nothing.
r="$(fixture passing)"
suite "$r" alpha 'check "one" true' 'check "two" true' 'finish'
suite "$r" beta 'check "one" true' 'finish'
ran "$r"
check "a root whose suites all pass passes, which is the control for every case below" \
  '[ "$rc" -eq 0 ]'
check "and the run says what it executed, in suites and in checks" \
  '[ "$(printf "%s\n" "$out" | tail -n 1)" = "all suites passed (2 suites, 3 checks)" ]'

r="$(fixture failing)"
suite "$r" alpha 'check "one" true' 'check "two" false' 'finish'
suite "$r" beta 'check "one" true' 'finish'
ran "$r"
check "a suite with a failed check fails the run" '[ "$rc" -ne 0 ]'
check "and the failing run says what it executed too, which is the number a green run hides" \
  '[ "$(printf "%s\n" "$out" | tail -n 1)" = "1 suite(s) failed of 2 (3 checks)" ]'

# The four shapes of "exited 0 without finishing", which were reported identically to a pass.
r="$(fixture truncated)"
suite "$r" alpha 'check "one" true' 'check "two" true'
ran "$r"
check "a suite that never reaches its verdict fails the run" '[ "$rc" -ne 0 ]'
check "and the runner names the suite and what it was looking for" \
  'grep -q "alpha.test.sh did not end with the verdict its own output implies" <<<"$out"'
check "and prints both lines, so the gap is readable rather than inferred" \
  'grep -q "implied:" <<<"$out" && grep -q "alpha: all passed (2 checks)" <<<"$out"'

r="$(fixture early-exit)"
suite "$r" alpha 'check "one" true' 'exit 0' 'check "two" true' 'finish'
ran "$r"
check "a debugging exit left in a suite fails the run rather than shortening it" '[ "$rc" -ne 0 ]'

r="$(fixture no-checks)"
suite "$r" alpha 'echo "setting up"' 'finish'
suite "$r" beta 'check "one" true' 'finish'
ran "$r"
check "a suite that executed no checks fails the run" '[ "$rc" -ne 0 ]'
check "and the runner asks that itself rather than trusting the suite to have asked" \
  'grep -q "alpha.test.sh executed no checks" <<<"$out"'

# A syntax error before the verdict, which is where one lands: `finish` exits, so anything after it
# is never parsed. The status rule already caught this one; what is new is that the runner names the
# verdict the suite never printed, rather than reporting a number the shell happened to exit with.
r="$(fixture syntax-error)"
suite "$r" alpha 'check "one" true' 'if then fi' 'check "two" true' 'finish'
ran "$r"
check "a suite that dies before its verdict fails the run" '[ "$rc" -ne 0 ]'
check "and is named by the verdict it never printed, not only by the status it exited with" \
  'grep -q "alpha.test.sh did not end with the verdict" <<<"$out"'

# The three shapes of "said something other than what it ran". One string comparison refuses all of
# them, because the line the runner rebuilds from a suite's own output is the only line it accepts.
r="$(fixture raw-fail)"
suite "$r" alpha 'check "one" true' 'printf "  FAIL  two\n"' 'finish'
ran "$r"
check "a FAIL line under a passing verdict fails the run" '[ "$rc" -ne 0 ]'

r="$(fixture miscount)"
suite "$r" alpha 'check "one" true' 'check "two" true' \
  'printf "alpha: all passed (9 checks)\n"' 'exit 0'
ran "$r"
check "a verdict declaring more checks than the suite printed fails the run" '[ "$rc" -ne 0 ]'

r="$(fixture borrowed)"
suite "$r" alpha 'check "one" true' 'check "two" true' \
  'printf "beta: all passed (2 checks)\n"' 'exit 0'
ran "$r"
check "a verdict naming another suite fails the run, so a copied line cannot stand in" \
  '[ "$rc" -ne 0 ]'

r="$(fixture trailing)"
suite "$r" alpha 'check "one" true' 'check "two" true' \
  'printf "alpha: all passed (2 checks)\n"' 'echo "cleaning up"' 'exit 0'
ran "$r"
check "a verdict that is not the last thing a suite said fails the run" '[ "$rc" -ne 0 ]'

# And the status rule is still there beside the string rule. A suite can print exactly the right
# verdict and still have exited non-zero, and the new rule must not have replaced the old one.
r="$(fixture bad-status)"
suite "$r" alpha 'check "one" true' 'check "two" true' 'verdict_line alpha 2 0' 'exit 3'
ran "$r"
check "a suite whose verdict is right and whose exit status is not fails the run" '[ "$rc" -ne 0 ]'
check "and the runner reports the status it saw" 'grep -q "alpha.test.sh exited 3" <<<"$out"'

# How the suites are found, where every error is in the fail-open direction: a suite that exists and
# is never run reports nothing at all, and nothing anywhere says it did not run.
r="$(fixture stdin)"
suite "$r" alpha 'check "one" true' 'check "two" true' 'cat >/dev/null' 'finish'
suite "$r" beta 'check "one" true' 'check "two" true' 'finish'
suite "$r" gamma 'check "one" true' 'check "two" true' 'finish'
ran "$r"
check "a suite that reads its standard input does not swallow the suites still to run" \
  '[ "$rc" -eq 0 ] && grep -q "^gamma: all passed" <<<"$out"'
check "and the count says all three ran, which is what names the swallowed ones" \
  'grep -q "(3 suites, 6 checks)" <<<"$out"'

r="$(fixture decoy)"
suite "$r" alpha 'check "one" true' 'check "two" true' 'finish'
suite "$r" beta 'check "one" true' 'check "two" true' 'finish'
mkdir -p "$r/notasuite.test.sh"
ran "$r"
check "a directory whose name ends in .test.sh is not handed to bash as a suite" '[ "$rc" -eq 0 ]'
check "and is not counted as one either" 'grep -q "(2 suites, 4 checks)" <<<"$out"'

# A symlinked suite is the case `-type f` alone would drop, which is why the test is `-type f -o
# -type l` rather than the obvious half of it. Green before this warp and after it: a regression
# guard for a correction made in passing, not a red.
r="$(fixture symlinked)"
suite "$r" alpha 'check "one" true' 'check "two" true' 'finish'
ln -s alpha.test.sh "$r/beta.test.sh"
ran "$r"
check "a symlinked suite is run and counted, which -type f alone would silently drop" \
  '[ "$rc" -eq 0 ] && grep -q "(2 suites, 4 checks)" <<<"$out"'

# The list is fixed before the first suite runs. This held already, by accident rather than by
# design — `find … | sort` makes `sort` read the whole walk before it emits a line — and the array
# is what makes it a property of this runner instead of of a pipeline element chosen for its order.
r="$(fixture growing)"
suite "$r" alpha 'check "one" true' 'check "two" true' \
  'printf "if then fi\n" >"$D/zeta.test.sh"' 'finish'
ran "$r"
check "a suite written while the run is in progress is not picked up by it" \
  '[ "$rc" -eq 0 ] && grep -q "(1 suite, 2 checks)" <<<"$out"'

r="$(fixture empty)"
ran "$r"
check "a root with no suites in it is a failure rather than a clean run" '[ "$rc" -ne 0 ]'
check "and the runner says it found none" 'grep -q "found no suites" <<<"$out"'

finish
