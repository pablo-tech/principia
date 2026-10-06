#!/usr/bin/env bash
# What an absent policy file means — asked of the whole chain at once, because the answer differs.
#   bash guards/absent-policy.test.sh
#
# ARCHITECTURE.md §3 states this as a table of four guards, and `guards/policy.sh`'s header repeats
# the four lines. It is a claim ABOUT THE RELATIONSHIP between the guards, so no single guard's suite
# can hold it: each of those pins its own guard's behaviour, under a name about that guard's own
# concerns, and a reader looking for the asymmetry finds four files none of which asserts it. This
# suite is the table, run against one scratch repository that carries no `.protocol/` at all — the
# shape every repository has before anyone has thought about any of this.
#
# The sentence it exists to keep false is "an absent policy file means the guard exits 0", which was
# doctrine here in six places and is wrong for the credentials guard in the dangerous direction: it
# reads as a repository carrying no `.protocol/` being unguarded, when in fact that is where the
# credentials guard is at its strictest. Documentation drifted from behaviour that every guard's own
# suite already pinned, because nothing pinned the shape of the whole.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
# shellcheck disable=SC1091
source "$DIR/../bin/check.sh"

# bare path content: a fresh repository with NO `.protocol/` directory, holding one staged file.
bare() {
  scratch_repo "$t/repo" >/dev/null
  mkdir -p "$t/repo/$(dirname "$1")" && printf '%s\n' "$2" >"$t/repo/$1"
  git -C "$t/repo" add -A
}
# allow name content: give the repository one policy file, which is how it opts into or out of a rule.
allow() { mkdir -p "$t/repo/.protocol" && printf '%s\n' "$2" >"$t/repo/.protocol/$1" && git -C "$t/repo" add -A; }
guard() { (cd "$t/repo" && bash "$DIR/$1-guard.sh" >/dev/null 2>&1); }

# --- the table, one row at a time -----------------------------------------------------------------
# A denylist with no terms has nothing to refuse, so these two stand down. That is the half of the
# chain the short sentence describes correctly.
bare notes.md "anything at all"
check "tenant: a denylist that is absent has nothing to refuse, so the guard stands down" "guard tenant"
check "identity: an allow-list that is absent and no tenant to inherit one from, likewise" "guard identity"

# The row that is not like the others, and the whole reason this file exists. `credentials-allow-name`
# and `credentials-allow-content` list what is EXEMPT, so absent is an empty exemption list.
bare infra/prod.env "REGION=us-west-2"
check "credentials: two absent ALLOW-lists exempt nothing, so the guard runs at its strictest" "! guard credentials"

# Nothing to be absent: the ceiling is the protocol's and not the repository's to relax, so a
# repository that carries no policy directory has not escaped it either.
scratch_repo "$t/repo" >/dev/null
truncate -s $((25 * 1048576 + 1)) "$t/repo/over.bin" && git -C "$t/repo" add -A
check "size: reads no policy at all, so carrying none changes nothing" "! guard size"

# --- absent against present-and-empty -------------------------------------------------------------
# The guess a reader makes next, and it is wrong for the same reason: an empty allow-list and an
# absent one exempt the same nothing, so a repository cannot opt out of this rule by gesture.
bare infra/prod.env "REGION=us-west-2"
allow credentials-allow-name '# nothing here is exempt yet'
check "credentials: an empty allow-list is no different from an absent one" "! guard credentials"

# Which leaves exactly one way to say it, and saying it is the point: the repository whose job IS to
# hold credentials declares that, in a tracked file, where review can see it.
bare keys/deploy.env "PASSPHRASE=hunter2correct"
allow credentials-allow-name '*'
allow credentials-allow-content '*'
check "credentials: a repository opts out by declaring it, never by omission" "guard credentials"

finish
