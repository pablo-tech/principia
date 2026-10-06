---
name: as-built
description: The document that describes a system is part of that system — changed in the same change that changes the system, and corrected on the spot when it is merely found to be wrong.
---

# As-built

*A document is part of the system it describes, and the evidence for a discrepancy decays from the
moment it is found.*

**Named:** stop the line — Taiichi Ohno, *Toyota Production System*, 1978. As-built record
documents — AIA Document A201, *General Conditions of the Contract for Construction*, §3.11, which
requires a record set marked to show the work as actually executed.

**The document that describes a system is part of that system.** It is not a report about the work,
written afterwards by whoever has time. A reader who cannot trust it has to re-derive the system from
the system, which is the cost the document existed to remove.

- **A change to a system updates the document that describes it, in the same change.** Not a
  follow-up, not a ticket. This is the documentation analogue of the rule that new or modified
  behaviour gets its test in the same change, and it holds for the same reason: the change and the
  record of it are one unit of work, and splitting them means one of the halves does not happen.
- **State what is, not what was decided.** The document describes the system as it stands. The
  reasoning that led there belongs in the plan, the commit message or a decision record — places that
  are dated by construction and are not read as current. "A decision record" below says what one of
  those is and when a decision has earned one.
- **A setting observed is a setting changed, for this purpose.** Reading a live system and finding it
  configured differently from its document is a discrepancy that has already happened; the reading is
  simply when it was noticed.
- **Correct on discovery.** See "Found wrong" below.
- **If nothing describes it, that is the finding.** A system with no document is not exempt from this
  rule — it is the case the rule is most expensive to have skipped. Write the short true version now
  rather than the complete one later.

## A decision record

**A decision record is one to three sentences: what the context was, what was decided, and why.**
That is the whole required form. Status, the options considered and the consequences are added where
a reader needs them and left out where they would be ceremony — a template filled in to be complete
is how the three sentences that matter end up on page two.

**A decision has earned one when all three of these hold.** It is **hard to reverse**; it is
**surprising** to a reader who does not have the context that produced it; and it was a **real
trade-off**, with alternatives that were genuinely available. Miss one and there is nothing to
record: an easy decision is simply reversed when it stops fitting, an unsurprising one raises no
question for a record to answer, and a decision with no alternative is a constraint — which is part
of what the system *is*, and belongs in the document that says so. The three conditions are the
whole gate, and they are strict on purpose: a project that records every decision has built a second
changelog nobody reads, and the few records that were worth writing are now buried in it.

**It lives in the repository the decision concerns, as `docs/adr/NNNN-slug.md`, and the first record
that is earned creates the directory.** Whoever meets the surprising code is in that repository, and
the record has to be reachable from there rather than from wherever the work was planned. The path
is named here instead of left to each project to invent, because a location re-derived per project
is a location that drifts — and then the pointer above dangles again in a new way.

**This is a third kind of document, and that is why neither of the other two may carry it.** A plan
says what is intended and is superseded by the work it authorized; an as-built document says what
is; a decision record says why what is, is what it is. The plan cannot hold it because the plan is
replaced, and this document cannot hold it because reasoning stated here reads as current policy
rather than as a choice someone made on a date.

## Found wrong

**A document found to disagree with the system is corrected in the change that found it**, at the
moment of discovery, not queued.

The reason is that the evidence is never again this good. Whoever found the discrepancy has the
system in front of them, knows what they ran to see it, and knows which of the two is right. An hour
later that is a question someone has to re-open; a week later it is an archaeology task, and the
usual outcome is that the document is left alone because nobody can prove it wrong any more.

The cost of deferring is not the edit that was postponed. It is that every reader between the
discovery and the correction is misled by a document someone already knew was false — and they act on
it, because the document is the thing that exists to be acted on.

Two consequences worth stating, because they are the ones people argue with:

- **A correction is in scope by definition.** It is not scope creep to fix the document your change
  just falsified, and it is not scope creep to fix the one you happened to disprove on the way. The
  boundary is the discrepancy you found, not the file it lives in.
- **Small and true beats complete and late.** A one-line correction landed today is worth more than
  the rewrite that would have been thorough. The rewrite is a separate piece of work, and it is
  allowed to be planned; the correction is not allowed to wait for it.
