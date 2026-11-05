# Self-Hosting, Headers and PWA

Facts dated 2026-11-05. Sources: Cloudflare Pages limits page, Godot 4.7 web export docs (host
compression notes), Vite build guide, npm registry metadata queried 2026-11-05
(`vite-plugin-pwa` 2.0.0, 2026-10-03, supports Vite 8). Host config syntax beyond what is cited is
standard, long-stable configuration; still test every header after deploy.

## 1. Choosing a host

| Host | Strengths | Limits and caveats |
|---|---|---|
| Cloudflare Pages | Free tier, global CDN, `_headers` file, automatic compression | Free: 20,000 files per site, 25 MiB per file, 500 builds/month; `_headers` up to 100 rules. Cloudflare points large fleets (>100 sites) to Workers Static Assets |
| Cloudflare Workers (static assets) | Static files plus server code (and Durable Objects for multiplayer) in one deploy | Configure assets directory in `wrangler.jsonc`; same account as your realtime backend |
| Netlify | `_headers` or `netlify.toml`, deploy previews | Check current free-tier bandwidth before a launch spike |
| Vercel | `vercel.json` headers, previews | Check current free-tier and commercial-use terms |
| GitHub Pages | Free with the repo, on-the-fly compression | **No custom headers**, so no COOP/COEP; use a single-threaded build or a service-worker isolation shim |
| itch.io | Players and community included | See `itch-io.md`; not a general web host |

Rules of thumb:
- Own a domain for anything you want online in five years. Free subdomains and jam hosts rot.
- Keep the game static. If a backend is needed (leaderboards, multiplayer), the game should still
  start and be playable when the backend is down.
- Put the version in the page (`<meta name="version">` or the settings menu) to debug caching.

## 2. Header files per host

Vite copies everything in `public/` into the build output, so keep host config files in `public/`.

### Cloudflare Pages and Netlify: `public/_headers`

```
/assets/*
  Cache-Control: public, max-age=31536000, immutable

/index.html
  Cache-Control: no-cache

/*.wasm
  Content-Type: application/wasm
```

Threaded builds only, add:

```
/*
  Cross-Origin-Opener-Policy: same-origin
  Cross-Origin-Embedder-Policy: require-corp
```

Deploy to Cloudflare Pages from the CLI with `npx wrangler pages deploy dist/web`, or connect the
repo in the dashboard. Automating deploys belongs to `game-ci-pipeline`.

### Netlify: `netlify.toml` (alternative to `_headers`)

```toml
[build]
  command = "npm run build:web"
  publish = "dist/web"

[[headers]]
  for = "/assets/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "/index.html"
  [headers.values]
    Cache-Control = "no-cache"
```

### Vercel: `vercel.json`

```json
{
  "buildCommand": "npm run build:web",
  "outputDirectory": "dist/web",
  "headers": [
    {
      "source": "/assets/(.*)",
      "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }]
    },
    {
      "source": "/(.*)",
      "headers": [
        { "key": "Cross-Origin-Opener-Policy", "value": "same-origin" },
        { "key": "Cross-Origin-Embedder-Policy", "value": "require-corp" }
      ]
    }
  ]
}
```

Drop the second block if the build is single-threaded.

### GitHub Pages
- No way to set response headers. For threaded builds, either:
  - export Godot with the PWA option that ensures cross-origin isolation headers via a service
    worker, or
  - add a COI service-worker shim (for example the open-source `coi-serviceworker` script), which
    reloads the page once under a service worker that adds the headers.
- Project sites live at `https://<user>.github.io/<repo>/`; `base: './'` handles the subpath.
- Godot's docs note GitHub Pages compresses on the fly.

## 3. Verifying a deploy

1. Open the site in a private window with DevTools > Network, "Disable cache" on.
2. Check `index.html` response headers (cache, COOP/COEP if threaded).
3. Check a hashed asset: `Cache-Control` immutable, `Content-Encoding: br` or `gzip`.
4. Check `.wasm` has `Content-Type: application/wasm`.
5. Console: `self.crossOriginIsolated` (threaded builds must be `true`).
6. Deploy a trivial change and confirm returning players get it (no stale `index.html`).

## 4. PWA: installable and offline

A PWA lets players install the game to the home screen or desktop and play offline. It suits
single-player games with modest asset sizes. Use `vite-plugin-pwa` (2.0.0 supports Vite 8).

```ts
// vite.config.ts (excerpt)
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig(({ mode }) => ({
  base: './',
  plugins: [
    mode === 'web' && VitePWA({
      registerType: 'prompt',            // ask before swapping versions; never reload mid-run
      includeAssets: ['icons/*.png'],
      manifest: {
        name: 'Ember Drift',
        short_name: 'Ember Drift',
        display: 'fullscreen',           // or 'standalone' if you need browser UI
        orientation: 'landscape',
        background_color: '#101014',
        theme_color: '#101014',
        start_url: '.',
        icons: [
          { src: 'icons/icon-192.png', sizes: '192x192', type: 'image/png' },
          { src: 'icons/icon-512.png', sizes: '512x512', type: 'image/png' },
          { src: 'icons/icon-512-maskable.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
        ],
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,wasm,png,webp,ktx2,glb,ogg,mp3,json}'],
        // Workbox skips precaching files above its size limit (2 MiB by default).
        // Raise it for engine .wasm/.pck files, or runtime-cache large assets instead.
        maximumFileSizeToCacheInBytes: 40 * 1024 * 1024,
      },
    }),
  ].filter(Boolean),
}));
```

Guidance:
- Only the `web` (own domain) target gets a service worker. Portals and embeds manage their own
  caching, and a stray service worker on a portal origin causes stale-build bugs.
- **Precache** the core (engine, menu, first level). **Runtime-cache** later levels with a
  cache-first strategy so the first visit stays light.
- **Updates**: with `registerType: 'prompt'`, show "Update available, restart?" on the title
  screen, never during a run.
- **Save data**: call `navigator.storage.persist()` after the player has invested time; browsers
  may evict storage for sites that are not persisted. Offer export/import of saves.
- **iOS**: installed web apps work via Add to Home Screen; storage eviction and feature support
  differ from desktop Chrome. Test the installed app on a real iPhone (specific iOS limits are
  UNVERIFIED in this pass).
- Test offline: DevTools > Application > Service Workers > Offline, then reload and play.

## 5. Custom domain checklist

```markdown
- [ ] Domain registered for multiple years, auto-renew on, registrar 2FA on
- [ ] HTTPS enforced; HTTP redirects to HTTPS
- [ ] Apex and www resolve to the same build
- [ ] Cache headers verified (immutable assets, no-cache index.html)
- [ ] COOP/COEP verified only if threaded; third-party scripts still load
- [ ] 404 page links back to the game
- [ ] Open Graph tags (title, description, 1200x630 image) for link previews
- [ ] Privacy notice linked if analytics or accounts exist
- [ ] Version string visible in game; old builds cleared from CDN cache after deploy
```
