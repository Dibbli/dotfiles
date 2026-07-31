---
name: mr
description: Use when preparing GitLab MR review comments for uncommitted changes or the current branch. Static gates plus specialist review, output as paste-ready Hungarian (or English) MR comment blocks written to a file in ~/Downloads. Read-only. Usage mr [en] [opus].
---

# MR

Review one change set with static gates and specialist agents, then write paste-ready GitLab MR comment blocks to a file. Read-only: do not edit, format, stage, commit, stash, reset, or push.

**Language.** Speak to the user in English (status, the final summary line). The MR comment blocks are Hungarian by default; when invoked as `mr en`, the blocks are English. `mr opus` means review deeper.

## 1. Freeze the scope

Confirm the current directory is a Git worktree. Run `git status --porcelain`.

- Non-empty: review all working-tree changes against `HEAD`. Use `git diff HEAD` for tracked files and `git ls-files --others --exclude-standard` for untracked paths; include untracked text file contents in the frozen diff.
- Empty: resolve the base from `refs/remotes/origin/HEAD`. If that fails, use the first locally existing branch from `main`, `master`, then `develop`. Review `<base>...HEAD`.

Record the base revision, changed paths, and complete diff once. The frozen diff is authoritative for the whole run. If there is no reviewable diff, say so and stop. Find repository instruction files (`AGENTS.md`, `CLAUDE.md`, scoped rule files) and pass their paths to reviewers.

## 2. Run static gates

Detect tooling from repository files and installed commands; missing tools are skipped, never failures.

- `package.json`: run its `typecheck` script when present, else `tsc --noEmit` when `tsc` and `tsconfig.json` exist; run its `lint` script when present.
- `Cargo.toml`: `cargo check`, then `cargo clippy --all-targets -- -D warnings` when clippy is installed.
- `go.mod`: `go vet ./...` and `gofmt -l .`.
- `pyproject.toml`: `ruff check .` when ruff is installed; mypy only when mypy config exists and mypy is installed.

Capture concise failure evidence. A failed gate is reported inline and does not stop review. Detect whether a test framework exists, and whether the frozen diff changes types, interfaces, enums, schemas, or data models.

## 3. Dispatch specialist review

Spawn these custom agents with their matching `agent_type`, subject to the session concurrency limit:

- `code-reviewer`
- `silent-failure-hunter`
- `comment-analyzer`
- `pr-test-analyzer`, only when a test framework exists
- `type-design-analyzer`, only when types or schemas changed

Tell every agent: this is read-only; review only the frozen diff and consequences it causes; use the base revision to separate new from pre-existing issues; read only relevant surrounding code and applicable repository instructions; return findings with `severity`, `path`, `line`, `issue`, `fix`, `ease`; return nothing when evidence is speculative. Wait for every dispatched agent. If an optional specialist is unavailable, note it and continue.

## 4. Apply the blame gate

Independently verify every finding. A finding survives only when this diff introduced it: the problem is on a line the diff added or changed, or the diff changes a contract and thereby breaks a caller, exhaustive mapping, switch, schema consumer, or other dependent site. Compare with `git show <base>:<path>` when needed. Drop anything that exists unchanged at the base. Do not delegate this decision. Deduplicate overlapping findings, keeping the clearest issue.

## 5. Score and filter

Assign each surviving non-comment finding a confidence score 0 to 100:

- 0-20 false positive or already enforced by tooling
- 21-40 plausible but weakly supported
- 41-60 verified, narrow issue or edge case
- 61-80 verified issue in normal use or explicit convention violation
- 81-100 correctness, security, data-loss, or load-bearing failure

For MR output, keep only findings scoring at least 61. Comment findings stay unscored after the blame gate; from them keep at most **2**, only clearly load-bearing (a comment that will actively mislead a future reader, or a missing comment whose WHY is genuinely non-obvious). Drop everything stylistic or "could be clearer".

## 6. Write the comment file

Write to `~/Downloads/mr-review-<branch>.md`, where `<branch>` is `git rev-parse --abbrev-ref HEAD` with `/` replaced by `-`; if detached, `mr-review.md`. Do not dump the blocks in chat. Body in this fixed order:

**Real findings first** (the score-≥61 survivors), sorted critical to warn, one block per finding separated by `---` on its own line. If none survived, write `Nincs jelzés.` (`No findings.` in en mode).

**Comment-only findings second**: the kept comment findings, under a single header `Komment-észrevételek:` (`Comment-only notes:` in en), same block format, separated by `---`. Skip the whole section, header included, when empty.

Each block:

- First line: `path/to/file.ext:line`. Anchor on the single offending line; ranges (`path:line-line`) only for genuinely multi-line patterns.
- Blank line.
- One sentence (two if necessary) in casual developer voice. State the observation, not full reasoning.
  - **Default**: Hungarian, proper accents (`működne`, `lásd`, `kéne`), all lowercase including the sentence start; proper nouns and identifiers keep their case (`BadRequestError`, `useEffect`, `Float`). Rhetorical questions ("itt működne X?", "inkább Y?") and short imperatives ("ezt page object-be kéne rakni", "rakjuk át elé") are the register.
  - **en mode**: English, same casual lowercase register.
- **State the consequence, not the rule.** Not `"konvenció miatt"` but the concrete failure mode: `"try elé, különben az auth error sima form errorba megy."` The `"különben X"` / `"hogy ne Y"` tail is the typical shape. No `"kell"`/`"kellene"` filler unless the sentence needs it.
- **Never cite `.claude/rules/*`, `AGENTS.md`, `CLAUDE.md`, or rule names in a comment body** — it screams AI. State the corrective action or its consequence. At most `"konvenció miatt"` / `"máshol is így van"`, and prefer the concrete failure mode.
- English loanwords stay English inside Hungarian: "auth error" / "form error", not "auth hiba".
- **Quote keywords with double quotes**: `"as" cast`, not `as cast`.
- **Cite real in-repo examples** when recommending a pattern, smallest meaningful range: `(példa: <path:line>)`. If no in-repo example exists, point at a sibling repo in the workspace with `(példa még itt nincs, <repo>-ban itt: <path:line-line>)`; do not imply a missing reference is local.
- Reference related sites inline: `lásd other-file.ts:269-272` (en: `see other-file.ts:269-272`).

**Hard nos**: no em-dashes anywhere (use period, comma, parens, or "lásd"); no code blocks or "suggested change" snippets unless asked; no section headers beyond the single comment-bucket header; no bullet lists inside a comment; do not repeat the file path in the body; no padding words. **No AI flourishes**: no "sziget" metaphor for interactive components, no "shape cast" (say "as cast"), no "határon"/"a határponton" for fetch/API boundaries, no "némán"/"nyom nélkül", no "ág" for code branches (say "domainbe kerüljön"). Skip nit-tier findings unless nothing higher survives.

After writing the file, end with one English line: `Wrote <path>. <n> findings, <c> comment notes. Static gates: <pass/fail per tool>.` If nothing survived, still write the file containing `Nincs jelzés.` (`No findings.` in en) and report the path the same way.
