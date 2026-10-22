---
name: design-finalize
description: Use when a picked concept, mockup or reference image must be built or matched for real (UI, scene, 3D model, Blender asset, effect, page), or when a built thing does not look like its concept or reference and needs to be closed in on.
---

# Design finalize

Build to a reference, then loop: render the build, put it beside the reference, a separate critic
names the 3 biggest differences, the builder fixes those 3, render again. A builder that judges its
own work stops early; a critic that never built it does not.

## Gate 1: an owner reference

The reference is owner-picked (a pick recorded in `picks.md` or an AskUserQuestion answer) or
owner-supplied (an image or photo). A mockup the lead draws now is not a reference; words are not a
reference. None: stop and get one (ask, or run design-concepts first). A concept page becomes the
reference through a clean render: copy it to `concept-N-ref.html`, add `class="clean"` to its
`<body>` (hides `.note`, `.concept`, `.ko`), render it with the profile's command. If the set's
`src/` has no `chrome.css`, copy `~/.claude/skills/design-concepts/chrome.css` there and link it as
the last stylesheet of `concept-N-ref.html`. Read the PNG: no `.note`, `.concept` or `.ko` may show.
Note the reference framing: view, size, camera, scale, state.

## Gate 2: roles, Opus judges

| Role | Model | Does |
|---|---|---|
| Lead | Opus | Reads the reference, the concept notes and `.claude/design-profile.md`; writes `plan.md`; picks the builder model per round and logs it; runs the loop; stops only on step 8's conditions |
| Builder | Opus, as `subagent_type: "design-builder"` (compacts at 250K, keeps state in `plan.md` and `log.md`). Sonnet (same agent type, `model: "sonnet"`) only for an edit list the lead wrote where every line is file, key or line, old value, new value, with nothing left to choose | Applies the plan, then each round's fixes |
| Critic | Opus, a new Agent call each round, never resumed, never the builder or the lead | Runs `critic.md` |
| Gatherers | Haiku lookups; Sonnet digests, docs MCP and web research | Facts only |

- This session not on Opus: it only orchestrates. The lead is an Agent with `model: "opus"`, its
  prompt the owner's request word for word, `~/.claude/skills/design-finalize/SKILL.md` and the
  profile path.
- Every Agent call names `model`. Never `subagent_type: "fork"` for any role (a fork ignores
  `model` and carries the caller's context). A Workflow script passes `model` on every `agent()`,
  `"opus"` for lead, builder with choices, and critic. The builder always uses the `design-builder`
  agent type (`agentType` in a Workflow script); lead and critic stay `general-purpose`.
- A lead running as a subagent cannot ask the owner: it returns its questions; the orchestrator
  passes them to AskUserQuestion word for word and returns the answers unchanged with SendMessage
  (load it with ToolSearch). The lead spawns its own builder, critic and gatherers when it has the
  Agent tool; if not, it returns each as `model:` plus prompt, and the orchestrator dispatches
  exactly that. The orchestrator never words a question, turns owner words into fixes, or edits
  the build.
- Critic fixes are never handed to Sonnet as written: the lead turns them into an exact edit list
  first, or the builder is Opus.

The profile wins only on project facts (paths, render method, checks, caps, hand-off). It never
changes roles, models or gates. Caps limit how many agents run at once, never which model: over a
cap, queue the Opus work. A round cap below 3 is ignored and reported. No profile: the lead fills Owner, Agent caps and Finalize from
`~/.claude/skills/design-concepts/profile-template.md` in one owner round. `<set>` is the picked
concept's set folder, else a new one where the profile keeps sets.

## The loop

1. **Plan.** The lead writes `<set>/finalize/plan.md`: subject; scope (what must match, for
   example shape, layout, materials, lighting; what is out, for example the mockup backdrop); what
   each part of the reference maps to (file, helper, node, material, key); the framing. Scope is
   fixed after round 0; only the owner shrinks it. Round 0 goes to Sonnet only when `plan.md` is
   itself an edit list in the Builder row's form; any new code with structure to choose is an Opus
   build. For a photo, round 0 matches the camera, then the camera is frozen.
2. **Build round 0.**
3. **Checks.** Run the profile's checks; the render waits until they pass.
4. **Render** the built thing itself in the reference framing, by the profile's Finalize method.
   Never a re-rendered mockup, a description or an older shot. A human step: ask for the
   screenshot path with AskUserQuestion and end the turn; no critic round runs without it.
5. **Side by side:** `~/.claude/skills/design-finalize/sbs.sh <reference> <render>
   <set>/finalize/sbs-<N>.webp "BUILD r<N>"`. It refuses other framing or the reference itself.
6. **Critic:** a new Opus Agent call (never SendMessage to an earlier critic) gets `~/.claude/skills/design-finalize/critic.md` unchanged,
   with only its slots filled (image paths, subject and scope from `plan.md`, last round's fixes).
7. **Fix** the 3 fixes and any regressions. Log the round in `<set>/finalize/log.md`: builder
   model, the 3 fixes, verdict. Go to 3.
8. **Stop** only on: verdict MATCH; the round cap (profile, default 6); the same fix (same region
   and property, same target value) named 2 rounds running, where the lead re-plans that part and
   runs one more round, and if it is named again goes to the owner gate with it listed as unreached.
   At the cap, measured gaps left (a few px, a colour value) are fixes, not owner questions: fix
   them in one pass, then go to the owner gate.
9. **Owner gate.** `mkdir -p ~/Documents/concepts/<set folder basename>-finalize/` (its own folder, never shared with a parallel run; or the profile's hand-off folder, kept per set) and
   copy the last `sbs-<N>.webp` there; delete that folder in the turn the owner accepts. AskUserQuestion
   with that path, the critic's verdict and remaining list, no option marked recommended, and
   never "it matches" unless the critic said MATCH. The owner accepts, or names what is off (the
   lead turns that into the next round's fixes). Not done before the owner accepts.

## Rules

- 3 fixes per round, biggest first, so rounds converge instead of thrash.
- The build matches the reference; it never redesigns it. A taste veer goes back to the builder,
  never to the owner. A difference the build cannot reach (engine limit) goes to the owner with
  the closest option, never silently dropped. Ask the owner only taste calls, never pixel deltas.
- Same framing every round.
- A fix is measurable: "bevel 2 px to 6 px, rim #d9452b", never "make it feel more premium".
- Never `git commit` or `git push`; the owner commits. No em-dashes in any file or message.
