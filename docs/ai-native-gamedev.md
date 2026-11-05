# AI-Native Game Development (Late 2026)

What AI tools can and cannot do for an indie team as of **2026-11-05**: which are production-ready, which are experimental, what the license and rights position is, what you must disclose, and where GameForge skills plug in. Tool versions, licenses and store rules change monthly. Before anything ships, re-check it against the numbered source.

Companion docs: [MCP integrations](mcp-integrations.md) (agent-to-editor wiring and security) and [engine comparison](engine-comparison.md) (engine choice for AI-assisted builds).

---

## How to Read the Ratings

| Rating | Meaning |
|---|---|
| **Production-ready** | Shipping teams use it. Output reaches the release build after normal review. |
| **Usable with review** | It works, but every output needs cleanup, a rights check, or human sign-off. |
| **Experimental** | Preview, research, or no evidence of shipped use. Use it for prototypes and ideation only. |
| **Legally unsettled** | Technically capable, but rights are in active litigation. Keep it out of shipped builds. |

**UNVERIFIED** means one secondary or vendor source supports the claim, or sources conflict. A **vendor claim** is a performance figure nobody has independently tested.

---

## Summary Matrix

| Category | Leading options (Nov 2026) | Rating | Rights / license watch-outs | GameForge skill |
|---|---|---|---|---|
| Coding agents | Claude Code, GitHub Copilot, Codex, Cursor [1] | Production-ready with a check loop | Steam exempts code assistants from disclosure [40] | `/gameforge:game-vibe-code` |
| Engine assistants & MCP | Unity AI (beta), Unreal MCP (experimental), community Godot/Blender servers [7][11] | Usable with review | Code-execution tools are arbitrary code execution | engine specialists |
| 3D generation | Meshy 6, Tripo P1, Rodin Gen-2.5, TRELLIS.2, Hunyuan3D 2.1 [14]–[18] | Props: usable with review. Hero assets: experimental | Hunyuan3D license excludes EU/UK/South Korea [17] | `/gameforge:game-ai-assets` |
| 2D, pixel art, textures | PixelLab, Retro Diffusion, Scenario, Layer.ai [19] | Usable with review | Check each vendor's commercial terms; "seamless" output often fails to tile | `/gameforge:game-ai-assets` |
| Animation | Move AI Gen 2, Rokoko Vision 3.0, Cascadeur 2026.x, UE 5.8 MetaHuman Animator [12][20]–[22] | Usable with review | MetaHumans may not be used to train AI | `/gameforge:game-art-director` |
| SFX | ElevenLabs SFX v2, Stable Audio 3 [23][24] | Production-ready for many uses | Stable Audio open weights need an Enterprise license above US$1M revenue | `/gameforge:game-audio-director` |
| Music | Eleven Music, Stable Audio 3; Suno/Udio [25][26] | Licensed-data models: usable with review. Suno/Udio: legally unsettled | UMG and Sony still suing Suno | `/gameforge:game-audio-director` |
| Voice / TTS | ElevenLabs, Inworld TTS, NVIDIA ACE TTS [33][34] | Usable with review | SAG-AFTRA consent and disclosure rules; player backlash [27][28] | `/gameforge:game-audio-director` |
| World models | Genie 4, Muse/WHAM, Marble [29]–[32] | Experimental | Pitch and mood only | `/gameforge:game-brainstorm` |
| Runtime AI NPCs | NVIDIA ACE on-device, Inworld, Convai [33]–[35] | Usable with review (ACE). Cloud: per-game call | EU Art. 50(1) disclosure, Steam guardrails, Microsoft 11.16 [40][42][43] | `/gameforge:game-narrative-director` |
| QA / playtest agents | modl.ai, nunu.ai, engine MCP test runners, Playwright loops [11][37] | Experimental (vendor agents). Usable (scripted loops) | No published accuracy benchmarks | `/gameforge:game-qa-lead` |
| Localization | Hybrid NMT + LLM + human review; Gridly, Crowdin, Lokalise [38] | Usable with review | Steam counts AI localization as disclosable content [40] | `/gameforge:game-localization-manager` |

---

## 1. Coding Agents

**State of play.** Among developers who used an AI coding agent in the past year, the Stack Overflow 2026 survey (published 2026-10-06, n=12,255) reports the following usage [1]:

| Agent | Share | Agent | Share |
|---|---|---|---|
| Claude Code | 65.5% | Google Antigravity | 16.0% |
| GitHub Copilot | 58.7% | Gemini Code Assist | 14.6% |
| OpenAI Codex | 29.5% | OpenCode | 13.6% |
| Cursor | 25.5% | Windsurf | 6.5% |

**What works.** Every published workflow that produces playable games has the same core: the agent gets a check it can run.
- **A pass/fail signal.** Anthropic's guidance is to give Claude "something it can run that comes back pass or fail," such as a test, a build exit code, or a screenshot next to the mockup. Write a spec first, then build it in a fresh session [2].
- **Observable state.** OpenAI's `develop-web-game` skill adds `window.render_game_to_text()` (compact JSON of the visible state) and `window.advanceTime(ms)` for deterministic stepping. It also runs Playwright after every meaningful change [3].
- **Instruments.** Practitioners have agents build debug tools, editors and AI-vs-AI balance harnesses. Simon Willison's *Battle Drones* ran more than 1,200 simulated matches, although he says he reviewed "almost none of the code" [6].

**What breaks.**
- **Vibe debt.** Repeated regeneration produces code without structural rationale.
- **Client-trusted multiplayer.** Scores, state and purchases must be validated on the server.
- **Hidden platform bugs.** Mid-range Android performance and cross-browser math differences (Chrome vs. Safari `Math.sin` desynced *Battle Drones* replays [6]).
- **Stale API knowledge.** Engine APIs have moved: Godot 3→4, Phaser 3→4, three.js r181–r187 deprecations. Pin versions and point the agent at current docs ([docs for agents](mcp-integrations.md#docs-for-agents-llmstxt)).

**Originality guard.** Since late October 2026, Claude Code declines to build recreations of specific existing games, even renamed ones. Anthropic says original games, genre games, and games built from your own designs and assets keep working [4]. Activision's DMCA takedowns of AI-built *Call of Duty* browser ports (2026-10-11) show the legal side of the same line [60]. GameForge skills steer toward genre mechanics, original designs and your own assets.

**Upstream contributions.** Since 2026-06-30, the Godot Foundation rejects substantial AI-authored code and agent-driven or "vibe-coded" pull requests to the engine. It allows minor assistance if you disclose it. This applies to contributing to Godot, not to games built with it [5].

**Rating: production-ready**, provided every task ends in a runnable check and a human reviews architecture, netcode and anything touching money or saves.

---

## 2. Engine Assistants and MCP

| Engine | Official AI integration | Status |
|---|---|---|
| Unity | **Unity AI** includes an in-editor agent (Ask, Agent and Plan modes, Skills, rollback, Generators) that uses credits. It is included in Pro, Enterprise and Industry; on Personal, a trial converts to US$10/month. The **AI Gateway** lets you bring a third-party agent you already pay for, without Unity credits. The **MCP server, Unity CLI and the official Claude Code plugin** are described as free on Unity 6.0+ [7][9]. | Open beta since 2026-05-04 [8] |
| Unreal | UE 5.7 added an experimental in-editor AI Assistant (press F1 on a UI element; it can generate C++) [10]. UE 5.8 ships the experimental **Unreal MCP** plugin: editor-only, loopback-only, no authentication [11]. | Experimental |
| Godot | None. No official MCP server and no `llms.txt`. Community servers fill the gap. | Community |
| Web | No official three.js MCP server, but three.js publishes an official `llms.txt`. PlayCanvas ships an Editor MCP server. | Mixed |

**Unity Spark** (announced 2026-10-07) is a browser-based, prompt-driven game maker that publishes to Google's Playground. It is in closed beta with no pricing [13]. **Experimental.**

Unity's May 2026 MCP setup post listed an AI-tools trial or subscription as a prerequisite. The current Unity AI page says the MCP server needs no credits [7][8]. Confirm the terms on the day you set it up.

Setup, maturity and security for each server are in [MCP integrations](mcp-integrations.md).

**Rating: usable with review.** These tools edit live projects. Commit before each session and review the diff afterwards.

---

## 3. Asset Generation

Log every generated asset (tool, model version, prompt, date, human edits, license) in an asset provenance log. GameForge v3.0 adds a `templates/ai-asset-log.md` template for this. Then set studio-level rules in the [AI content policy](../templates/ai-content-policy.md) template. Steam, itch.io and EU disclosures are all generated from that log. Run the pipeline with `/gameforge:game-ai-assets`.

### 3D

| Tool | Strength | License / rights | Rating |
|---|---|---|---|
| Meshy 6 (Jan 2026) | Low-poly mode, Remesh retopology, auto-rig [14] | Commercial SaaS; check tier terms | Usable with review (props) |
| Tripo P1 "Smart Mesh" (Mar 2026) | Topology-focused generation; a reviewer found hero assets still need cleanup [15] | Commercial SaaS | Usable with review |
| Rodin Gen-2 / 2.5 | Quad-dominant meshes (vendor claim) [16] | Commercial SaaS | Usable with review |
| Hunyuan3D 2.1 (open weights) | Strong open model | **License does not apply in the EU, UK or South Korea, and the restriction covers outputs.** Services above 1M MAU need a separate license [17]. 3.x reportedly API-only (UNVERIFIED) | Avoid if you sell in the excluded regions |
| TRELLIS.2-4B (Microsoft) | Full PBR output | **MIT.** Needs a 24 GB+ GPU; tested on Linux only [18] | Usable with review |

**Reality check.** Auto-retopology and auto-rigging hold up for props and background characters. Hero meshes still need hand-placed edge loops and manual retopology [14][15]. Budget artist time for them.

### 2D, Pixel Art and Textures

- **PixelLab:** rotations, skeleton animation, tilesets, plus an Aseprite plugin and API (third-party reports) [19].
- **Retro Diffusion:** RD Plus is FLUX-based and trained at 256 px or below; RD Animation makes spritesheets [19].
- **Scenario:** style training plus tileable PBR maps. **Layer.ai:** a multi-model workspace aimed at volume [19].

No independent texture benchmark exists. Generated "seamless" textures do not always tile, so check every edge in-engine. **Rating: usable with review.**

### Animation

- **Move AI Gen 2:** single-camera capture model [20].
- **Rokoko Vision 3.0** (2026-07-16): video-to-motion and text-to-motion [21].
- **Cascadeur 2026.1 / 2026.2:** generative in-betweens, UE Live Link, animation layers, and a simple MCP server in 2026.2 [22].
- **UE 5.8 MetaHuman Animator:** face and body capture from a single webcam [12]. MetaHumans can be used in Unity and Godot, but not to train AI.
- DeepMotion's 2026 changes: UNVERIFIED.

**Rating: usable with review.** Captured motion still needs cleanup on contacts and loops.

### Audio: SFX and Music

| Tool | Notes | Rights | Rating |
|---|---|---|---|
| ElevenLabs SFX v2 (Sept 2025) | 30 s clips, seamless loops, 48 kHz [23] | Commercial per plan | Production-ready |
| Stable Audio 3 (2026-05-20) | Trained on licensed data. Small SFX, Small and Medium are open weights; Large is API-only [24] | Stability AI Community License; **Enterprise license above US$1M revenue** | Usable with review |
| Eleven Music | Trained on licensed data (Merlin and Kobalt deals); offered for commercial use [25] | Game-specific tier requirements UNVERIFIED | Usable with review |
| Suno / Udio | UMG settled with Udio (Oct 2025), and Udio then disabled downloads. WMG settled with Suno (2025-11-25). **UMG and Sony are still suing Suno** [26]. | Unsettled | **Legally unsettled. Keep out of shipped games** |

### Voice

- **Union rules.** The **2025 SAG-AFTRA Interactive Media Agreement** (ratified 2025-07-09) requires consent and disclosure for digital voice replicas, a "reasonably specific description" of each use, and usage reports to performers. Performers can suspend consent during a strike [27].
- **Player reaction.** *ARC Raiders* shipped with licensed TTS and then re-recorded many lines with actors after backlash [28].
- **Rule of thumb.** TTS for placeholders, barks and systemic lines. Actors for characters players are meant to care about.

---

## 4. World Models

None of these is a production engine.

| Model | Status |
|---|---|
| Google DeepMind Genie 3 (Aug 2025) → Project Genie (2026-01-29) → **Genie 4** (research preview, 2026-10-27) | Genie 4 adds native audio, mid-session prompt steering and about 2 minutes of consistency. Google acknowledges drift and illegible in-world text. Project Genie was US-only, for AI Ultra subscribers, in 60-second sessions [29][30]. |
| Microsoft Muse / WHAM (2025-02-19) | 300×180 output, weights released, positioned for **ideation** [31] |
| Decart Oasis 2.0, Dynamics Lab Mirage 2 | Demos; latency figures are vendor claims |
| World Labs Marble | Exports Gaussian splats and GLB meshes; export needs the paid Pro plan [32] |

**Use them for** pitch videos, mood boards and greybox reference (`/gameforge:game-brainstorm`, `/gameforge:game-prototype`). **Rating: experimental.**

---

## 5. Runtime AI NPCs

**Options**
- **NVIDIA ACE on-device** is the most production-ready. The Game Agent SDK and UE5 plugins run local speech recognition, a small language model (Qwen 3.5 4B) and TTS, with function calling. It is live in *inZOI* and *NARAKA: BLADEPOINT* [33].
- **Inworld** has pivoted toward runtime and TTS; TTS-1.5 costs about US$5–10 per million characters [34].
- **Convai** ships Unreal, Unity and MetaHuman plugins [35].
- Per-player cost claims for cloud NPCs are UNVERIFIED.

**Shipped lessons**
- *Where Winds Meet*'s AI chat NPCs were quickly exploited by players [36].
- *Whispers from the Star* (iOS) is built around one real-time AI character [36].
- Fortnite's AI conversations remain experimental and cannot be published in UEFN [36].

**Design guidance**
1. Hand-author critical story dialogue. Use LLMs for barks, shopkeeper banter and ambient flavor.
2. Route model output through **function calls into deterministic game systems**. Never let the model set prices, grant items or decide quest state directly.
3. Treat player input as hostile. Harden against prompt injection, cap output length, filter output, and log it for moderation.
4. Prefer on-device models where VRAM allows: no per-call cost, offline play, no data leaving the machine. Cloud means latency and an ongoing bill. Valve suggests covering that bill through the price, microtransactions, a subscription or DLC [40].
5. **Disclose:**
   - EU AI Act Art. 50(1) requires telling users they are interacting with AI unless that is obvious [43].
   - Steam's Live-Generated category requires you to describe your guardrails [40].
   - Microsoft Store 11.16 requires a way for players to report content [42].

Route NPC design to `/gameforge:game-narrative-director` and the cost model to `/gameforge:game-economy-designer`.

---

## 6. QA, Playtesting and Feedback

- **Agent testers** (vendor sources; quality UNVERIFIED):
  - modl.ai (modl:test, modl:play) runs black-box agents that read the screen, accept plain-language test tasks and plug into CI.
  - nunu.ai offers end-to-end agent testing [37].
  - A Razer agentic QA tool shown at GDC 2026 appears in one directory only: UNVERIFIED.
- **Engine-native loops.** Unreal MCP runs automation tests [11]. MCP for Unity runs tests and profiling. For web games, a Playwright loop driven by your coding agent, plus `render_game_to_text` and `advanceTime`, gives deterministic, screenshot-checked runs [3].
- **Feedback summarizers.** FirstLook (Steam and Discord aggregation, with an MCP agent) and Accord analyze community feedback. Neither publishes accuracy benchmarks [39]. Validate them against a sample you have read yourself.
- **What Claude does without running the game.** Analytical playtesting: it reads the systems code to predict dominant strategies, exploits and edge cases. This feeds `/gameforge:game-balance-check` and `/gameforge:game-playtest`.

**Rating:** agents supplement human playtests and do not replace them. Fun, feel and readability still need people.

---

## 7. Localization

- **Pipeline.** The working pattern is hybrid: neural MT for volume, an LLM pass for tone and terminology, and human review for humor, culture and UI fit [38].
- **Platforms.** Gridly is game-focused, Crowdin has a Copilot agent, and Lokalise offers LLM routing and quality scoring [38].
- **Disclosure.** Steam explicitly lists AI-generated localization as disclosable content [40].

Run it with `/gameforge:game-localization-manager`.

---

## 8. Security Posture

AI tooling widens your attack surface in three places.

1. **MCP servers that can execute code**
   - Blender's `execute_blender_code` runs arbitrary Python over an unauthenticated local socket.
   - Playwright MCP's `browser_run_code_unsafe` is RCE-equivalent.
   - Unreal MCP has no authentication at all.

   Keep every server bound to localhost and treat code-execution tools as arbitrary code execution. Never expose an editor bridge to a network [11]. Configuration and deny-rule examples are in [MCP integrations](mcp-integrations.md#security).
2. **Prompt injection through content**
   - An agent that reads web pages, asset-store descriptions, issues or player feedback can be steered by text inside them.
   - Do not combine untrusted-content tools and code-execution tools in one unattended session.
3. **Shipped builds**
   - Never ship an MCP bridge inside a release build.
   - Keep API keys off the client. Proxy model calls through your server.
   - Validate multiplayer state, scores and purchases server-side.

---

## 9. Policy and Disclosure (as of 2026-11-05)

| Rule | What it requires | Source |
|---|---|---|
| **Steam Content Survey** (rewritten 2026-01-16) | Disclose AI content that ships and is consumed by players: "artwork, sound, narrative, localization", plus marketing assets. **Code assistants and other efficiency tools are exempt.** **Pre-Generated** content is reviewed like any other content. **Live-Generated** content needs described guardrails; live-generated adult-only sexual content is not allowed. | [40][41] |
| **Microsoft Store Policy 11.16** (policy v7.20, 2026-09-14) | Products with live generative AI must disclose it in metadata and in Partner Center, keep output within Store policy, and provide a way to report content and act on reports. "Store" includes XBOX-branded stores. Pre-generated assets are not covered. | [42] |
| **itch.io** | Generative-AI disclosure is required and feeds the "no AI" filter, which reached search on 2026-11-03. On the same day itch deleted "a couple terabytes" of bulk AI uploads as spam. | [53] |
| **PlayStation, Nintendo** | No public AI-specific store rule found (absence of evidence) | — |
| **Apple App Store** | No AI-specific ban. In Mar 2026 Apple blocked updates to vibe-coding apps under guideline 2.5.2 (executing downloaded code), so in-app game *makers* are at risk. | [56] |
| **Google Play** | The AI-Generated Content policy covers generative features (no offensive or deceptive output). No labeling mandate found. | [57] |
| **US copyright** | Copyright Office Part 2 (2025-01-29): prompts alone are not enough, but human selection, arrangement and modification can be protected. The Supreme Court denied cert in *Thaler* (2026-03-02), so human authorship is still required. | [47][48] |
| **SAG-AFTRA 2025 IMA** | Consent, specific-use description and usage reports for digital voice replicas | [27] |
| **European Accessibility Act** (in force 2025-06-28) | Consoles, e-commerce (including in-game purchase flows) and electronic communications are in scope; games themselves are not named. Microenterprises are exempt for services. See `/gameforge:game-accessibility-specialist`. | [46] |

### EU AI Act, Article 50

| Date | Milestone |
|---|---|
| 2026-06-10 | Code of Practice finalized |
| 2026-07-20 | Commission guidelines published |
| **2026-08-02** | Transparency obligations apply |
| **2026-12-02** | End of the grace period for Art. 50(2) machine-readable marking, and only for generative systems already on the market (Omnibus Regulation (EU) 2026/1744) |
| 2027-02-02 | Detection interoperability |

What each paragraph means for games [43][44][45]:
- **50(1):** AI agents and avatars, including AI NPCs, must tell users they are AI unless that is obvious. The exception is read narrowly.
- **50(2):** runtime generative systems must mark output in machine-readable form. Source code is excluded.
- **50(4):** for evidently artistic or fictional works, deepfake disclosure must not hamper enjoyment of the work.
- The obligations are not retroactive for media generated before 2026-08-02.
- Fines reach up to €15M or 3% of turnover.

### Litigation and Reputation

- **Getty v. Stability (UK)** was largely won by Stability on 2025-11-04.
- **Disney, Universal and WBD v. Midjourney** is in discovery.
- **Andersen v. Stability** has a summary-judgment hearing set for Feb 2027 [49].
- The **Indie Game Awards rescinded *Clair Obscur*'s awards** (Dec 2025) over generative-AI placeholder textures, even though they had already been patched out [50].

Hidden use costs more than disclosed use.

Build the compliance checklist with `/gameforge:game-launch`, and set the studio stance with `/gameforge:game-creative-director`.

---

## 10. Industry Sentiment

- **GDC 2026 State of the Industry** (more than 2,300 respondents) [51]:
  - **52%** say generative AI is harming the industry, up from 30% in 2025 and 18% in 2024. Only 7% see a positive impact.
  - **36%** use it at work: 30% at studios and 58% at publishers and marketing firms. Top uses are brainstorming (81%) and code assistance (47%).
  - 28% of respondents were laid off in the past two years.
- **Layoffs:** 10,977 in 2026 by 2026-10-20, already more than all of 2025 [52].
- **Store flooding:**
  - itch.io's daily new pages roughly doubled in two months, almost all of them AI-made, with no matching growth in downloads. That led to the Nov 2026 cleanup [53].
  - Steam build review is running up to 12 business days, and new pre-review checks apply from 2026-11-04 [54].
  - October Next Fest had about 7,300 demos, against about 4,400 in June. Developers report AI clones and extortion attempts [55].
- **Hits:** no well-sourced commercial hit attributable mainly to AI assistance was found. Reporting instead shows tiny teams prototyping faster, more cloning, and fewer artist and junior roles [58].
- **Jam games decay fast.** Vibe Jam entries rot quickly: about 42% of 2025 entries and 13% of 2026 entries are offline, with backend-dependent games dying first (secondary analysis) [59].

**Implication:** speed alone stopped being a differentiator. Originality, craft, community and honest disclosure are what separate a game from the flood.

---

## 11. How GameForge Uses This

GameForge's core bet is unchanged: Claude is strongest where it is the intelligence layer. It reads code, traces systems, spots patterns and produces structured plans. External AI runtimes (asset generators, NPC models, playtest agents) are tools that skills plan around, log and govern.

| Need | Skill | What it does with this doc |
|---|---|---|
| Build a game with an agent loop | `/gameforge:game-vibe-code` | Spec, check, and small-diff loop; Playwright and `render_game_to_text` hooks; vibe-debt guardrails |
| Generate and govern assets | `/gameforge:game-ai-assets` | Tool and license matrix, provenance log, disclosure text for Steam, itch.io and the EU |
| Wire the engine to the agent | `/gameforge:game-godot-specialist`, `/gameforge:game-unity-specialist`, `/gameforge:game-unreal-specialist`, `/gameforge:game-threejs-specialist`, `/gameforge:game-web2d-specialist` | MCP setup, current APIs, engine-specific agent pitfalls |
| Set the studio's AI stance | `/gameforge:game-creative-director`, [AI content policy](../templates/ai-content-policy.md) | What is allowed, what is disclosed, who signs off |
| Architecture and MCP security | `/gameforge:game-technical-director` | Localhost-only servers, least privilege, review gates |
| Review agent-written code | `/gameforge:game-code-review` | Architecture, netcode trust and pattern review of MCP-generated changes |
| AI NPCs | `/gameforge:game-narrative-director`, `/gameforge:game-economy-designer` | Guardrails, function-call design, disclosure, cost model |
| Agent QA and analytical playtests | `/gameforge:game-qa-lead`, `/gameforge:game-playtest`, `/gameforge:game-balance-check` | Agent test loops as a supplement to human sessions |
| Localization | `/gameforge:game-localization-manager` | Hybrid pipeline and disclosure |
| Launch compliance | `/gameforge:game-launch`, `/gameforge:game-web-publish` | Steam survey, Microsoft 11.16, EU Art. 50, EAA, portal rules |
| Not sure where to start | `/gameforge:game-help` | Routes to the right skill |

---

## Sources

All accessed 2026-11-05. The date in parentheses is the publication or update date where known.

1. Stack Overflow Developer Survey 2026, AI coding agents: https://survey.stackoverflow.co/2026/ai/data/ai-code-agent (2026-10-06)
2. Anthropic, "Best practices for Claude Code": https://code.claude.com/docs/en/best-practices
3. OpenAI, `develop-web-game` skill: https://github.com/openai/skills/tree/main/skills/.curated/develop-web-game
4. Game Developer, "Anthropic appears to have ordered AI tool Claude to stop remaking video games": https://www.gamedeveloper.com/programming/anthropic-appears-to-have-ordered-ai-tool-claude-to-stop-remaking-video-games (2026-10-30)
5. Godot contribution policy: https://godotengine.org/article/contribution-policy-2026/ ; PC Gamer coverage: https://www.pcgamer.com/gaming-industry/open-source-game-engine-godot-will-no-longer-accept-ai-authored-code-contributions-we-cant-trust-heavy-users-of-ai-to-understand-their-code-enough-to-fix-it/ (2026-07-01)
6. Simon Willison, "Battle Drones": https://simonwillison.net/2026/Oct/20/battledrones/ (2026-10-20)
7. Unity, AI tools page: https://unity.com/features/ai
8. Unity Discussions, "Unity AI's open beta now live for Unity 6": https://discussions.unity.com/t/unity-ai-s-open-beta-now-live-for-unity-6/1718560 (2026-05-04) ; Unity, "Unity AI MCP: how to get started": https://unity.com/blog/unity-ai-mcp-how-to-get-started (2026-05-11)
9. Unity docs, "Unity's plugin for Claude Code": https://docs.unity.com/en-us/ai/unity-plugin/claude-code (updated Oct 2026)
10. Digital Production, Unreal Engine 5.7: https://digitalproduction.com/2025/11/12/unreal-engine-5-7-foliage-pcg-and-in-editor-ai/ (2025-11-12)
11. Epic Games, "Unreal MCP in Unreal Editor": https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor?lang=en-US (UE 5.8)
12. GamesBeat, "Epic Games launches Unreal Engine 5.8": https://gamesbeat.com/epic-games-launches-unreal-engine-5-8/ (2026-06-17) ; CG Channel, MetaHuman licensing: https://www.cgchannel.com/2025/06/you-can-now-sell-metahumans-or-use-them-in-unity-or-godot/ (2025-06-04)
13. GameFromScratch, Unity Spark: https://gamefromscratch.com/unity-announce-unity-spark-game-engine/ (2026-10-07)
14. Meshy, "Meshy 6 launch": https://www.meshy.ai/blog/meshy-6-launch (Jan 2026)
15. Tripo Smart Mesh P1.0 press release: https://finance.yahoo.com/sectors/technology/articles/tripo-ai-launches-smart-mesh-162600191.html (Mar 2026) ; Neural4D review: https://blog.neural4d.com/comparisons/tripo-3-1-model-review/
16. Runware, Rodin Gen-2: https://runware.ai/docs/models/hyper3d-rodin-gen-2 ; Scenario, Rodin Gen-2.5: https://help.scenario.com/articles/3791851266-rodin-hyper3d-gen-2-5-models-the-essentials
17. Tencent Hunyuan3D 2.1 license: https://raw.githubusercontent.com/Tencent-Hunyuan/Hunyuan3D-2.1/main/LICENSE
18. Microsoft TRELLIS.2-4B model card: https://huggingface.co/microsoft/TRELLIS.2-4B (paper 2025-12-16)
19. Cinevva, AI pixel-art generators: https://app.cinevva.com/guides/ai-pixel-art-generators ; Scenario, Retro Diffusion: https://help.scenario.com/en/articles/retro-diffusion-models-the-essentials/ ; Scenario textures: https://www.scenario.com/features/generate-textures
20. Move AI, Gen 2: https://www.move.ai/gen-2
21. Rokoko, "Introducing Rokoko Vision 3.0": https://www.rokoko.com/insights/introducing-rokoko-vision-3-0 (2026-07-16)
22. CG Channel, Cascadeur 2026.2: https://www.cgchannel.com/2026/08/nekki-releases-cascadeur-2026-2-with-animation-layers/ (2026-08-06)
23. The Decoder, ElevenLabs SFX v2: https://the-decoder.com/elevenlabs-releases-version-2-of-its-ai-sound-effects-model-with-longer-clips-and-better-audio-quality/ (Sept 2025)
24. Stability AI, Stable Audio 3: https://stability.ai/news-updates/meet-stable-audio-3-the-model-family-built-for-artistic-experimentation-with-open-weight-models (May 2026)
25. ElevenLabs, "Eleven Music, now available in the API": https://elevenlabs.io/blog/eleven-music-now-available-in-the-api
26. Music Business Worldwide, Suno litigation: https://www.musicbusinessworldwide.com/suno-fights-to-keep-warner-music-settlement-terms-away-from-umg-and-sony/ (Oct 2026)
27. PC Gamer, SAG-AFTRA ratification: https://www.pcgamer.com/gaming-industry/the-videogame-voice-actors-strike-officially-ends-as-performers-ratify-agreement-between-sag-aftra-and-publishers (July 2025) ; FKKS analysis: https://technologylaw.fkks.com/post/102mewu/inside-the-new-sag-aftra-interactive-media-agreement-new-standards-for-ai-and-di
28. Kotaku, ARC Raiders re-recorded lines: https://kotaku.com/arc-raiders-replaced-ai-generated-content-human-recorded-dialogue-voices-2000678774
29. TechCrunch, Genie 4: https://techcrunch.com/2026/10/27/googles-genie-4-world-model-adds-audio-more-realistic-worlds-and-real-time-steering/ (2026-10-27)
30. Engadget, Project Genie: https://www.engadget.com/ai/googles-project-genie-lets-you-generate-your-own-interactive-worlds-183646186.html (Jan 2026)
31. Microsoft Research, "Introducing Muse": https://www.microsoft.com/en-us/research/blog/introducing-muse-our-first-generative-ai-model-designed-for-gameplay-ideation/ (2025-02-19)
32. World Labs, Marble export docs: https://docs.worldlabs.ai/marble/export/gaussian-splat
33. NVIDIA, ACE Game Agent SDK and UE5 plugins: https://developer.nvidia.com/blog/build-on-device-ai-companions-with-the-nvidia-ace-game-agent-sdk-and-unreal-engine-5-plugins/ (2026) ; inZOI and NARAKA: https://www.nvidia.com/en-gb/geforce/news/nvidia-ace-naraka-bladepoint-inzoi-launch-this-month
34. Toolradar, Inworld pricing: https://toolradar.com/tools/inworld-ai/pricing (read 2026-10-09)
35. Convai, MetaHumans in Unreal Engine: https://home.convai.com/blog/real-time-ai-conversations-facial-animation-metahumans-unreal-engine-convai (2026-02-25)
36. AOL, Where Winds Meet AI NPC exploits: https://www.aol.com/news/where-winds-meet-players-using-115622558.html ; Eposyne, AI NPCs that shipped: https://www.eposyne.com/insights/ai-npcs-what-shipped-what-worked ; Fortnite, AI-powered conversations: https://www.fortnite.com/news/bring-npcs-to-life-with-ai-powered-conversations
37. CB Insights, modl.ai vs nunu.ai: https://www.cbinsights.com/compare/modlai-vs-nunuai ; modl.ai listing: https://aiagentstore.ai/ai-agent/modl-ai
38. Gridly, AI translation in game localization: https://gridly.com/blog/ai-translation-game-localization
39. GamesBeat, Accord: https://gamesbeat.com/accord-launches-ai-community-feedback-analyst-for-games/
40. Steamworks, Content Survey (AI section and FAQ): https://partner.steamgames.com/doc/gettingstarted/contentsurvey
41. Game Developer, "Valve tweaks and clarifies AI disclosure rules for Steam": https://www.gamedeveloper.com/business/valve-tweaks-and-clarifies-ai-disclosure-rules-for-steam (2026-01-16)
42. Microsoft Store Policies v7.20, §11.16 "Live Generative AI Content": https://learn.microsoft.com/en-us/windows/apps/publish/store-policies (2026-09-14)
43. European Commission, Article 50 FAQ: https://digital-strategy.ec.europa.eu/en/faqs/transparency-obligations-under-article-50-ai-act (updated 2026-07-24)
44. ActuIA, Omnibus (EU) 2026/1744 dates: https://www.actuia.com/en/news/ai-act-obligations-in-force-and-delays-under-omnibus-2026-1744/ (2026-10-06)
45. Reed Smith, Article 50 Code of Practice: https://www.reedsmith.com/our-insights/blogs/viewpoints/102nbz0/transparency-obligations-for-ai-generated-content-the-code-of-practice-adequacy/ (2026-07-28)
46. Travers Smith, European Accessibility Act now applies: https://www.traverssmith.com/knowledge/knowledge-container/a-new-milestone-for-accessibility-the-european-accessibility-act-now-applies/ (2025-06-27)
47. US Copyright Office, Copyright and AI Part 2: https://copyright.gov/newsnet/2025/1060.html (2025-01-29)
48. Holland & Knight, Thaler cert denied: https://www.hklaw.com/en/insights/publications/2026/03/the-final-word-supreme-court-refuses-to-hear-case-on-ai-authorship (Mar 2026)
49. Crail, Midjourney and Stability case status: https://www.crail.ai/blog/midjourney-disney-copyright-battle-status/ ; Andersen schedule: https://chatgptiseatingtheworld.com/2026/02/03/sarah-andersens-copyright-lawsuit-the-1st-filed-v-ai-companies-gets-pushed-back-again-at-her-request/ (2026-02-03)
50. Engadget, Indie Game Awards rescind Clair Obscur awards: https://www.engadget.com/gaming/the-indie-game-awards-snatches-back-two-trophies-from-clair-obscur-over-its-use-of-generative-ai-164730842.html (Dec 2025)
51. GDC, 2026 State of the Game Industry: https://gdconf.com/article/gdc-2026-state-of-the-game-industry-reveals-impact-of-layoffs-generative-ai-and-more/ (Jan 2026)
52. TweakTown, 2026 games-industry layoffs: https://www.tweaktown.com/news/114442/games-industry-layoffs-hit-10977-in-2026-already-surpassing-all-of-2025-with-months-to-go/index.html (Oct 2026)
53. VGC, "Itch mass deletes 'AI slop'": https://www.videogameschronicle.com/news/itch-mass-deletes-ai-slop-lets-users-filter-out-any-ai-assisted-games/ (2026-11-03) ; Aftermath: https://aftermath.site/itch-ai-games-pc-slop/ (2026-11-01)
54. Engadget, Valve changes Steam release rules: https://www.engadget.com/2306215/valve-changed-its-steam-release-rules-amid-a-flood-of-ai-games/ (2026-11-04)
55. Game Developer, Valve on Next Fest AI cloning: https://www.gamedeveloper.com/pc/valve-addresses-steam-ai-cloning-problem (2026-10-28)
56. Heise, Apple blocks updates for vibe-coding apps: https://www.heise.de/en/news/Apple-blocks-updates-for-vibe-coding-apps-11216835.html (2026-03-18)
57. Google Play Console Help, AI-Generated Content policy: https://support.google.com/googleplay/android-developer/answer/14094294?hl=en
58. Rest of World, AI and shrinking game teams: https://restofworld.org/2026/ai-video-games-developer-jobs/ (2026)
59. Vibe Jam link-rot analysis (secondary): https://www.michaelscheiwiller.com/blog/vibe-jam-link-rot ; Vibe Jam: https://vibejam.com/
60. XDA, Activision DMCA of AI-built Call of Duty ports: https://www.xda-developers.com/activision-hits-vibe-coded-classic-call-of-duty-browser-ports-with-dmca-takedowns/ (2026-10-11)
