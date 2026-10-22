---
name: feedback_pick_models_for_subagents
description: When and which model to use for agents: Sonnet by default for checked, fanned-out or research work, Opus 5.5 set explicitly for final or costly output, Haiku for format conversion and locate-and-report.
metadata:
  type: feedback
---
Set the model per agent or workflow stage on purpose. Settings set CLAUDE_CODE_SUBAGENT_MODEL=sonnet, so an agent with no model param runs on Sonnet. Opus must be set explicitly with `model: "opus"` (`claude-opus-5-5`).

**Decision logic (ask in order):**
1. Is the output final, with no later check? Is a mistake expensive (security, money, auth, data loss, architecture)? Use **Opus 5.5**: planning, root-cause analysis, first-pass review of a non-trivial diff, the one judge that merges many outputs, critical code even when spec'd.
2. Does a later stage or the main model check the output, or is it fanned out to many agents? Use **Sonnet** (the default): spec'd non-critical implementers, scoped re-reviews of small fixes (escalate to Opus for safety-critical or architectural diffs), scouts before one Opus judge, tracing exploration, research.
3. Is it summarisation, format conversion or locate-and-report, with no source edits? Use **Haiku**. Not for editors or reviewers.

**Exploration:** a single grep or one file read with a known target stays inline, because a cold agent costs more. Sweeps across many files or several projects go to an agent (Explore or Haiku for locate-and-report, Sonnet when it needs tracing). The agent returns only the conclusion, so file dumps stay out of the main context.

**Research:** web (WebFetch/WebSearch, GitHub issues, docs, forums) and multi-file local digging (decompiles, mod/game files) go to a Sonnet agent. Batch the questions into one prompt with "cite only pages you loaded". The main model keeps a quick first look and the final judgement. Owner quotes: "sonnet research agent, dont waste fable tokens on research" (they interrupted an inline WebFetch). 2026-10-11, mid-way through a Vintage Story mod bug (unzip, ilspycmd, grep): "use sonnet for exploration".

**Why:** Sonnet is cheaper and good enough when its output gets checked. Opus 5.5 earns its cost where a mistake is final. Judgement stages do not drop to a cheaper model.

**Fork = main-loop model.** `subagent_type: "fork"` always runs on the main-loop model (model param ignored). Fork only when the task needs the full conversation state and top-tier judgement.

**Deep-research workflow:** pin `model: "haiku"` on pure fetch/extract stages, Sonnet on scope and search, Opus 5.5 on verify/synthesize.

See also [[feedback_deep_audit_dispatch]].
