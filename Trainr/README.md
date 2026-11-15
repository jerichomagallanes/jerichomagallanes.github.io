# Trainr site

Served at https://jerichomagallanes.github.io/Trainr/ from this folder, so the
address the apps and both store listings link to never depends on a repository
name. Plain files: this repository has `.nojekyll`.

- `index.html` is the landing page; edit it directly.
- `privacy-policy.html` and `terms-of-use.html` are rendered from the markdown
  in `src/`. Edit the markdown, then re-render the body with
  `npx --yes marked --gfm -i src/<name>.md -o /tmp/body.html` and paste it
  between `<main>` and `</main>`; the head, header and footer are the same on
  both pages. Bump the "Last updated" date in the markdown.
- `assets/` holds the self-hosted fonts (OFL files beside them), the store
  badges, the screenshots, the link-preview image and `clips/`: the five
  feature videos (MP4 H.264 at 660 px, 24 fps, with a WebP poster each;
  no WebM: iOS Safari picks it and never starts playing).
- Re-recording a clip: append `src/ClipTests.swift.txt` to
  `TrainrUITests/OnboardingFlowTests.swift` in the iOS repo (temporarily; it
  is not committed there), `xcodebuild build-for-testing` for the iPhone 17 Pro
  Max simulator with the status bar set to 9:41, then `src/record-clips.sh
  testClipPlan plan` and so on. The script records the visible simulator with
  `simctl io recordVideo` while the test drives the app with deliberate pauses,
  and prints `MARK` timestamps; cut from `start` to `end` with ffmpeg
  (`-ss`/`-t`, `fps=24,scale=660:-2`, libx264 crf 27 and libvpx-vp9 crf 36).
  All five are cut by `src/cut-clips.sh`: motion starts about half a second
  in and the tail is short, so a clip that restarts when scrolled into view
  never looks stuck. The Adjust clip needs the on-device model on the host
  (`TRAINR_MODEL`); its cut keeps start to a few seconds after `useNote`,
  then `read` to `end`, so the model's wait is gone but "Reading your note"
  stays, and the typing half runs at 1.35×.
  Record it on an iOS 27 simulator (`UDID=... src/record-clips.sh`): on the
  iOS 26.2 simulator the app keeps running after the read but stops being
  drawn, and the recording shows the home screen. Keep the note about time
  only; a note that mentions pain goes to the pain screen, not a shorter
  workout, and ask for less time than the session has left. The progress
  clip drags a session onto another day; a completed day blocks any drag
  across it, so drop onto an unfinished one.
- Motion: the page has a small reveal system (blocks rise in once, children
  staggered), clips that play only while on screen and restart from their
  first frame when they come in, a nav that firms up after the first scroll,
  a hero fan that drifts and tilts with the pointer on desktop, and hover
  lifts on buttons, badges, cards and the feature phones. Everything is
  opacity/transform only, hidden states exist only when JavaScript runs
  (`html.js`), and `prefers-reduced-motion` turns all of it off.
- `src/check-page.mjs <url> <outdir>` drives headless Chrome over CDP as a phone
  and a desktop: reports reveal states and whether each clip plays when
  scrolled in, and saves screenshots. Needs Node 22+ and Google Chrome.
