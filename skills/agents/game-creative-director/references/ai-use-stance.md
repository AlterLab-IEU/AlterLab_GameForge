# AI-Use Stance: Detail Reference

Read this before setting or changing a project's AI-use stance, before a public build, and whenever
a director proposes a new AI tool for player-facing content. Facts are as of 2026-11-05; policies
in this area change every few months, so re-check the primary pages before a store submission.

## 1. Policy landscape (late 2026)

### Storefronts

| Store | What must be disclosed | Notes |
|---|---|---|
| **Steam** | AI content that ships and is consumed by players: "artwork, sound, narrative, localization", plus marketing assets. Two categories: **Pre-Generated** (reviewed like any other content) and **Live-Generated** (you must describe your guardrails) | Rewritten 2026-01-16. Efficiency tools such as code assistants are exempt. Live-generated adult-only sexual content is not allowed. Disclosures appear on the store page [1][2] |
| **Microsoft Store / Xbox stores (policy 11.16)** | Products with **live** generative AI: disclose in metadata and Partner Center, keep output within Store policy, offer a way to report content and act on reports | Pre-generated assets are not covered by 11.16 [3] |
| **itch.io** | Generative-AI content must be disclosed; the tag feeds a "no AI" browse filter that since 2026-11-03 also filters search | Bulk AI uploads are treated as spam; itch.io deleted "a couple terabytes of AI slop" in Nov 2026 [4] |
| **PlayStation, Nintendo, Epic** | No public AI-specific store rule found | Absence of evidence, not a green light; follow general content policy [5] |
| **Apple App Store** | No AI-specific ban | In Mar 2026 Apple blocked updates of vibe-coding apps under guideline 2.5.2 (executing downloaded code). Relevant only if your game ships an in-app game *maker* [6] |
| **Google Play** | AI-Generated Content policy covers generative features: no offensive or deceptive output | No labelling mandate found [7] |

### Regulation

- **EU AI Act, Article 50** applies from **2026-08-02** [8][9]:
  - 50(1): AI agents and avatars, including **AI NPCs**, must tell users they are AI unless that is
    obvious. The exception is read narrowly.
  - 50(2): runtime generative systems need machine-readable marking of output. Systems already on
    the market have a grace period to **2026-12-02** (Omnibus Regulation (EU) 2026/1744). Source
    code is excluded.
  - 50(4): for evidently artistic or fictional works, deepfake disclosure must not hamper the work.
  - Not retroactive for media generated before 2026-08-02. Fines up to EUR 15M or 3% of turnover.
- **US copyright**: human authorship is required. The Copyright Office's Part 2 report
  (2025-01-29) says prompts alone are not enough, but human selection, arrangement and modification
  can be protected. The Supreme Court denied cert in *Thaler* on 2026-03-02 [10][11].
- **Voice**: the SAG-AFTRA 2025 Interactive Media Agreement (ratified 2025-07-09) requires consent
  and disclosure for digital replicas, a reasonably specific description of each use, and usage
  reports to performers. Performers can suspend consent during a strike [12].

### Model and asset licensing flags

- **Music**: UMG and Sony are still suing Suno; Udio disabled downloads after settling with UMG.
  Treat Suno and Udio output as legally unsettled for shipped games. Eleven Music and Stable Audio 3
  are trained on licensed data; Stable Audio 3's open-weight models need an Enterprise license above
  US$1M revenue [13].
- **3D**: the Hunyuan3D 2.1 license does not apply in the EU, UK or South Korea, and that
  restriction covers outputs; TRELLIS.2 is MIT. Hero meshes still need manual retopology [14].
- Route tool-by-tool license checks to `/gameforge:game-ai-assets` and the art and audio directors.

### Industry sentiment

- GDC 2026 State of the Industry (2,300+ respondents): 52% say generative AI is harming the
  industry (30% in 2025, 18% in 2024); 36% use it at work; top uses are brainstorming (81%) and code
  assistance (47%) [15].
- Visible AI use has caused backlash: the Indie Game Awards rescinded *Clair Obscur*'s awards in
  Dec 2025 over gen-AI placeholder textures that had been patched out [16]; *ARC Raiders* used
  licensed TTS and re-recorded many lines with actors after criticism [17].
- Rest of World reports tiny teams prototyping faster, more cloning, and fewer artist and junior
  jobs [18]. GameForge's Nov 2026 research found no well-sourced commercial hit attributable mainly
  to AI assistance.

## 2. Per-asset matrix

Fill one row per asset class in `design/ai-content-policy.md`. "Gate" is who signs off.

| Asset class | L0 | L1 | L2 | L3 | Gate | Disclosure |
|---|---|---|---|---|---|---|
| Gameplay code, tools, build scripts | assistant OK | yes | yes | yes | Technical Director review | None on Steam (exempt) |
| Internal ideation, mood boards | no | yes | yes | yes | Creative Director | None (never ships) |
| Placeholders in dev builds | no | logged, replaced before any public build | same | same | Release gate | None if fully replaced |
| Concept art | no | internal only | yes, human-finished | yes | Art Director | If shipped (artbook, store) |
| Shipped 2D/3D art | no | no | named classes only (props, textures) | yes | Art Director | Steam pre-gen; itch.io tag |
| Logo, key art, main characters | no | no | no | no by default | Creative Director | Keep human-made for copyright |
| SFX | no | no | yes | yes | Audio Director | Steam pre-gen |
| Music | no | no | licensed-data models only | same | Audio Director + legal | Steam pre-gen |
| Voice / TTS | no | no | consented, contracted only | same | Audio Director + legal | Steam pre-gen; credits |
| Localization | no | no | MT/LLM draft + human review | same | Localization lead | Steam counts it as disclosable |
| Store page, trailers, marketing | no | no | human-finished | same | Creative Director | Steam covers marketing |
| Runtime generation (NPC chat, levels) | no | no | no | with guardrails | Creative + Technical Director | Steam live-gen; MS 11.16; EU Art. 50 |

## 3. Placeholder gate

The *Clair Obscur* case shows that a placeholder discovered after launch is treated as a shipped
asset. Make placeholders impossible to forget:

1. Name or tag every AI placeholder (`AI-PLACEHOLDER` in the filename, metadata or a tracking list).
2. Log it in the asset provenance log kept by `/gameforge:game-ai-assets`, with the replacement
   owner and milestone.
3. Before any public build (demo, Next Fest, review keys, launch), search for the tag and the log's
   open rows. Any hit blocks the build.
4. After replacement, keep the log row with the replacement date. It is your evidence if asked.

## 4. Disclosure wording

Specific beats vague. Name the asset class, the human role, and what is generated live.

**Steam content survey, pre-generated (example)**
> Some environment textures and prop meshes were generated with AI tools and then edited and
> finished by our artists. All characters, key art, music and writing are made by people.

**Steam content survey, live-generated (example)**
> Shopkeeper NPCs reply to typed questions using an on-device language model. Replies are limited
> to in-world topics, filtered against a blocklist, logged locally, and can be reported from the
> pause menu.

**Credits line**
> AI-assisted production: environment textures (Scenario), localization drafts (DeepL), reviewed and
> edited by the team. Code written with AI coding assistants.

**In-game notice for an AI NPC (EU Art. 50(1))**
> Shown the first time the player talks to the NPC: "Mara's replies are generated by AI."
> Skip it only if the AI nature is genuinely obvious from context, and record why.

**itch.io**: set the generative-AI disclosure to match the Steam answer. Expect the "no AI" filter
to hide the page from players who opted out; that is the honest trade.

## 5. Changing a stance

- Change only at a milestone gate or before a public build, never quietly mid-production.
- Record the change as a creative decision (`CD-NNN`) with the reason and the asset classes affected.
- Moving up a level (more AI) triggers a disclosure review with `/gameforge:game-launch` and a
  license check per tool. Moving down triggers a replacement plan with the producer.
- Tell the community before the store page changes. Discovered changes read as concealment.

## 6. Red flags that require a ruling

- "We'll disclose it later" or "it's only placeholder" for anything in a public build.
- A tool whose license or training data the team cannot describe.
- Any voice that sounds like a real performer without a signed consent and usage description.
- Prompts naming a living artist, studio or franchise.
- Live-generated content without a written guardrail list and a player report path.
- Marketing that calls AI-assisted content "hand-crafted".

## Sources

All accessed 2026-11-05 unless dated otherwise.

1. Steamworks Content Survey (AI section and FAQ): https://partner.steamgames.com/doc/gettingstarted/contentsurvey
2. Game Developer, "Valve tweaks and clarifies AI disclosure rules for Steam" (2026-01-16): https://www.gamedeveloper.com/business/valve-tweaks-and-clarifies-ai-disclosure-rules-for-steam
3. Microsoft Store Policies, 11.16 "Live Generative AI Content": https://learn.microsoft.com/en-us/windows/apps/publish/store-policies
4. VGC, "Itch mass deletes 'AI slop'..." (2026-11-03): https://www.videogameschronicle.com/news/itch-mass-deletes-ai-slop-lets-users-filter-out-any-ai-assisted-games/
5. The Conversation, platform AI rules (Feb 2026): https://theconversation.com/are-video-game-developers-using-ai-players-want-to-know-but-the-rules-are-patchy-274850
6. Heise, "Apple blocks updates for vibe-coding apps" (2026-03-18): https://www.heise.de/en/news/Apple-blocks-updates-for-vibe-coding-apps-11216835.html
7. Google Play, AI-Generated Content policy: https://support.google.com/googleplay/android-developer/answer/14094294
8. European Commission, Article 50 FAQ (updated 2026-07-24): https://digital-strategy.ec.europa.eu/en/faqs/transparency-obligations-under-article-50-ai-act
9. ActuIA, Omnibus (EU) 2026/1744 dates (2026-10-06): https://www.actuia.com/en/news/ai-act-obligations-in-force-and-delays-under-omnibus-2026-1744/
10. US Copyright Office, Copyright and AI: https://www.copyright.gov/ai/
11. Holland & Knight, Thaler cert denied (Mar 2026): https://www.hklaw.com/en/insights/publications/2026/03/the-final-word-supreme-court-refuses-to-hear-case-on-ai-authorship
12. PC Gamer, SAG-AFTRA ratification (Jul 2025): https://www.pcgamer.com/gaming-industry/the-videogame-voice-actors-strike-officially-ends-as-performers-ratify-agreement-between-sag-aftra-and-publishers
13. Music Business Worldwide on Suno litigation (Oct 2026): https://www.musicbusinessworldwide.com/suno-fights-to-keep-warner-music-settlement-terms-away-from-umg-and-sony/ ; Stability AI, Stable Audio 3: https://stability.ai/stable-audio
14. Hunyuan3D 2.1 license: https://huggingface.co/tencent/Hunyuan3D-2.1 ; TRELLIS.2 model card: https://huggingface.co/microsoft/TRELLIS.2-4B
15. GDC 2026 State of the Game Industry: https://gdconf.com/article/gdc-2026-state-of-the-game-industry-reveals-impact-of-layoffs-generative-ai-and-more/
16. Engadget, Indie Game Awards rescind *Clair Obscur* awards (Dec 2025): https://www.engadget.com/gaming/the-indie-game-awards-snatches-back-two-trophies-from-clair-obscur-over-its-use-of-generative-ai-164730842.html
17. Kotaku, *ARC Raiders* re-recorded lines: https://kotaku.com/arc-raiders-replaced-ai-generated-content-human-recorded-dialogue-voices-2000678774
18. Rest of World, AI and shrinking game teams (2026): https://restofworld.org/2026/ai-video-games-developer-jobs/
