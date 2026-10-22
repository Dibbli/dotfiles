# Ballot mode: many items or rounds


For a roster (effects, cosmetics, icons) or more than 3 takes per item.
1. Optional first round: one `design-builder` agent (Opus) per style direction, each showing its
   style on one item per tier; the owner picks per item, not per style.
2. The designer writes one shared `brief.md` (owner calls, items or pairings table, true scale,
   kit API, render command, limits) and pre-lists every item in the ballot before any agent
   starts. Agents never edit shared files.
3. One `design-builder` agent (Opus) per item or pairing, within the cap, writes only its own
   files: 3 takes whose idea differs, not only their numbers, rendered and read by itself.
4. The designer reads every PNG, then bundles one self-contained ballot (the profile's kit wins)
   into the set folder and copies it to the hand-off folder (made as in Full mode step 7):
   `python3 ~/.claude/skills/design-concepts/ballot.py <set>/ballot-r<N>.html "<round title>" <item>/<take>.webp ...`
   (takes may be PNG, JPG, WEBP, OGG, MP3, WAV, MP4, WEBM, or a self-contained HTML page; a
   `<take>.txt` beside a take is its caption). Animated takes
   load paused at 0 s (the owner starts them), each row on one clock so its takes stay in sync; the header has a
   Pause all button, every row a Pause / Resume row button, and every animated take its own
   Pause / Play, so the owner can pause all and then play takes one by one (a row or all button
   puts every take back on the row clock). A project kit must do the same. An animated take draws from time (the
   requestAnimationFrame timestamp, `performance.now()`, CSS animations), never a frame counter. An HTML
   take that is not 16:9 posts `{ballotTake: {w, h, note}}` to its parent: the frame keeps its aspect,
   stops at 1:1, and shows the note under it. The take fills its frame with no scroll and no text.
   **A take with sound is a video**, never a live HTML take: a sandboxed take frame gets no autoplay
   permission, so its Web Audio stays silent. Row and all buttons play videos muted; a video plays its
   sound only from its own Play (or a click on it), one take at a time, and playing another take of the
   row hands the sound over at the same moment of the loop (an A/B switch). Silent animated takes may
   be videos too (no WebGL context cap, and they play on a phone).
   - Render (outside the Bash sandbox; Node, Chromium, ffmpeg):
     `node ~/.claude/skills/design-concepts/video.mjs <page-url> <take.mp4> [--audio loop.wav] [--width W] [--crf 23] [--fps 30]`.
     The page sets `window.ballotFrames = { seconds, frame(t) }`: `frame(t)` draws the picture at `t`
     seconds and returns its canvas (nothing: the viewport is shot, set `--size WxH`). The clip is exactly
     one loop: H.264 + AAC MP4, which plays in Chromium, Firefox and phones; the file has no audio seam (a browser's loop
     restart may add a few ms).
   - The WAV is one loop long with its tails wrapped round the loop end (the steady-state mix); the
     renderer runs it through a -2 dBFS limiter, so summed takes may peak past 0 dBFS. Takes that share a
     picture (sound takes over one animation): render the picture once with no `--audio`, then per take
     `node ~/.claude/skills/design-concepts/video.mjs mux <picture.mp4> <take.wav> <take.mp4>`.
   - A project kit with animated takes gives a frames route (a query that sets `window.ballotFrames` for
     one take) and a way to write each sounded take's loop mix as a WAV; the profile names both.
   - Check each video before the ballot: `ffprobe` duration equals the loop seconds and it has an audio
     stream; read a frame or two (`ffmpeg -ss <t> -i take.mp4 -frames:v 1 f.png`). Each video is in the
     ballot whole, so a ballot holds about 15 MB of takes; split a bigger round into several ballots.
   An option the designer or an agent judges worse (not plainly terrible) stays in as an extra
   take labelled "Rejected: <reason>. Here for review."; takes are not fixed at three.
5. The owner votes Favourite, Keep and notes and pastes the Export back. Nothing is built before
   that. Record votes in the set's `picks.md`. Every Keep is built and plays the same; a Favourite
   only steers the style of later concepts, never a weight, slot or order in the build. Several
   keeps on one theme stay; never trim them to fit a count. Small tweaks: the designer. Bigger
   ones: that item's own `design-builder` agent with SendMessage. A tweak round shows only edited or
   new takes; cut, rejected and kept-as-is takes stay off it.
6. After the picks are built, an optional last ballot shows each concept beside its rendered
   build, with Accept / Deny and a reason field.
