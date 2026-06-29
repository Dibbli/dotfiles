---
description: Turn a ticket (URL, ID, or pasted text) into a structured spec, then enter plan mode. Usage:/intake [ticket-or-url]
disable-model-invocation: true
---

# Intake

Two-stage flow: a cheap model distills the raw ticket into a tight spec, then opus plans against that spec. The point is to spend opus's context on design, not on chewing through ticket noise.

## Steps

1. **Resolve ticket source**:
   - If `$1` is provided and looks like a URL or ticket ID:
     - If an Atlassian, Linear, or Jira MCP tool is connected, fetch the ticket via MCP.
     - Otherwise tell the user "no ticket MCP available, paste the ticket body" and wait.
   - If `$1` is empty, ask the user to paste the ticket body.
   - If `$1` looks like prose (not a URL/ID), treat it as the ticket body directly.

2. **Distill via subagent**: dispatch the `ticket-distiller` agent (haiku) with the raw ticket text. It returns exactly:

   ```
   ## Problem
   ## Acceptance criteria
   ## Out of scope
   ## Open questions
   ## Risks / unknowns
   ```

3. **Confirm and hand off to plan mode**:
   - Print the spec back to the user. Ask: "proceed to plan mode? (y / edit / abort)".
   - On `y`: enter plan mode seeded with the spec.
   - On `edit`: take the user's edits, re-confirm.
   - On `abort`: stop.

## Notes

- Do not fetch ticket bodies from URLs via WebFetch unless the user explicitly OKs it, tickets often live behind auth and may contain secrets.
- If the ticket body is shorter than ~500 chars, skip the distiller and go straight to plan mode; the two-stage step earns its keep on long tickets, not short ones.
