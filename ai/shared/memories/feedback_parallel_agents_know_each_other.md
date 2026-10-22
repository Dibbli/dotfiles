---
name: feedback_parallel_agents_know_each_other
description: When dispatching two or more agents in parallel, name each one and tell each which files the others own; siblings message each other only for a shared helper, an error or a file clash.
metadata:
  type: feedback
---
Claude Code gives named agents a sibling roster with SendMessage by itself. In each parallel prompt, name the agent and list the files each sibling owns. A sibling is messaged only for a shared helper (before adding one to a shared file), an error or a file clash, never for status chatter. Owner decisions still go through the main session.

**Why:** the owner asked (2026-10-22): "inform them of eachother", so they "can cross communicate for DRY coding or errors if needed". Parallel agents that cannot see each other write the same helper twice or clash in a shared file.

**How to apply:** keep the scope fences from [[feedback_parallelize_disjoint_tasks]].
