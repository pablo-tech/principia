#!/usr/bin/env bash
# guards.sh — the dispatcher every repository's pre-commit shim reaches, against stubs.
#   bash guards/guards.test.sh
#
# ARCHITECTURE.md §4 makes four claims about this file: the order it runs the guards in, that it
# stops at the first non-zero exit, that a guard which is missing or not executable BLOCKS rather
# than being skipped, and that it is the single entry point. Nothing asserted any of them, in the
# one file whose whole job is to fail closed — and §9 says every script has a suite beside it.
#
# Stubs rather than the real guards, for the same reason command-guards.test.sh uses them: a real
# guard cannot be made to be missing, or to fail for a reason of its own. The names come from the
# dispatcher itself rather than a second copy of the list, because the list drifting out of step
# with what is in guards/ is one of the things this pins.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
# shellcheck disable=SC1091
source "$DIR/../bin/check.sh"

# The `for g in ...` list, read off the dispatcher.
guard_names() { sed -n 's/^for g in \(.*\); do$/\1/p' "$DIR/guards.sh"; }

# A set of stubs, each announcing itself so the order is readable off the output.
stubs() {
  rm -rf "$t/g" && mkdir -p "$t/g"
  local g
  for g in $(guard_names); do
    printf '#!/usr/bin/env bash\necho "%s"\nexit 0\n' "$g" >"$t/g/$g"
    chmod +x "$t/g/$g"
  done
}
# chain: run the dispatcher against the stub directory, from a scratch repository.
scratch_repo "$t/repo" notes.md >/dev/null
chain() { (cd "$t/repo" && PROTOCOL_GUARDS="$t/g" bash "$DIR/guards.sh" 2>&1); }
ran() { chain | tr '\n' ' '; }
rc() { local r=0; chain >/dev/null 2>&1 || r=$?; printf '%s' "$r"; }

check "the dispatcher names guards that exist and are executable" \
  "[ -n \"\$(guard_names)\" ] && for g in \$(guard_names); do [ -x '$DIR/'\$g ] || exit 1; done"

# The order is the claim, not an accident of the list: the size ceiling is cheapest to answer and
# the identity check reads git configuration, so a refusal arrives in the order a reader expects.
stubs
check "every guard runs, in the order the dispatcher lists them" \
  "[ \"\$(ran)\" = \"\$(guard_names | tr ' ' '\\n' | tr '\\n' ' ')\" ]"
check "and a full set of passing guards exits 0" "[ \"\$(rc)\" = 0 ]"

# Fail closed. These three are the whole promise, and all three were unasserted.
stubs && rm "$t/g/$(guard_names | awk '{print $2}')"
check "a missing guard blocks rather than being skipped" "[ \"\$(rc)\" = 1 ]"
check "and the refusal names the guard that is missing" \
  "[ -n \"\$( chain | grep -F \"\$(guard_names | awk '{print \$2}')\" )\" ]"
stubs && chmod -x "$t/g/$(guard_names | awk '{print $2}')"
check "so does one that is not executable" "[ \"\$(rc)\" = 1 ]"

# The short-circuit, which is what makes a refusal readable: a commit refused by four guards at once
# is four problems to a reader and one to the person who staged it.
stubs && printf '#!/usr/bin/env bash\necho refused\nexit 1\n' >"$t/g/$(guard_names | awk '{print $1}')"
check "the first non-zero exit stops the chain" "[ \"\$(ran)\" = 'refused ' ]"
check "and the chain exits with that guard's own status" "[ \"\$(rc)\" = 1 ]"

# A guard that fails for a reason of its own is still a guard that did not approve. Exit 3 rather
# than 1, because a chain that mapped every failure onto 1 would hide the difference.
stubs && printf '#!/usr/bin/env bash\nexit 3\n' >"$t/g/$(guard_names | awk '{print $1}')"
check "a guard failing for a reason of its own stops the chain too" "[ \"\$(rc)\" = 3 ]"

# Every check above rides on PROTOCOL_GUARDS redirecting the whole chain before any guard is read,
# so that claim is already pinned and is not asserted again here. What is left is the two shapes a
# redirect can take badly, both of which are a chain of no guards at all.
mkdir -p "$t/empty"
blocks() { (cd "$t/repo" && PROTOCOL_GUARDS="$1" bash "$DIR/guards.sh" >/dev/null 2>&1) || echo blocked; }
check "an empty guards directory blocks rather than approving" "[ \"\$(blocks '$t/empty')\" = blocked ]"
check "so does one that is not there at all" "[ \"\$(blocks '$t/nowhere')\" = blocked ]"

finish
