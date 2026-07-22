---
name: feedback_no_kill_by_port
description: When a port is occupied and needs to be freed, never kill by port without asking first
metadata:
  type: feedback
---

Never run `lsof -ti :PORT | xargs kill` or otherwise kill a process by port without asking. A port may belong to something unexpected, not the dev or e2e server.

**Why:** Killing by port is indiscriminate; an unrelated process (e.g. a browser) can silently own a common port like 3000, and the kill will terminate the wrong program with no warning.

**How to apply:** If a port is occupied (e.g. e2e fails with "port already in use"), report which process holds it and let the user decide whether to kill it, or ask explicitly before acting. Do not reflexively reap by port. See also [[feedback_check_dev_server_first]] (probe, don't assume).
