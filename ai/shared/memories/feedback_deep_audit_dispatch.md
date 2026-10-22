---
name: feedback_deep_audit_dispatch
description: When the user requests a deep/thorough code review, dispatch many narrow parallel agents rather than a few broad ones.
metadata:
  type: feedback
---

When the user wants a deep or fine-tooth-comb review, dispatch **many** parallel agents each scoped to a **small** slice (2-4 files), not a few agents over broad areas.

**Why:** Broad-scope agents skim and return a shallow summary. Narrow scope combined with an explicit per-file checklist forces depth. The user's intent is "more agents, not fewer, so they don't stop early after getting the gist."

**How to apply:**
- One agent per 2-4 related files; cover the whole changeset across the fleet. Review agents run on Sonnet, with one Opus judge to consolidate.
- Give each a required-checks list (justify every function/type/comment, hunt reinvented-wheel + DRY + dead code).
- Instruct agents to verify library claims via the docs MCP (`mcp__docs__search_docs`), cite sources, and report `file:line + severity + what's there + exact fix`.
- Run agents with `run_in_background: true`; consolidate only after all return, triaging out pre-existing/out-of-scope items rather than dumping every finding raw.

Present the triaged findings and let the owner choose what to action.
