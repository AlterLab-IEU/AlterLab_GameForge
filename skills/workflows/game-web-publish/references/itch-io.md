# itch.io: Browser Builds with butler

Facts dated 2026-11-05. Sources: itch.io "Uploading HTML5 games" docs, butler documentation
("Pushing builds"), and press coverage of itch.io's AI policy changes (VGC, Heise, Aftermath,
1-3 Nov 2026). Items marked UNVERIFIED were not confirmed in itch.io's own docs.

## 1. Platform facts

| Topic | Rule |
|---|---|
| Upload format | ZIP with `index.html` at the root (or butler push of a folder) |
| Files | ≤1,000 files after extraction |
| Size | ≤500 MB extracted total; ≤200 MB for any single file |
| Paths | ≤240 characters including path; UTF-8; **case-sensitive server** |
| Hosting | Served from a **subdirectory** on itch.io's HTML CDN, inside an iframe |
| Absolute paths | Fail. A request for `/assets/x.png` points outside your folder |
| Missing files | Return **403**, not 404 (do not chase a permissions bug) |
| Trailing-slash folder URLs | Fail; reference files, not folders |
| External requests | Must be HTTPS ("itch.io is an HTTPS website with no exceptions") |
| Compression | The CDN gzips common types (html, js, css, wasm, pck and others) automatically. Pre-gzipped files are detected by content; Brotli files must end in `.br` |
| Mobile | On phones the page always uses "Click to launch in fullscreen"; without "Mobile friendly", players see a warning |
| Autostart | Click-to-play is on by default; with autostart, some browsers mute audio |

## 2. butler setup

butler is itch.io's command-line uploader. It uploads only the changed bytes (patches), which makes
frequent updates cheap.

```bash
butler login                  # opens a browser to authorize this machine once
butler push dist/itch yourname/your-game:html5 --userversion 1.0.3
```

- `yourname/your-game` is the project's URL slug, lowercase.
- The channel name (`html5`) is a label you choose. Channel names containing `win`/`windows`,
  `linux`, `mac`/`osx` or `android` are auto-tagged with that platform. A web channel is not
  auto-tagged: after the first push, open **Edit game > Uploads** and tick **This file will be
  played in the browser**, and set **Kind of project** to **HTML**.
- `--userversion 1.0.3` shows your version instead of itch's auto-incremented integer. In CI use
  `--userversion-file version.txt` (one line, UTF-8, no BOM).
- `--dry-run` lists what would be pushed without uploading. Use it to check ignore patterns.
- `--if-changed` skips the push when files match the last build; use it in CI.
- `--ignore '*.map'` (repeatable, two dashes) keeps source maps out of public builds.
- `butler status yourname/your-game` lists channels and their latest builds (UNVERIFIED on the
  current docs page; the build list is also visible from the channel button on the game page).

CI: authenticate with an API key stored as a secret (commonly the `BUTLER_API_KEY` environment
variable) instead of `butler login`. Never commit the key. Automating this is `game-ci-pipeline`'s
job.

Recommended channels:

| Channel | Use |
|---|---|
| `html5` | Public browser build |
| `html5-beta` | Hidden or restricted upload for testers |
| `windows`, `linux`, `mac` | Optional downloadable desktop builds (wrapped; see `wrappers.md`) |

## 3. Embed settings (Edit game > Embed options)

| Setting | Recommendation |
|---|---|
| Embed in page vs Click to launch in fullscreen | Embed for keyboard/mouse games at a fixed size; fullscreen launch for phones and for games that need the whole screen |
| Viewport dimensions | Match your design aspect, e.g. 960x540 or 1280x720 for 16:9; the game should still scale to any size |
| Fullscreen button | On; itch overlays it bottom-right |
| Mobile friendly | On only after testing on phones; set orientation if offered |
| Automatically start on page load | Off unless the game is silent until first input |
| Enable scrollbars | Off (hidden by default) |
| SharedArrayBuffer support | On **only** for threaded builds (Godot Thread Support, Unity threads, multithreaded physics WASM). Reported by secondary sources; confirm the option label on your Edit page and test the uploaded build with `self.crossOriginIsolated` |

## 4. Page and metadata

- **Cover image**: 630x500 is the common recommendation (UNVERIFIED as a current requirement);
  plus 3-5 screenshots and a short GIF of the core loop.
- **Short description**: one line that states the hook and the controls.
- **Genre and tags**: accurate tags beat many tags; include "HTML5" or "Browser" style tags.
- **Pricing**: free, paid, or "No payments" vs "Donate" / pay-what-you-want minimums.
- **Community**: enable comments or a board; jam entries benefit from comments.
- **Visibility**: Draft while testing, Restricted with a password or secret URL for testers,
  then Public.

## 5. AI disclosure on itch.io (as of 2026-11-05)

- itch.io requires creators to disclose generative-AI content; the disclosure powers a "no AI"
  filter that players can enable. On 2026-11-03 itch.io extended that filter to search and removed
  a large volume of AI-generated "slop" uploads (VGC, Heise, 3 Nov 2026).
- Bulk or low-effort AI uploads are treated as spam.
- Practical rule: disclose AI-generated art, audio, voice and writing that ship in the game or on
  the page. AI-assisted code is a grey area in itch.io's wording (UNVERIFIED); when in doubt,
  disclose and describe ("code written with an AI assistant; all art hand-made").
- Answer from the provenance log maintained via `game-ai-assets`, and keep the log with the
  release so the answer can be defended.

## 6. Devlogs and updates

- Post a devlog with each meaningful update: what changed, a GIF, and the version number that
  matches `--userversion`. Followers get notified, which is itch.io's main retention channel.
- Keep the old build reachable during a jam's judging period if the jam rules require a frozen
  build; push fixes to a separate channel or after judging.
- Changelog lines in the devlog should match the build report's "Known issues" fixes.

## 7. Jam submissions

- Check the jam's rules for allowed post-deadline fixes (often only critical bugs).
- Vibe Jam 2026 required instant play on the web with no login, signup or loading screens and a
  mandatory `widget.js` snippet; rules change per year, so read the current page.
- Submit the itch.io page early, then push the final build to the same channel before the deadline.

## 8. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Blank page, 403 errors in console | Absolute paths or wrong case in file names | `base: './'`; match case exactly |
| Works locally, not on itch | Local server is case-insensitive or serves from root | Test with `vite preview` from a subfolder |
| Godot: "SharedArrayBuffer is not defined" | Threaded export without isolation | Export single-threaded, or enable the SharedArrayBuffer option |
| Unity: decompression error | Host not sending `Content-Encoding` for `.br`/`.gz` | Enable Decompression Fallback, or rely on itch's `.br` handling |
| No sound until second click | Autostart or audio created before a gesture | Create/resume the `AudioContext` inside the first gesture |
| Too many files rejected | >1,000 files | Pack assets (atlases, audio sprites, a single data archive) |
