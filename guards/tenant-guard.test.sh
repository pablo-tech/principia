#!/usr/bin/env bash
# tenant-guard.sh against the index of a scratch repository carrying a .protocol/tenant denylist.
#   bash guards/tenant-guard.test.sh
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
# shellcheck disable=SC1091
source "$DIR/../bin/check.sh"

# tenant <denylist-lines>: a fresh repository that declares those terms as OTHER tenants'.
tenant() {
  scratch_repo "$t/repo" >/dev/null
  mkdir -p "$t/repo/.protocol" && printf '%s\n' "$1" >"$t/repo/.protocol/tenant"
  git -C "$t/repo" add -A
}
# stage path content
stage() { mkdir -p "$t/repo/$(dirname "$1")" && printf '%s\n' "$2" >"$t/repo/$1" && git -C "$t/repo" add -A; }
guard() { (cd "$t/repo" && bash "$DIR/tenant-guard.sh" >/dev/null 2>&1); }
scan() { (cd "$t/repo" && bash "$DIR/tenant-guard.sh" --scan-tree >/dev/null 2>&1); }

scratch_repo "$t/repo" >/dev/null
stage notes.md "anything at all"
check "a repo that declares no tenant policy is not policed" "guard"

tenant 'Initech'
stage notes.md "the deploy is green"
check "a commit naming no other tenant passes" "guard"

tenant 'Initech'
stage notes.md "met with Initech about the migration"
check "a commit naming another tenant in its content is refused" "! guard"

tenant 'Initech'
stage notes.md "met with initech about the migration"
check "the match ignores case" "! guard"

tenant 'Initech'
stage "initech/plan.md" "nothing sensitive here"
check "a path naming another tenant is refused even when the content is clean" "! guard"

tenant 'Initech
Acme Corp'
stage notes.md "quarterly review at Acme Corp"
check "any one line of the denylist is enough" "! guard"

tenant 'Acme-[0-9]+'
stage notes.md "carried over from Acme-42"
check "a denylist line is an extended regex, not a literal" "! guard"

tenant '# only a comment

Initech'
stage notes.md "the deploy is green"
check "comments and blank lines in the denylist match nothing" "guard"

tenant 'Initech'
check "the denylist naming the terms is not itself an offence" "guard"

tenant 'Initech'
stage notes.md "the deploy is green"
git -C "$t/repo" commit -qm x --no-verify
printf 'Initech\n' >"$t/repo/notes.md"
check "--scan-tree reads the working tree, not the staged set" "! scan"

# The denylist has an untracked second layer, `.protocol/tenant.local`, for the terms a repository
# cannot afford to publish in the file itself. The guard does not know it is there — `policy tenant`
# hands back both layers as one list — and that is the point: the names bind commits without being
# committed.
tenant '# nothing tracked here names anybody'
printf '/.protocol/*.local\n' >"$t/repo/.gitignore"
printf 'Initech\n' >"$t/repo/.protocol/tenant.local"
stage notes.md "met with Initech about the migration"
check "a term carried only by the untracked overlay is still refused" "! guard"

stage notes.md "the deploy is green"
check "and the overlay itself is never staged, so nothing scans it" \
  "guard && [ -z \"\$(git -C '$t/repo' diff --cached --name-only | grep 'tenant\\.local')\" ]"

# A control that cannot determine whether it applies refuses — doctrine/tenancy.md. Each check below
# was seen passing against the guard as it stood, which is what made it a defect rather than a
# worry: the guard reported every file clean and exited 0.

tenant 'Acme(Corp'
stage notes.md "met with Initech about the migration"
check "a denylist that does not compile refuses instead of finding nothing" "! guard"

tenant 'Acme(Corp'
# `grep -F` rather than `grep -qF`: the suite runs under `pipefail`, and `-q` closes the pipe on the
# first match, which makes the guard upstream of it exit non-zero. That is the trap tenant-guard.sh's
# own comment at `first_match` is about, met here.
check "and the refusal names the line grep would not take" \
  "[ -n \"\$( (cd '$t/repo' && bash '$DIR/tenant-guard.sh' 2>&1) | grep -F 'Acme(Corp' )\" ]"

tenant 'Initech'
stage notes.md "the deploy is green"
git -C "$t/repo" commit -qm x
git -C "$t/repo" mv notes.md initech-plan.md
check "a path renamed into a term is refused, not skipped as a rename" "! guard"

tenant 'Initech'
stage "café/initech.md" "nothing sensitive here"
check "a path git C-quotes is still judged by the path rule" "! guard"

tenant 'Initech'
stage "café/notes.md" "met with Initech about the migration"
check "and by the content rule" "! guard"

tenant 'Initech'
stage notes.md "the deploy is green"
ln -sfn /nonexistent/target "$t/repo/initech-link.md"
git -C "$t/repo" add -A
git -C "$t/repo" commit -qm x
check "--scan-tree judges a tracked symlink rather than skipping it" "! scan"

tenant 'Initech'
stage notes.md "met with Initech about the migration"
check "an index git cannot read refuses rather than reading as nothing staged" \
  "! (cd '$t/repo' && printf x > .git/bad-index && GIT_INDEX_FILE=.git/bad-index bash '$DIR/tenant-guard.sh' >/dev/null 2>&1)"

# `--scan-tree` is an audit of the repository, and a repository is not the directory the command was
# typed in. `git ls-files` is cwd-relative, so run from `sub/` the audit walked `sub/` alone and
# reported clean on a tree naming another tenant at its root — an audit mode that looks armed and is
# scoped to whichever subtree happened to be the working directory. `CONTRIBUTING.md:62` and
# `.github/PULL_REQUEST_TEMPLATE.md:22` hand this command to a person, who runs it from wherever
# they are. The root-run check below is the control: same tree, same file, same verdict required.
tenant 'Initech'
stage notes.md "met with Initech about the migration"
stage sub/clean.md "the deploy is green"
check "--scan-tree run from the root refuses a file naming another tenant" "! scan"
check "and run from a subdirectory refuses the same file, rather than auditing that subtree" \
  "! (cd '$t/repo/sub' && bash '$DIR/tenant-guard.sh' --scan-tree >/dev/null 2>&1)"

finish
