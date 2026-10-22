---
name: feedback_ashen_palette
description: The user's ashen palette (warm near-black + ember red) with contrast ratios; dark by default for screens, light only for print
metadata:
  type: feedback
---

**Scope.** Use this palette for every visual deliverable unless the user names another scheme: PDFs, HTML pages, charts, plots, diagrams, slides, dashboards, mock-ups. Apply it with no questions asked.

**Where it comes from.** The user's desktop runs NixOS themed "ashen": warm near-black greys with ember / glowing-red accents. The source of truth is the `[palette]` table in `~/nix-config/theme/themes/ashen/theme.toml` (the theme switcher reads it), and every hex below is one of its tokens. The GTK theme is `Ashen-Orange-Dark`. The house gradient is the hyprland active-border blend, `#B14242` (ember) to `#DF6464` (glow) at 45 degrees.

**Dark by default.** Every screen deliverable is dark. Go light only for something a printer may see (a PDF or printable page). Pick from that test, never ask.

**Dark set (screens), on surface `#121212`:**
- surfaces: `#121212` base, `#191919` raised cards, `#212121` higher panels, `#2a2a2a` inputs and hover
- body text: `#d5d5d5` (12.76)
- muted text: `#a7a7a7` (7.79), dimmer `#949494` (6.18)
- hairlines and borders: `#535353` (2.44, decoration only, never text)
- brand ember: `#DF6464` (5.48) for text, marks and small accents. `#B14242` (3.33) is display-only, for large headings and the window border. The two pair as the house gradient.
- warm secondaries: `#E49A44` (8.03), `#D87C4A` (6.16), `#C4693D` (4.85)
- cool accent: `#4A8B8B` teal (4.78)
- alerts: warning `#E49A44`, error `#DF6464`. Red is the brand, so lean on orange when an alert must read as distinct from the accent.
- Never small text in `#B14242`, `#535353` or `#89492a` on `#121212`; all fail 4.5.

**Light set (print only), on page `#faf7f4`:**
- page: `#faf7f4`, a warm off-white. Never pure white.
- ink / body: `#191919` (16.47)
- headings and emphasis: `#B14242` ember (5.28)
- secondary text and rules: `#89492a` brown (6.45), `#535353` grey (7.21)
- list markers, underlines, large display: `#C4693D` (3.62)
- teal accent and run-in labels: `#1F7A7A` (4.77), a deepened print-only teal. Use this punchier teal ONLY on the white / print page next to black ink, where it stays crisp for small bold labels; keep the standard ashen teal `#4A8B8B` for screen and dark deliverables (there `#1F7A7A` would look muddy, and `#4A8B8B` on the print page reads washed at 3.67).
- tint fill for table headers and callouts: `#f0e2de`, a pale ember (about 1.1 on the page)
- On the page, `#191919`, `#B14242`, `#1F7A7A`, `#89492a` and `#535353` all clear 4.5. The oranges and `#4A8B8B` do not, so keep those to large or display use.

**Measured contrast ratios (WCAG).** Use these to pick a colour, do not guess.

On `#121212`: `#f5f5f5` 17.18, `#d5d5d5` 12.76, `#b4b4b4` 9.04, `#E49A44` 8.03, `#a7a7a7` 7.79, `#949494` 6.18, `#D87C4A` 6.16, `#DF6464` 5.48, `#C4693D` 4.85, `#4A8B8B` 4.78, `#B14242` 3.33, `#89492a` 2.72, `#535353` 2.44.

On page `#faf7f4`: `#121212` 17.55, `#191919` 16.47, `#212121` 15.09, `#535353` 7.21, `#89492a` 6.45, `#B14242` 5.28, `#1F7A7A` 4.77 (print-only teal), `#4A8B8B` 3.67, `#C4693D` 3.62, `#D87C4A` 2.85, `#E49A44` 2.19.

**Rules that follow from the numbers:**
- Small and small-bold text need 4.5 or more. Large or heavy display type may drop to 3.
- On `#121212`: body text `#d5d5d5`, accent `#DF6464` (or an orange for more punch), `#535353` for hairlines only. `#B14242` is for large display and borders, not body text.
- On `#faf7f4`: headings `#B14242`, body `#191919`, rules and markers `#C4693D` or `#89492a`. Never put small orange text on it.
- Do not flood a whole printable page with `#121212`.

**Chart and diagram series order** (so neighbouring series stay distinguishable):
- dark: `#DF6464`, `#4A8B8B`, `#E49A44`, `#949494`, `#D87C4A`.
- light page: `#89492a`, `#4A8B8B`, `#B14242`, `#535353`, `#C4693D`.

Related: [[feedback_pdf_typography]], which carries the font and build rules for PDF output.
