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
construct validity, and it arrived here by luck rather than by design. Since 2026-10-13 one such
instrument is designed: `bin/test.sh` counts the `ok` and `FAIL` lines a suite printed, rebuilds
the verdict those counts imply, and refuses the suite unless its last line is that line byte for
byte — so a suite whose checks did not all run is a failure rather than a pass, judged by something
that is not the suite. It would not have caught this one, whose checks all ran and whose count was
honest; what it closes is the other half of the same hole, a suite that never reached its verdict at
all. `bin/test.test.sh` is what holds the runner to that, and `shellcheck -x` is still the
instrument for this entry's own shape.

### The citation condition failed in the document that states it — 2026-10-07

**The rule** — [`INDUCTION.md`](INDUCTION.md#a-name-is-not-yet-a-citation), second test: the work
cited is the one the field cites, not the earliest antecedent a search turns up.

**What happened** — construct validity was cited to Campbell and Fiske, 1959, which is the
multitrait–multimethod procedure for *arguing* construct validity rather than the work that defines
it. The field cites Cronbach and Meehl, 1955. Corrected in `6b98fa9`, in the three places that
commit went looking in. A fourth carried it, and still did five days later — see the entry of
2026-10-12 below.

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
and nothing reconciles the three texts. Two more arrived on 2026-10-12: the year a copy prints is
held to the year inside the lineage anchor beside it, and every work a `Named:` line names is held
to carrying one. Neither reaches the disagreement this entry records, which was about *which work*,
and nothing mechanical does.

### A correction said it was complete, and it was not — 2026-10-12

**The rule** — [`doctrine/as-built.md`](doctrine/as-built.md) requires the record to be corrected to
what was actually built, and [`INDUCTION.md`](INDUCTION.md#printed-in-four-places-deliberately)
takes its four-places exemption on the ground that a disagreement between the copies is a typo "a
reader catches for free."

**What happened** — `6b98fa9` corrected construct validity from Campbell and Fiske, 1959 to
Cronbach and Meehl, 1955 and reported that it had done so "in all three places that carried it."
Four carried it. The fourth was a `CHANGELOG.md` bullet, fifty-four lines below the bullet
announcing the correction and inside the same unreleased section, and the entry above on this page
repeated the count of three. So the page recording that the exemption had failed carried the
failure, and the commit message a reader would check it against asserted completeness it had not
measured. Corrected here and in `CHANGELOG.md`; the claim that was wrong is `6b98fa9`'s.

**What caught it** — an audit of the whole repository against its own sentence about what the
documents are for, five days later. Not a reader, not the suite, and not the correction's own author
on the day.

**What it says about the rule** — a claim that a correction is complete is a claim about a count,
and it was made by the party who had just done the counting, with no second count anywhere. That is
the shape [`doctrine/as-built.md`](doctrine/as-built.md) names for a comparative claim — that the
means of falsifying it ship beside it — applied to the one kind of claim this page is made of. What
was available and unused is grep. So two checks now stand where the exemption's "for free" was:
`bin/induction.test.sh` holds the year in a copy to the year in the lineage anchor beside it, and
holds every work a `Named:` line names to carrying one, which is the half of this that a script can
count. The half it cannot is whether a correction reached every place — the copies are in files
nothing enumerates — and that is recorded here as unenforced rather than left to the next reader.

---

## What found them

Four were found on one day and the fifth five days later, and none was found by review. Three
surfaced while writing [`LINEAGE.md`](LINEAGE.md), which forced every citation to be restated
somewhere it had never been stated before, the fourth by a linter that had been running all along
over a construction no reader looks for, and the fifth by an audit that restated the claim a third
way — as a check, which is the one form that counts rather than reads. The general claim is the one
[`doctrine/as-built.md`](doctrine/as-built.md) already makes about documents and this page extends to
rules: what audits a claim is being made to state it again, at a different length, for a different
reader. Re-reading it where it already sits finds nothing.
