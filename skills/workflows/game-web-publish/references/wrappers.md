# Desktop and Mobile Wrappers

Facts dated 2026-11-05. Versions from npm registry metadata (queried
2026-11-05). Behavior from the Electron security tutorial, the steamworks.js README, Tauri docs
(start page and Linux graphics debugging page), Capacitor docs (v8) and Apple's App Store Review
Guidelines. Store submission itself (Steam store page, depots, review, app-store listings) belongs
to `game-launch`.

## 1. Which wrapper

| Wrapper | Version (2026-11) | Rendering | Pick it when | Watch out for |
|---|---|---|---|---|
| Electron | 45.2.3 (2026-11-04) | Bundled Chromium, identical on every OS | Steam release of a web game; you want one rendering engine everywhere | Download size (a full Chromium per app); security settings |
| Tauri 2 | CLI 2.12.4 (2026-10-21); 3.0 in alpha | System webview: WebView2 (Windows), WKWebView (macOS), WebKitGTK (Linux) | Small downloads, Rust comfort, simple 2D games | Three engines to test; documented Linux/NVIDIA WebKitGTK issues; WebGPU on WebKitGTK UNVERIFIED; Steamworks through Rust |
| NW.js | 0.119.2 (2026-10-23) | Bundled Chromium with Node in the page context | Legacy projects already on it | Node in the renderer is a large attack surface |
| Capacitor | 8.6.0 (2026-10-28); 9.0 in beta | iOS WKWebView, Android System WebView | iOS/Android store builds of a web game | Apple 4.2 and 2.5.2; IAP rules; WebView performance on low-end Android |

Default recommendation: **Electron for Steam, Capacitor for mobile**, unless download size is a
selling point and the game is simple enough to test on three webviews (then Tauri 2).

Public precedent: *Vampire Survivors* shipped its 1.0 as a Phaser game in a desktop wrapper (per
JSLegendDev's write-up on packaging JavaScript games for PC). It proves the route works; it does not
prove it is easy.

## 2. Electron

### Security baseline (Electron security tutorial)
Defaults you must not undo:
- `contextIsolation: true` (default since Electron 12), `sandbox: true` (default since 20),
  `nodeIntegration: false` for any content you did not write (default since 5).
- Do not disable `webSecurity`, do not enable `allowRunningInsecureContent` or experimental
  features.
- Prefer a custom protocol over `file://`, define a CSP, limit navigation and new windows,
  validate the `sender` of every IPC message, never pass untrusted content to `shell.openExternal`.
- Keep Electron current; check which fuses you can lock down.

### Minimal game shell

```js
// main.js
const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('node:path');

function createWindow() {
  const win = new BrowserWindow({
    width: 1280, height: 720, fullscreenable: true, backgroundColor: '#000000',
    webPreferences: { preload: path.join(__dirname, 'preload.js') }, // isolation + sandbox stay on
  });
  win.removeMenu();
  win.loadFile(path.join(__dirname, 'game', 'index.html')); // or a custom protocol handler
}
app.whenReady().then(createWindow);
app.on('window-all-closed', () => app.quit());
```

```js
// preload.js -- expose a narrow, typed surface; never the whole ipcRenderer
const { contextBridge, ipcRenderer } = require('electron');
contextBridge.exposeInMainWorld('steam', {
  unlock: (id) => ipcRenderer.invoke('steam:unlock', id),
  playerName: () => ipcRenderer.invoke('steam:name'),
});
```

Point the game's platform adapter (`portals.md`, section 1) at `window.steam` for a `desktop`
build mode.

### Steamworks from Electron
- **steamworks.js**: last npm release **0.4.0 (2024-08-06)**; the GitHub README is still the main
  documentation. Treat it as working but slow-moving; pin the version and test on every Electron
  upgrade.
- Its README says it "cannot be used by default in the renderer process" without
  `contextIsolation: false` and `nodeIntegration: true`. **Do not do that.** Initialize it in the
  main process and expose only what you need through IPC:

```js
// main.js (excerpt)
const steamworks = require('steamworks.js');
const client = steamworks.init(480);            // replace 480 (Spacewar test app) with your App ID
ipcMain.handle('steam:name', () => client.localplayer.getName());
ipcMain.handle('steam:unlock', (_e, id) => client.achievement.activate(String(id)));
// At the end of main.js, per the README, to enable the Steam overlay:
steamworks.electronEnableSteamOverlay();
```

- Production builds: copy the Steamworks redistributable binaries from
  `sdk/redistributable_bin/<platform>` into the root of the packaged app (README instruction).
- Method names above follow the README's API at the time of writing; confirm against the version
  you install.
- Alternative: `steamworks-ffi-node` 0.11.3 (2026-09-24) exists; its maturity is UNVERIFIED.
  greenworks is described by the steamworks.js README as no longer maintained.

### Packaging
- Use Electron Forge or electron-builder; produce Windows x64 first, then Linux and macOS.
- macOS needs signing and notarization; Windows signing avoids SmartScreen warnings.
- Test the Steam overlay, achievements and controller input on the packaged build, on a Steam
  Deck if you claim Deck support. Store-side Deck review routes to `game-launch`.

## 3. Tauri 2

- A minimal app can be under 600 KB because it uses the system webview instead of bundling one
  (Tauri's claim).
- Test the game on WebView2, WKWebView and WebKitGTK separately: audio latency, WebGL 2
  performance and gamepad support differ. Tauri documents Linux graphics problems (notably NVIDIA
  with WebKitGTK) and workarounds on its "Linux graphics" debugging page.
- Steamworks integration means Rust code (a Steamworks Rust binding) exposed as Tauri commands.
- Do not use Tauri 3 alpha for a release.

## 4. NW.js

- Chromium and Node share the page context, which is convenient and unsafe for any remote content.
- Only choose it to maintain an existing NW.js project; new projects should use Electron.

## 5. Capacitor (iOS and Android)

### Setup

```bash
npm i @capacitor/core
npm i -D @capacitor/cli
npx cap init "Ember Drift" com.example.emberdrift --web-dir dist/mobile
npm run build:mobile          # a Vite mode with mobile adapter, no portal SDKs
npx cap add ios
npx cap add android
npx cap sync                  # copy dist/mobile into the native projects
```

```ts
// capacitor.config.ts
import type { CapacitorConfig } from '@capacitor/cli';
const config: CapacitorConfig = {
  appId: 'com.example.emberdrift',
  appName: 'Ember Drift',
  webDir: 'dist/mobile',
  // Never ship `server.url`: it is for live reload in development. A release that loads its game
  // from a remote URL is a repackaged website and downloads code (Apple 4.2 and 2.5.2 risk).
};
export default config;
```

### Apple App Store Review Guidelines (quoted, read 2026-11-05)
- **4.2 Minimum Functionality**: "Your app should include features, content, and UI that elevate
  it beyond a repackaged website." A web game in a WebView passes when it is a complete,
  app-like game: offline-capable, native-feeling input, no browser chrome, no external links out.
- **2.5.2**: apps "may not download, install, or execute code which introduces or changes features
  or functionality of the app". Bundle the whole game; ship content updates as data, or as an app
  update. In March 2026 Apple blocked updates of the Replit and Vibecode apps under 2.5.2 (Heise);
  an in-app game *maker* that runs generated code is high risk.
- **4.7** allows apps to offer HTML5/JavaScript mini apps and mini games that are not embedded in
  the binary, but the app is responsible for all of it, and 4.7.2 forbids exposing native APIs to
  that software without Apple's permission. This is for platforms hosting many games, not for
  shipping your own game.
- **3.1.1**: unlocking features "(by way of example: subscriptions, in-game currencies, game
  levels, access to premium content, or unlocking a full version), you must use in-app purchase."
  The US storefront is exempt from the ban on buttons and external links to other purchase methods
  (3.1.1(a), 3.1.3). Elsewhere, no links to outside purchases.

### Google Play
- Google Play's AI-Generated Content policy covers generative features (no offensive or deceptive
  output); no labelling mandate was found (Play Console Help, read 2026-11-05).
- Digital goods normally go through Google Play Billing; check current regional exceptions before
  designing payments (UNVERIFIED for 2026 specifics).

### Mobile wrapper checklist block
```markdown
- [ ] Game bundled in the binary; no `server.url`; no remote code
- [ ] Works offline after install; no browser UI, no outbound links in the game
- [ ] Safe areas handled (`env(safe-area-inset-*)`), orientation locked natively
- [ ] Audio resumes after interruptions (calls, backgrounding) on a real iPhone
- [ ] Purchases via StoreKit / Play Billing plugin; validated server-side
- [ ] Tested on a low-end Android device for WebView performance
- [ ] Store listing, ratings and AI questions handed to /gameforge:game-launch
```
