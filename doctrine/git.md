---
name: git
description: Commit and branch discipline — who decides to commit and push, what a commit message says, what a pull request declares about the phase that authorized it, how a promotion works, why the file-size ceiling is enforced at commit rather than push, and why every repo-scoped command names its repo.
---

# Git

*A gate placed after the irreversible step is a gate paid for twice.*

- **Don't commit unless asked. Don't push unless asked.** A warp lifts both for the scope of one
  approved plan, and nothing else does.
- Never use `--no-verify`, `--force`, or `--amend` on published commits without asking first.
- Commit messages: imperative mood, one line, focused on *why* rather than *what*.
- **Every repository-scoped command names its repository** — `gh -R owner/repo`, `git -C <path>`,
  `repos/owner/repo/...` for an API call. This includes commands handed to a person to run, which
  may execute outside any checkout. A command that relies on the current directory is a command that
  eventually runs in the wrong one.

## Branch protection does not have an organization-wide default

GitHub has no organization-wide default for branch protection, head-branch deletion, labels or
required checks, so every repository drifts alone. The answer belongs in one declarative file that a
script reconciles, run after creating a repository or an organization — not re-decided per repository.

## A pull request names the phase that authorized it

**The body opens with the phase, as a fenced `json` block, and quotes that phase's executive summary
beneath it.** Six fields, every one of them fixed when the phase was approved:

```json
{
  "plan": "planning/<repo>/<path>.md",
  "phase": "<the phase's label>",
  "pre_sha": "<the commit this phase rewinds to>",
  "verify": "<the phase's Verify row, verbatim>",
  "undo": "<the phase's Undo row, verbatim>",
  "door": "<the phase's Door row, verbatim>"
}
```

`plan` is the path as it is written in the context repository; `phase` is the `<n>` of the `Phase <n>`
heading `planning.md` already refers to a phase by. One phase per pull request, and a phase spanning
repositories has one in each.

**Two parts, because there are two readers, and no fact is in both.** The block is for whatever has to
find this later without a person; the quotation is for the person. Recovering six facts out of prose
means agreeing on heading depth and emphasis markers, and that agreement then has to become doctrine
to be relied on — which writes one implementation's current tolerances into a rule. A fence has no
tolerances. Equally, an executive summary inside a JSON string is readable by nobody, which is why it
is the one field that stays prose.

**The summary is quoted and not linked.** The reviewer is in the forge with the diff in front of them
and the plan is in a different repository they may not be able to read, so a link resolves to nothing
for the one audience that needs it. A plan is also edited after approval where a body is dated by the
forge, so a quotation pins what was approved while a link silently re-points at whatever the claim
later became. `planning.md` already holds a phase's report to answering that summary in the past
tense; this is the same comparison, made at the one moment the diff can still change and the evidence
for it is on screen.

**`verify` and `undo` are the phase's own rows, copied rather than written again** — they are the how
to test and the rollback, and a pull request stating different ones has either found a defect in the
plan, which is fixed in the plan and then copied, or is improvising. This is where the rule bites
rather than in naming the phase: a phase whose `Verify` is an inspection instead of a command, or
whose `Undo` was never run, has no string to put in the field, so the defect announces itself to
whoever opens the pull request — before review, while the plan is still cheap to change. `door` is
copied under the same rule and is the half of it a machine can act on: `verify` and `undo` are
commands, and whether the phase can be taken back at all is neither — a phase with a working `Undo`
can still be one-way, which is the distinction `planning.md`'s row carries. A one-way phase is one
of `warp.md`'s four, so the field is how that stop reaches the reviewer before the merge rather
than at it.

**Nothing else from the phase goes in the block, and particularly not how the phase is doing.**
Whether it has landed, whether its checks pass, how old it is, which worktree is dirty, who is working
in it: all of that is computed from the repository and the forge whenever it is asked, and a body is
written once and never revised. A status copied into one reads as current for as long as the pull
request exists, which is the hand-typed status line `planning.md` refuses, in a place nothing can
correct it.

**A pull request with no phase behind it declares that, and says what brought it into existence
instead** — `"phase": null` with `"reason": "a dependency bump"`, `"a failing check"`, `"asked for
directly"`. That is `planning.md`'s `none — <why>` as a field, for its reason: one that is never
optional cannot be read as one nobody got to. A repository shared by tenants and owned by none is the
standing case, a plan path being a tenant's fact that does not travel to it. Such a declaration
carries no `door` either: a door is a property of a phase and there is no phase, so the field goes
with the `plan` and the `phase` it was copied from, and the `reason` is what the reviewer reads in
its place.

**Why the pull request and not the branch.** A phase is otherwise tied to its work by the branch its
`Worktree` row creates, and `warp.md` deliberately destroys that key: the worktree is removed and the
branch deleted locally and remotely once the phase is deployed. A branch name is unique only inside
one repository, so nothing resolves one afterwards by searching either. The pull request and the merge
commit are what outlive cleanup, which is why the declaration goes in the one of them a person writes
— and why the reverse direction is a query against the forge rather than a number copied back into the
plan.

## Promote whole, never by cherry-pick

A promotion merges all of the source branch, and only once that branch is clean: checks green,
nothing unsoaked or half-done. If part of it is not ready, fix or revert it on the source branch
first. A cherry-picked target branch diverges, and the next whole promotion conflicts.

## Heavy files: a ceiling enforced at commit

**Large files live in object storage. Repositories keep information extracted from them, never the
files themselves.** Build artefacts and dependencies get ignored rather than moved — they are
neither records nor information.

The ceiling is 25 MB per file, enforced by [`guards/size-guard.sh`](../guards/size-guard.sh). That
script is the single source and every repository carries only a thin `.githooks/pre-commit` shim
that calls it, so the threshold changes in one place. Do not copy the logic into a repository.

**Why at commit rather than at push:** GitHub hard-rejects any blob over 100 MiB, and by the time a
push is refused the blob is already in local history — the branch then stays unpushable until history
is rewritten, which costs a force-push to every branch that carries it. Refusing the commit is the
cheap end of that trade.

`core.hooksPath` is local configuration and does **not** travel with a clone. On a fresh clone:
`git config core.hooksPath .githooks`. The shim fails closed if the guards cannot be found.
