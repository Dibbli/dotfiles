---
name: feedback_parallelize_disjoint_tasks
description: When executing a multi-task plan via subagents, batch tasks with disjoint file sets into parallel waves instead of running them one at a time.
metadata:
  type: feedback
---
When executing a plan task-by-task with subagents, do not default to strict sequential dispatch. Group the remaining tasks into parallel waves by FILE SET, and dispatch each wave in a single message with multiple Agent calls.

**How to plan the waves:**
1. Extract every task's Files list (Create / Modify / Delete) from the plan.
2. Two tasks conflict only if they write the same file. Same directory is not a conflict.
3. Tasks that conflict get serialised into later waves. Everything else goes in the current wave.
4. A file that MANY tasks each append one line to (a README index, a central table) is best kept out of all of them: tell each task not to touch it, have it report the line it would have added, and apply them yourself in one edit.
5. Reviews parallelise too. Package and dispatch a task's review as soon as that implementer returns, without waiting for its wave to finish.

**Why:** "never dispatch implementers in parallel" exists to prevent write conflicts, not to enforce sequencing. Once the file sets are proven disjoint the conflict risk is gone, and serial dispatch just spends wall-clock. Leaf tasks late in a plan are usually independent, even when the early ones genuinely were not (a gate or index has to exist before other tasks can build on it).

**How to apply:** Extract shared per-task dispatch boilerplate (constraints, gates, branch and commit rules, known-baseline numbers) into ONE file in the plan workspace and have each subagent read it, instead of repeating it in every prompt. Give each agent an explicit scope fence naming the files a concurrent sibling owns. Record in the ledger which tasks ran in which wave and why any were held back, so the sequencing survives compaction. See [[feedback_pick_models_for_subagents]] for choosing each agent's model.
