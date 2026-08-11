---
name: feedback_pick_models_for_subagents
description: When dispatching subagents or structuring multi-stage workflows, pick the model per stage instead of letting everything inherit the most capable model.
metadata:
  type: feedback
---
When dispatching agents or structuring multi-stage workflows, actively assign the model per stage instead of letting every stage inherit the most capable (most expensive) model.

**Stage assignments:**
- **Opus** for any task involving judgement or logic: code review, architectural reasoning, root-cause analysis, planning, adversarial verification, synthesis, judging outputs. This is the quality-priority tier -- do not downgrade to save cost.
- **Sonnet** for code-tracing and exploration that does not require deep judgement.
- **Haiku** for structured summarisation or format conversion.

**Decision question:** Is this agent making judgement calls, or doing structured transformation? Judgement (review, planning, diagnosis) goes to Opus. Transformation/distillation goes to Haiku. Code search or exploration without strong judgement goes to Sonnet.

**Why:** Broad scouting work (web search, fetch, grep sweeps, data extraction) does not benefit from a top-tier model. Expensive models should be reserved for stages that actually need reasoning depth. Conversely, the user prioritises higher-quality logical reasoning over token cost savings -- cost-efficiency arguments for downgrading reasoning-heavy agents to a weaker model do not apply.

**How to apply:** In workflow scripts use per-agent model/effort options; in the Agent tool use the model param. Do not propose downgrades from Opus for review, planning, or reasoning-heavy agents.

**Implementer subagents that write code → Sonnet minimum, not Haiku.** This holds even for fully-spec'd mechanical edits that are pure transcription from a plan. Haiku is only for summarisation and format conversion, never for an agent that edits source files.

**Reviews and scoped re-reviews default to Sonnet.** Escalate to Opus only when the diff is big, architectural, or safety-critical (live DB, money, auth, data loss). Never Haiku: a re-review verdicts each finding ADDRESSED/NOT ADDRESSED and fact-checks it against source, which is judgement, and it is the fix loop's only brake. Diff size is not a reason to go below Sonnet.

**Security-critical implementation → Opus, even when fully spec'd.** Escalate the implementer tier, not just the reviewer, for security, anti-cheat, money, or exploit-critical code. Heuristic for the Roblox project: trivial config/JSON/pure-math = Haiku ok; real implementation = Sonnet; security/anti-cheat-critical = Opus.

**Deep-research workflow:** its agents inherit the main-loop model (Opus) by default, which is wasteful for web search. Before running it, edit the script to pin `model: "haiku"` on the search and fetch stages and `model: "sonnet"` on scope/verify/synthesize. Do not launch it at the inherited default.
