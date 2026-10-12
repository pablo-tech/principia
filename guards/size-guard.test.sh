#!/usr/bin/env bash
# size-guard.sh against the index of a scratch repository, on either side of the 25 MB ceiling.
#   bash guards/size-guard.test.sh
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
# shellcheck disable=SC1091
source "$DIR/../bin/check.sh"

MB=1048576
# stage bytes path: a fresh repository whose index holds one file of that size.
stage() { scratch_repo "$t/repo" >/dev/null && truncate -s "$1" "$t/repo/$2" && git -C "$t/repo" add -A; }
guard() { (cd "$t/repo" && bash "$DIR/size-guard.sh" >/dev/null 2>&1); }

stage $((25 * MB)) exactly.bin
check "a file of exactly 25 MB is let through" "guard"
stage $((25 * MB + 1)) over.bin
check "one byte more is refused" "! guard"
stage $((25 * MB + 1)) "with space.bin"
check "a path with a space in it is still measured" "! guard"
stage $((25 * MB + 1)) over.bin
echo small > "$t/repo/over.bin"
check "the staged blob is what counts, not the file on disk" "! guard"
stage $((2 * MB)) two.bin
check "PROTOCOL_MAX_FILE_MB lowers the ceiling" "! (cd '$t/repo' && PROTOCOL_MAX_FILE_MB=1 bash '$DIR/size-guard.sh' >/dev/null 2>&1)"

# A moved ceiling says so. The override is documented and deliberate, and it is still the quietest
# of the chain's bypasses: the blob lands in history at a size the ceiling refuses and nothing in
# the commit records that the ceiling was moved. So the line is printed on a pass as well, which is
# the case that had no output at all until 2026-10-12.
stage $((2 * MB)) two.bin
# shellcheck disable=SC2034 # read inside the check expression below
raised="$( (cd "$t/repo" && PROTOCOL_MAX_FILE_MB=100 bash "$DIR/size-guard.sh" 2>&1) )"
check "a raised ceiling is reported even though nothing is refused" \
  "grep -q 'ceiling is 100 MB, not the protocol.s 25 MB' <<<\"\$raised\" &&
   grep -q 'PROTOCOL_MAX_FILE_MB' <<<\"\$raised\""
check "and the default says nothing, there being nothing to report" \
  "[ -z \"\$( (cd '$t/repo' && bash '$DIR/size-guard.sh' 2>&1) )\" ]"

# Both were seen passing against the guard as it stood: a renamed path reached no guard at all, and
# an unreadable index read as an empty one.
stage $((25 * MB + 1)) over.bin
git -C "$t/repo" commit -qm x
git -C "$t/repo" mv over.bin renamed.bin
check "an oversized file renamed is still measured, not skipped as a rename" "! guard"

stage $((2 * MB)) two.bin
check "an index git cannot read refuses rather than reading as nothing staged" \
  "! (cd '$t/repo' && printf x > .git/bad-index && GIT_INDEX_FILE=.git/bad-index bash '$DIR/size-guard.sh' >/dev/null 2>&1)"

finish
