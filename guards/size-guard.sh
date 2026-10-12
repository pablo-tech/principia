#!/usr/bin/env bash
# CANONICAL oversized-file guard.
#
# Policy: heavy files live in cloud storage. Repos keep information extracted from them, never the
# files themselves. Threshold below, overridable via PROTOCOL_MAX_FILE_MB.
#
# Why at COMMIT rather than push: GitHub hard-rejects any blob over 100 MiB, and by the time a push
# is refused the blob is already in local history — the branch then stays unpushable until history
# is rewritten, which costs a force-push to every branch that carries it.
#
# Run directly to check the current index:  guards/size-guard.sh
# Emergency bypass (in the calling repo):   git commit --no-verify

set -uo pipefail
# Sourced for `require_index` alone — this guard reads no policy file. The refusal lives there
# because three guards make it and one sentence should have one home.
# shellcheck source-path=SCRIPTDIR source=policy.sh
. "$(dirname "${BASH_SOURCE[0]}")/policy.sh"

DEFAULT_MAX_MB=25
MAX_MB="${PROTOCOL_MAX_FILE_MB:-$DEFAULT_MAX_MB}"
MAX_BYTES=$((MAX_MB * 1024 * 1024))

# A raised ceiling says so, every run, whatever the outcome. The override is documented and it is
# deliberate, but an environment variable leaves no trace in the commit it let through: the blob is
# in history at a size the ceiling refuses and nothing anywhere records that the ceiling was moved.
# A guard that is quieter when it is doing less is the shape this repository refuses, so the one
# line is printed on a pass as well as on a refusal, and a lowered ceiling is reported too — an
# unexpected refusal is read as a bug in the guard until the reader is told why.
if [ "$MAX_MB" != "$DEFAULT_MAX_MB" ]; then
  echo "pre-commit: size-guard: ceiling is ${MAX_MB} MB, not the protocol's ${DEFAULT_MAX_MB} MB" \
       "(PROTOCOL_MAX_FILE_MB)"
fi

require_index size-guard

toobig=""
unreadable=""
# -z so paths containing spaces survive; records carry them.
#
# `--diff-filter=d` excludes deletions and keeps everything else, where `=AM` kept only additions and
# modifications: rename detection is on by default, so `git mv notes.txt big.bin` is reported as `R`
# and reached no guard at all. A deletion is the one status with no staged blob to measure, which is
# why it is the one excluded rather than the rest selected.
while IFS= read -r -d '' path; do
  # A path reported above is in the index, so a failure here is git declining to answer about a blob
  # it just named. It is recorded and refused rather than skipped: `|| continue` would report the
  # commit clean, which is the file this guard exists to catch going through unmeasured.
  sha="$(git rev-parse ":$path" 2>/dev/null)" || { unreadable="$unreadable\n  $path"; continue; }
  # Size of the blob as STAGED, not as on disk: the index is what a commit would record.
  size="$(git cat-file -s "$sha" 2>/dev/null)" || { unreadable="$unreadable\n  $path"; continue; }
  if [ "$size" -gt "$MAX_BYTES" ]; then
    toobig="$toobig\n  $((size / 1048576)) MB  $path"
  fi
done < <(git diff --cached --name-only --diff-filter=d -z)

if [ -n "$unreadable" ]; then
  echo "pre-commit: refusing to commit file(s) whose staged size git would not report:"
  printf "%b\n" "$unreadable"
  echo "pre-commit:   the ceiling could not be applied to them, so nothing here says they are under it."
  echo "pre-commit: (bypass: git commit --no-verify)"
  exit 1
fi

if [ -n "$toobig" ]; then
  echo "pre-commit: refusing to commit file(s) over ${MAX_MB} MB:"
  printf "%b\n" "$toobig"
  echo "pre-commit:   keep only what you extract from the file, not the file."
  echo "pre-commit:   unstage with:  git restore --staged <path>"
  echo "pre-commit:   if it is a build artifact or dependency, gitignore it instead."
  echo "pre-commit: (bypass: git commit --no-verify)"
  exit 1
fi
exit 0
