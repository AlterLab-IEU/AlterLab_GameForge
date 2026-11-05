# Jam and Portal Checklist

Read this before entering an AI-friendly jam or targeting a web portal. Rules were checked on
5 Nov 2026 (the Vibe Jam page was re-read that day; portal limits come from each portal's docs as
cited in the GameForge research briefs). Rules change every edition; re-read the live page before
you start. Schedule and theme work belong to `game-jam-mode`; packaging and uploads to
`game-web-publish`.

## Cursor Vibe Jam 2026 (closed; template for the next edition)

Organized by Pieter Levels, with @s13k_ as co-host and lead judge. Ran 1 Apr 2026 to
1 May 2026, 13:37 UTC. Sponsors: Cursor (title), Bolt.new, Glif, Tripo AI.

- [ ] **At least 90% of the code written by AI.** Keep `docs/iteration-log.md` as your record.
      (The 2025 edition required at least 80% of code and assets.)
- [ ] **Web, free, no login or signup.** A username prompt is fine.
- [ ] **No loading screens and no heavy downloads.** The rules page puts it as "NO loading screens
      and heavy downloads (!!!)". Budget for near-instant first input.
- [ ] **One domain**, ideally your own domain or subdomain, so entries can be tracked.
- [ ] **Widget script in your HTML or you are disqualified:**
      `<script async src="https://vibejam.com/2026/widget.js"></script>`
      Add it to `index.html`; confirm it is still in `dist/index.html` after `npm run build`.
- [ ] **New game.** Games that existed before the start date were not eligible.
- [ ] **One entry per person.**
- [ ] **Optional portal webring.** An exit portal sends players to
      `https://vibejam.com/portal/2026` with `username`, `color`, `speed` and `ref` (the URL of
      your game) as query parameters; the redirector adds `portal=true`. When your game loads with
      `?portal=true`, show a return portal that sends players back to `ref`.
- [ ] **Any engine; Three.js recommended. Multiplayer preferred but not required.**

Scale and prizes: 945 games and 242,212 players (the organizer's X post, 1 May 2026); $25k,
$10k and $5k for the top three plus twelve $1k special awards. 2026 winners: *A Game About
Capybaras Delivering Food* (Gold), *Fanto's Mega-Mart*, *WenWare* (also Most Played).

Calibrate expectations: judge Tim Soret rated the best 2026 entries at "3rd year student" level
(levels.io, 17 Jun 2026). A jam entry is a showcase of a hook, not a finished product.

## What the 2026 winners and guides did

- **Scope:** about 5 to 10 minutes of play (Gold winner, per Wccftech, 13 Jul 2026).
- **Human time:** mostly brainstorming, planning and playing; the 3D map was built by hand in an
  editor; 2 to 3 parallel Claude Code sessions on separate subsystems.
- **Multiplayer:** the winner found it "simpler than expected for a jam" with one Cloudflare
  WebSocket lobby.
- **From vendor guides:** one hook a player understands in about 5 seconds, one mechanic per
  prompt, near-instant load, and testing in a fresh browser (the harness uses a fresh browser
  context per scenario for this reason).

## Other AI-era jams

| Jam | When | Key rules | Route |
|---|---|---|---|
| Epic AI MegaJam | 12-15 Nov 2026 | Unreal Engine or UEFN; $65k in prizes plus up to $50k in grants; coding agents unlimited but AI optional; Epic's prep guide says to set up coding agents and MCP tools before the start | `game-unreal-specialist` (UE 5.8's Unreal MCP is experimental, editor-only, loopback-only, unauthenticated) plus `game-jam-mode` |
| Reddit x Phaser "Games with a Hook" | Jun-Jul 2026 | Devvit Web with a Phaser template; Reddit explicitly rejected "obvious AI slop" | `game-web2d-specialist` |

## Hosting: keep it static

A secondary analysis of Vibe Jam entries found 42% of 2025 entries and 13% of 2026 entries already
offline, with backend-dependent games dying fastest and static hosting surviving best. Ship a static
build that works with no server; make any backend (leaderboards, lobbies) optional and degrade
gracefully when it is gone.

## Portal limits

| Portal | Initial download | Total | Other hard requirements |
|---|---|---|---|
| CrazyGames | 50 MB or less up to the gameplay-start event; **20 MB or less for the mobile homepage** | 250 MB and 1,500 files | Chrome and Edge; must be smooth on 4 GB Chromebooks; ads only through their SDK; fire the `gameplayStart` event; externally hosted games must reach gameplay within 20 s; DPR is forced to 1 on iOS; PEGI 12; in-app purchases are invite-only via Xsolla |
| Poki (curated) | No numeric cap on the current requirements page; an older page said under 8 MB; players leave after about 10 s of loading | Not stated | Desktop, mobile and tablet; 16:9; storage that survives incognito; no external requests; works with ad blockers; no other ad SDKs; no debug code; `gameplayStart()` on first input; 50/50 revenue share on Poki-sourced traffic, web-exclusive preferred |
| YouTube Playables | Under 30 MiB (should be under 15 MiB) | Under 250 MiB; each file under 30 MiB | Saves under 3 MiB; JS heap capped at 512 MB |
| itch.io | Upload a ZIP with `index.html` at its root | About 500 MB (unverified) | Toggle SharedArrayBuffer support if you use threads; generative-AI disclosure |

Run `node tests/budget.mjs <initialMB> <totalMB> <maxFiles>` with the target's numbers (script in
`vibe-debt-controls.md`). Portal SDK integration (CrazyGames, Poki, YouTube Playables) goes
through `game-web-publish`.

## Web checks every target needs

- [ ] Audio unlocks on the first tap or key (iOS requires resuming the `AudioContext` from a user
      gesture; Firefox blocks Web Audio until sticky activation).
- [ ] Plays on a mid-range Android phone, not only on a flagship.
- [ ] Touch controls exist if mobile is a target. Pointer Lock is unavailable in iOS Safari and the
      Fullscreen API is unavailable on iPhone.
- [ ] Works in a fresh browser profile with no cache, storage or extensions.
- [ ] `base: './'` in `vite.config.ts`, so the build works from any subpath.
- [ ] Title, controls and restart reachable without reading a manual.
- [ ] The upload is the release build (`npm run build`), never the test build, so it carries no
      test hooks, debug overlay or tuning panel (Poki rejects debug code).
- [ ] Credits and AI disclosure text ready (see `originality-and-disclosure.md`).

## Combined pre-submission checklist

```markdown
## Submission: <game> to <jam or portal> -- <YYYY-MM-DD>
- [ ] Rules re-read on the live page today; edition-specific items (widget, portal URL) updated
- [ ] npm run verify: <N/N pass>, screenshots opened
- [ ] npm run debt: no flags · npm run licenses: allowlist clean
- [ ] npm run budget -- <initial> <total> <files>: <initial MB / total MB / file count>
- [ ] Tested on: desktop Chrome, Safari or WebKit, mid-range Android phone (<model>)
- [ ] Fresh-profile load to first input: <seconds>
- [ ] Originality distance test passed; asset log complete
- [ ] AI disclosure written for this platform
- [ ] Static hosting live at <URL>; backend optional
- [ ] Commit tagged <v1.0-jam>
```
