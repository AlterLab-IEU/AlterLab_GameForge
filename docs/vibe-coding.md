# Building Games with AI Coding Agents

The shared GameForge reference on building games with Claude Code and similar coding agents, often
called "vibe coding." It covers where the practice stands in late 2026, which tools people use,
what works and what fails, how to verify an agent-built game, and the originality, security,
disclosure and distribution issues that come with it. GameForge skills cite this page; the
hands-on loop lives in the [game-vibe-code skill](../skills/workflows/game-vibe-code/SKILL.md).

**As of 5 Nov 2026.** Bracketed numbers point to the Sources list at the end. **Self-reported**
marks figures whose only source is the person who benefits from them. **Unverified** marks claims
GameForge's research could not confirm. Nothing here is legal advice.

## 1. Terms

- **Vibe coding.** Andrej Karpathy's coinage (2 Feb 2025): "fully give in to the vibes… and forget
  that the code even exists" [1]. By late 2025 the term had widened to mean any AI-assisted
  development [2].
- **Agent-built game.** GameForge's neutral term: a game whose code is mostly written by a coding
  agent under human direction.
- **Vibe debt.** Code that works but has no structural rationale anyone can explain, so no human
  or agent session can change it safely.
- **The check.** Anything the agent can run that comes back pass or fail: a typecheck, a build exit
  code, a scenario test, a screenshot compared against expectations [30].
- **Test hooks.** `window.render_game_to_text()` and `window.advanceTime(ms)`: the game exposes its
  state as text and lets tests step time deterministically [31].
- **Handoff file.** `progress.md`: original prompt, decisions, state and next steps, so a fresh
  session or agent can continue [31].

## 2. State of the practice, late 2026

### Reference cases

| Case | What happened | Evidence quality |
|---|---|---|
| fly.pieter.com (Feb 2025) | Pieter Levels built a browser flight-sim MMO in Three.js with Cursor, with no game-dev background [3]. Revenue came from in-world ad blimps sold to startups and a $29.99 jet: "$38,000/mo" on 3 Mar 2025 [4], then "$87,000 MRR… 320,000 people have now flown" on 11 Mar 2025 [5]. 404 Media reported the claims without verifying them [6]. By mid-2026 his bio reportedly lists it at "$0/m" [7]. | Revenue self-reported; the decline is unverified |
| Vibe Jam 2025 | 1,000+ games; rule: at least 80% of code and assets written by AI; judges included Karpathy [26] | Organizer's archive |
| Cursor Vibe Jam 2026 | 1 Apr to 1 May 2026; at least 90% of code by AI; 945 games and 242,212 players [25][27] | Organizer's figures |
| *A Game About Capybaras Delivering Food* | 2026 Gold winner: about 2 weeks with Claude Code, about 27k lines, 188+ commits, one Cloudflare WebSocket lobby [8][9] | Developer interview |
| Battle Drones (Oct 2026) | Simon Willison's browser RTS, built over 321 agent commits; "actually fun to play", though he reviewed "almost none of the code" [10] | Developer's own write-up |
| Astrocade | Text-to-game platform; $56M raised, about 5M MAU, 140M plays a month [11] | As reported by Fortune |

### The honest read

- **Quality ceiling.** Judge Tim Soret rated the best 2026 jam games at "3rd year student" level
  [8]. Non-coders get novelty, not quality [12].
- **No proven commercial formula.** GameForge's research found no well-sourced commercial hit
  attributable mainly to AI assistance; reporting shows tiny teams prototyping faster, with more
  cloning [13]. fly.pieter.com shows that a large existing audience plus a novel ad format can
  produce a spike, not a repeatable business [6][7].
- **Industry mood.** In the GDC 2026 State of the Industry survey (more than 2,300 respondents),
  52% said generative AI is harming the industry, up from 30% in 2025; 36% use it at work; code
  assistance is the second most common use after brainstorming [14].

## 3. Toolchain landscape

### Coding agents

Stack Overflow Developer Survey 2026 (published 6 Oct 2026), respondents who use AI coding agents,
**n = 12,255**, past-year use [15]. Respondents could name several agents, so shares sum past 100%.

| Agent | Share |
|---|---|
| Claude Code | 65.5% |
| GitHub Copilot | 58.7% |
| OpenAI Codex | 29.5% |
| Cursor | 25.5% |
| Google Antigravity | 16.0% |
| Gemini Code Assist | 14.6% |
| OpenCode | 13.6% |
| Windsurf | 6.5% |
| Replit Agent | 2.3% |

Cursor was the 2026 Vibe Jam's title sponsor [25]; both 2026 showcase games above were built with
Claude Code [9][10].

### App builders and text-to-game platforms

- **General app builders:** Bolt.new (Node in the browser via WebContainers; sponsored both Vibe
  Jams), Lovable, v0 and Replit Agent. None is a game tool [16][25].
- **Prompt-to-playable platforms:** Astrocade and Rosebud [11][17]. Engine-oriented builders such as
  Summer Engine (Godot-compatible) and SEELE (Unity export) exist, but most comparisons are written
  by the vendors themselves [17].
- **Unity Spark** (announced 7 Oct 2026): a browser-based, prompt-driven game maker publishing to
  Google's Playground; closed beta [18].

### Engine integrations

| Engine | Agent integration (as of 5 Nov 2026) |
|---|---|
| Unity | Unity AI open beta since 4 May 2026, with an official MCP server via the Unity CLI and an official Claude Code plugin (`/plugin marketplace add Unity-Technologies/unity-agent-plugin`, then `/plugin install unity@unity-agent-plugin`); needs Unity 6.0+ [19][74] |
| Unreal | UE 5.8 ships an experimental Unreal MCP plugin: editor-only, loopback-only, no authentication [20] |
| Godot | No official MCP server or `llms.txt`; Coding-Solo/godot-mcp is the main community server [21]. Godot's plain-text scenes and scripts are easy for agents to edit. |
| Blender | Community MCP server (ahujasid/mcp-for-blender) runs arbitrary Python over an unauthenticated socket [22] |

The Godot Foundation banned autonomous-agent and vibe-coded contributions to the *engine itself*
on 30 Jun 2026; games made with Godot are unaffected [23]. More detail on MCP setup is in
[MCP integrations](mcp-integrations.md).

### Stacks people actually ship

A secondary analysis of Vibe Jam entries found Three.js in about 60% of 2025 entries and 65% of 2026
entries, Phaser in 5-6%, and Godot rising from 5 games to 21 [24]. The jam recommends Three.js
[25]. A Phaser-published comparison reports fewer AI hallucinations with Phaser than with Kaplay or
Excalibur (vendor source) [28]. Three.js's own `llms.txt` calls `WebGLRenderer` the "default,
mature" path [29].

GameForge defaults, pinned on 5 Nov 2026 [75]:

| Target | Stack |
|---|---|
| 3D web | Vite 8.3 + `three@0.187.0` (r187) with `WebGLRenderer` |
| 2D web | Vite 8.3 + `phaser@4.2.1` (WebGL, Arcade physics) |
| Desktop or console path | Godot 4.7.2 stable (GDScript) |
| Verification | `playwright@1.64.1` |

Vite 8 requires Node 20.19+ or 22.12+ [76]. Godot's web export uses the Compatibility renderer
only, and C# projects cannot export to the web [77]. See also
[engine comparison](engine-comparison.md).

## 4. What works

1. **Give the agent a check.** Anthropic's guidance: "Give Claude something it can run that comes
   back pass or fail." Ask for evidence (the command and its output, or the screenshot), and run
   `/verify` after Claude says it is done so it builds, runs and looks at the app [30].
2. **Spec first, in a fresh session.** Have Claude interview you, write `SPEC.md`, then build from
   it in a new session with a clean context [30]. Critique before building: "First research and
   then critique this design. Only build after we have agreed…" [10].
3. **Keep `CLAUDE.md` short,** with the check command first. A rule that must never be broken
   belongs in a hook, not in more emphatic prose [30].
4. **Expose state and time.** OpenAI's `develop-web-game` skill standardizes
   `render_game_to_text()` and `advanceTime(ms)`, runs Playwright after every meaningful change,
   and treats screenshots as the source of truth [31].
5. **Debug with discipline:** change one variable at a time, fix the first new console error
   first, reset state between scenarios, test whole action chains (shoot, enemy HP, score) [31].
6. **Keep a handoff file.** `progress.md` with the original prompt, decisions and TODOs [31].
7. **Small diffs.** One mechanic per prompt; undo regressions rather than patching over them
   [33][34].
8. **Ask for fun explicitly.** "This game isn't fun enough yet. Make it a LOT more fun" [10].
9. **Have the agent build instruments.** Willison ran 1,200+ AI-vs-AI balance matches and had the
   agent build a debug tool he calls "effectively free" [10].
10. **Parallel sessions by subsystem.** The 2026 Gold winner ran 2-3 Claude Code sessions on
    separate subsystems, a fresh session per feature, and one long-lived session for
    context-heavy bugs; built the 3D map by hand in an editor; and spent most human time
    brainstorming, planning and playing [9]. Claude Code's `claude -w <name>` starts a session in
    its own git worktree [30].
11. **Determinism early.** Battle Drones' replays desynced because Chrome and Safari compute
    `Math.sin`/`Math.cos` differently; custom functions fixed it [10]. Use a fixed timestep, test
    at several frame rates, and use continuous collision detection for fast bodies (general physics
    advice) [71].
12. **Browser-driving tools for QA.** The developer of the jam entry Geobeat credits a
    browser-driving MCP for fast fixes [32].
13. **Checkpoints alongside git.** `/rewind` rolls code and conversation back, but does not restore
    files changed only by shell commands; it complements git [30].
14. **Independent review against the spec.** "Use a subagent to review … against SPEC.md … report
    gaps that affect correctness and skip style"; without "skip style", reviewers invent work [30].

## 5. What fails

- **Vibe debt.** An arXiv lifecycle study tracks AI-introduced issues over time; secondary reports
  say most are code smells (figures unverified) [36]. Repeated regeneration leaves code without
  "structural rationale" [37]. Agents "are bad at knowing when the structure underneath needs to
  change" [38].
- **The monolith.** A fly.pieter.com recreation cites a warning that single-file games pass 3,000
  lines (secondary) [35].
- **Client-trusted multiplayer.** fly.pieter.com ran on page globals; its creator's own mod
  overrides `checkCollisions` and `animate` [39]; a player reported someone "constantly hitting
  everyone at the same time" (6 Mar 2025) [40]; a researcher demonstrated an AI-assisted hack [41];
  the game reportedly survived a DDoS in its first week (secondary) [42].
- **Mobile performance.** A game smooth on an iPhone stuttered on a mid-range Android phone [34].
- **AI slop in feel and art:** bent limbs, floating guns, characters without distinct voices, crude
  sound effects [34]. Players and platforms now filter against it [55][70].
- **Backend dependence.** 42% of 2025 Vibe Jam entries and 13% of 2026 entries were already offline
  in a secondary analysis; backend-dependent games died fastest, static hosting survived best [24].

## 6. Verification patterns

| Check | Catches | Misses | Cost |
|---|---|---|---|
| Typecheck and build exit code | Broken imports, type errors, build config | Anything behavioral | Seconds |
| Scenario expectations on `render_game_to_text()` | Broken rules, scoring, state transitions, action chains | Rendering, feel | Seconds per scenario |
| Screenshots opened and described by the agent | Blank canvas, missing sprites, HUD mismatch, layout breaks | Subtle feel and timing | Low |
| Console-error gate | Runtime exceptions, failed loads | Silent logic bugs | Free |
| Golden state diff across a refactor (fixed seed) | Behavior changes during "pure" refactors | New bugs in untested paths | Low |
| Headless engine run (Godot `--headless`, fixed FPS) | Script errors, state after N frames | Rendering | Seconds |
| Spec-gap review in a fresh subagent | Missing requirements, untested edge cases | What the spec forgot | Minutes |
| Human plays for two minutes | Fun, feel, confusion | Rare edge cases | Two minutes |
| Real mid-range Android phone | Frame drops, touch, audio unlock, memory | Desktop-only issues | Minutes |

The copy-paste harness (hooks, Playwright script, scenario format, Godot smoke test) is in the
skill's [verification harness reference](../skills/workflows/game-vibe-code/references/verification-harness.md).

## 7. Originality and IP

- **Claude Code declines clones.** Around 27 Oct 2026 Anthropic added a rule: "Do not build a
  recreation of a specific existing game, even if it is renamed or called original." Anthropic
  says "Original games, genre games, and games built from your own designs and assets are meant to
  keep working." Developers report some false refusals [47][48].
- **Rights holders act.** Activision sent DMCA notices against AI-built Call of Duty browser ports
  (11 Oct 2026), including one built from assets exported from the original games [45]. Mega Crit
  sent DMCA notices over leaked *Slay the Spire II* source (7 Oct 2026) [46].
- **Stores manage volume, not copying.** Developers report AI clones of their games and emails
  threatening to clone a game unless they pay. Valve: "we don't want to be gatekeepers"; extortion
  is a police matter [49][50]. Some studios cancelled public playtests [46].
- **Human authorship.** The US Copyright Office's Part 2 report (29 Jan 2025): prompts alone are
  not enough for protection; human selection, arrangement and modification can be protected [51].
  The Supreme Court denied cert in *Thaler* on 2 Mar 2026 [52].

**GameForge's stance:** build original games, genre mechanics, and the user's own designs and
assets. Turn "make a clone of X" into an original design that keeps the mechanic the user loves.
Keep an asset provenance log (from the [AI asset log template](../templates/ai-asset-log.md)) and
an iteration log as provenance.

## 8. Security

- The server owns state, scores, matchmaking and purchases; clients send inputs [43][44].
- Discord's guidance for Activities: "Trust (the SDK), but Verify (via the API)" [43].
- No API keys in the client bundle; route paid API calls through your server [44].
- Audit `window` globals before anything goes online [39].
- Keep MCP servers on localhost and treat code-execution tools as arbitrary code execution
  [20][22].

## 9. Disclosure and regulation

| Platform | Rule as of 5 Nov 2026 |
|---|---|
| Steam | Disclosure since Jan 2024, rewritten 16 Jan 2026. Code assistants and other efficiency tools are exempt. AI content players consume (artwork, sound, narrative, localization) and marketing assets are disclosed; live-generated content needs described guardrails [53][54]. Valve declined a player-side AI filter (Oct 2026) [50]. |
| itch.io | Generative-AI disclosure feeds a "no AI" filter, extended to search on 3 Nov 2026; bulk AI uploads are banned as spam [55][56]. |
| Microsoft Store and Xbox-branded stores | Policy 11.16 covers live generative AI: disclose, keep output within policy, let players report [58]. |
| Apple App Store | No AI-specific ban; in Mar 2026 Apple blocked vibe-coding app updates under 2.5.2 (executing downloaded code), a risk for in-app game makers [59]. |
| Google Play | AI-Generated Content policy covers generative features; no labelling mandate found [60]. |
| PlayStation, Nintendo, Epic | No published mandatory AI-disclosure policy found [54]. |

**EU AI Act, Article 50** [61][62][63][64]:

| Date | Milestone |
|---|---|
| 2 Aug 2026 | Transparency obligations apply |
| 2 Dec 2026 | Machine-readable marking (50(2)) due for generative systems already on the market |
| 2 Feb 2027 | Detection interoperability |

- 50(1): AI NPCs and companions must disclose that they are AI unless obvious; the Commission's FAQ
  reads the exception narrowly [64].
- 50(2): providers mark generated output; source code is excluded [61].
- 50(4): for evidently artistic, creative, satirical or fictional works, deepfake disclosure must
  not hamper the work; the Guidelines read this narrowly [61].
- Not retroactive for media generated before 2 Aug 2026 [61]. Fines reach EUR 15M or 3% of
  turnover [62].

Also in force: the European Accessibility Act (since 28 Jun 2025) covers consoles, e-commerce
including in-game purchase flows, and communication features, with a services exemption for
microenterprises [72]. The 2025 SAG-AFTRA Interactive Media Agreement requires consent and
disclosure for digital voice replicas [73].

## 10. Distribution realities

- **Store flooding.** New itch.io pages per day "doubled in the past 2 months", almost all
  AI-made, while downloads and purchases did not grow [57]; on 3 Nov 2026 itch.io deleted
  "a couple terabytes of AI slop" [55][56]. Steam build review was taking up to 12 business days
  against a 3-5 day target, with new pre-review checks from 4 Nov 2026 [65]; October 2026 Next Fest
  had about 7,300 demos against about 4,400 in June [50].
- **Portal limits** (each portal's docs, accessed 5 Nov 2026):

| Portal | Initial download | Total |
|---|---|---|
| CrazyGames | 50 MB or less; 20 MB or less for the mobile homepage [66] | 250 MB and 1,500 files [66] |
| Poki | No numeric cap on the current page; older guidance under 8 MB; players leave after about 10 s [67] | Not stated |
| YouTube Playables | Under 30 MiB (should be under 15 MiB) [68] | Under 250 MiB; JS heap capped at 512 MB [68] |

- **Jams with AI rules:** Vibe Jam 2026 required a `widget.js` script tag on pain of
  disqualification and banned logins and loading screens [25]. Epic's AI MegaJam (12-15 Nov 2026,
  Unreal and UEFN) allows unlimited agents but makes AI optional [69]. The 2026 Reddit x Phaser
  hackathon explicitly rejected "obvious AI slop" [70].
- **Economics.** Plan distribution, community and retention, not novelty. Viral sponsor revenue
  decays, and every channel is flooded [7][57][65].

## 11. How GameForge skills fit in

| You want to | Run |
|---|---|
| Find an idea, then a one-page spec | `/gameforge:game-brainstorm`, then `/gameforge:game-vibe-code` |
| Build the game with an agent, verified iteration by iteration | `/gameforge:game-vibe-code` |
| Test one mechanic and throw it away | `/gameforge:game-prototype` |
| Run a jam schedule | `/gameforge:game-jam-mode` (with the vibe-code loop inside it) |
| Go deep on an engine | `game-threejs-specialist`, `game-web2d-specialist`, `game-godot-specialist`, `game-unity-specialist`, `game-unreal-specialist` |
| Generate art, audio or voice with provenance | `/gameforge:game-ai-assets` |
| Add multiplayer safely | `/gameforge:game-multiplayer` |
| Review agent-written code | `/gameforge:game-code-review` |
| Ship to itch.io, portals, Discord or a desktop wrapper | `/gameforge:game-web-publish`, then `/gameforge:game-launch` |
| Set the project's AI stance | `/gameforge:game-creative-director` with the [AI content policy template](../templates/ai-content-policy.md) |

GameForge's session hooks keep `production/session-state/active.md` in front of every session
([hooks](hooks.md)); the vibe-code loop adds `progress.md` and `docs/iteration-log.md` in the game
project ([directory conventions](directory-conventions.md)).

## Sources

1. Andrej Karpathy, X post, 2 Feb 2025. https://x.com/karpathy/status/1886192184808149383
2. Questera, "History of Vibe Coding", 28 May 2026. https://www.questera.ai/blogs/history-of-vibe-coding-karpathy-tweet
3. levels.io, "fly.pieter.com, my first vibecoded flight simulator", 22 Feb 2025. https://levels.io/full-multiplayer-python-websockets-game-ai
4. @levelsio, X post, 3 Mar 2025. https://x.com/levelsio/status/1896690611257844116
5. @levelsio, X post, 11 Mar 2025. https://x.com/levelsio/status/1899596115210891751
6. 404 Media (E. Maiberg), 5 Mar 2025. https://404media.co/this-game-created-by-ai-vibe-coding-makes-50-000-a-month-yours-probably-wont
7. Promptway (D. Ferraro), "…Then It Went to Zero", 24 Jun 2026. https://promptway.com/blog/pieter-levels-flight-sim-to-zero
8. levels.io, "Vibe Jam 2026 winners", 17 Jun 2026. https://levels.io/vibe-jam-2026-winners-quality
9. Wccftech (O. Sohail), capybara winner workflow, 13 Jul 2026. https://wccftech.com/ios-developer-made-capybara-game-using-vibe-coding-and-won-25000/
10. Simon Willison, "Battle Drones", 20 Oct 2026. https://simonwillison.net/2026/Oct/20/battledrones/
11. Fortune (A. Garfinkle), Astrocade raises $56M, 5 May 2026. https://www.fortune.com/2026/05/05/astrocade-raises-56-million-series-b-sequoia-video-games-platform-ali-amir-sadeghian/
12. Slate (L. O'Leary), 5 Apr 2026. https://slate.com/technology/2026/04/ai-vibe-coding-video-game.html
13. Rest of World, AI and game team sizes, 2026. https://restofworld.org/2026/ai-video-games-developer-jobs/
14. GDC, 2026 State of the Game Industry, Jan 2026. https://gdconf.com/article/gdc-2026-state-of-the-game-industry-reveals-impact-of-layoffs-generative-ai-and-more/
15. Stack Overflow Developer Survey 2026, AI coding agents, 6 Oct 2026. https://survey.stackoverflow.co/2026/ai/data/ai-code-agent
16. Altar.io, AI app builders compared (2026). https://altar.io/ai-app-builders-founders-comparison-2026/
17. Cinevva, "Best AI Game Generators in 2026". https://app.cinevva.com/guides/ai-game-generators-2026
18. GameFromScratch, Unity Spark, 7 Oct 2026. https://gamefromscratch.com/unity-announce-unity-spark-game-engine/
19. Unity docs, "Unity's plugin for Claude Code", updated 14 Oct 2026. https://docs.unity.com/en-us/ai/unity-plugin/claude-code
20. Epic docs, "Unreal MCP in Unreal Editor" (UE 5.8). https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor?lang=en-US
21. Coding-Solo/godot-mcp (GitHub). https://github.com/Coding-Solo/godot-mcp
22. ahujasid/mcp-for-blender (GitHub). https://github.com/ahujasid/mcp-for-blender
23. GameFromScratch, "Godot Say No To AI", 2 Jul 2026. https://gamefromscratch.com/godot-say-no-to-ai/
24. M. Scheiwiller, Vibe Jam link-rot analysis (secondary). https://www.michaelscheiwiller.com/blog/vibe-jam-link-rot
25. Cursor Vibe Jam 2026, official rules, accessed 5 Nov 2026. https://vibejam.com/
26. Vibe Jam 2025 archive, accessed 5 Nov 2026. https://vibejam.com/2025/
27. @levelsio, X post (945 games, 242,212 players), 1 May 2026. https://x.com/levelsio/status/2050213288609235424
28. Phaser News, "Phaser vs Kaplay vs Excalibur", 13 Apr 2026. https://phaser.io/news/2026/04/phaser-vs-kaplay-vs-excalibur-2d-web-game-framework
29. three.js `llms.txt`. https://threejs.org/llms.txt
30. Anthropic, "Best practices for Claude Code", accessed 5 Nov 2026. https://code.claude.com/docs/en/best-practices
31. OpenAI, `develop-web-game` skill (openai/skills, curated), via mirror, accessed 5 Nov 2026. https://mcp.directory/skills/develop-web-game
32. dmnshd (F. Isikci), "Vibe Jam 2026: Geobeat", 28 May 2026. https://dmnshd.gg/blog/vibe-jam-2026-geobeat
33. Summer Engine (vendor), "Cursor Vibe Jam 2026: The Complete Guide", 6 Jun 2026. https://www.summerengine.com/blog/cursor-vibe-jam-2026-guide
34. VL Studio, "Vibe-Coding a Game in 2026: What AI Builds, What Breaks", updated 2 Nov 2026. https://vlstudio.app/blog/vibe-coding-a-game-2026/
35. cedrickchee/vibe-jet (fly.pieter.com recreation). https://awesome.ecosyste.ms/projects/github.com%2Fcedrickchee%2Fvibe-jet
36. Liu et al., arXiv 2603.28592, Mar 2026. https://arxiv.org/abs/2603.28592
37. Waseem et al., "Vibe Coding in Practice", arXiv 2512.11922. https://arxiv.org/pdf/2512.11922
38. R. Fitzpatrick, "Vibe Jam 2026", 12 Apr 2026. https://ryanfitzpatrickio.pages.dev/blog/vibe-jam-2026/
39. levelsio, GitHub Gist, fly.pieter.com mod, 2 Mar 2025. https://gist.github.com/levelsio/cd46c0d3bbc1f5a06be715219fe9f74c
40. fly.pieter.com bug board, 6 Mar 2025. https://ideasandbugs.com/p/someone-hacked-the-game-and-is-constantly-hitting-everyone-at
41. @sw33tLie, X post, 26 Feb 2025. https://x.com/sw33tLie/status/1894834463915298971
42. Indie Hackers, fly.pieter.com feature (2025, secondary). https://www.indiehackers.com/post/tech/pieter-levels-used-ai-to-build-a-viral-flight-simulator-in-3-hours-with-no-background-in-game-development-7CPfMr1yRLEwH6cC8xhE
43. Discord Developer Docs, "Implementing IAP for Activities". https://docs.discord.com/developers/monetization/implementing-iap-for-activities.md
44. Indie Hackers, "Vibe coding has a security problem". https://www.indiehackers.com/post/vibe-coding-has-a-security-problem-vLxyPTrTlZVwDo76oqvr
45. XDA (P. O'Rourke), Activision DMCA takedowns, 11 Oct 2026. https://www.xda-developers.com/activision-hits-vibe-coded-classic-call-of-duty-browser-ports-with-dmca-takedowns/
46. Kotaku (L. Parker), 15 Oct 2026. https://kotaku.com/ai-vibe-coding-just-hit-the-video-game-industry-like-an-avalanche-2000746366
47. Game Developer (B. Francis), Anthropic and game recreations, 30 Oct 2026. https://www.gamedeveloper.com/programming/anthropic-appears-to-have-ordered-ai-tool-claude-to-stop-remaking-video-games
48. 80.lv, "Claude Code Now Refuses to Recreate Existing Video Games", 2 Nov 2026. https://80.lv/articles/claude-code-blocks-video-game-cloning-some-reverse-engineering-tasks
49. Game Developer (I. Khan), Valve on Next Fest AI cloning, 28 Oct 2026. https://www.gamedeveloper.com/pc/valve-addresses-steam-ai-cloning-problem
50. Talkesport and GameSpot, Valve at Indie Connect, 27-28 Oct 2026. https://www.gamespot.com/articles/valve-knows-steam-next-fest-has-an-ai-slop-problem-and-its-looking-for-solutions/
51. US Copyright Office, Copyright and AI, Part 2, 29 Jan 2025. https://copyright.gov/newsnet/2025/1060.html
52. Holland & Knight, Thaler cert denied, Mar 2026. https://www.hklaw.com/en/insights/publications/2026/03/the-final-word-supreme-court-refuses-to-hear-case-on-ai-authorship
53. Game Developer (D. Riendeau), Steam AI disclosure rules, 16 Jan 2026. https://www.gamedeveloper.com/business/valve-tweaks-and-clarifies-ai-disclosure-rules-for-steam
54. Steamworks, Content Survey, accessed 5 Nov 2026; The Conversation via TechXplore, 11 Feb 2026. https://partner.steamgames.com/doc/gettingstarted/contentsurvey ; https://techxplore.com/news/2026-02-video-game-ai-players-patchy.html
55. VGC (R. Bevan), itch.io mass-deletes AI uploads, 3 Nov 2026. https://www.videogameschronicle.com/news/itch-mass-deletes-ai-slop-lets-users-filter-out-any-ai-assisted-games/
56. Heise, itch.io deletes terabytes of AI uploads, Nov 2026. https://www.heise.de/en/news/itch-io-deletes-terabytes-of-AI-slop-and-adds-search-filter-11510931.html
57. Aftermath (L. Plunkett), 1 Nov 2026. https://aftermath.site/itch-ai-games-pc-slop/
58. Microsoft Store Policies, 11.16, accessed 5 Nov 2026. https://learn.microsoft.com/en-us/windows/apps/publish/store-policies
59. Heise, "Apple blocks updates for vibe-coding apps", 18 Mar 2026. https://www.heise.de/en/news/Apple-blocks-updates-for-vibe-coding-apps-11216835.html
60. Google Play Console Help, AI-Generated Content policy, accessed 5 Nov 2026. https://support.google.com/googleplay/android-developer/answer/14094294?hl=en
61. Reed Smith, Article 50 transparency obligations, 28 Jul 2026. https://www.reedsmith.com/our-insights/blogs/viewpoints/102nbz0/transparency-obligations-for-ai-generated-content-the-code-of-practice-adequacy/
62. Cooley, "EU AI Act: Transparency Obligations Take Effect 2 August 2026", 3 Aug 2026. https://www.cooley.com/news/insight/2026/2026-08-03-eu-ai-act-transparency-obligations-take-effect-2-august-2026
63. EU AI Act, Article 50. https://artificialintelligenceact.eu/article/50/
64. European Commission, Article 50 FAQ, updated 24 Jul 2026. https://digital-strategy.ec.europa.eu/en/faqs/transparency-obligations-under-article-50-ai-act
65. Engadget (S. Dent), Steam release rule changes, 4 Nov 2026. https://www.engadget.com/2306215/valve-changed-its-steam-release-rules-amid-a-flood-of-ai-games/
66. CrazyGames Docs, technical requirements, accessed 5 Nov 2026. https://docs.crazygames.com/requirements/technical
67. Poki for Developers, requirements, accessed 5 Nov 2026. https://developers.poki.com/guide/requirements-quality
68. Google, YouTube Playables requirements, accessed 5 Nov 2026. https://developers.google.com/youtube/gaming/playables/certification/requirements_stability
69. Beebom, Epic Games' AI MegaJam 2026, 23 Oct 2026. https://beebom.com/epic-games-ai-megajam-2026-will-let-devs-vibe-code-games-for-cash-prize/
70. Phaser News, Reddit and Phaser hackathon, Jun 2026. https://phaser.io/news/2026/06/reddit-and-phaser-launch-a-40-000-game-dev-hackathon
71. Bugnet, physics QA articles. https://bugnet.io/blog/qa-testing-for-physics-based-games
72. Travers Smith, European Accessibility Act now applies, 27 Jun 2025. https://www.traverssmith.com/knowledge/knowledge-container/a-new-milestone-for-accessibility-the-european-accessibility-act-now-applies/
73. PC Gamer, SAG-AFTRA Interactive Media Agreement ratified, Jul 2025. https://www.pcgamer.com/gaming-industry/the-videogame-voice-actors-strike-officially-ends-as-performers-ratify-agreement-between-sag-aftra-and-publishers
74. Unity, "Unity AI Open Beta: How to get started with MCP", May 2026. https://unity.com/de/blog/unity-ai-mcp-how-to-get-started
75. npm registry metadata for three, phaser, vite, create-vite and playwright, queried 5 Nov 2026. https://registry.npmjs.org/
76. Vite, "Announcing Vite 8", 12 Mar 2026. https://vite.dev/blog/announcing-vite8
77. Godot docs, Exporting for the Web (4.7). https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html
