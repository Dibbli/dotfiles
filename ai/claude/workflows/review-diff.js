export const meta = {
  name: 'review-diff',
  description: 'Multi-agent diff review: specialist fan-out, two-pass confidence scoring, mechanical keep filter. Returns structured findings; the caller formats.',
  whenToUse: 'Invoked by the /fix and /mr skills. args: {repoPath, diffRange, baseRef, changedPaths, rulePaths, mode:"fix"|"mr", deep, hasTestFramework, touchesTypes}. Every finding passes a blame gate (introduced-by-this-branch vs pre-existing on baseRef) before scoring. Returns {findings, commentFindings}.',
  phases: [
    { title: 'Review', detail: 'parallel specialist reviewers over the diff' },
    { title: 'Blame', detail: 'drop findings not introduced by this branch (haiku, 5 per agent)' },
    { title: 'Score', detail: 'reality + ease scoring (haiku, 5 per agent)' },
  ],
}

const READONLY = [
  'READ-ONLY MODE. Do NOT call Edit, Write, or NotebookEdit. Do NOT use Bash for any',
  'state-changing operation: no `>` / `>>` redirects, no `tee`, no `sed -i`, no',
  '`mv`/`cp`/`rm`, no `git add`/`git commit`/`git checkout --`/`git reset`/`git push`/`git stash`.',
  'Read, Grep, Glob, and read-only Bash (`git diff`, `git log`, `cat`, `ls`, `grep`, `find`, `rg`) only.',
  'If you find yourself wanting to apply a fix, return it as a finding instead.',
].join(' ')

const RETURN_SPEC = [
  'Return findings as `{findings: [...]}` where each item is',
  '`{path, line, severity, issue, fix, ease}` and `ease` is an integer 1-4:',
  '1 = trivial (1-2 line change), 2 = easy (<10 lines), 3 = medium, 4 = hard/invasive.',
  'The `fix` field must be a concrete change description, not vague advice. No prose.',
].join(' ')

// The Workflow runtime delivers `args` as a JSON string, not a parsed object.
let a = {}
try { a = (typeof args === 'string' ? JSON.parse(args || '{}') : (args || {})) || {} } catch { a = {} }
const repoPath = a.repoPath || '.'
const diffRange = a.diffRange || '' // e.g. "main...HEAD"; empty = uncommitted working tree
const baseRef = a.baseRef || (diffRange ? diffRange.split(/\.\.\.?/)[0] : 'HEAD')
const changed = (a.changedPaths || []).join('\n')
const rules = (a.rulePaths || []).join('\n')
const mode = a.mode === 'fix' ? 'fix' : 'mr'
const blameEnabled = a.blame !== false
const specialistModel = a.deep ? 'opus' : 'sonnet'
const diffCmd = `git -C ${repoPath} diff ${diffRange}`.trim()
// Frozen snapshot beats a live `git diff`: a working tree edited mid-run is a moving target.
const frozenDiff = a.diff || ''
const diffSource = frozenDiff
  ? ['## Diff under review (authoritative snapshot; this defines scope, not a live `git diff`)', '```diff', frozenDiff, '```',
     `Read full files under ${repoPath} for surrounding context, but the snapshot above is the change set.`].join('\n')
  : [`## How to get the diff`, `Run \`${diffCmd}\` for the diff under review. Read full files under ${repoPath} for surrounding context when a finding needs it.`].join('\n')
log(`mode=${mode} diff=${frozenDiff ? 'frozen snapshot' : 'live ' + diffCmd} base=${baseRef}`)

const SCOPE = [
  '## Scope rule (strict)',
  'This is a review of ONE ticket branch, not a codebase audit. Report ONLY issues this branch',
  'is responsible for: bugs on the lines it added or changed, AND consequences its change causes',
  'elsewhere even in code it did not directly edit (a new enum member an existing Record/switch/',
  'exhaustive map no longer covers, a caller that must change because a signature or contract',
  'changed). Do NOT report pre-existing issues that already exist on the base branch, general',
  'smells in files this branch did not touch, or missing tests for behavior this branch did not',
  `alter. The base (pre-branch) state of any file: \`git -C ${repoPath} show ${baseRef}:<path>\`.`,
].join('\n')

const context = [
  diffSource,
  '', SCOPE,
  '', '## Changed file paths (relative to repo root)', changed,
  '', '## Authoritative repo convention files (paths relative to repo root; read on demand if a finding hinges on a convention; do not assume contents)', rules,
].join('\n')

const FINDINGS_SCHEMA = {
  type: 'object',
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          path: { type: 'string' },
          line: { type: 'integer' },
          severity: { type: 'string' },
          issue: { type: 'string' },
          fix: { type: 'string' },
          ease: { type: 'integer' },
        },
        required: ['path', 'line', 'severity', 'issue', 'fix'],
      },
    },
  },
  required: ['findings'],
}
const batchSchema = (name, props) => ({
  type: 'object',
  properties: {
    [name]: {
      type: 'array',
      items: {
        type: 'object',
        properties: { index: { type: 'integer' }, ...props },
        required: ['index', ...Object.keys(props)],
      },
    },
  },
  required: [name],
})
const SCORE_SCHEMA = batchSchema('scores', { score: { type: 'integer' } })
const EASE_SCHEMA = batchSchema('eases', { ease: { type: 'integer' } })
const BLAME_SCHEMA = batchSchema('verdicts', { introducedByBranch: { type: 'boolean' }, reason: { type: 'string' } })

const BLAME = [
  'Decide whether a code-review finding is in scope for a single-ticket branch review.',
  `The branch diff under review: run \`${diffCmd}\`.`,
  `The base (pre-branch) state of any file: run \`git -C ${repoPath} show ${baseRef}:<path>\`.`,
  '',
  'IN SCOPE (introducedByBranch=true): this branch is responsible for the issue. Either the bug',
  'is on lines the diff added/changed, OR the diff causes it elsewhere in code it did not edit -',
  'e.g. the branch adds an enum member and an existing Record<Enum,string> / switch / exhaustive',
  'map in an untouched file no longer covers it, or a caller now needs updating because a',
  'signature or contract changed.',
  '',
  'OUT OF SCOPE (introducedByBranch=false): the issue would already be present on the base branch',
  'without this change - a pre-existing bug, a pre-existing swallowed error, a general smell, or a',
  'missing test for behavior this branch did not alter. Compare the base file to the diff before',
  'deciding. When the base already had the problem, it is out of scope.',
  '',
  'You are judging a batch of findings, each with an `index`. Judge every one independently.',
  'Return {verdicts: [{index, introducedByBranch, reason: <one short sentence>}, ...]} with one',
  'entry per finding given, same indexes. No prose.',
].join('\n')

const SPECIALISTS = [
  {
    key: 'code-reviewer', agentType: 'code-reviewer', when: true,
    brief: 'Generalist review: type safety, error handling, DRY, security smells, dead code, naming, repo-convention compliance, and tests where a framework exists.',
  },
  {
    key: 'silent-failure-hunter', agentType: 'silent-failure-hunter', when: true,
    brief: 'Hunt swallowed errors, empty catches, fallback-on-error patterns, and missing logging at I/O boundaries.',
  },
  {
    key: 'pr-test-analyzer', agentType: 'pr-test-analyzer', when: !!a.hasTestFramework,
    brief: 'Test coverage gaps for new branches and edge cases. A test framework is present in this repo.',
  },
  {
    key: 'type-design-analyzer', agentType: 'type-design-analyzer', when: !!a.touchesTypes,
    brief: 'Type design of the types/interfaces/data models this diff introduces or modifies: encapsulation, invariant expression, enforcement.',
  },
  {
    key: 'comment-analyzer', agentType: 'comment-analyzer', when: true,
    brief: [
      'Check existing and added comments for:',
      '(a) context poisoning - obsolete framing, stale assumptions, misleading rationale;',
      '(b) over-specificity - comments naming exact call sites, ticket IDs, dates, or "added for X" provenance that rots;',
      '(c) historical narration - any "this used to/previously/we changed this from" wording; comments must describe current behavior only;',
      '(d) gaps - places in the changed code where a comment SHOULD exist (non-obvious WHY, hidden constraint, subtle invariant).',
      'For (d) use issue="missing comment" and fix=the suggested comment text.',
    ].join(' '),
  },
]

phase('Review')
const raw = await parallel(
  SPECIALISTS.filter(s => s.when).map(s => () =>
    agent(
      [s.brief, '', context, '', RETURN_SPEC, '', READONLY].join('\n'),
      { label: `review:${s.key}`, phase: 'Review', agentType: s.agentType, model: specialistModel, schema: FINDINGS_SCHEMA }
    ).then(r => ({ key: s.key, findings: (r && r.findings) || [] }))
  )
)

const allFindings = []
for (const r of raw.filter(Boolean)) {
  const isComment = r.key === 'comment-analyzer'
  for (const f of r.findings) allFindings.push({ ...f, source: r.key, isComment })
}
const nComment = allFindings.filter(f => f.isComment).length
log(`${allFindings.length - nComment} specialist findings + ${nComment} comment notes; ${blameEnabled ? 'blame-gating all' : 'blame gate OFF (noblame)'}`)

const PASS_A = [
  'Return an integer 0-100. Bands:',
  '  0-20   false positive: misreads the code, or a linter/typechecker/compiler already catches it.',
  '  21-40  speculative: cannot verify from the diff alone.',
  '  41-60  real but small: verified, narrow blast radius or edge case.',
  '  61-80  real and routine: hits in normal use, or backed by repo guidance.',
  '  81-100 real and load-bearing: correctness bug, security, swallowed error,',
  '         or explicit convention violation.',
  '',
  'Scope is already filtered upstream; do not down-score for "pre-existing".',
  'Pick a specific number inside the band. Score every finding in the batch independently.',
  'Return {scores: [{index, score}, ...]} with one entry per finding given, same indexes. No prose.',
].join('\n')

const PASS_B = [
  'How invasive is each proposed fix? Rate every one with an integer 1-4.',
  '  1  trivial, 1-2 line change, no ripple.',
  '  2  easy, under ~10 lines in one file, no API change.',
  '  3  medium, multiple files or a small API/shape change.',
  '  4  hard, broad refactor, public API change, or migration needed.',
  '',
  'Return {eases: [{index, ease}, ...]} with one entry per fix given, same indexes. No prose.',
].join('\n')

const fjson = f => JSON.stringify({ path: f.path, line: f.line, issue: f.issue, fix: f.fix })
const BATCH = 5
const chunks = arr => Array.from({ length: Math.ceil(arr.length / BATCH) }, (_, i) => arr.slice(i * BATCH, i * BATCH + BATCH))
const byIndex = (rows, key) => new Map((rows || []).map(r => [r.index, r[key]]))
const listOf = (items, render) => items.map((f, i) => `### index ${i}\n${render(f)}`).join('\n\n')

// Findings are batched BATCH-per-agent: one blame agent and two score agents per chunk, not per finding.
const processed = await pipeline(
  chunks(allFindings),
  // Blame gate: drop anything this branch did not introduce.
  async (batch) => {
    if (!blameEnabled) return batch
    const v = await agent(
      [BLAME, '', '## Findings', listOf(batch, fjson), '', READONLY].join('\n'),
      { label: `blame:${batch[0].path}+${batch.length}`, phase: 'Blame', agentType: 'Explore', model: 'haiku', schema: BLAME_SCHEMA }
    )
    // A dead agent means no verdicts: keep the batch rather than silently dropping real findings.
    if (!v) return batch
    const verdict = byIndex(v.verdicts, 'introducedByBranch')
    return batch.filter((_, i) => verdict.get(i) !== false)
  },
  // Score survivors. Comment findings carry through unscored (the caller judges/limits them).
  async (batch) => {
    const comments = batch.filter(f => f.isComment).map(f => ({ ...f, score: null, ease: f.ease || 1 }))
    const rest = batch.filter(f => !f.isComment)
    if (!rest.length) return comments
    const label = `${rest[0].path}+${rest.length}`
    const [sa, sb] = await parallel([
      () => agent([PASS_A, '', READONLY, '', context, '', '## Findings', listOf(rest, fjson)].join('\n'),
        { label: `scoreA:${label}`, phase: 'Score', agentType: 'Explore', model: 'haiku', schema: SCORE_SCHEMA }),
      () => agent([PASS_B, '', READONLY, '', '## Proposed fixes', listOf(rest, f => f.fix)].join('\n'),
        { label: `scoreB:${label}`, phase: 'Score', agentType: 'Explore', model: 'haiku', schema: EASE_SCHEMA }),
    ])
    const scores = byIndex(sa && sa.scores, 'score')
    const eases = byIndex(sb && sb.eases, 'ease')
    return comments.concat(rest.map((f, i) => ({
      ...f,
      score: scores.has(i) ? scores.get(i) : 0,
      ease: eases.has(i) ? eases.get(i) : (f.ease || 3),
    })))
  }
)

const survivors = processed.filter(Boolean).flat()
const commentFindings = survivors.filter(f => f.isComment)
const scored = survivors.filter(f => !f.isComment)

function keep(f) {
  if (mode === 'mr') return f.score >= 61
  // fix mode: ease-weighted bands
  if (f.score >= 61) return true
  if (f.score >= 41) return f.ease <= 3
  if (f.score >= 21) return f.ease <= 2
  return false
}

const kept = scored.filter(keep).sort((x, y) => y.score - x.score)
log(`blame-dropped ${allFindings.length - survivors.length}; kept ${kept.length}/${scored.length} scored + ${commentFindings.length} comment notes (mode=${mode})`)

return { mode, findings: kept, commentFindings }
