# Originality and Disclosure Reference

Read this when a request names an existing game, when any asset comes from outside the project, or
before a store page or jam entry goes live. Facts are as of 5 Nov 2026 and come from the GameForge
research briefs; sources are listed in `docs/vibe-coding.md`. This is practical guidance, not legal
advice. When a design sits close to a commercial game, or money is involved, talk to a lawyer.

## What happened in October and November 2026

| Date | Event |
|---|---|
| 7 Oct 2026 | Mega Crit sent DMCA notices over leaked *Slay the Spire II* source code (Kotaku, 15 Oct 2026). |
| 11 Oct 2026 | Activision took down AI-built Call of Duty browser ports with DMCA notices, including "Claude of Duty: Vibe Slops II", which used assets exported from the original games (XDA). |
| ~27 Oct 2026 | Anthropic added a Claude Code rule: "Do not build a recreation of a specific existing game, even if it is renamed or called original." Anthropic: "Original games, genre games, and games built from your own designs and assets are meant to keep working." Developers report some false refusals (Game Developer, 30 Oct; 80.lv, 2 Nov). |
| 27-28 Oct 2026 | At Valve's Indie Connect, developers described AI clones and emails threatening to clone their game unless they paid. Valve: "we don't want to be gatekeepers"; extortion is a police matter. Some studios have cancelled public playtests. |
| 3 Nov 2026 | itch.io deleted "a couple terabytes of AI slop" and extended its "no AI" filter to search. |
| 4 Nov 2026 | Steam began new pre-review checks; build review was taking up to 12 business days against a 3-5 day target. |

The pattern: the tool declines clones, rights holders file takedowns, stores fight volume rather
than adjudicate copying, and players can filter AI work out. An original game avoids all four.

## The practical line

| Build freely | Never copy |
|---|---|
| Genre mechanics shared across many games: double jump, deckbuilding, tower placement, auto-attack waves, match-3 | A specific game's name, logo, characters or story |
| Your own designs, levels, art, audio and writing | Its art, sprites, models, textures or UI look, including "exported" or "ripped" files |
| CC0 or properly licensed packs, with the license recorded | Its music, sound effects or voice lines |
| "Inspired by" credits that describe mechanics | Its level layouts and maps |
| Feel targets described in your own words ("weighty jump, short hang time") | Decompiled, leaked or "ported" source code |

Renaming changes nothing; the Claude Code rule says so explicitly. Fan games need the rights
holder's permission and are out of scope for this skill.

## Converting a clone request

1. **Find the love.** One AskUserQuestion: "What do you love most about <game>?" with options for
   the core verb, the progression, the moment-to-moment feel, and the theme or mood.
2. **Name the mechanic neutrally.** "Roguelike deckbuilder: build a deck during a run, fight
   turn-based battles, choose paths on a branching map."
3. **Make three changes that matter:** a new fantasy and theme, a distinct art direction, and at
   least one rule twist that changes decisions.
4. **Run the distance test.** If any answer is yes, it is not done:
   - Could a player name the original from one screenshot?
   - From the title, a character name or the logo?
   - From the first level or map?
   - From the music or a sound effect?
   - Is any file in the project taken from the original or a rip?
5. **Record it** in `design/vibe-spec.md` under "Original design and distance from inspirations".

Worked examples:

| Request | Mechanic kept | Original direction | Rule twist |
|---|---|---|---|
| "Make Slay the Spire" | Roguelike deckbuilder with a branching map | A night-shift lighthouse crew; cards are crew orders | Your hand is shared with the storm, which plays one card each turn |
| "Make Among Us" | Hidden-role social deduction in short rounds | Rival bakers sabotaging a royal wedding cake | Sabotage leaves smells that fade over time instead of bodies |
| "Make Stardew Valley" | Seasonal farming and relationship life sim | Tending a floating garden on a whale's back | The whale migrates; seasons are places, not dates |
| "Remake Pac-Man" | Maze chase with power reversal | A moth collecting lantern light while bats hunt it | Light you collect also lights the bats' path to you |

For genre depth, GameForge's roguelike and narrative genre packs are in the plugin's
`genre-packs/` folder; `game-designer` and `game-brainstorm` use them.

## Handling refusals

- **A real clone request:** convert it as above. Do not rename the clone and retry; the rule
  anticipates that.
- **A false refusal on an original game:** state originality in the prompt, describe mechanics
  instead of saying "like <game>", and list your own names: "This is an original survivors-like.
  It does not recreate any specific game. The hero is Ilse, the setting is a tidal lighthouse, and
  all art and audio are ours."
- **Never ask an agent to extract, decompile or port another game's assets or code.** That is
  where the October 2026 takedowns landed.

## Provenance: what to log as you build

- **Asset log** (`design/ai-asset-log.md`, created from the plugin's `templates/ai-asset-log.md`
  and maintained with `game-ai-assets`): a row per asset when it is made or added, with tool or
  source, license, human modifications, reviewer and a disclosure category. Non-AI third-party
  assets get a row too, with disclosure `none`.
- **Iteration log** (`docs/iteration-log.md`): who wrote what. It backs a jam's AI-share rule
  (Vibe Jam 2026 required at least 90% AI-written code) and honest disclosure.
- **Human authorship:** the US Copyright Office's Part 2 report (29 Jan 2025) says prompts alone
  are not enough for protection, while human selection, arrangement and modification can be
  protected; the Supreme Court declined to hear *Thaler* on 2 Mar 2026. Your spec decisions,
  hand-built levels and chosen tuning values are a record of human authorship. Keep them.

## Disclosure by platform (as of 5 Nov 2026)

| Platform | Rule | For an agent-coded game |
|---|---|---|
| Steam | Disclosure required since Jan 2024; rewritten 16 Jan 2026. Efficiency tools such as code assistants are exempt. Disclose AI content shipped in the game, on the store page or in marketing (artwork, sound, narrative, localization). Two categories: pre-generated (reviewed like other content) and live-generated (describe your guardrails; no live-generated adult sexual content). Valve declined to add a player-side AI filter (Oct 2026). | Code alone: nothing to disclose. Any AI art, audio, text or translation that players see: disclose. |
| itch.io | Generative-AI disclosure on the project page feeds the "no AI" filter, which covers search since 3 Nov 2026. Bulk AI uploads are banned as spam. | Answer accurately. The research brief does not settle whether code assistance alone counts; read the form's current wording. |
| Microsoft Store (incl. Xbox-branded stores) | Policy 11.16 covers live generative AI: disclose in metadata and Partner Center, keep output within policy, let players report it. Pre-generated assets are not covered. | Only matters if the game generates content at runtime. |
| Apple App Store | No AI-specific ban. In Mar 2026 Apple blocked updates to vibe-coding apps under guideline 2.5.2 (executing downloaded code). | An in-app game maker that runs generated code is at risk. |
| Google Play | AI-Generated Content policy covers generative features (no offensive or deceptive output). No labelling mandate found. | Only matters for runtime generation. |
| PlayStation, Nintendo, Epic | No published mandatory AI-disclosure policy found (absence of evidence). | Check at submission. |
| Newgrounds | Art Portal banned AI art (June 2025 snapshot); games policy unverified. | Check before uploading. |
| Reddit Devvit hackathons | The 2026 Reddit x Phaser hackathon explicitly rejected "obvious AI slop". | Originality and polish are judged. |

## EU AI Act Article 50

| Date | Milestone |
|---|---|
| 10 Jun 2026 | Code of Practice published |
| 20 Jul 2026 | Final Guidelines published |
| **2 Aug 2026** | Article 50 obligations apply |
| **2 Dec 2026** | Machine-readable marking (50(2)) due for generative systems already on the market |
| 2 Feb 2027 | Detection interoperability |

What it means for a small game:

- **50(1), AI interaction:** AI NPCs and chat companions must tell players they are AI unless that
  is obvious. The European Commission's FAQ reads the "obvious" exception narrowly.
- **50(2), marking:** providers of generative systems mark their output machine-readably; source
  code is excluded. If your game generates images, audio or text at runtime, work out whether you
  or your model vendor is the provider.
- **50(4), deepfakes:** for evidently artistic, creative, satirical or fictional works, the notice
  must simply not hamper the work. The Guidelines read this narrowly.
- **Timing:** not retroactive for media generated before 2 Aug 2026 (per Reed Smith's analysis).
- **Fines:** up to EUR 15M or 3% of turnover.

The launch-time compliance checklist lives in `game-launch`; the project's AI stance belongs in
the plugin's `templates/ai-content-policy.md`.

## Wording you can adapt

Steam content survey, pre-generated section:

```
We used <tool> to generate first drafts of <12 background textures and 6 ambient loops>.
Every asset was reviewed and edited by <studio>. No AI-generated content is created during play.
```

itch.io description footer:

```
Built with Claude Code (AI-assisted programming). Art, music and sound: <own work / pack name + license>.
<AI-generated assets: none.>  or  <AI-generated assets: <list>, made with <tool>.>
```

In-game notice for an AI character (Art. 50(1)):

```
<Mara> is an AI character. Her replies are generated as you play and may be imperfect.
```
