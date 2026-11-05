# Phaser 4 Content Pipeline: Assets, Tilemaps, Scaling, Audio, Saves

Code type-checked against `phaser@4.2.1`; behavior notes come from the Phaser 4.2.1 source and
its bundled docs (checked 2026-11-05). Browser facts come from MDN browser-compat-data 8.1.8.

## 1. Preload scene (verified)

```ts
import Phaser from 'phaser';

export class Preload extends Phaser.Scene {
  constructor() { super('Preload'); }

  preload(): void {
    const bar = this.add.rectangle(240, 135, 0, 6, 0xf2c14e).setOrigin(0, 0.5);
    this.load.on(Phaser.Loader.Events.PROGRESS, (p: number) => (bar.width = 200 * p));
    this.load.setPath('assets/');
    this.load.atlas('sprites', 'atlases/sprites.png', 'atlases/sprites.json'); // JSON hash
    this.load.image('tiles', 'tilemaps/tiles-extruded.png');
    this.load.tilemapTiledJSON('level1', 'tilemaps/level1.json');
    this.load.audio('jump', ['audio/jump.webm', 'audio/jump.mp3']);   // Opus first, MP3 fallback
    this.load.audio('music', ['audio/theme.webm', 'audio/theme.mp3']);
  }

  create(): void {
    this.anims.create({
      key: 'hero-run',
      frames: this.anims.generateFrameNames('sprites', { prefix: 'hero/run_', start: 0, end: 5, zeroPad: 2 }),
      frameRate: 12,
      repeat: -1,
    });
    this.scene.start('Level');
  }
}
```

Relative paths plus `base: './'` in `vite.config.ts` keep the build working on itch.io, portal
CDNs and sub-paths. Assets in `public/` are copied as-is; do not import big binaries through JS.

## 2. Atlases and animations

- Pack sprites with TexturePacker or free-tex-packer (JSON hash), or export from Aseprite.
- Keep each atlas <= 2048x2048 for mobile; group by what draws together (player + FX, enemies
  of a level, UI) so a scene uses few textures and batches stay unbroken.
- Name frames `character/action_00`; `generateFrameNames` with `prefix` and `zeroPad` builds
  animations without hand lists.
- Aseprite: `this.load.aseprite('hero', 'hero.png', 'hero.json')` in Preload, then
  `this.anims.createFromAseprite('hero')` creates one animation per tag (verified API).
- Compressed textures (KTX2/Basis) need re-export with Y flipped for Phaser 4's GL orientation.

## 3. Tiled tilemaps (verified)

```ts
export class Level extends Phaser.Scene {
  constructor() { super('Level'); }

  create(): void {
    const map = this.make.tilemap({ key: 'level1' });
    // tileset name in Tiled, texture key, tile size, margin, spacing (extruded: margin 1, spacing 2)
    const tiles = map.addTilesetImage('tiles', 'tiles', 16, 16, 1, 2)!;
    map.createLayer('Background', tiles, 0, 0, true);       // TilemapGPULayer: static, fast, WebGL only
    const ground = map.createLayer('Ground', tiles, 0, 0)!;  // regular layer: tiles change at runtime
    ground.setCollisionByProperty({ collides: true });

    const spawn = map.findObject('Objects', (o) => o.name === 'PlayerSpawn');
    const hero = this.physics.add.sprite(spawn?.x ?? 32, spawn?.y ?? 32, 'sprites', 'hero/idle_00');
    hero.play('hero-run');
    this.physics.add.collider(hero, ground);

    this.physics.world.setBounds(0, 0, map.widthInPixels, map.heightInPixels);
    this.cameras.main.setBounds(0, 0, map.widthInPixels, map.heightInPixels).startFollow(hero, true, 0.15, 0.15);

    const startMusic = () => this.sound.play('music', { loop: true, volume: 0.5 });
    if (this.sound.locked) this.sound.once(Phaser.Sound.Events.UNLOCKED, startMusic);
    else startMusic();
  }
}
```

Tiled workflow rules:

- **Embed tilesets** in the map before exporting JSON. Phaser's Tiled parser warns "External
  tilesets unsupported. Use Embed Tileset and re-export".
- Mark solid tiles with a custom boolean property `collides`; spawn points, triggers and enemy
  paths go on an object layer (`Objects`).
- Extrude tilesets (`tile-extruder` or TexturePacker's extrude) to stop seams on regular layers;
  `TilemapGPULayer` renders seam-free on its own.
- `TilemapGPULayer` limits: one tileset image, orthographic maps only, up to 4096x4096 tiles;
  supports flips and tile animation; after edits call `generateLayerDataTexture()`. It shares the
  collision API with regular layers (`setCollisionByProperty` lives on the common base class).

## 4. LDtk

Phaser 4.2.1 has no LDtk parser. Options: use LDtk's "Super simple export" (layer PNGs plus
IntGrid CSV), vet a community loader, or convert the JSON yourself (type-checked sketch;
field names follow LDtk's JSON format, so check them against your LDtk version):

```ts
interface LdtkTile { px: [number, number]; t: number }
interface LdtkLayer { __identifier: string; __type: string; __gridSize: number; __cWid: number; __cHei: number; gridTiles: LdtkTile[]; autoLayerTiles: LdtkTile[] }
interface LdtkLevel { identifier: string; layerInstances: LdtkLayer[] | null }
interface LdtkProject { levels: LdtkLevel[] }

export function buildLdtkLevel(scene: Phaser.Scene, jsonKey: string, levelId: string, tilesetKey: string) {
  const project = scene.cache.json.get(jsonKey) as LdtkProject; // this.load.json(jsonKey, 'levels/world.ldtk')
  const level = project.levels.find((l) => l.identifier === levelId);
  if (!level?.layerInstances) throw new Error(`LDtk level ${levelId} not found`);
  const layers: Phaser.Tilemaps.TilemapLayer[] = [];
  for (const li of [...level.layerInstances].reverse()) { // LDtk lists top layer first
    const tiles = li.__type === 'Tiles' ? li.gridTiles : li.autoLayerTiles;
    if (!tiles.length) continue;
    const map = scene.make.tilemap({ tileWidth: li.__gridSize, tileHeight: li.__gridSize, width: li.__cWid, height: li.__cHei });
    const tileset = map.addTilesetImage(tilesetKey, tilesetKey, li.__gridSize, li.__gridSize)!;
    const layer = map.createBlankLayer(li.__identifier, tileset)!;
    for (const t of tiles) layer.putTileAt(t.t, t.px[0] / li.__gridSize, t.px[1] / li.__gridSize);
    layers.push(layer);
  }
  return layers;
}
```

Limits of the sketch: it ignores tile flips, stacked auto-layer tiles in one cell, and entities.
Read entities from `__type === 'Entities'` layers into spawn data yourself.

## 5. Pixel art, resolution and scaling

| Goal | Config |
|---|---|
| Pixel art, any window | `pixelArt: true`, base 480x270 or 320x180, `scale: { mode: Phaser.Scale.FIT, autoCenter: Phaser.Scale.CENTER_BOTH }` |
| Pixel-perfect (no shimmering) | `mode: Phaser.Scale.NONE` + integer zoom (below) |
| Pixel art scaled to non-integer sizes | `smoothPixelArt: true` (WebGL): blocky pixels, smoothed edges when scaled up |
| HD art | `pixelArt: false`, base 1280x720, `Scale.FIT` |

`pixelArt: true` sets nearest filtering, `antialias: false` and `roundPixels: true`. Without it,
Phaser 4's `roundPixels` defaults to `false` (it was `true` in v3); per-object control is
`vertexRoundMode` (`off`, `safe`, `safeAuto` default, `full`, `fullAuto`).

Integer zoom (verified):

```ts
export const integerScaleConfig: Phaser.Types.Core.ScaleConfig = {
  mode: Phaser.Scale.NONE,
  autoCenter: Phaser.Scale.CENTER_BOTH,
  width: TUNING.view.width,
  height: TUNING.view.height,
};

export function keepIntegerZoom(game: Phaser.Game): void {
  const apply = () => {
    const z = Math.max(1, Math.floor(Math.min(innerWidth / TUNING.view.width, innerHeight / TUNING.view.height)));
    game.scale.setZoom(z);
  };
  game.events.once(Phaser.Core.Events.READY, apply);
  addEventListener('resize', apply);
}
```

Mobile page shell:

```html
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
<style>
  html, body { margin: 0; height: 100%; background: #000; overflow: hidden; }
  #app { width: 100vw; height: 100dvh; } /* dvh: excludes mobile browser toolbars */
  canvas { touch-action: none; }
</style>
```

- No `screen.orientation.lock()` in Safari and no Fullscreen API on iPhone: show an HTML "rotate
  your device" overlay driven by `scene.scale.isPortrait` and `Phaser.Scale.Events.ORIENTATION_CHANGE`.
- HD text on a low-res canvas: `text.setResolution(2)`, or BitmapText (`this.load.bitmapFont`).
- Web fonts: `await document.fonts.load('16px "Your Font"')` before creating Text objects, or the
  first frame renders a fallback font. Self-host fonts; external font CDNs break portal rules.

## 6. Audio

- Phaser uses Web Audio when available and unlocks it on the first user gesture. Check
  `this.sound.locked` and wait for `Phaser.Sound.Events.UNLOCKED` before starting music.
- `this.sound.pauseOnBlur` is `true` by default (music pauses when the tab loses focus).
- Formats: list WebM/Opus first and MP3 second; Phaser picks the first the browser can play.
  WebM/Opus is consistent in Safari since 17.4; Safari 18.4 added Ogg Opus/Vorbis.
- Mute and volume settings live in the save; apply them in Boot with `this.sound.mute` /
  `this.sound.volume`.
- Portal ad breaks: pause with `this.sound.pauseAll()` and resume after the SDK callback.

## 7. Save data (verified)

```ts
const KEY = 'my-game:save';
const VERSION = 2;

export interface SaveData { version: number; bestScore: number; unlockedLevel: number; muted: boolean }
const DEFAULTS: SaveData = { version: VERSION, bestScore: 0, unlockedLevel: 1, muted: false };

/** localStorage can throw (Safari private mode, portal iframes, quota): never let it crash the game. */
export function loadSave(): SaveData {
  try {
    const raw = localStorage.getItem(KEY);
    if (!raw) return { ...DEFAULTS };
    return migrate({ ...DEFAULTS, ...(JSON.parse(raw) as Partial<SaveData>) });
  } catch {
    return { ...DEFAULTS };
  }
}

export function writeSave(data: SaveData): void {
  try {
    localStorage.setItem(KEY, JSON.stringify({ ...data, version: VERSION }));
  } catch {
    /* storage unavailable: keep playing with in-memory state */
  }
}

function migrate(d: SaveData): SaveData {
  if (d.version < 2) d.muted = false; // v1 had no audio setting
  d.version = VERSION;
  return d;
}
```

- Namespace the key per game: `localhost` and some hosts serve many games from one origin.
- Some portals require their SDK's data module instead of raw `localStorage`, and YouTube
  Playables caps saves at 3 MiB. Route to `game-web-publish` for portal specifics.
- Never trust saves for leaderboards; validate scores on a server (`game-multiplayer`).
