---
name: planning
description: What a plan has to contain before it can be executed without further check-ins — an executive summary first, in the architect voice the closing report uses, what the work will take in calendar time, a worktree named as step one, per-phase summaries and rollback in a fixed table, what a completed phase reports having accomplished, and where the document lives.
---

# Planning

*Summary-first is pre-registration: a goal stated after its evidence is a conclusion the reader has
already agreed with.*

**Named:** pre-registration — Nosek, Ebersole, DeHaven and Mellor, "The preregistration revolution",
2018. Answer-first exposition — Barbara Minto, *The Pyramid Principle*, 1987.
[Lineage](../LINEAGE.md#pre-registration--nosek-ebersole-dehaven-and-mellor-2018).

A plan is not a build artefact and does not ship. **Planning documents live in the context
repository, under a path mirroring the one they would have had inside the repository they plan for**
— never inside that repository. Leaving a plan where it applies means every repository re-derives
its own answer to "where do plans live" and drifts.

A repository's own `docs/` still holds **operational** reference: runbooks, architecture-as-built,
ops documents. The line is forward-looking intent ("what we are going to do and why") against
current-state description ("how this works today"). When genuinely unsure, treat anything titled
plan, milestone, roadmap, evaluation or migration as planning.

## Every plan opens with an executive summary

The first thing in the document, ahead of any context or background, in the voice `warp.md`'s
closing report already defines: written for an architect who does not know this codebase, naming a
tool or a file only where the sentence fails without it. A reader should not have to infer the goal
from the remediation.

It answers four things, in this order:

- **What is wrong today, and what that costs.** Concretely — the money, the outage, the hours a
  recurring fault takes back. A problem with no stated cost cannot be weighed against doing nothing.
- **What will be true when this is done.** The end state, not the activity that produces it.
- **Why this shape and not the obvious alternative.** Name the alternative a competent reader would
  reach for first, and say what it fails on.
- **What is deliberately left open**, and whose decision it is.

**A summary that states only *how* fails, however accurate it is.** An account of what the plan will
do reads as thorough while leaving the reader nothing to disagree with but the ordering. The test is
whether someone who will never read the phases could tell that the plan is aimed at the wrong thing.

## Every plan says what it will take, and the calendar is the answer

Under its own heading, immediately after the executive summary: one table, a row per phase.

| Phase | Work | Notes |
|---|---|---|

- **Work** is a range of hands-on hours. A single number claims a precision nobody has, and is read
  as a commitment rather than as an estimate.
- **Notes** is what the calendar does to that number, and it is the column carrying the answer: what
  is blocked right now and on whom, what waits for something that runs at a fixed hour, what pays
  for a pull request and a continuous-integration run and a merge however small the diff, and which
  phase will stop and ask under `warp.md`'s four. Each of those is a wait on somebody else, and no
  quantity of hours estimates one.
- It closes with one sentence naming the **shape of the calendar** — how many sittings, and what
  decides where one of them ends. That sentence is the estimate; the hours are its input.

**The sum of the hours is not the answer.** Six hours of work is an afternoon or it is three days,
and which one it is turns entirely on the column beside them — so a plan offering only the total has
answered a question nobody asked, while reading as though it answered the one they did.

**It is stated once for the plan, where everything below is stated per phase.** The difference is
when each is needed: a worktree command is wanted at the moment its phase is executed, an estimate
at the moment the plan is approved. And the facts that decide the calendar sit between the phases
rather than inside any one of them — what unblocks what, which sitting a boundary falls on — so they
have no per-phase row to live in. A plan whose estimate is spread across its phases makes every
reader add it up.

**An estimate is not a status.** It is a judgement recorded once, at approval, and never revised:
nothing derives from it, and it does not become wrong when the work slips — it becomes a thing worth
knowing. What the work actually took belongs to the closing report, not to this table.

## Every plan is drafted to be warped

Assume approval is the last check-in and the plan runs straight through to production — so anything
the executing session would otherwise come back and ask about belongs in the plan. Concretely: the
branches and worktrees and the merge order, the migrations and the secrets or resources to set, the
deploy targets, how to verify each step, and which steps are irreversible enough to stop and ask.

**All of that is stated per phase, not once for the plan.** A milestone is executed and unwound
phase by phase, so a plan that states its worktree, its rollback and its verification globally still
sends the executing session back to ask. Each phase names:

| | |
|---|---|
| Summary | see below |
| Worktree | the command that creates it and the command that removes it — or `as Phase <n>`, where the work continues in an earlier phase's tree |
| Pre-phase SHA | the exact commit this phase can be rewound to, filled in when the phase begins. Until then, the phase whose commit it will be: for every phase after the first, that commit does not exist when the plan is written |
| Deploys to | what changes in the world when this phase lands, or "nothing" |
| Door | **one-way** or **two-way**, and what makes it one-way. One of `warp.md`'s four — a publish, a destruction, money above noise, a credential that cannot be recovered — or nothing, which is two-way |
| Work | what is done |
| Verify | how the phase is known to have worked — a command, not an inspection |
| Undo | the one command that reverses it |

**That is the form, not an illustration of one.** Those rows, those names, under the phase heading
and ahead of the work. A phase whose fields are spread through its prose holds the same facts and
can be read by nobody but a person, which is the difference between a plan that can be tracked
while it runs and one that has to be re-read to be known.

**No row is absent, and `none — <why>` is the answer when there is nothing to name.** A stated
`none` is a decision on the record; a missing row cannot be told apart from a field nobody
considered. A phase with nothing runnable to verify says that, rather than leaving the row out.

**`Door` is not `Undo` restated, which is why it is a row of its own.** A phase can carry a working
`Undo` and still be one-way: reverting the merge that published a package does not unpublish it, and
`git revert` on a destructive migration restores the schema and not the rows. `Undo` names the
command that reverses the change; `Door` says whether reversing the change reverses its *effect* —
the one fact deciding whether the phase is one of `warp.md`'s four and stops for the owner. A
one-way phase names what makes it one-way, so the stop is visible at approval rather than discovered
at the merge. The honest answer is sometimes both halves at once: a public merge whose text
`git revert` restores exactly is one-way on the publication and two-way on the content, and that is
the distinction the row exists to carry.

**A phase table acquires its `Door` row when its document is next touched.** Sweeping every plan
already written is the work this rule removes, and a table written before the row existed is a
record of what was required then rather than a defect to fix. The row is required of the document
being written, which is the only one anybody is reading.

**Every phase opens with a brief executive summary**, in the voice the section above asks the plan's
own summary for: what is broken, what changes, what it costs, what the risk is, written for an
architect who does not know this codebase. A plan is read and approved phase by phase, so a summary
that exists only at the top is not available at the moment anyone needs it.

**A code task raised in planning mode is a warp-ready plan.** Not a sketch to discuss and then
re-plan, and there is no lighter form for a small change: a plan that does not carry the fields above
per phase is not a plan yet.

## Every completed phase reports what it accomplished, not only what was done

A phase ends with a report — said in the session that ran it and written into the plan document the
next one resumes from — and the first thing in it is **what is now true that was not true before**,
put so that someone who will never open the diff can tell whether the phase was worth running. The
files, the counts, the commands and the gate results follow, and they are the *evidence* for that
sentence rather than a replacement for it.

Each phase was approved against an executive summary saying what would be true when it was done.
**The report answers that same sentence in the past tense**, which is what makes this checkable
rather than a matter of taste: a report that cannot be lined up against the summary that authorized
the work is answering a question nobody asked.

**A report of only *how* fails as a plan of only *how* fails**, and it fails later, where it is
dearer to fix: an inventory of files touched, tests green and lines written reads as complete, so
nobody asks what the phase bought, and a phase that built the wrong thing correctly is
indistinguishable from one that did not. A gate result is not an accomplishment — "every test green,
the type-checker clean" says the work is admissible, not that it achieved anything — and a report
whose first paragraph is made of those leaves the reader to reverse-engineer the goal out of the
remediation, which is the same defect the plan's own summary is held to above.

**The outcome is a distinct part of the report, not a sentence distributed through it.** A reader
assembling it out of an itemized list is doing the work the report exists to have already done.

**A phase whose outcome is not visible from outside the code says so, and says what it unblocks** —
the same answer `none — <why>` gives above. Scaffolding, an extraction, a migration nothing consumes
yet: the accomplishment is then that the next phase can be built on it, which is a claim that can be
wrong and is therefore worth writing down.

## Every plan sets up its own worktree, and names it as its first step

A plain `git worktree add -b <branch> <path> origin/<deploy-branch>`, created before the plan's first
edit and removed at cleanup. A plan that does not name its worktree is not ready to execute.

**Never edit in a standing checkout.** A standing checkout is what a machine runs, what another
session may be mid-change in, and what a deploy fast-forwards — an edit there is live before anyone
has reviewed it, and a branch switch takes whatever reads that tree with it. Run
`git branch --show-current` before the first edit, not after the last.

## Every plan has a Rollback section

The exact pre-deploy commits or tags of each deploy branch, which merge commits to revert, whether
the migrations are additive, what secrets or resources were added, and the commands that undo it. A
plan without one is not ready to warp.

**Every phase is reversible on its own.** A phase that cannot be undone is split until it can, or it
stops and asks. Ordering is itself a rollback property: sequence the phases so the thing being
replaced is still in place until its replacement is proven, and so the irreversible step is last.
