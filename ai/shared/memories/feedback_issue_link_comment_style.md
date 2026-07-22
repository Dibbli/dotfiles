---
name: feedback_issue_link_comment_style
description: When writing code comments that justify a workaround with external links, use terse prose + one trailing See: line per issue, no essays or bulleted manifestos.
metadata:
  type: feedback
---

When a code or schema comment needs to justify a workaround via external links (GitHub issues, vendor docs), use this style:
- 1-4 lines of prose stating the **cause / problem** that forced the workaround. Not a tour of the implementation, not "we use X to achieve Y", not a description of how clever the solution is.
- One trailing `// See: https://...` line per issue (TypeScript/JS) or `-- See: https://...` (SQL)
- One linked issue per `See:` line, never a sentence packed with multiple URLs
- No multi-paragraph essays, no bulleted manifestos quoting fragments of each issue

**Examples:**
```ts
// 'form' intentionally omitted from dependencies. Mantine's useForm creates new
// references each render, causing infinite loops.
// See: https://github.com/mantinedev/mantine/issues/5338
```
```ts
// Sort in memory: ACTIVE first, then DRAFT
// See: https://github.com/prisma/prisma/issues/16968
const sorted = items.sort(sortByStatus)[0];
```

**Why:** The purpose of such a comment is to state the external cause, not to narrate or praise the implementation. "This is just explaining what it does" is not a justification comment. The code itself is the solution; describing it in the comment is narrating.

**How to apply:**
- Write the comment as if you were filing a bug, not pitching a fix. State the library/tool limitation, not what your code does around it.
- Even when you have 5+ links justifying a single architectural choice, compress the cause to one sentence and list URLs on consecutive `See:` lines.
- Don't editorialise what's inside each issue; the link is the citation, the reader follows it if they need depth.
