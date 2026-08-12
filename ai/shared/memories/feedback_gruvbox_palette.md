---
name: feedback_gruvbox_palette
description: The user's gruvbox palette with measured contrast ratios, dark by default for anything on screen, light only for printable documents
metadata:
  type: feedback
---

**Scope.** Use this palette for every visual deliverable, unless the user names another scheme. This covers PDFs, HTML pages, charts, plots, diagrams, slides, dashboards, and mock-ups. Apply it with no questions asked.

**Where it comes from.** The user's desktop runs NixOS with the Gruvbox-Orange-Dark GTK theme (`~/nix-config/home/theming.nix`). The hex values below come from his own kitty and waybar configs. They are his real accents, not the upstream gruvbox defaults.

**Dark by default.** Every screen deliverable is dark: HTML pages, charts, diagrams, slides, dashboards, mock-ups. The reference is the user's waybar and his own website: `#282828` surface, `#ebdbb2` text, amber accent. Go light ONLY for a document that a printer may see, meaning a PDF or a printable page. Never ask which mode, pick it from that test.

**Dark set (use these first):**
- surface: `#282828`
- body text on it: `#ebdbb2` (10.75)
- muted text: `#a89984` (5.3)
- hairlines and borders: `#504945` (1.67, decoration only, never text)
- brand amber: `#d79921` (5.94). This is the hyprland active-window border and the accent on the user's own website, so it is the default accent for a screen deliverable.
- brighter accent: `#fabd2f` (8.69) or `#e49a44` (6.32). Hyprland pairs `#d79921` to `#fabd2f` as a 45 degree gradient, which is the house gradient.
- alert: `#fb4934` (4.29)
- Never `#3c3836`, `#665c54` or `#b14242` as text on `#282828`. All three fail.

**Light set (documents only):**
- ink / body text: `#3c3836`
- muted / secondary text, borders: `#665c54` (or `#7c6f64` where lighter is wanted)
- primary accent, orange: `#d87c4a`
- lighter orange: `#e49a44`
- red: `#b14242`
- bright red for dark backgrounds: `#fb4934`
- teal: `#4a8b8b`
- yellow: `#fabd2f`
- page: plain white. `#ebdbb2` serves as the warm tint fill for table headers and callouts.

**Measured contrast ratios (WCAG formula).** Use these to pick a colour. Do not guess.

On white: `#3c3836` 11.6, `#665c54` 6.51, `#af3a03` 6.12, `#b14242` 5.63, `#7c6f64` 4.87, `#4a8b8b` 3.92, `#d87c4a` 3.04, `#e49a44` 2.33, `#fabd2f` 1.7

On `#ebdbb2`: `#3c3836` 8.45, `#665c54` 4.75, `#b14242` 4.11, `#7c6f64` 3.55, `#4a8b8b` 2.86, `#d87c4a` 2.22, `#e49a44` 1.7, `#fabd2f` 1.24

On `#282828`: `#ebdbb2` 10.75, `#fabd2f` 8.69, `#e49a44` 6.32, `#d79921` 5.94, `#a89984` 5.3, `#d87c4a` 4.85, `#fb4934` 4.29, `#4a8b8b` 3.76, `#7c6f64` 3.03, `#b14242` 2.62, `#665c54` 2.26, `#504945` 1.67

`#d79921` is dark-only: it drops to 2.48 on white and 1.81 on `#ebdbb2`.

**Rules that follow from those numbers:**
- Small text and small bold text need a ratio of 4.5 or more. Large or heavy display type may go down to 3.
- On `#282828`, text is `#ebdbb2`, the accent is `#d79921` (or `#fabd2f` where more punch is wanted), and alerts are `#fb4934`. `#504945` is for hairlines only, at 1.67.
- On a white page, headings and emphasis use `#b14242`, and `#d87c4a` is for rules, list markers, underlines, tint fills and large display type. Never put small orange text on white.
- The `#ebdbb2` tint costs about a quarter of the ratio white gives, so `#b14242` lands at 4.11 on it. Keep red headings at 12pt or heavier there, or use `#3c3836` for small text.
- Do not fill a whole printable page with `#282828` or `#ebdbb2`.

**Chart and diagram series order.** Take colours in this order, so neighbouring series stay distinguishable. On dark: `#d79921`, `#4a8b8b`, `#fb4934`, `#fabd2f`, `#a89984`, `#e49a44`. On a white page: `#d87c4a`, `#4a8b8b`, `#b14242`, `#fabd2f`, `#665c54`, `#e49a44`.

**Worked example.** A Typst one-pager applied these rules: white page, ink body text, `#b14242` headings, `#d87c4a` rule and list markers, a tinted table header.

Related: [[feedback_pdf_typography]], which carries the font and build rules for PDF output.
