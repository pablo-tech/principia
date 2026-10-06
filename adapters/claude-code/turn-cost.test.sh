#!/usr/bin/env bash
# turn-cost.sh on a scratch transcript: two turns, the last with one request logged twice (one line per content
# block, the same usage on each), as Claude Code writes them.
#   bash adapters/claude-code/turn-cost.test.sh
# shellcheck disable=SC2016 # a check's condition is eval'd by the harness, so $t and $DIR expand there
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
# shellcheck disable=SC1091
source "$DIR/../../bin/check.sh"

u() { printf '{"type":"assistant","requestId":"%s","message":{"usage":{"input_tokens":%s,"cache_creation_input_tokens":%s,"cache_read_input_tokens":%s,"output_tokens":%s}}}\n' "$@"; }
{
  echo '{"type":"user","message":{"content":"an earlier prompt"}}'
  u old 1000 0 0 100
  echo '{"type":"user","message":{"content":"this turn"}}'
  u b 10 1000 100000 500
  echo '{"type":"user","message":{"content":[{"type":"tool_result","content":"ok"}]}}'
  u b 10 1000 100000 500
  u c 0 0 50000 100
} >"$t/turn.jsonl"
echo '{"type":"user","message":{"content":"nothing answered yet"}}' >"$t/empty.jsonl"

# **Exported for the whole suite, not passed at each call site.** The script under test appends to a
# real path in `$HOME` by default, so a suite that forgets this on one check out of nine files its own
# fixtures into the log a report is computed from -- and the report then reads green over its own test
# data. A default that has to be remembered at nine call sites is a default that will be missed at the
# tenth, so it is set once, here, and the first check below pins it.
export PROTOCOL_WORK_LOG="$t/state/work-log.jsonl"

# b once and c: 10*15 + 1000*18.75 + 150000*1.5 + 600*75 per Mtok. b twice would be $0.4953, the earlier turn $0.3114.
check "costs this turn only, each request once" \
  "bash '$DIR/turn-cost.sh' '$t/turn.jsonl' | grep -cF 'Turn cost: \$0.2889  ·  in 10 · cache-w 1k · cache-r 150k · out 600 tok' >/dev/null"
check "as a hook, says it as a systemMessage" \
  "echo '{\"transcript_path\":\"$t/turn.jsonl\",\"session_id\":\"a-session\"}' | bash '$DIR/turn-cost.sh' --hook | jq -er '.systemMessage | startswith(\"Turn cost: \$0.2889\")' >/dev/null"
check "says nothing for a turn with no requests" "[ -z \"\$(bash '$DIR/turn-cost.sh' '$t/empty.jsonl')\" ]"

echo "and keeps what the turn cost"
check "a suite run writes its log into its own tmp, never the real one" \
  '[ "$PROTOCOL_WORK_LOG" = "$t/state/work-log.jsonl" ]'
check "the two runs above appended one line each" '[ "$(wc -l <"$PROTOCOL_WORK_LOG")" -eq 2 ]'
check "which is one json object per turn" \
  'jq -e "type == \"object\"" "$PROTOCOL_WORK_LOG" >/dev/null'
check "saying what kind of record it is, and when" \
  'jq -e --slurp "all(.kind == \"cost\") and all(.at | test(\"^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:]+Z$\"))" "$PROTOCOL_WORK_LOG" >/dev/null'
check "carrying the same token counts the line printed" \
  'jq -e --slurp ".[0].tokens == {input:10, output:600, cache_read:150000, cache_write:1000}" "$PROTOCOL_WORK_LOG" >/dev/null'
check "and how many requests answered the turn" \
  'jq -e --slurp ".[0].requests == 2" "$PROTOCOL_WORK_LOG" >/dev/null'
# The largest single request, not the sum: 101010 for b, 50000 for c. It is the figure that decides
# whether a turn billed at the long-context tier, which a total across requests would not.
check "and the biggest context any one of them carried" \
  'jq -e --slurp ".[0].context_max == 101010" "$PROTOCOL_WORK_LOG" >/dev/null'
# Pinned as the whole field set, which is also how "no dollar figure" is enforced: a cost in money is
# derived from prices the script itself admits go stale, so storing one would put a number that was
# true once into a file nobody re-reads. Tokens are the measurement; money is a view over them.
check "and these fields and no others, so no price is ever stored" \
  'jq -e --slurp "all(keys | . == [\"at\",\"context_max\",\"kind\",\"requests\",\"session\",\"tokens\"])" "$PROTOCOL_WORK_LOG" >/dev/null'
check "a hook records the session it was handed" \
  'jq -e --slurp ".[1].session == \"a-session\"" "$PROTOCOL_WORK_LOG" >/dev/null'
check "and a plain run names the session after the transcript it read" \
  'jq -e --slurp ".[0].session == \"turn\"" "$PROTOCOL_WORK_LOG" >/dev/null'

echo "and is never the reason a turn fails"
check "a turn with nothing to report appends nothing" \
  'bash "$DIR/turn-cost.sh" "$t/empty.jsonl" >/dev/null && [ "$(wc -l <"$PROTOCOL_WORK_LOG")" -eq 2 ]'
check "an empty setting turns the log off and still prints the line" \
  'PROTOCOL_WORK_LOG= bash "$DIR/turn-cost.sh" "$t/turn.jsonl" | grep -q "^Turn cost:"'
check "a log that cannot be written is silent, not fatal" \
  'PROTOCOL_WORK_LOG=/proc/nope/work-log.jsonl bash "$DIR/turn-cost.sh" "$t/turn.jsonl" 2>/dev/null | grep -q "^Turn cost:"'
check "and nothing of that reached the log" '[ "$(wc -l <"$PROTOCOL_WORK_LOG")" -eq 2 ]'

finish
