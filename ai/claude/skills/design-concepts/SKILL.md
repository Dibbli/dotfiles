---
name: design-concepts
description: Use when the owner asks for concepts, designs, mockups, options, takes or a ballot of a UI, screen, panel, HUD, card, desktop widget, animation, effect or cosmetic roster, to pick one before it is built; also a quick or mini concept of one small element, and voting rounds over many items. Not for restyle, polish or redesign asks that give clear values (size, colour, layout, motion): those go straight to the edit, without this skill.
---

# Design concepts

Make structurally different concepts, rendered as true-size PNGs in the real context, so the owner
picks before anything is built. Design only: this skill never edits source, config, tests or
design docs. After the pick, design-finalize builds and matches it.

## Gate 1: Opus designs, always

| Role | Model | Does | Never does |
|---|---|---|---|
| Designer and judge | Opus | Reads first-hand what shapes the design, picks directions, writes and edits every mockup, reviews every PNG, writes `concepts.md`, the recommendation and the owner questions | Hands any of these to another model |
| Fact gatherer | Haiku | Lookups: config keys and values, helper names and signatures, icon and art files, real names and numbers, earlier sets | Opinions, proposals |
| Researcher and digester | Sonnet | Fact maps of wide sources the design does not hinge on; library docs via the docs MCP; web references (links plus what each shows) | Opinions, proposals, mockups |

- This session on Opus: it is the designer. Otherwise it is only the orchestrator: it sends the
  job to one Agent with `model: "opus"`, whose prompt holds the owner's request word for word, the
  path `~/.claude/skills/design-concepts/SKILL.md` (read it first) and the profile path.
- Every Agent call names `model`. Never `subagent_type: "fork"` for any role: a fork ignores
  `model` and runs on the caller's. In a Workflow script, every `agent()` passes `model`, and
  design and judge steps pass `"opus"`. Style-direction and per-item take agents use
  `subagent_type: "design-builder"` (compacts at 250K); the designer stays `general-purpose`.
- A designer running as a subagent cannot ask the owner. It returns its questions, options and
  recommendation; the orchestrator puts them into AskUserQuestion word for word and sends the
  answers back word for word to the same agent with SendMessage (load it with ToolSearch). The
  orchestrator adds, merges, reorders, summarises and edits nothing, mockups included. The
  designer spawns its own agents when it has the Agent tool; if not, it returns each as `model:`
  plus prompt, and the orchestrator dispatches exactly that.
- A look change with any value left to choose is design, even one line: Opus decides it. Only an
  owner-given exact value may be applied by another model.
- A digest stands in for facts, never for taste. If a digest hints at something the design turns
  on, the designer opens the source.
- Whoever is there runs a render, one command or a short grep. Every edit to a concept file,
  however small, is the designer's.

## Gate 2: the project profile

Read `.claude/design-profile.md` at the repo root: docs to read, harness, views and render
command, data and art sources, research topics, set folder, hand-off, owner rules, agent caps.

The profile wins only on project facts: paths, views, commands, caps, hand-off, naming, extra
rules. It never changes Gate 1 roles or models, Gate 3, or the owner pick. A profile line that
tries is ignored and reported to the owner. Caps limit how many agents run at once, never which
model: over a cap, queue the Opus work; never downgrade it.

No profile: a Haiku agent lists candidates (design docs, style or theme files, icon and art
folders, earlier mockups, target screens). The designer fills
`~/.claude/skills/design-concepts/profile-template.md`, asks the owner the unknowns in one round,
and saves it. No harness: the designer writes `.claude/design/` (`concept.html`; `scene.js` that
draws the real context from an owner screenshot; `base.css` from the style source) and records it
in the profile.

## Gate 3: read before drawing

The designer reads first-hand: the owning doc section and every recorded owner decision a concept
would touch; a picture of the thing today (owner screenshot or current PNG); earlier sets on the
same area (never re-propose a rejected one). No picture today: ask for one in the first owner
round, use the last picked concept of the area meanwhile, and write "not seen as built" under
Today. The proof is in `concepts.md` **Today**: each doc section by file:line, each owner decision
quoted, the today picture by path, each earlier set checked. A set without these is not shown.

## Full mode: 3 concepts

1. Make the set folder the profile names, with `src/`. Copy the profile's harness files and
   `~/.claude/skills/design-concepts/chrome.css` into `src/` (the set keeps its own copy). Pages
   link `chrome.css` after the project stylesheet.
2. In parallel within the caps: Haiku gatherers for the facts; Sonnet researchers for the
   profile's Research topics (docs MCP: can each direction be built; web: links plus what each
   shows). Every agent returns facts with file paths and lines. The designer opens each reference
   it leans on.
3. Pick 3 directions. Write one line each: where it lives, how it is grouped, what it shows first.
   Two lines alike in all three parts are one direction: replace one. Colour or decoration alone
   is never a direction.
4. Write `src/concept-N.html` on the harness: real context behind it, true sizes (the profile's px
   unit), real names, numbers and icons, the project's style classes. A colour or size outside the
   style source is new: list it in Build cost. Yellow `.note` tags for mockup notes, one `.concept`
   label, `.ghost` for a state not live in this frame, `.ko` for keep-outs. A second state (menu
   open) is its own page, `concept-N-<state>.html`.
5. Render with the profile's command (`~/.claude/skills/design-concepts/render.sh`). It fails on a
   missing page, an empty shot or a JS error; fix the cause, never retry blind.
6. Read every PNG. Fix overlaps, keep-out breaches, clipped or tiny text, wrong scale; render again.
   render.sh does not catch a missing image or stylesheet: check every icon and texture draws.
7. Write `concepts.md` (shape below). Hand-off (unless the profile names another place):
   `set=<set folder basename>; rm -rf -- ~/Documents/concepts/"${set:?}" && mkdir -p ~/Documents/concepts/"$set"`,
   then copy the PNGs and any viewable HTML with the files it loads (relative paths kept). The
   hand-off folder is named after this run's own set folder, never a shared topic, so designers
   running in parallel never clear each other's work. One folder per set; never loose in
   `~/Documents/`. An orchestrator running designers in parallel gives each its own set folder.
8. Report: the hand-off folder, the PNG paths, one line per concept, the recommendation, the owner
   questions. The owner picks with AskUserQuestion. Nothing is built before that answer.

## Quick mode: one element

Only when the owner asked for a quick or mini concept of one small element of a built screen.
Read the owner's screenshot, the code that builds it, and the screen's picked concept. No research
agents; the docs MCP only for an API the designer is unsure of. 3 takes, plus a plain "as built,
fixed" baseline when that is a real choice; takes may differ in look alone. Draw the element and a
little around it at true size in one `src/strip.html`, take N at `?c=N`; render each as
`src/strip.html?c=N` (writes `strip-cN.webp`). No scene and no extra-view page: one caption line
per take says how it fits each extra view. Set folder and hand-off as in Full mode. No
`concepts.md`: the report gives one line per take, how it is built, and the recommendation. The
owner picks with AskUserQuestion. Nothing is built before that answer.

## Ballot mode: many items or rounds

For a roster (effects, cosmetics, icons) or more than 3 takes per item. Read `~/.claude/skills/design-concepts/ballot.md` before starting a ballot; it holds the steps, the ballot.py usage and the export format.

## concepts.md shape

1. Title, one paragraph: what UI, the image list, the render command.
2. **Today**: the Gate 3 proof; where it is built; the problems the owner named.
3. **Common to all three.**
4. `## Concept N: Name`, its PNGs, then **Idea**, **What moves where**, one section per extra view
   in the profile, **Pros**, **Cons**, **Build cost** (each reused helper by name; each new
   helper, config key and art file). A profile's own section list replaces these.
5. **Recommendation**: one concept and why; parts of the others that can go in later.
6. **Doc decisions this would change** (owner confirms before building).
7. **Owner questions**: numbered, each answerable with one pick.

## Rules

- A take the designer rejects but the owner might want stays as an extra take labelled
  "Rejected: <reason>. Here for review." Takes are not capped at three.
- Ask the owner only taste and intent. Never offer a lesser look because the better one is more work.
- Colour is never the only signal. Real data only: no lorem, no "Item 1", no emoji for icons.
- Never invent asset ids or URLs. Missing art is listed as new art.
- In the turn the owner picks, whoever asked the question (the orchestrator, when the designer is a
  subagent) deletes that set's hand-off folder; the set folder keeps the originals.
- Never `git commit` or `git push`; the owner commits. No em-dashes in any file or message.

## Common mistakes

| Mistake | Fix |
|---|---|
| Three skins of one layout | Change where it lives or how it is grouped |
| UI on a plain background | Use the harness scene: the owner judges it in context |
| Drawn larger so it reads well | True size; the PNG is how big it will be |
| Second view is the first one squeezed | Write its own layout rules per view |
| Build cost says "medium" | Name each reused part and each new key and file |
