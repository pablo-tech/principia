---
description: Snapshot one phase's progress into the plan document, then prompt a /clear so the next phase starts on a fresh context.
---

You are closing out one phase of a plan. The point is to end this session's context growth here: a
long-running session re-reads its whole transcript every turn, and past the long-context tier that
costs double. The plan document is the handoff artefact, and the next phase resumes from it in a
fresh session.

Do this now:

1. Identify the plan document this session has been working from. It lives where
   `protocol/doctrine/planning.md` says a plan lives. If more than one could be meant, ask which.

2. Append or update a short **Progress** entry in it, carrying only what a fresh session needs to
   continue. Not a transcript:
   - which phase just completed, and **what it accomplished** — what is now true that was not
     true before, answering that phase's own executive summary in the past tense. First, in a
     sentence or two of its own; `protocol/doctrine/planning.md` says why a list of files touched
     and gates passed is not this
   - how that is known: the gate result, the commit SHA, what deployed — in this entry's prose, and
     not typed into a phase row that means something else. `Pre-phase SHA` is the commit the phase
     rewinds to and nothing else; the phase is named in the pull request instead
     (`protocol/doctrine/git.md`), so a pull-request number copied into the plan is a second copy of
     what the forge already answers
   - the exact next phase, and its first concrete step
   - any decision or gotcha found this phase that is not already written down
   - `file:line` anchors for where the next phase starts

3. Leave committing to whoever asked for the work, unless they have already said otherwise.

4. Then say what the phase accomplished in one sentence — the outcome, not the file list — and
   that the phase is snapshotted and they should run `/clear` before starting the next one, which
   you cannot run yourself.

Keep the edit tight. Do not re-read large source files to write it: this session already holds what
it needs.
