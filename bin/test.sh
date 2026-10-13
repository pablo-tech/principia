#!/usr/bin/env bash
# Every suite in the repository, one line of verdict each — and each verdict judged against the
# output it sits on top of rather than read off the end of it.
#   bin/test.sh
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

# Sourced for `verdict_line` alone, so the shape of a verdict has one home: `finish` prints the line
# a suite ends with and this file rebuilds the line it should have ended with. What has to stay
# independent is the two COUNTS either side of that comparison — the suite counts its checks as it
# runs them, this file counts the lines they printed — and a shared formatter cannot make two
# different counts agree. Counting lines alone would not do either: `bin/doctor:49` prints
# `  ok    %s` byte-identically, so a suite echoing doctor's output inflates this file's count, and
# the disagreement is then the finding rather than a miscount nobody sees.
# shellcheck source=bin/check.sh
. bin/check.sh

# `fails` and `passes` belong to the harness just sourced. These three are this file's own.
broken=0
suites_run=0
checks_run=0

# count n noun — `1 suites` is the kind of wart that makes a reader doubt the number beside it.
count() {
  if [ "$1" -eq 1 ]; then printf '%d %s' "$1" "$2"; else printf '%d %ss' "$1" "$2"; fi
}

# Found rather than listed: an adapter that brings its own suites is then tested by existing here,
# which is the same reason bin/adapt discovers adapters by directory.
#
# `-type f -o -type l` rather than the obvious half of it. A directory named `x.test.sh` was being
# handed to bash, and `-type f` alone would drop a symlinked suite — which is the fail-open
# direction, because a suite that exists and never runs reports nothing at all and nothing anywhere
# says it did not run.
#
# Collected into an array before the first suite runs. That was already true, and true for a reason
# nobody chose: `sort` reads the whole walk before it emits a line. The array makes it a property of
# this file rather than of a pipeline element present for its ordering.
found=0
suites=()
while IFS= read -r suite; do
  suites+=("$suite")
  found=$((found + 1))
done < <(find . \( -type f -o -type l \) -name '*.test.sh' -not -path './.git/*' | sort)

# Nothing to run is the quietest pass available, and `all suites passed` over an empty list is a
# sentence this file should not be able to print.
if [ "$found" -eq 0 ]; then
  echo "test.sh: found no suites under $PWD, which is a failure rather than a clean run"
  exit 1
fi

for suite in "${suites[@]}"; do
  echo "== $suite"
  # `</dev/null` so a suite reading standard input cannot consume the list of suites still to run —
  # the loop's stdin is the walk, and a suite that drained it took the rest of the run with it,
  # silently and in the fail-open direction.
  #
  # Buffered rather than streamed, because the output is the evidence: judging a suite's last line
  # means having all of its output, and which line is last is not knowable until there is no more.
  # A run still reports as it goes, suite by suite rather than line by line.
  #
  # The status into a variable before anything else reads it. `$?` is the status of the last
  # command, and a `$(basename …)` on the line that reads it has already replaced it — which is how
  # a consumer's own runner, reading this harness through a symlink, once read a crashing suite as
  # `ok`.
  out="$(bash "$suite" </dev/null 2>&1)"
  status=$?
  printf '%s\n' "$out"

  name="${suite##*/}"
  name="${name%.test.sh}"
  ok="$(printf '%s\n' "$out" | grep -c '^  ok    ')"
  bad="$(printf '%s\n' "$out" | grep -c '^  FAIL  ')"
  last="$(printf '%s\n' "$out" | tail -n 1)"
  want="$(verdict_line "$name" "$ok" "$bad")"
  suites_run=$((suites_run + 1))
  checks_run=$((checks_run + ok + bad))

  # Asked here as well as in `finish`, because a suite can only report a number it reached the end
  # to report — and because a consumer may run these suites through a runner of its own that never
  # asks it.
  if [ "$((ok + bad))" -eq 0 ]; then
    echo "test.sh: $suite executed no checks, so nothing it printed says what it ran"
    broken=$((broken + 1))
    continue
  fi
  # One string comparison, four assertions: the suite reached its verdict, the verdict was the last
  # thing it said, it named itself rather than carrying another suite's line, and the count it
  # declared is the count it printed.
  if [ "$last" != "$want" ]; then
    echo "test.sh: $suite did not end with the verdict its own output implies"
    echo "test.sh:   last line: $last"
    echo "test.sh:   implied:   $want"
    broken=$((broken + 1))
    continue
  fi
  # A suite that reported its own failures has already printed them, so it is counted and not
  # commented on. The exit status is still read afterwards: a suite can print exactly the right
  # verdict and have exited non-zero anyway, and the line above must not stand in for that.
  if [ "$bad" -gt 0 ]; then
    broken=$((broken + 1))
    continue
  fi
  if [ "$status" -ne 0 ]; then
    echo "test.sh: $suite exited $status"
    broken=$((broken + 1))
  fi
done

# What the run executed, on the pass as well as on the failure. A verdict carrying only failure
# counts says the same thing about a run of several hundred checks and a run of none, which is what
# doctrine/testing.md:57 is about. No count is written down in this file or in any document: a
# number either place would be a claim about what this line prints, kept by hand. Both lines extend
# the ones this file printed before, character for character.
if [ "$broken" -eq 0 ]; then
  printf 'all suites passed (%s, %s)\n' \
    "$(count "$suites_run" suite)" "$(count "$checks_run" check)"
else
  printf '%d suite(s) failed of %d (%s)\n' "$broken" "$suites_run" "$(count "$checks_run" check)"
  exit 1
fi
