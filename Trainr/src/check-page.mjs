// Drives headless Chrome over CDP: mobile + desktop, scrolls to each clip, reports reveal state and playback, saves screenshots.
import { spawn } from "node:child_process"; import { writeFileSync, mkdtempSync } from "node:fs"; import { tmpdir } from "node:os"; import { join } from "node:path";
const CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; const URL0 = process.argv[2]; const OUT = process.argv[3];
const port = 9333, prof = mkdtempSync(join(tmpdir(), "cdp-"));
const chrome = spawn(CHROME, [`--remote-debugging-port=${port}`, `--user-data-dir=${prof}`, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--autoplay-policy=no-user-gesture-required", "--window-size=1400,900", "about:blank"], { stdio: "ignore" });
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
async function target() { for (let i = 0; i < 40; i++) { try { const r = await fetch(`http://127.0.0.1:${port}/json/new?about:blank`, { method: "PUT" }); return (await r.json()).webSocketDebuggerUrl; } catch { await sleep(250); } } throw new Error("no chrome"); }
const ws = new WebSocket(await target()); await new Promise(r => ws.onopen = r);
let id = 0; const pending = new Map(); ws.onmessage = (m) => { const d = JSON.parse(m.data); if (d.id && pending.has(d.id)) { pending.get(d.id)(d.result ?? d.error); pending.delete(d.id); } };
const cdp = (method, params = {}) => new Promise(r => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params })); });
const evaluate = async (expr) => (await cdp("Runtime.evaluate", { expression: expr, returnByValue: true, awaitPromise: true })).result?.value;
const shot = async (name) => writeFileSync(join(OUT, name), Buffer.from((await cdp("Page.captureScreenshot", { format: "png" })).data, "base64"));
await cdp("Page.enable"); await cdp("Runtime.enable");
for (const [label, w, h, mobile] of [["mobile", 390, 844, true], ["desktop", 1400, 900, false]]) {
  await cdp("Emulation.setDeviceMetricsOverride", { width: w, height: h, deviceScaleFactor: mobile ? 2 : 1, mobile });
  if (mobile) await cdp("Emulation.setUserAgentOverride", { userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1" });
  await cdp("Page.navigate", { url: URL0 + "?cdp=" + Date.now() }); await sleep(2500);
  const top = await evaluate(`({ js: document.documentElement.classList.contains('js'), reveals: document.querySelectorAll('.reveal').length, inTop: document.querySelectorAll('.reveal.in').length, h1: [...document.querySelectorAll('.hero h1 .line > span')].map(s => s.classList.contains('in')), nav: document.querySelector('nav').className })`);
  console.log(label, "top:", JSON.stringify(top)); await shot(`${label}-hero.png`);
  const ids = ["plan", "adjust", "setup", "session", "progress"];
  for (const sec of ids) {
    await evaluate(`document.querySelector('#${sec} video').scrollIntoView({block:'center'}); true`); await sleep(1800);
    const st = await evaluate(`(() => { const v = document.querySelector('#${sec} video'); const r = v.getBoundingClientRect(); return { paused: v.paused, t: +v.currentTime.toFixed(2), ready: v.readyState, inView: r.top < innerHeight && r.bottom > 0, phoneIn: v.closest('.phone').classList.contains('in'), copyIn: [...document.querySelectorAll('#${sec} .copy > .reveal')].every(e => e.classList.contains('in')) }; })()`);
    console.log(label, sec, JSON.stringify(st)); if (sec === "adjust" || sec === "progress") await shot(`${label}-${sec}.png`);
  }
  await evaluate(`scrollTo(0, 0); true`); await sleep(600);
  const after = await evaluate(`({ playing: [...document.querySelectorAll('.feature video')].filter(v => !v.paused).length, nav: document.querySelector('nav').className })`);
  console.log(label, "back at top:", JSON.stringify(after));
}
ws.close(); chrome.kill();
