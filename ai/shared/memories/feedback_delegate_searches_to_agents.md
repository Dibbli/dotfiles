---
name: feedback_delegate_searches_to_agents
description: when deciding whether to run grep/find inline vs. dispatching a search agent for multi-file or cross-project lookups
metadata:
  type: feedback
---

For lookups that require sweeping many files or multiple projects, dispatch a search agent and surface only its conclusion, rather than running grep/find inline and pulling all matching output into the main context.

**Why:** inline searches dump file contents into the conversation and burn context fast; a delegated agent returns just the answer, keeping the main context clean.

**How to apply:** default to a subagent for "where is X / how does Y work" questions that span many files or multiple projects; use a broad fan-out agent for cross-project sweeps. Single-fact lookups where the target file is already known can still be done inline. Relates to [[feedback_deep_audit_dispatch]].
