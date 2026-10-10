# Refutation

*Where the doctrine has been wrong here. One entry per rule that was stated or applied and failed:
what happened, what caught it, and what the failure says about the rule rather than about the day it
happened.*

**This page is not doctrine.** It holds no rule and binds nothing, and where it and a doctrine
document disagree the document wins and this page is the defect. That is the standing
[`LINEAGE.md`](LINEAGE.md) has and for the same reason — it is evidence rather than instruction, and
nothing here is installed as a skill.

**Why it exists.** [`INDUCTION.md`](INDUCTION.md#five-conditions-and-they-are-conjunctive) admits a
rule only when its breach is observable and cheap to observe, on the stated ground that a rule whose
violation is indistinguishable from compliance "is also the shape that never gets removed, because
nothing can ever show it failing." That condition is written to make removal possible. Until this
page there was nowhere for a rule to be shown failing, so the condition bought the possibility and
discarded the result.

**It is not a second copy of the register.** [`LINEAGE.md`](LINEAGE.md) prints what the *field* says
against each name — objections that existed before a word here was written, and which the admitter
therefore held before being wrong. [The register](INDUCTION.md#the-register)'s third column prints
the departures, which are this repository's own narrowings, declared in advance. Both are arguments
available at admission. This page prints what *use* says against a rule, which arrives only
afterwards and cannot be anticipated. A repository carrying the first two and not the third has
published every argument against itself that costs nothing.

**What an entry is, and is not.** A rule, stated or applied, and an observable breach with a commit
a reader can go and read. Not a defect in a mechanism — that belongs in the commit message that
fixes it. And not the particular that produced it beyond the commit that identifies it:
[condition 3](INDUCTION.md#five-conditions-and-they-are-conjunctive) leaves the inducing case with
whoever paid for it, and the reasoning holds here too, because a failure stated as an incident is a
war story and a war story cannot be argued with by anyone who was not in the room.

**What the length of this page is not evidence of.** It records what somebody noticed. A rule with
no entry here has not been vindicated; it has not been caught.

**What holds the page, and what nothing holds.** `bin/refutation.test.sh` asks of every entry that
it carry the four slots, that it be dated, that it name a commit, and that the commit be one this
repository contains — and asks of the documents describing this repository that they still reach
here. What nothing holds is the part that matters most: that an entry gets *written* when a rule
fails. No script can tell a rule that has never failed from one whose failure nobody recorded, and
the check that would seem to close the gap — an entry required per doctrine document — buys coverage
by inviting the one thing that would make this page worthless, an entry written to satisfy it. So it
is recorded here as unenforced with the decision attached, which is what
[`doctrine/as-built.md`](doctrine/as-built.md) asks of a gap instead of a note.

---

### The counter-arguments were imported in name only — 2026-10-07

**The rule** — [`INDUCTION.md`](INDUCTION.md#why-the-name-is-the-load-bearing-condition) admits a
rule partly because a name "imports the counter-arguments": the cases where it is known to fail, the
costs it is known to carry, the practitioners who think it is wrong.

**What happened** — the repository printed an objection for one of forty-one names. The other forty
arrived with the authority of a literature and none of its contents, which is the failure the same
section names two paragraphs later, of a rule "named but *uncited*", and which it calls failing "the
same way with better manners". The claim had stood since `ca967d7`, the commit that introduced it.
Answered by `b8c3282`.

**What caught it** — counting the printed objections while writing a different document. Nothing in
the repository asked the question, and the claim was load-bearing in the argument for the whole
admission gate.

**What it says about the rule** — a justification that lives only in the prose of the document
granting it is held by nobody. The import is a mechanism now: `bin/induction.test.sh` refuses an
entry carrying neither a dated objection nor the claim that none was found, which is condition 4
applied to condition 1 after the fact.

### The suite that forbids a vacuous pass contained one — 2026-10-07

**The rule** — [`doctrine/testing.md`](doctrine/testing.md): a test must be able to fail, and a
check that has never been red is telling you about its own construction rather than about the code.

**What happened** — `unlineaged()`, the check requiring every `Named:` line to reach a lineage
entry, was spliced in before the closing brace of the check before it. Bash bound the name only
while the enclosing function was running, so the suite passed because check 6 happens to run before
check 7. Reordered, check 7 would have failed with `unlineaged: command not found` — a failure that
says nothing about the tree it is judging. `f88b650`.

**What caught it** — `shellcheck -x`, as SC2329, a function never invoked. Not the suite, which was
green, and not a reading of the diff.

**What it says about the rule** — red-first does not reach a check added to a suite that already
passes, and the document's own corollary about distrusting checks that pass on first run is written
for a suite written before its implementation rather than for one check appended to a green suite.
What held the line was an instrument outside the suite, which is the remedy the field names for
construct validity, arriving here by luck rather than by design.

### The citation condition failed in the document that states it — 2026-10-07

**The rule** — [`INDUCTION.md`](INDUCTION.md#a-name-is-not-yet-a-citation), second test: the work
cited is the one the field cites, not the earliest antecedent a search turns up.

**What happened** — construct validity was cited to Campbell and Fiske, 1959, which is the
multitrait–multimethod procedure for *arguing* construct validity rather than the work that defines
it. The field cites Cronbach and Meehl, 1955. Corrected in `6b98fa9`, in all three places that
carried it.

**What caught it** — writing the lineage entry, which cannot be written without stating what the
work claims at its own scope. The `Named:` line and the register row had both carried it unexamined.

**What it says about the rule** — `bin/induction.test.sh` checks that a dated work is *present*,
which is the half a script can judge, and the document says so. What it cannot check is whether the
work is the right one. The first audit of all forty-one names corrected three of them. The
mechanical half of condition 1 is not the condition, and a green suite here is the weakest evidence
in the repository.

### The exemption from one canonical home drifted first — 2026-10-07

**The rule** — [`INDUCTION.md`](INDUCTION.md#printed-in-four-places-deliberately) prints each
citation in four places and takes an explicit exemption from
[`doctrine/clean-code.md`](doctrine/clean-code.md), on the ground that "a citation is dated and
immutable" and that "nothing can make the four copies disagree except a typo — the one failure mode
a reader catches for free."

**What happened** — `warp.md`'s `Named:` line said Jensen and Meckling, 1976, while the register and
the lineage headed the entry Ross, 1973. Three copies, one disagreement, inside a day of the
exemption being taken. It was not a typo: the copies disagreed about *which work* the rule is named
from, which is not caught for free and was not caught by a reader. The copy that was wrong was the
one printed where the rule is applied — the copy the same document says cannot be skipped, and so
the only one whose reader has nothing to check it against. `6b98fa9`.

**What caught it** — writing the lineage entry, as above.

**What it says about the rule** — the exemption is sound and its stated ground is not. Immutability
of the fact bounds how the copies can disagree but not whether they will, because what is copied is
a choice of work and not only its date. `clean-code.md`'s claim is that a second copy needs somebody
who has undertaken to keep it true, and the exemption was granted without naming who that was. One
of the four now has a check — `unlineaged` requires a `Named:` line to reach an entry that exists —
and nothing reconciles the three texts.

---

## What found them

All four were found on one day, and none was found by review. Three surfaced while writing
[`LINEAGE.md`](LINEAGE.md), which forced every citation to be restated somewhere it had never been
stated before, and the fourth by a linter that had been running all along over a construction no
reader looks for. The general claim is the one
[`doctrine/as-built.md`](doctrine/as-built.md) already makes about documents and this page extends to
rules: what audits a claim is being made to state it again, at a different length, for a different
reader. Re-reading it where it already sits finds nothing.
