---
name: feedback_afk_decisions_log
description: When the user goes AFK and lets me decide, make the calls myself and log only the big judgement ones (concept accepts, design picks) in a numbered decisions file; never mention the AFK in repo files
metadata:
  type: feedback
---

When the user goes AFK and says I may decide, I make their calls myself and append them to a numbered, append-only AFK decisions log in `~/Downloads/` (one file per project or effort). User's words: "no need to record every minute ne like last time, can just do the big judgement style ones (ie, desgin concept accepts and such)".

**Why:** an earlier log listed every small call and was too long to review.

**How to apply:** log concept or take picks, accepts at review gates, accepts of doc or spec deviations, and scope cuts. Skip small calls: naming, file layout, check fixes, tuning values inside an accepted look. Work only a human can do (manual testing, screenshots from tools I cannot drive) still waits for the user. Subagents keep handing their user questions to the main session, which decides and logs.

**Never write that the user was AFK into anything tracked or team-facing** (plans, specs, design docs, code comments, commit or MR text, Jira). The decisions log in `~/Downloads/` is the only place AFK is mentioned. In repo docs, date the decisions plainly (`## Döntések (2026-10-22)`, `Jóváhagyva: a fejlesztő, <date>`). User, 2026-10-22: "as in, weore commitng that I was AFK? shouldnt do that"; they had me strip it from the MP-136 docs and leave older docs alone.
