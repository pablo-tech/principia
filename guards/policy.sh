# shellcheck shell=bash
# The per-repo policy files every guard reads, all under `.protocol/` at the committing repo's root.
#
# A guard whose policy file is absent has nothing to enforce and exits 0. That is what makes one
# shared guard chain safe to point at any checkout: a repo opts into a rule by carrying the file
# that configures it, rather than by being recognised by name from inside the guard.

# It also carries the two refusals every guard shares, below the policy reader: a control that
# cannot determine whether it applies refuses, which is doctrine/tenancy.md's rule and is why they
# are here rather than written out once per guard.

# policy <name> [<root>]: the file's content lines, or non-zero if that repo carries neither layer.
#
# Two layers, read in order and concatenated: the tracked `.protocol/<name>`, then an untracked
# `.protocol/<name>.local`. Either may be absent; only both being absent is the "no such policy"
# answer a guard exits 0 on.
#
# The overlay exists because a policy file in a repository anyone can read cannot state what it
# protects against — the list would be the disclosure it was written to prevent. So the tracked file
# carries the shapes and the categories, which are safe to publish, and the overlay carries the
# proper nouns, which are not. The overlay is gitignored, so the names stay on the machine that
# needs them and never reach history.
#
# <root> is the committing repository unless a guard names another. Only `tenant_root` below answers
# with another, and only one guard asks it to.
#
# Whole-line comments only: a policy line is a path or a regex and may legitimately contain `#`.
policy() {
  local root=${2:-} file found=1
  [ -n "$root" ] || root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
  for file in "$root/.protocol/$1" "$root/.protocol/$1.local"; do
    [ -f "$file" ] || continue
    found=0
    sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' -e 's/[[:space:]]*$//' "$file"
  done
  return "$found"
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
# `principia` rather than `protocol`, which is git's own configuration section: a bare
# `protocol.tenant` collides with nothing git reads today, and squatting a reserved section is the
# kind of thing that is discovered years later by the version that starts reading it.
tenant_root() {
  local dir
  dir="$(git config --get principia.tenant 2>/dev/null)" || return 1
  [ -n "$dir" ] && [ -d "$dir/.protocol" ] || return 1
  printf '%s' "$dir"
}
