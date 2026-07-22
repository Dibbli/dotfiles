---
name: feedback_cite_only_what_loads
description: When citing a URL as evidence for a claim, verify the cited page actually contains that specific claim before publishing.
metadata:
  type: feedback
---

When a code comment or explanation cites a URL as evidence for a technical claim, that URL must contain the specific claim being supported. Do not combine examples from page A into a comment that links to page B.

**Why:** Conflating two docs pages (e.g. citing a page about unsupported database features but using examples that only appear on a separate extensions page) means the reviewer searches the cited page and finds nothing, which destroys trust in the citation. A wrong link is worse than no link.

**How to apply:**
- Before writing a "see X" comment, open X and confirm the specific example or phrase appears there.
- If two pages each support part of the claim, cite both, or pick one and use only examples that page contains.
- Bare assertions are better than wrong citations.
