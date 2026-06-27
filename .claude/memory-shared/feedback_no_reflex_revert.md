---
name: feedback_no_reflex_revert
description: When a change causes a regression, diagnose the cause first and apply a logical fix — don't reflexively propose reverting.
metadata:
  type: feedback
---

When a change causes a regression, do NOT reflexively propose "revert it". Diagnose the actual mechanism first, ground it in library docs (e.g. via context7), then apply the correct fix.

**Why:** The user explicitly rejected a panic-revert response and dismissed a follow-up that contained no actual documentation lookup — claiming to have "thought about it" without calling the research tool is not sufficient.

**How to apply:**
- State the precise cause-and-effect of the breakage before touching anything (e.g. "key bound to URL value -> remount on every flush -> focus loss").
- Pull the relevant library semantics via context7 and let the docs guide the fix.
- A revert is a last resort, not the reflex. The right fix is usually forward, not backward.
- If the user asks for research, actually call the tool — a response that skips the tool call will be rejected.
