---
name: retrieval
description: How a question finds its answer in a repository — one declared way in at the root of what it routes, every surface that can be derived generated from the prose it describes and the one mapping a question's words onto the records' words authored by hand, a projection repairable from what it projects or else a second copy, a refusal carried as data with a reason per rule, a gap declared so that absence is an answer, and every reading taken at a ref rather than a working tree.
---

# Retrieval

*A corpus with no declared way in is read by guessing, and a search that found nothing is reported
in the same voice as a fact.*

**Named:** the vocabulary problem — George Furnas, Thomas Landauer, Louis Gomez and Susan Dumais,
"The vocabulary problem in human-system communication", *Communications of the ACM* 30(11), 1987.
[Lineage](../LINEAGE.md#the-vocabulary-problem--furnas-landauer-gomez-and-dumais-1987).

**The cost of an unroutable corpus is not slowness. It is confident wrong answers.** Whoever cannot
find a record says the repository does not hold it, in the same voice they use for what it does
hold — so the failure arrives as an answer rather than as an error, and nothing downstream of it
can tell the two apart. That is the defect this document is about, and it is why a route is part of
a corpus rather than a convenience beside it.

- **One declared way in, and it sits at the root of what it routes.** A repository whose
  answer-bearing corpus is one subtree puts the entry point *in* that subtree and spends one
  sentence of the root file pointing at it, rather than growing the root file until it routes the
  subtree too. An entry point is read whole, so it has a ceiling, and keeping it inside its own
  corpus is what keeps its claims honest: what the route says it covers and what the route indexes
  are then the same set by construction.
- **Generate every surface that can be derived, and author the one that cannot.** The index of
  headings, the contents block inside a long document, the readable form of a refusal: each is
  derived from the prose it describes, and a generated surface is the only kind that cannot
  disagree with its source. **The mapping from the words a question uses onto the words the records
  use is the exception, and it is the whole reason this is a document rather than a script.** Two
  people asked to name the same object spontaneously agree under 20% of the time (Furnas,
  Landauer, Gomez and Dumais, 1987), and the word a question arrives in is by definition the one
  the corpus does not contain — so nothing reading the corpus can invent it. That table is written
  by hand, row by row, and it is also the one surface an index would not remove the need for: an
  index finds the words that are there.
- **An omission and a wrong row are not the same cost, and the threshold follows the costs rather
  than the coverage.** A missing row under-routes, and a ranked search over the corpus recovers
  from it. A wrong row mis-routes — it sends the question somewhere plausible and empty, which
  reads as an answer and ends the search. So a row exists only where the destination is certain,
  and a table that is thin where the author was unsure is the rule working.
- **A projection is repairable by hand from what it projects, or it is a second copy.** The test is
  whether a reader could rebuild the generated surface from the documents it indexes. Where they
  could not, it carries a fact of its own, and two copies of a fact drift until one of them is a
  lie with no signal which ([`clean-code.md`](clean-code.md)). This is what distinguishes a route
  from a second corpus, and the distinction is the one worth defending: a route costs a regeneration
  and a second corpus costs a reconciliation nobody has undertaken.
- **A hand edit to a generated surface is a failure rather than a shortcut.** The verifier refuses
  the disagreement and says which file is the source; it does not silently rewrite the edit away. An
  author who edited the projection meant the sentence, and the place to put it is the document the
  projection is derived from.
- **A refusal is data, and every rule in it carries its reason.** Prose states what may not be
  opened to a reader with a person in the loop; an unattended process in front of the same files
  needs that same rule as something it can read. Where both exist the data is canonical and the
  prose is its projection, generated like the others. A rule with no reason is refused, because a
  rule nobody can review is not a rule — six months on, a bare pattern cannot be told apart from a
  path that moved. **A rule matching nothing is refused too**, and that is the quieter half: it is
  enforced against nothing while reading as protection, and the file it was written for is readable.
- **A gap is declared, so that absence is an answer.** A document that says what it does not hold
  turns the worst case above into an ordinary result — *the repository does not have this* becomes
  something a reader was told rather than something they concluded from a search that failed.
- **Read at a ref, never a working tree.** A checkout is whatever branch somebody left it on, and
  several working trees share one repository, so a reading taken off a tree is a reading of whatever
  was last left there. The deliberate exception is the verifier an author runs *before* a change is
  a commit, which judges the working copy because that is the state it exists to judge.
- **The breach is observable, and observing it is one command.** A check whose subject is absent
  reports a skip rather than a pass, so a repository with none of this layer cannot read as a
  repository with all of it. And a verifier that has never refused anything is not known to refuse,
  so each refusal this document names has a check asserting the non-zero exit
  ([`testing.md`](testing.md)).

**Whether a corpus needs more than a ranked search is a measurement, and it belongs to whoever took
it.** The claim that an index is unnecessary here is empirical, which means it is the kind of claim
[`as-built.md`](as-built.md) requires a measurement beside rather than an assertion: a repository
that has measured its own corpus and found a search too slow to answer with has a finding, and that
finding is a fact about that corpus and not a correction to this document. What travels is the
asymmetry — an index finds the words that are there, so it replaces the four generated surfaces and
never the authored one.

## Where the route is extended

**Where a question's answer sits in a document and no heading routed to it, extend that heading in
the same change.** This is correction on discovery ([`as-built.md`](as-built.md)) applied to the
route: whoever just failed to find a thing they knew was there is the one person holding the
evidence, and they are holding it now.

A heading that says what its section holds is what makes both the search and the index answer
rather than merely point, which is why the repair is a heading and not a row in the authored table —
the table is for the words that are nowhere in the corpus, and a subject the corpus discusses under
a heading too vague to match is a different defect with a cheaper fix.

Two consequences, because they are what makes the rule cheap enough to keep:

- **A clause appended to a heading breaks nothing that already resolves.** A citation matches a
  heading as a prefix, so extending the end of one is safe and rewriting its opening is not.
- **There is no sweep.** A corpus improved on discovery improves where the questions actually are,
  and an audit that extended every heading in the corpus would spend most of its effort on the
  sections nobody has asked about yet.
