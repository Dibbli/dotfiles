---
name: feedback_event_driven_agent_waits
description: When waiting for subagents after dispatching parallel work, use a minimum five-minute event-driven wait instead of short polling loops.
metadata:
  type: feedback
---

Treat `wait_agent` as an event subscription, not a status poll. After dispatching agents, continue any independent local work. When nothing useful remains, call `wait_agent` once with a timeout of at least 300,000 ms (five minutes); it returns early when an agent sends a message or completes.

Do not repeatedly call `wait_agent` with short timeouts, and do not poll `list_agents` for progress. Agents should notify the orchestrator only when they finish, discover a material blocker, or have a result that changes the remaining work.

If one update arrives while other agents are still running, process it and then make one new blocking wait of at least 300,000 ms for the remaining agents. This keeps the main context compact while preserving prompt handling and agent completion notifications.
