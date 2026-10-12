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
given a version number. **The tag names the commit that carries the break, not the last one
without it** — it is the release that change is in, and a consumer who would rather not move with
`main` pins the tag below it. That sentence read the other way until `2.0.0`, which is the first
breaking change there has been to read it against, and either reading left a consumer pinning the
wrong commit.

## [Unreleased]

### Added

- **The installer says what it decided not to do, in the three places it used to decide in
  silence.** A `.gitignore` pattern declined because the tenant's own rules already cover that path
  now prints both the pattern and the tenant's line, so the skip is a judgement the operator can see
  and overrule rather than an absence to infer something from — a live tenant had `/skills/synced/`
  declined on that ground and had to add the line by hand. A directory with no `.git` gets a note
  saying `.githooks/` is installed and nothing will run it, which is the state a tenant adapted
  before `git init` is actually in. And a run that stops names the step it stopped in and says that
  `bin/adapt` is idempotent, because `set -e` stops at the right place and tells the operator
  nothing about how far the install got, while a part-installed tenant looks wired.
- **Two checks stand where the four-places citation exemption's "a reader catches it for free"
  was.** `bin/induction.test.sh` holds the year a copy prints to the year inside the lineage anchor
  beside it, and holds every work a `Named:` line names to carrying a year rather than only the
  first. The exemption is granted on the ground that a disagreement between the four copies is a
  typo a reader catches for nothing; the A201 citation stood at 2017 in the lineage and in every
  anchor pointing at it and carried no year at all in the document or the register for as long as
  the page existed, which is that prediction failing for the second time. Both checks were proved
  red against the real defect and each carries a fixture control naming its own cause. What they
  cannot reach — whether a correction reached every copy, the copies being in files nothing
  enumerates — is recorded in `REFUTATION.md` as unenforced rather than left to the next reader.
- **A third check holds the refusal triage character-identical across the three documents that
  print it.** It is the one sanctioned near-duplicate whose justification is two readers of one
  sentence, and the sentence had drifted to three categories in `AGENTS.md` against four in
  `INDUCTION.md` — the missing one being *advice*, which is the category that lets a proposal be
  refused on its subject rather than on its form.
- **`bin/adapt.test.sh` asserts the ignore rules it only used to exercise**: that a tenant rule
  about a sibling path does not swallow the rule for this one, that a covered pattern is skipped
  *and said to be*, and that a `.gitignore` whose last line carries no newline keeps its last rule.

### Fixed

- **A tenant's `.gitignore` line is compared as the path it names, not as its first segment.** The
  reduction to a first path segment read `skills/omarchy` — one ignored directory in a tenant that
  shares every other skill — as a ruling on the whole of `skills/`. The comparison is now a
  path-prefix one at a `/` boundary, which is narrower than that and wider than equality on purpose:
  equality would reintroduce the hazard the function exists for, where a broader rule appended
  underneath wins as the last matching pattern and silently undoes the exception a tenant carved
  out. It is not a second implementation of git's matcher and deliberately not one — both sides are
  compared literally, so a rule covers this pattern when it names the same path or a parent of it.
- **`bin/adapt.test.sh`'s idempotence measurement is taken rather than reported.** `digest()` was
  three GNU-only tools in one pipeline — `sort -z`, `xargs -r`, `sha256sum` — so on a machine
  carrying none of them every stage failed, the digest was empty, and the check compared the empty
  string to the empty string and passed. That is this repository's own vacuous pass, in the one
  check whose comment says idempotence "is measured instead". It is now `shasum` or `sha256sum`,
  whichever the machine has, with a probe that stops the suite rather than letting it degrade, and
  the file count is part of the digest and asserted on its own — because two digests agreeing is
  also what two runs that hashed nothing look like.
- **The A201 citation carries its year**, 2017, in `doctrine/as-built.md` and in `INDUCTION.md`'s
  register, read out of `LINEAGE.md` rather than retyped.
- **Two claims on `REFUTATION.md` corrected, and the correction recorded as the fifth entry.**
  `6b98fa9` reported correcting a citation "in all three places that carried it" and four carried
  it; the fourth was a `CHANGELOG.md` bullet fifty-four lines below the bullet announcing the
  correction, and this page repeated the count. A claim about a correction's completeness that was
  itself incomplete is what that page is for, so it is an entry rather than a quiet edit, and
  `## What found them` now accounts for a fifth finding five days after the other four.
- **`CHANGELOG.md` says forty lineage entries**, which is what `2.0.0` shipped. The count is a dated
  claim about a release and is deliberately not derived: a check reading today's `LINEAGE.md` would
  be right about `[2.0.0]` today and wrong at `2.1.0`.

## [2.0.0] — 2026-10-12

**One thing breaks, and a tenant adapted before this release meets it on its next commit.**
`bin/adapt` used to seed an empty `.protocol/identity` into every tenant, and the identity guard
exited 0 on an empty allow-list — so the file claimed *everybody* while two documents said it
claimed *nobody*. Absent and present-and-empty are now different states: absent stands the guard
down and the installer no longer writes the file, and a list naming nobody refuses every commit
until somebody says who. **Fill the file in, or delete it** — deleting it is the state the tenant
was actually in, and `tenant-template/.protocol/identity` is there to be copied back when it
matters. A second behaviour change reaches only a repository that had relied on one: the credentials
guard's two allow-lists are read from the index, so an exemption in an untracked `.local` overlay,
or in an unstaged edit, no longer grants one.

Everything else here is additive. The release is four phases of one audit — the repository read
against its own sentence, *"The protocol is these documents. Everything else in this repository
exists to install them or to enforce them"* — and what the audit found was not fifty unrelated
defects but four classes of one shape: a claim in a document and a behaviour in a mechanism that
disagree, where the document is the only evidence and so it reads as coverage. That shape was
already named in `doctrine/as-built.md`, about a rule nothing enforces, and nothing applied it to
this repository's own as-built documents. It does now, and three of the counts those documents make
are derived from the mechanisms they count rather than written down.

### Added

- **`bin/doctrine.test.sh` holds three of the repository's own counts to the mechanisms they count,
  and `ARCHITECTURE.md` §9 carries the decision for every script with no suite beside it.** The rule
  being applied is `doctrine/as-built.md`'s, extended there in the same commit from *an unenforced
  rule* to *a claim about a mechanism*: a false claim about a mechanism leaves no trace either, so
  the document asserting it is the only evidence there is, and it reads as coverage in exactly the
  same way. Three claims were mechanizable and are now derived — `doctrine/README.md`'s count of
  commit-enforced rules against the dispatch list, §6's table of environment variables against every
  `PROTOCOL_*` a non-suite script actually reads, and §9's list of scripts with no suite against the
  same union selection CI's own static-analysis sweep makes, in both directions, so a script that
  since gained a suite is reported as a stale excuse. Each check ships with its own readability
  check, because a table the suite cannot parse is a claim it passes without having read; each was
  proved able to fail by mutating the mechanism rather than the document. §9 says `except the ten
  below` and the ten are a table: six covered by a suite that is not beside them, and four
  unenforced by decision with the reason attached — among them `bin/check.sh`, whose own defect (a
  suite that never reaches `finish` reports success, since only `finish` exits non-zero) is recorded
  there rather than left to be rediscovered, the harness being shared with every consumer's test run
  at once. Two rules of `doctrine/git.md` are recorded as enforced by nothing at commit time for the
  same reason, with what prevents each from being a commit guard said in the document rather than
  inferred.

- **The credentials rule gets a principle: `doctrine/git.md` gains *Credentials: rotation is the only
  removal*.** `guards/guards.sh` dispatches four guards and three of them traced to a doctrine
  document; the credentials guard traced to none — so the most unrecoverable moment the repository
  has a mechanism for was the one no document named, and an agent reading the doctrine met it for the
  first time as a refused commit. The section states what the mechanism was already assuming:
  deleting a committed secret does not remove it, because a pushed branch has been fetched and a fork
  holds its own copy, so the act that ends the exposure is at the issuer and the deletion is
  housekeeping afterwards. It names the guard by path, names both `.protocol/credentials-allow-*`
  files as the only exemption there is, and says in as many words that absence is their strict
  setting rather than their off switch — the one thing about that guard which surprises everybody who
  reads it, and which until now was written only in the guard's own header. `doctrine/warp.md`'s
  authorization to commit a credential to the repository that holds them gains the gate it omitted:
  that is a repository whose own tracked declaration says it holds them, and a warp refused there has
  found a repository that never made one, which is a stop. No new `LINEAGE.md` entry — shift left and
  the end-to-end argument are already `git.md`'s own `Named:` line, and its register row in
  `INDUCTION.md` already states the reversibility departure this rule is an instance of.
  `bin/doctrine.test.sh` is the practice half and is what makes the class non-recurring: every guard
  the chain dispatches must be named by path in at least one `doctrine/*.md`, with the list read off
  the dispatcher rather than restated, and a separate check that the list was read at all — because a
  dispatch list the suite cannot parse is a chain it passes without having looked at. Two documents
  that counted the enforced rules as **two** (`doctrine/README.md` and `README.md`) now name all
  four and the document each belongs to, in the same words.

- **`doctrine/tenancy.md` gains *A control that cannot tell whether it applies refuses*, and
  `guards/guards.sh` gains the suite it never had.** The document already applied fail-safe defaults
  to the policy a guard reads — a repository carrying no file has not opted in, a missing guard in
  the chain blocks — and said nothing about the guard's own inputs, which had acquired the opposite
  default without anyone choosing it. The new section is that one level up: an absent policy and an
  unreadable one are not the same answer, because absence is a decision somebody took and an
  unreadable input is the control failing while looking like it worked. It also says why failing
  closed is not sufficient on its own — an allowlist that will not compile refuses every identity,
  which is the safe direction and arrives as a verdict about whoever is committing, and the list and
  the identity are repaired by opposite edits — so a refusal names the input it could not read
  rather than stating the conclusion the rule would have reached. No new `LINEAGE.md` entry: Saltzer
  and Schroeder are already this document's own `Named:` line, and the tenancy row in `INDUCTION.md`
  records the strong form reaching further than it did. `guards/guards.test.sh` is the practice half
  of the same sentence — `ARCHITECTURE.md` §4 makes four claims about the 27-line file that carries
  the whole fail-closed promise, and until now nothing asserted any of them. Twelve checks, reading
  the guard list off the dispatcher rather than restating it, and the CI shellcheck sweep now selects
  by name as well as by shebang, which is what puts `guards/policy.sh`, `bin/check.sh` and
  `bin/tenant.sh` in it as files of their own rather than as somebody else's `-x` dependency.

- **The premise the doctrine is derived from, stated in `README.md`, and the admission criterion
  derived from it in `INDUCTION.md`.** The five conditions were a filter and not a generator: a rule
  requiring a copyright header on every file is nameable, citable, general, observably breached and
  has one home, so it passed all five, and nothing written down anywhere said why it obviously did
  not belong. `README.md` now opens on the premise — work handed to an autonomous agent as an
  objective and run without anyone watching each step, so the standard it runs under is the
  arrangement agreed beforehand or it is nothing — cited to the two works already in `LINEAGE.md`
  that carry it, Moltke 1869 and Ross 1973, which had been filed as `doctrine/warp.md`'s alone when
  they are what the other six derive from too. `INDUCTION.md` gains **Where a mistake stops being
  recoverable**, ahead of the conditions so the generator precedes the filter: a rule earns its
  place by naming a moment at which a cost stops being recoverable, either the act that cannot be
  undone or the signal that would have let somebody notice while it still could be. It names what
  that excludes — elegance, simplicity, performance, delivery speed, whether the software is of any
  use to anyone, each refused by the fourth condition rather than by modesty — and names the two
  documents to attack if the criterion is wrong, `doctrine/git.md` and `doctrine/tenancy.md`, whose
  rules predate delegation and derive from the premise only in their placement. Held by review
  alone, recorded as unenforced with the decision attached. The refusal triage in `CONTRIBUTING.md`
  and `INDUCTION.md` gains a fourth category to match — **advice**, a rule naming no such moment —
  so a proposal can be refused on its subject rather than only on its paperwork. Nothing under
  `doctrine/` changed: a consumer who pulls this gets no new rule and no changed rule.

- **`REFUTATION.md`: one entry per occasion a rule here was stated or applied and failed.** Four to
  start, each resolving to the commit a reader can go and read. `INDUCTION.md`'s fourth condition
  admits a rule only if its breach is observable, and until now a breach that *was* observed had
  nowhere to live — so the condition could be satisfied in writing by every document and
  demonstrated by none, which is the shape it exists to refuse. Not doctrine and not a changelog: it
  records the showing rather than the fix, and the page says in its own words that a rule with no
  entry has not been vindicated. Held by `bin/refutation.test.sh` — every entry carries all four
  labels, is dated, names a commit, and names one this repository actually contains, and every
  document describing this repository still reaches the page. `ARCHITECTURE.md` §1 states the one
  thing a consumer may rely on there — an entry names a commit this repository contains — and says
  that an entry existing for a given rule is not a claim at all. `CONTRIBUTING.md` carries the
  standing invitation that fills it — a particular rather than an argument, an issue rather than a
  pull request, credited by whatever name the finder gives — which extends to the rules the stance
  `INDUCTION.md` already took for a citation nobody could find.

- **An eighth judgement: every `Named:` line reaches the lineage, and reaches an entry that is
  there.** Both halves are one check because a link that resolves nowhere is worse than none —
  GitHub reports a renamed heading as silence, opening the page at the top while the reader thinks
  they are reading about the work. Controlled on both causes at once, over what the failure names.

- **`LINEAGE.md`: one entry per work the doctrine is named from, with its field's objections.**
  Forty entries under eleven literature headings, each carrying the full citation, what the
  work claims *at its own scope*, **what the field says against it**, and the rule here that leans
  on it. It exists because `INDUCTION.md` admits a rule partly on the grounds that a name "imports
  the counter-arguments", and the repository printed an objection for one of forty-one names — a
  condition it had written down and was failing. The page is at the root and not under `doctrine/`
  on purpose: `adapters/claude-code/adapt.sh` installs every `doctrine/*.md` but `README.md` as a
  skill, and this is scholarship rather than instruction. It holds no rule, binds nothing, and loses
  to a doctrine document wherever the two disagree.

- **Seven new judgements in `bin/induction.test.sh`.** Every register row reaches the lineage; every
  anchor it asks for exists; **every entry is reached from the register**, which is what keeps the
  page from becoming the reading list `INDUCTION.md` refuses; every entry carries all four labels;
  every entry cites a dated work; and every entry carries a dated objection or says in as many words
  that **no serious objection was found** — the same falsifiable escape the register already gives
  "no prior work was found". Plus the empty-set control, eight fixture controls, and two assertions
  pinning GitHub's heading-anchor rule, including the doubled hyphen an em dash leaves behind.

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

- **The closer work `git.md`'s provenance departure asked for in writing, named.** The register
  declared *respect des fonds* a metaphor and said that naming a closer work for the authorization
  half "is the contribution to make"; writing the lineage found one, and it is now cited beside the
  archival principle with an entry of its own — in-toto (Torres-Arias, Afzali, Kuppusamy, Curtmola
  and Cappos, 2019), where a chain is verified by requiring every step to be attested by whoever was
  authorized in advance to perform it. The archival principle keeps the custody half it actually
  states. **The rule in `doctrine/git.md` did not change**: a pull request already quoted the phase
  that authorized it, and that is still what the register names it for.

### Changed

- **BREAKING: an absent `.protocol/identity` and an empty one stop meaning the same thing, and
  `bin/adapt` no longer installs the file.** Two sentences in `ARCHITECTURE.md` and `bin/doctor`
  said an empty list "claims nobody"; the guard exited 0 on an empty list, so it claimed everybody —
  and the installer seeded exactly that state into every tenant, under a test whose own name said
  "claims nobody until it is filled in." So the one guard whose subject is a person rather than the
  work was off in every tenant that had not thought about it, and the document asserting otherwise
  was the only evidence there was. The code was the defect, not the document, by this repository's
  own rule that absence is an allow-list's strictest setting — but inverting the guard alone would
  have refused the first commit in every fresh tenant, so the resolution splits the two states
  instead. **Absent** is a repository that never opted in: which identity a commit is made as is a
  question about the machine, and the guard stands down, which is why the installer withholds the
  seed and says so in its header. **Present** is the repository having answered, and it is judged by
  its own list and nothing else, empty or not — so a list naming nobody refuses every commit there
  is, in its own words, naming the file rather than the identity and naming both ways out, because
  which one is right is the repository's to say and not the guard's. `bin/doctor` reports the three
  states apart by reading the policy's exit status rather than whether the list came back empty: a
  note where nothing has opted in, and a fault where no commit can be made at all. **What a consumer
  must do:** a tenant adapted before this commit carries a seeded empty `.protocol/identity`, and
  its next commit is refused. Fill the file in with the identities those commits are made as, one
  extended regular expression per line, or delete it — deleting it is the state the tenant was
  actually in, and `tenant-template/.protocol/identity` is there to be copied back in on the day it
  matters.

- **An exemption from the credentials guard must be in a commit, which closes two ways past it that
  left no trace.** `.protocol/credentials-allow-name` and `-content` were read through the shared
  two-layer `policy()`, so a gitignored `.protocol/credentials-allow-name.local` granted an
  exemption that travelled to no clone and appeared in no diff — and an edit to the tracked file
  alone granted one in the working tree while the commit being judged contained no such line.
  `guards/absent-policy.test.sh` said in its own comment that neither was possible. Both now read
  the index, through the guard's own reader rather than through `policy()`: the overlay is justified
  for a list that **tightens**, and these two say what is exempt, so for them it was a hole in no
  commit at all. Reading the index is also the rule this guard already applies to every staged blob,
  so an exemption added in the same commit as the file it exempts still works and arrives where a
  reviewer sees it. **What a consumer should expect:** a repository relying on an untracked
  `credentials-allow-*.local`, or on an unstaged edit to the tracked file, now has that commit
  refused. Move the lines into the tracked file and stage them.

- **`size-guard.sh` prints a line whenever the ceiling is not the protocol's, and `bin/adapt`
  removes only what the same run created.** `ARCHITECTURE.md` §4 said the bypass was
  `git commit --no-verify`, "deliberately and universally", and there were three quieter ones; what
  distinguished them is that none had to be typed twice and none left a trace.
  `PROTOCOL_MAX_FILE_MB` now says so on every run it changes, so a raised ceiling is in the output
  of the commit it permitted. `PROTOCOL_GUARDS` cannot be closed — a chain that cannot be pointed
  somewhere else cannot be tested — and §4 now records that rather than omitting it. And §8's "never
  removes anything" was false in one place: under `--copy`, `rm -rf "$TENANT/protocol/.git"` could
  not tell the copy the run had just made from a clone the tenant made by hand, and would destroy
  that clone's whole history reporting one word. It now strips only a `.git` belonging to a copy
  this run placed, reports `skip` for a `protocol/` it found already there, and §8 says what the one
  removal is.

- **Six places where a guard reported a commit clean because it could not tell.** Each is a
  behaviour change for a consumer, and in every case the behaviour it replaces is a guard that was
  enforcing nothing while reporting success. `tenant-guard.sh` read `grep`'s exit 2 on a pattern it
  cannot compile as exit 1, "no match", so one unbalanced parenthesis in a hand-maintained denylist
  passed every file in the tree — in the pre-commit hook and in the `--scan-tree` step CI depends
  on, both green. `identity-guard.sh` had the same construct with its sense inverted, so it failed
  closed and then blamed the identity for a broken list. All four guards read `git diff --cached`
  with `--diff-filter=AM`, which hands a renamed, copied or type-changed path to no guard at all, so
  `git mv notes.txt deploy.env` walked past the credential shape rule; it is now `--diff-filter=d`,
  which excludes only the one status with no staged blob to read. `credentials-guard.sh` and
  `tenant-guard.sh` read their path lists newline-delimited, so a path git C-quotes escaped both the
  name rule and the content rule; both now use `-z`, as `size-guard.sh` already did. `[ -f "$path" ]`
  follows symlinks, so `--scan-tree` skipped every tracked symlink — `bin/adapt` installs those into
  every tenant by design — and the link target is now read through `git show :<path>` as the staged
  branch already does. And the whole chain exited 0 when git declined to say what was staged, which
  is indistinguishable from nothing being staged: `require_index` in `guards/policy.sh` refuses
  instead, naming the guard and saying that no rule was applied. **What a consumer should expect:** a
  repository whose policy file does not compile, or whose index git cannot read, now has its commits
  refused where it previously had them approved unexamined. That is not a new restriction on
  legitimate work — it is the first report that the control was not running.

- **`dangerous-flags.sh` stopped enumerating the guards `--no-verify` turns off, because the list had
  already drifted.** Both deny messages named "the size, credentials and tenant guards" when
  `guards/guards.sh:16` dispatches four — `identity-guard.sh` arrived and the sentence describing the
  chain did not move with it. It was also wrong in the other direction for every consumer, since a
  tenant adds guards of its own to the same chain and the shared message cannot know them: one
  measured tenant discards three more than the protocol has. So the messages now name the dispatcher
  rather than its contents — every guard `guards/guards.sh` dispatches, and every guard the tenant
  has added to it — which is the same one-home rule `doctrine/clean-code.md` states, applied to a
  guard's own prose. No verdict changed.

- **The push guard's advice on a deleted remote ref told the reader to do the one thing that cannot
  work.** Denying a `git push --delete` is right and unchanged — an unmerged remote branch is the
  only copy left. What the denial then said was "Delete it after the merge, by hand", which is
  advice for a world where the forge keeps a merged head branch. Where it does not, the branch went
  as the merge landed and the suggested command can only fail with `remote ref does not exist`, so
  the guard spent the reader's next step on a command that was never going to run. The denial now
  says that: not merged means the remote copy is the only one, merged means there is likely nothing
  left to delete, and what a merge does leave is the local worktree and the local branch
  `git worktree remove` does not take with it. Named as the instance rather than the rule, the way
  `doctrine/git.md:56` already treats head-branch deletion — a setting a repository declares, whose
  value is read on the day and can change. Found by a consumer measuring it across eight
  repositories rather than reasoning from a default. No doctrine file changed and no verdict
  changed; `bin/test.sh` asserts the verdict and never the prose, which is why nothing caught this.

- **Construct validity is cited to Cronbach and Meehl, 1955, not Campbell and Fiske, 1959.** The
  1959 paper is convergent and discriminant *validation* by the multitrait-multimethod matrix — the
  procedure for arguing construct validity from a pattern of agreements between instruments. The
  work that defines the term is "Construct Validity in Psychological Tests", *Psychological
  Bulletin* 52(4), 1955, 281–302, which is what `INDUCTION.md`'s second test asks for: the work the
  field cites. Corrected in all three places at once — the cited sentence in `doctrine/testing.md`,
  the register row, and the lineage entry, whose anchor moves with it. Both other works stay in the
  entry, which is where a reader who wants the procedure or the standard treatment will look.

- **`warp.md` cited one work for the principal–agent problem and the register cited another.** The
  `Named:` line said Jensen and Meckling, 1976; the register and the lineage head the entry Ross,
  1973. Ross is where the problem is formulated under the name the doctrine uses — "The Economic
  Theory of Agency: The Principal's Problem", *American Economic Review* 63(2), 1973, 134–139 — so
  the `Named:` line is the copy that was wrong, and it now says what the other two say. Jensen and
  Meckling, the more cited development, stays named in the entry with its volume and pages.

- **Every doctrine document's `Named:` line now links to the lineage**, which is the fourth place a
  citation is printed and the first one reachable from where the rule is applied. One link per
  document, to the work it is named from first; the one-or-two-work cap on the line is unchanged, so
  no document becomes a bibliography. `README.md`, `ARCHITECTURE.md` §1, `CONTRIBUTING.md` and the
  pull-request template say what an addition now owes: the entry, carrying the work's own scope and
  its field's objection. No frontmatter was touched, so no skill description moves and nothing is
  reinstalled.

- **`doctrine/README.md` no longer restates what counts as a publish.** "A publish that a merge
  triggers is still a publish, because the job keys on the push, not on the paths" was the narrower
  form `doctrine/warp.md` generalized in `b348ac9` — a second statement of a rule, and by then a
  stale one. The index points at the document instead.

- **The register's name-cells are now a handle, a short cite and one clause, the cite linking to its
  entry.** The prose describing each work moved to `LINEAGE.md`; it did not get copied there. The
  longest cell dropped from 2,026 characters to 1,202, and every cell is now under 180 characters
  per name. **The departure column is untouched**: the admitter's reading, and the only place
  a departure is stated.

- **"Printed in three places" is now "Printed in four places"**, with the fourth reader named: the
  one who has stopped arguing with the rule and started arguing with its origin. The exemption that
  licenses the copies is unchanged, because what licenses it — a citation being dated and
  immutable — does not care how many copies there are. `INDUCTION.md`'s *Proposing an addition*
  now asks for the lineage entry alongside the name and the work.

- **The doctrine's rules did not change.** No rule was added, removed, softened or lengthened,
  and no document under `doctrine/` was touched, so no skill description moves and nothing is
  reinstalled.

- **`doctrine/clean-code.md`, `doctrine/testing.md` and `doctrine/warp.md` gain the last four of the
  nine claims the audit held back.** All four were earned in a tenant and are stated here with the case
  left behind, per `INDUCTION.md` condition 3. **The test for a second copy of a derivable fact is not
  whether it is accurate today but who keeps it accurate** — a copy a command recomputes is a cache with
  an invalidation, and a copy a person has to remember to rewrite is a replica with no replication
  protocol: no acknowledgement, no retry, and divergence nothing detects (Gray, Helland, O'Neil and
  Shasha, 1996), which is DRY's existing rule given the question that decides a case. **A passing run is
  evidence about what it executed, which is not always what you changed** — where a test resolves its
  inputs through the environment it can exercise code that is not the code under test, and the green
  tick answers a question nobody asked. That is a failure of construct validity (Cronbach and Meehl,
  1955; the standard treatment is Cook and Campbell, 1979), and it is worse here than in the field that
  named it: a badly constructed survey yields a number somebody can argue with, while an invalid test
  yields a pass, which is the one output nobody re-examines. It is distinct from the oracle problem the
  same document already states — there the judgement is too weak to decide a real result, here the
  judgement is sound and the result came from somewhere else. **An automated action fires on its declared condition, not on what
  you think you changed** — `warp.md`'s publish-on-merge sentence is generalized in place rather than
  restated in `git.md`, which would have been the second home condition 5 refuses; the failure is an
  automation surprise (Sarter and Woods, 1995) and the remedy is to read the declaration, blast radius
  being a property of the mechanism rather than of a diff. **And a procedure handed to a person to
  execute is not a transaction** — a sequence carries no all-or-nothing guarantee, so partial execution
  is a state nobody designed (atomicity; Gray, 1981), and since rollback is unavailable the form that
  is available is irreducibility: one act whose partial execution is not meaningful, the sequence behind
  it, the place a procedure is valid in named inside the act rather than in the prose above it — a
  forcing function, or poka-yoke (Shingo, 1986; Norman, 1988). Three register rows state the departures,
  of which two matter: Sarter and Woods wrote about a system whose state the operator cannot see, where
  every trigger here is declared and readable, so the claim is weaker and the failure less forgivable;
  and atomicity is borrowed without the mechanism that makes it true.

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
