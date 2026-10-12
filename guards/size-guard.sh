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

MAX_MB="${PROTOCOL_MAX_FILE_MB:-25}"
MAX_BYTES=$((MAX_MB * 1024 * 1024))

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
