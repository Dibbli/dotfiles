---
name: feedback_context7_for_libs
description: Query context7 MCP for authoritative library/framework docs before guessing or asking the user
metadata:
  type: feedback
---

When stuck on library/framework API behavior (e.g. Mantine, Next.js, Prisma, React Query, Tailwind), reach for the context7 MCP tools (`mcp__context7__resolve-library-id` then `mcp__context7__query-docs`) before guessing or before asking the user. It returns authoritative current docs and saves iteration loops.

**Why:** One context7 query surfaced an official answer immediately where two failed workarounds had already been tried. Earlier guesses were wrong; the documented pattern was right on the first lookup.

**How to apply:** When a library's component or hook isn't behaving as expected after one straightforward attempt, query context7 instead of attempting another workaround. Especially worthwhile for libraries that evolve fast (component APIs, router patterns, query-cache behavior).
