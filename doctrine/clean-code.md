---
name: clean-code
description: The Clean Code standard, applied to prose as well as to code — no comments without a non-obvious why, ruthless DRY, small single-responsibility units, one concept to one word with a glossary that names the synonyms it refuses, and the Boy Scout rule with its limit.
---

# Clean Code

*Two copies of a fact is a missing signal, not redundancy.*

**Named:** don't repeat yourself — Andrew Hunt and David Thomas, *The Pragmatic Programmer*, 1999,
whose database form is older and sharper: a value stored twice admits an update anomaly — E. F. Codd,
"A Relational Model of Data for Large Shared Data Banks", 1970. This document's title, and the Boy
Scout rule below, are Robert C. Martin's — *Clean Code*, 2008.

This applies to code *and* to prose — instruction files, prompts, skills, agent configuration,
runbooks. A bloated or duplicated document is the same defect as a bloated or duplicated function,
just paid by every session instead of by every call.

- **No comments unless the *why* is non-obvious** — a hidden constraint, a subtle invariant, a
  workaround for a known bug. No docstrings on obvious functions.
- **Don't handle what cannot happen.** Trust the guarantees the framework already makes.
- **Don't introduce abstractions beyond what the task requires.**
- **No half-finished implementations.** No `TODO` left behind unless one was asked for.
- **DRY, ruthlessly.** The same fact or logic in two places will drift, and one of them becomes a lie
  with no signal which. This is why a cross-cutting fact gets exactly one home and everything else
  links to it; the same rule governs a helper copy-pasted across call sites.
- **A document restating the environment is a cache, and a cache earns its load only where the
  lookup it saves is expensive.** The unwritten convention, the reason behind a choice, the gotcha no
  configuration file confesses — those have no source to read, so writing them down is the only copy
  there is. A fact one command answers is left to the command, where it cannot go stale. That is the
  general form of the hand-typed status [`planning.md`](planning.md) refuses: a second copy of a
  derivable fact, wrong from the moment the source moves and silent about when that was.
- **Small, single-responsibility units.** A function or module doing one thing, named for that thing,
  beats a god-function dispatching on twenty flags or a 900-line file owning every concern in a
  domain. Split by responsibility, not to hit a line count.
- **The why is a line, not a paragraph.** A comment, a document section or a note states the rule and,
  where needed, one line of reason. An incident post-mortem belongs in a dated history — a changelog,
  a decision record (`as-built.md` says what one is), the commit log — not reloaded in full as live
  policy forever.
- **Boy Scout rule:** leave the code and documents you touch cleaner than you found them — but that
  is not licence to refactor or reorganize beyond what the task requires. The default fate of a
  document nobody prunes is **sediment**: layers that settle because adding a line feels safe and
  removing one feels risky. That asymmetry is the mechanism, which is why the counter has to be
  scheduled rather than felt — a document is pruned in the change that touches it, under the same
  limit as the rest of this rule.
- **Introduce the one thing that was asked for.** Don't restructure or rename what already works
  along the way.
- **Clean up after yourself, and only after yourself.** "Cleanup" means the worktrees, branches,
  scratch files and test artefacts *this* session created. Anything already in the tree is someone
  else's in-flight work: name it if it is in the way, and leave it where it is.

## One concept, one word

**A project keeps one glossary, at its root, created when the first term has to be resolved.** An
entry is a sentence or two saying what the term *is*, and **the synonyms it refuses**. That refused
list is the load-bearing half — it is what makes a drifting term visible, where a definition alone
leaves the second name reading as a third concept.

Only terms specific to that project belong in it. A general concept arrives with its meaning already,
and defining it here only competes with what the reader has. No implementation detail either: a
glossary is not a spec. **A term used against the glossary is challenged in the change that used
it**, which is [`as-built.md`](as-built.md)'s correct-on-discovery rule applied to language.

All of this is the drift rule above, over terms rather than over facts: two names for one concept, or
one name for two, and a reader is right half the time.
