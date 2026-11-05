# Production Calendar: External Dates (late 2026)

Read this when building or reviewing a release schedule, opening a gate review, or when a project
changes engine version, target store or target region. Snapshot as of 2026-11-05. External dates
move: re-verify each one against its source at every milestone gate and record the check date in
`production/calendar.md`.

## 1. How to turn a date into a milestone

For each date that touches the project:
1. **Decide relevance.** Which engine line, store, region or feature does it touch? If none, skip.
2. **Set the lead time.** How long does the readiness work take, plus the 20% buffer?
3. **Name the owner** (usually a director) and **the check** that proves readiness.
4. **Add it** to `production/calendar.md`, and to the risk register if missing it would hurt.
5. **Re-verify** the date at every gate. Note "verified YYYY-MM-DD" beside it.

## 2. Engine support windows

| Line | Facts | Producer reading |
|---|---|---|
| Unity 6.0 LTS | Standard support ended **2026-10-16**; Enterprise and Industry customers get support to 2027-10-16 [1] | Any project still on 6.0 carries an upgrade task now. Ask the TD for a one-sprint spike estimate |
| Unity 6.3 LTS | Released 2025-12-04, supported to **2027-12-04** [1][2] | The default production line. Shipping or supporting the game after Dec 2027 means scheduling the next LTS upgrade |
| Unity 6.6 | Update release (2026-08-31). Fast Enter Play Mode is on by default, so static fields no longer reset [3] | Update releases are short-lived. Ship on an LTS |
| Unity 6.7 LTS / 7.0 | 7.0 alpha (2026-10-05) is the first CoreCLR editor; 6.7 LTS is the bridge release; neither has a committed date [4] | Track on the risk register; never schedule around it |
| Unreal 5.8 | Released **2026-06-17**; Epic calls it the last planned major UE5 release [5] | Lock UE projects to 5.8 for their life cycle |
| UE6 | Early access targeted for **late 2027**, built around Verse and Scene Graph; Blueprints and Actors to be phased out over time [6] | Not a dependency for anything shipping before 2028. Early access is not a production target |
| Godot 4.7 | 4.7 on 2026-06-18; **4.7.2 on 2026-08-18** [7] | Current production line |
| Godot 4.8 | Beta 1 on 2026-10-15 (feature freeze), beta 2 on 2026-10-29; the .NET build needs .NET 10 [8] | Stable date not announced. Plan an upgrade window after release, not before |
| Three.js / Phaser | three.js releases every 1-3 months (r187 on 2026-10-30); Phaser 4 stable since 2026-04-10 [9] | Pin versions; upgrade only at gates |

## 3. Regulatory dates

| Date | Rule | Scope and notes |
|---|---|---|
| **2025-06-28** | European Accessibility Act in force [10] | Consoles, e-commerce (including in-game purchase flows) and electronic communications (the basis for arguments that in-game chat is covered) are in scope. Games themselves are not named. Microenterprises (fewer than 10 staff and at most EUR 2M turnover) are exempt for services. Owner: Accessibility Specialist |
| **2026-01-16** | Steam AI disclosure rewrite [11] | Covers AI content players consume (art, sound, narrative, localization) and marketing; code assistants exempt; live-generated content needs described guardrails. Owner: Creative Director |
| **2026-04-22** | Amended US COPPA Rule: full compliance date (published 2025-04-22, effective 2025-06-23) [12] | Services directed at children or with actual knowledge of under-13 users. Separate parental consent is needed to disclose children's data for targeted advertising. Owner: Producer with legal |
| **June 2026** | PEGI updated criteria for games submitted from June 2026 (announced 2026-03-12) [13] | Paid random items default to PEGI 16 (sometimes 18); NFT or blockchain mechanics PEGI 18; fully unrestricted communication with no blocking or reporting PEGI 18; time- or quantity-limited offers PEGI 12 minimum; daily return rewards PEGI 7 minimum (12 if players are penalized for not returning). Already-rated games keep their rating. Owner: Economy Designer |
| **2026-08-02** | EU AI Act Article 50 applies [14][15] | 50(1): AI NPCs must be disclosed unless obvious. 50(4): fictional works get a lighter deepfake notice. Fines up to EUR 15M or 3% of turnover |
| **2026-12-02** | Art. 50(2) machine-readable marking for generative systems already on the market (Omnibus Regulation (EU) 2026/1744) [15] | Runtime generative features only; source code excluded |
| 2027-02-02 | Article 50 detection-interoperability milestone, per Reed Smith's timeline [16] | Watch item; confirm with counsel if you ship runtime generation |

## 4. Store and platform lead times

| Item | Facts | Plan |
|---|---|---|
| Steam build review | Reported at up to 12 business days against a 3-5 day target; new pre-review checks apply from **2026-11-04** [17] | Submit the release build at least three weeks before a fixed date (rule of thumb) |
| Steam Coming Soon page | Steamworks requires a public Coming Soon page for at least two weeks before release | Page live no later than four weeks before launch, to collect wishlists |
| Steam Next Fest | October 2026 had about 7,300 demos, against about 4,400 in June [18] | Demo quality and marketing, not just registration, decide visibility |
| itch.io | Generative-AI disclosure required; "no AI" filter covers search since 2026-11-03; bulk AI uploads treated as spam [19] | Disclose accurately on day one |
| Web portals | CrazyGames, Poki and YouTube Playables have size and technical requirements and their own review [20] | Route to `/gameforge:game-web-publish`; add portal QA to the schedule |
| Google Play | Apps with native code that target Android 15+ must support 16 KB memory pages; the enforcement date for updates has moved, so check the Play Console [21] | TD confirms engine support (Godot added it in 4.5) |
| Consoles | Certification rules and lead times are under NDA | Get dates from the platform holder or porting partner; never guess |

## 5. Industry context (for scope calibration)

- GDC 2026 State of the Industry (2,300+ respondents): 28% were laid off in the past two years; 52%
  say generative AI is harming the industry (30% in 2025, 18% in 2024); 36% use it at work; top
  uses are brainstorming (81%) and code assistance (47%) [22].
- Layoffs tracked at about 9,000 in 2025 (9,053 per GamesBeat) and 10,977 in 2026 by 2026-10-20
  (TweakTown, citing the ASGC tracker) [23].
- itch.io new pages roughly doubled in two months, mostly AI-made, without growth in downloads or
  purchases (Aftermath, 2026-11-01) [19].
- Viral AI-built web games can spike and fade: the widely covered 2025 browser flight sim's
  sponsor revenue was self-reported, unverified by press, and later reported as not renewing
  (secondary source) [24]. Plan distribution and retention, not novelty.

## Sources

All accessed 2026-11-05.
1. endoflife.date, Unity: https://endoflife.date/unity
2. Unity, "Unity 6.3 LTS is now available": https://unity.com/blog/unity-6-3-lts-is-now-available
3. Unity Manual, New in Unity 6.6: https://docs.unity3d.com/6000.6/Documentation/Manual/WhatsNewUnity66.html
4. Unity Discussions, CoreCLR update Oct 2026: https://discussions.unity.com/t/coreclr-scripting-and-net-update-october-2026/1738338
5. GamesBeat, UE 5.8: https://gamesbeat.com/epic-games-launches-unreal-engine-5-8/
6. Inven Global, Sweeney on UE6: https://www.invenglobal.com/articles/22928/ceo-tim-sweeney-unreal-engine-6-will-fundamentally-change-the-development-paradigm
7. Godot blog index: https://godotengine.org/blog/
8. Godot 4.8 beta 1: https://godotengine.org/article/dev-snapshot-godot-4-8-beta-1/
9. three.js releases: https://github.com/mrdoob/three.js/releases ; Phaser v4.0.0: https://github.com/phaserjs/phaser/discussions/7274
10. Travers Smith, EAA now applies (2025-06-27): https://www.traverssmith.com/knowledge/knowledge-container/a-new-milestone-for-accessibility-the-european-accessibility-act-now-applies/
11. Game Developer, Valve AI disclosure rules (2026-01-16): https://www.gamedeveloper.com/business/valve-tweaks-and-clarifies-ai-disclosure-rules-for-steam
12. Hunton, COPPA compliance deadline: https://www.hunton.com/privacy-and-cybersecurity-law-blog/coppa-rule-amendment-compliance-deadline-approaches ; National Law Review: https://natlawreview.com/article/amendments-ftc-coppa-rule-now-effect
13. VGC, PEGI 16 for loot boxes (2026-03-12): https://www.videogameschronicle.com/news/all-games-with-loot-boxes-in-them-will-be-rated-minimum-pegi-16-starting-this-summer ; Lewis Silkin: https://www.lewissilkin.com/insights/2026/03/18/pegi-announces-major-update-to-age-rating-criteria-what-games-businesses-need-to-102mn9y
14. European Commission, Article 50 FAQ: https://digital-strategy.ec.europa.eu/en/faqs/transparency-obligations-under-article-50-ai-act
15. ActuIA, Omnibus (EU) 2026/1744 dates: https://www.actuia.com/en/news/ai-act-obligations-in-force-and-delays-under-omnibus-2026-1744/
16. Reed Smith, Article 50 Code of Practice (2026-07-28): https://www.reedsmith.com/our-insights/blogs/viewpoints/102nbz0/transparency-obligations-for-ai-generated-content-the-code-of-practice-adequacy/
17. Engadget, Steam release rule changes (2026-11-04): https://www.engadget.com/2306215/valve-changed-its-steam-release-rules-amid-a-flood-of-ai-games/
18. GameSpot, Valve on Next Fest (Oct 2026): https://www.gamespot.com/articles/valve-knows-steam-next-fest-has-an-ai-slop-problem-and-its-looking-for-solutions/
19. Aftermath, itch.io flooding (2026-11-01): https://aftermath.site/itch-ai-games-pc-slop/ ; VGC, itch.io cleanup (2026-11-03): https://www.videogameschronicle.com/news/itch-mass-deletes-ai-slop-lets-users-filter-out-any-ai-assisted-games/
20. CrazyGames requirements: https://docs.crazygames.com/requirements/technical ; Poki: https://developers.poki.com/guide/requirements-quality ; YouTube Playables: https://developers.google.com/youtube/gaming/playables/certification/requirements_stability
21. Android developers, Support 16 KB page sizes: https://developer.android.com/guide/practices/page-sizes
22. GDC 2026 State of the Game Industry: https://gdconf.com/article/gdc-2026-state-of-the-game-industry-reveals-impact-of-layoffs-generative-ai-and-more/
23. TweakTown, 2026 layoffs: https://www.tweaktown.com/news/114442/games-industry-layoffs-hit-10977-in-2026-already-surpassing-all-of-2025-with-months-to-go/index.html ; GamesBeat, 2025 total: https://gamesbeat.com/gaming-layoffs-slowed-from-15631-in-2024-to-9053-in-2025-amir-satvat/
24. 404 Media (2025-03-05): https://404media.co/this-game-created-by-ai-vibe-coding-makes-50-000-a-month-yours-probably-wont ; Promptway (2026-06-24): https://promptway.com/blog/pieter-levels-flight-sim-to-zero
