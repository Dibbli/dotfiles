---
name: feedback_no_sudo
description: when a task requires elevated privileges and you would normally invoke sudo via Bash
metadata:
  type: feedback
---
Do not invoke `sudo` via the Bash tool. The harness cannot authenticate, so the call hangs or fails, wasting a turn.
**Why:** sudo prompts for a password that cannot be supplied interactively through the tool; the process stalls or errors out without producing useful output.
**How to apply:** When a step requires root, print the exact command for the user to run in their own terminal (e.g. "run: `sudo systemctl restart <service>`") instead of calling it via Bash.
