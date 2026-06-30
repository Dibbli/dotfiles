---
description: Review uncommitted changes or current branch vs base with static gates and a multi-agent blame-gated review, output as a concrete fix plan grouped by file. Use when reviewing your own code, checking a diff or branch, or finding bugs and cleanups before committing. Read-only, produces a plan and does not edit. Usage /fix [opus]
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(pnpm *)
  - Bash(npm *)
  - Bash(yarn *)
  - Bash(bun *)
  - Bash(cargo *)
  - Bash(go *)
  - Bash(ruff *)
  - Bash(mypy *)
  - Bash(uv run *)
  - Read
---

# /fix

Static gates plus a multi-agent diff review, output as a concrete fix plan grouped by file. Does not edit code, you review the plan first. The plan is English.

The review itself (specialist fan-out, a blame gate that drops anything not introduced by this diff, confidence scoring, and the keep filter) runs in the `review-diff` workflow. This skill's job: collect scope, run static gates, invoke the workflow, format the result.

## Steps

1. **Determine scope.**
   - `git status --porcelain`. Non-empty → review the working tree: `diffRange = ""`, `baseRef = "HEAD"`.
   - Empty → review the branch: resolve base via `git symbolic-ref refs/remotes/origin/HEAD` (strip `refs/remotes/origin/`; on failure fall back to `main`, `master`, `develop`, first that exists locally). `diffRange = "<base>...HEAD"`, `baseRef = "<base>"`.

2. **Static gates.** Detect tooling, run only what's present, never error on missing tooling:
   - `package.json`: run the `typecheck` script if defined, else `tsc --noEmit` when `tsc` and `tsconfig.json` exist; run `lint` if defined.
   - `Cargo.toml`: `cargo check`, then `cargo clippy --all-targets -- -D warnings` if clippy is present.
   - `go.mod`: `go vet ./...` and `gofmt -l .`.
   - `pyproject.toml`: `ruff check .` if present; `mypy` if a config block exists.
   - Capture failures, they become fix-plan items alongside the workflow's findings.

3. **Detect the workflow flags** from the diff and repo:
   - `hasTestFramework`: a test runner is configured (vitest/jest/playwright/pytest/`cargo test`/`go test`).
   - `touchesTypes`: the diff adds or changes types, interfaces, enums, schemas, or data models.
   - `deep`: true only if invoked as `/fix opus`.
   - `changedPaths`: the file paths in the diff. `rulePaths`: paths (not contents) of `CLAUDE.md` and any `.claude/rules/*`.

4. **Invoke the review** with the Workflow tool:
   `Workflow({ scriptPath: "$HOME/.claude/workflows/review-diff.js", args: { repoPath, diffRange, baseRef, changedPaths, rulePaths, mode: "fix", deep, hasTestFramework, touchesTypes } })`
   It returns `{ findings, commentFindings }`. `findings` are already blame-gated, scored, and kept; each carries `score` and `ease`. `commentFindings` are comment-analyzer notes, unscored.

5. **Output a fix plan** (do not edit code):
   - **Static gates** (only if any failed): one bullet per failing tool with the failure summary and what must happen to make it pass. Skip the section if all passed or none ran.
   - **Fixes**, grouped by file path, sorted critical-to-warn within each file. For each finding:
     - Header line: `path/to/file.ext:line` (or `path:line-line`), then a short parenthetical category ("null check", "swallowed error", "extract helper").
     - One line: what's wrong, stated as fact.
     - One line starting with `Fix:` describing the concrete change; reference related sites inline as `see other-file.ts:269-272`.
     - One tag line: `[ease N, score S]`. For comment findings: `[ease N, score n/a, comments]`.
   - Order files by total severity (most critical first); within a file, by line number.
   - **Suggested order of operations**: a final numbered list (max 5) sequencing the work — failing gates first, then ease-1 fixes, then larger refactors; group fixes that should land in one commit.
   - **Hard nos**: no em-dashes (use period, comma, parens, or "see"); no code blocks unless a fix needs a snippet under 5 lines; no padding words ("Concerns:", "Note:", "Consider:"); do not repeat the path in body lines; no airy blank-line spacing within a group.
   - End with a one-line summary outside the plan: `<n> fixes across <m> files. Static gates: <pass/fail per tool>.`
   - If nothing survived and gates passed: output `No fixes needed.` and stop.

6. **Wait for user direction.** The plan is the deliverable; do not start applying fixes.
