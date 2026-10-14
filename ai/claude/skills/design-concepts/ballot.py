"""Usage: python3 ballot.py <out.html> <title> <take>...

A take is an image (png, jpg, webp, gif), a sound (ogg, mp3, wav) or a self-contained HTML page
(animated take; it may load nothing relative), optionally "path=Label".
Animated takes all play at once on load, on one clock per row, so a row's takes stay in sync. The
header has Pause all / Resume all; each row has Pause row / Resume row and Restart row. A take must
draw from time, not a frame counter: the requestAnimationFrame timestamp, performance.now(),
Date.now(), CSS animations or video; the ballot holds and sets that clock.
Takes group by their parent folder (one group per item or pairing). Writes ONE self-contained
ballot: per take Favourite (one per group), Keep (any number) and a note; Export gives Markdown the
owner pastes back. Votes persist per viewer in localStorage, keyed by the takes, so a new round
never inherits old votes. The page lists its keyboard shortcuts in its header.
"""
import base64
import hashlib
import html
import json
import re
import sys
from pathlib import Path

MEDIA = {".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".webp": "image/webp",
         ".gif": "image/gif", ".ogg": "audio/ogg", ".mp3": "audio/mpeg", ".wav": "audio/wav"}
# Injected first into every animated take: its clock is the row's clock, sent by the ballot page.
CLOCK = """<script>(() => {
const realNow = performance.now.bind(performance), realRaf = requestAnimationFrame.bind(window), epoch = Date.now();
let playing = false, at = 0, base = 0, step = true, id = 0, cbs = new Map();
const now = () => (playing ? at + realNow() - base : at);
performance.now = now;
Date.now = () => epoch + now();
window.requestAnimationFrame = (cb) => (cbs.set(++id, cb), id);
window.cancelAnimationFrame = (i) => cbs.delete(i);
const sync = () => {
	// play() on a finished animation rewinds it to 0, so the time is set after it.
	for (const a of document.getAnimations()) { playing ? a.play() : a.pause(); a.currentTime = now(); }
	for (const m of document.querySelectorAll("video, audio")) {
		if (m.duration) m.currentTime = (now() / 1000) %% m.duration;
		playing ? m.play().catch(() => {}) : m.pause();
	}
};
const tick = () => {
	if ((playing || step) && cbs.size) {
		step = false;
		const run = cbs, t = now();
		cbs = new Map();
		run.forEach((cb) => cb(t));
	}
	if (!playing) for (const a of document.getAnimations()) if (a.playState === "running") { a.pause(); a.currentTime = at; }
	realRaf(tick);
};
realRaf(tick);
addEventListener("message", (e) => {
	if (e.source !== parent || e.data?.ballot !== 1) return;
	({ at, playing } = e.data);
	base = realNow();
	step = true;
	sync();
});
parent.postMessage({ ballotReady: 1 }, "*");
})();</script>""".replace("%%", "%")


def with_clock(doc: str) -> str:
    for pattern in (r"<head[^>]*>", r"<html[^>]*>", r"<!doctype[^>]*>"):
        m = re.search(pattern, doc, re.I)
        if m:
            return doc[: m.end()] + CLOCK + doc[m.end() :]
    return CLOCK + doc


RELATIVE = re.compile(r"""(?:src|href)\s*=\s*["'`](?!data:|https?:|#|about:|blob:)|url\(\s*["']?(?!data:|https?:|#|blob:)""")

out, title, args = sys.argv[1], sys.argv[2], sys.argv[3:]
groups: dict[str, list[dict]] = {}
seen = set()
for arg in args:
    path, _, label = arg.partition("=")
    p = Path(path)
    tid = f"{p.parent.name}/{p.name}"
    if tid in seen:
        sys.exit(f"duplicate take {tid}")
    seen.add(tid)
    take = {"id": tid, "label": label or p.stem}
    ext = p.suffix.lower()
    if ext in MEDIA:
        kind = "audio" if MEDIA[ext].startswith("audio") else "img"
        take[kind] = f"data:{MEDIA[ext]};base64," + base64.b64encode(p.read_bytes()).decode()
    elif ext == ".html":
        doc = p.read_text(encoding="utf-8")
        if RELATIVE.search(doc):
            sys.exit(f"{p} loads relative files: inline them first")
        take["doc"] = with_clock(doc)
    else:
        sys.exit(f"{p}: unsupported take type")
    groups.setdefault(p.parent.name, []).append(take)

page = """<!doctype html><html lang="en"><head><meta charset="utf-8"><title>%(title)s</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
:root {
	color-scheme: dark;
	--base: #121212; --card: #191919; --panel: #212121; --input: #2a2a2a; --line: #535353;
	--text: #d5d5d5; --muted: #a7a7a7; --ember: #df6464; --ember-deep: #b14242; --amber: #e49a44; --teal: #4a8b8b;
	--grad: linear-gradient(45deg, #b14242, #df6464);
	--sans: "Inter", system-ui, "Segoe UI", Roboto, "Noto Sans", sans-serif;
	--mono: "Lilex Nerd Font Mono", "Lilex", ui-monospace, "JetBrains Mono", "DejaVu Sans Mono", monospace;
}
* { box-sizing: border-box; }
html { scroll-padding-top: calc(var(--head, 96px) + 16px); }
body { margin: 0; background: var(--base); color: var(--text); font: 14px/1.45 var(--sans); }
button { font: inherit; color: var(--text); background: var(--panel); border: 1px solid var(--line); border-radius: 6px; padding: 5px 12px; cursor: pointer; white-space: nowrap; }
button:hover { background: var(--input); }
button.primary, button.fav[aria-pressed="true"] { background: var(--ember-deep); border-color: var(--ember-deep); color: #fff; }
button.primary:hover, button.fav[aria-pressed="true"]:hover { filter: brightness(1.12); }
button.keep[aria-pressed="true"] { background: var(--teal); border-color: var(--teal); color: var(--base); font-weight: 600; }
button.fav[aria-pressed="true"] { font-weight: 600; }
:focus-visible { outline: 2px solid var(--ember); outline-offset: 2px; }
::selection { color: #fff; background: var(--ember-deep); }
kbd { font: 11px/1.5 var(--mono); color: var(--muted); background: var(--panel); border: 1px solid var(--line); border-bottom-width: 2px; border-radius: 4px; padding: 0 5px; }

.top { position: sticky; top: 0; z-index: 5; background: rgb(18 18 18 / .95); backdrop-filter: blur(8px); border-bottom: 1px solid var(--input); }
.top::before { content: ""; display: block; height: 2px; background: var(--grad); }
.bar { display: flex; flex-wrap: wrap; align-items: center; gap: 10px 20px; padding: 12px 24px 8px; }
h1 { flex: 1 1 240px; margin: 0; font-size: 17px; font-weight: 650; overflow-wrap: anywhere; }
.progress { display: flex; align-items: center; gap: 10px; font: 13px var(--mono); color: var(--muted); }
.meter { width: 140px; height: 6px; border-radius: 3px; background: var(--input); overflow: hidden; }
.meter i { display: block; height: 100%%; width: 0; background: var(--grad); transition: width .2s; }
.actions { display: flex; flex-wrap: wrap; gap: 8px; }
.keys { display: flex; flex-wrap: wrap; gap: 4px 18px; padding: 0 24px 10px; font-size: 12px; color: var(--muted); }

.layout { display: grid; grid-template-columns: 220px minmax(0, 1fr); gap: 28px; padding: 20px 24px 64px; }
nav { position: sticky; top: calc(var(--head, 96px) + 20px); align-self: start; max-height: calc(100vh - var(--head, 96px) - 40px); overflow: auto; }
nav p { margin: 0 0 8px 12px; font-size: 11px; letter-spacing: .08em; text-transform: uppercase; color: var(--muted); }
nav ol { list-style: none; margin: 0; padding: 0; }
nav button { display: grid; grid-template-columns: 18px minmax(0, 1fr); width: 100%%; padding: 6px 10px; text-align: left; white-space: normal; background: none; border: 0; border-left: 2px solid transparent; border-radius: 0 6px 6px 0; }
nav button:hover { background: var(--card); }
nav .current button { background: var(--panel); border-left-color: var(--ember-deep); }
nav .mark { color: var(--muted); }
nav .done .mark { color: var(--ember); }
nav small { grid-column: 2; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 12px; color: var(--muted); }

.group { margin-bottom: 40px; }
.ghead { display: flex; flex-wrap: wrap; align-items: center; gap: 8px 12px; margin-bottom: 12px; padding: 2px 0 2px 12px; border-left: 3px solid var(--input); }
.group.current .ghead { border-left-color: var(--ember-deep); }
.idx { font: 13px var(--mono); color: var(--muted); }
h2 { margin: 0; font-size: 16px; font-weight: 600; }
.status { font-size: 13px; color: var(--muted); }
.group.done .status { color: var(--ember); }
.tools { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; margin-left: auto; }
.clock { min-width: 7ch; text-align: right; font: 13px var(--mono); color: var(--muted); }
.takes { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%%, 380px), 1fr)); gap: 16px; }
/* A lone sound player stretched to full width reads as a scrubber bar, not a take. */
.takes.sounds { grid-template-columns: repeat(auto-fill, minmax(min(100%%, 380px), 1fr)); }

.take { display: flex; flex-direction: column; background: var(--card); border: 1px solid var(--input); border-radius: 10px; overflow: hidden; }
.take { transition: border-color .15s, box-shadow .15s; }
.take.is-keep { border-color: var(--teal); box-shadow: 0 0 0 2px var(--teal); }
.take.is-fav { border-color: var(--ember); box-shadow: 0 0 0 2px var(--ember), 0 0 28px rgb(223 100 100 / .35); }
.take.is-keep .thead { background: rgb(74 139 139 / .22); }
.take.is-fav .thead { background: rgb(177 66 66 / .32); }
/* Once a row has a pick, the takes without a vote step back so the votes read at a glance. */
.group.done .take:not(.is-fav):not(.is-keep) .media { opacity: .45; transition: opacity .15s; }
.group.done .take:not(.is-fav):not(.is-keep):hover .media { opacity: 1; }
.take.wide { grid-column: 1 / -1; }
.thead { display: flex; flex-wrap: wrap; align-items: center; gap: 6px 8px; padding: 10px 12px; }
.thead b { flex: 1 1 8em; font-weight: 600; overflow-wrap: anywhere; }
.chip { padding: 0 8px; border: 1px solid; border-radius: 999px; font-size: 12px; white-space: nowrap; }
.chip-fav, .chip-keep { padding: 1px 10px; font-weight: 700; letter-spacing: .04em; text-transform: uppercase; }
.chip-rej { color: var(--amber); border-color: var(--amber); }
.chip-fav { color: #fff; background: var(--ember-deep); border-color: var(--ember); }
.chip-keep { color: var(--base); background: var(--teal); border-color: var(--teal); }
.take:not(.is-fav) .chip-fav, .take:not(.is-keep) .chip-keep { display: none; }
.thead .enlarge { padding: 2px 10px; font-size: 12px; }
.media { flex: 1; display: grid; place-items: center; background: var(--base); }
.media img { display: block; max-width: 100%%; max-height: 70vh; cursor: zoom-in; }
.media audio { width: calc(100%% - 24px); margin: 16px 12px; }
.media iframe { display: block; width: 100%%; aspect-ratio: 16 / 9; border: 0; background: #000; }
.vote { display: flex; gap: 8px; padding: 10px 12px 0; }
textarea { font: inherit; color: var(--text); background: var(--input); border: 1px solid var(--line); border-radius: 6px; padding: 6px 8px; }
textarea::placeholder { color: var(--muted); }
.note { margin: 8px 12px 12px; min-height: 2.4em; resize: vertical; field-sizing: content; }

#export { padding: 20px; background: var(--card); border: 1px solid var(--input); border-radius: 10px; }
#export h2 { margin-bottom: 6px; }
#export p { margin: 0 0 12px; color: var(--muted); }
#export p button { padding: 0 6px; color: var(--ember); background: none; border: 0; text-decoration: underline; }
#export .actions { align-items: center; }
#copied { font-size: 13px; color: var(--muted); }
#out { display: block; width: 100%%; min-height: 12em; margin-top: 12px; font: 13px/1.5 var(--mono); }

#zoom { width: 100vw; height: 100vh; max-width: none; max-height: none; margin: 0; padding: 0; border: 0; color: var(--text); background: var(--base); }
#zoom[open] { display: flex; flex-direction: column; }
.zbar { display: flex; flex-wrap: wrap; align-items: center; gap: 8px 12px; padding: 10px 16px; background: var(--card); border-bottom: 1px solid var(--input); }
.zbar b { flex: 1 1 auto; }
.zbar span { font: 13px var(--mono); color: var(--muted); }
.zview { flex: 1; display: flex; min-height: 0; overflow: auto; }
.zview img { margin: auto; max-width: 100%%; max-height: 100%%; cursor: zoom-in; }
.zview.actual img { max-width: none; max-height: none; cursor: zoom-out; }

@media (max-width: 1100px) {
	.layout { grid-template-columns: minmax(0, 1fr); }
	nav { display: none; }
}
@media (max-width: 760px) {
	.bar, .layout { padding-left: 12px; padding-right: 12px; }
	.keys { display: none; }
	.meter { width: 80px; }
}
</style></head><body>
<header class="top"><div class="bar"><h1>%(title)s</h1>
	<div class="progress"><div class="meter"><i id="meter"></i></div><span id="count"></span></div>
	<div class="actions"><button id="next">Next open row</button><button id="all" hidden></button><button id="toexport" class="primary">Export</button></div></div>
	<div class="keys"><span><kbd>J</kbd> <kbd>K</kbd> next / previous row</span><span><kbd>N</kbd> next open row</span>
	<span><kbd>1</kbd>-<kbd>9</kbd> favourite take</span><span><kbd>Shift</kbd>+<kbd>1</kbd>-<kbd>9</kbd> keep</span>
	<span><kbd>P</kbd> pause row, <kbd>Shift</kbd>+<kbd>P</kbd> all</span><span><kbd>E</kbd> export</span><span>Click an image to view it large</span></div>
</header>
<div class="layout"><nav><p>Rows</p><ol id="nav"></ol></nav>
<main><div id="ballot"></div>
<section id="export"><h2>Export</h2><p id="summary"></p>
	<div class="actions"><button id="export-md" class="primary">Export Markdown</button><button id="dl">Download .md</button><span id="copied" role="status"></span></div>
	<textarea id="out" readonly placeholder="Press Export Markdown, then paste it back."></textarea></section></main></div>
<dialog id="zoom"><div class="zbar"><b id="zlabel"></b><span id="zinfo"></span><button id="zfit">1:1</button><button id="zprev">Prev</button><button id="znext">Next</button><button id="zclose" class="primary">Close</button></div>
	<div class="zview"><img id="zimg" alt=""></div></dialog>
<script>
const TITLE = %(title_js)s, GROUPS = %(groups)s, KEY = "ballot:" + %(digest)s;
const START = performance.now(); // every row starts on the same clock
let votes = {};
try { votes = JSON.parse(localStorage.getItem(KEY)) || {}; } catch {}
const save = () => { try { localStorage.setItem(KEY, JSON.stringify(votes)); } catch {} };
const v = (id) => (votes[id] ??= { fav: false, keep: false, note: "" });
const $ = (s, el = document) => el.querySelector(s);
const make = (tag, cls, text) => { const n = document.createElement(tag); if (cls) n.className = cls; if (text) n.textContent = text; return n; };
const header = $(".top"), out = $("#out"), rows = [];
let cur = 0, want = 0;
new ResizeObserver(() => document.documentElement.style.setProperty("--head", header.offsetHeight + "px")).observe(header);

Object.entries(GROUPS).forEach(([group, takes], gi) => {
	const sec = make("section", "group"), head = make("div", "ghead"), box = make("div", "takes");
	head.append(make("span", "idx", String(gi + 1).padStart(2, "0")), make("h2", "", group), make("span", "status"), make("span", "tools"));
	box.classList.toggle("sounds", takes.every((t) => t.audio));
	sec.append(head, box);
	$("#ballot").append(sec);
	const li = make("li"), go = make("button");
	go.append(make("span", "mark"), make("span", "", group), make("small"));
	go.onclick = () => goto(gi);
	li.append(go);
	$("#nav").append(li);
	const row = { group, sec, box, li, cards: [] };
	takes.forEach((t, ti) => row.cards.push(card(row, t, ti)));
	if (takes.some((t) => t.doc)) row.clock = rowClock(row);
	rows.push(row);
	paint(row);
});

function card(row, t, ti) {
	const el = make("article", "take");
	el.innerHTML = `<div class="thead">${ti < 9 ? `<kbd title="Press ${ti + 1} to favourite, Shift+${ti + 1} to keep">${ti + 1}</kbd>` : ""}<b></b>
		<span class="chip chip-fav">\\u2605 Favourite</span><span class="chip chip-keep">\\u2713 Keep</span></div>
		<div class="media">${t.img ? `<img alt="">` : t.audio ? `<audio controls preload="none"></audio>` : `<iframe sandbox="allow-scripts"></iframe>`}</div>
		<div class="vote"><button class="fav"></button><button class="keep"></button></div>
		<textarea class="note" rows="1" placeholder="Notes"></textarea>`;
	$("b", el).textContent = t.label;
	if (/reject/i.test(t.label)) $(".chip", el).before(make("span", "chip chip-rej", "Rejected"));
	const c = { el, t, fav: $(".fav", el), keep: $(".keep", el) };
	if (t.img || t.doc) {
		const big = make("button", "enlarge", "Enlarge");
		big.onclick = () => (t.img ? zoomOpen(row, ti) : (big.textContent = el.classList.toggle("wide") ? "Shrink" : "Enlarge"));
		$(".thead", el).append(big);
	}
	if (t.img) { const img = $("img", el); img.src = t.img; img.onclick = () => zoomOpen(row, ti); }
	else if (t.audio) $("audio", el).src = t.audio;
	else $("iframe", el).srcdoc = t.doc;
	const note = $(".note", el);
	note.value = v(t.id).note;
	note.oninput = () => { v(t.id).note = note.value; save(); exportRefresh(); };
	c.fav.onclick = () => favourite(row, c);
	c.keep.onclick = () => keep(row, c);
	el.addEventListener("focusin", () => setCur((want = rows.indexOf(row))));
	row.box.append(el);
	return c;
}
// Favourite is one per row; pressing it again clears it.
function favourite(row, c) {
	const on = !v(c.t.id).fav;
	for (const o of row.cards) v(o.t.id).fav = on && o === c;
	save(); paint(row); progress();
}
function keep(row, c) { v(c.t.id).keep = !v(c.t.id).keep; save(); paint(row); exportRefresh(); }
function paint(row) {
	const pick = row.cards.find((c) => v(c.t.id).fav);
	for (const { el, t, fav, keep } of row.cards) {
		const s = v(t.id);
		el.classList.toggle("is-fav", s.fav);
		el.classList.toggle("is-keep", s.keep);
		fav.setAttribute("aria-pressed", s.fav);
		fav.textContent = (s.fav ? "\\u2605" : "\\u2606") + " Favourite";
		keep.setAttribute("aria-pressed", s.keep);
		keep.textContent = (s.keep ? "\\u2713" : "+") + " Keep";
	}
	row.done = !!pick;
	row.sec.classList.toggle("done", row.done);
	$(".status", row.sec).textContent = pick ? "\\u2605 Favourite: " + pick.t.label : "No favourite yet";
	row.li.classList.toggle("done", row.done);
	$(".mark", row.li).textContent = row.done ? "\\u2605" : "\\u25CB";
	$("small", row.li).textContent = pick ? pick.t.label : "";
}
function progress() {
	const open = rows.filter((r) => !r.done), done = rows.length - open.length, sum = $("#summary");
	$("#count").textContent = `${done} / ${rows.length} rows picked`;
	$("#meter").style.width = (100 * done) / rows.length + "%%";
	sum.replaceChildren(open.length ? `${done} of ${rows.length} rows have a favourite. Still open:` : `All ${rows.length} rows have a favourite.`);
	for (const r of open) { const b = make("button", "", r.group); b.onclick = () => goto(rows.indexOf(r)); sum.append(" ", b); }
	exportRefresh();
}

// The current row is the one at the top of the view; keys act on it.
function setCur(i) {
	cur = i;
	rows.forEach((r, j) => { r.sec.classList.toggle("current", j === i); r.li.classList.toggle("current", j === i); });
}
function track() {
	const line = header.offsetHeight + 40, bottom = innerHeight + scrollY >= document.documentElement.scrollHeight - 2;
	let i = 0;
	rows.forEach((r, j) => { if (r.sec.getBoundingClientRect().top <= line) i = j; });
	// The last rows never reach the top, so at the bottom a row picked with J, the nav or a click wins.
	setCur(bottom ? Math.max(i, want) : i);
}
function goto(i) {
	want = Math.max(0, Math.min(rows.length - 1, i));
	setCur(want);
	rows[want].sec.scrollIntoView({ behavior: "smooth" });
}
function nextOpen() {
	const i = [...rows.keys()].map((k) => (cur + 1 + k) %% rows.length).find((k) => !rows[k].done);
	i === undefined ? exportNow() : goto(i);
}
addEventListener("scroll", track, { passive: true });

// One clock per row: every animated take in the row gets the same time and state at once. A take
// holds still until it says it is ready and is sent the row clock.
function rowClock(row) {
	let playing = true, at = 0, base = START;
	const time = () => (playing ? at + performance.now() - base : at);
	const post = (f) => f.contentWindow?.postMessage({ ballot: 1, at: time(), playing }, "*");
	const send = () => row.box.querySelectorAll("iframe").forEach(post);
	const toggle = make("button", "", "Pause row"), restart = make("button", "", "Restart row"), clock = make("span", "clock");
	const set = (on) => {
		at = time();
		base = performance.now();
		playing = on;
		toggle.textContent = on ? "Pause row" : "Resume row";
		send();
		allButton();
	};
	toggle.onclick = () => set(!playing);
	restart.onclick = () => { at = 0; base = performance.now(); send(); };
	(function show() { clock.textContent = (time() / 1000).toFixed(1) + " s"; requestAnimationFrame(show); })();
	$(".tools", row.sec).append(toggle, restart, clock);
	return { set, toggle: () => set(!playing), playing: () => playing, greet: (src) => row.box.querySelectorAll("iframe").forEach((f) => f.contentWindow === src && post(f)) };
}
const clocks = rows.map((r) => r.clock).filter(Boolean), all = $("#all");
addEventListener("message", (e) => { if (e.data?.ballotReady === 1) clocks.forEach((c) => c.greet(e.source)); });
const allButton = () => (all.textContent = clocks.some((c) => c.playing()) ? "Pause all" : "Resume all");
all.onclick = () => { const on = !clocks.some((c) => c.playing()); clocks.forEach((c) => c.set(on)); };
all.hidden = !clocks.length;
allButton();
// One sound at a time: starting a take stops the others.
document.addEventListener("play", (e) => document.querySelectorAll("audio").forEach((a) => a !== e.target && a.pause()), true);

const zoom = $("#zoom"), zimg = $("#zimg"), zview = $(".zview");
let zset = [], zi = 0;
function zoomOpen(row, ti) {
	zset = row.cards.filter((c) => c.t.img);
	zshow(zset.indexOf(row.cards[ti]));
	if (!zoom.open) zoom.showModal();
}
function zshow(i) {
	zi = (i + zset.length) %% zset.length;
	actual(false);
	zimg.src = zset[zi].t.img;
	$("#zlabel").textContent = zset[zi].t.label;
}
// 1:1 means one image pixel per screen pixel, so a HiDPI screen shows it at 1 / devicePixelRatio CSS size.
function actual(on) {
	zview.classList.toggle("actual", on);
	zimg.style.width = on ? zimg.naturalWidth / devicePixelRatio + "px" : "";
	$("#zfit").textContent = on ? "Fit" : "1:1";
}
zimg.onload = () => ($("#zinfo").textContent = `${zi + 1} / ${zset.length}, ${zimg.naturalWidth} \\u00D7 ${zimg.naturalHeight}`);
zimg.onclick = $("#zfit").onclick = () => actual(!zview.classList.contains("actual"));
$("#zprev").onclick = () => zshow(zi - 1);
$("#znext").onclick = () => zshow(zi + 1);
$("#zclose").onclick = () => zoom.close();
zoom.addEventListener("keydown", (e) => {
	const k = { ArrowLeft: () => zshow(zi - 1), ArrowRight: () => zshow(zi + 1), z: () => $("#zfit").click() }[e.key];
	if (k) { k(); e.preventDefault(); }
});

addEventListener("keydown", (e) => {
	if (zoom.open || e.ctrlKey || e.metaKey || e.altKey || e.target.matches("textarea:not([readonly]), input")) return;
	const k = e.key.toLowerCase(), row = rows[cur], n = /^Digit[1-9]$/.test(e.code) ? +e.code[5] : 0;
	if (n) { const c = row.cards[n - 1]; if (c) (e.shiftKey ? keep : favourite)(row, c); }
	else if (k === "j" || k === "k") goto(cur + (k === "j" ? 1 : -1));
	else if (k === "n") nextOpen();
	else if (k === "p") e.shiftKey ? all.hidden || all.click() : row.clock?.toggle();
	else if (k === "e") exportNow();
	else return;
	e.preventDefault();
});

function md() {
	let o = `# ${TITLE}\\n`;
	for (const [group, takes] of Object.entries(GROUPS)) {
		o += `\\n## ${group}\\n`;
		for (const t of takes) {
			const s = v(t.id), tags = [s.fav && "FAVOURITE", s.keep && "keep"].filter(Boolean).join(", ") || "no";
			o += `- ${t.label}: ${tags}${s.note ? ". " + s.note.replace(/\\n/g, " ") : ""}\\n`;
		}
	}
	return o;
}
function exportRefresh() { if (out.value) out.value = md(); }
async function exportNow() {
	out.value = md();
	$("#export").scrollIntoView({ behavior: "smooth" });
	out.select();
	try { await navigator.clipboard.writeText(out.value); $("#copied").textContent = "Copied to the clipboard. Paste it back in the chat."; }
	catch { $("#copied").textContent = "Selected below. Press Ctrl+C to copy."; }
}
$("#toexport").onclick = $("#export-md").onclick = exportNow;
$("#next").onclick = nextOpen;
$("#dl").onclick = () => {
	const a = document.createElement("a");
	a.href = URL.createObjectURL(new Blob([md()], { type: "text/markdown" }));
	a.download = TITLE.replace(/[^\\w-]+/g, "-") + ".md";
	a.click();
};
progress();
track();
</script></body></html>
"""
Path(out).parent.mkdir(parents=True, exist_ok=True)
Path(out).write_text(page % {
    "title": html.escape(title),
    "title_js": json.dumps(title).replace("</", "<\\/"),
    "groups": json.dumps(groups).replace("</", "<\\/"),
    "digest": json.dumps(hashlib.sha1(json.dumps(groups, sort_keys=True).encode()).hexdigest()),
}, encoding="utf-8")
print(out)
