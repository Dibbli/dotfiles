---
name: feedback_deep_audit_dispatch
description: When the user requests a deep/thorough code review, dispatch many narrow parallel agents rather than a few broad ones.
metadata:
  type: feedback
---

When the user wants a deep or fine-tooth-comb review, dispatch **many** parallel agents each scoped to a **small** slice (2-4 files), not a few agents over broad areas.

**Why:** Broad-scope agents skim and return a shallow summary. Narrow scope combined with an explicit per-file checklist forces depth. The user's intent is "more agents, not fewer, so they don't stop early after getting the gist."

**How to apply:**
- One agent per 2-4 related files; cover the whole changeset across the fleet.
- Give each a required-checks list (justify every function/type/comment, hunt reinvented-wheel + DRY + dead code) and a finding floor ("aim for >=N findings per file unless genuinely clean").
- Instruct agents to verify library claims via context7, cite sources, and report `file:line + severity + what's there + exact fix`.
- Run agents with `run_in_background: true`; consolidate only after all return, triaging out pre-existing/out-of-scope items rather than dumping every finding raw.

Pairs with feedback_planning_tasks_discuss_first: present the triaged plan and let the user choose what to action.
