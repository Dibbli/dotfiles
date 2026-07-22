---
name: feedback_no_magic_numbers
description: Behavior-affecting numeric constants belong in a central config/environment file, not scattered inline in feature code
metadata:
  type: feedback
---

When introducing a numeric constant for behavior (debounce ms, timeout, retry count, length cap, polling interval, etc.), add it to the project's central config or environment file under a feature-scoped key, and import it from there. Don't declare `const FOO = 400` at the top of a component or service.

**Why:** Keeps tuning knobs in one discoverable place and avoids scattering them across feature files.

**How to apply:** Find the project's existing environment or config object and add the constant there with a descriptive, feature-scoped name (e.g. `featureX.typingDebounceMs`). Bare HTML attribute literals (like `step="0.01"`) and structural array indices stay inline; the rule is about behavior-affecting numbers a future maintainer would want to find and tune.
