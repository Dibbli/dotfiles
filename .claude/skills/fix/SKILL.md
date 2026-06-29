---
description: Review uncommitted changes (or current branch vs base) with static gates, parallel specialist subagents, and a confidence-filter pass, then produce an actionable plan to fix the surviving findings. Usage:/fix
agent: code-reviewer
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
---

# /fix

Multi-agent review of a diff with a confidence filter, output as a concrete fix plan grouped by file. Does not edit code, the user reviews the plan first.

**You are an orchestrator, not a reviewer.** Do not produce review findings yourself. Every finding must come from a subagent invoked via the Agent tool. Your job is: collect context, fan out Agent calls, collect results, fan out scorer calls, format a fix plan.

**Read-only contract for ALL subagents.** Every Agent prompt in this skill MUST end with this exact paragraph (in addition to its own return-format instruction):

> READ-ONLY MODE. Do NOT call Edit, Write, or NotebookEdit. Do NOT use Bash for any state-changing operation: no `>` / `>>` redirects, no `tee`, no `sed -i`, no `mv`/`cp`/`rm`, no `git add`/`git commit`/`git checkout --`/`git reset`/`git push`/`git stash`. Read, Grep, Glob, and read-only Bash (`git diff`, `git log`, `cat`, `ls`, `grep`, `find`, `rg`) only. If you find yourself wanting to apply a fix, return it as a finding instead, the orchestrator and the user decide what gets applied.

**Language rule.** Status updates and the final plan are English.

## Steps

1. **Determine scope**:
   - Run `git status --porcelain`.
   - If non-empty → review uncommitted changes (`git diff --stat`, `git diff`).
   - If empty → review current branch vs base:
     - Resolve base: `git symbolic-ref refs/remotes/origin/HEAD` (strip `refs/remotes/origin/`). On failure, try `main`, `master`, `develop` in that order, pick the first that exists locally.
     - Run `git log --no-merges --stat <base>..HEAD` and `git log --no-merges -p <base>..HEAD`.

2. **Static gates**, detect tooling, run only what's present, do not error on missing tooling:
   - `package.json`: read scripts. If `typecheck` exists run it; else if `tsc` is on PATH and `tsconfig.json` exists run `tsc --noEmit`. Run `lint` script if defined.
   - `Cargo.toml`: `cargo check`, then `cargo clippy --all-targets -- -D warnings` if clippy is available.
   - `go.mod`: `go vet ./...` and `gofmt -l .`.
   - `pyproject.toml`: `ruff check .` if ruff available; `mypy` if a config block exists.
   - Skip silently for any stack not present. Capture all failures, they become fix-plan items alongside subagent findings.

3. **Parallel specialist review**, you MUST issue these as Agent tool calls, all in a single assistant message so they run concurrently. **Pass `model: "sonnet"` to every Agent call in this step unless the user invoked `/fix opus`, these specialists are pattern-matching reviewers, not deep reasoners.** Do not summarize or substitute. Each call's prompt must include the full diff, the list of changed file paths, and **paths only** (not contents) to any `CLAUDE.md` / `.claude/rules/` files (authoritative repo conventions). Subagents read those files on demand if a finding hinges on a convention; do not paste rule-file contents into prompts.
   - Agent with `subagent_type: code-reviewer`, generalist (type safety, error handling, DRY, security smells, dead code, naming, repo-convention compliance, tests where a framework exists).
   - Agent with `subagent_type: silent-failure-hunter`, swallowed errors, empty catches, fallback-on-error patterns, missing logging at I/O boundaries.
   - Agent with `subagent_type: pr-test-analyzer`, test coverage gaps for new branches and edge cases (only when a test framework is present).
   - Agent with `subagent_type: type-design-analyzer`, only when the diff introduces or modifies types/interfaces/data models.
   - Agent with `subagent_type: comment-analyzer`, run whenever the diff contains code changes (not just new comments). It must check existing and added comments for: (a) **context poisoning**, comments that bake in obsolete framing, stale assumptions, or misleading rationale that will mislead future readers; (b) **over-specificity**, comments naming exact call sites, ticket IDs, dates, or "added for X" provenance that rots as the code evolves; (c) **historical narration**, any "this used to…", "previously…", "we changed this from…" wording, the comment must describe current behavior only; (d) **gaps**, new places in the changed code where a comment SHOULD exist (non-obvious WHY, hidden constraint, subtle invariant, surprising behavior). Findings for (d) use `issue` = "missing comment" and `fix` = the suggested comment text.

   Each agent prompt must end with the read-only contract paragraph (verbatim from the top of this file), followed by: "Return findings as a JSON array of `{path, line, severity, issue, fix, ease}` where `ease` is an integer 1–4: 1 = trivial (1–2 line change), 2 = easy (< 10 lines), 3 = medium, 4 = hard/invasive. The `fix` field must be a concrete change description, not vague advice. No prose." Skip a specialist whose trigger condition isn't met. Merge all returned findings.

4. **Confidence filter**, two independent haiku passes per finding. Both passes are Agent calls with `subagent_type: Explore` and `model: haiku`. Explore is used (not general-purpose) because its tool list excludes Edit/Write/NotebookEdit, a hard guarantee scorers cannot apply edits even if a prompt is misinterpreted. Issue every Pass A and Pass B call in a single assistant message so they all run concurrently. The specialist's self-reported `ease` is discarded, Pass B replaces it.

   Each Pass A and Pass B prompt MUST start with the read-only contract paragraph from the top of this file, followed by the verbatim band/scale prompt below.

   **Pass A, reality scorer.** Prompt receives the full diff, relevant `CLAUDE.md` / `.claude/rules/` paths, and the single finding. Do not mention ease, thresholds, or how the score will be used. Prompt body verbatim:

   ```
   Return an integer 0-100. Bands:
     0-20   false positive: pre-existing, not on changed lines, misreads code,
            or would be caught by linter/typechecker/compiler.
     21-40  speculative: can't verify from the diff alone.
     41-60  real but small: verified, narrow blast radius or edge case.
     61-80  real and routine: hits in normal use, or backed by CLAUDE.md.
     81-100 real and load-bearing: correctness bug, security, swallowed error,
            or explicit convention violation.

   Pick a specific number inside the band. No prose.
   ```

   **Pass B, ease rater.** Independent of Pass A, runs in parallel. Prompt receives the diff and the single finding's `fix` description. Prompt body verbatim:

   ```
   How invasive is the proposed fix? Return a single integer 1-4.
     1  trivial, 1-2 line change, no ripple.
     2  easy, under ~10 lines in one file, no API change.
     3  medium, multiple files or a small API/shape change.
     4  hard, broad refactor, public API change, or migration needed.

   No prose.
   ```

   **Comment-analyzer findings skip this filter.** They are comment-only changes with zero blast radius, and haiku scoring of prose nuance is unreliable. Carry them through with `score = n/a` and the analyst's own `ease` value (default 1).

   **Combine** (orchestrator only, never shown to haiku):
   - score ≥ 61: keep, always.
   - score 41-60: keep if ease ≤ 3.
   - score 21-40: keep if ease ≤ 2.
   - score 0-20: drop.

   If nothing survives and static gates passed, output `No fixes needed.` and stop.

5. **Output a fix plan**, do not edit code. The plan is for the user to review before greenlighting changes. Structure:

   **Static gates** (only if any failed): one bullet per failing tool with the failure summary and what needs to happen to make it pass. Skip the section entirely if all gates passed or none ran.

   **Fixes**, grouped by file path, sorted critical-to-warn within each file. For each finding:
   - Header line: `path/to/file.ext:line` (or `path:line-line`), then a short title in parens describing the change category (e.g. "null check", "extract helper", "swallowed error").
   - One line: what's wrong, stated as fact.
   - One line starting with `Fix:` describing the concrete change. Reference call sites or related files inline as `see other-file.ts:269-272` when relevant.
   - One tag line: `[ease N, score S]` using the Pass A and Pass B values. For comment-analyzer findings use `[ease N, score n/a, comments]`.

   Order files by total severity (most critical first). Within a file, order by line number.

   **Suggested order of operations**, a final short numbered list (max 5 items) sequencing the work: cheapest/blocking-est first (failing static gates, then ease-1 fixes, then larger refactors). Group related fixes that should land in the same commit.

   **Hard nos**: no em-dashes (use period, comma, parens, or "see"); no code blocks unless a fix genuinely requires showing a snippet (then keep it under 5 lines); no padding words like "Concerns:", "Note:", "Consider:"; do not repeat the file path inside the body lines; no airy blank-line spacing between bullets in the same group.

   End with a one-line summary outside the plan: `<n> fixes across <m> files. Static gates: <pass/fail per tool>.`

6. **Wait for user direction.** Do not start applying fixes. The plan is the deliverable. The user will pick which items to act on.
