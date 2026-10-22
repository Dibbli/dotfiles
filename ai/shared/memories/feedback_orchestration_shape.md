---
name: feedback_orchestration_shape
description: "Multi-agent work: no middle agent for one worker, and no single planner or contract agent that every unit waits on; the main session fills those roles"
metadata:
  type: feedback
---

Two rules, both about middle agents:
- **No single-child lead.** If a lead would only start one agent (one builder, one fix round), the main session dispatches that agent itself. Use a lead only for real parallel fan-out or long multi-step judgement the main session cannot hold. A skill that calls for a lead keeps its gates and roles; the main session fills the lead role.
- **No single-agent gate.** Do not open a workflow with one planner or contract agent that every unit waits on. Write the shared contract (types, remotes, Config keys, stubs whose bodies error) in the chat, commit it green, then start the units together. Only a merge queue may be serial. This holds only when the units are truly independent.

**Why:** user, 2026-10-22: "why are we using an orchestrator agent as a middle man if its just starting 1 agent anyway. start the fix agent yourself." 2026-09-23, after a planner agent ran 20 minutes on 350k tokens: "same issue ,instant bottleneck. stop having the workflow bottleneck on something we can monitor (ie a single agent)". Work in the chat is visible to the user and was faster.

**How to apply:** give each unit exact signatures from the landed stubs. Units may add keys to shared files (Config, Types) inside their own tables, so parallel merges rarely conflict. Related: [[feedback_parallel_agents_know_each_other]], [[feedback_parallelize_disjoint_tasks]], [[feedback_pick_models_for_subagents]].
