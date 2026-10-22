# MR comment style

The owner pastes these comments into GitLab MR threads under their own name. Write them so they need no edits.

## Block format
- First line: `file.ext:line`, trimmed to the meaningful path tail (`auth-shell.tsx:57`, not `apps/developer-portal/src/.../auth-shell.tsx:57`). Anchor on the single offending line. Use a range (`file.ext:line-line`) only for a pattern that spans lines (a dead branch plus the check above it).
- Blank line.
- One short comment, usually one sentence, at most two.
- `---` on its own line between blocks.
- No section headers ("Issues", "Summary", "Komment-észrevételek:"). Each block stands alone.

## Voice
- Default Hungarian with proper accents (`működne`, `lásd`, `kéne`), even when the chat is English. In en mode, English in the same register.
- All lowercase, sentence starts too: "rakjuk át elé, vagy töröljük." Identifiers and proper nouns keep their case (`BadRequestError`, `useEffect`, `NextResponse`).
- Casual developer register: rhetorical questions ("itt működne X?", "inkább Y?") and short imperatives ("ezt page object-be kéne rakni", "trim előbb").
- Lead with the fix. The most common shape is the corrective action alone: `"as" helyett isSuccessApiResponse` is a complete comment. Other shapes: `X helyett Y`, `inkább X-ként, akkor a compiler elkapja`, `rakd külön type-ba (FooProps), ne inline.`, `töröld, vagy kösd be a ...-be`, `ez ránézésre unused`.
- Add the consequence only when the reader would not infer it: `anélkül mindig 200, és utólag jön az error`, `különben az auth error sima form errorba megy.` No `kell`/`kellene` filler unless the sentence needs it.
- State the observation, not the full reasoning. The owner knows the codebase.
- English loanwords stay English: "auth error", "form error", not "auth hiba". Say "try", not "try/catch".
- Quote keywords with double quotes: `"as" cast`, not `as cast` ("as" is also a Hungarian word).
- Keep the owner's own spelling when you echo their phrasing ("schemet" stays "schemet").
- Apply any word swap the owner asks for in the session from then on.

## References
- Never cite `.claude/rules/*`, `AGENTS.md`, `CLAUDE.md` or rule names in a comment. Say "konvenció szerint", "máshol is így van", or just give the fix.
- When you recommend a pattern, cite a real example with the smallest meaningful range (stop at the last line of the pattern): `(példa: <path:line>)`. If the repo has none yet, point at a sibling repo in the workspace: `(példa még itt nincs, <repo>-ban itt van: <path:line-line>)`. Never imply a missing example is local.
- A related site inline is fine: `lásd other-file.ts:269-272` (en: `see other-file.ts:269-272`). No "see also" sections.
- Do not repeat the file path in the body.

## Hard nos
- No em-dashes or en-dashes. Use a period, comma, parentheses, or "lásd".
- No code blocks, suggested-change snippets or GitLab `suggestion` blocks unless the owner asks. When asked, match the target line's exact indentation so a suggestion applies, and do not explain around the snippet.
- No bullet lists inside a comment. No padding words ("Concerns:", "Note:", "Consider:").
- No AI flourishes: no "shape cast" (say "as cast"), no "határon"/"a határponton" for fetch or API boundaries, no "némán"/"nyom nélkül" (say "szótlanul" or drop it), no "sziget" for interactive components, no "ág" for code branches ("domainbe kerüljön", not "domain ágba kerüljön"), no "kontextus-mergezés".

## When to use it
Use this style for MR output (cues: "for MR", "so I can send it", pasted GitLab threads). For a review the owner wants for their own thinking ("review this for me", "what do you think"), use a longer free format. If unsure, ask once. If the owner already showed example threads, match them and do not ask.
