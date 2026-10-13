# shellcheck shell=bash
# The two things bin/adapt and every adapter do to a tenant, written once. Both set TENANT to the
# tenant's root before sourcing this.

# One line per change, so a second run visibly does nothing.
say() { printf '  %-6s %s\n' "$1" "$2"; }

# Patterns for the tenant's .gitignore — unless the tenant already has a rule about that path.
#
# Not a comparison of the line: a tenant that answered this in a spelling of its own has answered it,
# and a broader rule appended underneath wins as the last matching pattern and silently undoes the
# exception it carved out. A context repo ignoring `projects/*/*` while keeping `projects/*/memory/*.md`
# tracked loses that memory to a later `/projects/`. The tenant's rules are the tenant's, same as its
# instruction file — an adapter may create, never edit.
#
# Which is why one caller's whole set arrives in one call. "Has the tenant said anything about this
# path" is a question about the tenant's lines, and a pattern the caller is installing beside this one
# is not the tenant saying anything. Two rules under one directory would otherwise have the first
# silence the second on the very first run — and the second is the one that was holding a credential
# out of the index.
ignore() {
  local file="$TENANT/.gitignore" theirs pattern theirline
  # The tenant's own lines: the file, less the patterns this call is installing.
  theirs="$(grep -vxF -f <(printf '%s\n' "$@") -- "$file" 2>/dev/null)" || true
  for pattern in "$@"; do
    # The pattern is already there, verbatim. Nothing happened and nothing is said: a second run
    # printing a line about every rule it found in place is the header's claim broken in the other
    # direction.
    grep -qxF -- "$pattern" "$file" 2>/dev/null && continue
    # Not installing it is a decision, and until 2026-10-12 it was made in silence. A live tenant
    # ignoring `skills/omarchy` had `/skills/synced/` declined on that ground and the operator had
    # to work out from the absence that anything had been considered at all. Whether the tenant's
    # line really does rule on this path is a judgement, and a judgement the operator can overrule
    # by writing their own rule — but only one they are told about.
    if theirline="$(covers "$pattern" "$theirs")"; then
      say skip "$pattern (the tenant's own '$theirline' already rules on it)"
      continue
    fi
    # A file whose last line carries no newline takes the append onto the end of it: the tenant's
    # last rule is rewritten into something neither party wrote, and this pattern is not installed
    # either. `>>` cannot see that, so it is asked first. An empty or absent file needs nothing.
    if [ -s "$file" ] && [ -n "$(tail -c1 -- "$file")" ]; then printf '\n' >>"$file"; fi
    printf '%s\n' "$pattern" >>"$file"
    say ignore "$pattern"
  done
}

# Which of the tenant's own lines, if any, already rules on the path a pattern names — printed, so
# the caller can say it.
#
# A path-prefix either way, at a `/` boundary, which is narrower than it was and wider than equality.
# Full-pattern equality would install `/projects/` underneath a tenant's `projects/*/*` and
# `!projects/*/memory/*.md` and take that memory with it, which is the loss the header describes.
# The first path segment, which is what this compared until 2026-10-12, reads `skills/omarchy` as an
# answer about `/skills/synced/` — a different directory under a shared parent, and the live case
# above. The prefix is what lies between: a rule about `.protocol/` is a rule about
# `.protocol/*.local` under it, and a rule about one leaf beside it is not.
#
# Both sides are compared literally — the quoting in `case` is what makes `*` a character here rather
# than a wildcard — because a tenant's glob is not a path and guessing what it would have matched is
# a second implementation of git's matcher.
covers() {
  local mine="$1" theirs="$2" a b line
  a="$(ignore_path "$mine")"
  [ -n "$a" ] || return 1
  while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    b="$(ignore_path "$line")"
    [ -n "$b" ] || continue
    case "$a/" in "$b/"*) printf '%s' "$line"; return 0 ;; esac
    case "$b/" in "$a/"*) printf '%s' "$line"; return 0 ;; esac
  done <<<"$theirs"
  return 1
}

# The path a .gitignore line rules on: the line without its negation, its anchor or its trailing
# slash, none of which change which path it is about.
ignore_path() { local p="${1#!}"; p="${p#/}"; printf '%s' "${p%/}"; }
