# shellcheck shell=bash
# Sourced by the shell suites that are a list of checks rather than a table of verdicts, and by
# bin/test.sh, which judges what they printed rather than reading their exit status alone.
fails=0
# What a passing run executed, which is the number doctrine/testing.md is about: a verdict reporting
# only failures says the same thing about a suite that ran 40 checks and one that ran none.
passes=0
# name condition: the condition is eval'd, so each check reads as what it asserts.
check() { # name condition
  if eval "$2"; then printf "  ok    %s\n" "$1"; passes=$((passes+1))
  else printf "  FAIL  %s\n" "$1"; fails=$((fails+1))
  fi
}
# verdict_line name passes fails: the one line a suite ends with. It is a function rather than two
# printfs inside `finish` because bin/test.sh rebuilds this line from the `ok` and `FAIL` lines a
# suite printed and refuses the suite unless its last line is that line byte for byte — so the shape
# has one home, and the two counts either side of that comparison are what stay independent. A
# shared formatter cannot make two different counts agree.
#
# Named `verdict_line` rather than `verdict` because three suites in this repository define
# `verdict()` of their own after sourcing this file, and a dozen more could: a name this file calls
# is a name this file owns, and taking `verdict` would have had `finish` print `deny` or `ask` as a
# suite's verdict with nothing announcing the substitution. bin/test.test.sh asserts that no suite
# shadows a name owned here.
#
# Zero checks has its own wording rather than `all passed (0 checks)`, which is the sentence this
# whole mechanism exists to stop being printable.
verdict_line() { # name passes fails
  local total=$(( $2 + $3 ))
  if [ "$total" -eq 0 ]; then printf '%s: no checks ran\n' "$1"
  elif [ "$3" -eq 0 ]; then printf '%s: all passed (%d checks)\n' "$1" "$total"
  else printf '%s: %d failed (%d checks)\n' "$1" "$3" "$total"
  fi
}
# The last line, and the exit status test.sh reads as the verdict.
#
# Both arms exit. The passing one used to fall off the end, which made "the verdict is the last line
# a suite printed" a property of every author having written nothing after `finish` rather than of
# this file — and bin/test.sh now requires it of the output, so it has to be true by construction.
# `exit` runs EXIT traps, so the suites that install `trap 'rm -rf "$t"' EXIT` still clean up.
#
# Zero checks is a failure. A suite that ran none is the case a green run cannot distinguish from a
# suite that passed, and it is the shape a truncated file, a stray `exit 0` and a sourcing error all
# arrive in.
finish() {
  local name=${0##*/}
  name=${name%.test.sh}
  verdict_line "$name" "$passes" "$fails"
  if [ "$fails" -ne 0 ] || [ "$((passes + fails))" -eq 0 ]; then exit 1; fi
  exit 0
}
# scratch_repo dir path...: a fresh repository at dir whose index holds just these paths.
scratch_repo() {
  local repo=$1 path
  shift
  rm -rf "$repo" && git init -q "$repo"
  for path in "$@"; do mkdir -p "$repo/$(dirname "$path")" && echo x >"$repo/$path"; done
  git -C "$repo" add -A
}
