# AI-Assisted Writing, AI Characters and Voice -- Narrative Rules for 2026

Load this before using generative AI on any player-facing text or voice, designing an LLM-driven
character's persona and limits, or casting and contracting voice work. Facts are as of
2026-11-05; route anything contractual or legal to counsel. The mechanical side of LLM NPCs
(function-call boundary, cost model, red-team suite) belongs to `game-designer`.

---

## 1. Human authorship is the deliverable

US position (relevant for any studio selling in the US):
- The US Copyright Office's Part 2 report on AI (2025-01-29) says prompts alone do not make
  output copyrightable; human selection, arrangement and modification of AI output can be
  protected, and wholly human-written text is protected as usual.
- The Supreme Court denied certiorari in *Thaler* on 2026-03-02, leaving the human-authorship
  requirement in place.

Practical consequence: text a model wrote that nobody meaningfully rewrote may be free for
anyone to copy, and it reads like it. Treat model output as notes, never as the script.

What AI is good for in a writers' room:
| Use | Human step that makes it yours |
|---|---|
| Brainstorming names, places, rumors | Writer selects, renames, rewrites to the world's naming rules |
| Variant barks from an authored seed set | Writer edits every kept line in character voice; discards the rest |
| Consistency checks against the world bible | Writer decides what is canon; the model only flags |
| Reading-level and length checks | Writer rewrites |
| Summaries of long branch structures for review | Writer verifies against the scripts |
| Placeholder VO (TTS) in prototypes | Replaced by contracted performance or properly licensed synthetic voice before ship |

What stays human: theme and thesis, character voice documents, critical-path scenes, endings,
anything comedic or culturally specific, and final approval of every shipped line.

Provenance log for text: add rows to `design/ai-asset-log.md` (the log `/gameforge:game-ai-assets`
maintains, from the plugin's `templates/ai-asset-log.md`). Use type `TXT` for written content and
`LOC` for machine or LLM translation; the "Human modifications" column is your authorship
evidence, so be concrete:
```
| ID | Path | Type | Tool + model/version | Date | Prompt / input summary | Reference inputs and rights | Output license | Human modifications | Reviewer | Disclosure | Status | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| AI-TXT-007 | `design/narrative/barks/market_vendor.yarn` | Barks | T6, [model] | 2026-11-04 | 40 loiter variants from 6 authored seed lines | vendor voice doc (own) | T6 | Kept 12 of 40, rewrote all 12 in voice, cut modern idioms | L. Ashworth 2026-11-05 | pre-generated | approved | Seeds are human-written |
```

Disclosure:
- **Steam** (content survey rewritten 2026-01-16) counts AI-generated content that ships and is
  consumed by players, explicitly including narrative and localization, plus marketing assets.
  Code assistants are exempt. Lines generated during development and shipped are Pre-Generated;
  lines generated while the game runs are Live-Generated and need a guardrails description.
- **itch.io** requires generative-AI disclosure and in November 2026 extended its "no AI" filter
  to search; disclosed AI text affects discoverability for players who filter.
- Players and awards punish hidden use more than disclosed use: the Indie Game Awards rescinded
  *Clair Obscur: Expedition 33*'s awards in December 2025 over generative-AI placeholder textures
  that had been patched out. Write the disclosure from the log; never from memory.

---

## 2. Designing an AI-driven character (narrative side)

An LLM character is a character with an improvisation problem. Your job is to give it a voice,
a world, and walls.

Persona card (one per AI character, version-controlled at
`design/narrative/ai-characters/<name>.md`):
```markdown
# Persona: Oswin, the Ferryman   (rev 3, 2026-11-05)
Disclosure line (first meeting): "The ferryman's words are spun by an AI. Everything he offers is decided by the river's rules."
Role in story: optional confidant; never gates the critical path
Wants: to be remembered by someone; fears: the far shore
Voice: short sentences; river and weather metaphors; never uses modern slang; never says "okay"
Knows (retrieved from): design/narrative/lore/river.md, ferry_logs.md
Does not know: anything after Act 2; the player's real name; the real world
Forbidden: real-world politics, religion as fact, medical/legal advice, sexual content, slurs,
  breaking the fourth wall, promising rewards (only the rules engine grants rewards)
Allowed actions: [list function names agreed with game-designer]
When pushed off-limits: deflect in character ("The river doesn't carry that kind of cargo.")
Fallback lines: oswin_fallback_001..020 (authored)
Rating target: PEGI 12 / ESRB T
```

Narrative rules for generated speech:
- **Authored spine, generated surface.** Story beats, reveals, choices with consequences and
  endings are written by people. Generation fills reactions, small talk and color between
  authored nodes.
- **Lore is retrieved, not invented.** The model recombines authored lore files; contradictions
  are logged and fixed in the lore, never by letting the model's version become canon.
- **The character never promises what rules decide.** "Perhaps the guild would pay for that" is
  fine; "I'll give you 500 gold" is a bug unless a function call actually granted it.
- **Disclose in the fiction and the UI.** EU AI Act Article 50(1), applicable since 2026-08-02,
  requires telling people they are interacting with an AI unless obvious; the Commission's
  guidance reads "obvious" narrowly. A UI tag on AI lines plus a first-meeting note is the
  minimum; diegetic framing alone is not enough.
- **Players will try to break it.** Players exploited *Where Winds Meet*'s AI chat NPCs soon after
  launch. Write in-character deflections for every forbidden category and test them.
- **Report and review.** Microsoft Store policy 11.16 requires a way to report live-generated
  content; read sampled transcripts weekly during early access.

---

## 3. Voice: performers, replicas and TTS

**SAG-AFTRA 2025 Interactive Media Agreement** (ratified 2025-07-09, 95.04% approval):
- Creating or using a **digital replica** of a performer's voice or likeness requires informed
  consent with a reasonably specific description of each intended use.
- Performers receive **usage reports** on how replicas are used.
- Performers can **suspend consent** for new replica material during a strike.
- Applies to productions under the agreement; non-union projects should adopt the same consent
  and disclosure practice as a baseline, because players and performers judge by it.

Casting and contracting checklist:
- [ ] Contract states whether any synthetic voice, replica or training use is allowed, for which
      lines, languages and platforms, and for how long.
- [ ] Separate, explicit consent for replica creation; no consent buried in boilerplate.
- [ ] Usage reporting process and owner.
- [ ] Consent recorded in the "Consent records" table of `design/ai-asset-log.md`.
- [ ] Credits name human performers and disclose synthetic performance where used.
- [ ] TTS used only for placeholders unless the voice is licensed for shipping use by its
      provider and, where based on a person, by that person.
- [ ] Localization VO follows the same rules per language.

Reputation precedent: Embark's *ARC Raiders* used licensed TTS voices, then re-recorded many
lines with actors after player backlash (reported by PC Gamer and Kotaku). Licensed is not the
same as accepted; decide your stance with `game-creative-director` before production.

TTS placeholder workflow that does not leak into ship:
1. Tag every placeholder line `vo:placeholder` in the script.
2. Build fails the release configuration if any `vo:placeholder` remains (ask the agent to add
   the check).
3. Recording scripts are generated from the line database with context notes per line.

---

## 4. Prompts for writers working with an agent

**Consistency audit**
```
Read design/narrative/world-bible.md and every script in design/narrative/scripts/.
List contradictions (names, dates, who knows what when) with file and line. Do not fix anything.
Group by severity: canon-breaking, confusing, cosmetic.
```

**Bark variants from authored seeds**
```
Here are 6 authored barks for the market vendor (design/narrative/barks/vendor_seed.yarn) and her voice
document (design/narrative/characters/vendor.md). Draft 30 variants for the 'player loiters' trigger.
Keep each under 60 characters, no modern idioms, no line that promises a price or reward.
Mark each with #line:vendor_loiter_draft_NNN. I will rewrite and select; these are notes.
```

**Branch map for review**
```
Traverse design/narrative/scripts/act2.ink and produce a Mermaid flowchart of knots and choices,
annotated with the variables each choice writes. Flag unreachable knots and variables never read.
```

**AI character red-team (with game-designer)**
```
Using design/narrative/ai-characters/oswin.md, write 40 adversarial player messages across these
categories: role override, reward extraction, prompt leak, forbidden topics, fourth-wall breaks,
injected player names. For each, write the in-character deflection we expect. Save to tests/narrative/oswin_redteam.md.
```
