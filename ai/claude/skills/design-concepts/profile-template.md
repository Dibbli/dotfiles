# Design profile: <project>

Project facts for the design-concepts and design-finalize skills (their Gate 2 says what a profile may set).
Keep each section to the facts an agent cannot find on its own.

## Owner and voice
- Who picks (the owner, the user), how they want questions asked, words to use or avoid.

## Agent caps
- Max concurrent Opus agents; Sonnet and Haiku limits, if any.

## Read first
- Where design rules live and which doc owns what (a doc map, a router hook).
- Style and theme sources the mockups must draw from (file paths, helper names).
- Where earlier concept sets live, to avoid re-proposing a rejected one.

## Harness
- Folder whose files each set copies into its `src/` (scene, style CSS, data dumps), and what each
  file gives a page (classes, functions, query params, body classes).
- How to regenerate any data file the harness needs (a command).

## Views and render
- Each view: name, size, scale, what it stands for (`1920x1080`, `844x390@2:mobile?view=phone`).
- The exact render command, run from the repo root, and whether it needs network or no sandbox.
- The px unit: what 1 CSS px means in the product.

## Real data and art
- Where real names, numbers and text come from; icon and art folders; what to do when art is
  missing.

## Research
- Libraries to check with context7 (each concept must be buildable on them).
- Reference topics for web research (genres, games, apps, moods).

## Output and hand-off
- Set folder pattern, e.g. `docs/design/concepts/<YYYY-MM-DD>-<topic>/`; file naming.
- Only if not the default `~/Documents/concepts/<topic>/`: where the owner looks at a set, and when it is cleared.
- Ballot kit for animated takes, if the project has one.

## Rules
- Project rules for mockups (no em-dashes, keep-outs, minimum touch size, decisions to flag).

## Finalize
- How to get a render of the BUILT thing in the reference's framing: a command, an MCP tool, or a
  human step (who takes the screenshot, at which view).
- Checks that must pass after each build round (a test or lint command), and the round cap.
