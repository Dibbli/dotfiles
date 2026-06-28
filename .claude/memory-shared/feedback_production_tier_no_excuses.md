---
name: feedback_production_tier_no_excuses
description: When working on a production-grade or corporate-tier codebase, never propose JS-side approximations of DB features, "good enough for now" workarounds, or scope-cut excuses framed as "at larger scale" or "not a tonight job".
metadata:
  type: feedback
---

Treat every feature in a production-grade codebase as production-grade from day one. Do not propose shortcuts, approximations, or deferred correctness without a concrete reason.

**Banned framings (use NONE of these):**
- "good enough for this dataset size"
- "fine for now, revisit at larger scale"
- "not a one-evening job" / "not a tonight job"
- "JS-side approximation is acceptable here"
- "we can skip the schema change for now"
- any framing that defers correctness to a future MR without a concrete justification

**Why:** Shipping vibe-coded approximations (e.g. hand-rolling in TypeScript what the DB already provides natively, bolting raw SQL onto wrong indexes, quietly dropping items from spec) is a recognized failure mode when AI assistance is used without upfront design. The root cause is "no developer planning, no concrete technical guidance, just task fed to AI". The standard is: design before coding, use the right DB or framework primitive, implement to spec.

**How to apply:**
- When a feature needs DB-level machinery (FTS, GIN indexes, generated columns, custom text-search configs, materialized views), implement it at the DB layer with proper schema and migrations, not as application-layer code.
- When the spec asks for N things, deliver N things. Don't quietly scope-cut without flagging the gap.
- Genuine "out of scope" items are fine, but they need a concrete reason (separate ticket, separate concern, separate ADR), never "too big" or "later".
- When something is hard, propose the correct architecture and the actual amount of work it requires. The user will make the call. Don't pre-shrink the proposal.
- Design first, then code.
