#!/usr/bin/env node
// Renders an animated take to a looping MP4 (H.264 + AAC), frame-exact, in headless Chromium.
// Usage:
//   node video.mjs <page-url> <out.mp4> [--fps 30] [--crf 23] [--width W] [--audio loop.wav] [--size WxH]
//   node video.mjs mux <picture.mp4> <loop.wav> <out.mp4>
// The page sets window.ballotFrames = { seconds, frame(t) }: frame(t) draws the picture at t seconds
// (0 <= t < seconds, called in order from 0) and returns the canvas to capture, or a promise of it.
// Returning nothing captures the viewport instead (set --size). The clip holds round(seconds * fps)
// frames at a frame rate of frames / seconds, so it lasts exactly one loop. --width scales the picture down
// (aspect kept); --crf trades size for quality (lower is better, 18 to 28 is sane).
// The WAV is exactly one loop long (the picture's seconds), its tails already wrapped round the loop end.
// mux limits it to -2 dBFS (summed takes may peak past 0 dBFS) and copies the picture as is, so one
// picture render serves every sound take of a row. Run outside the Bash sandbox.
import { spawn, execFileSync } from "node:child_process";
import { mkdtempSync, rmSync } from "node:fs";
import { once } from "node:events";
import { tmpdir } from "node:os";
import { join } from "node:path";

const LIMIT = 0.794, // -2 dBFS: AAC overshoots a limited mix by up to about 1.1 dB
	LEAD = 2048; // two AAC frames
const run = (args) => execFileSync("ffmpeg", ["-hide_banner", "-loglevel", "error", "-y", ...args], { stdio: "inherit" });
const seconds = (f) => +execFileSync("ffprobe", ["-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", f]).toString();

function mux(picture, wav, out) {
	const n = Math.round(seconds(wav) * 48000);
	// Three loops through the limiter and the middle one kept, so the limiter is settled at the seam. The AAC
	// encoder overshoots on a cold start, so it also gets LEAD samples of the loop's end before it, at negative
	// time, which the MP4 edit list hides.
	run(["-i", picture, "-stream_loop", "2", "-i", wav, "-filter_complex",
		`[1:a]aresample=48000,alimiter=limit=${LIMIT}:attack=1:release=100:level=0:latency=1,` +
			`atrim=start_sample=${n - LEAD}:end_sample=${2 * n},asetpts=PTS-STARTPTS-${LEAD}/(SR*TB)[a]`,
		"-map", "0:v", "-map", "[a]", "-c:v", "copy", "-c:a", "aac", "-b:a", "128k", "-movflags", "+faststart", out]);
}

async function render(url, out, { fps = 30, crf = 23, width, audio, size }) {
	const profile = mkdtempSync(join(tmpdir(), "video-"));
	const [w, h] = size ? size.split("x").map(Number) : [1280, 720];
	const chrome = spawn("chromium", ["--headless=new", "--remote-debugging-pipe", "--use-angle=swiftshader", "--enable-unsafe-swiftshader",
		"--hide-scrollbars", "--mute-audio", "--allow-file-access-from-files", `--window-size=${w},${h}`, `--user-data-dir=${profile}`],
		{ stdio: ["ignore", "ignore", "ignore", "pipe", "pipe"], env: { ...process.env, DBUS_SESSION_BUS_ADDRESS: "disabled:" } });
	const pending = new Map();
	let buf = "", id = 0;
	chrome.stdio[4].on("data", (d) => {
		buf += d;
		for (let i; (i = buf.indexOf("\0")) >= 0; buf = buf.slice(i + 1)) {
			const m = JSON.parse(buf.slice(0, i)), p = pending.get(m.id);
			if (!p) continue;
			pending.delete(m.id);
			m.error ? p.no(new Error(JSON.stringify(m.error))) : p.ok(m.result);
		}
	});
	let session;
	const send = (method, params = {}) => new Promise((ok, no) => {
		const timer = setTimeout(() => no(new Error(`${method} timed out`)), 120_000);
		pending.set(++id, { ok: (r) => (clearTimeout(timer), ok(r)), no: (e) => (clearTimeout(timer), no(e)) });
		chrome.stdio[3].write(JSON.stringify({ id, method, params, sessionId: session }) + "\0");
	});
	const js = async (expression) => {
		const r = await send("Runtime.evaluate", { expression, awaitPromise: true, returnByValue: true });
		if (r.exceptionDetails) throw new Error(r.exceptionDetails.exception?.description || r.exceptionDetails.text);
		return r.result.value;
	};
	const tmp = audio && join(profile, "picture.mp4");
	try {
		const { targetId } = await send("Target.createTarget", { url });
		({ sessionId: session } = await send("Target.attachToTarget", { targetId, flatten: true }));
		await send("Emulation.setDeviceMetricsOverride", { width: w, height: h, deviceScaleFactor: 1, mobile: false });
		let sec = 0;
		for (let i = 0; !(sec = await js("window.ballotFrames?.seconds || 0")); i++) {
			if (i > 600) throw new Error(`${url} never set window.ballotFrames`);
			await new Promise((r) => setTimeout(r, 100));
		}
		// One warm-up frame makes the page ask for the fonts and images it draws, then they load.
		await js("Promise.resolve(ballotFrames.frame(0)).then(() => document.fonts.ready).then(() => new Promise((r) => setTimeout(r, 500)))");
		const n = Math.round(sec * fps);
		const ff = spawn("ffmpeg", ["-hide_banner", "-loglevel", "error", "-y", "-f", "image2pipe", "-c:v", "png", "-framerate", `${n}/${sec}`, "-i", "-",
			"-vf", width ? `scale=${width}:-2:flags=lanczos` : "scale=trunc(iw/2)*2:trunc(ih/2)*2", "-frames:v", String(n), "-c:v", "libx264", "-pix_fmt", "yuv420p", "-profile:v", "high",
			"-crf", String(crf), "-preset", "slow", "-tune", "animation", "-g", String(fps), "-movflags", "+faststart", "-an", tmp || out], { stdio: ["pipe", "inherit", "inherit"] });
		const done = once(ff, "close");
		for (let i = 0; i < n; i++) {
			let png = await js(`Promise.resolve(ballotFrames.frame(${(i * sec) / n})).then((c) => c ? c.toDataURL("image/png") : null)`);
			png = png ? png.slice(png.indexOf(",") + 1) : (await send("Page.captureScreenshot", { format: "png" })).data;
			if (!ff.stdin.write(Buffer.from(png, "base64"))) await once(ff.stdin, "drain");
		}
		ff.stdin.end();
		const [code] = await done;
		if (code) throw new Error(`ffmpeg exited ${code}`);
		if (audio) mux(tmp, audio, out);
		console.log(`${out}  ${n} frames, ${sec} s`);
	} finally {
		// Chromium writes its profile until it exits, so the folder is removed only after that.
		if (chrome.exitCode === null && chrome.signalCode === null) {
			chrome.kill();
			await once(chrome, "exit");
		}
		rmSync(profile, { recursive: true, force: true, maxRetries: 3 });
	}
}

const argv = process.argv.slice(2);
const opt = (name) => { const i = argv.indexOf(`--${name}`); return i < 0 ? undefined : argv.splice(i, 2)[1]; };
if (argv[0] === "mux" && argv.length === 4) mux(argv[1], argv[2], argv[3]);
else {
	const o = { fps: +(opt("fps") || 30), crf: +(opt("crf") || 23), width: opt("width"), audio: opt("audio"), size: opt("size") };
	if (argv.length !== 2) {
		console.error("usage: node video.mjs <page-url> <out.mp4> [--fps 30] [--crf 23] [--width W] [--audio loop.wav] [--size WxH] | mux <picture.mp4> <loop.wav> <out.mp4>");
		process.exit(2);
	}
	render(argv[0], argv[1], o).catch((e) => { console.error(`video.mjs: ${e.message}`); process.exit(1); });
}
