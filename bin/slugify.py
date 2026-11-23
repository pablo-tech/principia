"""GitHub-compatible heading slugs, shared by the TOC generator and the heading index."""
import re


def gh_slug(text, _seen=None):
    s = text.strip().lower()
    s = re.sub(r"[^\w\s-]", "", s, flags=re.UNICODE)  # drop punctuation, keep word chars/space/-
    s = s.replace(" ", "-")
    return s


class Slugger:
    """gh_slug plus GitHub's duplicate suffixes, which need state gh_slug does not hold.

    GitHub numbers repeated heading texts within one document — the second `## Status`
    anchors at `#status-1` — so a slug function with no memory of what it has already
    emitted cannot address the second one. `gh_slug` is left exactly as it is, pure and
    importable, and the state lives in a caller one document long. A corpus where a
    heading text repeats is the normal case rather than the exception: an arrival ledger
    with one section per arrival repeats every one of its headings, and an index generated
    without this ships one link to the wrong section per repetition.
    """

    def __init__(self):
        self.seen = {}

    def __call__(self, text):
        s = gh_slug(text)
        n = self.seen.get(s, 0)
        self.seen[s] = n + 1
        return s if n == 0 else f"{s}-{n}"
