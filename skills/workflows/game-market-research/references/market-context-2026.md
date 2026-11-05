# Market Context, Late 2026 (baseline as of 2026-11-05)

A dated baseline for `game-market-research`. Use it to frame the brief, then refresh anything the
recommendation depends on with WebSearch/WebFetch. If today is more than about three months after
2026-11-05, treat every line as "last known" and re-check before citing it. Cite the source and date
next to every figure you reuse.

---

## 1. Industry mood and labor

| Fact | Source |
|---|---|
| GDC 2026 State of the Game Industry (more than 2,300 respondents): **52%** say generative AI is harming the industry (30% in 2025, 18% in 2024); only 7% see a positive impact | GDC, Jan 2026; Game Developer coverage |
| **36%** use generative AI at work (30% at studios, 58% at publishers and marketing firms); among users, the top uses are brainstorming (81%) and code assistance (47%) | GDC 2026 survey |
| **28%** of respondents were laid off in the past two years | GDC 2026 survey |
| Market share of primary engine among respondents: Unreal 42%, Unity 30%; Godot 11% among newer indies | GDC 2026 survey |
| Industry layoffs reached **10,977 in 2026 by 2026-10-20**, already more than all of 2025 (about 9,000) | TweakTown, Oct 2026, citing the ASGC layoffs tracker; GamesBeat for the 2025 total |

What it means for a brief: more experienced developers are going indie or solo, which raises the
quality bar in crowded genres; players and press are primed to react to visible AI use.

## 2. Steam

| Fact | Source |
|---|---|
| About **19,000 games released on Steam in 2025** (19,008 per SteamDB on 2025-12-12), the most ever; 18,558 in 2024; about half of 2025's releases had 10 or fewer reviews | GamingOnLinux, Dec 2025, citing SteamDB |
| October 2026 Next Fest had about **7,300 demos**, against about 4,400 in June 2026 | Talkesport / GameSpot coverage of Valve at Indie Connect, late Oct 2026 |
| Build review taking **up to 12 business days** against a 3-5 day target; new pre-review checks apply from **2026-11-04** | Engadget, 2026-11-04 |
| Valve declined to add a player-side AI filter (Oct 2026) and said of AI cloning and clone-extortion emails that it does not "want to be gatekeepers"; developers were pointed to the police | Game Developer, 2026-10-28; GameSpot |
| Some studios cancelled public playtests over cloning fears | Kotaku, 2026-10-15 |
| AI disclosure rewritten **2026-01-16**: code assistants and other efficiency tools are exempt; pre-generated content that players see (art, sound, narrative, localization, marketing assets) and live-generated content are disclosed; live generation needs described guardrails. Disclosures show on the store page | Steamworks content survey docs; Game Developer, 2026-01-16 |
| Revenue share 30%, dropping to 25% after US$10M and 20% after US$50M per title (long-standing since Dec 2018); Steam Direct fee US$100 per title, recoupable | Steamworks documentation |

Implications:
- Discovery, not release, is the bottleneck. A brief that assumes "launch and Steam surfaces it" is
  wrong. Plan wishlists, festivals, creators and community before launch.
- Next Fest is more crowded than ever; a demo needs a sharper first five minutes, not just existence.
- Pad launch schedules for slower build review.
- Cloning risk: public demos and playtests of an easily copied mechanic can be cloned fast. Weigh
  visibility against exposure; ship the hook with enough content or craft that a clone is visibly
  worse.

## 3. itch.io

| Fact | Source |
|---|---|
| New game pages per day **"doubled in the past 2 months"**, almost all AI-made, while downloads and purchases did not grow | Aftermath, 2026-11-01 |
| On **2026-11-03** itch.io deleted "a couple terabytes of AI slop" and extended its "no AI" filter to search; bulk AI uploads are treated as spam | VGC, 2026-11-03; Heise |
| Creators answer a generative-AI disclosure question on the project page; it feeds the "no AI" filter | VGC; earlier PC Gamer and Engadget coverage of the disclosure rollout |

Implications: itch.io is still the default home for jams, demos and experimental games, but raw
"new release" browsing is noise. Traffic comes from jams, collections, creators and your own
community. Players who filter out AI content are a real segment: accurate disclosure matters.

## 4. AI use and player sentiment

| Fact | Source |
|---|---|
| The Indie Game Awards rescinded *Clair Obscur: Expedition 33*'s awards (Dec 2025) over generative-AI placeholder textures that had since been patched out | Engadget, Dec 2025 |
| *ARC Raiders* used licensed text-to-speech, then re-recorded many lines with actors after backlash | PC Gamer; Kotaku |
| No well-sourced commercial hit attributable mainly to AI assistance was found as of Nov 2026; reporting shows small teams prototyping faster, more cloning, fewer artist and junior roles | Rest of World, 2026; research brief |
| Claude Code declines to recreate specific existing games (prompt rule added around 2026-10-27) | Game Developer, 2026-10-30; 80.lv, 2026-11-02 |
| Activision DMCA'd AI-built Call of Duty browser ports (Oct 2026) | XDA, 2026-10-11 |

Implications: "made with AI" is not a selling point to most PC players; disclosure is public on
Steam and itch.io; agent-written code with hand-made or licensed assets needs no Steam disclosure.
Position on the game, not the tooling.

## 5. Vibe-coded and web games

| Fact | Source |
|---|---|
| Vibe Jam 2026: **945 games, 242,212 players**, about 12M views on X | @levelsio, 2026-05-01 |
| Vibe Jam entries: about 60-65% used Three.js; **42% of 2025 entries and 13% of 2026 entries were already offline**; games that depended on a backend died fastest | Secondary analysis (michaelscheiwiller.com, "Vibe Jam link rot") |
| fly.pieter.com (browser flight sim built with an AI editor, Feb 2025): self-reported **US$87,000 MRR** on 2025-03-11 from in-world sponsor blimps; by mid-2026 the creator's bio reportedly listed it at $0/month (UNVERIFIED). 404 Media reported the revenue without verifying it | @levelsio X posts, Mar 2025; 404 Media, 2025-03-05; Promptway, 2026-06-24 |
| Astrocade (text-to-game platform): US$56M raised, about 5M monthly active users, 140M plays a month | Fortune, 2026-05-05 |
| Quality ceiling: a Vibe Jam 2026 judge rated the best entries at "3rd year student" level | levels.io, 2026-06-17 |

Implications: a large existing audience plus a novel ad format produced a spike, not a repeatable
model. Text-to-game platforms flood the low end with free, instantly playable content. A small web
game competes on craft, a sharp hook, and distribution (portals, creators, communities).

## 6. Platform cost inputs for break-even

| Cost | As of | Source |
|---|---|---|
| Unity Personal free below US$200K revenue or funding; Pro rose 5% on 2026-01-12 to US$2,310 per seat per year; Runtime Fee cancelled (Sept 2024) | Nov 2026 | Unity pricing pages; 80.lv |
| Unreal: 5% royalty above US$1M lifetime gross per product; 3.5% under Launch Everywhere (ship on the Epic Games Store at the same time or first); revenue from Epic Games Store sales is royalty-free | Nov 2026 | Unreal Engine licence |
| Godot: MIT licence, no fees | | godotengine.org |

---

## Data sources and their caveats

| Source | Gives | Caveat |
|---|---|---|
| SteamDB | Release counts, tags, followers, price history, concurrent players | Followers and CCU are proxies, not sales |
| Gamalytic, VG Insights | Revenue and unit estimates per title | Model estimates; differ from each other; cite as estimates with the tool's name |
| SteamSpy | Owner ranges | Its method has been unreliable since Valve's 2018 profile-privacy change; do not use as the main source |
| Steam store and tag pages | Reviews, price, release date, tags, "more like this" | Review count is the most reliable public signal |
| itch.io browse, jam pages | Volume, tags, popular-this-week | Flooded since autumn 2026; weight curated collections and jams |
| Portal "top" and "new" lists (Poki, CrazyGames) | What plays on the web | No public sales data |
| Twitch and YouTube | Watch interest, creator coverage | Watching is not buying |
| Reddit, Discord communities | Unmet needs, common complaints | Vocal minorities; quote, do not generalize |
| GameDiscoverCo, How To Market A Game | Indie-scale analysis and conversion benchmarks | Partly paywalled; cite the post and date |
| GDC State of the Industry | Developer sentiment and practices | Survey of developers, not players |

## Rules of thumb (label them as such in the brief)

- **Review multiplier.** Lifetime sales are often estimated at roughly 30-50 per Steam review (the
  "Boxleiter" ratio). It varies widely by genre, price, audience and year. Show a range, never a
  single number, and prefer Gamalytic or VG Insights estimates where they exist.
- **Survivorship.** Comparables found by search are the games that succeeded. Include a few
  median and failed titles in the same tag so the estimate is not a highlight reel.
- **Gross is not net.** Subtract the store cut, sales tax and VAT, refunds, regional pricing and
  discounting before comparing with the budget. Model each line explicitly.
