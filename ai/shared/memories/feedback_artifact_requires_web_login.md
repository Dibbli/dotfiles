---
name: feedback_artifact_requires_web_login
description: When about to use the Artifact tool for a report/document deliverable, consider that the user may not be logged into a web browser and can't open it
metadata:
  type: feedback
---
Don't default to the Artifact tool for report-style deliverables (audits, summaries, comparisons, write-ups) without checking the user can actually view one — the Artifact viewer requires being logged in on a web browser, which isn't always true for a given session/device.
**Why:** A user asked for a documentation audit, got an Artifact link, and couldn't open it: "cant look at that unfortunatly as i am not logged in on web browser, .md pls."
**How to apply:**
- Default text-heavy deliverables to a plain file (.md/.txt, see [[feedback_long_output_to_downloads]]) instead of an Artifact, unless the user has already viewed an Artifact successfully earlier in the session or explicitly asks for one.
- Genuinely visual/interactive content (charts, dashboards, generated UI) still warrants Artifact — this is about not defaulting to it for plain reports.
- If a user says an Artifact link doesn't work, immediately regenerate the same content as a plain file rather than asking why or offering to fix the link.
