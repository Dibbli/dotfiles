---
description: Review uncommitted changes or current branch vs base with static gates and a multi-agent blame-gated review, output as paste-ready Hungarian GitLab MR comments written to a file. Use when preparing MR review comments, reviewing a branch for merge, or commenting on a diff. Read-only. Usage /mr [en] [opus]
disable-model-invocation: true
allowed-tools:
  - Workflow
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
  - Write
---

# /mr

Static gates plus a multi-agent diff review, output as paste-ready Hungarian GitLab MR comment blocks written to a file.

The review (specialist fan-out, blame gate, scoring, keep filter) runs in the `review-diff` workflow. This skill collects scope, runs static gates, invokes the workflow, and formats the result.

**Language.** Speak to the user in English (status updates, the final summary line). The MR comment blocks are Hungarian by default; if `$1 == "en"`, the blocks are English too. The rest of the style rules are unchanged.

## Steps

1. **Determine scope.**
   - `git status --porcelain` non-empty → working tree: `diffRange = ""`, `baseRef = "HEAD"`.
   - empty → branch: resolve base via `git symbolic-ref refs/remotes/origin/HEAD` (strip prefix; fall back to `main`, `master`, `develop`). `diffRange = "<base>...HEAD"`, `baseRef = "<base>"`.

2. **Static gates.** Detect tooling, run what's present, never error on missing: `typecheck`/`lint` for `package.json`; `cargo check` + clippy for `Cargo.toml`; `go vet`/`gofmt -l .` for `go.mod`; `ruff`/`mypy` for `pyproject.toml`. Report failures inline; do not block.

3. **Flags**: `hasTestFramework`, `touchesTypes`, `deep` (true on `/mr opus`), `changedPaths`, `rulePaths` (paths only, not contents).

4. **Invoke the review** with the Workflow tool:
   `Workflow({ name: "review-diff", args: { repoPath, diffRange, baseRef, changedPaths, rulePaths, mode: "mr", deep, hasTestFramework, touchesTypes } })`
   Returns `{ findings, commentFindings }`. In `mr` mode `findings` are the score-≥61 survivors. `commentFindings` are raw comment-analyzer notes; you select at most 2 load-bearing ones (below).

5. **Output** paste-ready GitLab MR comment blocks **written to a Markdown file in `~/Downloads`** (do not dump them in chat). Filename: `~/Downloads/mr-review-<branch>.md`, where `<branch>` is `git rev-parse --abbrev-ref HEAD` with `/`→`-`; if detached, `mr-review.md`. Body, in this fixed order:

   **Real findings first** (the workflow's `findings`), sorted critical to warn, one block per finding separated by `---` on its own line. If none survived, write `Nincs jelzés.` (`No findings.` in en).

   **Comment-only findings second**: from `commentFindings`, keep at most **2**, only clearly load-bearing (a comment that will actively mislead a future reader, or a missing comment whose WHY is genuinely non-obvious). Drop everything stylistic or "could be clearer". Same block format, after the real findings, no section header. Skip if empty.

   Write every block in the style of `style.md` next to this file (read it before writing). Skip nit-tier findings unless nothing higher survives.

   After writing the file, end with one English line: `Wrote <path>. <n> findings, <c> comment notes. Static gates: <pass/fail per tool>.` If nothing survived, still write the file containing `Nincs jelzés.` (`No findings.` in en) and report the path the same way.
