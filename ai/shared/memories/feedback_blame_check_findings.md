---
name: feedback_blame_check_findings
description: When reviewing a branch diff, blame-check every finding to confirm it was actually introduced by this branch before reporting it
metadata:
  type: feedback
---

For branch reviews (`/mr`, `/fix`, code review of `main..HEAD`), a finding only counts if THIS branch introduced or modified the cited line. Pre-existing code that the branch merely carries along (unchanged context in a modified file, or a line relocated by a refactor whose smell already exists on `main`) is a false positive and must be dropped.

**Why:** confidence-filter scorers and specialist agents reason from diff hunks and routinely flag pre-existing lines in `M` files. The user has caught false positives this way: lines that were byte-identical on `main` or authored by pre-branch commits inside files the branch only touched elsewhere. The orchestrator must run this gate itself on surviving findings and cannot delegate it to subagents or scorers -- they pass through pre-existing lines anyway.

**How to apply:** before reporting any finding, verify in-branch origin:
- `git diff --name-status main..HEAD -- <path>` -- `A` = new file, all in-branch; absent = drop; `M` = must check the line.
- For `M` files: `git blame -L N,N HEAD -- <path>` then `git merge-base --is-ancestor <commit> main` (ancestor means pre-existing, so drop). Also confirm the cited text sits in a `+`/`-` hunk, not unchanged context.
- A line that exists byte-identical on `main` is pre-existing even if a refactor re-emits it as `+`.
- A finding about an *absence* (missing export, missing test) is in-scope only if the branch created the absence (added the field, deleted the test).
- File-level `M` status is NOT sufficient evidence; the specific cited line must be branch-authored.

Run this gate after the confidence filter and before writing any output. Make it a standard step, not an afterthought.
