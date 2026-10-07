# principia

*principia — first principles: the statements a body of work is derived from rather than argued
from. Written once, kept apart from the work, belonging to none of it. More on the name
[below](#on-the-name).*

[![CI](https://github.com/pablo-tech/principia/actions/workflows/ci.yml/badge.svg)](https://github.com/pablo-tech/principia/actions/workflows/ci.yml)
[![Community Health](https://img.shields.io/badge/dynamic/json?url=https://api.github.com/repos/pablo-tech/principia/community/profile&query=$.health_percentage&suffix=%25&label=community%20health)](https://github.com/pablo-tech/principia/community)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A working standard — that a plan opens with a summary saying why, that a test must be able
to fail, that large files never enter history — is usually written into the file an AI coding agent
reads. Those three are real rules, they are written down here, and they are the subject of the
first half of this page. The second half is about the file they are usually kept in, **which is the
one place a standard cannot hold.**

> **New here?** [`START-HERE.md`](START-HERE.md) has two ways in: ten minutes reading, or ten
> minutes running it.

## The doctrine

The documents under [`doctrine/`](doctrine/), indexed for an agent by [`AGENTS.md`](AGENTS.md)
and for a person by [`doctrine/README.md`](doctrine/README.md). They are the whole of the
protocol — everything else in this repository installs them or enforces them.

Each is written as a forcing function rather than as advice: a rule shaped so the failure it
prevents either cannot happen or announces itself while it is still cheap to fix. A reminder is
the other thing, and a control that depends on remembering costs nothing until the hour it
matters.

| Document | What it holds you to | Named from |
|---|---|---|
| [`planning.md`](doctrine/planning.md) | "Every plan opens with an executive summary." | pre-registration — Nosek and colleagues, 2018 |
| [`testing.md`](doctrine/testing.md) | "A test must be able to fail." | falsifiability — Popper, 1934 |
| [`clean-code.md`](doctrine/clean-code.md) | "The same fact or logic in two places will drift, and one of them becomes a lie with no signal which." | don't repeat yourself — Hunt and Thomas, 1999 |
| [`git.md`](doctrine/git.md) | "Large files live in object storage. Repositories keep information extracted from them, never the files themselves." | the end-to-end argument — Saltzer, Reed and Clark, 1984 |
| [`as-built.md`](doctrine/as-built.md) | "A document found to disagree with the system is corrected in the change that found it." | stop the line — Ohno, 1978 |
| [`warp.md`](doctrine/warp.md) | "Take the plan from approval to deployed product with no further check-ins." | mission command — Moltke, 1869 |
| [`tenancy.md`](doctrine/tenancy.md) | "The ordering matters more than the list. A great deal of effort is commonly spent on 3 while 1 is quietly violated, which buys nothing." | complete mediation — Saltzer and Schroeder, 1975 |

**The third column is a condition of entry, not a bibliography.** A rule is admitted to `doctrine/`
only when it can be named as an instance of something the wider field already knows *and* attributed
to a specific prior work — author, title, year, in the form the field recognizes it by.
[`INDUCTION.md`](INDUCTION.md) is the argument for why that is the expensive condition and the
register of the full lineage; each document prints its own citation directly under its opening line;
and `bin/induction.test.sh` refuses a tree where a document, a row above, or a register row names no
dated work. It is also the fastest way to audit this list from outside: every rule here points at
something older than this repository, and the day one does not, the document has to say in as many
words that no prior work was found.
[`LINEAGE.md`](LINEAGE.md) is where each of those names answers for itself: one entry per work, with
the full citation, what the work claims at its own scope and in its own field, and what that field
says against it — which is the half `INDUCTION.md` promises when it admits a rule because the name
"imports the counter-arguments", and the half this repository owed on forty of forty-one names.

Quoted like that the rules read as slogans, which is the failure mode of every list of principles.
Two of them worked out show what the shape is actually doing.

**"A test must be able to fail."** The sentence is unremarkable until you ask what its opposite
looks like in practice, because a test that cannot fail does not announce itself — it reports
green, which is the one signal nobody re-examines. So the rule arrives with a procedure attached:
write it red first, and when a suite written before its implementation reports some checks
already passing, *those* are the checks to distrust. A check that has never been red is telling
you about its own construction and not about the code. That turns an unfalsifiable claim about
quality into a moment with an observable answer.

**"Corrected in the change that found it."** The part people argue with is not *correct the
document* but *now*. The argument is about evidence: whoever found the discrepancy has the system
in front of them, knows what they ran to see it, and knows which of the two is right. An hour
later that is a question someone has to re-open. A week later it is archaeology, and the usual
outcome is that the document is left standing because nobody can still prove it wrong. Deferring
the fix is what converts a five-minute edit into a permanent inaccuracy.

The rest, with the same treatment, are in
[`doctrine/README.md`](doctrine/README.md); [`AGENTS.md`](AGENTS.md) is the table of which one to
open before a particular piece of work. They are one practitioner's and they are opinionated:
disagree with one, rewrite it in your fork, and nothing else here breaks.

## A doctrine only holds if it travels

The rules above are ordinary enough that most people writing them down put them in the file their
AI coding agent reads. That is where a standard gives way, in two directions at once.

**It is not portable across agents.** The file is named for one vendor's tool. A second agent on
the same machine reads nothing, so the rules are copied into its configuration too, and now the
same rule exists twice and drifts — the defect `clean-code.md` names, committed by the document
that names it. Worse, the rules only ever bound *that* agent: a diff written by a different
agent, by an editor, or by hand passes every one of them untouched.

**It is not separable from the work it was written beside.** The same file that holds *how work is
done* holds *whose work it is* — which repositories exist, where credentials live, which account
is which. The moment the standard is worth having in a second place, there is no way to hand over
the first half without the second.

The obvious fixes each fail:

- **Copy the rules into each repository.** Now every repository has its own copy of the working
  standard, and they disagree within a month. One of them is a lie and nothing says which.
- **Ship it as a plugin for the agent you use.** That fixes distribution and deepens the lock-in:
  the protocol now requires that vendor to be installed to exist at all, and still says nothing
  about a commit made by anything else.
- **Keep it in the agent's configuration and just be careful.** This is what fails in practice,
  and it is the reminder the doctrine is written against.

**So this repository is the doctrine as plain documents, plus the commit-time guards that enforce
the part a machine can judge.** The documents are markdown; the entry point is `AGENTS.md`, the
filename most AI coding agents already read, and any agent that does not still reads it when told
to, because it is prose. The guards are shell scripts that run from a repository's `pre-commit`
hook — the one gate every route to history passes through, whichever agent, editor or hand wrote
the diff.

Nothing here knows who you are. A **tenant** — whoever a given body of work belongs to — keeps its
own context repository with its own facts and its own denylist, and installs this one into it.
Two tenants share every word of the doctrine and not one word about each other.

### One file, two readers

Each doctrine file carries exactly two lines of frontmatter, `name` and `description`. That is the
whole of what one agent's skill format requires, and it is inert to every other reader — a person,
a different agent, a diff. So the installer wires a skill as a **symlink to the doctrine file**,
never a copy of it:

```
<tenant>/skills/warp/SKILL.md  ->  ../../protocol/doctrine/warp.md
```

Edit the doctrine, and the agent's skill changed, because there was only ever one file. This is
the shape the whole repository is built around: adapters point a tool at the protocol and never
copy configuration out of it. Delete every adapter and the protocol is intact —
[`adapters/README.md`](adapters/README.md) states that as the contract each one is held to.

### A rule, from written to enforced

One rule, followed from the sentence a person can disagree with to the commit a machine refuses.
This is not "how to install it"; it is the argument for why the doctrine is a repository with a
guard attached rather than a well-written page in your agent's config.

**Scenario.** `doctrine/git.md` says large files never enter history. A 40 MB export lands in a
working tree, and the person — or the agent — about to commit it has not read that document.

**Before.** Written into an agent's configuration, the rule holds exactly as long as the agent
that read it is the thing making the commit. It says nothing about `git commit` in a terminal, an
editor's commit button, or the next tool nobody here has heard of. The usual fallback is a
server-side push limit, which is the wrong end of the trade — see step 2.

**After.**

1. **The rule, as a sentence.** [`doctrine/git.md`](doctrine/git.md): *"Large files live in object
   storage. Repositories keep information extracted from them, never the files themselves."* The
   ceiling is 25 MB per file. It is prose in a markdown document, and anyone may disagree with it.

2. **Why the ceiling sits at commit and not at push.** GitHub hard-rejects any blob over 100 MiB,
   and by the time a push is refused the blob is already in local history — the branch stays
   unpushable until history is rewritten, which costs a force-push to every branch carrying it.
   Refusing the commit costs one retry. This is the reasoning in the document, not in the script.

3. **The guard that enforces it.** [`guards/size-guard.sh`](guards/size-guard.sh) measures the
   blob *as staged* (`git cat-file -s ":$path"`) rather than the file on disk, because the index
   is what a commit would record. It is one script; every repository carries a thin
   `.githooks/pre-commit` shim that calls it, so the threshold changes in one place.

4. **The commit it refuses.**

   ```
   pre-commit: refusing to commit file(s) over 25 MB:
     40 MB  data/export.csv
   pre-commit:   keep only what you extract from the file, not the file.
   pre-commit:   unstage with:  git restore --staged <path>
   pre-commit:   if it is a build artifact or dependency, gitignore it instead.
   ```

   The guard read the diff, not the conversation. Whether an agent, an editor or a person staged
   that file makes no difference to it.

5. **The same file reaching a second agent.** With the tenant as the configuration directory, one
   agent lists `git` among its skills; point a second agent at its own adapter directory and it
   reads the identical file, because step 2 of an install makes links and not copies. An agent
   with no adapter at all still gets the doctrine, as `AGENTS.md`.

6. **A second tenant, and then a change.** A new tenant starts from
   [`tenant-template/`](tenant-template/) and runs `bin/adapt` from inside itself; it now has the
   same rule and the same guard. Raise the ceiling in `doctrine/git.md` and `guards/size-guard.sh`,
   both tenants pull their protocol checkout, and every agent in both has the new number. Nothing
   was copied, so nothing can disagree.

   ```bash
   git init my-context && cd my-context
   cp -r ~/principia/tenant-template/. .
   ~/principia/bin/adapt
   ```

   `bin/adapt` symlinks this repository in as `protocol/`, gitignores that path because it is
   machine-local, seeds any template file the tenant lacks, points `core.hooksPath` at
   `.githooks`, creates `~/.principia` as the well-known path the shim falls back to, and
   wires whichever AI coding agents the machine has. Run it twice and the second run installs
   nothing — every line is a `skip`, save the `record` that writes down which commit of this
   protocol the files came from, and which writes the same bytes from the same commit.

**The point.** Step 4 binds a diff written by hand, by an editor, or by an agent that does not
exist yet — none of which is reachable from inside one agent's configuration file. Step 5 is the
same bytes in two tools with no second copy to drift. And step 1 is still a sentence in a markdown
file that you can disagree with and fork, which is the half a guard cannot give you.

The tenancy rule works the same way and is the reason the template ships a denylist:
`.protocol/tenant` takes one extended regular expression per line — the *other* tenants' names,
and the identifier shapes that are always somebody's infrastructure. It is never an allowlist of
this tenant, because nobody can enumerate in advance every term their own work will legitimately
contain, and a control that refuses unfamiliar material is one people bypass on the first false
refusal. A repository that will itself be read by others keeps the proper nouns in an untracked
`.protocol/tenant.local` and publishes only shapes, since a denylist read backwards is a list of
what the repository is protecting — [`ARCHITECTURE.md`](ARCHITECTURE.md) §3.

## What is in here

| Path | What it is |
|---|---|
| [`doctrine/`](doctrine/) | the protocol itself, and nothing else is normative — [`doctrine/README.md`](doctrine/README.md) is what each document holds you to |
| [`INDUCTION.md`](INDUCTION.md) | what it takes for a rule to be admitted to `doctrine/`: named in the strongest form the field states it, cited to a specific prior work, with a register row per document and a departure where this repository takes the weaker version |
| [`LINEAGE.md`](LINEAGE.md) | one entry per work the doctrine is named from, grouped by the literature it was earned in: the full citation, what the work claims at its own scope, what its own field says against it, and the rule here that leans on it. Not doctrine — it holds no rule and loses to a doctrine document wherever the two disagree |
| [`AGENTS.md`](AGENTS.md) | the entry point an agent reads: which document to open before which piece of work |
| [`guards/`](guards/) | the commit-time enforcement: file size, credentials, tenancy, and the identity a commit is made as |
| [`bin/adapt`](bin/adapt) | the installer, idempotent, `--copy` for a machine that will not follow symlinks |
| [`adapters/`](adapters/) | one small directory per AI coding agent, each holding `detect.sh` and `adapt.sh` |
| [`tenant-template/`](tenant-template/) | the files a new tenant starts from, each one a seed to edit |
| [`bin/doctor`](bin/doctor) | run inside a tenant: which protocol it is on and how far behind, the symlinks, the hook, the denylist and each installed launcher, checked against what is on disk. Run against a repository worked on under a tenant (`--in <dir>`), the same questions with the answers that shape has: the guards its shim resolves instead of a `protocol/` it is not supposed to carry, and the tenant's identity list it is held to |

A guard reads its policy from a file the *tenant* carries under `.protocol/`, and a guard whose
policy file is absent exits 0. That is what makes one shared chain safe to point at any checkout:
a repository opts into a rule by carrying the file that configures it, never by being recognised
by name from inside the guard. [`ARCHITECTURE.md`](ARCHITECTURE.md) is the contract for all of it.

## What this does not catch

**Most of the doctrine is not machine-checkable, and is not meant to be.** Two of the rules have a
guard behind them — the size ceiling and the tenancy declaration. The rest are held by whoever
reads them, which is the ordinary condition of a standard: no script judges whether a plan's
summary says why rather than only how.

**It gates commits, not reads.** The guards run at `pre-commit`. Nothing here stops an agent from
*reading* another tenant's files, or from putting their contents in a prompt that leaves the
machine. If a tenant's material must not be readable at all, it must not be on the machine —
absence is the only control that survives an adversary with root, and on a device someone else
manages that adversary is the device.

**A symlinked adapter does not survive a centrally-managed configuration directory.** `--copy`
exists for exactly that machine, and it buys back the drift that symlinks eliminate: a copied
doctrine file is a copy, and it goes stale the moment the protocol moves. Re-running `bin/adapt`
is the only thing that refreshes it, and nothing reminds you.

**A denylist is a filter, not a proof.** It catches the terms you thought to write down, spelled
the way you wrote them. It will not catch a tenant described without naming it, a paraphrased
figure, or a screenshot. `--scan-tree` narrows this by auditing the whole tree rather than one
diff, and `--no-verify` widens it back to nothing.

**Permission rules constrain an agent, not a machine's owner.** An adapter can tell one tool which
commands to refuse. It cannot stop device management software, a backup agent, or anyone with
administrative access to a machine from reading what is on its disk.

**Nothing here is a secret store.** The credentials guard refuses to let a secret *into* a commit.
Where secrets actually live, and how they reach a process, is the tenant's problem and belongs in
the tenant's own documentation.

## On the name

*Principia* is the plural of *principium* — a beginning, the thing something starts from. Used of a
text it means the first principles of a subject: the statements the rest is derived from rather
than argued from. That is what [`doctrine/`](doctrine/) is, and §1 of
[`ARCHITECTURE.md`](ARCHITECTURE.md) is what keeps it that — a rule is admitted only if it would
still be true if every model on the machine were replaced tomorrow, the same admission test that
keeps any one tenant's facts out.

It is a name about the content rather than about whoever wrote it, which is the right way round for
the one repository here that owns no tenant's facts. Everything that names a person, a machine or
an account lives in a tenant; this travels between them and belongs to none of them.

**Cost accepted:** the word is not unsquatted — Newton's *Philosophiæ Naturalis Principia
Mathematica* is what most readers meet first, and there is no using the word without borrowing a
little of that. It is Latin, so it needs the gloss above, once. What it buys is a title that states
what is in the repository, which is a claim the contents can be held to.

## License

MIT — see [LICENSE](LICENSE). The protocol documents under `doctrine/` are covered by the same
licence as the code: take them, fork them, rewrite them for how your own work is done.
