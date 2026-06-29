---
description: Triage a bug, draft a failing test, fix it, verify, then self-review. Usage:/bugfix [issue-or-description]
disable-model-invocation: true
---

# Bugfix

Reproduce-first loop. The failing test is the contract: it pins down both the symptom and "fixed" before anyone touches code.

## Steps

1. **Gather symptom**:
   - From `$1`, an MCP-fetched ticket (Atlassian/Linear/Jira if connected), or ask the user.
   - Capture: observed behaviour, expected behaviour, exact repro steps, environment (OS / runtime / version), recent changes if known.
   - If any of those are missing and not inferable, ask the user a single batched question rather than dribbling.

2. **Reproduce**, dispatch the `bug-reproducer` subagent. It will:
   - Use parallel Explore subagents to locate the suspect code path.
   - Propose a minimal repro.
   - If a test framework is detected (`vitest`, `jest`, `pytest`, `cargo test`, `go test`, etc.), draft a failing test in the repo's style.
   - Return: hypothesis (root cause), suspected `<file>:<line>`, draft test.

3. **Confirm with user**:
   - Show the hypothesis + draft test.
   - Wait for `y / edit / abort` before writing anything.

4. **Pin the bug**:
   - Write the test.
   - Run only that test. Confirm it fails *for the reason in the hypothesis* (not a setup error). If it fails for the wrong reason, loop back to step 2.

5. **Fix**:
   - If the fix touches a third-party library/framework API, call context7 (`mcp__context7__resolve-library-id` then `mcp__context7__query-docs`) before writing the patch. Cheap insurance against outdated API knowledge.
   - Smallest change that makes the test pass. No drive-by refactors.
   - Re-run the focused test → green.
   - Run the broader suite if it's cheap (under ~60s); skip if expensive and call that out in the report.

6. **Self-review**, invoke the `/review` skill on the resulting diff before reporting done. Address `[CRITICAL]` findings; surface `[WARN]/[NIT]` to the user.

7. **Report**:
   - **Root cause**: one paragraph, blame the code path not the symptom.
   - **Fix**: one-line summary + diff stat.
   - **Follow-ups**: related bugs that may share the same cause; tests worth adding for adjacent paths.
