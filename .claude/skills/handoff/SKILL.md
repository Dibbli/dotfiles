---
description: Snapshot current work to CHECKPOINT.md. Usage:/handoff
disable-model-invocation: true
---

# Handoff

Writes a checkpoint mid-work.

## Steps

1. **Sense the current state**:
   - `git status` and `git diff --stat`.
   - List modified files.
   - Pull session-level context from the conversation: completed tasks, in-progress task, open questions.

2. **Write `CHECKPOINT.md`** at the repo root:

   ```markdown
   # Checkpoint: <feature or branch name>

   Created: <YYYY-MM-DD HH:MM>

   ## Current Status

   **Completed:**
   - …

   **In progress:**
   - <task>: <what's done, what remains>

   ## Key decisions
   - **<decision>**: <reasoning>

   ## Next steps
   1. …
   2. …

   ## Blockers / open questions
   - …
   ```

3. Tell the user: "checkpoint written. Resume with `/intake` for new work or pick up next steps from `CHECKPOINT.md`."
