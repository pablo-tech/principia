---
name: warp
description: The delegation mode. Say "warp" to take an approved plan from approval to deployed product with no further check-ins — what that authorizes, the four things it still stops for, why blast radius is read off the declared trigger rather than off your diff, why a procedure handed to a person is reduced to one act, the mark it starts with and the report it ends with.
---

# Warp

*Delegation is only useful if its edges are fixed in advance.*

**Named:** mission command — Helmuth von Moltke, *Verordnungen für die höheren Truppenführer*
("Instructions for Large Unit Commanders"), 1869. The principal–agent problem — Michael Jensen and
William Meckling, "Theory of the Firm: Managerial Behavior, Agency Costs and Ownership Structure",
1976. [Lineage](../LINEAGE.md#mission-command--moltke-1869).

**"warp" means: take the plan from approval to deployed product with no further check-ins.**
Commit, push, open and merge the pull requests, run the migrations, set the secrets, deploy to
production, and make every decision along the way by best judgement. The authority is delegated at
the moment the word is said, and it overrides a standing "don't commit or push unless I ask".

A warp is scoped to one approved plan. It is not a standing grant, and it does not carry into the
next request.

**A warp marks its start in that plan, naming the phases it covers.** The report at the end says
what happened; without a mark at the beginning, nothing in the record says when the work began, and
no duration is recoverable from it afterwards — the branch and the pull request are both created
late, so neither one dates the work.

## What it still stops for

Warp covers reversible work. Four things are not reversible, and each one stops and asks however
small it looks:

- **Publishing externally.** Making a repository public, publishing a package, posting to anything
  the world can read. A minute of public is public forever; indexing and forks do not honour a
  reversal.
- **Destroying data.** Destructive migrations, dropping a table, deleting a bucket or a repository.
- **Spending money above noise.**
- **Losing a credential irreversibly.** This is the only one that is about *reading* rather than
  writing, and it cuts the other way: a warp is explicitly authorized to read credentials, and to
  commit one to the repository that holds them. It stops only where a later step could not recover
  the value. The ordering that follows is: salvage the credential first, then delete whatever held it.

**An automated action fires on its declared condition, not on what you think you changed.** Where
merging to a branch runs a release job, that merge belongs to the owner however small the diff, and
*the diff not touching the published artefact is not an exemption* — the job keys on the push, not on
the paths. The general failure is an **automation surprise**: the operator's model of what an
automated system will do diverges from what it will do, and the divergence is discovered by the
system acting (Nadine Sarter and David Woods, "How in the World Did We Ever Get into That Mode? Mode
Error and Awareness in Supervisory Control", *Human Factors*, 1995). That literature is about a
running system whose state the operator cannot see, and here every trigger's condition is declared,
static and readable before the merge — which makes the remedy cheaper than anything it proposes and
the failure less forgivable. **Read the declaration.** Blast radius is read off the mechanism, and
"this change could not possibly have published anything" is a prediction about a trigger rather than
a fact about a diff.

## A procedure handed to a person is not a transaction

A warp that cannot take a step itself hands it over, which is delegation at its narrowest — and what
has to be fixed in advance there is not the intent but the **shape**. A sequence of steps carries no
all-or-nothing guarantee: the second step runs after the first has failed, so a guard on the first
step protects that step and nothing after it, and partial execution is a state nobody designed while
the real world has already moved. That is **atomicity** and its absence (the A in ACID — Jim Gray,
"The Transaction Concept: Virtues and Limitations", 1981).

**The departure is that rollback is not available**, because the earlier steps were performed rather
than recorded. So the available form of atomicity is not recovery but **irreducibility**: reduce the
handover to one act whose partial execution is not a meaningful state, and put the sequence behind
that act, where it either runs or does not. That is a **forcing function** — design the task so the
wrong action is impossible rather than discouraged (**poka-yoke**: Shigeo Shingo, *Zero Quality
Control: Source Inspection and the Poka-Yoke System*, 1986; named for design generally by Donald
Norman, *The Psychology of Everyday Things*, 1988). It is also why a procedure valid in only one
place names that place *inside* the act rather than in the prose above it: prose does not travel with
a copied line. Length is the variable that decides all of this, which makes brevity a control rather
than a courtesy, and review before handover is the only holder there is — the failure happens in
someone else's terminal, past the last point anything here can see.

## Working around other sessions

Sessions run in parallel, so no session's work waits on another's checkout. A shared checkout often
holds someone else's uncommitted work, sometimes on its own branch. Leave it exactly as found and
say nothing about it: it is not the warp's to commit, stash, revert or report. Route around it — the
warp's own work happens in a separate worktree off the deploy branch, which is a plain
`git worktree add`, no coordination and nothing to wait for.

A session that finishes by reporting itself blocked on where someone else parked a checkout has not
finished.

## The closing report

A warp ends with a report: an **Executive Summary** first, then the itemized list of what was done,
the decisions made, how to test it, and the rollback.

**The Executive Summary is written for an architect who does not know this codebase** — no
continuous-integration, web or product implementation background assumed. What was broken, what it
cost, what changed, what it costs now, and what is still open. Name a tool or a file only when the
sentence fails without it, and spell out any acronym the first time. The itemized sections below it
stay as technical as they need to be; the summary is the part someone can act on without reading them.

**The summary says what it took against what was estimated.** The plan carries a per-phase estimate
and a sentence on the shape of the calendar (`planning.md`); the report answers it — the hours, the
number of sittings, and where it diverged, why. A warp marks its start so that a duration is
recoverable at all, and this is what the mark is for. An estimate nothing ever grades is decoration,
and the next plan's is written by somebody with no record of how the last one went.

**The report is filed, not just printed.** A warp confined to one repository updates that repository's
own planning document with the outcome, and *that* is the record — no second file. A warp spanning
several has no such home and is filed once, under a dated path, report first with the approved plan
below it. Either way the scratch plan goes: it is working material, not a record, and leaving the
outcome only there files nothing.

The report is what happened; a planning document is the intent. A lesson meant to outlive the warp
belongs in the planning document it concerns, not restated in the report.

## Cleanup

Once the goal is deployed and verified, remove the warp's worktrees and delete its local and remote
branches. A merged branch left behind is noise the next session must re-audit.

**A worktree or branch outliving the merge of its phase is a finding, named with its age.** That is
not "Working around other sessions" reversed: a checkout holding live work is left alone and
unremarked, and what makes this the other case is that the phase has landed. What is left is
residue, and residue nobody names reads as work in progress for as long as it sits.
