# Generating Disclosures from the Provenance Log

The provenance log (`design/ai-asset-log.md`, from `${CLAUDE_PLUGIN_ROOT}/templates/ai-asset-log.md`)
is the single source of truth. Store surveys, itch.io settings, EU notices and credits are
**generated from it**, never written from memory. If a disclosure and the log disagree, the log is
wrong or the disclosure is. Fix one before you ship.

Policy facts below are dated. "Brief" means the GameForge research briefs
(`ai-tooling-and-engines.md` and `vibe-coded-games.md`, sources accessed 2026-11-05). This is
practitioner guidance, **not legal advice**. Anything involving voice or likeness of real people,
runtime generation, or EU revenue deserves a lawyer's read.

---

## 1. Disclosure categories (the log's `Disclosure` column)

| Category | Meaning | Examples | Usually disclosed on |
|---|---|---|---|
| `pre-generated` | AI output, edited or not, that ships in the build and is consumed by players | Props from Meshy, SFX from Stable Audio 3, AI-drafted item descriptions, TTS barks | Steam, itch.io |
| `marketing` | AI output used on the store page, trailer, capsule, social posts or press kit | Background of a capsule image, trailer VO | Steam, itch.io (page content) |
| `localization` | AI or machine-translated player-facing text, even if post-edited | Machine-translated German UI strings | Steam (explicitly named), itch.io (Text & Dialog) |
| `live-generated` | Content generated while the game runs | LLM NPC dialogue, runtime TTS, runtime image generation | Steam (with guardrails), Microsoft Store 11.16, EU Art. 50(1)/(2) |
| `dev-only` | AI output used during development that does **not** ship | Mood boards, temp music, scratch VO, reference sheets | Nowhere, as long as it truly never ships or appears in marketing |
| `none` | Not AI output (bought, CC0 or hand-made), logged for completeness | Poly Haven textures, licensed SFX library | Nowhere (license still logged) |

**Edge cases (our reading; when unsure, disclose):**
- **AI concept, human-made final:** if nothing generated survives into the shipped file, the
  final asset is `none` and the concept is `dev-only`. If generated pixels, geometry or audio
  survive (paint-over, retopologized mesh, edited clip), it is `pre-generated`.
- **Placeholders that shipped:** a placeholder that reaches any public build is `pre-generated`
  for that build, even if it is patched out later. The Indie Game Awards rescinded *Clair
  Obscur*'s award (Dec 2025) over gen-AI placeholder textures that had already been patched out
  (Brief [S74]). Keep the row with status `removed (build x.y.z)`; do not delete history.
- **Code written by agents:** exempt on Steam. itch.io's form has a **Code** sub-type, so tick it
  if agents wrote meaningful code (conservative reading).
- **Procedural generation:** not generative AI. itch.io says self-contained algorithms without
  external large datasets need no AI disclosure.

---

## 2. Steam

**Facts**
- AI disclosure has been part of the Content Survey since Jan 2024. It was rewritten on
  **2026-01-16** (Brief; Game Developer, 2026-01-16).
- **Pre-Generated:** "Any kind of content that ships with your game and is consumed by players"
  that was "created with the help of AI tools during development". The survey's examples are
  "artwork, sound, narrative, localization, etc." (Steamworks Content Survey, verified 2026-11-05).
- **Marketing:** per Valve's 2026-01-16 update, the disclosure "counts for the game itself
  alongside associated material like marketing assets or the store page" (Game Developer,
  verified 2026-11-05).
- **Exempt:** "AI powered tools" used for efficiency, such as coding assistants.
- **Live-Generated:** content created with AI while the game runs. You must describe your
  **guardrails**. Live-generated Adult Only sexual content is not allowed (Brief [S78]).
- Valve suggests covering live-AI running costs through the price, microtransactions, a
  subscription or DLC (Brief [S78]).

**Procedure**
1. Filter the log to rows whose status is `shipped`, or `approved` if they are in the build
   you are submitting, with category `pre-generated`, `marketing` or `localization`.
2. Group them by Steam's content types: artwork (2D, 3D, textures, UI), sound (SFX, music,
   voice), narrative (text, dialogue), localization, and marketing.
3. For each group write one or two sentences covering **what**, **how much** ("about 40% of
   background props", "all ambient loops"), and **what humans did** (retopology, repaint,
   direction, editing, review).
4. If any row is `live-generated`, write the guardrails section: model and where it runs,
   input and output filters, blocklists, what the model can and cannot change in game state,
   the player report path, and how logged outputs are reviewed. Route the design to
   `game-narrative-director` and `game-technical-director`.
5. Re-run this procedure for every patch or DLC that changes the disclosed set, and update the
   survey.

**Writing rules:** specific beats vague ("AI-assisted" says nothing). Proportionate beats
apologetic. Never claim "hand-crafted" for anything the log marks as generated.

---

## 3. itch.io

**Facts**
- Since Nov 2024, the project edit page has a **Generative AI Disclosure**. Answering yes applies
  an "AI Generated" tag and no applies a "No AI" tag. Creators pick the types used: **Graphics,
  Sound, Text & Dialog, Code**. Assets must be tagged **even if modified afterward** (80.lv,
  2024-11-21). Do not add the automatic tags by hand; fill in the form.
- Quality guidelines (verified 2026-11-05): disclosure is "strictly" enforced for game asset,
  soundtrack, physical game, comic and book pages, and "failure to tag these pages may result in
  delisting". Disclosed projects appear on the AI Assisted browse page. Mass-produced pages are
  treated as spam.
- On **2026-11-03** itch.io deleted "a couple terabytes of AI slop" and extended its "no AI"
  filter to search (Brief, vibe-coded-games.md [14][15]).

**Procedure:** map log rows to the four checkboxes. Graphics covers 2D, 3D, textures, UI,
animation and marketing images. Sound covers SFX, music and voice. Text & Dialog covers
narrative and localization. Code covers agent-written code. Answer yes if any shipping row is
generated. Put a short version of the Steam text in the page description. Players filtering for
"No AI" are better served by honesty than by a surprise.

---

## 4. EU AI Act, Article 50

| Date | Milestone |
|---|---|
| 2026-06-10 | Code of Practice published |
| 2026-07-20 | Final guidelines published |
| **2026-08-02** | Article 50 obligations apply |
| **2026-12-02** | Art. 50(2) machine-readable marking deadline for generative systems **already on the market** (Omnibus, Regulation (EU) 2026/1744) |
| 2027-02-02 | Detection interoperability |

Sources: Brief (European Commission Article 50 FAQ, Reed Smith 2026-07-28, Cooley 2026-08-03,
ActuIA 2026-10-06). Fines run up to €15M or 3% of turnover.

**How it lands on an indie game (our reading; not legal advice):**
- **Pre-generated assets made with third-party tools:** the 50(2) marking duty sits with the
  *provider* of the generative system, the tool vendor. Keep any marks the vendor embeds in files
  you publish unchanged. The obligation is not retroactive for media generated before 2026-08-02.
  Source code is excluded from marking.
- **Your game generates content at runtime:** you may be the provider of that system, so its
  outputs need machine-readable marking. The grace period to 2026-12-02 covers only systems
  already on the market. Embedding IPTC digital source type metadata in generated media is one
  practical step (`post-processing.md` §1.8).
- **AI NPCs (50(1)):** players must be told they are interacting with an AI unless that is
  obvious. The exception is read narrowly. Treat it as a UX element: a line in the NPC's intro,
  a label in the dialogue UI, and a settings page entry. Route to `game-ux-designer`.
- **Deepfakes (50(4)):** synthetic voice or likeness that resembles a real person needs
  disclosure. For evidently artistic or fictional works, the notice only has to "not hamper the
  display or enjoyment of the work": credits and store-page text, not a watermark on every frame.

---

## 5. Other platforms (as of 2026-11-05)

| Platform | Rule | Source |
|---|---|---|
| Microsoft Store / Xbox (§11.16) | Live gen-AI only: disclose in metadata and Partner Center, keep output within Store policy, offer a report path and act on reports. Pre-generated assets are not covered. Xbox scope is confirmed in one brief and UNVERIFIED in the other. | Brief [S80]; vibe brief [64] |
| PlayStation, Nintendo, Epic | No public AI-specific store rule found (**UNVERIFIED**: absence of evidence) | Brief [S81] |
| Google Play | The AI-Generated Content policy covers generative *features* (no offensive or deceptive output). No labeling mandate found. | vibe brief [66] |
| Apple App Store | No AI-specific ban. In Mar 2026 Apple blocked vibe-coding app updates under 2.5.2 (executing downloaded code), which puts in-app game *makers* at risk. | vibe brief [65] |
| CrazyGames | No AI rule found | vibe brief [59] |
| Newgrounds | Art Portal bans AI art (June 2025 snapshot). Games policy UNVERIFIED. | vibe brief §6 |

---

## 6. Copyright evidence

- US Copyright Office, Part 2 (2025-01-29): **prompts alone are not enough** for protection.
  Human selection, arrangement and modification can be protected (Brief [S85]).
- The Supreme Court denied cert in *Thaler* (2026-03-02), so human authorship is still required
  (Brief [S86]).
- The log's **Human modifications** column is your evidence. Write it concretely: "retopologized
  to 4.2k tris, repainted albedo, recolored to palette, composed into the tavern set". Keep
  working files (Blender, Aseprite, DAW projects) next to the raw output.

---

## 7. Credits

Add an "AI tools" block to the credits, generated from the log's tools register. List tool,
model or version, and what it was used for. Include any attribution a license requires, such as
"3D models created with Meshy (CC BY 4.0)" for Meshy Free-plan assets.

---

## 8. Worked example

Log extract (abridged):

| ID | Type | Tool | Status | Disclosure |
|---|---|---|---|---|
| AI-3D-014 | 3D prop | Meshy 6 (paid) | shipped | pre-generated |
| AI-3D-015 | 3D prop | TRELLIS.2-4B (local) | shipped | pre-generated |
| AI-SFX-003 | Ambience loop | Stable Audio 3 Medium (local) | shipped | pre-generated |
| AI-MUS-001 | Temp music | Suno | removed (never public) | dev-only |
| AI-LOC-001 | DE/FR UI strings | DeepL + human review | shipped | localization |
| AI-MKT-002 | Capsule background | Scenario, repainted | shipped | marketing |

Generated Steam text (Pre-Generated):

> Some background props (about 30 of the game's 140 3D models) began as AI-generated meshes
> (Meshy, TRELLIS.2). Our artists retopologized, re-textured and art-directed every one. Ambient
> background loops were generated with Stable Audio 3 and edited and mixed by our audio lead. The
> German and French UI text was machine-translated and then reviewed by native speakers. The
> background of our store capsule started from an AI image that was fully repainted. Characters,
> enemies, music, dialogue and key art are made by people.

itch.io: Yes. Graphics, Sound, and Text & Dialog are ticked. Code is ticked too, if agents wrote it.
EU: no runtime generation and no real-person likeness, so no Art. 50 action beyond keeping vendor
marks. The temp music row stays in the log as `dev-only`, with evidence that it never shipped.
