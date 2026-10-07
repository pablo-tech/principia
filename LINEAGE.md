# Lineage

Where the doctrine's names come from. One entry per work a rule here is named from: the work
itself, what it claims in its own field, what that field says against it, and the rule that leans
on it.

**This page is not doctrine.** It holds no rule and binds nothing, and it is deliberately not
under [`doctrine/`](doctrine/), because everything there is installed as a skill and this is
scholarship rather than instruction. A reader looking for what to do is in the wrong file. Where
this page and a doctrine document disagree, the document wins and this page is the defect.

**It is not a reading list either.** An entry exists only because a rule here leans on the work,
and `bin/induction.test.sh` refuses an entry that no register row reaches. The converse is held
too: every name in [the register](INDUCTION.md#the-register) resolves to an entry here, so a name
cannot be borrowed without the field's objection to it being printed where a reader can find it.
That judgement is the one this page was built for. [`INDUCTION.md`](INDUCTION.md) admits a rule
partly because a name "imports the counter-arguments"; before this page existed the repository
printed an objection for one of forty-one names.

**Departures are not here.** What this repository narrows, weakens, or takes only half of is in
the register's third column — the admitter's reading, and the only place it is stated. This page
says what each work claims in its own scope; the register says what was done with it.

Grouped by the literature the work comes from, which is part of the exhibit: seven short documents
rest on eleven bodies of work, and the groups are of very unequal size.

## Scientific method and inference

### Falsifiability — Popper, 1934

**The work** — Karl Popper, *Logik der Forschung*, 1934; in English, *The Logic of Scientific
Discovery*, 1959.

**What it claims** — that what separates an empirical claim from an unfalsifiable one is whether
some observation could contradict it, and that a theory earns standing by surviving attempts to
refute it rather than by accumulating confirmations. Its unit of analysis is a theory in a
science, and its target was the claim to scientific status made by psychoanalysis and historical
materialism. The original claim is far wider than the use made of it here: Popper is arguing about
what science *is*, not about how to write a check.

**What the field says against it** — the Duhem–Quine objection is that a prediction is never made
by one hypothesis alone, so a failed observation refutes the conjunction and leaves the choice of
what to abandon open (W. V. O. Quine, "Two Dogmas of Empiricism", 1951). Thomas Kuhn, *The
Structure of Scientific Revolutions*, 1962, argues that working science does not behave this way
at all, and Imre Lakatos, "Falsification and the Methodology of Scientific Research Programmes",
1970, concedes the point and replaces naive falsification with a research programme judged over
time.

**Taken here** — [`doctrine/testing.md`](doctrine/testing.md), for "a test must be able to fail",
and [`doctrine/as-built.md`](doctrine/as-built.md), for the comparative claims a document makes
about itself. Departures stay in [the register](INDUCTION.md#the-register).

### One factor at a time — Fisher, 1935

**The work** — R. A. Fisher, *The Design of Experiments*, 1935.

**What it claims** — that an experiment is a question put to nature, and that a comparison
confounding two differences cannot say which one produced the effect. Its unit of analysis is the
replicated agricultural trial, and randomization plus blocking are what make the inference legal.

**What the field says against it** — Fisher himself, in the same book: he calls the belief that we
must "ask Nature few questions, or, ideally, one question, at a time" *wholly mistaken*, and
argues from 1926 onward that a factorial design varying every factor together is strictly more
informative, because it recovers interactions that no sequence of one-factor trials can see. So
the handle names the diagnosis in Fisher and not the remedy, which is why the register prints a
departure beside it.

**Taken here** — [`doctrine/testing.md`](doctrine/testing.md), for one knob per diff. Departures
stay in [the register](INDUCTION.md#the-register).

### Construct validity — Cronbach and Meehl, 1955

**The work** — Lee Cronbach and Paul Meehl, "Construct Validity in Psychological Tests",
*Psychological Bulletin* 52(4), 1955, 281–302, which is where the term is defined. Donald Campbell
and Donald Fiske, "Convergent and Discriminant Validation by the Multitrait-Multimethod Matrix",
*Psychological Bulletin*, 1959, supplies the procedure for arguing it from a pattern of agreements
between instruments; the standard treatment is Thomas Cook and Donald Campbell,
*Quasi-Experimentation: Design and Analysis Issues for Field Settings*, 1979.

**What it claims** — that whether an instrument measures the thing it names is a separate
question from whether it measures anything precisely, and that the answer is argued from a pattern
of agreements and disagreements with other instruments rather than read off the instrument.

**What the field says against it** — Harold Bechtoldt, "Construct Validity: A Critique",
*American Psychologist*, 1959, argued that the concept licenses a test to be defended by appeal to
a theory the test is also the evidence for, which makes the defence unfalsifiable — the objection
arriving four years later, in the same year as the Campbell and Fiske procedure above.

**Taken here** — [`doctrine/testing.md`](doctrine/testing.md), for a run against a source nobody
checked. Departures stay in [the register](INDUCTION.md#the-register).

### Pre-registration — Nosek, Ebersole, DeHaven and Mellor, 2018

**The work** — Brian Nosek, Charles Ebersole, Alexander DeHaven and David Mellor, "The
preregistration revolution", *PNAS*, 2018. The practice is older than the paper: clinical trial
registration became a condition of publication at ICMJE journals in 2004.

**What it claims** — that declaring the hypothesis and the analysis before the data exist is what
keeps a prediction a prediction, because an analysis chosen after seeing the result cannot be
distinguished from one chosen because of it. Its unit of analysis is a study in a field with
publication incentives, and the failure it addresses is a statistical one.

**What the field says against it** — Aba Szollosi, David Kellen, Danielle Navarro, Richard
Shiffrin, Iris van Rooij, Trisha Van Zandt and Chris Donkin, "Is Preregistration Worthwhile?",
*Trends in Cognitive Sciences*, 2020, argue that it does nothing about the actual problem —
theories too vague to constrain anything — and can entrench a bad design by making it costly to
abandon.

**Taken here** — [`doctrine/planning.md`](doctrine/planning.md), for the plan that fixes its own
phases and verification before the work starts. Departures stay in
[the register](INDUCTION.md#the-register).

## Software engineering and testing

### The oracle problem — Barr, Harman, McMinn, Shahbaz and Yoo, 2015

**The work** — Earl Barr, Mark Harman, Phil McMinn, Muzammil Shahbaz and Shin Yoo, "The Oracle
Problem in Software Testing: A Survey", *IEEE Transactions on Software Engineering* 41(5), 2015,
507–525 — where the field settled the term.

**What it claims** — that deciding whether an output is *correct* is a different and harder
problem than generating the input that produced it, that most of the testing literature's
automation addresses the easier half, and that the oracle is where the cost actually sits.

**What the field says against it** — the field's own answer narrows the problem rather than
disputing it: T. Y. Chen, S. C. Cheung and S. M. Yiu, "Metamorphic Testing: A New Approach for
Generating Next Test Cases", 1998, show that a relation between the outputs of related runs is a
partial oracle, so the absence of an expected value does not leave a run unjudgeable. The claim
that survives is about the whole output, not about every property of it.

**Taken here** — [`doctrine/testing.md`](doctrine/testing.md), for the distinction between a run
that completed and a run that was right. Departures stay in
[the register](INDUCTION.md#the-register).

### F.I.R.S.T. — Martin, 2008

**The work** — Robert C. Martin, *Clean Code*, 2008, where the acronym is credited to Tim Ottinger
and Brett Schuchert: fast, independent, repeatable, self-validating, timely.

**What it claims** — that a test with any of those five properties missing stops being run, and a
test that is not run is not a test. The claim is about a unit test in a codebase with a developer
suite, and it is a claim about the economics of running the suite rather than about correctness.

**What the field says against it** — James Coplien, "Why Most Unit Testing is Waste", 2014, argues
that a suite of fast isolated unit tests buys confidence about units while the defects that matter
are in the interactions between them, so the properties that make a test cheap to run are the ones
that make it unlikely to find anything.

**Taken here** — [`doctrine/testing.md`](doctrine/testing.md), for the properties a test needs
before it is worth having. Departures stay in [the register](INDUCTION.md#the-register).

### Test-driven development — Beck, 2002

**The work** — Kent Beck, *Test-Driven Development: By Example*, 2002.

**What it claims** — two things, and only the first is taken here: that a test written before the
code cannot pass vacuously, because it has been seen to fail; and that a design is better arrived
at by letting it emerge from the tests, which is the larger and contested half.

**What the field says against it** — Davide Fucci, Hakan Erdogmus, Burak Turhan, Markku Oivo and
Natalia Juristo, "A Dissection of the Test-Driven Development Process: Does It Really Matter to
Test-First or to Test-Last?", *IEEE Transactions on Software Engineering*, 2017, found that the
ordering is not what produces the measured effect — granularity and uniformity of the development
cycle are — which removes the usual argument for the prescription while leaving the red-first
mechanism intact.

**Taken here** — [`doctrine/testing.md`](doctrine/testing.md), for a check recorded failing before
the thing it checks exists. Departures stay in [the register](INDUCTION.md#the-register).

### Don't repeat yourself — Hunt and Thomas, 1999

**The work** — Andrew Hunt and David Thomas, *The Pragmatic Programmer*, 1999.

**What it claims** — that every piece of knowledge in a system should have one authoritative
representation, because two representations of one fact will diverge and nothing will say which is
current. The claim is about knowledge, not about text: two identical lines that encode different
facts are not a repetition.

**What the field says against it** — Sandi Metz, "The Wrong Abstraction", 2016, argues that
duplication is cheaper than the wrong abstraction, because the abstraction accretes conditionals
as each caller's needs diverge and nobody is willing to undo it. The practical consequence is that
removing duplication early, before the facts are known to be the same fact, is the more expensive
mistake.

**Taken here** — [`doctrine/clean-code.md`](doctrine/clean-code.md), for a fact stated in one
place. Departures stay in [the register](INDUCTION.md#the-register).

### Ubiquitous language — Evans, 2003

**The work** — Eric Evans, *Domain-Driven Design: Tackling Complexity in the Heart of Software*,
2003.

**What it claims** — that a model is only useful if the code, the conversation and the domain
expert's own speech use one vocabulary, and that translating between a technical name and a
business name is where the model quietly stops matching the domain. Its unit of analysis is a
bounded context, and the claim is explicitly *not* that one vocabulary serves a whole enterprise.

**What the field says against it** — Susan Leigh Star and James Griesemer, "Institutional Ecology,
'Translations' and Boundary Objects", *Social Studies of Science*, 1989, show that cooperation
across communities of practice usually runs through objects that mean something different to each
one, rather than through a shared vocabulary — so insisting on one language can suppress the
difference rather than resolve it.

**Taken here** — [`doctrine/clean-code.md`](doctrine/clean-code.md), for one deliberate vocabulary
shared with the domain's own people. Departures stay in
[the register](INDUCTION.md#the-register).

### The broken-windows theory — Wilson and Kelling, 1982

**The work** — James Q. Wilson and George Kelling, "Broken Windows", *The Atlantic*, 1982;
borrowed into software as *don't live with broken windows* by Hunt and Thomas, 1999.

**What it claims** — that visible, unrepaired disorder signals that nobody is watching, which
invites more of it, so the repair matters out of proportion to the damage. Its unit of analysis is
a neighbourhood and its mechanism is a social one about what residents infer from what they see.

**What the field says against it** — Bernard Harcourt and Jens Ludwig, "Broken Windows: New
Evidence from New York City and a Five-City Social Experiment", *University of Chicago Law
Review*, 2006, found no support for the causal claim once the trends the theory was credited with
are controlled for — one of the clearest cases in the social sciences of a widely adopted
mechanism not surviving measurement.

**Taken here** — [`doctrine/clean-code.md`](doctrine/clean-code.md), for why sediment accumulates.
Departures stay in [the register](INDUCTION.md#the-register).

### The Boy Scout rule — Martin, 2008

**The work** — Robert C. Martin, *Clean Code*, 2008, which also supplies that document's name:
leave what you touch cleaner than you found it.

**What it claims** — that improvement does not need a project, because the cost of a small cleanup
made while already in the file is near zero and the alternative is a cleanup nobody schedules.

**What the field says against it** — Martin Fowler, *Refactoring*, 1999 (second edition 2018),
holds that refactoring and behaviour change are separated, and that mixing them is what makes a
change unreviewable: the reviewer cannot tell which edits were required and which were taken in
passing. Taken literally, the rule asks for exactly that mixture.

**Taken here** — [`doctrine/clean-code.md`](doctrine/clean-code.md), for the cleanup that rides
along with the change that found it. Departures stay in
[the register](INDUCTION.md#the-register).

### Shift left — Smith, 2001

**The work** — Larry Smith, "Shift-Left Testing", *Dr. Dobb's Journal*, 2001, where the term was
coined. The cost curve underneath it is Barry Boehm, *Software Engineering Economics*, 1981.

**What it claims** — that a defect costs more the later it is found, so moving a check earlier is
worth paying for. Boehm's curve is the quantitative half: the cost of repair rising by orders of
magnitude from requirements to operation.

**What the field says against it** — Tim Menzies, Will Nichols, Forrest Shull and Lucas Layman,
"Are delayed issues harder to resolve? Revisiting cost-to-fix of defects throughout the lifecycle",
*Empirical Software Engineering*, 2017, examined the data and found no exponential curve. The
practice may still pay, but not for the reason it is usually given, and the number cited for it is
not supported.

**Taken here** — [`doctrine/git.md`](doctrine/git.md), for the check that runs where the commit is
made. Departures stay in [the register](INDUCTION.md#the-register).

## Data, information and transactions

### The update anomaly — Codd, 1970

**The work** — E. F. Codd, "A Relational Model of Data for Large Shared Data Banks",
*Communications of the ACM* 13(6), 1970, 377–387.

**What it claims** — that a value stored in two places admits an update that reaches one of them,
and that the condition is structural rather than a matter of care: normalization removes the
possibility instead of asking anyone to maintain both copies. This is the older and sharper form
of the same argument the previous entry makes informally, and it comes with a procedure.

**What the field says against it** — Ralph Kimball, *The Data Warehouse Toolkit*, 1996,
deliberately denormalizes for a read-mostly workload, accepting the anomaly because the writes
that would expose it are controlled by one load process. The principle holds; its scope is the
schema whose updates are not funnelled.

**Taken here** — [`doctrine/clean-code.md`](doctrine/clean-code.md), for the test applied to a
derivable fact: not whether the copy is accurate today but who keeps it accurate. Departures stay
in [the register](INDUCTION.md#the-register).

### Atomicity — Gray, 1981

**The work** — Jim Gray, "The Transaction Concept: Virtues and Limitations", *VLDB*, 1981 — the A
in ACID.

**What it claims** — that a transaction is an all-or-nothing unit, so a failure part way through
leaves no state that was not either the start or the end. The corollary, which is what gets
borrowed, is that a sequence which is *not* a transaction has no such guarantee, and its partial
execution is a state nobody designed and nobody has reasoned about.

**What the field says against it** — Dan Pritchett, "BASE: An Acid Alternative", *ACM Queue* 6(3),
2008, argues that in a partitioned system the atomic guarantee across components is bought with
availability — two-phase commit multiplies the participants' failure probabilities — and that
trading it for eventual consistency is the better engineering at scale.

**Taken here** — [`doctrine/warp.md`](doctrine/warp.md), for the procedure whose half-finished
state has to be designed because it cannot be prevented. Departures stay in
[the register](INDUCTION.md#the-register).

### Replication without a replication protocol — Gray, Helland, O'Neil and Shasha, 1996

**The work** — Jim Gray, Pat Helland, Patrick O'Neil and Dennis Shasha, "The Dangers of
Replication and a Solution", *SIGMOD*, 1996.

**What it claims** — that a second copy which nothing reconciles diverges silently, because
divergence is not an event: there is no acknowledgement to miss, no retry to exhaust and no error
to report. The paper's quantitative claim is about lazy replication's reconciliation rate growing
with the cube of the node count, which is why it recommends a protocol rather than a habit.

**What the field says against it** — Bettina Kemme and Gustavo Alonso, "Don't Be Lazy, Be
Consistent: Postgres-R, A New Way to Implement Database Replication", *VLDB*, 2000, showed that
eager replication need not carry the cost the 1996 analysis assigned it once the protocol is built
into the database rather than layered over it.

**Taken here** — [`doctrine/clean-code.md`](doctrine/clean-code.md), for the second copy nothing
reconciles. Departures stay in [the register](INDUCTION.md#the-register).

## Modularity and systems design

### Separation of concerns — Dijkstra, 1974

**The work** — Edsger Dijkstra, "On the role of scientific thought", 1974 (EWD447), collected in
*Selected Writings on Computing: A Personal Perspective*, 1982.

**What it claims** — that the only way to handle a subject of any size is to study its aspects one
at a time, giving each "a more or less monomaniacal attention" while being fully aware that one is
doing so. Dijkstra is careful that this is not a claim that the aspects are independent: it is a
claim about the attention of the person reasoning, which is why he pairs it with the obligation to
remember what has been set aside.

**What the field says against it** — Peri Tarr, Harold Ossher, William Harrison and Stanley
Sutton, "N Degrees of Separation: Multi-Dimensional Separation of Concerns", *ICSE*, 1999 (named
ICSE's Most Influential Paper in 2009), argue that any single decomposition serves one set of
concerns and obstructs the others, so the principle underdetermines the design. Gregor Kiczales
and others, "Aspect-Oriented Programming", *ECOOP*, 1997, made the same case concretely: concerns
that cross-cut the chosen decomposition end up scattered through the code by construction.

**Taken here** — [`doctrine/clean-code.md`](doctrine/clean-code.md), for small single-purpose
units. Departures stay in [the register](INDUCTION.md#the-register).

### Information hiding — Parnas, 1972

**The work** — David Parnas, "On the Criteria To Be Used in Decomposing Systems into Modules",
*Communications of the ACM* 15(12), 1972, 1053–1058.

**What it claims** — that a module's boundary should be drawn around a decision likely to change,
and should expose as little of that decision as possible, so that a change is contained. Parnas's
demonstration is that decomposing by processing step and decomposing by hidden decision produce
different module structures for the same program, and only the second one localizes change.

**What the field says against it** — Butler Lampson, "Hints for Computer System Design", *SOSP*,
1983, states the counter-hint plainly as "don't hide power": an abstraction that conceals what the
underlying layer can do leaves the caller unable to get at the performance or the capability it
needs, and the usual outcome is a bypass around the abstraction rather than a better one.

**Taken here** — [`doctrine/clean-code.md`](doctrine/clean-code.md), alongside separation of
concerns, for what a unit exposes. Departures stay in
[the register](INDUCTION.md#the-register).

### The end-to-end argument — Saltzer, Reed and Clark, 1984

**The work** — Jerome Saltzer, David Reed and David Clark, "End-to-End Arguments in System
Design", *ACM Transactions on Computer Systems* 2(4), 1984, 277–288.

**What it claims** — that a function requiring knowledge held only at the endpoints cannot be
completely implemented in the middle of the network, so an implementation there is at best a
performance optimization and never a guarantee. The paper's canonical example is reliable file
transfer: no amount of hop-by-hop reliability removes the need for an end-to-end check.

**What the field says against it** — Marjory Blumenthal and David Clark, "Rethinking the design of
the Internet: the end-to-end arguments vs. the brave new world", *ACM Transactions on Internet
Technology*, 2001 — Clark revisiting his own argument — hold that it assumed mutually trusting
endpoints, and that once the endpoints are untrusted or the operator is accountable for what
crosses the network, functions legitimately move into the middle.

**Taken here** — [`doctrine/git.md`](doctrine/git.md), for a ceiling enforced where the commit is
made rather than where the push arrives. Departures stay in
[the register](INDUCTION.md#the-register).

### Convergence to a declared state — Burgess, 1995

**The work** — Mark Burgess, "A Site Configuration Engine", *Computing Systems* 8(3), 1995 — the
cfengine paper, and the origin of convergent configuration management.

**What it claims** — that a system should be held to a written specification by something that
repeatedly reconciles it, because any one-shot configuration leaves the machine in the state of
whoever last touched it. Convergence is the property that matters: running the engine again from
any starting state moves the system toward the specification rather than somewhere new.

**What the field says against it** — Steve Traugott and Lance Brown, "Why Order Matters: Turing
Equivalence in Automated Systems Administration", *LISA*, 2002, argue that convergence is not
enough on its own — a system reached by converging from an unknown state is not the same as one
built from a known one, and reproducibility requires the order of operations to be defined, not
just the destination.

**Taken here** — [`doctrine/git.md`](doctrine/git.md), for a tree held to a specification rather
than to the residue of the last change. Departures stay in
[the register](INDUCTION.md#the-register).

### The robustness principle, and its reconsideration — Postel, 1980

**The work** — Jon Postel, RFC 760, 1980 — "be conservative in what you send, be liberal in what
you accept" — restated as a requirement in RFC 1122, 1989. The reconsideration is Eric Allman,
"The Robustness Principle Reconsidered", *ACM Queue*, 2011.

**What it claims** — in its original scope, that an implementation should tolerate variation in
what it receives so that deployment can proceed without every peer being correct first. It is a
claim about interoperability during incremental deployment, not about error handling generally.

**What the field says against it** — Allman's argument, which this repository takes as the
operative one, is that liberal acceptance conceals the sender's defect until the defect is the de
facto specification everything is written against. The IETF has since adopted that reading: RFC
9413, "Maintaining Robust Protocols", 2023, recommends active maintenance and intolerance of
unnecessary variation in place of the original advice.

**Taken here** — [`doctrine/git.md`](doctrine/git.md), for refusing malformed input at the
boundary rather than repairing it. Departures stay in
[the register](INDUCTION.md#the-register).

## Security and protection

### Complete mediation — Saltzer and Schroeder, 1975

**The work** — Jerome Saltzer and Michael Schroeder, "The Protection of Information in Computer
Systems", *Proceedings of the IEEE* 63(9), 1975, 1278–1308 — the paper that states eight design
principles for protection mechanisms, three of which this repository names and a fourth of which
(*economy of mechanism*) it relies on without naming.

**What it claims** — that every access to every object must be checked for authority, and that
the design should not permit a path by which an access reaches an object without passing the
check. The authors are explicit that the expensive consequence is caching: remembering a previous
authorization decision is the usual performance fix and the usual hole.

**What the field says against it** — the standard concrete objection is the time-of-check to
time-of-use gap, characterized by Matt Bishop and Michael Dilger, "Checking for Race Conditions in
File Accesses", *Computing Systems* 9(2), 1996, 131–152: a check and the access it authorizes are
separated in time, and if the binding of name to object can change in between, mediation at the
check does not mediate the access.

**Taken here** — [`doctrine/tenancy.md`](doctrine/tenancy.md), for why an unmediated path is
unprotected whatever the policy says. Departures stay in
[the register](INDUCTION.md#the-register).

### Fail-safe defaults — Saltzer and Schroeder, 1975

**The work** — Saltzer and Schroeder, 1975, as above; this is the second of their eight
principles.

**What it claims** — that the default should be lack of access, so that a design error or an
omission in the policy produces a refusal rather than an exposure. The asymmetry is the argument:
a mistakenly refused access is reported by the user who needed it, while a mistakenly permitted
one is reported by nobody.

**What the field says against it** — Cormac Herley, "So Long, And No Thanks for the Externalities:
The Rational Rejection of Security Advice by Users", *NSPW*, 2009, 133–144, shows that a control
whose cost to the person it is imposed on exceeds the harm it averts is rationally rejected, and
denial by default is the archetypal such control: its cost is paid continuously by everyone with
legitimate work to do, and the usual response is a blanket exemption that is worse than the
default would have been.

**Taken here** — [`doctrine/tenancy.md`](doctrine/tenancy.md), for absence of a permission being a
refusal. Departures stay in [the register](INDUCTION.md#the-register).

### Least privilege — Saltzer and Schroeder, 1975

**The work** — Saltzer and Schroeder, 1975, as above; the third of the three this repository names.

**What it claims** — that every program and every user should operate with the least set of
privileges necessary to complete the job, which bounds the damage from an accident as much as from
an attack, and reduces the number of privileged interactions that have to be reasoned about.

**What the field says against it** — Fred Schneider, "Least Privilege and More", *IEEE Security &
Privacy* 1(5), 2003, 55–59, observes that the principle names an optimum without giving any
procedure for finding it: determining the least sufficient set for a real program is hard in
practice and, for application-specific policies, hard in theory — so in use it degenerates into
whatever set was convenient to grant.

**Taken here** — [`doctrine/tenancy.md`](doctrine/tenancy.md), for the privileges a guard runs
with. Departures stay in [the register](INDUCTION.md#the-register).

### Separation of policy from mechanism — Levin, Cohen, Corwin, Pollack and Wulf, 1975

**The work** — Roger Levin, Ellis Cohen, William Corwin, Fred Pollack and William Wulf,
"Policy/Mechanism Separation in Hydra", *SOSP*, 1975.

**What it claims** — that a kernel should supply mechanisms that enforce, and leave the decisions
those mechanisms enforce to be expressed from outside, because a decision frozen into a mechanism
cannot be changed by whoever turns out to own it.

**What the field says against it** — Ray Spencer, Stephen Smalley, Peter Loscocco, Mike Hibler,
David Andersen and Jay Lepreau, "The Flask Security Architecture: System Support for Diverse
Security Policies", *USENIX Security*, 1999, found the separation harder than stated: supporting
policies that change requires the mechanism to participate in revocation of an authority it has
already granted, which is a mechanism obligation derived from the policy and not independent of
it.

**Taken here** — [`doctrine/tenancy.md`](doctrine/tenancy.md), for the decision that cannot be
mechanized being expressed as configuration. Departures stay in
[the register](INDUCTION.md#the-register).

### The trust boundary — Shostack, 2014

**The work** — Adam Shostack, *Threat Modeling: Designing for Security*, 2014.

**What it claims** — that a control reaches the edge of what it is installed in and no further,
and that the work of threat modelling is enumerating those edges and asking what crosses each one.
The scope is a system under design, and the method's claim is about coverage rather than about
severity.

**What the field says against it** — Riccardo Scandariato, Kim Wuyts and Wouter Joosen, "A
descriptive study of Microsoft's threat modeling technique", *Requirements Engineering*, 2015,
measured the technique in use and found a high rate of false positives and a correctness that
depended heavily on the analyst — so the enumeration is not the mechanical step the method
presents it as.

**Taken here** — [`doctrine/tenancy.md`](doctrine/tenancy.md), for enumerating the edges a control
does not reach. Departures stay in [the register](INDUCTION.md#the-register).

### Data minimization — Cavoukian, 2009

**The work** — Ann Cavoukian, *Privacy by Design: The 7 Foundational Principles*, 2009; now
statutory as GDPR Article 5(1)(c), 2016.

**What it claims** — that material which is not collected cannot be breached, so the strongest
privacy control is the absence of the data, and that this is the only control which survives an
adversary holding administrative access to the system that would otherwise protect it.

**What the field says against it** — Seda Gürses, Carmela Troncoso and Claudia Diaz, "Engineering
Privacy by Design", 2011, argue that the principles are stated at a level that gives an engineer
nothing to build: they name goals without the mechanisms or the adversary model that would decide
between designs, and in practice get satisfied by compliance language rather than by architecture.

**Taken here** — [`doctrine/tenancy.md`](doctrine/tenancy.md), for the terms that are never
written into a tracked file. Departures stay in
[the register](INDUCTION.md#the-register).

### Attested provenance — Torres-Arias, Afzali, Kuppusamy, Curtmola and Cappos, 2019

**The work** — Santiago Torres-Arias, Hammad Afzali, Trishank Karthik Kuppusamy, Reza Curtmola and
Justin Cappos, "in-toto: Providing farm-to-table guarantees for bits and bytes", *28th USENIX
Security Symposium*, 2019, 1393–1410. The register asked in writing for a work closer than the
archival principle for the authorization half of provenance, and this is the answer to that.

**What it claims** — that a chain is not secured by trusting the artifact at the end of it, but by
requiring every step to be attested by whoever was authorized in advance to perform it, against a
layout declaring who may do what. Its unit of analysis is the step and its signer, which is the
thing the archival principle has no account of: the Manual says where a record belongs, not who was
entitled to make it.

**What the field says against it** — Mahzabin Tamanna, Sivana Hamer, Mindy Tran, Sascha Fahl,
Yasemin Acar and Laurie Williams, "Analyzing Challenges in Deployment of the SLSA Framework for
Software Supply Chain Security", 2024, read 1,523 issues across 233 repositories and found adoption
turning on complex implementation and unclear communication rather than on any disagreement with
the design — a mechanism mostly unreached, which is the objection that bites hardest where there is
nobody to run it.

**Taken here** — [`doctrine/git.md`](doctrine/git.md), for the authorization half of a change that
carries the record of what authorized it: the pull request quotes the phase that authorized it
rather than linking to it, and the merge is what attests the step. Departures stay in
[the register](INDUCTION.md#the-register).

## Risk and internal control

### Accepted risk — ISO 31000, 2018

**The work** — ISO 31000:2018, *Risk management — Guidelines* (first published 2009).

**What it claims** — that risk acceptance is one of the available treatments, equal in standing to
avoidance and mitigation, and that it is a recorded decision with an owner rather than the absence
of a decision. The standard's contribution to this repository is procedural: the register entry
survives the treatment choice, so an exposure nobody acted on is still in the record.

**What the field says against it** — Matthew Leitch, "ISO 31000:2009 — The New International
Standard on Risk Management", *Risk Analysis* 30(6), 2010, 887–892, argues that the standard's
central definitions are ambiguous and that it is not mathematically rigorous enough to be followed
consistently — two readers applying it reach different answers, which is a poor property for a
document whose purpose is comparability.

**Taken here** — [`doctrine/as-built.md`](doctrine/as-built.md), for an exposure entered in the
record with its decision attached rather than omitted because nothing was done. Departures stay in
[the register](INDUCTION.md#the-register).

### Preventive and detective controls — COSO, 1992

**The work** — Committee of Sponsoring Organizations of the Treadway Commission, *Internal
Control — Integrated Framework*, 1992 (revised 2013).

**What it claims** — that stopping an action and discovering one that was not stopped are
different instruments with different reaches, and that a control environment specifies both,
because prevention covers what it was designed for and detection covers what falls outside it.

**What the field says against it** — Michael Power, *The Audit Explosion*, 1997, and at length in
*The Audit Society*, 1997, argues that frameworks of this kind produce auditable traces rather
than control: the organization reorganizes itself around what can be shown to an inspector, and
the ritual of verification displaces the thing being verified.

**Taken here** — [`doctrine/tenancy.md`](doctrine/tenancy.md), for a guard that refuses paired
with a sweep that finds what the guard did not reach. Departures stay in
[the register](INDUCTION.md#the-register).

## Computability and its limits

### Rice's theorem — Rice, 1953

**The work** — H. G. Rice, "Classes of Recursively Enumerable Sets and Their Decision Problems",
*Transactions of the American Mathematical Society* 74(2), 1953, 358–366; Alan Turing, "On
Computable Numbers, with an Application to the Entscheidungsproblem", 1936, is underneath it.

**What it claims** — that every non-trivial semantic property of a program is undecidable: there
is no algorithm which, given a program, decides a question about what the program *does* rather
than about how it is written. This is the formal reason that no mechanical check decides what a
thing is *for*.

**What the field says against it** — not a refutation but a bound on what the theorem forbids:
Patrick Cousot and Radhia Cousot, "Abstract Interpretation: A Unified Lattice Model for Static
Analysis of Programs by Construction or Approximation of Fixpoints", *POPL*, 1977, 238–252, show
that a sound over-approximation of a semantic property is decidable and useful. Undecidability
rules out an exact answer, not a conservative one, so "no mechanical check can do this" is a
stronger claim than the theorem supports unless exactness is required.

**Taken here** — [`doctrine/tenancy.md`](doctrine/tenancy.md), for why a guard checks what a file
contains and a person decides what it is for. Departures stay in
[the register](INDUCTION.md#the-register).

## Organization, delegation and behaviour

### Mission command — Moltke, 1869

**The work** — Helmuth von Moltke, *Verordnungen für die höheren Truppenführer* — "Instructions
for Large Unit Commanders" — 1869, the written form of Prussian *Auftragstaktik*; current doctrine
in several armies, stated as U.S. Army ADP 6-0, *Mission Command*, 2019.

**What it claims** — that an order should not go beyond what the situation can be foreseen to
hold: "one does well to order no more than is absolutely necessary and to avoid planning beyond
the situation one can foresee." The higher the authority the shorter and more general the order,
with the next level adding what precision it needs, so that each retains freedom of decision
within its own authority. The claim rests on an information asymmetry: the subordinate at the
point of contact knows things the plan could not.

**What the field says against it** — Eitan Shamir, *Transforming Command: The Pursuit of Mission
Command in the U.S., British, and Israeli Armies*, 2011, traces the adoption of the doctrine in
three armies and finds it largely rhetorical: organizations that had adopted the vocabulary
retained centralized practice, because the conditions mission command needs — shared training, a
tolerance for subordinate error, and trust built in advance — are much harder to install than the
terminology.

**Taken here** — [`doctrine/warp.md`](doctrine/warp.md), for intent and constraints fixed in the
plan and the means chosen at the point of contact. Departures stay in
[the register](INDUCTION.md#the-register).

### The principal–agent problem — Ross, 1973

**The work** — Stephen Ross, "The Economic Theory of Agency: The Principal's Problem", *American
Economic Review* 63(2), 1973, 134–139, which is the formulation the name belongs to. Michael Jensen
and William Meckling, "Theory of the Firm: Managerial Behavior, Agency Costs and Ownership
Structure", *Journal of Financial Economics* 3(4), 1976, 305–360, is the more cited development,
and the one a reader is likelier to have met.

**What it claims** — that delegation creates a divergence of both interest and information, that
the divergence cannot be removed by watching harder because the monitoring is itself costly and
incomplete, and that the remedy is in the structure of the arrangement agreed beforehand.

**What the field says against it** — Sumantra Ghoshal, "Bad Management Theories Are Destroying
Good Management Practices", *Academy of Management Learning & Education*, 2005, argues that agency
theory's assumption of opportunism is self-fulfilling: designing an arrangement around the
expectation that the agent will defect produces the behaviour it was built to contain, and the
theory's spread did measurable damage on that mechanism.

**Taken here** — [`doctrine/warp.md`](doctrine/warp.md), for delegation bounded in advance rather
than supervised continuously. Departures stay in
[the register](INDUCTION.md#the-register).

### One-way and two-way doors — Bezos, 2015

**The work** — Jeff Bezos, Amazon letter to shareholders for 2015: Type 1 decisions are
consequential and near-irreversible — one-way doors — and deserve deliberation; Type 2 decisions
are reversible, two-way doors, and should be made quickly by small groups.

**What it claims** — that reversibility rather than size sets how much deliberation a decision
deserves, and that the characteristic organizational failure is applying the heavyweight process
to the reversible case, which buys slowness and risk aversion and loses the experiments.

**What the field says against it** — Barry Staw, "Knee-Deep in the Big Muddy: A Study of
Escalating Commitment to a Chosen Course of Action", *Organizational Behavior and Human
Performance*, 1976, showed that commitment to a chosen course increases after negative feedback,
particularly for whoever chose it. A door being physically two-way does not make it behaviourally
two-way: the decision is reversible and the decider is the one who will not reverse it.

**Taken here** — [`doctrine/warp.md`](doctrine/warp.md), for the door each phase declares.
Departures stay in [the register](INDUCTION.md#the-register).

### Answer-first exposition — Minto, 1987

**The work** — Barbara Minto, *The Pyramid Principle: Logic in Writing and Thinking*, 1987; the
military states the same rule as *bottom line up front*.

**What it claims** — that a reader given the evidence before the conclusion forms a conclusion of
their own and then reads the rest as argument against it, so the conclusion leads and the support
is arranged beneath it in a structure the reader can enter at any level. Its scope is business
writing addressed to a decision-maker who may stop reading.

**What the field says against it** — Edward Tufte, "The Cognitive Style of PowerPoint: Pitching
Out Corrupts Within", 2003, argues that the conclusion-first, hierarchically-bulleted form strips
out the reasoning and the evidence that would let a reader disagree, weakens spatial and verbal
reasoning, and corrupts statistical argument — his case in point being the NASA slides preceding
the Columbia loss.

**Taken here** — [`doctrine/planning.md`](doctrine/planning.md), for the executive summary that
leads with the answer. Departures stay in
[the register](INDUCTION.md#the-register).

## Manufacturing and operations

### Stop the line — Ohno, 1978

**The work** — Taiichi Ohno, *Toyota Production System: Beyond Large-Scale Production*, 1978 (in
English, 1988), on *jidoka* and the andon cord.

**What it claims** — that any worker may halt the line on finding a defect, because the
alternative is building more product on top of it; and that the halt is the diagnostic instrument,
since a line that stops often is showing where the process is weak. The authority is the point:
*jidoka* means the machine stops itself, and the andon extends that to the person.

**What the field says against it** — Mike Parker and Jane Slaughter, *Choosing Sides: Unions and
the Team Concept*, 1988, argue from the shop floor that the system is "management by stress": the
line is deliberately run near the point of stoppage, and the stops are read as a map of where
slack remains to be removed, so the authority to stop is the instrument by which the work is
intensified rather than a protection for the person holding the cord.

**Taken here** — [`doctrine/as-built.md`](doctrine/as-built.md), for a defect corrected where and
when it is found rather than queued. Departures stay in
[the register](INDUCTION.md#the-register).

### The forcing function, or poka-yoke — Shingo, 1986

**The work** — Shigeo Shingo, *Zero Quality Control: Source Inspection and the Poka-Yoke System*,
1986; named for design generally by Donald Norman, *The Psychology of Everyday Things*, 1988.

**What it claims** — that the wrong action should be made impossible rather than discouraged: a
fixture that only accepts the part in one orientation removes a class of defect without depending
on anyone's attention, which is what distinguishes it from a warning or a procedure.

**What the field says against it** — Ross Koppel, Tosha Wetterneck, Joel Telles and Ben-Tzion
Karsh, "Workarounds to Barcode Medication Administration Systems: Their Occurrences, Causes, and
Threats to Patient Safety", *JAMIA*, 2008, catalogued fifteen types of workaround to a forcing
function deployed in hospitals, several of which defeated it entirely. A constraint that blocks
work people are still accountable for delivering gets routed around, and the workaround is less
visible than the error it replaced.

**Taken here** — [`doctrine/warp.md`](doctrine/warp.md), for a guard that refuses rather than a
rule that asks. Departures stay in [the register](INDUCTION.md#the-register).

## Human factors and automation

### Automation surprise, and its usual cause mode confusion — Sarter and Woods, 1995

**The work** — Nadine Sarter and David Woods, "How in the World Did We Ever Get into That Mode?
Mode Error and Awareness in Supervisory Control", *Human Factors* 37(1), 1995, 5–19.

**What it claims** — that in a system with modes, the operator's model of what the automation will
do can diverge from what it will do, and the divergence is typically discovered only when the
automation acts. The scope is supervisory control of a highly automated system — the glass cockpit
— and the finding is about awareness rather than about skill.

**What the field says against it** — Asaf Degani and Michael Heymann, "Formal Verification of
Human-Automation Interaction", *Human Factors* 44(1), 2002, narrow the claim usefully: the
surprises are a property of the relationship between the interface model and the machine model,
and can be found by formal analysis before deployment, so they are not the irreducible
consequence of automation the earlier framing suggests.

**Taken here** — [`doctrine/warp.md`](doctrine/warp.md), for blast radius read off a trigger's
declared condition rather than off the size of a diff. Departures stay in
[the register](INDUCTION.md#the-register).

## Records and archives

### Provenance, or respect des fonds — Muller, Feith and Fruin, 1898

**The work** — Samuel Muller, Johan Feith and Robert Fruin, *Handleiding voor het ordenen en
beschrijven van archieven* — the Dutch Manual — 1898, where the principle is codified. It was
formulated earlier, in the French ministerial circular of 1841 drafted by Natalis de Wailly: that
records are grouped by the body that accumulated them, rather than sorted by subject, date or
place.

**What it claims** — that a record's meaning is inseparable from where it came from, so the
arrangement must preserve the originating body, the integrity of its fonds and its original
order. The archivist's job is to keep provenance legible rather than to impose a more convenient
classification, because the convenient one destroys evidence that cannot be reconstructed.

**What the field says against it** — Peter Scott, "The Record Group Concept: A Case for
Abandonment", *The American Archivist* 29(4), 1966, 493–504, argued that a single physical
arrangement by originating body cannot be maintained once bodies merge, split and transfer their
functions, and proposed describing provenance as a separate series of relationships instead. The
modern practice descends from Scott, not from the Manual's physical reading.

**Taken here** — [`doctrine/git.md`](doctrine/git.md), for a change that carries the record of what
authorized it, where the register declares the use a metaphor and keeps it for the custody half it
actually states: records of one creator kept together and never intermingled with another's. The
closer work the register asked for is cited beside it and has its own entry —
[attested provenance](#attested-provenance--torres-arias-afzali-kuppusamy-curtmola-and-cappos-2019).
Departures stay in [the register](INDUCTION.md#the-register).

### As-built documentation — AIA A201, 2017

**The work** — AIA Document A201, *General Conditions of the Contract for Construction*, §3.11
(current edition A201–2017; the document dates to 1911), which obliges the contractor to maintain
a record set marked to show the work as actually executed, and to deliver it at completion.

**What it claims** — that the authoritative record of a building is what was built, not what was
drawn, and that keeping the two in correspondence is a contractual obligation owed by whoever did
the work. The obligation is editorial only in form; in substance it is a condition of payment.

**What the field says against it** — the obligation is widely held not to produce an accurate
record. Pu Tang, Daniel Huber, Burcu Akinci, Robert Lipman and Alan Lytle, "Automatic
reconstruction of as-built building information models from laser-scanned point clouds: A review
of related techniques", *Automation in Construction* 19(7), 2010, 829–843, open from the premise
that models derived from design documents "do not generally capture details of a facility as it
was actually built", and that recovering the as-built condition requires measuring the facility
again — which is an expensive admission that the delivered record set is not relied on.

**Taken here** — [`doctrine/as-built.md`](doctrine/as-built.md), for the record corrected to what
was actually built. Departures stay in [the register](INDUCTION.md#the-register).

### The architecture decision record — Nygard, 2011

**The work** — Michael Nygard, "Documenting Architecture Decisions", 2011.

**What it claims** — that the reasoning behind a decision should be written where whoever later
meets the decision will be standing, in a short immutable record per decision, because the
alternative is an undocumented constraint that the next person either violates or preserves
without knowing why.

**What the field says against it** — the design rationale literature's standing objection is an
incentive one, stated by Jonathan Grudin, "Evaluating Opportunities for Design Capture", in *Design
Rationale: Concepts, Techniques, and Use*, 1996: whoever pays the cost of capturing the rationale
is not whoever benefits from it, and the benefit arrives later and to someone else, so capture is
the first thing dropped under schedule pressure. Rafael Capilla, Anton Jansen, Antony Tang, Paris
Avgeriou and Muhammad Ali Babar, "10 years of software architecture knowledge management: Practice
and future", *Journal of Systems and Software*, 2016, report the same gap a generation later.

**Taken here** — [`doctrine/as-built.md`](doctrine/as-built.md), for the reasoning written where
the decision is met. Departures stay in [the register](INDUCTION.md#the-register).
