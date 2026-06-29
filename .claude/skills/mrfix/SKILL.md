---
description: Pull all comments from a GitLab MR via glab, diagnose each one, then fix them. Usage:/mrfix [mr-id-or-url]
disable-model-invocation: true
allowed-tools:
  - Bash(glab *)
  - Bash(git *)
  - Bash(jq *)
  - mcp__context7__resolve-library-id
  - mcp__context7__query-docs
---

# MR Fix

Pull every comment off a GitLab MR, work out what each reviewer actually wants, then apply the fixes locally. Diagnosis runs in opus context (logic, judgement); implementation follows after user approval.

## Steps

1. **Resolve MR**:
   - If `$1` looks like an MR URL or numeric ID, use it.
   - Else `glab mr show -F json` on the current branch. Fail clearly if there's no MR for the branch.
   - Capture: project path, MR `iid`, source branch, target branch, current HEAD SHA.

2. **Pre-flight**:
   - `git status --porcelain` must be clean. If not, stop and ask the user to commit or stash.
   - `git fetch origin` and `git rev-parse --abbrev-ref HEAD`, ensure local branch matches the MR's source branch. If not, stop.

3. **Pull comments**:
   - **Threaded (positional) discussions**, `glab api "projects/:id/merge_requests/<iid>/discussions?per_page=100"` (paginate via `--paginate` if the API supports it for this endpoint, else loop on `?page=N`).
   - **General notes**, already covered by the discussions endpoint; do not double-fetch via `glab mr note list`.
   - Save raw JSON to `/tmp/mrfix-<iid>-discussions.json` for the diagnosis step.

4. **Filter**:
   - Drop system notes (`"system": true`), these are auto-events (assigned, label added).
   - Drop resolved threads (`"resolved": true` on the discussion or all its notes).
   - Drop notes authored by the current user (resolve via `glab api user`), replying to one's own comments isn't a fix target.
   - Drop notes from known bots if the project uses them (sonarqube, danger, dependabot), flag these to the user separately rather than acting on them.
   - Keep: file path + old/new line from `position`, note body, author username, discussion ID, note ID.

5. **Diagnose** (in-context, opus):
   - For each remaining comment, decide one of:
     - **Actionable code change**: clear ask tied to a file:line. Output: `<file>:<line>, <what to change>, <why>`.
     - **Question, no change implied**: reviewer asked for clarification. Draft a one-sentence Hungarian reply (per MR comment style) the user can paste; do not modify code.
     - **Disagree-worthy**: ask seems wrong or contradicts repo conventions / `CLAUDE.md`. Flag with a short rebuttal the user can paste.
     - **Out of scope**: stylistic preference, future work. Note and skip.
   - Group actionable items by file. Note conflicts where two reviewers asked for opposite things, surface those to the user, don't pick a side.

6. **Confirm**:
   - Print the diagnosis grouped by category (Actionable / Replies / Disagree / Out-of-scope / Conflicts).
   - Ask: "apply actionable fixes? (y / select / abort)". `select` lets the user disable specific items by discussion ID.

7. **Apply**:
   - If a fix touches a third-party library/framework API, call context7 (`mcp__context7__resolve-library-id` then `mcp__context7__query-docs`) before writing the change. Reviewers' suggestions can be wrong about library shapes too, verify before applying.
   - Make the changes in the order the diagnosis listed them.
   - After each file is touched, re-read it to confirm the edit landed where intended.
   - Run `/review` over the diff before reporting done. Address `[CRITICAL]` findings; surface `[WARN]/[NIT]` to the user.

8. **Report**:
   - Per-thread status block:
     ```
     <discussion-id> | <file>:<line> | <author> | <action taken | reply drafted | skipped>
     ```
   - Drafted replies in MR comment style (Hungarian, no em-dashes, paste-ready), one per relevant thread.
   - Final summary: `<n> applied, <n> replies drafted, <n> skipped, <n> conflicts.`

## Notes

- **Do not commit**, user handles commits themselves. Stage nothing automatically.
- **Do not post replies to GitLab**, output them as paste-ready blocks instead. Posting under the user's name is a visible action that needs explicit per-call approval.
- **Do not resolve threads** via `glab`, same reason.
- If `glab` isn't authenticated (`glab auth status` fails), stop and ask the user to run `glab auth login`.
- For very large MRs (>50 comments), batch the diagnosis output by file rather than one giant block.
