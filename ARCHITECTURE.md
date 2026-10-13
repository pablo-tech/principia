# Architecture

This is the contract, not a tour. [`doctrine/README.md`](doctrine/README.md) is what the rules
say, [README.md](README.md) argues why they are a repository rather than a page in an agent's
configuration file, and this file states what a consumer may rely on — so that a change which
breaks one of these statements is a breaking change and is announced as one. Sections are numbered
so prose elsewhere can cite §4.

## 1. The protocol is `doctrine/`. Everything else installs it or enforces it

The documents under `doctrine/` are the only normative content. `AGENTS.md` indexes them for an
agent and `doctrine/README.md` for a person; that index is the file beside them in the directory
and is not itself doctrine (§7).
`guards/`, `bin/` and `adapters/` are mechanism: delete all three and the protocol still exists as
documents, which is the property the whole design is arranged to preserve.

A doctrine file carries exactly two frontmatter keys, `name` and `description`, and no others.
That is the minimum one agent's skill format requires and it is inert to every other reader, which
is what lets a skill be a symlink to the doctrine file rather than a copy of it. **Adding a third
key is a breaking change**: it is the contract that makes one file serve two readers.

Doctrine is tenant-free. It may name this repository and its owner and nothing else — no tenant,
no machine, no account. §10 is the check that holds this.

Doctrine is model-free. A rule is admitted only if it would still be true if every model on the
machine were replaced tomorrow. A claim about how a model behaves is a measurement — true on a date,
of a generation — and belongs in a dated finding in the tenant that measured it, not here, where it
would inherit the authority of a rule with a twenty-year half-life and be shared with every tenant
that never measured it. §10 is the check that holds this one too.

Doctrine is named and cited. A rule is admitted only when the document carries the principle it
instantiates, in the strongest form the wider field states it, **and the specific prior work it is
named from — author, title, year — printed on a `Named:` line under the document's opening line and
again in `README.md`'s table of the doctrine**. A practice area is not a citation. Every document
under `doctrine/` also has a row in [INDUCTION.md](INDUCTION.md)'s register, which carries the full
lineage and where this repository departs from it. That file is the terms of admission and the
argument for them; `bin/induction.test.sh` refuses a tree where a document has no `Named:` line, no
register row, or where that line, its README row or its register row names no dated work. A consumer
may rely on this: a rule here is either traceable to a work older than this repository or says in as
many words that no prior work was found.
The fourth place is [LINEAGE.md](LINEAGE.md), one entry per work rather than one row per document,
and a consumer may rely on that too: every name a document is admitted on has an entry carrying that
work's own scope and a dated objection from its own field, or the claim in as many words that none
was found, and the same suite refuses a tree where an entry has neither.
[REFUTATION.md](REFUTATION.md) is the same accounting after the fact: where a rule here was stated or
applied and failed. It is not doctrine and holds nothing, and what a consumer may rely on there is
narrow — every entry names a commit this repository contains, and `bin/refutation.test.sh` refuses a
tree where one does not, which is what makes an entry a claim somebody can check rather than a note
about a bad day. That an entry exists for any given rule is not a claim, and the page says so.

## 2. The tenant is the unit

A tenant is whoever the work belongs to. Each has one context repository, and that repository
carries five things, all of which `bin/adapt` installs:

| Path | What it is | Who owns it |
|---|---|---|
| `protocol/` | this repository, symlinked; gitignored, being a machine-local path | the installer |
| `AGENTS.md` | the tenant's own facts, and a pointer to `protocol/AGENTS.md` | the tenant |
| `.protocol/*` | one file per guard policy the tenant opts into (§3) | the tenant |
| `.protocol/protocol-version` | which commit of this protocol installed the tenant (§11) | the installer, rewritten every run |
| `.githooks/pre-commit` | the shim that runs `protocol/guards/guards.sh` (§5) | seeded, then the tenant's |

Nothing in this repository knows the name of any tenant. **What arrives in a tenant arrives one of
three ways, and which one it is decides who may edit it:**

| How | What | Who may edit it |
|---|---|---|
| **Linked** | `protocol/`, and every `skills/<name>/SKILL.md` and `commands/<name>.md` an adapter installs | nobody — editing one edits this repository |
| **Seeded** | the four files above that are not `protocol/`, copied once from `tenant-template/` and skipped ever after | the tenant, which is what they are for |
| **Written whole** | an agent's own configuration an adapter composes — `CLAUDE.md`, `settings.json`, `.agents/cortex/*` — written once if absent, never touched again | the tenant, and §1 is why: an adapter is deletable, so what it writes is not doctrine |

So a tenant does carry copies of material from this repository, and the number of them is not fixed
— `--copy` turns every link in the first row into a copy, for a machine that will not follow one,
and that is the mode whose cost is that a `git pull` here no longer reaches it. `bin/doctor` reports
a copied install as a note for exactly that reason (§11). This sentence read "nothing in a tenant
repository is copied from this one except the seeds" until 2026-10-12, which was false in both
directions at once: four of the installed paths are copies in the default mode and all of them are
under `--copy`.

## 3. A guard reads a policy file the tenant carries, and what an absent policy means is the guard's own decision

`guards/policy.sh` resolves `.protocol/<name>` relative to the committing repository's root,
strips whole-line comments and blank lines, and returns non-zero when the file is absent.

A policy has **two layers**, read in that order and concatenated into one list: the tracked
`.protocol/<name>`, then an untracked `.protocol/<name>.local`. Either may be absent; only both
being absent is the "no such policy" answer. What a guard does with that answer is the guard's own,
and it is not the same in all four — the subsections below say what it means where it bites.
`bin/adapt` gitignores the overlay in every tenant, before one can exist.

The overlay is what lets a policy file survive being published. A list of the terms a repository
must refuse is, read the other way, a list of what that repository is protecting — so in a
repository anyone can read, the tracked file states the *shapes* and the *categories*, which are
safe to publish, and the overlay states the proper nouns, which are not. A guard sees one list and
cannot tell which layer a term came from, which is the property that keeps this out of every guard.

This is the mechanism that makes one shared guard chain safe to point at any checkout. **A
repository opts into a rule by carrying the file that configures it, never by being recognised by
name from inside the guard.** A guard that special-cased a repository name would have to be edited
every time a repository was added — and would be wrong the first time one was renamed.

### A repository worked on under a tenant

A repository that is merely *worked on* under a tenant is deliberately not a tenant: it is given the
pre-commit shim and nothing else, so that nothing of the tenant's is in its tree for its own
contributors and its own continuous integration to inherit. That leaves it with no `.protocol/` of
its own, and so carrying every policy file absent — which means something different for each of the
three rules that read one. For tenancy it means policed by nothing, and that is the right answer: a
denylist with no terms has nothing to refuse. For credentials it means the opposite of policed by
nothing, because those two policy files are **allow**-lists — absent is an empty allow-list, so the
guard runs there at its strictest and refuses every credential-shaped path and every key-shaped blob
it finds. For identity, absent is wrong in the other direction: who a commit is made as is a
question about this machine, and that repository is where most of this machine's commits are made.

**The credentials answer is right for a repository holding work and wrong for one holding keys, and
only the repository can say which it is.** One worked on under a tenant that tracks a path with a
credential shape and no secret in it — an encrypted blob, a `.env` of non-secret settings — carries
`.protocol/credentials-allow-name` naming that path, or cannot commit it without `--no-verify`,
which discards the rest of the chain in the same breath. Carrying the file is the only way to say so,
and it is not something the tenant can say on its behalf, for the reason the fallback below gives.

So whatever wires such a repository records the tenant in its **local git configuration**,
`principia.tenant`, alongside the `core.hooksPath` it sets there already. `tenant_root` in
`guards/policy.sh` reads it, and a guard may pass the answer to `policy` as a second argument to
read that tenant's file instead of this repository's. Local configuration is not in the tree and
does not travel, which is also what makes it safe to read: nothing arriving over the network can
set it and point a guard at a directory of its own choosing. The section is `principia` rather
than `protocol` because `protocol.*` is git's own.

**A guard opts into that fallback one at a time, and only one does.** A fallback can only be safe
where inheriting tightens: the identity guard inherits an allowlist, so the worked-on repository is
held to more than it was. `credentials-allow-name` and `credentials-allow-content` are exemptions,
and inheriting those would hand a repository the tenant's holes. The rule stands unchanged — the
repository that carries `.protocol/identity` is judged by it and by nothing else, empty or not,
because carrying the file is how a repository opts in and an empty one claims nobody.

**Which is why `bin/adapt` does not install `.protocol/identity`, and is the one seed it withholds.**
An empty list claims nobody and so refuses every commit, so seeding one would refuse the first
commit in a tenant that has not yet decided whose commits these are — and the tenant would read the
refusal as the installer being broken rather than as a question it has not answered. The template
carries the file for a tenant to copy in and fill in on the day the answer matters. It *was* seeded
empty until 2026-10-12, under a test whose own name said "claims nobody", while the guard exited 0
on an empty list and claimed everybody; the document said one thing, the installer created the
other, and nothing was enforced in any tenant on the machine.

**`bin/doctor --in <dir>` reads this shape rather than a tenant missing its install.** It is the one
place the wiring above is visible at all, local configuration being invisible in a tree, and before
it knew the shape it reported a correctly wired repository as a broken tenant and named `bin/adapt`
as the remedy — the one command that must never be run there. What it reports instead: the checkout
the **shim** resolves, which is what decides the guards where there is no `protocol/`, together with
a note where that checkout and the one the tenant reads its doctrine from are not at the same commit
— two separate checkouts is what every machine has, so the commits are what is compared and the
paths are what the note names; the two can differ deliberately, one tenant pinned to a tag while the
machine tracks a branch, and whichever loses does so silently; the identity list from whichever file
the guard would read, named by path; and a `principia.tenant` pointing at a directory that is
not a tenant, which resolves to nothing in every guard and so leaves the repository held to no
policy while every outward sign says it is wired.

The policy files in use:

| File | Guard | Contents |
|---|---|---|
| `.protocol/tenant` | `tenant-guard.sh` | extended regular expressions; the terms belonging to the tenants this repository is **not** |
| `.protocol/identity` | `identity-guard.sh` | extended regular expressions; the identities this repository's commits may be made as. The one policy with a fallback — see above |
| `.protocol/credentials-allow-name` | `credentials-guard.sh` | globs exempt from the *shape* rule — a file whose name looks like a credential and holds none |
| `.protocol/credentials-allow-content` | `credentials-guard.sh` | globs that may *contain* credential-shaped text — the suites whose fixtures pin these rules |
| `.protocol/<name>.local` | whichever guard reads `<name>` | the untracked overlay, appended to the tracked file of that name — **except for the two `credentials-allow-*` files, which have no overlay at all** |

**The overlay is for a list that tightens, and the exception is the proof of it.** Its whole
justification above is that a *denylist* in a repository anyone can read cannot state what it
refuses. An exemption list is the other kind: an overlay there would be a hole in no commit, which
review never sees and no clone carries, so `credentials-guard.sh` reads its two files with
`git show :<path>` and consults no overlay at all — an exemption added in the same commit still
works and arrives in the diff.

**Reading the tracked layer from the index is no longer what distinguishes those two files, and the
absence of an overlay is.** `policy()` read its own tracked layer from the worktree until
2026-10-13, so an unstaged edit to `.protocol/tenant` disarmed the tenancy guard for the very commit
that edit was not part of — the same hole §4's third bullet records as closed, left open in the two
files that bullet does not name. It now reads the tracked layer with `git show ":.protocol/<name>"`
wherever the index carries the path, which is §4's rule for every staged blob applied to the policy
as well as to what the policy judges. The overlay stays a worktree read, because an untracked file
cannot be in the index by construction, and that asymmetry is the whole of the difference now.

Comments are whole-line only. A policy line is a path or a regular expression and may legitimately
contain `#`.

### The one policy this repository deliberately does not carry

**`.protocol/tenant` and `.protocol/credentials-allow-content` are tracked here. There is no
`.protocol/identity`, which by the rule above means this repository's own commits are judged by no
list.** That is a decision and not an omission, and the reason is the shape of the repository rather
than the cost of the file: an allowlist is the control for a **closed** set of committers, and this
one's set is open by design. [CONTRIBUTING.md](CONTRIBUTING.md) invites contributions and
[`doctrine/git.md`](doctrine/git.md) tells a fresh clone to point `core.hooksPath` at `.githooks`
itself — so a tracked list naming the identities already on the branch would refuse the first commit
of every contributor who followed that instruction, and fail their pull request besides once the
same list ran in continuous integration. A list of the people who have committed so far is a correct
description of the past and the wrong control for a repository that asks for patches.

**What is enforced instead is the sign-off, and it is the control an open set admits.**
`.github/workflows/ci.yml` requires a Developer Certificate of Origin line on every commit of every
pull request: it asks the person to certify the commit rather than asking a list whether that person
was expected, which is the only one of the two questions a stranger can answer. What it does not
reach, stated here rather than left to be inferred: a commit header set to somebody else's name on a
machine with no hook configured is not refused here — only an unsigned commit is, and
`identity-guard.sh --scan-history` is the control that would reach it. A repository whose committer
set *is* closed says so for itself, and the untracked `.protocol/identity.local` is where it says
it, because that file does not travel to a clone and a list of people is the one list that should
not. `bin/doctrine.test.sh` holds both halves of this to the mechanisms — that no identity allowlist
is tracked here, and that the sign-off walk exists — so the decision cannot quietly become a stale
paragraph in either direction.

## 4. The guard chain runs in order and fails closed

`guards/guards.sh` is the single entry point. It runs `size-guard.sh`, then
`credentials-guard.sh`, then `tenant-guard.sh`, then `identity-guard.sh`, and stops at the first
non-zero exit. A guard that is missing or not executable **blocks the commit** rather than being
skipped: a silently skipped guard lets the thing it was meant to catch reach history, and the
absence never announces itself.

Each guard that reads the tree judges the staged blob, not the file on disk — `git show :<path>`,
not `cat <path>` — because the index is what a commit would record. `size-guard.sh` and
`credentials-guard.sh` also compare against staged size and staged bytes for the same reason.

Two guards take `--scan-tree`, which applies their rules to every tracked file instead of the
staged set, and `identity-guard.sh` takes `--scan-history`, which applies its list to the commits
already on the branch. That is the audit mode: it reads the terms from the repository rather than
from a document that then drifts — and for the history it is also the only mode there is, since a
header a machine with no hook configured wrote is past the hook by the time anyone looks.

`identity-guard.sh` is the one guard that does not read the staged set at all. Which identity a
commit is made as is neither a staged path nor a staged byte: it is `git var GIT_AUTHOR_IDENT`,
asked of git rather than derived, so the guard judges the identity the commit will actually carry
rather than a second implementation of that lookup.

**The sanctioned bypass is `git commit --no-verify`, deliberately and universally.** A control with
no bypass is a control that gets uninstalled, and that one is loud: it is typed per commit, it
discards the whole chain at once rather than one rule, and it is the string every guard prints as it
refuses. **There are three quieter ones, and this sentence named none of them until 2026-10-12** —
which is the defect in it, because a bypass nobody has written down is one nobody can decide to
close:

- **`PROTOCOL_GUARDS`** redirects the entire chain at another directory (§6). It cannot be closed,
  because it is how the shim finds the guards at all where there is no `protocol/`, and a guard
  cannot judge the checkout it is being run from. What holds it is that a commit it let through is
  judged by whatever is in that directory, and `bin/doctor` reports which checkout the shim
  resolves for exactly that reason.
- **`PROTOCOL_MAX_FILE_MB`** moves the size ceiling (§6), and a blob then lands in history at a size
  the ceiling refuses with nothing in the commit recording that the ceiling moved. **It now prints
  one line whenever it differs from 25, on a pass as well as a refusal** — the override stays, and
  stops being silent.
- **A policy edit that is in no commit.** `credentials-allow-name` and `credentials-allow-content`
  were read through the two-layer `policy()` like every other file, so an untracked
  `.protocol/credentials-allow-*.local` granted an exemption no clone carries and no review sees,
  and an unstaged edit to the tracked file exempted the very commit it was not part of.
  **Closed for those two on 2026-10-12, and for the rest on 2026-10-13:** `policy()` reads the
  tracked layer of every policy from the index as well, so an unstaged edit to `.protocol/tenant`
  no longer disarms the tenancy guard for the commit it is not part of (§3). This bullet said
  "those two files are read from the index alone" while the other two were still read the old way,
  which made the class read as closed on the strength of the half of it that was.

The first is a documented override, the second is now recorded every time it is used, and the third
is closed. What distinguishes all three from `--no-verify` is that none of them had to be typed
twice, and none of them left a trace.

## 5. A shim resolves the guards in four steps, in this order

`.githooks/pre-commit` decides *which checkout of the protocol* it loads, and nothing else. That
choice has to be made before anything can be read from the protocol, which is why it is the one
decision the shim owns rather than `guards.sh`:

1. `PROTOCOL_GUARDS`, if set — an explicit override, for a checkout under test.
2. `<repo>/guards/guards.sh`, if it exists — this repository guarding itself.
3. `<repo>/protocol/guards/guards.sh`, if it exists — the checkout this repository's own doctrine
   is read from, and so the one its receipt (§11) names.
4. `${PROTOCOL_DIR:-$HOME/.principia}/guards` — the well-known path `bin/adapt` symlinks to
   whatever clone the machine uses.

Step 3 exists because step 4 is **one path per machine**, where a tenant's own `protocol/` is one
per repository. Where the two resolve to different checkouts — one tenant that pins a tag while
the machine tracks a branch, or two tenants wired to separate clones — step 4 alone would judge
one of them by the other's guards, a tenant reading its doctrine from one checkout and being
refused, or not refused, by another. Step 3 is the entry that always agrees with what that tenant
reads, because it is the same entry it reads through.

The well-known path is what keeps a machine-local path out of every tenant's committed hook.
`bin/adapt` creates it and **never repoints an existing one**: where it already exists, that is
somebody's choice.

**A tenant may write its own shim, and some do** — one that dispatches guards of its own alongside
these, for instance. Then this order is that tenant's to honour, and `bin/doctor` says nothing
about it: it can read the order out of a shim that came from `tenant-template/`, and not out of a
dispatcher it has never seen. A check that reported a fault against a correctly wired repository
would be a check people learn to scroll past.

`core.hooksPath` is local configuration and does not travel with a clone, so a fresh clone runs no
hooks until `bin/adapt` (or `git config core.hooksPath .githooks`) is run in it. There is no way
around this in git, which is the second reason the guards are not the only control.

## 6. Environment variables

**Every `PROTOCOL_*` variable anything here reads, and `bin/doctrine.test.sh` holds this table to
that list** — a count or a set called complete is a claim about a mechanism, and the mechanism is
in the same repository as the sentence. All are optional and all are read at run time.

| Variable | Default | Effect |
|---|---|---|
| `PROTOCOL_GUARDS` | unset | the `guards/` directory to run, overriding resolution (§5) |
| `PROTOCOL_DIR` | `$HOME/.principia` | the well-known protocol path |
| `PROTOCOL_MAX_FILE_MB` | `25` | the size ceiling `size-guard.sh` enforces — a value other than the default prints one line per run (§4) |
| `PROTOCOL_COMMAND_GUARDS` | unset | the command-guard directory one adapter's hooks run |
| `PROTOCOL_PROTECTED_BRANCH` | `main` | the branch those guards refuse a push or a pick onto |
| `PROTOCOL_WORK_LOG` | `$XDG_STATE_HOME/warp/work-log.jsonl` | where one adapter's turn-cost hook appends; set empty to turn the append off |

Two more are read and are **not** this protocol's to name: `XDG_STATE_HOME`, which is the
specification's, and `CLAUDE_CONFIG_DIR`, which is one agent's — both in the Claude Code adapter
alone, and an adapter is deletable (§1). They are listed here because a reader checking the table
against the tree finds them, not because this protocol defines either.

## 7. The adapter contract

An adapter is a directory under `adapters/` holding `detect.sh`, `adapt.sh` and `README.md`.
`bin/adapt` discovers it by directory listing; adding an adapter changes no other file.

- `detect.sh` exits 0 if the agent is installed on this machine, non-zero otherwise, and prints
  nothing.
- `adapt.sh <tenant-dir> <link|copy>` wires that tenant for that agent, idempotently, reporting
  each action as two spaces followed by a verb and a path.
- **An adapter may create a file; it may never edit one the tenant already has.** Where the file
  exists, the adapter says what is missing and stops. The single exception is `.gitignore`, which
  an adapter appends to — and even there, a tenant that already has a rule about that path keeps
  it exactly as written, because a broader pattern appended underneath wins as the last match and
  would silently undo an exception the tenant carved out.
- **An adapter carries rules, never a list of repositories.** The moment it needs to know which
  clone is which, it has stopped being protocol and started being one tenant's context.
- **`doctrine/README.md` is the directory's index, not a doctrine document**, and an adapter that
  walks `doctrine/*.md` excludes it. It carries no `name`/`description` frontmatter, so wiring it
  would install something the agent cannot read.
- **A script the adapter installs is a file in the adapter, never a heredoc inside `adapt.sh`.**
  `adapters/cortex/run` is the example: tracked here, copied into the tenant unchanged, and so
  covered by the sweep that shellchecks every tracked file with a shebang. A script written from a
  string inside another script is a script no checker can see, and the tenant runs it anyway.
  `bin/doctor` compares each `adapters/*/run` with the tenant's copy for the same reason the receipt
  is compared with the checkout: the adapter writes the file whole and `bin/adapt` then skips it
  forever, so a tenant installed before the adapter changed keeps the old one silently. It reports
  the difference as a note, because a tenant may have meant it.

The guarantee a consumer may rely on: **deleting every adapter leaves the protocol intact.**
`bin/adapt` runs on a machine with none and says so.

## 8. `bin/adapt` is idempotent and additive

It skips anything already present and prints one line per change. **It removes exactly one thing,
and only ever what the same run created:** under `--copy`, the `.git` of the `protocol/` copy it
just made, printed as `strip`. A copy is not a checkout, and carrying the protocol's own `.git` in
would have git answer about the repository the copy was taken from — so the copy would report
whatever that repository is at now, which is worse than reporting nothing. The condition that it be
this run's own copy is the whole of what makes that safe, and **it was missing until 2026-10-12**: a
tenant that had put its own clone at `protocol/` and kept it current by hand — a shape `bin/doctor`
reports on — had that clone's entire history deleted by an installer that reported one word and
whose own section said it never removed anything. A second run installs nothing: `skip` for each
file already there, and no `strip`, there being nothing this run made. The one file it rewrites rather than skips
is the receipt in `.protocol/protocol-version` (§11), printed as `record`, and every field of that
line is read out of the protocol checkout — so a second run from the same commit writes the same
bytes and the tenant is left byte for byte as it was. `--copy` substitutes copies for symlinks throughout, for a machine
that will not follow a link or whose agent configuration directory is centrally managed; it
dereferences on copy, because the machine that needs `--copy` is exactly the machine that cannot
read a link.

`bin/adapt` refuses to run with this repository as its own tenant.

## 9. Testing

Every script has a `*.test.sh` beside it, **except the nine below**. `bin/test.sh` finds the suites
rather than listing them, so an adapter that brings its own suites is tested by existing.
`bin/check.sh` is the assertion helper they share. The suites are bash and take no arguments, no
network and no fixtures outside their own `mktemp -d`.

**A suite's last line is its verdict, and the runner judges it rather than reading it.** `finish`
prints `<name>: all passed (N checks)` or `<name>: N failed (M checks)`. `bin/test.sh` counts the
`  ok    ` and `  FAIL  ` lines a suite printed, rebuilds the verdict those counts imply, and
refuses any suite whose last line is not that line byte for byte — one comparison asserting that the
suite reached its verdict, that the verdict was the last thing it said, that it named itself rather
than carrying another suite's line, and that the count it declared is the count it printed. The two
counts stay independent, which is the point: the suite counts its checks as it runs them and the
runner counts the lines they produced, so neither is the other's witness. A suite that executed no
checks fails in both places, because a consumer may run these suites through a runner of its own
that asks in neither.

**And the run says what it executed** — `all suites passed (N suites, M checks)`, on the failing run
as well as the passing one. A verdict carrying only failure counts says the same thing about a run
of hundreds of checks and a run of none, which is the case `doctrine/testing.md` is about. No count
is written down on this page: a number here would be a claim about a mechanism that the mechanism
prints, which §9 is not the place to copy. Both lines extend the ones this runner printed before,
character for character, because every tenant's suites print them and a consumer matching on the
first words keeps matching.

**The nine, and the decision for each.** `bin/doctrine.test.sh` holds this list to the tree, by the
same selection CI's shellcheck sweep uses — so a new script with no suite turns the check red and
arrives here as a decision rather than quietly enlarging the exception. Seven are covered by a suite
that is not beside them, which is recorded rather than left to be inferred; two are unenforced by
decision, which is `doctrine/as-built.md`'s requirement and the reason neither is merely absent from
this page.

| Script | Decision |
|---|---|
| `adapters/claude-code/adapt.sh` | covered by `bin/adapt.test.sh`, which installs through it and asserts every path it writes, including the `.gitignore` exception a tenant carved out |
| `adapters/cortex/adapt.sh` | covered the same way, by the same suite |
| `adapters/cortex/run` | covered by `bin/adapt.test.sh`, which asserts it is written and byte-identical to the one shipped. What it does when run is that agent's behaviour, not this protocol's |
| `bin/tenant.sh` | covered by `bin/adapt.test.sh`'s ignore-rule assertions, `say` and `ignore` having no caller but the installer and the adapters |
| `.githooks/pre-commit` | covered by every commit made to this repository, which is the only thing it is for — four lines resolving the guards beside it |
| `tenant-template/.githooks/pre-commit` | covered by `bin/adapt.test.sh`'s last case, which makes a real commit through the shim that run installed |
| `bin/check.sh` | covered by `bin/test.test.sh`, which asserts the verdict `finish` prints against literals and asserts that no suite redefines a name this file owns. The second is not hypothetical: three suites here define a `verdict()` of their own, which is why the formatter is `verdict_line` and why the collision is a check rather than a sentence advising care |
| `adapters/claude-code/detect.sh` | **unenforced.** It answers whether that agent is installed on this machine, so a suite could assert only what is true of the machine running it — which is a test of the machine |
| `adapters/cortex/detect.sh` | **unenforced**, for the same reason |

`bin/adapt.test.sh` ends with an end-to-end case: it installs into a scratch tenant, then makes a
real commit through the shim that run installed, resolving the guards through the well-known path.
Every link between `bin/adapt` and `guards/tenant-guard.sh` is exercised at once, because each of
them individually is the kind of thing that passes its own unit test and is wired to nothing.

## 10. Explicitly out of scope

- **Runtime enforcement.** The guards run at `pre-commit`. Nothing here observes what an agent
  reads, what it sends to a model, or what it writes outside a repository.
- **Secret storage.** The credentials guard refuses to let a secret into a commit. Where secrets
  live and how a process receives them belongs to the tenant.
- **A package registry.** Nothing here is published to one. Consumers clone this repository and
  track a branch, or check out a tag or a commit if they would rather not move with it; a tag is a
  human-readable name for one commit, not a distribution channel.
- **Configuration merging.** No adapter merges into a file a tenant wrote (§7). There is
  deliberately no schema-aware merge of an agent's settings file, because a tool that rewrites a
  person's configuration is a tool they stop running.
- **Windows.** The scripts are bash and use symlinks, `git`, and POSIX tools. They are not tested
  anywhere else.
- **Anything that identifies a tenant.** No tenant names, no repository names, no machine names,
  no accounts, no addresses. `guards/tenant-guard.sh --scan-tree` enforces it against this tree on
  every commit and in CI, over identifier shapes and over the words a tenancy is described with.
  The proper nouns it would otherwise have to list are in the untracked overlay (§3), because a
  denylist in a public repository cannot name what it denies — the list would be the disclosure.
  `.protocol/tenant` is exempt from the scan it configures, which is why keeping the names out of
  the tracked half is structural rather than a habit.
- **Anything that measures a model.** No doctrine document names a vendor, a model family, a price
  or a model version, and none of them carries the tuning vocabulary a measurement needs. A finding
  about how a generation of models behaves is true on a date and belongs to the tenant that took the
  measurement; filed here it would be read as a rule and shared with every tenant that did not.
  `bin/doctrine.test.sh` enforces it against this tree in the `bin/test.sh` sweep, over `doctrine/`
  alone — the rest of the repository is mechanism and may say whatever it has to about the agents it
  installs for.

## 11. A tenant records which protocol installed it, and the record is a receipt rather than a pin

`protocol/` is a symlink. The checkout behind it can be moved by whoever develops this protocol and
no file in the tenant changes — the tenant would read different doctrine and be judged by different
guards with nothing to see in a diff. That is two questions wearing one answer, and they separate
cleanly:

1. **Which protocol judges a commit.** Decided live, by following `protocol/` at the moment of the
   commit. No file in the tenant can answer it, because no file in the tenant changes when the
   answer does.
2. **Which protocol installed the files that are here** — the shim, the seeded policy files, the
   agent launchers, each written once and skipped forever after. Frozen at the last `bin/adapt` run.

`.protocol/protocol-version` answers the second, and only the second. One line, the first that is
neither blank nor a whole-line comment: `<ref> <short-sha> <date>`, where `ref` is the branch the
installing checkout was on, or the tag it was exactly at, or the bare commit when it was on
neither. `bin/adapt` **rewrites it on every run**, because a receipt stating an install other than
the last one is precisely the drift it exists to report; every field comes from the checkout, so
two runs from the same commit write the same bytes. It is not edited by hand — an edit claims an
install that never happened, and the next run overwrites the claim.

`bin/doctor` asks the first question live and reads the second off that line. Where the ref names a
branch, it reports whether `protocol/` is still on it and how far behind `origin/<ref>` the last
fetch left it — a note, because being behind breaks nothing until you commit against doctrine you
have not read. Where it names a tag, it checks the checkout is at that tag, which is the whole of
what a consumer who would rather pin wants. Either way it reports separately when the checkout has
moved past the commit recorded, because that is the install going stale rather than the protocol.

`bin/doctor`, run in a tenant, also
reports the failures that are otherwise silent because nothing reads them until something else
fails: a skill symlink whose target has moved, `core.hooksPath` unset in a fresh clone, and a
`.protocol/tenant` that parses to zero terms. It counts those terms and never prints one, for the
reason §3 gives.

Where there is no receipt to read, because the repository is one worked on under a tenant rather
than a tenant, the first question is still which protocol judges a commit — and the shim answers
it. So
`bin/doctor` resolves the guards the way `tenant-template/.githooks/pre-commit` does, in that order,
and reports the checkout it lands on. That duplicates the shim's order in a second place, which is a
cost paid deliberately: the shim ends in an `exec` of the chain against the index, so the only way
to report what it would resolve without committing is to resolve it again.
