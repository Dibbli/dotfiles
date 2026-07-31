---
name: fix
description: Use when reviewing uncommitted changes or the current branch for concrete bugs and cleanups before committing. Read-only and returns a fix plan.
---

# Fix

Review one change set with static gates and specialist agents, then return a concrete fix plan. This workflow is read-only: do not edit, format, stage, commit, stash, reset, or push.

**Options.** If the request includes `noblame` (for example "fix noblame"), skip the blame gate in step 4 and report every finding, including pre-existing issues in the files this change touches. The default is blame-gated.

## 1. Freeze the scope

Confirm the current directory is a Git worktree. Run `git status --porcelain`.

- When status is non-empty, review all working-tree changes against `HEAD`. Use `git diff HEAD` for tracked files and `git ls-files --others --exclude-standard` for untracked paths. Include untracked text file contents in the frozen diff.
- When status is empty, resolve the base from `refs/remotes/origin/HEAD`. If that fails, use the first locally existing branch from `main`, `master`, then `develop`. Review `<base>...HEAD`.

Record the base revision, changed paths, and complete diff once. The frozen diff is authoritative for the entire run. If there is no reviewable diff, say so and stop.

Find repository instruction files such as `AGENTS.md`, `CLAUDE.md`, and scoped rule files. Pass their paths to reviewers so they can read applicable rules without copying unrelated content into the main thread.

## 2. Run static gates

Detect tooling from repository files and installed commands. Missing tools are skipped, never treated as failures.

- `package.json`: run its `typecheck` script when present. Otherwise run `tsc --noEmit` when `tsc` and `tsconfig.json` exist. Run its `lint` script when present.
- `Cargo.toml`: run `cargo check`. Run `cargo clippy --all-targets -- -D warnings` when clippy is installed.
- `go.mod`: run `go vet ./...` and `gofmt -l .`.
- `pyproject.toml`: run `ruff check .` when ruff is installed. Run mypy only when mypy configuration exists and mypy is installed.

Capture concise failure evidence. A failed gate becomes a fix-plan item and does not stop specialist review.

Detect whether a test framework already exists. Detect whether the frozen diff changes types, interfaces, enums, schemas, or data models.

## 3. Dispatch specialist review

Spawn these custom agents with their matching `agent_type`, subject to the session concurrency limit:

- `code-reviewer`
- `silent-failure-hunter`
- `comment-analyzer`
- `pr-test-analyzer`, only when a test framework exists
- `type-design-analyzer`, only when types or schemas changed

Tell every agent:

- This is read-only.
- Review only the supplied frozen diff and consequences caused by it.
- Use the base revision to distinguish new issues from pre-existing issues.
- Read only relevant surrounding code and applicable repository instructions.
- Return findings with `severity`, `path`, `line`, `issue`, `fix`, and `ease`.
- `ease` is 1 for a one or two-line local fix, 2 for under roughly ten lines in one file, 3 for a small multi-file or API-shape change, and 4 for a broad refactor or migration.
- Return no finding when evidence is speculative.

Wait for every dispatched agent. If an optional specialist is unavailable, report that limitation and continue with the remaining evidence.

## 4. Apply the blame gate

When invoked with `noblame`, skip the verification below and keep every finding regardless of whether this diff introduced it. Otherwise the primary agent must independently verify every proposed finding. A finding survives only when it was introduced by this diff:

- The problem is on a line added or changed in the frozen diff, or
- The diff changes a contract and thereby breaks a caller, exhaustive mapping, switch, schema consumer, or other dependent site.

Compare with `git show <base>:<path>` when needed. Drop any issue that exists unchanged at the base revision. Do not delegate this final blame decision.

Deduplicate overlapping specialist findings in either case, keeping the clearest issue and concrete fix.

## 5. Score and filter

Assign each surviving non-comment finding a confidence score from 0 to 100:

- 0 to 20: false positive or already enforced by tooling
- 21 to 40: plausible but weakly supported
- 41 to 60: verified, narrow issue or edge case
- 61 to 80: verified issue in normal use or explicit convention violation
- 81 to 100: correctness, security, data-loss, or load-bearing failure

Keep a finding when:

- confidence is at least 61, or
- confidence is 41 to 60 and ease is at most 3, or
- confidence is 21 to 40 and ease is at most 2.

Comment findings remain unscored after the blame gate. Keep only verified comment problems and assign their ease directly.

## 6. Output the plan

Do not edit code. Produce these sections only when they contain content.

### Static gates

One bullet per failing tool. State the failure and the concrete condition required for it to pass.

### Fixes

Group findings by file. Order files by total severity, then findings by line. For each finding use exactly:

```text
path/to/file.ext:line (short category)
What is wrong, stated as fact.
Fix: Concrete change, with related locations referenced inline.
[ease N, score S]
```

Use `[ease N, score n/a, comments]` for comment findings. Sort critical findings before warnings within a file.

### Suggested order of operations

Provide at most five numbered steps. Put failing gates first, then ease-1 fixes, then larger changes. Group changes that belong together.

End with:

```text
<n> fixes across <m> files. Static gates: <pass/fail per tool>.
```

Do not use padding labels, repeat paths in body lines, or add airy spacing inside a finding. Use no code block unless a concrete fix requires a snippet under five lines.

When all gates pass and no finding survives, output exactly:

```text
No fixes needed.
```

Stop and wait for user direction.
