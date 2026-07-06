export const meta = {
  name: 'review-diff',
  description: 'Multi-agent diff review: specialist fan-out, two-pass confidence scoring, mechanical keep filter. Returns structured findings; the caller formats.',
  whenToUse: 'Invoked by the /fix and /mr skills. args: {repoPath, diffRange, baseRef, changedPaths, rulePaths, mode:"fix"|"mr", deep, hasTestFramework, touchesTypes}. Every finding passes a blame gate (introduced-by-this-branch vs pre-existing on baseRef) before scoring. Returns {findings, commentFindings}.',
  phases: [
    { title: 'Review', detail: 'parallel specialist reviewers over the diff' },
    { title: 'Blame', detail: 'drop findings not introduced by this branch' },
    { title: 'Score', detail: 'per-finding reality + ease scoring (haiku)' },
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
const SCORE_SCHEMA = { type: 'object', properties: { score: { type: 'integer' } }, required: ['score'] }
const EASE_SCHEMA = { type: 'object', properties: { ease: { type: 'integer' } }, required: ['ease'] }
const BLAME_SCHEMA = {
  type: 'object',
  properties: { introducedByBranch: { type: 'boolean' }, reason: { type: 'string' } },
  required: ['introducedByBranch'],
}

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
  'Return {introducedByBranch: boolean, reason: <one short sentence>}.',
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
log(`${allFindings.length - nComment} specialist findings + ${nComment} comment notes; blame-gating all`)

const PASS_A = [
  'Return an integer 0-100. Bands:',
  '  0-20   false positive: misreads the code, or a linter/typechecker/compiler already catches it.',
  '  21-40  speculative: cannot verify from the diff alone.',
  '  41-60  real but small: verified, narrow blast radius or edge case.',
  '  61-80  real and routine: hits in normal use, or backed by CLAUDE.md.',
  '  81-100 real and load-bearing: correctness bug, security, swallowed error,',
  '         or explicit convention violation.',
  '',
  'Scope is already filtered upstream; do not down-score for "pre-existing".',
  'Pick a specific number inside the band. No prose.',
].join('\n')

const PASS_B = [
  'How invasive is the proposed fix? Return a single integer 1-4.',
  '  1  trivial, 1-2 line change, no ripple.',
  '  2  easy, under ~10 lines in one file, no API change.',
  '  3  medium, multiple files or a small API/shape change.',
  '  4  hard, broad refactor, public API change, or migration needed.',
  '',
  'No prose.',
].join('\n')

const fjson = f => JSON.stringify({ path: f.path, line: f.line, issue: f.issue, fix: f.fix })

const processed = await pipeline(
  allFindings,
  // Blame gate: drop anything this branch did not introduce. Throwing drops the item.
  async (f) => {
    const v = await agent(
      [BLAME, '', '## Finding', fjson(f), '', READONLY].join('\n'),
      { label: `blame:${f.path}:${f.line}`, phase: 'Blame', agentType: 'Explore', model: 'sonnet', schema: BLAME_SCHEMA }
    )
    if (!v || !v.introducedByBranch) throw new Error('pre-existing')
    return f
  },
  // Score survivors. Comment findings carry through unscored (the caller judges/limits them).
  async (f) => {
    if (f.isComment) return { ...f, score: null, ease: f.ease || 1 }
    const fctx = [READONLY, '', context, '', '## Finding', fjson(f)].join('\n')
    const [sa, sb] = await parallel([
      () => agent([PASS_A, '', fctx].join('\n'), { label: `scoreA:${f.path}:${f.line}`, phase: 'Score', agentType: 'Explore', model: 'haiku', schema: SCORE_SCHEMA }),
      () => agent([PASS_B, '', READONLY, '', '## Proposed fix', f.fix].join('\n'), { label: `scoreB:${f.path}:${f.line}`, phase: 'Score', agentType: 'Explore', model: 'haiku', schema: EASE_SCHEMA }),
    ])
    return { ...f, score: sa ? sa.score : 0, ease: sb ? sb.ease : (f.ease || 3) }
  }
)

const survivors = processed.filter(Boolean)
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
