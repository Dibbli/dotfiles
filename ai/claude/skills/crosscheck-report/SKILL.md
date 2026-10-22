---
name: crosscheck-report
description: Use when the user wants to visually cross-check a batch of fixes or screenshots against a list of reported issues, review a fix package, or build a "did this actually get fixed" checklist page. Generates a self-contained dark-themed HTML checklist, one card per screenshot with OK/NOT CORRECT toggles per issue, persistent notes, and an Export-to-markdown feedback button.
argument-hint: [report-name]
---

# Crosscheck report

Builds a portable folder under `~/Downloads/<name>-crosscheck/` containing an
HTML checklist page plus the screenshots it references, from a list of
screenshots and the issues reported against each one.

## Gather inputs

Ask only for what is missing from the conversation, do not ask for
everything by rote:

- `name`: short slug for the report (ticket id, feature name). Used for
  the folder, page title, and `<name>-feedback.md` export filename.
  Default to `$1` if given.
- The screenshot list: file paths (existing PNGs) or pages/URLs to
  screenshot first with whatever screenshot capability the session has.
  Each screenshot maps to one card.
- Per-screenshot issues: the reported issue text, in the reviewer's
  original wording (Hungarian stays Hungarian, do not translate). When the
  source review splits issues into ones specific to a screenshot and ones
  that apply everywhere, mirror that split: a shared legend section plus
  one generic item per card, not a duplicated full line per card.
- Optional: "live check" items that cannot be proven from a screenshot
  (interaction-only checks). Render them in the separate live section with
  the same OK/NOT toggles; delete that section if there are none. Every
  location a live check names must be a clickable `<a target="_blank">`
  link to the actual running page (resolve app/page ids up front), never
  a bare page label. Each live check also carries a collapsible
  `<details>` block with numbered step-by-step instructions (what to
  open, click, type, using real on-screen labels) ending in one PASS and
  one FAIL line, and the data behind each linked page must be verified
  present (row counts) before handing the report over.

## Build the output folder

1. Create `~/Downloads/<name>-crosscheck/`.
2. Copy (not move, unless the source is already scratch/temp) every
   screenshot into that folder, flat, with short filenames (existing name
   or `<app>-<page>.png` style). Card `src`/`href` must be the bare
   filename so the folder stays portable when zipped or moved.
3. Copy `template.html` from this skill directory to
   `<name>-crosscheck/<name>-crosscheck.html` and fill the placeholders
   (below). Do not hand-roll the CSS/JS from scratch; the template is the
   source of truth for the UI contract.
4. Report the folder path back to the user when done.

## Fill the template

Replace every `{{PLACEHOLDER}}` in the copied template:

- `{{TITLE}}`: short report title, e.g. `S6 FIX CROSS-CHECK - NOA-99`.
- `{{SUBTITLE}}`: one line: what was fixed, review source, date, and keep
  "each item names the REPORTED ISSUE: mark OK when it is gone, NOT when
  it is still broken; click a screenshot for full size".
- `{{STORAGE_PREFIX}}`: short unique localStorage prefix ending in `:`
  (e.g. `s6cc:`), so two crosscheck pages in one browser don't share state.
- `{{LEGEND_TITLE}}` + `{{LEGEND_ITEMS}}`: heading and `<li>` entries for
  issues reported on (nearly) every screenshot; delete the whole legend
  `<section>` if there is no such split.
- `{{CARDS_TITLE}}` + `{{CARDS}}`: heading and one `.card` block per
  screenshot, targeted issues first, the shared generic item last. Use the
  exact markup in the comment above the placeholder.
- `{{LIVE_TITLE}}` + `{{LIVE_CHECKS}}`: the live-checks heading and `<li>`
  entries (markup in the comment above the placeholder), or delete that
  `<section>` entirely.
- `{{FOOTER_SOURCES}}`: what the issue list was sourced from.
- `{{EXPORT_FILENAME}}`: `<name>-feedback.md` (two occurrences).
- `{{REPORT_HEADING}}`: heading inside the exported markdown, e.g.
  `S6 Feedback`.

Do not change the CSS variables, the OK/NOT/note/localStorage/export
JavaScript, or the ashen dark palette. That is the fixed UI contract; only
content is templated.

## Notes

- No em-dashes in generated title/subtitle/item text.
- Item wording is the reviewer's original phrasing where available, not a
  rewritten summary, so cross-checking against the review doc stays literal.
- Every `.item` needs a unique `id` (`c-<app>p<page>-<tag>` pattern); the
  export function and localStorage keying depend on it.
- After filling, grep the output for `{{` to prove no placeholder survived,
  and open-check that every referenced PNG exists in the folder.
