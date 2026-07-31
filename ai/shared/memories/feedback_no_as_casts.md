---
name: feedback_no_as_casts
description: When writing TypeScript, avoid `as` type assertions — use runtime narrowing guards or validated reconstruction instead.
metadata:
  type: feedback
---
Prefer runtime narrowing (`typeof x === 'object' && x !== null && 'key' in x`, `Array.isArray`, `typeof t === 'string'`) or explicit re-construction over `as SomeType`. Build a new object by validating fields rather than trusting a cast.
**Why:** Casts silence the compiler without proving the value matches the shape. After a JSON boundary they are a common source of runtime bugs that TypeScript was in a position to catch.
**How to apply:**
- Parsing `unknown` from JSON/import: narrow via `in` guards or filter/validate before use; do not `as` the whole object to a shape.
- Reading an optional field off an unknown: `typeof x === 'object' && x !== null && 'title' in x && typeof x.title === 'string'` instead of `(x as { title?: unknown }).title`.
- Collecting a typed subset: `arr.filter((v): v is string => typeof v === 'string')` — the type predicate on the filter callback is acceptable since it is a proven narrowing, not a widening cast.
- `as const` on literals (e.g. `kind: 'running' as const`) is a grey area; prefer explicit object types or `satisfies` if an alternative reads cleanly.
- `as unknown` alone is also not allowed. To handle an `any` boundary value (e.g. `await request.json()`), use a schema validator like Zod (`schema.safeParse(value)`) and consume `parsed.data`, or assign to a variable with a declared type and validate via a type-guard. Never cast.
