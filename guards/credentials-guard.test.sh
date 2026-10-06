#!/usr/bin/env bash
# credentials-guard.sh against the index of a scratch repository, and against its policy files.
#   bash guards/credentials-guard.test.sh
# shellcheck disable=SC2016 # the fixtures below are credential literals; a `$` in one is the point
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
# shellcheck disable=SC1091
source "$DIR/../bin/check.sh"

fresh() { scratch_repo "$t/repo" >/dev/null; }
# stage path content
stage() { mkdir -p "$t/repo/$(dirname "$1")" && printf '%s\n' "$2" >"$t/repo/$1" && git -C "$t/repo" add -A; }
# allow name lines: write one of the repo's policy files
allow() { mkdir -p "$t/repo/.protocol" && printf '%s\n' "$2" >"$t/repo/.protocol/$1" && git -C "$t/repo" add -A; }
guard() { (cd "$t/repo" && bash "$DIR/credentials-guard.sh" >/dev/null 2>&1); }

KEY='-----BEGIN OPENSSH PRIVATE KEY-----'

fresh
stage notes.md "nothing to see"
check "an ordinary file passes" "guard"

fresh
stage infra/prod.env "REGION=us-west-2"
check "a file whose name has a credential shape is refused whatever it holds" "! guard"

fresh
stage infra/prod.env "REGION=us-west-2"
allow credentials-allow-name 'infra/prod.env'
check "credentials-allow-name exempts a named path from the shape rule" "guard"

fresh
stage infra/prod.env "PASSPHRASE=hunter2correct"
allow credentials-allow-name 'infra/prod.env'
check "a path exempt from the shape rule is still read for content" "! guard"

fresh
stage infra/a.env x && stage infra/b.env y
allow credentials-allow-name 'infra/*.env'
check "a policy entry is a glob, not one literal path" "guard"

fresh
stage secrets.env "$KEY"
allow credentials-allow-name '*'
allow credentials-allow-content '*'
check "a repository whose job is credentials lists * in both and commits them" "guard"

fresh
stage scratch/tunnel_token.txt "$KEY"
check "a key header is refused at a path no rule anticipated" "! guard"

fresh
stage doc.md 'the file starts `BEGIN OPENSSH PRIVATE KEY` on its first line'
check "prose naming a key header without its delimiters is documentation" "guard"

fresh
stage deploy.sh 'VAULT_PASSPHRASE=s3cretvalue'
check "a credential-named variable assigned a literal is refused" "! guard"

fresh
stage deploy.sh ': "${VAULT_PASSPHRASE:?set it}"'
check "a script declaring the credential it needs is correct code" "guard"

fresh
stage deploy.sh 'API_KEY=$(read_secret vault)'
check "a value derived by a command is not a literal" "guard"

fresh
stage README.md 'PASSWORD=CHANGEME'
check "a masked value reads as documentation" "guard"

fresh
stage suite.test.sh "KEY='$KEY'"
check "a test carrying a fixture is refused until it is named" "! guard"

fresh
stage suite.test.sh "KEY='$KEY'"
allow credentials-allow-content 'suite.test.sh'
check "credentials-allow-content exempts a named suite from the content rules" "guard"

fresh
stage suite.test.sh "KEY='$KEY'"
allow credentials-allow-content 'other.test.sh'
check "naming one suite does not exempt every suite" "! guard"

fresh
stage keys/id_ed25519 x
check "an ssh identity is refused by name" "! guard"

# A wrapped key: high-entropy end to end, no issuer prefix, no `NAME=value`. The fixtures below are
# obviously-fake runs of the right SHAPE and length — what is matched is a key beside the material
# that unwraps it, so each half is exercised with the other absent.
HEX96="$(printf 'deadbeef%.0s' $(seq 12))"   # 96 hex characters, the shortest a real one can be
B64='QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVphYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5eg=='
KDF='{"salt":"0123456789abcdef0123456789abcdef","iterations":200000}'

fresh
stage db/0002_seed.sql "INSERT INTO credentials (account_id, method, wrapped_private_key, kdf_params) VALUES ('a', 'password', X'$HEX96', '$KDF');"
check "a wrapped private key seeded beside its KDF parameters is refused" "! guard"

fresh
stage records/org-key.json "{\"wrappedPrivateKey\": \"$B64\", \"kdfParams\": $KDF}"
check "the same key as a base64 JSON member is refused" "! guard"

fresh
stage db/0003_envelopes.sql "INSERT INTO vault_envelopes (vault_id, wrapped_dek, ephemeral_public_key_jwk) VALUES ('v', X'$HEX96', '{\"kty\":\"EC\"}');"
check "a wrapped DEK beside the ephemeral key it was sealed with is refused" "! guard"

fresh
stage db/0001_schema.sql "CREATE TABLE credentials (account_id TEXT, wrapped_private_key BLOB NOT NULL, kdf_params TEXT);"
check "a schema declaring the column carries no key and passes" "guard"

fresh
stage src/store.ts "export type Credential = { wrappedPrivateKey: Uint8Array; kdfParams: { salt: string; iterations: number } };"
check "a type declaring the field is correct code" "guard"

fresh
stage src/wrap.ts 'const c = await wrapPrivateKey(key, kek); // iterations: 200000'
check "a call site passing a wrapped key is correct code" "guard"

# The regression this rule was rewritten for. Asking only whether a file contains each part somewhere
# let a 1.7 MB patch of ordinary source match on a type declaration, an unrelated hash and a KDF
# default thousands of lines apart, with no credential in it at all. The name and the value have to
# share a line, because that is how a seeded credential is actually written.
fresh
stage big.patch "$(printf '%s\n' \
  '-  wrappedPrivateKey: Uint8Array;' \
  '   const DEFAULT = { iterations: 200000 };' \
  "   const integrity = '$B64';")"
check "parts scattered through a large file are not a key beside its parameters" "guard"

fresh
stage db/0002_seed.sql "INSERT INTO credentials (wrapped_private_key) VALUES (X'$HEX96');"
check "a wrapped key with no unwrapping material beside it is opaque and passes" "guard"

fresh
stage db/0002_seed.sql "INSERT INTO credentials (account_id, method, wrapped_private_key, kdf_params) VALUES ('a', 'password', X'$HEX96', '$KDF');"
allow credentials-allow-content 'db/0002_seed.sql'
check "credentials-allow-content exempts a named seed from the wrapped-key rule" "guard"

finish
