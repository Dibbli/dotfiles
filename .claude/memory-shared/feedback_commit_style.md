---
name: feedback_commit_style
description: When writing git commits — what format the user expects
metadata:
  type: feedback
---
For git commits, write a **single-line subject only**. Lowercase, casual register matching a typical git log (e.g. "merge fixes", "ci fix", "stage 5", "proper integration"). No body or description block. No bullet lists. No Conventional Commits prefix (feat:, fix:, etc.). No `Co-Authored-By: Claude` trailer.

**Why:** The user explicitly rejected structured multi-line commits ("these are not my style of commit. no desc, just a basic message") and trimmed the co-author trailer from a commit.

**How to apply:** Default to `git commit -m "subject"` with ~3-8 word subject, no body paragraphs, no co-author line. Match the casual register of the existing git log. Add a body only if the user explicitly asks for one.
