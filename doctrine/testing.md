---
name: testing
description: Tests held to the same standard as code — one behaviour per test, testability as a property of the design rather than of the suite, real implementations over mocks, one knob per diff so a difference has one cause, the rule that a test must be able to fail, and the rule that a passing run is evidence only about what it executed.
---

# Testing

*Red-first is falsifiability; one knob per diff is experimental design.*

**Named:** falsifiability — Karl Popper, *Logik der Forschung*, 1934 (in English, *The Logic of
Scientific Discovery*, 1959). One factor at a time — R. A. Fisher, *The Design of Experiments*, 1935.

**Tests are code and are held to the Clean Code standard** — the same bar for naming, size, single
responsibility and DRY. What is specific to tests:

- **One behaviour per test, named for the behaviour it pins.** The name is read far more often than
  the body; it is the failure message.
- **F.I.R.S.T.** — fast, isolated, repeatable, self-validating (Robert C. Martin, *Clean Code*,
  2008, where the acronym is Tim Ottinger and Brett Schuchert's). Asserts, never eyeballed output.
  Two departures from that form: *isolated* stands for Martin's *independent*, and his fifth
  letter — *timely*, the test written just before the code it pins — is the red-first rule below
  rather than a letter here, being a rule about when a test is written where the other four are
  properties of the test itself.
- **Testability is a property of the design, not of the suite.** If exercising a unit needs elaborate
  scaffolding, a network, wall-clock time or a deep mock tree, the production code is the defect. Fix
  the seam: inject the dependency, split the god-function, push the input and output to the edge.
- **Hit real implementations, not mocks**, unless mocking is the only option.
- **New *or modified* behaviour gets its test in the same change**, not a follow-up — changing
  behaviour means changing or adding the test that pins it.
- **Prefer writing the test first.** A test written first cannot pass vacuously, because it has to be
  red before the fix exists (test-driven development — Kent Beck, *Test-Driven Development: By
  Example*, 2002, of which only the red-first half is taken: nothing here asks that a design be
  allowed to emerge from its tests).
- **One knob per diff.** Attribution requires isolation. Land two changes together and a difference
  in the result has two candidate causes and no way to choose between them — and the one that
  improved things masks the one that made them worse, which is the case nobody notices. Each knob
  gets its own validation pass, in the order that establishes a bar before anything is measured
  against it.
- **A validator is not an oracle.** A check that a value parses, that a low bound sits below a high
  one and that units match has no way to notice that the conclusion drawn from those well-formed
  values is wrong. Output a human will act on therefore needs a check independent of whatever
  produced it: the well-formed false positive, the reference that was correct when it was stored, and
  the plausible range picked off the wrong scale all pass every schema check there is.

## A test must be able to fail

One that passes whether or not the property holds is not a test. This is not a theoretical
concern — it is the ordinary result of writing the assertion after the code, of a stub broad enough
to swallow the exact case the test claims to check, or of a suite whose setup silently no-ops.

The red-first discipline is the cheapest defence, and it has a corollary worth stating: when a suite
written before its implementation reports some checks already passing, those checks are the ones to
distrust. A check that "passes" because the thing under test does not yet exist is telling you about
its own construction, not about the code.

## A passing run is evidence about what it executed

**Which is not always what you changed.** Where a test resolves its inputs through the environment —
a path, a symbolic link, an installed copy, a cached build — it can exercise code that is not the code
under test, and the result is a green tick answering a question nobody asked. That is a failure of
**construct validity**: whether an instrument measures the thing it claims to measure, as distinct
from whether it measures it precisely (Donald Campbell and Donald Fiske, "Convergent and Discriminant
Validation by the Multitrait-Multimethod Matrix", 1959; the standard treatment is Thomas Cook and
Donald Campbell, *Quasi-Experimentation: Design and Analysis Issues for Field Settings*, 1979). A test
is a measuring instrument, so a run against the wrong source is an invalid instrument rather than a
flaky one, and no amount of repetition improves it.

**It is worse here than in the field that named it, and that is the part to carry.** A badly
constructed survey yields a number somebody can still argue with. A test that exercised the wrong
source yields a pass, which is the one output nobody re-examines. It is also not the oracle problem
above: there the judgement is too weak to decide a real result, here the judgement is sound and the
result came from somewhere else — a sound judgement about the wrong thing. So when a change is to
something *resolved* rather than something named, confirm what actually loaded before believing the
pass. Declaring and controlling every input — a **hermetic** run — is the structural remedy, and it
belongs wherever a particular toolchain is configured rather than here; what belongs here is the
refusal to read a green tick as evidence about a source nobody checked.
