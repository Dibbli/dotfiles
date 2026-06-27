---
name: feedback_no_narrative_comments
description: When writing or editing code, do not add comments that narrate what the code does or describe how a fix works; only comment on non-obvious WHY.
metadata:
  type: feedback
---

Do not write comments that narrate the code or describe the workaround. The code is the description; well-named identifiers carry the "what". Adding prose around them is redundant noise.

**Why:** Narrative comments restate information already visible in the code. They add maintenance burden, go stale, and signal low trust in the reader. The only comment worth writing explains a WHY the code cannot convey on its own (a non-obvious constraint, a workaround for an external bug, a surprising invariant).

**Anti-patterns (banned):**
- "Bridge the X gap so Y doesn't happen before Z fires." -- describes the fix.
- "Map whitespace-delimited tokens to a prefix-matching query, AND-joined." -- describes the body.
- "Parse sentinel markers into segments." -- describes the function.
- "Thin client island wrapper. Mirrors ComponentFoo." -- filler plus how-it-relates editorializing.
- "Drives global search via rawQuery in queries/search.ts; admin list-page substring search still uses ..." -- tour of consumers.
- Short summary comments above derived values like `const showLoader = ...` or `const isStale = ...`. The expression names the thing; restating it is filler.

**How to apply:**
- Default to NO comment when adding or editing code.
- Before writing any comment, ask: would removing this leave a future reader confused about WHY this exists, or only about WHAT it does? If only WHAT, delete it.
- If a comment is justified, state the cause or problem, not the solution.
- Watch for the reflex of "explain what I just wrote" immediately after an edit. Suppress it.
