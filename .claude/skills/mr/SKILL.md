---
description: Review uncommitted changes (or current branch vs base) with static gates, parallel specialist subagents, a confidence-filter pass, and Hungarian GitLab MR-comment output. Usage:/mr [en]
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

# /mr

Multi-agent review of a diff with a confidence filter, output as paste-ready Hungarian GitLab MR comments.

**You are an orchestrator, not a reviewer.** Do not produce review findings yourself. Every finding must come from a subagent invoked via the Agent tool. Your job is: collect context, fan out Agent calls, collect results, fan out scorer calls, format output.

**Read-only contract for ALL subagents.** Every Agent prompt in this skill MUST end with this exact paragraph (in addition to its own return-format instruction):

> READ-ONLY MODE. Do NOT call Edit, Write, or NotebookEdit. Do NOT use Bash for any state-changing operation: no `>` / `>>` redirects, no `tee`, no `sed -i`, no `mv`/`cp`/`rm`, no `git add`/`git commit`/`git checkout --`/`git reset`/`git push`/`git stash`. Read, Grep, Glob, and read-only Bash (`git diff`, `git log`, `cat`, `ls`, `grep`, `find`, `rg`) only. If you find yourself wanting to apply a fix, return it as a finding instead, the orchestrator and the user decide what gets applied.

**Language rule.** Always speak to the user in English (status updates, "running gates", "5 findings, 2 survived filter", the final summary line, etc.). The MR comment blocks themselves are Hungarian by default. If `$1 == "en"`, the comment blocks are English too (demo mode); the rest of the style rules still apply.

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
   - Skip silently for any stack not present. Report all failures inline; do not block subagents on them.

3. **Parallel specialist review**, you MUST issue these as Agent tool calls, all in a single assistant message so they run concurrently. **Pass `model: "sonnet"` to every Agent call in this step unless the user invoked `/mr opus`, these specialists are pattern-matching reviewers, not deep reasoners.** Do not summarize or substitute. Each call's prompt must include the full diff, the list of changed file paths, and **paths only** (not contents) to any `CLAUDE.md` / `.claude/rules/` files (authoritative repo conventions). Subagents read those files on demand if a finding hinges on a convention; do not paste rule-file contents into prompts.
   - Agent with `subagent_type: code-reviewer`, generalist (type safety, error handling, DRY, security smells, dead code, naming, repo-convention compliance, tests where a framework exists).
   - Agent with `subagent_type: silent-failure-hunter`, swallowed errors, empty catches, fallback-on-error patterns, missing logging at I/O boundaries.
   - Agent with `subagent_type: pr-test-analyzer`, test coverage gaps for new branches and edge cases (only when a test framework is present).
   - Agent with `subagent_type: type-design-analyzer`, only when the diff introduces or modifies types/interfaces/data models.
   - Agent with `subagent_type: comment-analyzer`, run whenever the diff contains code changes (not just new comments). It must check existing and added comments for: (a) **context poisoning**, comments that bake in obsolete framing, stale assumptions, or misleading rationale that will mislead future readers; (b) **over-specificity**, comments naming exact call sites, ticket IDs, dates, or "added for X" provenance that rots as the code evolves; (c) **historical narration**, any "this used to…", "previously…", "we changed this from…" wording, the comment must describe current behavior only; (d) **gaps**, new places in the changed code where a comment SHOULD exist (non-obvious WHY, hidden constraint, subtle invariant, surprising behavior). Findings for (d) use `issue` = "missing comment" and `fix` = the suggested comment text.

   Each agent prompt must end with the read-only contract paragraph (verbatim from the top of this file), followed by: "Return findings as a JSON array of `{path, line, severity, issue, fix, ease}` where `ease` is an integer 1–4: 1 = trivial (1–2 line change), 2 = easy (< 10 lines), 3 = medium, 4 = hard/invasive. The `fix` field must be a concrete change description, not vague advice. No prose." Skip a specialist whose trigger condition isn't met. Merge all returned findings.

4. **Confidence filter**, for each finding issue an Agent tool call (parallel, single message) with `subagent_type: Explore` and `model: haiku`. Explore is used (not general-purpose) because its tool list excludes Edit/Write/NotebookEdit, providing a hard guarantee scorers cannot apply edits even if a prompt is misinterpreted. The prompt: start with the read-only contract paragraph from the top of this file, then hand it the diff, the relevant `CLAUDE.md` paths, and the single finding. Do not mention thresholds or how the score is used. Prompt body verbatim:

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

   **Comment-analyzer findings are filtered separately and strictly.** Haiku scoring of prose nuance is unreliable, so don't route them through Pass A. Instead, keep at most **2** comment findings total, and only those that are clearly load-bearing: a comment that will actively mislead a future reader (context poisoning, historical narration on current behavior), or a missing comment where the WHY is genuinely non-obvious. Drop everything else, including all stylistic, "could be clearer", or "consider adding a note" suggestions. If more than 2 qualify, keep the 2 most load-bearing and drop the rest. Track these as a separate bucket from the real findings, they are rendered in their own section below.

   **Keep rule** (orchestrator only): keep if score ≥ 61. MR comments stay selective, ease is not consulted, the specialist's self-reported `ease` is ignored at this stage.

   If nothing survives, write the output file per step 5 containing `Nincs jelzés.` (or `No findings.` in `en` mode), report the path, and stop.

   False-positive examples to be strict about:
   - Pre-existing issues on lines the diff didn't touch.
   - Things a linter, typechecker, or compiler would catch (CI handles those).
   - Generic "could use more tests / better docs" without a CLAUDE.md mandate.
   - Pedantic nits a senior wouldn't raise.

5. **Output**, paste-ready GitLab MR comment blocks **written to a Markdown file in `~/Downloads`** (do not dump the blocks into the chat, write them to disk, then tell the user the path). Use the Write tool. Filename: `~/Downloads/mr-review-<branch>.md`, where `<branch>` is the current branch slugified (`git rev-parse --abbrev-ref HEAD`, replace `/` with `-`); if HEAD is detached or the name is unavailable, use `mr-review.md`. The file's body is exactly the two buckets below, in this fixed order so real issues are read first and comment-tier nits never crowd them out:

   **Real findings first** (everything that survived the confidence filter), sorted critical to warn. One block per finding, separated by `---` on its own line. If none survived, write `Nincs jelzés.` (or `No findings.` in `en` mode) in place of this section.

   **Comment-only findings second** (the ≤2 from the comment-analyzer bucket), under a single one-line header so the user can tell them apart at a glance. Header: `Komment-észrevételek:` (default) or `Comment-only notes:` (`en` mode). Then the blocks, same per-block format as above, separated by `---`. Skip the entire section, including the header, if the bucket is empty.

   Each block (both buckets):
   - First line: `path/to/file.ext:line`. **Anchor on the single offending line**, not a range, when the issue lives on one line; ranges (`path:line-line`) are only for genuinely multi-line patterns.
   - Blank line.
   - One sentence (two if necessary) in casual developer voice. State the observation, not full reasoning.
     - **Default**: Hungarian, **with proper accents** (`működne`, `lásd`, `kéne`), **all lowercase including the sentence start**, proper nouns and identifiers keep their case (`BadRequestError`, `useEffect`, `Float`). Rhetorical questions ("itt működne X?", "inkább Y?") and short imperatives ("ezt page object-be kéne rakni", "rakjuk át elé") are the target register.
     - **`en` mode**: English, same casual lowercase register. Rhetorical questions ("does this work when X?", "wouldn't Y be better?") and short imperatives ("pull this into a page object").
   - **State the consequence, not the rule.** Not `"konvenció miatt"` but the concrete failure mode: `"try elé, különben az auth error sima form errorba megy."` The "különben X" / "hogy ne Y" tail is the typical shape. No `"kell"` / `"kellene"` filler unless the sentence needs it.
   - **Never cite `.claude/rules/*`, `AGENTS.md`, `CLAUDE.md`, or rule names in a comment body**, it screams AI. Subagents may read those files to verify a convention (step 3), but the rendered comment states the corrective action or its consequence, not the source. At most say "konvenció miatt" / "máshol is így van", and prefer the concrete failure mode over even that.
   - English loanwords stay English inside Hungarian comments: "auth error" / "form error", not "auth hiba".
   - **Quote keywords with double quotes** when naming them: `"as" cast`, not `as cast`.
   - **Cite real codebase examples** when recommending a pattern. Prefer an in-repo site; when the positive example is in the current repo, label it with the parenthetical `(példa: <path:line>)` or `(példa a helyes verzióra: <path:line>)`. If none exists yet, point at a sibling repo with `(példa még itt nincs, egy másik repóban itt van: <path:line-line>)`, don't imply a missing reference is local. Cite the smallest meaningful range, stop at the last line of the pattern itself.
   - Reference related sites inline when it strengthens the point. Default: `lásd other-file.ts:269-272`. `en` mode: `see other-file.ts:269-272`.

   **Hard nos**: no em-dashes (`—`) anywhere in the output (use period, comma, parens, or "lásd"); no code blocks or "Suggested change" snippets unless asked; no section headers beyond the single comment-bucket header above; no bullet lists inside a comment; do not repeat the file path in the body; no padding words like "Concerns:", "Note:", "Consider:"; just say it. **No AI/reviewer flourishes**: no "sziget"/island metaphor for interactive components, no "shape cast" (say "as cast"), no "határon"/"a határponton" for fetch/API boundaries, no "némán"/"nyom nélkül", no "ág" for code branches (say "domainbe kerüljön", not "domain ágba"). Skip nit-tier findings unless nothing higher survives.

   After writing the file, end with a one-line summary in chat (always English, since it's for you, not the MR): `Wrote <path>. <n> findings, <c> comment notes. Static gates: <pass/fail per tool>.` If nothing survived the filter, still write the file containing `Nincs jelzés.` (or `No findings.` in `en` mode) and report the path the same way.
