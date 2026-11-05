# [YOUR GAME NAME] -- 2D Web Game (Phaser 4)

Project instructions for Claude Code. Copy this file to your game's root as `CLAUDE.md` (or
append it to an existing one) and replace the `[BRACKETED]` placeholders. Versions below were
current and verified together on 2026-11-05; change them only on purpose. Using PixiJS, Kaplay,
Excalibur or LittleJS instead? Keep the rules, swap the stack table (see the end of this file).

- **Game**: [NAME] -- [ONE SENTENCE: what the player does and why it is fun]
- **Art**: [pixel art at 480x270 / HD at 1280x720] | **Targets**: desktop + mobile browsers
- **Distribution**: [itch.io / CrazyGames / Poki / YouTube Playables / own domain]
- **Engine id for GameForge**: `phaser` (or `pixi`, `kaplay`, `excalibur`)

## Commands (a task is not done until these pass)

```bash
npm run dev            # Vite dev server
npx tsc --noEmit       # type-check
npm run build          # tsc --noEmit && vite build  -> dist/
npm run preview        # serve dist/ (what players get)
npm test               # Playwright: builds, previews, runs tests/*.spec.ts
npx playwright test --update-snapshots   # only when a visual change is intended; review diffs first
```

`package.json` scripts: `"dev": "vite"`, `"build": "tsc --noEmit && vite build"`,
`"preview": "vite preview"`, `"test": "playwright test"`. Node 20.19+ or 22.12+ (Vite 8).

## Stack (pinned with --save-exact; do not upgrade without asking)

| Package | Version | Note |
|---|---|---|
| `phaser` | 4.2.1 | MIT. WebGL renderer; Arcade physics; `import Phaser from 'phaser'` |
| `vite` | 8.3.6 | `base: './'`, `build.assetsInlineLimit: 0` |
| `typescript` | 7.0.2 | `strict: true`, `noUncheckedIndexedAccess: true` |
| `@playwright/test` | 1.64.1 | Verification loop |

Phaser 4.2.1 ships version-matched docs for agents inside the package:
`node_modules/phaser/skills/<topic>/SKILL.md` (scenes, physics-arcade, tilemaps,
filters-and-postfx, scale-and-responsive, v3-to-v4-migration, and more) and
`node_modules/phaser/changelog/v4/4.0/MIGRATION-GUIDE.md`. Read the relevant one before writing
Phaser code; most Phaser code online is Phaser 3.

## Folder layout

```
index.html                 # <div id="app"> sized 100vw x 100dvh, viewport-fit=cover
vite.config.ts
src/
  main.ts                  # Phaser.Game config only
  tuning.ts                # every gameplay number
  save.ts                  # versioned localStorage wrapper (try/catch)
  testHooks.ts             # render_game_to_text, advanceTime
  scenes/                  # Boot, Preload, Menu, Game, Hud, GameOver
  objects/                 # Player.ts, Enemy.ts (extend Phaser.Physics.Arcade.Sprite)
  systems/                 # spawner, scoring: plain TS, no rendering
public/assets/             # atlases/, tilemaps/, audio/, fonts/ (optimized, runtime)
assets-src/                # .aseprite, .tps, .tmx/.ldtk sources (Git LFS for large binaries)
tests/                     # Playwright specs and screenshot baselines
docs/architecture/         # decision records
production/session-state/  # active.md: current focus and next steps (GameForge)
```

Never edit `dist/` or `node_modules/` (GameForge's hooks block it); change sources and rebuild.

## Coding rules

**Phaser 4, not Phaser 3.**
- `type: Phaser.WEBGL` (the Canvas renderer is deprecated).
- Effects are Filters: `obj.enableFilters(); obj.filters!.internal.addGlow(...)`; cameras have
  `filters` already. No `preFX`, `postFX`, `BitmapMask`, `setPipeline`, custom pipelines.
- `setTint(c).setTintMode(Phaser.TintModes.FILL)` instead of `setTintFill`; `setLighting(true)`
  instead of `setPipeline('Light2D')`; `Phaser.Math.Vector2` instead of `Geom.Point`;
  `Math.TAU` is now 2*pi (`Math.PI_OVER_2` for pi/2); native `Set`/`Map` instead of `Phaser.Struct`.
- No raw `gl` calls; use an `Extern` object if you truly need WebGL.

**Scenes.** Boot -> Preload -> Menu -> Game (+ Hud launched in parallel) -> GameOver. One job per
scene. Pass data with `scene.start(key, data)` / `init(data)`; share state through
`this.registry`, not by reading another scene's fields. Remove listeners on `SHUTDOWN`.

**Frame-rate independence.**
- Arcade physics: `fixedStep: true`, `fps: 60` (the defaults). Keep them.
- Movement through velocities and physics, not `x += n` per frame. Anything manual scales by
  `delta`. Timers use `this.time` events or accumulated `delta`, never frame counts.
- Coyote time, jump buffer and similar windows are milliseconds in `tuning.ts`.

**Data-driven tuning.** Every gameplay number lives in `src/tuning.ts`; scenes and objects import
it. Balance commits touch only that file.

**Randomness.** Seed Phaser's RNG with `seed: [String(seed)]` in the game config from `?seed=N`
and use `Phaser.Math.RND`; no `Math.random()` in gameplay.

**Performance.** Pools via `physics.add.group({ classType, maxSize })` + `get()`; no `new` in
`update()`. Colliders between groups. Static level geometry in static groups or tilemap
collision. Bake static `Graphics` with `generateTexture()`. Update text only on change.

**Resolution.** Base resolution [480x270], `scale: { mode: Phaser.Scale.FIT, autoCenter:
Phaser.Scale.CENTER_BOTH }`, `pixelArt: true` for pixel art (Phaser 4's `roundPixels` default is
`false` otherwise). Rotate prompt instead of orientation lock (none in Safari).

**Input.** Keyboard via `createCursorKeys()` / `addKeys()` and `JustDown`; gamepad needs
`input: { gamepad: true }`; touch buttons at least ~44 CSS px; no reliance on hover, pointer
lock, or fullscreen on iPhone.

**Audio.** `this.load.audio(key, ['x.webm', 'x.mp3'])`. Start music only after
`Phaser.Sound.Events.UNLOCKED` when `this.sound.locked`. Pause on ads and tab hide.

**Saves.** Only through `src/save.ts`: namespaced key, `version` field with migration, every
`localStorage` call in try/catch (private mode and portal iframes throw).

## Asset rules

- Sprites in texture atlases (TexturePacker or free-tex-packer JSON hash, or Aseprite export),
  each <= 2048x2048; group by what draws together. No loose PNG per sprite.
- Tiled maps: embed tilesets before exporting JSON (Phaser does not load external tilesets);
  solid tiles carry a `collides` property; spawns and triggers on an `Objects` layer; extrude
  tilesets by 1 px. Large static layers: `map.createLayer(name, tiles, 0, 0, true)` (GPU layer).
- LDtk: no built-in Phaser parser; convert via a small loader in `src/systems/`.
- Audio: Opus in `.webm` plus `.mp3`; mono SFX; short music loops.
- Placeholder art from `Graphics#generateTexture` so mechanics can be built before final art.
- Files >= 20 MB go through Git LFS (GameForge's commit hook blocks them otherwise).
- AI-generated assets: record tool, date, prompt and license in `docs/asset-log.md` (run
  `/gameforge:game-ai-assets`). No ripped or decompiled assets from existing games.
- Everything loads from this origin: no runtime CDN requests (Poki forbids external requests).

## Verification loop (for AI agents)

1. Run `npm ls phaser` before writing code; write for the installed major version.
2. One scene, mechanic or fix per change. Name the check it must pass before starting.
3. After each change: `npx tsc --noEmit` -> `npm run build` -> `npm test` -> open the newest
   screenshot in `test-results/` and describe what it shows -> one line in `progress.md`.
4. Test contract (dev, or `?test=1` in production builds):
   - `window.render_game_to_text()` returns JSON: scene, player x/y, grounded, HP, score, enemies.
   - `window.advanceTime(ms)` steps the game: in test mode `game.loop.sleep()` on `ready`, then
     `game.step(t, 1000 / 60)` per step.
   - `?seed=N` seeds `Phaser.Math.RND`; `?debug` turns on Arcade debug and the tuning panel.
5. Playwright fails on any console error. Fix the first new error first. Test whole chains
   (jump -> stomp enemy -> score +10), not single functions.
6. Before a milestone: play the production build on a real mid-range Android phone and an iPhone,
   and fill the portal-readiness checklist from `/gameforge:game-web2d-specialist`.
7. Split any scene over ~400 lines into objects and systems before adding features.

## Commits

Format: `type(scope): summary` in the imperative, under 100 characters. Matches GameForge's
`"commit_convention": "conventional"` in `.gameforge/project.json`.

| Type | Use |
|---|---|
| `feat` | New mechanic, scene or feature |
| `fix` | Bug fix |
| `balance` | Tuning values only (`src/tuning.ts`) |
| `art` / `audio` | Sprites, atlases, tilesets; music and SFX |
| `design` / `level` | Design docs; tilemaps and level content |
| `ui` | HUD, menus, touch controls |
| `perf` | Performance work (state the measured gain) |
| `refactor` / `test` | Restructure without behavior change; tests |
| `chore` / `docs` | Tooling, dependencies, CI; documentation |

Examples: `feat(player): add wall jump`, `balance(slime): raise patrol speed from 40 to 48`,
`level(world1): add secret room to 1-3`, `perf(render): move background to TilemapGPULayer`.

## GameForge skills

Run `/gameforge:game-start` once to create `.gameforge/project.json` (engine `phaser`).

| I need to... | Run |
|---|---|
| Phaser, PixiJS, Kaplay, Excalibur or LittleJS help; Phaser 3 -> 4 migration | `/gameforge:game-web2d-specialist` |
| Build features fast with an agent: prompt, play, verify, commit | `/gameforge:game-vibe-code` |
| Generate or clean up AI sprites, tiles, music, SFX (with provenance) | `/gameforge:game-ai-assets` |
| Multiplayer: rooms, netcode, server authority | `/gameforge:game-multiplayer` |
| Ship to itch.io, portals, Discord, YouTube Playables, PWA, desktop | `/gameforge:game-web-publish` |
| Mechanics, systems, balance | `/gameforge:game-designer`, `/gameforge:game-balance-check` |
| Review code before merging | `/gameforge:game-code-review` |
| Automated builds and deploys | `/gameforge:game-ci-pipeline` |
| Playtest and feedback | `/gameforge:game-playtest` |
| 48-72 hour jam plan | `/gameforge:game-jam-mode` |
| 3D instead | `/gameforge:game-threejs-specialist` |
| Not sure where to start | `/gameforge:game-help` |

## Other 2D stacks (swap the stack table)

| Stack | Pin | Differences from the rules above |
|---|---|---|
| PixiJS | `pixi.js` 8.22.0 (+ `@pixi/sound` 6.0.2) | `await app.init({...})`; WebGL default (`preference: 'webgpu'` to opt in); write your own fixed-step accumulator, scenes and physics |
| Kaplay | `kaplay` 3001.0.19 | `kaplay({ global: false })`; fixed logic in `onFixedUpdate`; not `kaboom`, not the 4000 alpha |
| Excalibur | `excalibur` 0.32.0 | `fixedUpdateFps: 60`; pre-1.0, read release notes on every bump |
| LittleJS | `littlejsengine` 1.29.1 | Fixed 60 Hz updates; `setEngineManualStep(true)` + `engineStep(n)` for tests |
