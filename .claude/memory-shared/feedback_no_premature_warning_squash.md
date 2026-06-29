---
name: feedback_no_premature_warning_squash
description: Don't silence a transient compiler/linter warning that the next planned step will naturally eliminate
metadata:
  type: feedback
---

Don't squash a compiler or linter warning (e.g. dead_code, unused import) when the next planned step in the same task will naturally remove it.

**Why:** It adds churn to the diff and then has to be reverted. The warning is useful signal during multi-step work: it acts as a checklist that the wiring is incomplete.

**How to apply:** Silence or allow-annotate a warning only when it is genuinely permanent (e.g. an item kept for tests-only or for an external API that won't be called from this crate). For transient warnings expected to clear within the same continuous work session, leave them.
