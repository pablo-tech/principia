#!/usr/bin/env bash
# policy.sh's two layers: the tracked `.protocol/<name>` and the untracked `.protocol/<name>.local`.
#   bash guards/policy.test.sh
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
# shellcheck disable=SC1091
source "$DIR/../bin/check.sh"
# shellcheck source-path=SCRIPTDIR source=policy.sh
source "$DIR/policy.sh"

# The root as git reports it, which is not always the string `$t` carries. `git rev-parse
# --show-toplevel` answers with the physical path, and on macOS `mktemp -d` hands back a path
# through the `/var` -> `/private/var` symlink — so a check comparing a refusal's text to a path has
# to compare it to the path the refusal would print. Resolved once: `layers` recreates the
# repository but never moves it.
repo_root="$(cd "$t" && pwd -P)/repo"

# layers <tracked> <overlay>: a fresh repository carrying whichever of the two is not `-`.
layers() {
  rm -rf "${t:?}/repo" && git init -q "$t/repo" && mkdir -p "$t/repo/.protocol"
  [ "$1" = - ] || printf '%s\n' "$1" >"$t/repo/.protocol/thing"
  [ "$2" = - ] || printf '%s\n' "$2" >"$t/repo/.protocol/thing.local"
}
# The resolved lines, flattened with commas so a check can state the whole answer on one line.
resolve() { (cd "$t/repo" && policy thing) | paste -sd, -; }
# The status alone, which is what a guard branches on.
found() { (cd "$t/repo" && policy thing >/dev/null); }
# The exact status, because 1 and 2 are different answers and `!` cannot tell them apart.
status() { (cd "$t/repo" && policy thing >/dev/null 2>&1); echo "$?"; }
# What outcome 2 could not read. It comes back on stdout rather than in `POLICY_UNREADABLE`, because
# every caller reads a policy inside a command substitution and a variable set there is set in a
# shell that has already exited.
reason() { (cd "$t/repo" && policy thing 2>/dev/null); }

layers - -
check "a repository carrying neither layer has no such policy" "[ \"\$(status)\" = 1 ]"

layers 'alpha' -
check "a tracked policy alone reads as it always has" "found && [ \"\$(resolve)\" = alpha ]"

layers 'alpha' 'beta'
check "an overlay is appended to the tracked file, in that order" "[ \"\$(resolve)\" = alpha,beta ]"

layers - 'beta'
check "an overlay alone is a policy, with no tracked file" "found && [ \"\$(resolve)\" = beta ]"

layers 'alpha' '# a name nobody else needs

beta'
check "the overlay is comment-stripped like the tracked file" "[ \"\$(resolve)\" = alpha,beta ]"

layers 'alpha ' 'beta	'
check "trailing whitespace is trimmed from either layer" "[ \"\$(resolve)\" = alpha,beta ]"

# --- reading another repository's policy ----------------------------------------------------------
# The second argument, which only the identity guard passes, and only so that a repository worked
# on under a tenant is held to the tenant's list rather than to none at all.
layers 'alpha' 'beta'
mkdir -p "$t/elsewhere/.protocol"
printf 'gamma\n' >"$t/elsewhere/.protocol/thing"
check "a named root is read instead of the repository the guard is running in" \
  "[ \"\$( (cd \"$t/repo\" && policy thing \"$t/elsewhere\") | paste -sd, -)\" = gamma ]"
# Named rather than searched for: a guard that passes a root has already decided which one, and
# `git rev-parse` from inside it would answer about whatever repository happens to contain it.
check "a named root that carries no such policy is still no such policy" \
  "! (cd \"$t/repo\" && policy nothing \"$t/elsewhere\" >/dev/null)"

# --- the tenant a repository is worked on under ---------------------------------------------------
# Local git configuration, where core.hooksPath is: a repository worked on under a tenant is
# deliberately not a tenant, so it has nowhere in its tree to record this and should not have one.
layers - -
check "a repository nothing wired to a tenant answers with none" \
  "! (cd \"$t/repo\" && tenant_root >/dev/null)"
git -C "$t/repo" config principia.tenant "$t/elsewhere"
check "one that was answers with the tenant" \
  "[ \"\$( (cd \"$t/repo\" && tenant_root) )\" = \"$t/elsewhere\" ]"
# A tenant that has moved or been removed leaves the setting behind pointing at nothing. Answering
# with a directory that is not a tenant would have every guard that asked read its policies from a
# path of git configuration's choosing.
git -C "$t/repo" config principia.tenant "$t/no-such-directory"
check "a tenant that is no longer there is not a tenant" \
  "! (cd \"$t/repo\" && tenant_root >/dev/null)"

# --- outcome 2: a policy the guard could not READ -------------------------------------------------
# The whole of this change. `policy` answered 1 both for "this repository declares no policy" and
# for "git could not tell me where its root is", and the two call sites read 1 as "stand down" — so
# a guard approved a commit it had examined no part of, silently, which is the default
# doctrine/tenancy.md's own section says a control does not get to have. The two answers are now 1
# and 2, and every check below reads the NUMBER: `!` cannot tell them apart, which is why the check
# above is written `= 1` and not `! found`.
check "the fixture's own root is in no repository at all, which the next check needs" \
  "! git -C \"$t\" rev-parse --show-toplevel >/dev/null 2>&1"
check "a directory in no repository is outcome 2, not no-such-policy" \
  "[ \"\$( (cd \"$t\" && policy thing >/dev/null 2>&1); echo \$? )\" = 2 ]"

layers 'alpha' -
chmod 000 "$t/repo/.protocol/thing"
check "chmod 000 does make a file unreadable here, which the next three checks need" \
  "! [ -r \"$t/repo/.protocol/thing\" ]"
check "and git reports the root as this suite spells it, which the reason checks compare against" \
  "[ \"\$( (cd \"$t/repo\" && git rev-parse --show-toplevel) )\" = \"$repo_root\" ]"
check "a tracked layer present and unreadable is outcome 2, where it read as an empty policy" \
  "[ \"\$(status)\" = 2 ]"
# The remedy has to be derivable from the refusal, or the operator is left with the one remedy
# always available, which is to bypass the chain.
check "and the reason names the file, so the refusal carries its own remedy" \
  "[ \"\$(reason)\" = \"$repo_root/.protocol/thing is present and could not be read\" ]"
chmod 644 "$t/repo/.protocol/thing"
check "the same file readable again is outcome 0, so the status is the file and not the fixture" \
  "[ \"\$(status)\" = 0 ]"

layers 'alpha' 'beta'
chmod 000 "$t/repo/.protocol/thing.local"
check "an overlay present and unreadable is outcome 2, not the tracked layer read alone" \
  "[ \"\$(status)\" = 2 ]"
# Outcome 2 writes the reason where the content would have gone, which is only safe because the two
# never coexist. This is the check that holds that: the readable layer's `alpha` is not in there.
check "and the layer it could read does not travel beside the reason" \
  "[ \"\$(reason)\" = \"$repo_root/.protocol/thing.local is present and could not be read\" ]"
chmod 644 "$t/repo/.protocol/thing.local"
check "both readable again is outcome 0 with both layers, the unreadable one being the cause" \
  "[ \"\$(status)\" = 0 ] && [ \"\$(resolve)\" = alpha,beta ]"

# --- which copy of the tracked layer is authoritative ---------------------------------------------
# The policy that judges a commit has to be the policy that is IN it. Read from the worktree, one
# unstaged edit to a denylist disarms the guard completely and leaves nothing in the diff for a
# reviewer to see: the file on disk says one thing, the file the commit records says another, and
# the guard believed the one nobody is committing.
#
# `layers` stages nothing, so every check above this point reads the worktree — and that is this
# section's control rather than an omission in it: a path the index does not carry is read from
# disk, because the worktree copy is then the only copy there is.
#
# staged <in the index> <on disk, or - to leave the index copy in place>
staged() {
  rm -rf "${t:?}/repo" && git init -q "$t/repo" && mkdir -p "$t/repo/.protocol"
  printf '%s\n' "$1" >"$t/repo/.protocol/thing"
  git -C "$t/repo" add .protocol/thing
  [ "$2" = - ] || printf '%s\n' "$2" >"$t/repo/.protocol/thing"
}

staged 'alpha' 'GONE'
check "the tracked layer is read from the index, not from the worktree" "[ \"\$(resolve)\" = alpha ]"
check "and the worktree copy does say something else, which the check above needs" \
  "[ \"\$(cat \"$t/repo/.protocol/thing\")\" = GONE ]"
staged 'alpha' -
check "a staged layer nobody has since edited reads as itself" "[ \"\$(resolve)\" = alpha ]"
printf 'beta\n' >"$t/repo/.protocol/thing.local"
check "the overlay is still read from the worktree, which is the only place it can be" \
  "[ \"\$(resolve)\" = alpha,beta ]"
layers 'alpha' -
check "a tracked-layer path the index does not carry is read from disk, not called unreadable" \
  "[ \"\$(status)\" = 0 ] && [ \"\$(resolve)\" = alpha ]"
# A named root is the tenant. Nothing is being committed there, so there is no commit for an index
# read to be about, and it need not be a git repository at all — which `$t/elsewhere` above is half
# of. This is the other half: it IS one, with an index of its own, and the worktree still wins.
staged 'INDEX' 'WORKTREE'
check "a named root is read from its worktree even where it has an index of its own" \
  "[ \"\$( (cd \"$t/elsewhere\" && policy thing \"$t/repo\") | paste -sd, -)\" = WORKTREE ]"

# --- which configuration says what tenant this is -------------------------------------------------
# `--local`, because the whole argument for reading this out of git configuration is that
# `.git/config` is not in the tree and does not travel, so nothing arriving over the network can set
# it. A bare `--get` resolves system and global too, which handed one line in a user's `~/.gitconfig`
# an identity allowlist for every repository on the machine — including repositories carrying no
# `.protocol/` at all, which had opted into nothing.
printf '[principia]\n\ttenant = %s\n' "$t/elsewhere" >"$t/gitconfig-global"
layers - -
check "git itself does read that global file, which is what the next check needs to mean anything" \
  "[ \"\$( (cd \"$t/repo\" && GIT_CONFIG_GLOBAL=\"$t/gitconfig-global\" git config --get principia.tenant) )\" = \"$t/elsewhere\" ]"
check "a tenant set in global configuration is not this repository's tenant" \
  "! (cd \"$t/repo\" && GIT_CONFIG_GLOBAL=\"$t/gitconfig-global\" tenant_root >/dev/null)"
git -C "$t/repo" config principia.tenant "$t/elsewhere"
check "and the same value set locally still is, so it is the scope and not the reading" \
  "[ \"\$( (cd \"$t/repo\" && tenant_root) )\" = \"$t/elsewhere\" ]"

# --- the refusals, across all four guards ---------------------------------------------------------
# One loop rather than four assertions, because each claim below is about the class. The pair for
# these is `guards/absent-policy.test.sh`, which holds the other half: a repository that declares
# no policy is not policed, and reports clean.
guard_run() { # guard, then its arguments -> status, and whether it said anything
  local g=$1 dir=$2 out rc
  shift 2
  out="$( (cd "$dir" && bash "$DIR/$g-guard.sh" "$@") 2>&1 )"; rc=$?
  printf '%s\n' "$rc${out:+ spoke}"
}

# doctrine/tenancy.md's section is headed "A control that cannot tell whether it applies refuses".
# `size-guard` and `credentials-guard` did, reaching `require_index`; `tenant-guard` and
# `identity-guard` exited 0 in silence, having read outcome 1 from `policy` and stood down.
for g in credentials identity size tenant; do
  check "$g-guard refuses, and says so, where git cannot say what repository it is in" \
    "[ \"\$(guard_run $g \"$t\")\" = \"1 spoke\" ]"
done

# An option a guard does not know used to fall through to the staged check, which in a tree with
# nothing staged is a green run that examined no part of the repository — so a mistyped audit step
# in continuous integration passed, and the typo was the only evidence it had ever existed. Status 2
# rather than 1, so a caller can tell a guard refusing a commit from one refusing the question.
for g in credentials identity size tenant; do
  check "$g-guard refuses a near-miss of an option name instead of checking the staged set" \
    "[ \"\$(guard_run $g \"$t/repo\" --scan-tre)\" = \"2 spoke\" ]"
done

# --- the header's own table of which guard makes which refusal ------------------------------------
# `policy.sh`'s header states, per shared refusal, which guards make it. The claim it replaced was
# wrong in both directions at once — it said two of them were made by every guard, and the audit
# that corrected it first got `compiles` wrong the other way by counting a mention in a COMMENT as a
# call. So the table is derived rather than trusted: doctrine/as-built.md:50 applied to the sentence
# that broke it. A guard added, or a helper dropped from one, goes red here instead of leaving the
# header to read as coverage.
#
# What `callers` measures is a textual probe over each guard's non-comment lines, not a call graph:
# a name under `#` does not count, which is the distinction the first correction missed, and a name
# inside a string would count, which is the probe's own limit. That is enough for the claim being
# held — the header names guards, and a guard that mentions a helper outside a comment and does not
# call it is a defect of its own — and it is said here so the checks below are not read as more.
callers() { # helper -> the guards naming it outside a comment, alphabetical, comma-separated
  local helper=$1 guard out=''
  for guard in "$DIR"/*-guard.sh; do
    grep -v '^[[:space:]]*#' "$guard" | grep -q "\\b$helper\\b" &&
      out="${out:+$out,}$(basename "$guard" -guard.sh)"
  done
  printf '%s' "$out"
}
check "at_root is made by every guard, as the header says" \
  "[ \"\$(callers at_root)\" = credentials,identity,size,tenant ]"
check "and so is refuse_option, the other one the header calls all four" \
  "[ \"\$(callers refuse_option)\" = credentials,identity,size,tenant ]"
check "require_index is made by three, not by identity-guard, which reads no index" \
  "[ \"\$(callers require_index)\" = credentials,size,tenant ]"
check "refuse_unreadable is made by the two guards that read a policy through policy()" \
  "[ \"\$(callers refuse_unreadable)\" = identity,tenant ]"
# Also the control for the comment-stripping above. `credentials-guard.sh` calls `compiles` nowhere,
# and the word appears in it once, in a comment, as English — *"the pattern never compiles"* — so a
# `grep -ln` over whole files reports it as a caller. That is exactly how the correction to this
# header went wrong the first time, and it is the reason the probe strips comments rather than
# trusting a count a person took.
check "compiles is made by those same two, whose patterns come out of a policy file" \
  "[ \"\$(callers compiles)\" = identity,tenant ]"
check "and a helper no guard calls comes back empty, so the probe can answer no" \
  "[ -z \"\$(callers policy_strip)\" ]"

finish
