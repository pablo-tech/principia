#!/usr/bin/env bash
# Doctrine makes no claim about a model — asked of the documents themselves.
#   bash bin/doctrine.test.sh
#
# ARCHITECTURE.md §1 admits a rule only if it would still be true if every model on the machine were
# replaced tomorrow, and §10 lists the measurement of a model as out of scope. This suite is that
# sentence as a check, because the mixture it forbids is invisible to a reader: a claim with a
# two-month half-life filed in `doctrine/` inherits the authority of one with a twenty-year
# half-life, and nothing about the file's shape tells them apart. Two documents had drifted that way
# before this existed, and it took reading all nine to find them.
#
# What it looks for is narrow on purpose: a vendor, a model family, a version string beside a family
# name, a price, and the tuning vocabulary a measurement needs and a rule does not. The generic noun
# `model` is deliberately in none of the patterns — `tenancy.md` needs it to say that a rule telling
# a model what not to read is not a control against a file being readable, which is a claim about
# controls. A bare version number is out for the same reason: `1.0` is evidence of nothing without
# the family beside it, and the family is what the second pattern already refuses.
#
# Every pattern is also run against one sample of what it exists to refuse. A pattern that compiles
# and matches nothing passes a whole directory in silence, which is what a rule that never fires
# looks like, and an interval bound over RE_DUP_MAX is how this repository last produced one.
# shellcheck disable=SC2034  # each pattern is used inside an eval'd check condition below.
# shellcheck disable=SC2016  # a check's condition is eval'd by the harness, so $VENDORS
# expands there and not here.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$DIR/check.sh"

# `\b` is a GNU extension the BSD engine does not promise, and a boundary that silently becomes a
# literal widens the pattern rather than breaking it, so the controls below would not catch it.
B='(^|[^a-zA-Z])'
E='([^a-zA-Z]|$)'

VENDORS="anthropic|openai|deepmind|mistral ai|cohere|${B}xai${E}|${B}meta ai${E}"

FAMILIES="claude|chatgpt|${B}gpt${E}|${B}o[1-9]${E}|opus|sonnet|haiku|gemini"
FAMILIES="$FAMILIES|llama|mixtral|qwen|deepseek|grok|copilot"

VERSIONS='(claude|gpt|gemini|llama|opus|sonnet|haiku|qwen|grok)[ ._-]?[0-9]'

PRICES='\$[0-9]|[0-9]+ ?cents?|per (million|thousand) tokens?'
PRICES="$PRICES|per-token|(cost|price) per (turn|call|token)"

TUNING='temperature|top[_-]?[pk]|max.tokens|reasoning effort|extended thinking'
TUNING="$TUNING|thinking (mode|budget)|(token|context|attention) budget|context window"
TUNING="$TUNING|tokens? (per|a|every) (turn|call)"
TUNING="$TUNING|few.?shot|chain.of.thought|fine.?tun|(cheaper|smaller|frontier) model"
TUNING="$TUNING|model (swap|tier|family|version|generation)"

# The judgement, over `doctrine/` alone. Every match prints, because the fix is to read the line.
scan() {
  local hits
  hits=$(grep -niE "$1" "$DIR"/../doctrine/*.md) || return 0
  printf '%s\n' "$hits" | sed 's|.*/doctrine/|        doctrine/|'
  return 1
}
# The control: one sample of the thing the pattern exists to refuse.
fires() { printf '%s\n' "$2" | grep -qiE "$1"; }

check "no doctrine document names a vendor" 'scan "$VENDORS"'
check "no doctrine document names a model family" 'scan "$FAMILIES"'
check "no doctrine document carries a model version" 'scan "$VERSIONS"'
check "no doctrine document carries a price" 'scan "$PRICES"'
check "no doctrine document carries a tuning knob" 'scan "$TUNING"'

check "the vendor pattern can fail" 'fires "$VENDORS" "measured against the Anthropic API"'
check "the family pattern can fail" 'fires "$FAMILIES" "it held for Opus and not for Haiku"'
check "the version pattern can fail" 'fires "$VERSIONS" "unchanged since Sonnet 4.5"'
check "the price pattern can fail" 'fires "$PRICES" "the cross-check costs 4 cents a turn"'
check "the tuning pattern can fail" 'fires "$TUNING" "extended thinking widens a tight frame"'

finish
