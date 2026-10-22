---
name: feedback_parallelize_disjoint_tasks
description: When executing a multi-task plan via subagents, batch tasks with disjoint file sets into parallel waves instead of running them one at a time.
metadata:
  type: feedback
---
When executing a plan with subagents, group tasks into parallel waves by file set. Dispatch each wave in one message with several Agent calls.

**How to plan the waves:**
1. Extract every task's Files list (Create / Modify / Delete) from the plan.
2. Two tasks conflict only if they write the same file. Same directory is not a conflict.
3. Serialize conflicting tasks into later waves. Everything else goes in the current wave.
4. A file that many tasks each append one line to (a README index, a central table) stays out of all tasks. Each task reports the line it would add, and you apply them in one edit.
5. Split fix rounds the same way: one agent per disjoint file cluster, not "hard half vs easy half". Only the last agent runs the full test suite.
6. Start each review as soon as its implementer returns, without waiting for the wave.

**Why:** "never dispatch implementers in parallel" prevents write conflicts, not wall-clock savings.

**How to apply:** put shared per-task boilerplate (constraints, gates, branch and commit rules, baseline numbers) in one file in the plan workspace and have each subagent read it. Give each agent an explicit scope fence naming the files a concurrent sibling owns. Record in the ledger which tasks ran in which wave and why any were held back. Model picks: [[feedback_pick_models_for_subagents]].
