#!/usr/bin/env bash
# Refuse to COMMIT one tenant's material into another tenant's repository.
#
# One person works for several tenants through the same tools, often on the same machine, in the
# same hour. No AI coding tool can tell which tenant a diff belongs to, and a rule written into one
# tool's config says nothing about a diff produced by another tool, by an editor, or by hand. The
# commit is the one boundary every route passes through.
#
# `.protocol/tenant` lists the terms belonging to the OTHER tenants — as extended regular
# expressions, one per line — and any staged path or staged content matching one is refused. A repo
# without that file declares no tenancy and is not policed.
#
#   --scan-tree   apply the rules to every tracked file on disk instead of the staged set, so an
#                 audit reads the terms from the repo rather than from a doc that then drifts.
#
# Bypass, if you genuinely mean it: git commit --no-verify

set -uo pipefail
# shellcheck source-path=SCRIPTDIR source=policy.sh
. "$(dirname "${BASH_SOURCE[0]}")/policy.sh"

# An option this guard does not know is a refusal rather than a mode, and `at_root` is what makes
# `--scan-tree` an audit of the repository rather than of whatever directory it was invoked from.
# Both are in `policy.sh`, beside the argument for them. They come before the policy read because
# neither depends on one: a mistyped flag is wrong in a repository that declares no tenancy too.
case "${1:-}" in
  "" | --scan-tree) ;;
  *) refuse_option tenant-guard "$1" --scan-tree ;;
esac
at_root tenant-guard

# Three answers, not two. `|| exit 0` stood here, which made "git could not tell me where the root
# is" and "a policy file is present and unreadable" into "this repository declares no tenancy" — and
# the guard then approved a commit it had examined no part of, silently, which is the default
# doctrine/tenancy.md's own section says a control does not get to have.
terms="$(policy tenant)"
case "$?" in
  0) ;;
  1) exit 0 ;;
  *) POLICY_UNREADABLE="$terms"; refuse_unreadable tenant-guard ;;
esac
[ -n "$terms" ] || exit 0
PATTERN="$(printf '%s' "$terms" | paste -sd'|' -)"

# A control that cannot determine whether it applies refuses. The denylist is hand-maintained and
# every line is a regular expression, so one unbalanced parenthesis makes `grep` exit 2 — which
# `first_match`'s `|| return 1` below reads as "no match", and every file then comes back clean
# including the ones naming terms that ARE listed. Nothing announces it. Compiled here, before
# anything is read, so the refusal names the offending line rather than the file it failed on.
if ! compiles "$PATTERN"; then
  echo "pre-commit: refusing to commit: .protocol/tenant does not compile as a regular expression."
  echo "pre-commit: These lines are what grep would not take:"
  while IFS= read -r term; do
    compiles "$term" || echo "pre-commit:   $term"
  done <<<"$terms"
  echo "pre-commit:"
  echo "pre-commit: Until it compiles this guard can police nothing, so it refuses rather than"
  echo "pre-commit: report every file clean. Each line is an extended regular expression —"
  echo "pre-commit: a literal parenthesis, brace or bracket in a term is escaped."
  echo "pre-commit: (bypass: git commit --no-verify)"
  exit 1
fi

# The denylist is the one file that legitimately spells the terms out.
POLICY_PATH=".protocol/tenant"

# Returns the first term that matched, so the refusal names what to look for rather than only where.
# Captures before trimming rather than piping into `head`: under `pipefail` the closed pipe would
# make the pipeline report failure on exactly the file the guard was meant to catch.
#
# The pattern compiled above, so an exit over 1 here is `grep` failing on this particular input
# rather than on the pattern. That is recorded as an offence rather than raised by exiting, because
# the only caller runs inside a command substitution and an `exit` there kills the subshell and
# nothing else — leaving the file unrecorded, which is the failure this is about. An offence names
# the file, which is the same refusal.
UNAPPLIED='<the denylist could not be applied to this file>'
first_match() { # text
  local found rc=0
  found="$(grep -oiE -- "$PATTERN" <<<"$1")" || rc=$?
  [ "$rc" -le 1 ] || { printf '%s' "$UNAPPLIED"; return 0; }
  [ "$rc" = 0 ] || return 1
  printf '%s' "${found%%$'\n'*}"
}

offence() { # path content -> prints the matched term
  [ "$1" = "$POLICY_PATH" ] && return 1
  first_match "$1" && return 0
  first_match "$2"
}

require_index tenant-guard

# Nulls are stripped before the substitution sees them: the tree holds images and fonts, and bash
# warns once per null-carrying file otherwise. A check whose passing run prints warnings is a check
# people stop reading.
#
# Both loops read `-z`. `core.quotePath` defaults on, so a path carrying a byte over 0x7f arrives as
# `"caf\303\251.md"` — a different string from the path, which the path rule is then asked about,
# and not one `git show` resolves, so the content rule read an empty string. One omission, both axes.
offenders=""
if [ "${1:-}" = "--scan-tree" ]; then
  while IFS= read -r -d '' path; do
    # `-f` follows the link and is false for a dangling one, so a tracked symlink was skipped
    # outright — including by the path rule, which needs nothing but the name. The comment that
    # stood here said "Nothing is skipped — the path rule still sees the file", and it did not.
    # `bin/adapt` installs tracked symlinks into every tenant by design, so a tracked tree holding
    # them is the ordinary case here and not an edge of it.
    if [ -L "$path" ]; then
      term="$(offence "$path" "$(git show ":$path" 2>/dev/null | tr -d '\0')")" && offenders="$offenders
$path: $term"
      continue
    fi
    [ -f "$path" ] || continue
    term="$(offence "$path" "$(tr -d '\0' <"$path" 2>/dev/null)")" && offenders="$offenders
$path: $term"
  done < <(git ls-files -z)
else
  # `--diff-filter=d` excludes deletions and keeps everything else, where `=AM` kept only additions
  # and modifications: rename detection is on by default, so `git mv notes.md <term>-plan.md` is
  # reported as `R` and was handed to no guard at all — the staged path rule this guard's own suite
  # asserts, walked past by a rename.
  while IFS= read -r -d '' path; do
    term="$(offence "$path" "$(git show ":$path" 2>/dev/null | tr -d '\0')")" && offenders="$offenders
$path: $term"
  done < <(git diff --cached --name-only --diff-filter=d -z)
fi

if [ -n "$offenders" ]; then
  echo "pre-commit: refusing to commit another tenant's material into this repository:"
  printf '%s\n' "$offenders" | sed '/^$/d;s/^/pre-commit:   /'
  echo "pre-commit:"
  echo "pre-commit: Each term above is listed in .protocol/tenant, which names the tenants this"
  echo "pre-commit: repository is not. Put the material in that tenant's own repository instead."
  echo "pre-commit:"
  echo "pre-commit:   unstage with:  git restore --staged <path>"
  echo "pre-commit:"
  echo "pre-commit: If the term is genuinely this tenant's, the denylist is the bug — narrow it."
  echo "pre-commit: (bypass: git commit --no-verify)"
  exit 1
fi
