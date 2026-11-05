# Export and Platforms (Godot 4.7, notes for 4.8)

Reference for `game-godot-specialist`. Platform facts come from the Godot 4.7 export docs unless
another source is named. Store submission and compliance belong to `/gameforge:game-launch`; browser
release (itch.io, portals, PWA, wrappers) belongs to `/gameforge:game-web-publish`.

## 1. Before any export

| Item | Rule |
|---|---|
| Export templates | Must match the editor version exactly (4.7.2 editor, 4.7.2 templates). Editor > Manage Export Templates, or cache them in CI. |
| `export_presets.cfg` | The docs call it safe to commit, so commit it. CI exports need it. |
| `.godot/export_credentials.cfg` | Holds passwords and encryption keys. Never commit it. Copy it to a new machine by hand or inject the values from CI secrets. |
| Renderer | Pick early: Forward+ (desktop), Mobile, or Compatibility (low-end and web). Changing late means retuning lighting and shaders. |
| Shader baker (4.5+) | Enable it in the export preset. It precompiles shaders for the target driver; the 4.5 release notes report a 20x load-time drop for the TPS demo on Metal and D3D12. |
| Non-resource files | `.json`, `.csv`, `.txt` and similar are not exported unless listed under the preset's *Filters to export non-resource files/folders*. |
| `res://` vs `user://` | `res://` is read-only in exported builds. Saves, settings and logs go to `user://`. |
| Path case | Exported packs are case-sensitive. A `load("res://Art/hero.png")` that works on Windows can fail in the export. |
| Patches (4.6+) | `--export-patch` with `--patches` builds a patch pack; 4.6 added delta encoding so only changed parts of resources ship. |

Feature tags let one project behave per platform: `OS.has_feature("web")`, `"mobile"`, `"pc"`, plus
custom tags defined in a preset. Project settings can be overridden per tag (the web audio setting
below is one example), which beats `if` chains in code.

Always test the **exported** build, not just the editor run: missing filters, case mismatches and
`res://` writes only fail in exports.

## 2. Desktop

| Target | Notes |
|---|---|
| Windows | `.exe` plus `.pck`, or one file with *Embed PCK*. Code signing is optional but reduces SmartScreen warnings. |
| macOS | Signing and notarization need an Apple Developer account; follow the "Exporting for macOS" page step by step. From 4.8, editor downloads are per architecture, with universal builds still offered. |
| Linux | x86_64 and arm64 templates. Steam Deck runs the Linux build natively or the Windows build through Proton; test at 1280x800 with a controller. |

Steam: the common route is the community **GodotSteam** project, distributed as a GDExtension or as
a precompiled editor. Match its release to your exact engine version before upgrading Godot.

## 3. Mobile

**Android** (requirements from the 4.7 "Exporting for Android" page):

- OpenJDK 17 (newer versions work; 17 is recommended).
- Android SDK: Platform-Tools 35.0.0+, Build-Tools 35.0.1, Platform 35, Command-line Tools (latest),
  CMake 3.10.2.4988404, NDK r28b. Do not use a Linux distribution's packaged SDK.
- Google Play requires an **AAB**, and AAB export requires the Gradle build: install the template with
  `--install-android-build-template` (or from the Project menu) and enable *Use Gradle Build*.
- Release builds must be signed with a non-debug keystore. Keystore and key passwords must currently
  match. CI can supply them through `GODOT_ANDROID_KEYSTORE_RELEASE_PATH`, `_USER` and `_PASSWORD`.
- 16 KB memory pages are supported out of the box since 4.5 (.NET projects need .NET 9+ for this).
- 4.7 made the Godot Android Build Environment (GABE) stable, which allows exporting from an Android
  device, and added splash-screen options in the Android export settings.

**iOS:** the export produces an Xcode project; building, signing and uploading happen on a Mac with
Xcode. C# on Android and iOS has been supported since 4.2 but is still labeled experimental.

**Touch input:** 4.7 adds a built-in `VirtualJoystick` node (Fixed, Dynamic and Following modes,
themeable). Use it before writing your own. Keep UI touch targets large and test on real devices.

## 4. Web

| Constraint | Detail |
|---|---|
| Renderer | Compatibility renderer only (WebGL 2). "Godot currently does not support WebGPU." Forward+ and Mobile do not run on the web. |
| C# | Godot 4 C# projects cannot be exported to the web. A web-first game should be GDScript. |
| Threads | Single-threaded export has been the default since 4.3. *Thread Support* needs `Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp` plus a secure context, or the PWA option *Enable Cross Origin Isolation Headers*, which installs a service worker that simulates them. |
| GDExtension | Needs *Extension Support*, cross-origin isolation, and extensions compiled for the web. |
| Audio | Default playback type on the web is *Sample* (low latency, no bus effects). *Stream* restores full audio features at higher latency: `audio/general/default_playback_type.web` or per player. |
| Hosting | Serve from a web server, not `file://`. Serve `.wasm` as `application/wasm`. |
| Compression | Compress `.wasm` and `.pck` (gzip brings the `.wasm` to about a quarter; Brotli precompression saves more). GitHub Pages gzips on the fly; itch.io does not. |
| Size | A custom export template with unused modules disabled shrinks the WebAssembly payload. |
| Mobile browsers | WebAssembly on phones is slow; native Android/iOS exports perform much better. Use feature tags to lower settings on the web. |

Headers for a threaded build on a host you control (Netlify or Cloudflare Pages `_headers` format):

```
/*
  Cross-Origin-Opener-Policy: same-origin
  Cross-Origin-Embedder-Policy: require-corp
```

Cross-origin isolation applies to everything the page embeds, which can break portal SDKs, ads and
analytics scripts. itch.io offers an opt-in SharedArrayBuffer checkbox in its embed options, but
community reports describe inconsistent results with threaded Godot builds. **Default to the
single-threaded export for portals and itch.io**; enable threads only when you control the headers
and have measured a gain.

Browser platform limits that shape design (from GameForge's web stack research, Nov 2026):

- Audio starts only after a user gesture: put a click or tap to start screen in front of the game.
- Pointer Lock is unavailable in iOS Safari; the Fullscreen API is unavailable on iPhone.
- Portal budgets: CrazyGames caps the initial download at 50 MB, and at 20 MB for its mobile
  homepage. Poki warns that players leave when loading takes more than about 10 seconds.
- Online play: browsers cannot open raw UDP sockets, so ENet does not work. Use
  `WebSocketMultiplayerPeer` or `WebRTCMultiplayerPeer`; architecture goes to `/gameforge:game-multiplayer`.

**When Godot is the wrong tool for a web game:** if the browser is the primary platform and you
need a very small download, WebGPU, deep DOM/JS integration or a mobile-web-first audience, a
web-native stack is usually a better fit. Route 3D to `/gameforge:game-threejs-specialist` and 2D to
`/gameforge:game-web2d-specialist`. Godot remains a strong choice when web is one target among
desktop and mobile builds of the same game.

## 5. Export checklist (copy into the milestone plan)

```markdown
## Godot export check -- [build name], Godot [4.7.2]
- [ ] Editor and export templates are the same version: [version]
- [ ] export_presets.cfg committed; export_credentials.cfg present locally or injected by CI
- [ ] Shader baker enabled for desktop and mobile presets
- [ ] Non-resource file filters cover: [*.json, *.csv, ...]
- [ ] No res:// writes; saves and settings under user://
- [ ] Exported build launched on: [Windows / macOS / Linux / Steam Deck / Android device / browser]
- [ ] Web: single-threaded unless headers are controlled; click-to-start screen; .wasm compressed
- [ ] Android: AAB signed with release keystore; tested on a low-end device
- [ ] Version string visible on the title screen: [x.y.z]
- [ ] Load time measured: [s] cold start on [device]
```
