---
name: feedback_match_sibling_dont_cut_functionality
description: When a sibling feature already exists in the app, a new instance must match its full UX, not just compile
metadata:
  type: feedback
---

When a feature has an established sibling in the app, a new instance must match it in behavior AND placement, not just compile. Do not drop user-facing UX (loading state, progress modal, success/error toasts, placement) to satisfy an over-engineering or "be lazy" review.

**Why:** Consistency across the app is a hard requirement (see [[feedback_production_tier_no_excuses]]); "fewer lines" never justifies a worse or divergent user experience.

**How to apply:** Before simplifying anything user-facing, find the sibling feature and diff against it. Over-engineering reviews ([[ponytail]]-style) apply to internal plumbing, not to trimming visible functionality the rest of the app already provides.
