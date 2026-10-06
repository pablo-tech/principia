# Induction

*Latin inductio, a leading-in. Both senses are meant: the inference that climbs from particular
cases to a general claim, and the ceremony by which a body admits a member on stated terms. A rule
arrives here by the first and is admitted only by the second.*

**A rule is admitted to [`doctrine/`](doctrine/) only when it can be named and cited — stated as an
instance of a principle the wider field already knows, in the strongest form that field states it,
and attributed to a specific prior work a reader can go and get.** Not *resembles*, not *is in the
spirit of*, and not a practice area either: the name the literature uses, and under it an author, a
title and a year. Everything else this document asks is ordinary hygiene. That one condition is the
reason the directory is short.

**And the citation is printed where the rule is stated.** Under the document's own opening line, and
in the statement of the doctrine in [`README.md`](README.md), called out in the form the field
recognizes it by — not filed only in the register at the foot of this page. A lineage kept in one
file that nobody opens under pressure is a bibliography. A lineage printed above the rule is a
standing invitation to go and argue with something older and better argued than this repository,
which is the only reason to have one.

Admission is deliberately expensive, because the cheap way to grow a standard is to write down
whatever the last incident taught you. A standard grown that way is a list of scars. It is
unarguable, since nobody outside the room knows what the scar is; it is unbounded, since there is
always another incident; and it is unteachable, because a reader who has not been injured the same
way cannot tell a law from a bruise.

## Why the name is the load-bearing condition

**A rule nobody can name is a rule nobody can argue with.** That is not a strength, though it reads
as one. Four things the name does that nothing else here can:

**It imports the counter-arguments.** A named principle arrives with a literature: the cases where
it is known to fail, the costs it is known to carry, the practitioners who think it is wrong. That
inheritance is the point — a rule admitted with its objections attached can be applied by someone
who has to weigh it against something else, which is the only situation in which a rule is ever
actually used. A rule invented here arrives with no objections, so it cannot lose an argument, so it
is never tested. A rule named but *uncited* fails the same way with better
manners: it arrives with the authority of a literature and none of its contents, and nobody can go
and read what the objections were.

**It exposes re-invention, which is the usual case.** Most of what a practitioner discovers under
pressure has been named for decades, and once it is named the correct response is almost never a new
document. It is a sentence inside the document that already owns the subject, or nothing at all,
because the principle was already here and the discovery was a second instance of it. A directory
that grows every time someone rediscovers *single source of truth* is measuring its author's reading
rather than the field.

**It separates a principle from a habit.** *Domain-driven design* holds that a model is expressed in
one deliberate language, and that the language is shared with the people whose domain it is — Eric
Evans, 2003, where it is called **ubiquitous language**. "The glossary is a file at the project
root, and a term used against it is challenged in the change that used it" is not that principle; it
is one way of applying it, in a repository, with the tools this one has. The first belongs in
`doctrine/`. The second belongs in the document as the mechanism paragraph it is, and would be
replaced without ceremony by a better mechanism tomorrow. Collapsing the two is how a standard ends
up asserting that the field's wisdom is to keep a file at a particular path.

**It makes the rule portable past the situation that produced it**, which is exactly what the italic
line under each document's heading already claims. Naming is where that claim is checked rather than
asserted.

And *strongest form* closes the obvious evasion. A weak paraphrase is easy to agree with and commits
nobody; the field usually states its principles harder than a practitioner wants to live with. Where
this repository is not willing to go as far as the canonical form, **that gap is the most
interesting sentence in the document** and has to be written down as a departure rather than
smoothed into agreement.

## A name is not yet a citation

A name is a handle; the work is what the handle refers to, and only one of the two can be checked.
*Shift left*, *as-built documentation*, *provenance*, *defence in depth* — each is a real term with
real content, and not one of them is a citation. A practice area has no author to disagree with, no
year to date it from, and no text that might turn out to say something narrower than the person
quoting it. **A row that names a practice and stops there has not met condition 1.** Find who wrote
it down first, or wrote it well enough that the field cites them, and name that.

Three tests, and a term passes all three or it is unnamed:

- **It has an author, a title and a year.** A paper, a book, a report, a standard, a contract form,
  a letter — anything with a text somebody could read back to you. "Standard practice" is not one;
  folklore is not one; a textbook that restates a work without being it is not one either.
- **It is the work the field cites, not the earliest antecedent the search turns up.** The citation
  is for recognition, and a reader who already knows the principle has to see it at a glance. The
  end-to-end argument is cited as Saltzer, Reed and Clark, 1984 though the layering argument is
  older; Rice's theorem is cited as Rice, 1953 though Turing, 1936 is underneath it. Chasing priority
  past the recognizable form is scholarship and buys this repository nothing. Name the work the field
  names, and say what it rests on only where a reader needs it.
- **A survey counts when the survey is the recognizable form.** The oracle problem is cited as Barr,
  Harman, McMinn, Shahbaz and Yoo, 2015, because that survey is where the field settled the term. A
  survey standing in for a specific work that is itself famous is the lazy case and is not this one.

**The condition reaches inside the document, not only its headline.** A document names more terms
than the one it is admitted under — *F.I.R.S.T.*, *the Boy Scout rule*, *a decision record*, all
three of which stood uncited here for as long as this file has existed — and a handle used in the
prose borrows exactly as much authority as a handle in the register, so it owes exactly as much. Two
consequences. Such a term is cited **beside the sentence that uses it** — the bullet or the section,
which is "printed where the rule is stated" applied at the scale the term actually operates at — and
again in the **register row**, which carries the full lineage. It is *not* added to the `Named:`
line, which "What a name is not" caps at one or two works and which is reserved for the principle the
document is admitted under — the one exception being a handle that is the document's own *title*,
named nowhere else and so named there. And one copy per document is the whole of it: a second mention
thirty lines from the first has the same reader as the first, which is the ordinary duplication
[`doctrine/clean-code.md`](doctrine/clean-code.md) refuses and not the exemption below. That file is
both cases at once — the title is Martin's and its `Named:` line says so, which is also the citation
for the Boy Scout rule further down, so the rule is not cited again beside itself.

## What a name is not

- **Not an argument.** A citation establishes that a claim is known, not that it is right, and
  "Parnas said so" is worth nothing here. Every document still has to say why the rule holds, in
  terms a reader can refuse.
- **Not a licence to import a literature.** One or two names, stated once, with enough context to
  look them up. A document that becomes a reading list has stopped being doctrine.
- **Not satisfied by an adjacent name.** If the best-known form is about something else and the
  resemblance is metaphorical, say that, and say what work the metaphor is doing. A borrowed name
  used loosely is worse than no name: it smuggles in authority that was earned somewhere else.
- **Not waived when nothing is found.** The condition is the best *knowable* form, so the search is
  part of the work rather than a bibliography added at the end. A rule nobody has written down may
  still be admitted — the field is not finished — but the document says plainly, in those words,
  that **no prior work was found**. That is a falsifiable claim, any reader holding a citation can
  refute it, and such a refutation is a contribution rather than an embarrassment. A term that has a
  name but no work behind it is this case and not the satisfied one.

## Printed in three places, deliberately

Each doctrine document carries a **`Named:`** line directly under its opening discipline line: the
principle in its recognizable form, and the work. [`README.md`](README.md)'s table of the doctrine
carries the same work in its shortest form, in the row that states the rule. The register at the
foot of this page carries the full lineage — every name the rule touches, and the departures.

Three copies of one fact, which [`doctrine/clean-code.md`](doctrine/clean-code.md) would ordinarily
refuse outright. The exemption is narrow enough to state exactly: **a citation is dated and
immutable.** Saltzer and Schroeder, 1975 will not be reissued in 1976, and nothing can make the
three copies disagree except a typo — the one failure mode a reader catches for free. The rule that
two copies drift is about facts that change, and a published work is the single class of fact in this
repository that cannot. Nothing else here gets the exemption.

Each copy is also a different length, for a different reader, which is why none of them is derivable
from another. The document's line is for the person about to apply the rule, who needs to see at a
glance that it is not this repository's invention — one or two works and no more, because a document
that becomes a reading list has stopped being doctrine. The README row is for someone deciding from
the outside, in two minutes, whether to adopt any of this. The register row is for whoever is
deciding whether the rule should exist at all, and is the only one of the three that states the
departure.

[`doctrine/README.md`](doctrine/README.md) carries none of it and points at the documents instead:
it is the index beside them rather than doctrine ([`ARCHITECTURE.md`](ARCHITECTURE.md) §7), so a
citation there would be the fourth copy — the one with no reader of its own.

## Five conditions, and they are conjunctive

1. **It is named and cited**, in the strongest form the field states it, from a specific prior work,
   with its departures declared — and the citation printed where the rule is stated rather than only
   in the register. The three sections above are the whole of this condition, and
   `bin/induction.test.sh` holds the mechanical half of it: a doctrine document with no `Named:`
   line is refused, as is a `Named:` line, a README row or a register row that names no dated work.
2. **It survives both erasures.** Replace every tenant on the machine and the rule still reads the
   same — [`ARCHITECTURE.md`](ARCHITECTURE.md) §1, *doctrine is tenant-free*. Replace every model on
   the machine tomorrow and it is still true — §1 again, *doctrine is model-free*. Those two are
   checked mechanically and completely, by `guards/tenant-guard.sh --scan-tree` and
   `bin/doctrine.test.sh`. Condition 1 is checked in half — whether a dated work is printed is
   mechanical, whether it is the right work is not — and conditions 3, 4 and 5 are review's alone.
3. **It was induced from a particular, and the particular does not come with it.** A principle
   admitted with no case behind it is a slogan, and a case admitted with its particulars is a war
   story. What travels is the general claim; the dated, specific, verifiable instance stays with
   whoever paid for it, which is the same rule that keeps a measurement out. The induction happened,
   and leaving its evidence behind is the price of the rule being about information systems and
   human organization rather than about one afternoon.
4. **Its breach is observable, and cheap to observe.** Say what the world looks like when the rule is
   broken, and say it concretely enough that someone could notice. A rule whose violation is
   indistinguishable from compliance is a preference, however well argued; it is also the shape that
   never gets removed, because nothing can ever show it failing.
5. **It has exactly one home.** [`doctrine/clean-code.md`](doctrine/clean-code.md) is the reason, and
   it applies hardest to this directory: two documents stating one rule produce two slightly
   different rules inside a month. A claim that is mostly an existing document's claim is a sentence
   inside that document, not a new file beside it.

## A principle, a mechanism and a measurement read alike in a diff

Three kinds of sentence, three homes, three half-lives. Filing one as another is the failure this
whole document exists to prevent, and it is invisible in review because all three arrive as prose.

| | What it is | Where it lives | Half-life |
|---|---|---|---|
| **Principle** | a claim about information systems or human organization, true of other tools and in other decades | `doctrine/`, named and cited there and here | decades |
| **Mechanism** | how this repository applies a principle — at this gate, in this shell, with these paths | the document's own mechanism paragraph, `guards/`, `bin/`, `ARCHITECTURE.md` | as long as the tool |
| **Measurement** | what something did on a date, under conditions somebody arranged | the tenant that took it, dated | a season |

The third is settled by `ARCHITECTURE.md` §1 and enforced. The first two are settled by this
document and enforced by review, which is why the register below exists: a row that can only
describe a mechanism is a document that should not have been added.

## The register

**Every document under `doctrine/` has a row here, and `bin/induction.test.sh` refuses a tree where
one does not.** That is the forcing function: a new document cannot be added without naming what it
instantiates and the work it is named from, and neither can be deferred to a reviewer who will not
do it.

It is not a second copy of the doctrine. Each document states its rule for someone about to do the
work; its row states the lineage, for someone deciding whether the rule should exist at all. The
two are read by different people on different days, and neither can be derived from the other.

| Document | Named in its best-known form, and the prior work it is named from | Where this repository departs |
|---|---|---|
| [`planning.md`](doctrine/planning.md) | **Pre-registration** — the hypothesis and the method are declared before the evidence is gathered, so a result cannot be reinterpreted into a prediction (clinical-trials practice, made a condition of publication by the ICMJE in 2004; generalized for the social sciences by Nosek, Ebersole, DeHaven and Mellor, "The preregistration revolution", 2018). **Answer-first exposition** — the conclusion leads and the support follows, because a reader who gets the evidence first has already formed a conclusion of their own (Barbara Minto, *The Pyramid Principle*, 1987; the military states it as *bottom line up front*). | Pre-registration is a norm for experiments; here it is a gate on an ordinary work plan, and the thing pre-registered is the goal rather than a hypothesis. The stronger form — a plan whose phases cannot be renegotiated once approved — this repository deliberately does not take: [`warp.md`](doctrine/warp.md) enumerates the reasons to stop instead. |
| [`testing.md`](doctrine/testing.md) | **Falsifiability** — a claim that no observation could contradict is not a claim about the world (Karl Popper, *Logik der Forschung*, 1934; in English, *The Logic of Scientific Discovery*, 1959), which is what "a test must be able to fail" is an instance of. **One factor at a time** — a comparison with two differences has two candidate causes and no way to choose (R. A. Fisher, *The Design of Experiments*, 1935). **The oracle problem** — deciding whether an output is *correct* is a different and harder question than deciding whether it is well formed (Barr, Harman, McMinn, Shahbaz and Yoo, "The Oracle Problem in Software Testing: A Survey", 2015, which is where the field settled the term). **F.I.R.S.T.** — fast, independent, repeatable, self-validating, timely: the properties a test needs before it is worth running (Robert C. Martin, *Clean Code*, 2008, where the acronym is credited to Tim Ottinger and Brett Schuchert). **Test-driven development** — the test is written before the code it pins, so it cannot pass vacuously (Kent Beck, *Test-Driven Development: By Example*, 2002). | Fisher's remedy for several factors is a factorial design that varies them together and recovers the effects statistically. Here the remedy is serial: one knob per diff, each with its own pass. The reason is that a change to a system is not a replicated trial — there is one unit, run once — so the design that buys efficiency from replication has nothing to buy it with. Martin's acronym is quoted here with four of its five letters: *timely* is stated as its own rule beneath the list, because it is about when a test is written where the other four are properties of the test itself, and *isolated* is used for his *independent*. Of Beck only the red-first half is taken — nothing here asks that a design be allowed to emerge from its tests, which is the larger claim and the contested one. |
| [`clean-code.md`](doctrine/clean-code.md) | **Don't repeat yourself** — every piece of knowledge has one authoritative representation (Andrew Hunt and David Thomas, *The Pragmatic Programmer*, 1999), whose database form is older and sharper: a value stored twice admits an update anomaly, which normalization exists to remove (E. F. Codd, "A Relational Model of Data for Large Shared Data Banks", 1970). **Ubiquitous language** — one deliberate vocabulary, shared with the domain's own people (Eric Evans, *Domain-Driven Design*, 2003). **Separation of concerns** and **information hiding** (Edsger Dijkstra, "On the role of scientific thought", 1974; David Parnas, "On the Criteria To Be Used in Decomposing Systems into Modules", 1972) for small single-purpose units. **The broken-windows theory**, borrowed into software as *don't live with broken windows* (James Q. Wilson and George Kelling, "Broken Windows", *The Atlantic*, 1982; Hunt and Thomas again), for why sediment accumulates. **The Boy Scout rule** — leave what you touch cleaner than you found it — and the name of the document itself are Robert C. Martin's (*Clean Code*, 2008). | Codd's anomalies are repaired by a schema that makes the second copy impossible; prose has no schema and no transaction, so the only available form of the rule is to drop the stored copy and leave the fact to the command that answers it. Evans's ubiquitous language asks for a shared vocabulary; this repository additionally requires the **refused synonyms** to be written down, because a definition alone leaves a drifting second name reading as a third concept. Martin states the Boy Scout rule without a bound; here it is bounded by the change that touched the file, because the unbounded form licenses exactly the refactor-on-the-way this document otherwise refuses. |
| [`git.md`](doctrine/git.md) | **The end-to-end argument** — a function belongs at the endpoint that holds the information, not in the middle of the network, which is why a size ceiling is enforced where the commit is made rather than where the push arrives (Jerome Saltzer, David Reed and David Clark, "End-to-End Arguments in System Design", 1984). **Shift left** — move a check earlier, toward the point where the defect is cheap (Larry Smith, "Shift-Left Testing", *Dr. Dobb's Journal*, 2001, where the term was coined; the cost curve underneath it is Barry Boehm, *Software Engineering Economics*, 1981). **Provenance** — a change carries the record of what authorized it (the archival sense, codified as *respect des fonds* by Muller, Feith and Fruin, *Handleiding voor het ordenen en beschrijven van archieven* — the Dutch Manual — 1898). **Convergence to a declared state** — a system is held to a written specification by something that repeatedly reconciles it, rather than to the residue of whoever configured it last (Mark Burgess, "A Site Configuration Engine", 1995). **The robustness principle and its reconsideration** — be conservative in what you send, be liberal in what you accept (Jon Postel, RFC 760, 1980, restated as a requirement in RFC 1122, 1989); liberal acceptance conceals the error, so the defect propagates until it is the specification everything is written against (Eric Allman, "The Robustness Principle Reconsidered", *ACM Queue*, 2011). | The end-to-end argument is about correctness: the endpoint is the only place a check *can* be complete. The argument here is about reversibility — both ends can measure a blob, but only one of them has not yet written it into history. That is a cost asymmetry rather than a completeness one, and it points the same way for a different reason, which is worth saying out loud because the two diverge whenever the expensive end is also the only informed one. **And *respect des fonds* is a borrowed name, used here as a metaphor and declared as one.** The archival principle is about custody — the records of one creator are kept together and never intermingled with another's — not about what authorized a change. What transfers is the half that a pull request needs: a record detached from its origin is worth less than the same record carrying it, which is why the authorizing phase is quoted into the body rather than linked from it. A closer work for the authorization half would be better than this one, and naming it is the contribution to make. **And Postel is cited to be declined, not applied.** The robustness principle is sound where it was stated — between implementations that cannot coordinate, leniency buys deployment nobody could otherwise have had — so what this document does is refuse it in the case where that justification is absent: one owner on both ends, with the coordination available. Naming the strong form of the counter-argument rather than the original is deliberate, because the original is the version everybody already agrees with. Nothing mechanical holds this one: a stale reference that still resolves is a silent success, and no check can be written for a success. |
| [`as-built.md`](doctrine/as-built.md) | **As-built documentation** — the record is corrected to what was actually constructed, not to what was drawn (the obligation is contractual before it is editorial: AIA Document A201, *General Conditions of the Contract for Construction*, §3.11, which requires a record set marked to show the work as actually executed). **Stop the line** — a defect is corrected where and when it is found rather than queued, because queueing it multiplies what is built on top of it (Taiichi Ohno, *Toyota Production System*, 1978, on *jidoka* and the andon cord). **The architecture decision record** — the reasoning behind a decision is written where whoever later meets the decision will be standing (Michael Nygard, "Documenting Architecture Decisions", 2011). **Accepted risk** — an exposure that will not be remediated is entered in the record with that decision attached rather than omitted because nothing was done about it (ISO 31000:2018, *Risk management — Guidelines*). **Falsifiability** — a claim no observation could contradict is not a claim about the world (Karl Popper, *Logik der Forschung*, 1934), which `testing.md` names for tests and which this document applies to the comparative sentences a document makes about itself. | Stop-the-line halts production. Nothing here halts: the correction is required *in the change that found it*, which is the smallest unit this repository can stop. The stronger industrial form — stop everything until the cause is removed — is not available to one person with one working tree, and claiming it would be the kind of borrowed authority this document refuses. Nygard's record is a template of four headings; the required form here is three sentences, with a three-part gate on whether a record is earned at all, because a template filled in for completeness is how the sentences that matter end up on page two. **Popper is used for more than he asks.** His criterion separates claims about the world from claims that are not, and demands nothing about evidence accompanying one; this document demands that the means of falsifying a comparative claim ship beside it. The ground for the stronger form is not Popper but the authorship: the party making the claim and the party publishing it are the same one, so the claim will not be contradicted by anyone with an incentive to try. **Accepted risk is applied as stated**, with one narrowing — the standard supposes an organization with a risk register, and what is available here is the as-built document itself, which is why the decision is attached to the rule rather than filed somewhere a reader of the rule would not look. |
| [`warp.md`](doctrine/warp.md) | **Mission command** — the superior fixes the intent and the constraints, the subordinate chooses the means, because the person at the point of contact has information the plan never had (Helmuth von Moltke, *Verordnungen für die höheren Truppenführer* — "Instructions for Large Unit Commanders" — 1869, the written form of Prussian *Auftragstaktik*; current doctrine in several armies, stated as U.S. Army ADP 6-0, *Mission Command*, 2019). **The principal–agent problem** — delegation creates a divergence of interest and information that has to be bounded in advance rather than supervised continuously (Stephen Ross, "The Economic Theory of Agency: The Principal's Problem", 1973; Michael Jensen and William Meckling, "Theory of the Firm: Managerial Behavior, Agency Costs and Ownership Structure", 1976). **One-way and two-way doors** — the reversibility of a decision, not its size, sets how much deliberation it deserves (stated this way by Jeff Bezos in the letter to shareholders for 2015). | Mission command bounds delegation by *intent*; here it is bounded by a document whose phases, doors and rollback are written down before approval, which is a narrower and more auditable thing than intent and does not survive genuine surprise as well. The compensation is the enumerated list of reasons to stop — an explicit re-contracting point, which mission command deliberately does not provide. |
| [`tenancy.md`](doctrine/tenancy.md) | **Complete mediation** — every access is checked, so an unmediated path is unprotected whatever the policy says. **Fail-safe defaults** — the default is denial, and absence of a permission is a refusal. **Least privilege** (all three: Jerome Saltzer and Michael Schroeder, "The Protection of Information in Computer Systems", 1975, which is also where *economy of mechanism* comes from, and is why the chain is small enough to audit in one sitting). **Data minimization** — material that is not present cannot leak, which is the only control that survives an adversary with administrative access (Ann Cavoukian, *Privacy by Design: The 7 Foundational Principles*, 2009; now statutory, as GDPR Article 5(1)(c), 2016). **Rice's theorem** — every non-trivial semantic property of a program is undecidable, which is the formal reason no mechanical check decides what a thing is *for* (H. G. Rice, "Classes of Recursively Enumerable Sets and Their Decision Problems", 1953; Turing, 1936 is underneath it). **Separation of policy from mechanism** — the mechanism enforces and the decision that cannot be mechanized is taken elsewhere and expressed as configuration (Roger Levin, Ellis Cohen, William Corwin, Fred Pollack and William Wulf, "Policy/Mechanism Separation in Hydra", 1975). **The trust boundary** — a control reaches the edge of what it is installed in and no further, and enumerating those edges is the work (Adam Shostack, *Threat Modeling: Designing for Security*, 2014). **Preventive and detective controls** — stopping an action and discovering one that was not stopped are different instruments, and a framework specifies both because prevention has a reach and discovery covers what falls outside it (COSO, *Internal Control — Integrated Framework*, 1992). | **The large and deliberate departure: this repository uses a denylist where fail-safe defaults demand an allow-list.** Saltzer and Schroeder are right about the general case, and an allow-list here would be wrong anyway: nobody can enumerate in advance every term their own legitimate work will contain, and a control that refuses unfamiliar material gets bypassed on its first false refusal — after which it protects nothing at all. So the weaker control is chosen knowingly, its gap is stated in [`README.md`](README.md#what-this-does-not-catch) rather than papered over, and the strong form is applied where it does hold: a missing guard fails closed, and an absent policy file means the repository never opted in. **Rice is invoked for what it forbids, not as a proof about these controls.** The theorem is about semantic properties of programs; the controls here match tokens in text, which is weaker ground — the limit is practical before it is theoretical, and a better matcher would move the boundary without removing it. So the citation is doing one job: it ends the search for a cleverer pattern, after which placement is the only variable left. Said plainly, that much of the name is a metaphor. **And the trust-boundary paragraph is complete mediation read backwards, which is strictly weaker than reading it forwards.** Saltzer and Schroeder assume one reference monitor and ask whether every path through it is checked; here there is no single monitor — each root carries its own — and the question is not whether a path is mediated but whether the root was enrolled at all. That weakness is structural rather than chosen: roots that police themselves are what make one separable from another, which is the property being bought. What is available instead of mediation is an inventory, so that *unenrolled* is a value in a record rather than the default reading of silence. COSO's pairing, by contrast, is applied as stated; what the software case adds is only the reason the detective half is so easily left out — the preventive control is automatic, so it feels complete, and the state it leaves behind is an error nowhere. |

## Proposing an addition

Four sentences in the pull request body, which
[the template](.github/PULL_REQUEST_TEMPLATE.md) asks for and
[`CONTRIBUTING.md`](CONTRIBUTING.md) is the rest of:

1. **The name and the work** — the principle in its strongest known form, and the specific prior
   work it is named from, in the form the field recognizes: author, title, year.
2. **The departure**, if there is one, and why this repository takes the weaker or narrower version.
3. **The particular that induced it**, enough to show the rule was earned — and then left behind,
   per condition 3.
4. **What holds it**: a guard, a review, or nothing but the reader, which is the ordinary answer and
   is stated rather than implied.

A rule that cannot get through that is not thereby wrong. It is a mechanism, a measurement, or a
sentence belonging to a document that already exists — and all three of those have somewhere to go.

## Leaving

A rule is removed when it turns out to be a restatement of another (it is folded into it), a
measurement (it goes to the tenant that took it), or wrong (it goes). Nothing is kept as a tombstone
and no section records what used to be here: the commit log is the dated record of what this
repository believed and when, and a deprecation notice in a live document is a second copy of a fact
whose only remaining reader is archaeology.

**Seven documents is not a target and neither is seventy.** The number this directory settles at is
whatever survives the conditions above, and a principle rejected here is not refuted — it is
unnamed, uncited, or not yet stated well enough to be held to.
