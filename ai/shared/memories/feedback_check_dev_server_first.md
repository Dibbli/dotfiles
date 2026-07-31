---
name: feedback_check_dev_server_first
description: When about to ask if a dev server is running, probe the port first instead of asking
metadata:
  type: feedback
---
Before asking the user whether their dev server or app is running, probe the relevant localhost port directly (e.g. `curl -sI http://localhost:<port>` or `nc -z localhost <port>`). The user keeps dev servers running persistently across sessions; asking "is it up?" wastes a turn when a quick probe would answer it.
**Why:** The user pushed back on the habit of assuming the server is down without checking: "why do you keep assuming it isn't up, check the localhost next time."
**How to apply:** Before running e2e tests or any task that depends on a local server being reachable, run a quick HTTP or TCP probe. Only ask the user if the probe actually fails.
