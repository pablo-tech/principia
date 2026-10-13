# shellcheck shell=bash
# The per-repo policy files under `.protocol/`, and the refusals more than one guard makes.
#
# Two guards read a policy through this file — `tenant-guard` and `identity-guard`. `size-guard`
# reads none at all, and `credentials-guard` reads its two allow-lists through its own `exemptions`,
# for the reason given there. So `policy` below is the shape of a policy read and not the read every
# guard performs, which is the opposite of what this header used to say.
#
# A repository whose policy file is absent has not opted into that rule and is not policed by it.
# That is what makes one shared guard chain safe to point at any checkout: a repository opts in by
# carrying the file that configures it, rather than by being recognised by name from inside a guard.
# **What absence MEANS is not uniform across the guards, and nothing here should imply it is.** An
# absent `credentials-allow-*` is an empty ALLOW-list and so that guard's strictest setting, and an
# `identity` file present and naming nobody refuses every identity where an absent one stands down.
# Each guard states its own answer at the top of its own file; ARCHITECTURE.md §3 sets them side by
# side, and `guards/absent-policy.test.sh` is what holds all four to it.
#
# The refusals below are here rather than written out per guard so that one sentence has one home.
# Which guard makes which is **not** uniform, and this file used to claim two of them were made by
# every guard. Measured, which is also what `policy.test.sh` now derives rather than trusting:
#
#   at_root, refuse_option   all four
#   require_index            three — not `identity-guard`, which reads no index
#   refuse_unreadable        two — the two that read a policy through `policy`
#   compiles                 two — `tenant-guard` and `identity-guard`, whose patterns come out of a
#                            policy file. `credentials-guard`'s patterns are literals in its own
#                            source, and `size-guard` matches nothing at all
#
# `size-guard.sh:15-16` says the same thing about `require_index` from the other side.

# policy <name> [<root>]: the policy's content lines, and one of three statuses.
#
#   0  a policy was read.
#   1  no such policy — neither layer exists. That is a repository which has not opted into this
#      rule, and is the answer a guard exits 0 on, because carrying the file is how a repository
#      opts in.
#   2  a policy could not be READ, which is not the same answer and is the one that refuses.
#      doctrine/tenancy.md: absence is a decision somebody took, while an input the control could
#      not read is the control failing while looking like it worked — and from outside the two are
#      indistinguishable, so the second one has to say so. `$POLICY_UNREADABLE` carries what it
#      could not read, because a refusal whose remedy cannot be derived from it leaves the operator
#      the one remedy always available, which is to bypass the chain.
#
# Two layers, read in order and concatenated: the tracked `.protocol/<name>`, then an untracked
# `.protocol/<name>.local`. Either may be absent; only both being absent is status 1.
#
# The overlay exists because a policy file in a repository anyone can read cannot state what it
# protects against — the list would be the disclosure it was written to prevent. So the tracked file
# carries the shapes and the categories, which are safe to publish, and the overlay carries the
# proper nouns, which are not. The overlay is gitignored, so the names stay on the machine that
# needs them and never reach history.
#
# **The two layers are read from different places, and the asymmetry is the whole of it.** The
# tracked layer comes from the INDEX, because the policy that judges a commit has to be the policy
# that is IN it: read from disk, a single unstaged edit to the denylist disarms the guard completely
# and leaves nothing in the diff for a reviewer to see — the file on disk says one thing, the file
# the commit records says another, and the guard believed the one nobody is committing.
# `credentials-guard.sh` has read its own two lists from the index for exactly this reason, and
# ARCHITECTURE.md §4 claims it for the class; this is the rest of the class.
#
# The overlay is read from disk because it cannot be in the index by construction. It is gitignored,
# and that is what it is for, so there is no staged copy to prefer. A tracked-layer file that is not
# in the index at all is read from disk too, for the same reason narrowed: the worktree copy is then
# the only copy there is, which is not a failure to read. Both are therefore editable without a
# diff, and both are untracked — which is the one property that makes it safe, since a file nothing
# tracks cannot be what a reviewer thought they were reviewing.
#
# <root> is the committing repository unless a guard names another. Only `tenant_root` below answers
# with another, and only one guard asks it to — and a named root is read from disk in both layers,
# because nothing is being committed there and it need not be a git repository at all.
#
# Whole-line comments only: a policy line is a path or a regex and may legitimately contain `#`.

# What outcome 2 could not read, for `refuse_unreadable` to name.
#
# **It travels on stdout as well, and that is not redundancy.** Every caller reads a policy through
# `terms="$(policy tenant)"`, and a command substitution is a subshell — so a variable this function
# sets is set in a shell that has already exited by the time the caller tests the status. The reason
# would be lost in exactly the case it exists for. So outcome 2 writes the reason where the content
# would have gone, which is safe because the two never coexist: a policy that could not be read has
# no content to carry. A caller assigns it back (`POLICY_UNREADABLE="$terms"`) before refusing, and
# this variable is for the callers that are NOT in a subshell, `at_root` below being the one.
#
# That is also why the layers are buffered rather than streamed. Emitted layer by layer, the first
# layer's content would already be on stdout when the second one failed, and the caller would
# capture the two spliced together with no way to tell which it had.
POLICY_UNREADABLE=''

policy_strip() { sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' -e 's/[[:space:]]*$//'; }

# unreadable <reason>: outcome 2, both ways at once.
unreadable() {
  POLICY_UNREADABLE="$1"
  printf '%s' "$1"
  return 2
}

policy() {
  local root=${2:-} named=${2:+y} found=1 file out='' got
  POLICY_UNREADABLE=''
  if [ -z "$root" ]; then
    # Empty rather than non-zero is its own case: `git rev-parse` answers with nothing and succeeds
    # inside a bare repository and inside `.git` itself, and an unset root would make every path
    # below resolve against `/`.
    root="$(git rev-parse --show-toplevel 2>/dev/null)"
    [ -n "$root" ] ||
      unreadable "git cannot say where this repository's root is, so .protocol/$1 was never looked for" ||
      return 2
  fi

  # The tracked layer, from the index wherever the index has it.
  file="$root/.protocol/$1"
  if [ -z "$named" ] && git -C "$root" ls-files --cached --error-unmatch -- ".protocol/$1" >/dev/null 2>&1; then
    # A blob git declines to answer about is the case doctrine/tenancy.md names beside the
    # uncompilable pattern and the index it cannot read: a conflicted index has no stage 0 to read,
    # and a corrupt object store answers for neither. Both arrive here as a failed `git show`,
    # whose status is what the inner `exit` carries out of the pipeline.
    got="$(git -C "$root" show ":.protocol/$1" 2>/dev/null | policy_strip; exit "${PIPESTATUS[0]}")" ||
      { unreadable ".protocol/$1 is in the index of $root and git could not read it there"; return 2; }
    out="$got"
    found=0
  elif [ -f "$file" ]; then
    got="$( { policy_strip <"$file"; } 2>/dev/null )" ||
      { unreadable "$file is present and could not be read"; return 2; }
    out="$got"
    found=0
  fi

  # The overlay, always from disk.
  file="$root/.protocol/$1.local"
  if [ -f "$file" ]; then
    got="$( { policy_strip <"$file"; } 2>/dev/null )" ||
      { unreadable "$file is present and could not be read"; return 2; }
    [ -z "$got" ] || out="${out:+$out$'\n'}$got"
    found=0
  fi

  [ -z "$out" ] || printf '%s\n' "$out"
  return "$found"
}

# refuse_unreadable <guard>: the refusal for policy outcome 2, naming what could not be read.
#
# `require_index`'s shape, and for the same reason one level up: it names the input, says that no
# rule was applied, and does not state the conclusion the rule would have reached had it run. The
# two answers are repaired by opposite edits — a policy nothing can read is fixed in the policy, and
# a commit the policy refuses is fixed in the commit — so a refusal that conflated them would send
# the operator to the wrong file.
refuse_unreadable() { # guard name, for the refusal
  echo "pre-commit: $1: ${POLICY_UNREADABLE:-a policy could not be read}, so no rule was applied."
  echo "pre-commit: Refusing rather than reporting clean a commit nothing examined."
  echo "pre-commit:"
  echo "pre-commit: A repository carrying no policy file has not opted into this rule and is not"
  echo "pre-commit: policed, which is a decision and reports clean. This is the other answer: an"
  echo "pre-commit: input this guard needed and could not read. Repair the one named above."
  echo "pre-commit: (bypass: git commit --no-verify)"
  exit 1
}

# refuse_option <guard> <option> <accepted...>: an unrecognised option is a refusal, not a mode.
#
# Each guard used to test for its one audit flag and treat everything else as "no flag", so a
# mistyped `--scan-tree` ran the staged check instead — which in a repository with nothing staged
# exits 0 and prints nothing. A continuous-integration step asserting an audit therefore passed
# green having audited nothing, and the typo is the only evidence it ever existed.
#
# Status 2 rather than 1, so that a caller can tell a guard refusing a commit from a guard refusing
# the question. Either way the commit does not proceed.
refuse_option() { # guard name, the option, then the options it does accept
  local guard=$1 opt=$2
  shift 2
  echo "pre-commit: $guard: unrecognised option '$opt', so no rule was applied."
  echo "pre-commit: Refusing rather than reporting clean a run that audited nothing. An option this"
  echo "pre-commit: guard does not know used to fall through to the staged check, which in a tree"
  echo "pre-commit: with nothing staged is a green run that examined no part of the repository."
  echo "pre-commit:"
  if [ "$#" -gt 0 ]; then
    echo "pre-commit: Accepted here: $*, or no option at all for the commit being made."
  else
    echo "pre-commit: This guard has no modes. It judges the commit being made and takes no option,"
    echo "pre-commit: so there is no spelling of the above that would have audited anything."
  fi
  exit 2
}

# at_root <guard>: run from the repository's root, whatever directory the guard was invoked from.
#
# Every list git hands a guard is relative to the current directory — `git ls-files`,
# `git diff --cached --name-only` — while every pattern a guard matches against is anchored at the
# root: a `credentials-allow-*` glob, the `.protocol/` path the tenancy guard exempts from its own
# denylist. Invoked from a subdirectory the two stop describing the same string, and it fails in
# both directions at once. `--scan-tree` sees only the subtree, so it reports clean on a tree whose
# offending file sits above the directory it was run from; and an exempt path arrives as a basename
# that its own allowlist entry no longer matches, so the guard refuses the very files the repository
# declared fine.
#
# Neither is reachable through the pre-commit hook, because git runs a hook from the root. Both are
# reachable through the `--scan-*` audits, which are run by hand and by continuous integration —
# which is to say, reachable exactly where the result is read as an assertion about the whole tree.
#
# Resolved here rather than threaded through each `git` call, because it is the same fact every one
# of them needs and the ones that were missed are the ones nobody thought of.
at_root() { # guard name, for the refusal
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null)"
  if [ -z "$root" ]; then
    POLICY_UNREADABLE="git cannot say where this repository's root is"
    refuse_unreadable "$1"
  fi
  cd "$root" || { POLICY_UNREADABLE="the repository root $root could not be entered"; refuse_unreadable "$1"; }
}

# compiles <extended regular expression>: false only if `grep -E` cannot compile it.
#
# `grep` exits 2 on a pattern it cannot compile and 1 on "no match", and a caller written as
# `grep -qE -- "$PATTERN" || return 1` cannot tell those apart — so one unbalanced parenthesis in a
# hand-maintained policy file makes every file read clean and disarms the guard completely, in the
# pre-commit hook and in whatever sweep CI runs. Nothing announces it: the terms that ARE in the list
# stop being found too. So the pattern is compiled once, before anything is read, against input
# nothing can match — `grep` still parses the pattern on empty input, which is what makes the probe
# free.
compiles() {
  local rc=0
  grep -qE -- "$1" </dev/null 2>/dev/null || rc=$?
  [ "$rc" -le 1 ]
}

# require_index <guard>: refuse, naming the guard, if git cannot say what is staged.
#
# An index git declines to answer about reads as an empty result, which is indistinguishable from a
# commit with nothing staged — so every loop below finds nothing and the guard reports the commit
# clean. That is the lost signal rather than a missed one: no rule ran, and nothing anywhere says so.
#
# `git ls-files -s` reads the same index `git diff --cached` does, exits 0 on an empty one and needs
# no HEAD, so it answers for a repository's first commit as well as its thousandth. It is a probe
# rather than the exit status of the process substitution each guard reads from, because bash does
# not expose that one.
require_index() { # guard name, for the refusal
  git ls-files -s >/dev/null 2>&1 && return 0
  echo "pre-commit: $1: git cannot report what is staged, so no rule was applied."
  echo "pre-commit: Refusing rather than reporting clean a commit nothing examined."
  echo "pre-commit: (bypass: git commit --no-verify)"
  exit 1
}

# tenant_root: the tenant this repository is worked on under, if something wired it to one.
#
# A repository worked on under a tenant is deliberately not a tenant — it is given the guard chain
# and nothing else, so that nothing of the tenant's is in its tree for its own contributors and its
# own CI to inherit. That leaves it with nowhere to say which tenant it is worked on under, and
# nowhere it should have to: which tenant a checkout is worked on under is a fact about this
# machine, true of one clone of it and false of the next.
#
# So it is recorded where `core.hooksPath` is, in local git configuration, by whatever wired the
# repository. Local configuration is also what makes it safe for a guard to read. `.git/config` is
# not in the tree and does not travel, so nothing arriving over the network can set this and point a
# guard at a directory of its own choosing.
#
# `--local` is what makes that last paragraph true, and it was `--get` alone, which resolves system
# and global configuration as well. One line in `~/.gitconfig` therefore supplied an identity
# allowlist to every repository on the machine — including repositories carrying no `.protocol/` at
# all, which had opted into nothing — and the guard read its list from a path of configuration's
# choosing, which is the one thing the locality argument above says cannot happen.
#
# `principia` rather than `protocol`, which is git's own configuration section: a bare
# `protocol.tenant` collides with nothing git reads today, and squatting a reserved section is the
# kind of thing that is discovered years later by the version that starts reading it.
tenant_root() {
  local dir
  dir="$(git config --local --get principia.tenant 2>/dev/null)" || return 1
  [ -n "$dir" ] && [ -d "$dir/.protocol" ] || return 1
  printf '%s' "$dir"
}
