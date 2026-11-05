# Web Portals: CrazyGames, Poki, YouTube Playables, Newgrounds

Facts dated 2026-11-05. Sources: CrazyGames docs (technical requirements, SDK game and video-ads
modules), Poki for Developers (requirements and quality, HTML5 SDK), Google's YouTube Playables
certification requirements and SDK reference. Revenue terms come from secondary sources and are
labelled. Portals change rules often: re-read the linked docs before each submission and record
the date in the checklist.

## 1. One adapter interface for every portal

Gameplay code calls this interface only. Each target gets one implementation, selected at build
time (see `build-hardening.md`, section 1).

```ts
// src/platform/types.ts
export interface AdHooks {
  mute(): void; unmute(): void;          // master audio bus
  pauseInput(): void; resumeInput(): void;
}

export interface Platform {
  readonly name: string;
  init(): Promise<void>;                  // never throws; the game loads anyway
  loadingStart(): void;
  loadingFinished(): void;                // first frame can be shown, assets ready
  gameplayStart(): void;                  // first real input, level start, unpause
  gameplayStop(): void;                   // level end, game over, pause, menu
  commercialBreak(h: AdHooks): Promise<void>;     // interstitial at a natural break
  rewardedBreak(h: AdHooks): Promise<boolean>;    // true only if the reward is earned
  save(key: string, data: string): Promise<void>;
  load(key: string): Promise<string | null>;
  onPause(cb: () => void): void;          // platform-driven pause (Playables, ads)
  onResume(cb: () => void): void;
}
```

The web/itch implementation makes ads no-ops (`rewardedBreak` resolves `false` or grants the
reward directly if you have no ads), and wraps `localStorage` in try/catch.

Inject the portal's SDK script per build mode with a tiny Vite plugin, so other targets never
load it:

```ts
// vite.config.ts (excerpt)
const SDK_TAG: Record<string, string> = {
  poki: '<script src="https://game-cdn.poki.com/scripts/v2/poki-sdk.js"></script>',
  // crazygames: '<script src="<SDK v3 URL from docs.crazygames.com>"></script>',
  // playables:  '<script src="<SDK URL from the Playables SDK docs>"></script>',
};
export default defineConfig(({ mode }) => ({
  base: './',
  plugins: [{
    name: 'platform-sdk',
    transformIndexHtml: (html) => html.replace('<!--PLATFORM_SDK-->', SDK_TAG[mode] ?? ''),
  }],
}));
```

Put `<!--PLATFORM_SDK-->` in `<head>` before your game script. The CrazyGames and Playables script
URLs are left as placeholders because the pages read for this skill did not show them; copy them
from the current docs (UNVERIFIED here).

## 2. CrazyGames

### Requirements (docs.crazygames.com/requirements/technical, read 2026-11-05)

| Area | Rule |
|---|---|
| Initial download | ≤50 MB, measured up to the SDK `gameplayStart` event (total size is used if there is no SDK) |
| Mobile homepage | Initial download ≤20 MB to be eligible |
| Total | ≤250 MB and ≤1,500 files |
| External hosting | Allowed; QA checks time to gameplay, which must be ≤20 s |
| Paths | Relative only |
| Browsers | Must work on Chrome and Edge; games that work poorly on Safari are disabled there |
| Chromebooks | Disabled if not smooth on a 4 GB RAM device |
| Orientation | Landscape on desktop; portrait allowed with bars or a background |
| DPR | iOS and low-memory Android run at DPR 1 |
| iOS audio | Resume the `AudioContext` inside `touchend`/`click`; a visibility listener alone is insufficient. Howler and PlayCanvas have shown issues |
| Unity | Disabled on iOS by default (memory crashes); may be enabled later based on plays |
| CSS | `user-select: none` on `body` |
| Sitelock | If used, allowlist every crazygames.com origin plus the iOS and Android app origins |
| App | Must work in the CrazyGames app (fullscreen, safe-area padding) |

Launch tiers: **Basic Launch** requires the `gameplayStart` event and disables ads even if
integrated. **Full Launch** requires gameplay start/stop plus the Data and User modules where
applicable. Secondary sources describe an ad revenue share, invite-only IAP via Xsolla, a PEGI 12
content ceiling and no ban on AI-made games (UNVERIFIED in primary docs).

### SDK v3 calls

```ts
// src/platform/crazygames.ts
declare global { interface Window { CrazyGames: any } }
const sdk = () => window.CrazyGames.SDK;

function ad(type: 'midgame' | 'rewarded', h: AdHooks): Promise<boolean> {
  return new Promise((resolve) => {
    sdk().ad.requestAd(type, {
      adStarted: () => { h.mute(); h.pauseInput(); },
      adFinished: () => { h.unmute(); h.resumeInput(); resolve(true); },
      adError: (err: { code: string }) => {   // adsDisabled | unfilled | adblock | adCooldown | other
        h.unmute(); h.resumeInput(); resolve(false);
      },
    });
  });
}

const crazygames: Platform = {
  name: 'crazygames',
  async init() { try { await sdk().init(); } catch { /* continue without SDK */ } },
  loadingStart() { sdk().game.loadingStart(); },
  loadingFinished() { sdk().game.loadingStop(); },
  gameplayStart() { sdk().game.gameplayStart(); },
  gameplayStop() { sdk().game.gameplayStop(); },
  async commercialBreak(h) { await ad('midgame', h); },
  rewardedBreak(h) { return ad('rewarded', h); },   // grant reward only when true
  async save(k, v) { /* Data module; see Account Integration > Progress Save */ },
  async load(k) { return null; },
  onPause() {}, onResume() {},
};
export default crazygames;
```

- `init()` as `window.CrazyGames.SDK.init()` follows the SDK's module layout; the exact init call
  for plain HTML5 was not on the pages read (UNVERIFIED; check the SDK introduction).
- `happytime()` exists for special moments (a boss kill, a record). Use it sparingly.
- Call `gameplayStop` at every break: menus, pause, level end. Call `gameplayStart` on resume.
- `midgame` ads belong at natural breaks (death, level complete), never mid-action.

## 3. Poki

### Requirements (developers.poki.com/guide/requirements-quality, read 2026-11-05)

| Area | Rule |
|---|---|
| Loading | "Players tend to move to another game if loading takes more than 10 seconds." Keep the initial download small; load progressively. No numeric cap stated (an older page suggested about 8 MB, per secondary sources) |
| External requests | "Poki blocks all external requests by default." Bundle fonts, assets and libraries; exceptions only via their external-resources policy |
| Ads | Poki's SDK only; no other ad systems. Remove splash screens, outgoing links and branding (a studio logo on the loading screen is allowed) |
| Storage | Incognito restricts `localStorage`; wrap it in try/catch and stay playable |
| Ad blockers | Game must stay playable; no custom ad-block messages; no reward if a rewarded break is blocked |
| Devices | Desktop, mobile and tablet; on mobile fill the screen; on tablets use mobile controls |
| Aspect ratio | 16:9, scaling to cover the canvas; test at 640x360, 836x470 and 1031x580 |
| Debug | Remove all development tools, debug code and testing artifacts |
| Process | Upload to the Poki Inspector, test, then request review |

Commercial terms: Poki is curated; secondary sources describe a 50/50 split on Poki-sourced traffic
and a preference for web exclusivity (UNVERIFIED; read "How we partner with you" and the Terms,
dated 2024-03-13 on the page).

### SDK calls (in order)

```ts
// src/platform/poki.ts
declare const PokiSDK: any;

const poki: Platform = {
  name: 'poki',
  async init() { try { await PokiSDK.init(); } catch { /* "load your game anyway" */ } },
  loadingStart() {},
  loadingFinished() { PokiSDK.gameLoadingFinished(); },
  gameplayStart() { PokiSDK.gameplayStart(); },   // first one on the player's first click
  gameplayStop() { PokiSDK.gameplayStop(); },
  async commercialBreak(h) {
    await PokiSDK.commercialBreak(() => { h.mute(); h.pauseInput(); });
    h.unmute(); h.resumeInput();
  },
  async rewardedBreak(h) {
    const success: boolean = await PokiSDK.rewardedBreak(() => { h.mute(); h.pauseInput(); });
    h.unmute(); h.resumeInput();
    return success;                                // reward only when true
  },
  async save(k, v) { try { localStorage.setItem(k, v); } catch {} },
  async load(k) { try { return localStorage.getItem(k); } catch { return null; } },
  onPause() {}, onResume() {},
};
export default poki;
```

Call pattern around a level:

```ts
platform.gameplayStop();                 // level finished
await platform.commercialBreak(hooks);   // Poki decides whether an ad actually shows
platform.gameplayStart();                // player chose "next level"
```

- Poki recommends `commercialBreak()` before every `gameplayStart()` that follows a break.
- Tell the player before a rewarded break starts; a rewarded break resets the ad timer.
- `PokiSDK.shareableURL({...})` and `PokiSDK.getURLParam('id')` support share links;
  `PokiSDK.movePill(topPercent, topPx)` moves the mobile Poki pill (default `(0, 24)`).
- Prevent arrow keys, space and wheel from scrolling the page (snippet in `build-hardening.md`).

## 4. YouTube Playables

Access is program-based: you apply and work with a partner manager. Requirements below are the
certification "Stability and performance" MUSTs and SHOULDs (read 2026-11-05).

| Measure | MUST | SHOULD |
|---|---|---|
| Initial bundle (page load to `gameReady`) | <30 MiB | <15 MiB |
| Total bundle | <250 MiB (exceptions via FAQ) | Lazy-load what is not needed for interactivity |
| Single file | <30 MiB | <512 KiB |
| Files | ≤8,000 | |
| Saved game | <3 MiB | <500 KiB |
| Peak JS heap | ≤512 MB | |
| Load to interactive | | ≤5 s |
| Crashes | None consistently reproducible; must not crash the YouTube app or site | |

### SDK (`ytgame`)
- Load the SDK before any game code.
- `ytgame.game.firstFrameReady()` MUST be called before `ytgame.game.gameReady()`.
- `gameReady()` only when the game is interactable, never while a loading screen shows.
- Audio: initialize from `ytgame.system.isAudioEnabled()`, update on
  `ytgame.system.onAudioEnabledChange(cb)`.
- Lifecycle: `ytgame.system.onPause(cb)` / `onResume(cb)`; pause simulation and audio.
- Saves: `ytgame.game.saveData(string)` (≤3 MiB) and `ytgame.game.loadData()` (Promise<string>).
- Ads: `ytgame.ads.requestInterstitialAd()` and `ytgame.ads.requestRewardedAd(rewardId)`
  (Promise<boolean>).
- Also: `ytgame.system.getLanguage()`, `ytgame.engagement.sendScore(score)`,
  `ytgame.health.logError()` / `logWarning()`, `ytgame.IN_PLAYABLES_ENV`.

```ts
// src/platform/playables.ts (core lifecycle)
declare const ytgame: any;
const playables: Platform = {
  name: 'playables',
  async init() {},
  loadingStart() {},
  loadingFinished() { ytgame.game.gameReady(); },     // after firstFrameReady, when interactable
  gameplayStart() {}, gameplayStop() {},
  async commercialBreak(h) { h.mute(); await ytgame.ads.requestInterstitialAd(); h.unmute(); },
  async rewardedBreak(h) { h.mute(); const ok = await ytgame.ads.requestRewardedAd('extra-life'); h.unmute(); return ok; },
  save: (_k, v) => ytgame.game.saveData(v),           // one save blob; serialize all keys into it
  load: async () => (await ytgame.game.loadData()) || null,
  onPause: (cb) => ytgame.system.onPause(cb),
  onResume: (cb) => ytgame.system.onResume(cb),
};
// Call ytgame.game.firstFrameReady() right after the first rendered frame.
```

Whether Playables permit external network requests, and their monetization terms, were not covered
by the pages read for this skill (UNVERIFIED). Read the Integration, Monetization and Privacy
requirement pages before planning a backend.

## 5. Newgrounds

Status as of 2026-11-05: mostly UNVERIFIED in this pass.
- Upload HTML5 games as a ZIP through the Newgrounds portal submission; check current size limits.
- The Newgrounds.io API offers medals, scoreboards and cloud saves for integrated games.
- Policy: the Art Portal banned AI-generated art (June 2025 snapshot); the games-portal policy on
  AI content was not confirmed. Read the current submission guidelines before uploading AI art.
- Audience is long-standing web-game fans; expect blunt reviews and value polish.

## 6. Other portals

GameDistribution, Playgama and similar aggregators exist; they were not reviewed for this skill.
Treat any portal the same way: find its size limit, required SDK events, ad rules, external-request
policy, AI policy and revenue terms, then add an adapter and a checklist block.

## 7. Portal submission checklist block

Copy into `production/releases/web/<portal>-checklist.md` under "<target>-specific":

```markdown
- [ ] SDK script injected only in this build; adapter selected (`VITE_PLATFORM=<portal>`)
- [ ] loading-finished event at end of loading; gameplay start on first real input
- [ ] gameplay stop at every pause/menu/level end; start on resume
- [ ] Ads only at natural breaks; audio muted and input paused for the whole ad
- [ ] Rewarded: reward granted only on success; failure path tested (ad blocker on)
- [ ] No external requests (Poki) / only allowed hosts; no other ad or analytics SDKs
- [ ] Size: initial <= <limit>, total <= <limit>, files <= <limit> (build report)
- [ ] Devices: <portal's list>; Chromebook 4 GB smoothness (CrazyGames)
- [ ] Portal QA tool / inspector run: <date, result>
- [ ] AI-content answer in submission form: <answer>
```
