#!/usr/bin/env bash
# Refuse to COMMIT credential material.
#
# Real credentials belong in a repository whose whole job is to hold them, kept separate from the
# one carrying the work — which is what lets a work repository be cloned onto a machine or into an
# environment you do not own. This guard is the backstop against a secret drifting back in.
#
# Two optional policy files, both lists of repo-relative globs, split along the two axes the guard
# judges — what a file is CALLED and what it CONTAINS:
#   .protocol/credentials-allow-name      paths whose name has a credential shape and hold no
#                                         secret: a `.env` of non-secret settings, a public CA
#                                         bundle. Exempt from the shape rule only — still read.
#   .protocol/credentials-allow-content   paths that must contain credential-shaped text: the tests
#                                         that pin these rules, whose fixture has to contain the
#                                         thing it pins. Named one by one, because a blanket
#                                         `*.test.sh` exemption is a file per suite to hide a
#                                         secret in.
# A repository whose job IS to hold credentials lists `*` in both.
#
#   --scan-tree   apply the rules to every tracked file instead of the staged set.
#
# Bypass, if you genuinely mean it: git commit --no-verify

set -uo pipefail
# shellcheck source-path=SCRIPTDIR source=policy.sh
. "$(dirname "${BASH_SOURCE[0]}")/policy.sh"

# `|| true`, and not the `|| exit 0` the other policy-reading guards use, because "no such policy"
# is not a reason to stand down here: both files are ALLOW-lists, so a repository carrying neither
# exempts nothing and this guard then runs at its STRICTEST. Absent is the strict setting and not the
# off switch, which is the one thing about this guard that surprises everybody who reads it.
ALLOWED_NAME="$(policy credentials-allow-name || true)"
ALLOWED_CONTENT="$(policy credentials-allow-content || true)"

listed() { # path list
  local pat
  while IFS= read -r pat; do
    [ -n "$pat" ] || continue
    # shellcheck disable=SC2254
    case "$1" in $pat) return 0 ;; esac
  done <<<"$2"
  return 1
}

# Credential material recognised by file shape: the `.env`, `-sa.json`, `.pem`/`.key`/`.p8`, `.enc`
# and ssh-identity files a secrets split moves out.
credential_path() { # path
  case "$1" in
    *.env|*.pem|*.key|*.p8|*.p12|*.enc|*.dev.vars|*-sa.json|*-sa.*.json) return 0 ;;
    id_rsa|id_ed25519|id_ecdsa|*/id_rsa|*/id_ed25519|*/id_ecdsa) return 0 ;;
  esac
  return 1
}

# Path rules alone cannot hold: they know only the locations a secret was expected to land in, and a
# secret drifts back in by landing somewhere new. A script that captures a live token writes it
# wherever it was run, under whatever name it was given, and a run that failed part way leaves the
# file behind anyway. So content is read for every file, not just the expected ones.
#
# The PEM pattern requires the literal `-----` delimiters, so prose naming `BEGIN OPENSSH PRIVATE
# KEY` in backticks reads as documentation rather than as a leak.
#
# Takes the content as an argument rather than on a pipe: `grep -q` closes the pipe on its first
# match, the SIGPIPE fails the upstream, and under `pipefail` the pipeline then reports failure — so
# the guard would go quiet on exactly the file it was meant to catch.
leaks() { # content
  grep -qE -- '-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|sk-ant-[A-Za-z0-9_-]{20,}|GOCSPX-[A-Za-z0-9_-]{20,}' <<<"$1"
}

# Those shapes only match credentials whose issuer gave them a recognisable prefix, which is a
# minority. A bare assignment is how every one of the rest gets written down — a live value stated
# as `PASSPHRASE=<value>` reads as nothing at all to a shape-only guard, for as long as it stays
# committed.
#
# The rule is about the VALUE, never the name. Naming a credential is how a script declares what it
# needs — `: "${STREAM_TOKEN:?...}"` is correct code — and a guard firing on the name would refuse
# correct code and teach everyone to reach for --no-verify.
ASSIGNED='(^|[^A-Za-z0-9_])([A-Z][A-Z0-9_]*_)?(PASSPHRASE|PASSWORD|SECRET|API_KEY|TOKEN|PSK|PASS)=["'"'"']?[A-Za-z0-9/+._~@-]'
# Values that are obviously not the credential: a masked one reads as documentation, and refusing it
# would push people to delete the variable name too, which is the part worth keeping. A value that
# opens a bracket is a derivation rather than a literal — no credential charset contains `(`.
MASKED='=["'"'"']?([A-Za-z0-9_]+\(|REDACTED|MASKED|CHANGE_?ME|PLACEHOLDER|EXAMPLE|SAMPLE|TODO|FIXME|NONE|NULL|UNSET|YOUR[_-]|X{3,}|\.+([^A-Za-z0-9]|$))'
literal_credential() { # content
  grep -E -- "$ASSIGNED" <<<"$1" | grep -qviE -- "$MASKED"
}

# A wrapped key — a private key or a data-encryption key sealed under another key — defeats every
# shape above, and is the one credential a project encrypting its own data at rest is certain to
# write down. It has no issuer prefix, no `-----BEGIN` delimiters and no `NAME=value` assignment: it
# is a hex blob in a SQL seed or a base64 field in a JSON file, high-entropy end to end and
# indistinguishable from any other opaque identifier. Both rules above read straight past it.
#
# What makes it a credential rather than noise is that the material needed to unwrap it sits beside
# it — the KDF parameters a passphrase is stretched through, or the ephemeral public key an ECDH
# envelope was sealed with. A wrapped key is worth nothing alone, so committing it beside its own
# unwrapping material is what publishes it, and a file carrying the pair is the shape matched here.
#
# Two conditions, and the first of them is a single line rather than the whole file, which is what
# keeps the rule off code that is written correctly: a schema declaring the column
# (`wrapped_private_key BLOB NOT NULL`), a type declaring the field, a call site passing it and a
# document describing the design all name it on a line carrying no literal.
#
# Requiring the name and the value on ONE line is not tidiness, it is the rule working. Asking only
# whether a file contains each of the parts somewhere lets a large file satisfy them from unrelated
# places: a 1.7 MB salvage patch of ordinary source matched on a type declaration, a lockfile hash
# and a KDF default three thousand lines apart, with no credential in it anywhere. A seeded
# credential does not look like that — it is written as one `INSERT` row or one JSON member, so the
# name and the value sit together, and that is the shape to ask for.
#
# Like the two rules above it judges the VALUE and never the name, for the same reason: naming a
# wrapped key is how a schema and a call site declare themselves, and a guard firing on the name
# would refuse the correct version of the code and teach everyone to reach for --no-verify.
WRAPPED_FIELD='wrapped[_-]?(private[_-]?key|dek|key)'
# 64 characters sits far above an identifier or a placeholder and far below any real wrapped key:
# the smallest is 32 bytes of ciphertext plus a 16-byte GCM tag, which is 96 hex characters.
WRAPPED_VALUE="[Xx]'[0-9a-fA-F]{64,}'|[\"'][A-Za-z0-9+/_=-]{64,}[\"']"
# The gap spans the rest of a SQL column list and its leading values — `wrapped_private_key` and its
# `X'…'` sit about 110 characters apart in a seed row, and a JSON member puts them adjacent.
#
# 200 is the portable ceiling, not a judgement about how wide a seed row gets. POSIX caps an
# interval's upper bound at RE_DUP_MAX — 255 — and BSD `grep -E` enforces it while GNU's reports
# 32767, so a bound of 300 is rejected outright on macOS: the pattern never compiles, `grep -q`
# returns non-zero, and the rule silently never fires. It passed all six controls and failed only
# its three positive cases, which is exactly what a rule that never fires looks like. Stay under 255.
WRAPPED_PAIR="$WRAPPED_FIELD.{0,200}($WRAPPED_VALUE)"
# The material that unwraps it, which may be a line away — a pretty-printed JSON file puts the key
# and its `kdfParams` in separate members — so this half is asked of the whole file. `iterations`
# takes a count so that prose using the word in its ordinary sense does not qualify, and the ECDH
# spelling covers an envelope sealed with no passphrase at all.
UNWRAPPING_MATERIAL='iterations["'"'"']?[[:space:]]*[:=][[:space:]]*[0-9]{3,}|ephemeral[_-]?public[_-]?key'
wrapped_key() { # content
  grep -qiE -- "$WRAPPED_PAIR" <<<"$1" || return 1
  grep -qiE -- "$UNWRAPPING_MATERIAL" <<<"$1"
}

offends() { # path content
  listed "$1" "$ALLOWED_NAME" || { credential_path "$1" && return 0; }
  listed "$1" "$ALLOWED_CONTENT" && return 1
  leaks "$2" && return 0
  literal_credential "$2" && return 0
  wrapped_key "$2" && return 0
  return 1
}

offenders=""
if [ "${1:-}" = "--scan-tree" ]; then
  while IFS= read -r path; do
    [ -f "$path" ] || continue
    offends "$path" "$(tr -d '\0' <"$path" 2>/dev/null)" && offenders="$offenders $path"
  done < <(git ls-files)
else
  while IFS= read -r path; do
    offends "$path" "$(git show ":$path" 2>/dev/null | tr -d '\0')" && offenders="$offenders $path"
  done < <(git diff --cached --name-only --diff-filter=AM)
fi

if [ -n "$offenders" ]; then
  echo "pre-commit: refusing to commit credential material:"
  for f in $offenders; do echo "pre-commit:   $f"; done
  echo "pre-commit:"
  echo "pre-commit: Credentials belong in the repository that exists to hold them, not this one —"
  echo "pre-commit: that split is what keeps this repository portable to machines you do not own."
  echo "pre-commit:"
  echo "pre-commit:   unstage with:  git restore --staged <path>"
  echo "pre-commit:"
  echo "pre-commit: A credential NAMED in code is fine — it is a literal VALUE that is refused."
  echo "pre-commit: Read it at runtime instead:  source \"\$CREDENTIALS_DIR/<file>.env\""
  echo "pre-commit:"
  echo "pre-commit: A path whose name only looks like a credential goes in credentials-allow-name;"
  echo "pre-commit: one that must carry a key header goes in credentials-allow-content."
  echo "pre-commit: (bypass: git commit --no-verify)"
  exit 1
fi
