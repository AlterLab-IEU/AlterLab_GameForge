---
name: game-market-research
description: >
  Researches the market for a game concept as a forked analyst: genre health, comparable titles with
  sourced numbers, market sizing, audience, 2026 store conditions, positioning and a go/no-go call,
  saved to design/market-research/. Use for "market research", "competitive analysis", "is this game
  viable", "will this sell". Not for generating ideas (use game-brainstorm).
argument-hint: "[game concept, genre, or path to a concept doc]"
effort: high
context: fork
allowed-tools: Read, Glob, Grep, Write, WebSearch, WebFetch
---

# AlterLab GameForge -- Market Research Workflow

Making a game nobody wants is easy. Finding the audience requires knowing where those players are,
what they already play, what they wish existed, and how crowded the space is, in the market as it is
now rather than as it was when the last famous indie hit launched. Market research is not about
copying what sells; it is about the gap between what players want and what exists, and whether this
team can reach those players through a channel it can actually win.

**How this skill runs.** It runs as a forked background analyst: no access to the conversation that
launched it, and no way to ask questions. It works from the argument, the project's files and the
web, states every assumption it had to make, and writes a sourced brief to disk. The person who
launched it reads the brief and re-runs with corrections if an assumption was wrong.

## When NOT to use me

| The user wants... | Route to |
|---|---|
| New game ideas, or turning "a game like X" into an original concept | `/gameforge:game-brainstorm` |
| Currency design, store pricing inside the game, monetization ethics | `/gameforge:game-economy-designer` |
| Store page, launch checklist, platform submission | `/gameforge:game-launch` (Steam, consoles, mobile) or `/gameforge:game-web-publish` (web) |
| Whether the scope fits the deadline | `/gameforge:game-scope-check` |
| Analytics and KPIs after launch | `/gameforge:game-analytics-setup` |

## Critical Rules

1. **Truth over validation.** The goal is an accurate picture, not confirmation that the idea is
   brilliant. "Saturated", "tiny audience" and "no-go" are valid findings.
2. **Every number has a source and a date,** or is labeled as an estimate or a rule of thumb. Never
   invent sales figures, revenues, conversion rates, eCPMs or player counts. If a number cannot be
   found, say so and give a labeled range or leave the cell empty.
3. **Research, do not recall.** Use WebSearch and WebFetch for current data. The baseline in
   `${CLAUDE_SKILL_DIR}/references/market-context-2026.md` is dated 2026-11-05; refresh any line the
   recommendation depends on.
4. **Recency.** Prefer data from the last 12 months. 2025-2026 changed the market: record-high Steam
   release volume, AI-content flooding, crowded festivals and a wave of layoffs.
5. **Indie scale.** Size the market for this team's budget, price and reach, not for a 200-person
   studio.
6. **Positioning is not a feature list.** "A Metroidvania with combat" is not positioning; "a
   Metroidvania where every ability is a musical instrument" is.
7. **State assumptions; never ask.** This skill cannot ask questions. When information is missing,
   pick a sensible default, write it in the Assumptions table, and say how the conclusion would
   change if it were wrong.
8. **Channel is part of the market.** Steam, itch.io, web portals, Discord and others have different
   audiences, gates and money models. Research the channels this game can realistically use.

## Step 0: Inputs and assumptions

Read, in this order, whatever exists:

1. The argument (concept text, genre, or a path to a concept document).
2. `.gameforge/project.json` (name, engine, phase, pillars).
3. `design/concept.md`, `design/concepts/`, `design/gdd/`, and earlier briefs in
   `design/market-research/`.
4. `production/session-state/active.md` for the current focus.

Then fill the Assumptions table. Defaults when nothing says otherwise:

| Assumption | Default | Why it matters |
|---|---|---|
| Team | Solo developer or 2-5 people, possibly with coding agents | Break-even and reach |
| Budget | Self-funded, near-zero marketing spend | Realistic share of the market |
| Primary channel | PC on Steam for premium games; web portals plus itch.io for short web games | Audience and money model |
| Price | Premium PC: within the range of the closest comparables found; web: free with ads | Revenue model |
| Timeline | 12-18 months to launch (premium); weeks (web) | Which trends will still matter |
| Languages | English at launch | Addressable market |
| Generative AI in shipped content | None unless the concept says so | Disclosure and audience sentiment |

If the concept is too vague to research (no genre, no platform, no player), say so in the brief,
research the most likely interpretation, and list the two or three alternatives that should be run
separately.

## Phase 1: Genre analysis

Questions:
- Primary and secondary genres; the defining expectations players bring.
- Lifecycle stage: emerging, growing, mature, oversaturated. Evidence, not vibes.
- Sub-genres and hybrids forming in the space.
- The last notable commercial success in the genre, and how recent it is.

Method: search "[genre] games 2026" and "[genre] steam 2026"; read the Steam tag page and SteamDB tag
data (count of games, recent releases, review distribution); check itch.io tags and, for short games,
portal categories; check whether creators and press cover the genre now.

```
GENRE ANALYSIS
---------------------------------------------------------------
Primary genre: [genre]          Secondary: [genre, genre]
Lifecycle stage: [emerging | growing | mature | oversaturated]  Evidence: [source, date]
Player expectations: [what the game must have to be taken seriously]
Recent notable releases: [title (year, source for performance)] x3
Health signals: [release volume, review distribution, creator interest, press] with sources
---------------------------------------------------------------
```

## Phase 2: Competitive landscape

Three tiers:
- **Direct:** same genre, same audience, similar mechanics and price.
- **Indirect:** same player need through a different genre or format.
- **Aspirational:** the execution or market position this team is aiming for.

Analyze at least 3-5 direct, 2-3 indirect and 1-2 aspirational competitors, and include a few median
or underperforming titles from the same tag so the picture is not a highlight reel. Use
`${CLAUDE_PLUGIN_ROOT}/templates/competitive-analysis.md` for the full structure.

```
COMPETITOR
---------------------------------------------------------------
Game: [name]   Type: [direct | indirect | aspirational]   Channel: [Steam / web / ...]
Price: [$]   Release: [date]   Reviews: [count, % positive] (Steam, [date checked])
Estimated sales/revenue: [range] ([Gamalytic / VG Insights / review-multiplier rule of thumb])
Differentiator: [what makes it stand out]
Common complaints: [from reviews or communities, quoted]
Relevance: [what it means for this concept's positioning]
---------------------------------------------------------------
```

## Phase 3: Market sizing

- **TAM:** players of this genre on any platform.
- **SAM:** players reachable on the target channels, at the price, in the supported languages.
- **SOM:** what this team can realistically capture in year one given marketing reach and
  competition. Build it from comparables, not from a percentage of TAM.

Methods (rules of thumb are labeled; see the reference for caveats):
- **Comparable titles:** 5-10 titles closest in genre, scope, price and team size, including medians
  and misses; estimates from Gamalytic or VG Insights where available.
- **Review multiplier (rule of thumb):** roughly 30-50 lifetime sales per Steam review; varies widely.
  Always show low, middle and high cases.
- **Wishlists:** if the project has wishlist data, use current published conversion ranges (search
  for them; cite source and date) and show low/middle/high cases.
- **Web channels:** no public sales data; size with plays, chart positions and the portal's published
  money model. Do not invent ad revenue per play.

Break-even: development cost (time valued honestly) against net revenue after the store cut, tax and
VAT, refunds, regional pricing and discounts, and engine terms (Unity Personal free below US$200K;
Unreal 5% above US$1M lifetime gross, 3.5% under Launch Everywhere; Godot free).

```
MARKET SIZING
---------------------------------------------------------------
TAM: [estimate] ([method, sources])
SAM: [estimate] ([channels, price, languages])
SOM year 1: low [N] / middle [N] / high [N] units or plays ([method])
Net revenue per unit after cuts: [$] ([assumptions listed])
Break-even: [units] at [$price]; middle case covers it: [yes / no]
Comparables used: [title: estimate (source, date)] x5+
---------------------------------------------------------------
```

## Phase 4: Audience profile

- **Motivations** (Bartle types, Self-Determination Theory; definitions in
  `${CLAUDE_PLUGIN_ROOT}/docs/game-design-theory.md`) and the emotional state players seek.
- **Behavior:** where they discover games (Steam browse, festivals, creators, TikTok, Reddit, Discord,
  portals), what convinces them (demo, trailer, reviews, price), tolerance for early access, typical
  session length.
- **Community signals:** active subreddits and servers; what they say they want and cannot find;
  the most common complaints about existing games (quote them with links).
- **AI sentiment in this audience:** whether these players filter or criticize AI-made content
  (itch.io's "no AI" filter, review threads, community rules). Matters if the game ships generated
  art, audio or voice.

```
AUDIENCE PROFILE
---------------------------------------------------------------
Primary audience: [1-2 sentences]
Motivations: [Bartle types + SDT needs]
Discovery channels: [ranked, with evidence]
Purchase drivers: [ranked]
Session length: [typical]
Community hubs: [links]
Unmet needs: [quoted, linked]
AI sentiment: [neutral / wary / hostile, with evidence]
---------------------------------------------------------------
```

## Phase 5: 2026 market conditions and trends

Read `${CLAUDE_SKILL_DIR}/references/market-context-2026.md` now. Summarize the conditions that touch
this concept, refreshed where the recommendation depends on them:

- **Volume:** about 19,000 Steam releases in 2025, about half with 10 or fewer reviews (SteamDB via
  GamingOnLinux, Dec 2025); October 2026 Next Fest had about 7,300 demos (vs. about 4,400 in June).
- **Flooding and cleanup:** itch.io new pages doubled in two months, mostly AI-made; on 2026-11-03
  itch.io deleted terabytes of AI uploads and extended its "no AI" filter to search. Steam added
  pre-review checks on 2026-11-04 with build review taking up to 12 business days.
- **Cloning:** AI clones and clone-extortion emails were reported in October 2026; Valve does not
  want to gatekeep. Weigh public demos of an easily copied mechanic against the visibility they buy.
- **Sentiment:** 52% of GDC 2026 respondents say generative AI is harming the industry; Steam
  disclosure of player-facing AI content is public. Position on the game, not on the tooling.
- **Labor:** 10,977 layoffs in 2026 by 2026-10-20; more experienced developers are going indie.
- **Genre and platform trends** specific to this concept, with sources: hybrids forming, Steam Deck
  verification, mobile or web shifts, upcoming releases in the same window, seasonal patterns.

## Phase 6: Channels

Read `${CLAUDE_SKILL_DIR}/references/channels-and-portals.md` when the game is short, browser-based,
social, or could ship on more than one channel. For each realistic channel, record fit, technical
gate, money model, competition on that channel, risk and a verdict (primary, secondary, skip).

## Phase 7: Positioning, price and timing

```
For [target audience] who want [core need],
[game] is a [genre] that [unique value].
Unlike [primary competitor], it [key differentiator].
```

Check the statement: Would a player care? Is the differentiator defensible, or easy to copy (and in
2026, easy for someone to clone with an agent)? Does it match the design pillars? Can one screenshot
or a five-second clip show it? Could a creator explain it in one sentence?

- **Price:** what direct comparables charge for similar content; the minimum price that reaches
  break-even in the middle case; free-with-ads only where the channel supports it.
- **Timing:** avoid launching within two weeks of a major competitor in the same tag; plan around
  Steam Next Fest (taking part requires a playable demo) and seasonal sales; pad for slower build
  review.

## AI-Assisted Workflow

This skill is itself an AI research agent; the rules below keep it honest.

- **Search wide, then fetch primary.** Use WebSearch to find candidates, then WebFetch the store
  page, SteamDB page, developer post or platform documentation before quoting a number. Quote
  secondary coverage only with its outlet and date.
- **Mark confidence.** Each figure is Sourced (primary or reputable press, dated), Estimated (a named
  estimation tool or method), Rule of thumb (labeled), or UNVERIFIED (one weak source). The executive
  summary may rest only on the first two.
- **Never fill gaps from memory.** A model's recollection of a game's revenue is not data. If search
  fails, say "not found" and widen the range.
- **Check for clones and AI-flooded categories.** Search the store for the concept's hook; if many
  low-effort AI-made games already occupy it, say so and explain what would make this one visibly
  different.
- **Disclosure as positioning input.** If the concept ships generated art, audio, voice or
  localization, note the Steam and itch.io disclosure it will carry and the audience's likely
  reaction; route asset decisions to `/gameforge:game-ai-assets`.
- **Hand-off.** End the brief with the exact follow-up runs: `/gameforge:game-brainstorm` to sharpen
  the hook, `/gameforge:game-prototype` to test it, `/gameforge:game-web-publish` or
  `/gameforge:game-launch` for the chosen channel.

## Output Format

Save as `design/market-research/<concept-slug>-<YYYY-MM-DD>.md`. If
`production/session-state/active.md` exists, append one line under **Next:** pointing to the brief.

```markdown
# Market Research Brief: [Concept]
**Date:** [YYYY-MM-DD]   **Analyst:** game-market-research (forked)   **Data as of:** [date range]
**Concept:** [1-2 sentences]   **Genre:** [primary / secondary]   **Channels:** [primary, secondary]

## Recommendation
**[Go / Go with changes / Pivot / No-go]** -- [3-5 sentences: the opportunity, the main risk, the
condition under which the call flips]

## Assumptions (stated because this ran without a conversation)
| Assumption | Value used | Source | If wrong... |
|---|---|---|---|
| Team | [solo + agents] | [project.json] | [break-even changes to ...] |

## Genre analysis
## Competitive landscape
### Direct   ### Indirect   ### Aspirational
## Market sizing (low / middle / high)
## Audience profile
## 2026 conditions that affect this concept
## Channels
| Channel | Fit | Gate | Money | Verdict |
|---|---|---|---|---|

## Positioning
**Statement:** [...]   **Differentiator:** [...]   **Price:** [...]   **Window:** [...]

## Risks
| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| [Clone risk after public demo] | M | H | [...] |

## Sources
| # | Claim | Source (URL) | Published | Accessed | Confidence |
|---|---|---|---|---|---|
| 1 | [About 19,000 Steam releases in 2025] | [link] | [2025-12-12] | [YYYY-MM-DD] | Sourced |

## Next runs
- [/gameforge:game-brainstorm to sharpen ...]
```

## Quality Criteria

- At least five direct or indirect competitors, each with a dated source; medians included.
- Sizing uses at least one quantitative method and shows low, middle and high cases.
- Every number in the executive summary is Sourced or Estimated, never recalled.
- Assumptions are explicit, with the effect of each being wrong.
- The 2026 conditions section is specific to this concept, not boilerplate.
- Channels are evaluated, including web portals for short games.
- The recommendation is honest, including "no-go".
- Calibrated to indie scale.

## Example Use Cases

1. **"Roguelike deckbuilder: is the market too crowded?"** Saturation focus: tag volume, review
   distribution of the last 12 months' releases, medians beside the hits, a sharp positioning test.
2. **"Farming sim or horror game: which is more viable for a two-person team?"** Two abbreviated
   runs side by side, with the same assumptions table, then a comparison.
3. **"Our game launches in three months; position us."** Phases 2 and 7, release-window scan, Next
   Fest timing, price check.
4. **"A 5-minute browser game: where should it live?"** Channel-first research: Poki, CrazyGames,
   YouTube Playables, Discord Activities, itch.io; gates and money models from the platforms' docs.
5. **"What genres are working for small indies right now?"** Phases 1 and 5 across several genres;
   a trend report rather than a full brief.
