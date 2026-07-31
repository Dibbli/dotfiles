---
name: feedback_commit_style
description: When writing git commits — what format the user expects
metadata:
  type: feedback
---
For git commits, write a **single-line subject only**. Lowercase, casual register matching a typical git log (e.g. "merge fixes", "ci fix", "stage 5", "proper integration"). No body or description block. No bullet lists. No Conventional Commits prefix (feat:, fix:, etc.). No AI co-author trailer such as `Co-Authored-By: Claude` or `Co-Authored-By: Codex`. **Never mention a ticket/issue number** (e.g. NOA-68) in the commit message, even though branches are named after tickets and code/docs reference them.

**Why:** The user explicitly rejected structured multi-line commits ("these are not my style of commit. no desc, just a basic message") and trimmed the co-author trailer from a commit. Separately asked that no commit mention the ticket number.

**How to apply:** Default to `git commit -m "subject"` with ~3-8 word subject, no body paragraphs, no co-author line, no ticket id. Match the casual register of the existing git log. Add a body only if the user explicitly asks for one. (Note: the user authors all commits per [[feedback_commits_workflow]] — this governs any subject you draft/suggest.)
