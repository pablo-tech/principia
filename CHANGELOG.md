# Changelog

All notable changes to the protocol and its mechanism are documented here. This project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**A tag here is a marker, not a distribution.** Nothing is published to a registry; a consumer
clones this repository and tracks a branch, or checks out a tag or a commit if they would rather
not move with it. A tag exists only so that one commit has a human-readable name. This file is
where you find out what pulling gets you.

Breaking changes are named as such, and are what a tag is now cut for. A change to the doctrine
frontmatter contract, to the guard resolution order, to a policy file's name or meaning, or to the
adapter contract breaks every consumer the moment they pull, so it is announced here first and
given a version number — a name for the commit before it, which a consumer who would rather not
move with `main` can stop at.

## [Unreleased]

### Added

- **`INDUCTION.md`: what it takes for a rule to be admitted to `doctrine/`.** A rule is admitted
  only when it can be named *and cited* — stated as an instance of a principle the wider field
  already knows, in the strongest form that field states it, attributed to a specific prior work
  (author, title, year, in the form the field recognizes it by), with any departure from that form
  declared rather than smoothed away. A practice area is not a citation. The file is the argument for
  why that condition is the load-bearing one, the five conditions in full, the distinction between a
  principle, a mechanism and a measurement, and a **register** with one row per doctrine document:
  the named principle, the prior work it is named from, and where this repository departs from it.
  One departure is worth reading on its own — `tenancy.md` uses a denylist where fail-safe defaults
  demand an allow-list, knowingly, and the register is now where that is admitted.

- **Every doctrine document prints its citation itself, on a `Named:` line under its opening line**,
  and `README.md`'s table of the doctrine carries the same work in its shortest form. The citation is
  deliberately in three places and INDUCTION.md states the exemption that allows it: a published work
  is dated and immutable, so the copies cannot drift, which is the one class of fact
  `doctrine/clean-code.md`'s rule does not reach. **The doctrine's rules did not change** — the seven
  documents were already instances of named principles, and this is where the lineage stops being
  implicit — but their text did, so a consumer tracking `main` sees seven documents and seven skills
  change. `ARCHITECTURE.md` §1 states the contract that follows: a rule here is either traceable to a
  work older than this repository or says in as many words that no prior work was found.
  `bin/induction.test.sh` refuses a tree where a document has no `Named:` line, no register row, no
  row in README's table, or where any of the three names no dated work. What it cannot ask is whether
  the work cited is the right one; that half stays with review, and INDUCTION.md says so.

### Changed

- **`doctrine/git.md` gains the lever run backwards, and `doctrine/as-built.md` gains two rules about
  what a document owes.** All three were earned in a tenant and are stated here with the case left
  behind, per `INDUCTION.md` condition 3. **A compatibility shim runs shift-left backwards** — a
  redirect, an alias or a tolerated old spelling keeps a stale reference working, so the correction
  happens when the shim is removed rather than when the reference went stale, and what it spends is
  the signal, since a silent success is the one failure no check can be written for. The principle it
  declines is named rather than ignored: the robustness principle (Postel, RFC 760, 1980) is sound
  between implementations that cannot coordinate, and its reconsideration is the half that applies
  inside one system, where liberal acceptance only conceals the error until the defect is the
  specification (Allman, 2011). A shim that is kept is therefore kept as a decision, with what it
  covers for and the condition on which it goes. **A rule nothing enforces is recorded as unenforced,
  with the decision attached** — absence leaves no trace to contradict the document, so the document
  asserting the rule is the only evidence there is and it reads as coverage; writing the gap down with
  its decision is accepted risk (ISO 31000:2018). It is also the sentence that makes `tenancy.md`'s
  inversion honest, which is why it lands in the phase after it. **And a comparative claim in a
  document is an empirical claim, so the document ships what would settle it** — falsifiability
  (Popper, 1934) asks only that a claim could be contradicted, and a document is held to more because
  the party making the claim and the party publishing it are the same one. Both register rows state
  their departures, of which the one that matters is that Popper is used for more than he asks: the
  ground for the stronger form is the conflicted authorship, not the criterion.

- **`doctrine/tenancy.md` gains three named principles: what a control cannot decide, where that
  leaves you, and what an exclusion does not do.** All three were earned in a tenant and are stated
  here with the case left behind, per `INDUCTION.md` condition 3. **No mechanical control can decide
  what a file is for** — what a file contains is a property of its text and what it is for is a
  property of the intention behind it, and every non-trivial semantic property of a program is
  undecidable (Rice, 1953), so a matcher cannot be made to respect purpose by being made cleverer and
  the only remaining variable is *where it is installed* (policy separated from mechanism — Levin,
  Cohen, Corwin, Pollack and Wulf, Hydra, 1975). Which makes **the absence of a control an assertion
  that purpose differs there** rather than a gap — but only where the absence is recorded as a
  decision, since unrecorded it is indistinguishable from an oversight. **A policy root is the unit of
  enforcement, and silence about a root is not safety**: a control reaches the edge of what it is
  installed in and no further (the trust boundary — Shostack, 2014), so roots are inventoried and
  *unenrolled* is a recorded value rather than the default reading of an empty directory. And **an
  exclusion is a preventive control and nothing more** — it guarantees the excluded material is not
  carried and says nothing about whether it exists, leaving state that is invisible rather than
  absent, so an exclusion that matters is paired with a sweep that has an owner (preventive and
  detective controls — COSO, 1992). The register row states the departures, of which two matter: Rice
  is invoked for what it forbids rather than as a proof about controls that match text, and the
  trust-boundary paragraph is complete mediation read backwards, which is structurally weaker than
  reading it forwards because there is no single reference monitor to read forwards through.


- **The seven incumbent documents audited against `INDUCTION.md`, which was written from them.** A bar
  induced from the things it judges passes them by construction, so the useful question was whether
  each would be admitted today by someone who had not written it. All seven clear the condition on
  their headline principle. What the audit found is a class the mechanical check cannot see: terms
  **named inside a document** with no work behind them, where the test only asks whether the `Named:`
  line carries a dated one. `F.I.R.S.T.` is Robert C. Martin, *Clean Code*, 2008 — and
  `doctrine/testing.md` states four of its five letters and renames one, which is a departure and is
  now declared; red-first is Kent Beck, 2002, of which only that half is taken; the Boy Scout rule and
  the title of `doctrine/clean-code.md` are Martin's; the decision record of `doctrine/as-built.md` is
  Michael Nygard, "Documenting Architecture Decisions", 2011, narrowed here from four headings to three
  sentences. `INDUCTION.md` now states that the condition reaches inside a document and where such a
  citation goes, since the sweep it asks for is review's work permanently.

- **`doctrine/git.md`'s branch-protection section stated a vendor fact as a rule and now states the
  rule.** That one forge offers no organization-wide default is true of one product on the day it is
  read; what does not change is that a setting decided per repository is decided again by whoever
  creates the next one, with nothing afterwards saying which were decided differently. The principle is
  named — convergence to a declared state, Mark Burgess, "A Site Configuration Engine", 1995 — and the
  forge's behaviour is now the instance beneath it, dated as such.

- **`INDUCTION.md`'s `git.md` row declares *respect des fonds* as a metaphor**, which it was being used
  as without saying so. The archival principle is about custody of a body of records, not about what
  authorized a change; the register now says which half transfers, what work the metaphor does, and
  that a closer work for the authorization half would be an improvement on it.

## [1.0.0] — 2026-10-06

The first release under this name, and the first commit in this repository. Stated as what the
protocol *is* rather than as a diff against a version this repository does not carry — see
**Before 1.0.0** below.

**The doctrine is the documents under `doctrine/`, and nothing else here is normative.** Each is
written as a forcing function rather than as advice — a rule shaped so the failure it prevents
either cannot happen or announces itself while it is still cheap to fix — and each opens with the
general discipline it instantiates, which is what makes a rule portable past the situation that
produced it. `AGENTS.md` indexes them for an agent and `doctrine/README.md` for a person.
Everything else in the repository installs them or enforces them.

**A rule is admitted only if it would still be true if every model on the machine were replaced
tomorrow** (`ARCHITECTURE.md` §1, beside the rule that doctrine carries no tenant's facts). A claim
about how a model behaves is a measurement — true on a date, of a generation — and belongs in a
dated finding in the tenant that measured it, not here, where it would inherit the authority of a
rule and be shared with every tenant that never measured it. §10 lists it under what is explicitly
out of scope, and `bin/doctrine.test.sh` holds it against the tree: no doctrine document names a
vendor, a model family, a version string beside a family name, a price, or the tuning vocabulary a
measurement needs and a rule does not. **The doctrine here is the result of that cut rather than its
starting point** — two documents did not survive it, and five pieces of them did, folded into the
files that already own their subject.

**One file, two readers.** A doctrine file carries exactly two frontmatter keys, `name` and
`description` — the whole of what one agent's skill format requires, and inert to every other
reader. So an adapter wires a skill as a *symlink* to the doctrine file and never a copy, there is
no second copy to drift, and adding a third key is a breaking change (§1, §7).

**Four guards at the one gate every route to history passes through.** `size`, `credentials`,
`tenant` and `identity`, run in that order from a tenant's `pre-commit` shim, failing closed, each
judging the staged blob rather than the conversation — which is what makes them bind a diff written
by hand, by an editor, or by an agent nobody here has heard of. A guard reads its policy from a file
the tenant carries under `.protocol/`, and what an absent policy file means is each guard's own
decision: a denylist with nothing in it stands down, an allow-list with nothing in it exempts
nothing and so is that guard's strictest setting, and the size ceiling reads no policy at all (§3,
pinned as one table by `guards/absent-policy.test.sh`).

**`bin/adapt` installs it, `bin/doctor` audits it, and neither is required to read the doctrine.**
The installer is idempotent and additive — a second run installs nothing, and the guarantee a
consumer may rely on is that deleting every adapter leaves the protocol intact (§7, §8). A tenant
records which protocol installed it in `.protocol/protocol-version`, which is a **receipt rather
than a pin**: what judges a commit is whatever `protocol/` resolves to at the moment of the commit,
with no file in the tenant changing when that symlink moves, so `bin/doctor` asks the checkout
itself and reports the receipt beside the answer (§11).

**Consumers track `main`.** A tag is cut only for a breaking change, for whoever would rather pin.

## Before 1.0.0

The protocol ran for nine releases under a previous name, in a repository whose history this one
does not carry: this is a fresh repository with a single commit, by decision, and no version before
`1.0.0` is reachable from here. Nothing was ever published to a registry, so nothing depended on
those refs. What they held is the doctrine as it stood before the cut described above, which is the
one thing about them worth knowing.

[Unreleased]: https://github.com/pablo-tech/principia/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/pablo-tech/principia/releases/tag/v1.0.0
