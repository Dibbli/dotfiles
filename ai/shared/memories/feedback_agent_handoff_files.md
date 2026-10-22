---
name: feedback_agent_handoff_files
description: "At a handoff, each running agent writes its own handoff file from its fresh context; never kill it and write it yourself"
metadata:
  type: feedback
---

When the session must hand off (account swap, budget, context, "handoff and resend the agent"), SendMessage each running agent to stop, restore any live state it touched, and write its OWN handoff file (task, done, left, file state, scratch paths, doubts, next steps). Point the main handoff at those files. Never TaskStop an agent to cover its work yourself; a stopped agent can still be resumed to write it.

Order, bottom up: each lead first tells its own sub-agents to write their handoffs and waits for them (a lead that ends its turn early never hears back), then writes its own, listing their paths. The main session writes its own last and says "swap now" only when every lead has returned. On resend, start one fresh agent per handoff file; each fresh lead resends its own sub-agents from their files.

**Why:** the running agent holds the real state (what it read, changed, left half done); a main-session handoff misses it. User, 2026-10-09: "resume it and tell it to make a handoff file".

**How to apply:** one handoff file per agent, next to its output or scratch. Related: [[feedback_pick_models_for_subagents]].
