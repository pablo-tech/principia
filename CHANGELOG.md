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
