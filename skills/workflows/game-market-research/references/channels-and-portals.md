# Channels as Markets: Steam, Web Portals and Platform Niches

A game's market is partly its genre and partly where it is sold or played. In 2026 a large share of
new indie and jam games ship on the web first, often built with coding agents. Each channel has its
own audience, technical gate and money model. Research the channel as seriously as the genre.

Facts below are as of 2026-11-05 from platform documentation and press; re-check requirements on the
platform's own developer pages before relying on them. For shipping mechanics (builds, SDKs, size
budgets), route to `/gameforge:game-web-publish`.

---

## Channel matrix

| Channel | Audience and curation | Technical gate (summary) | Money model | Research it by |
|---|---|---|---|---|
| **Steam** (desktop, including web-tech games wrapped in Electron) | Huge, crowded (about 19,000 releases in 2025); algorithmic discovery driven by wishlists, reviews and festivals | Steam Direct fee; review can take up to 12 business days (Nov 2026) | Premium sales, DLC, F2P; 30/25/20% store cut | Tag pages, SteamDB, Gamalytic or VG Insights, Next Fest results |
| **itch.io** | Jams, experimental and niche games; flooded with AI uploads in autumn 2026, cleanup on 2026-11-03 | HTML ZIP with `index.html`; generative-AI disclosure; "no AI" filter in search | Paid, pay-what-you-want, donations | Jam pages, collections, "popular" by tag, creator coverage |
| **Poki** (curated web portal) | Large casual web audience, many young players | Desktop, mobile and tablet; incognito-safe storage; no external requests or third-party ad SDKs; works with ad blockers; small download (players leave if loading takes more than about 10 seconds) | 50/50 revenue share on Poki-sourced traffic; web exclusivity preferred | Poki developer docs; top and new lists by category |
| **CrazyGames** | Large web portal; PEGI 12 content rules | Initial download 50 MB or less, **20 MB or less for the mobile homepage**; 250 MB and 1,500 files total; smooth on 4 GB Chromebooks; SDK-only ads; `gameplayStart` event | Ad revenue share; in-app purchases invite-only (via Xsolla) | CrazyGames developer docs; category charts |
| **YouTube Playables** | YouTube viewers, curated program | Initial bundle under 30 MiB (under 15 preferred); total under 250 MiB; saves under 3 MiB; JS heap capped at 512 MB | Program-based; check current terms | Google's Playables developer docs |
| **Discord Activities** | Friends already in a voice channel; social and party games | Embedded App SDK in an iframe; your own server | SKUs and entitlements, verified server-side | Discord developer docs; the Activities shelf |
| **Reddit (Devvit Web)** | Subreddit communities; daily and social hooks | Devvit Web, Phaser template available | Developer Funds paid on engagement milestones (post-July-2026 terms unverified) | Devvit docs; the Reddit x Phaser "Games with a Hook" hackathon (Jun-Jul 2026) |
| **Telegram Mini Apps** | Telegram users | Web app inside Telegram | Telegram Stars for digital goods | Telegram developer docs |
| **Own domain** | Whoever you bring | Instant load, no login is the norm for viral web games | Direct sponsors, in-world ads, cosmetics; spikes then decays | Your own analytics; comparable launches' public posts |
| **Text-to-game platforms** (Astrocade, Rosebud and similar) | Prompt-to-playable communities | The platform's own runtime | Platform programs | Treat as competition for attention at the free, instant end of the market |

Sources: Poki for Developers (requirements and quality); CrazyGames docs (technical requirements,
AI policy summary); Google YouTube Playables certification requirements; Discord developer docs
(Activities IAP); Phaser news (Reddit hackathon, Jun 2026); Telegram (Stars); Fortune (Astrocade,
2026-05-05); research brief on vibe-coded games (Nov 2026).

---

## How web-channel research differs from Steam research

1. **No public sales data.** Portals do not publish revenue per game. Use plays, ratings and chart
   positions as demand signals, and the portal's own developer documentation for the money model.
   Do not invent eCPMs, revenue per thousand plays or retention numbers; if the brief needs one,
   search for a dated, attributed source and quote it as such, or give a range explicitly labeled as
   an assumption.
2. **The technical gate is part of market fit.** A 3D game with 200 MB of assets is not a
   CrazyGames mobile-homepage product. A game that needs a login cannot follow the viral "click and
   play" pattern. Check the gate before sizing the opportunity.
3. **Session length and audience age differ.** Portal players expect instant, short sessions; many
   are young, which pulls in content ratings and, in the EU, child-safety expectations. Discord and
   Reddit reward social play and daily hooks.
4. **Exclusivity and SDKs.** Some portals prefer exclusivity or forbid other ad SDKs. That constrains
   a multi-portal plan; note it in the risks.
5. **Link rot is a market risk.** Web games that depend on a backend go offline when the free tier
   or the developer's attention runs out (a secondary analysis found 42% of Vibe Jam 2025 entries
   already offline by late 2026). Static builds survive.
6. **Web-first to Steam later is a valid path,** but plan it: web-tech games on Steam usually ship in
   Electron with a Steamworks binding; the audience expects more content and polish than a portal
   game.

## Channel questions for the brief

For each candidate channel, answer in the brief:

```
CHANNEL: [Poki / CrazyGames / Steam / ...]
Fit: [why this game's session length, controls and audience match]
Gate: [size, SDK, content rules] -> [passes / needs work: ...]
Money: [model, from the platform's docs, dated]
Competition on this channel: [3-5 comparable titles visible on the channel]
Risk: [exclusivity, backend dependency, policy on AI content]
Verdict: [primary / secondary / skip]
```

## Jams and AI-friendly events as market signals

Jams are not markets, but they are cheap demand tests and audience builders:
- Vibe Jam 2026 drew 945 entries and about 242,000 players in a month.
- Epic's AI MegaJam runs 12-15 Nov 2026 (Unreal and UEFN; AI optional, agents unlimited).
- Reddit x Phaser "Games with a Hook" (Jun-Jul 2026) explicitly rejected "obvious AI slop".

A jam entry that players replay and share is evidence of a hook; a jam entry nobody finishes is
evidence too. Route jam planning to `/gameforge:game-jam-mode`.
