---
name: feedback_investigate_before_patching
description: When a prior fix only partially worked, add diagnostic logging at the data path and confirm the hypothesis with real output before iterating again
metadata:
  type: feedback
---

When a previous patch attempt fails to fully fix the reported behavior, do not iterate by tweaking the same code with another guess. Add concrete diagnostic logging at the data path in question, ask the user to reproduce and paste the log output, then patch based on observed data.

**Why:** Shipping multiple URL-tweak guesses without data is slower than one targeted fix informed by a log line. The right move is: add logging at the relevant boundary (URL, fetch, decode, parse, etc.), get one output back, then make a targeted fix.

**How to apply:** When the user reports a partial-fix failure on a feature with a clear data path (URL -> fetch -> decode -> render, or similar), the next step is logging instrumentation, not another code guess. Look for the project's existing debug/logging facility before reaching for raw print statements. Gate diagnostic output behind an env var or debug flag if the project convention supports it.
