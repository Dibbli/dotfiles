---
name: feedback_dropped_packets
description: When to apply the lone-period recovery signal — user sends "." to mean "connection dropped, resume"
metadata:
  type: feedback
---
If the user sends a message containing only `.` (or primarily `.`), it means packets were lost and the previous exchange got truncated.
**Why:** The user has an intermittent connection and established this as a lightweight signal to recover without re-typing context.
**How to apply:** Treat `.` as "retry/continue." Retry the previous tool call if it errored or got cancelled, or continue the in-progress response if only the assistant output was dropped. Do not interpret `.` as a literal request or as new instructions.
