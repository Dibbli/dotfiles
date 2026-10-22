---
name: feedback_real_timestamps
description: "When writing times into logs, lists or status notes, get them from `date`, never estimate"
metadata:
  type: feedback
---

Every clock time written into a log, progress list or status note comes from running `date` at that moment. Do not estimate elapsed time.

**Why:** in an overnight run an agent wrote "02:50" when it was 00:52. User: "make sure those timestamps are accurate!"

**How to apply:** run `date +%H:%M` before a timed entry. If no time was recorded, leave the time out.
