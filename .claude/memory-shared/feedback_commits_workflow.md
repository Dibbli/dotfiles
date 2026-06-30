---
name: feedback_commits_workflow
description: NEVER run `git commit` with a message you wrote, and never `git push`. The user authors every commit. This holds even when a plan says "commit" and the user said "go".
metadata:
  type: feedback
---
**HARD RULE: do not run `git commit` with a subject/body you composed. Do not `git push`. Ever, unless the user types an explicit, in-the-moment instruction to commit (e.g. "commit this", "write the commit").**

This rule is NOT satisfied by any of the following — they are traps I have fallen for:
- A plan (even an approved one) that lists a "commit" step. Plan commit steps are **review checkpoints**, not license to commit.
- The user saying "sure", "lets go", "proceed", "do it". That approves the **work**, never the commit wording.
- Me having just asked "should I commit X first?" and the user agreeing. Agreement = yes do the work; **I still hand the commit over.**
- Finishing a clean logical chunk that "obviously" wants a commit.

When work is ready: `git add` it (fine), then **STOP**, summarize what changed, and hand over a ready-to-run `git commit -m "..."` command for the user to run. Then wait.

**Always fine** (no permission needed): `git add`, `pull`, `merge` onto the working branch, committing a purely mechanical/default message (the auto "Merge branch ..." text), and all read-only git (status, log, diff, show).

**Never without an explicit in-the-moment ask:** authoring a commit subject or body, `git add -A` + auto-commit, `git push`.

**Why:** The user signs their own commits and controls granularity, wording, and timing. Pushing needs their interactive terminal anyway. They have corrected this more than once.

**How to apply:** If you are explicitly told to write a commit, follow [[feedback_commit_style]] (single casual lowercase line, no body, no co-author trailer), and still stop before `git push` and hand over the command.
