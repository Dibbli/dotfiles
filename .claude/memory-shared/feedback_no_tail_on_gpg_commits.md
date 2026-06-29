---
name: feedback_no_tail_on_gpg_commits
description: When to avoid piping git signing operations through tail/head — hides pinentry prompts
metadata:
  type: feedback
---

Do not pipe `git commit` (or any other GPG-signing git operation) through `tail`, `head`, or similar truncating commands. Run the command bare.
**Why:** When GPG commit signing is enabled, pinentry launches an interactive prompt for the passphrase. Piping stdout/stderr through `tail` swallows the pinentry trigger output, so the user sees truncated output with no signal that a PIN prompt is waiting.
**How to apply:** For `git commit`, `git rebase`, `git merge`, and any other potentially-signing operation, run the bare command with no `| tail` or `2>&1 | tail`. If the output is long, inspect it after the operation completes (e.g. `git log -1` separately).
