---
name: feedback_commits_workflow
description: Whether and how Claude runs git commit / push during a task — the user owns authored commits.
metadata:
  type: feedback
---
The user owns their commits. Do not author commit messages or `git push` unless explicitly asked.

Fine to run: `git add`, `pull`, `merge` onto the working branch, and committing with a DEFAULT/mechanical message (e.g. the auto "Merge branch ..." message). Read-only git (status, log, diff, show) is always fine.

Do not: write custom commit subjects or bodies, `git add -A` and auto-commit a finished chunk of work, or `git push`. The user signs commits, so pushing needs an interactive terminal — hand over the push command instead.

**Why:** The user wants control over commit granularity, message wording, and timing.

**How to apply:** When finishing a multi-step plan, complete each logical chunk, then stop and summarize what changed so the user can review and commit. Treat any "commit per area" plan steps as review checkpoints, not actions to execute. If you are explicitly asked to write a commit, follow [[feedback_commit_style]]; always stop at push and hand over the command.
