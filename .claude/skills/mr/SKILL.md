---
description: Review uncommitted changes or current branch vs base with static gates and a multi-agent blame-gated review, output as paste-ready Hungarian GitLab MR comments written to a file. Use when preparing MR review comments, reviewing a branch for merge, or commenting on a diff. Read-only. Usage /mr [en] [opus]
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
   `Workflow({ scriptPath: "$HOME/.claude/workflows/review-diff.js", args: { repoPath, diffRange, baseRef, changedPaths, rulePaths, mode: "mr", deep, hasTestFramework, touchesTypes } })`
   Returns `{ findings, commentFindings }`. In `mr` mode `findings` are the score-≥61 survivors. `commentFindings` are raw comment-analyzer notes; you select at most 2 load-bearing ones (below).

5. **Output** paste-ready GitLab MR comment blocks **written to a Markdown file in `~/Downloads`** (do not dump them in chat). Filename: `~/Downloads/mr-review-<branch>.md`, where `<branch>` is `git rev-parse --abbrev-ref HEAD` with `/`→`-`; if detached, `mr-review.md`. Body, in this fixed order:

   **Real findings first** (the workflow's `findings`), sorted critical to warn, one block per finding separated by `---` on its own line. If none survived, write `Nincs jelzés.` (`No findings.` in en).

   **Comment-only findings second**: from `commentFindings`, keep at most **2**, only clearly load-bearing (a comment that will actively mislead a future reader, or a missing comment whose WHY is genuinely non-obvious). Drop everything stylistic or "could be clearer". Under a single header `Komment-észrevételek:` (`Comment-only notes:` in en), same block format, separated by `---`. Skip the whole section, including the header, if empty.

   Each block:
   - First line: `path/to/file.ext:line`. Anchor on the single offending line; ranges (`path:line-line`) only for genuinely multi-line patterns.
   - Blank line.
   - One sentence (two if necessary) in casual developer voice. State the observation, not full reasoning.
     - **Default**: Hungarian, with proper accents (`működne`, `lásd`, `kéne`), all lowercase including the sentence start — proper nouns and identifiers keep their case (`BadRequestError`, `useEffect`, `Float`). Rhetorical questions ("itt működne X?", "inkább Y?") and short imperatives ("ezt page object-be kéne rakni", "rakjuk át elé") are the register.
     - **en mode**: English, same casual lowercase register.
   - **State the consequence, not the rule.** Not `"konvenció miatt"` but the concrete failure mode: `"try elé, különben az auth error sima form errorba megy."` The `"különben X"` / `"hogy ne Y"` tail is the typical shape. No `"kell"`/`"kellene"` filler unless the sentence needs it.
   - **Never cite `.claude/rules/*`, `AGENTS.md`, `CLAUDE.md`, or rule names in a comment body** — it screams AI. State the corrective action or its consequence, not the source. At most `"konvenció miatt"` / `"máshol is így van"`, and prefer the concrete failure mode.
   - English loanwords stay English inside Hungarian: "auth error" / "form error", not "auth hiba".
   - **Quote keywords with double quotes**: `"as" cast`, not `as cast`.
   - **Cite real in-repo examples** when recommending a pattern, smallest meaningful range: `(példa: <path:line>)`. If no in-repo example exists, point at a sibling repo in the workspace with `(példa még itt nincs, <repo>-ban itt: <path:line-line>)` — don't imply a missing reference is local.
   - Reference related sites inline: `lásd other-file.ts:269-272` (en: `see other-file.ts:269-272`).

   **Hard nos**: no em-dashes anywhere (use period, comma, parens, or "lásd"); no code blocks or "suggested change" snippets unless asked; no section headers beyond the single comment-bucket header; no bullet lists inside a comment; do not repeat the file path in the body; no padding words. **No AI flourishes**: no "sziget" metaphor for interactive components, no "shape cast" (say "as cast"), no "határon"/"a határponton" for fetch/API boundaries, no "némán"/"nyom nélkül", no "ág" for code branches (say "domainbe kerüljön"). Skip nit-tier findings unless nothing higher survives.

   After writing the file, end with one English line: `Wrote <path>. <n> findings, <c> comment notes. Static gates: <pass/fail per tool>.` If nothing survived, still write the file containing `Nincs jelzés.` (`No findings.` in en) and report the path the same way.
