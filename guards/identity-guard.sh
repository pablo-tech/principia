#!/usr/bin/env bash
# Refuse to COMMIT as an identity this repository does not claim.
#
# Which name and address a commit is made as is machine configuration, not repository
# configuration. A fresh clone carries none of its own, so it is committed to by whoever the
# machine was set up as — and git says nothing about it. The header is written, it is permanent,
# and it is found, if it is found at all, by someone reading `git log` long afterwards. It is also
# the one part of a commit that names a person rather than the work, which is what makes it the
# part that must not travel from one tenant into another's history.
#
# `.protocol/identity` lists the identities this repository's commits may be made as — extended
# regular expressions, one per line — matched case-insensitively against `Name <email>`, for the
# author and for the committer. A repository carrying no such file falls back to the list of the
# tenant it is worked on under, if local git configuration names one (`principia.tenant`, see
# policy.sh) — because a repository worked on under a tenant is deliberately not a tenant and so has
# no `.protocol/` of its own to state this in. A repository that carries the file is judged by it
# alone, empty or not: carrying it is how a repository opts in, and an empty one claims nobody —
# which refuses every identity, because claiming nobody is an answer and not the absence of one.
# Nothing installs this file; a repository that has not opted in does not have it.
#
#   --scan-history [<range>]   apply the rules to the commits in <range> (default: HEAD) instead of
#                              to the commit being made, so a header that reached the branch past
#                              the hook is found on the next run rather than never.
#
# Bypass, if you genuinely mean it: git commit --no-verify

set -uo pipefail
# shellcheck source-path=SCRIPTDIR source=policy.sh
. "$(dirname "${BASH_SOURCE[0]}")/policy.sh"

# An option this guard does not know is a refusal rather than a mode, and `at_root` is what makes
# the guard judge a repository rather than whatever directory it was invoked from. Both are in
# `policy.sh`, beside the argument for them.
#
# `--scan-history` takes an optional range, so the pattern is the option and then anything; a
# mistyped one used to fall through to the staged branch, where it ran the commit check instead of
# the audit and reported it under the audit's own headline.
case "${1:-}" in
  "" | --scan-history) ;;
  *) refuse_option identity-guard "$1" "--scan-history [<range>]" ;;
esac
at_root identity-guard

# Whose list this is, which the report below has to say: being refused by a file that is not in the
# repository you are committing to is otherwise unreadable.
#
# Three answers rather than two, which is why this reads `policy`'s exit status and not whether the
# list came back empty. A file ABSENT in both layers, and in the tenant's if there is one, is a
# repository that never opted in: which identity a commit is made as is then a question about this
# machine, and there is nothing here to enforce. A file PRESENT and naming nobody is the repository
# answering that question with "nobody", which refuses every identity there is. The two are the same
# picture to a test for a non-empty list and they mean opposite things, which is the whole of why
# the file is not seeded into a tenant that has not decided.
#
# A fourth answer sits underneath those three and is the one that was missing: a policy file this
# guard could not READ. That is `policy`'s outcome 2, and it took the `exit 0` arm below along with
# "never opted in" — so a repository whose identity list was present and unreadable was approved in
# silence, by the guard whose own file says a control that cannot tell whether it applies refuses.
whose="this repository"
where=".protocol/identity"
allowed="$(policy identity)"
case "$?" in
  0) ;;
  2) POLICY_UNREADABLE="$allowed"; refuse_unreadable identity-guard ;;
  *)
    if tenant="$(tenant_root)"; then
      allowed="$(policy identity "$tenant")"
      case "$?" in
        0) whose="this repository's tenant"; where="$tenant/.protocol/identity" ;;
        2) POLICY_UNREADABLE="$allowed"; refuse_unreadable identity-guard ;;
        *) exit 0 ;;
      esac
    else
      exit 0
    fi
    ;;
esac

# An empty list refuses, and says so in its own words rather than through the refusal below: that one
# reports an identity the list does not carry, and here the list carries nothing, so the two are
# fixed by opposite edits. Both remedies are real ones and which is right is the repository's to say.
if [ -z "$allowed" ]; then
  echo "pre-commit: refusing to commit: $where names no identity at all."
  echo "pre-commit: Carrying that file is how a repository opts into this rule, so a list with no"
  echo "pre-commit: lines in it is $whose saying its commits are made as nobody — which is every"
  echo "pre-commit: identity refused, and a different state from never having opted in. Either:"
  echo "pre-commit:"
  echo "pre-commit:   name the identities those commits are made as, one extended regular"
  echo "pre-commit:   expression per line, in $where"
  echo "pre-commit:"
  if [ "$whose" = "this repository" ]; then
    echo "pre-commit:   or delete $where, and which identity a commit is made as goes back to being"
    echo "pre-commit:   a question about this machine — where it was before the file arrived."
  else
    echo "pre-commit:   or give this repository its own .protocol/identity, and it is judged by that"
    echo "pre-commit:   and by nothing else."
  fi
  echo "pre-commit: (bypass: git commit --no-verify)"
  exit 1
fi
PATTERN="$(printf '%s' "$allowed" | paste -sd'|' -)"

# The same construct as tenant-guard's, and it fails the other way: `grep` exits 2 on a pattern it
# cannot compile, `claimed` reads that as "not claimed", and every identity is refused. That is
# fail-closed and so the right direction — but the refusal it produces says the identity is not on
# the list, when the list is what is broken, and the two are fixed by opposite edits. Named here
# instead.
if ! compiles "$PATTERN"; then
  echo "pre-commit: refusing to commit: $where does not compile as a regular expression."
  echo "pre-commit: These lines are what grep would not take:"
  while IFS= read -r term; do
    compiles "$term" || echo "pre-commit:   $term"
  done <<<"$allowed"
  echo "pre-commit:"
  echo "pre-commit: Until it compiles, every identity is refused — which is the safe direction and"
  echo "pre-commit: not the one to read as a verdict about who you are. Each line is an extended"
  echo "pre-commit: regular expression: a literal parenthesis, brace or bracket in a name is escaped."
  echo "pre-commit: (bypass: git commit --no-verify)"
  exit 1
fi

claimed() { grep -qiE -- "$PATTERN" <<<"$1"; }

# `git var` answers with what this commit would actually be made as — the configuration git will
# read, and the GIT_AUTHOR_* environment that overrides it, resolved the same way the commit will
# resolve it. Anything this guard derived itself would be a second implementation of that lookup,
# and would disagree with it on the day the difference mattered.
#
# The answer is `Name <email> 1790800093 -0700`; the trailing timestamp is the machine's clock
# rather than part of who this is, and `% * *` takes the shortest such tail, so a name with spaces
# in it survives.
ident() { local raw; raw="$(git var "$1" 2>/dev/null)" || return 1; printf '%s' "${raw% * *}"; }

# refuse_ident <git var>: what `ident` could not answer, reported by this guard in its own words.
#
# It is out here rather than inside `ident` because `ident`'s callers read it through a command
# substitution, and an `exit` inside one ends the subshell and nothing else: the refusal would be
# captured into the variable the guard goes on to test, and the status would arrive with nothing
# printed. Which is what the bare `|| exit 1` did. The refusal's entire output was git's OWN
# "Author identity unknown" advice, so the operator configured a name and an address and never
# learned that a guard had spoken — not which one, not that an allowlist exists, and not that the
# commit would be judged against it once the configuration was there. A refusal is also a report,
# and a report nobody can attribute is what ARCHITECTURE.md's bypass-line claim is about.
#
# git's own stderr is suppressed rather than kept alongside, for the same reason: it arrives first
# and reads as the whole story, and everything it would have said is said below.
refuse_ident() { # the git var that could not be answered
  echo "pre-commit: identity-guard: git cannot say what $1 this commit would be made as, so no"
  echo "pre-commit: rule was applied. Refusing rather than reporting clean a commit nothing"
  echo "pre-commit: examined."
  echo "pre-commit:"
  echo "pre-commit: git declines this when no name and address are configured anywhere it reads,"
  echo "pre-commit: which is a different answer from an identity $whose does not claim: that one is"
  echo "pre-commit: repaired in $where and this one is repaired here."
  echo "pre-commit:"
  echo "pre-commit:   git config user.name  \"<name>\""
  echo "pre-commit:   git config user.email \"<email>\""
  echo "pre-commit:"
  echo "pre-commit: Once git can answer, the identity is judged against $where as it always was."
  echo "pre-commit: (bypass: git commit --no-verify)"
  exit 1
}

offenders=""
if [ "${1:-}" = "--scan-history" ]; then
  headline="commits made as an identity $whose does not claim:"
  range="${2:-HEAD}"
  history="$(git log --format='%h%x09%an <%ae>%x09%cn <%ce>' "${range}" --)" || {
    echo "pre-commit: identity-guard: no history to read at '${range}'" >&2; exit 1; }
  while IFS=$'\t' read -r sha author committer; do
    [ -n "$sha" ] || continue
    claimed "$author" || offenders="$offenders
$sha  author     $author"
    # One identity for both is the ordinary case, and naming it twice reads as two problems.
    [ "$committer" = "$author" ] || claimed "$committer" || offenders="$offenders
$sha  committer  $committer"
  done <<<"$history"
else
  headline="refusing to commit as an identity $whose does not claim:"
  author="$(ident GIT_AUTHOR_IDENT)" || refuse_ident GIT_AUTHOR_IDENT
  committer="$(ident GIT_COMMITTER_IDENT)" || refuse_ident GIT_COMMITTER_IDENT
  claimed "$author" || offenders="$offenders
author     $author"
  [ "$committer" = "$author" ] || claimed "$committer" || offenders="$offenders
committer  $committer"
fi

if [ -n "$offenders" ]; then
  echo "pre-commit: $headline"
  printf '%s\n' "$offenders" | sed '/^$/d;s/^/pre-commit:   /'
  echo "pre-commit:"
  echo "pre-commit: $where lists the identities $whose claims its commits are made as."
  if [ "$whose" != "this repository" ]; then
    echo "pre-commit: This repository carries no such list of its own, so it is held to that"
    echo "pre-commit: one for as long as this clone is wired to that tenant."
  fi
  echo "pre-commit: An identity is configured per machine and a fresh clone carries none of this"
  echo "pre-commit: repository's own, so what is above is whoever that machine was set up as, which"
  echo "pre-commit: is a different question. Answer this one here:"
  echo "pre-commit:"
  echo "pre-commit:   git config user.name  \"<name>\""
  echo "pre-commit:   git config user.email \"<email>\""
  echo "pre-commit:"
  if [ "$whose" = "this repository" ]; then
    echo "pre-commit: If the identity above is genuinely this repository's, the list is the bug."
  else
    echo "pre-commit: If the identity above is genuinely this repository's, it is not that tenant's"
    echo "pre-commit: to claim: give this repository its own .protocol/identity and it is judged by"
    echo "pre-commit: that and by nothing else."
  fi
  echo "pre-commit: (bypass: git commit --no-verify)"
  exit 1
fi
