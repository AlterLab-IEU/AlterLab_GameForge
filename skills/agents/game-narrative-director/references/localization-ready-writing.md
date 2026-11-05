# Localization-Ready Writing -- Rules for Writers and Script Authors

Load this before writing any player-facing text that will ship in more than one language, or
before setting up a line database. The localization pipeline, vendor choice and LQA belong to
`/gameforge:game-localization-manager`; this file covers what writers control at the source.
Numbers marked *rule of thumb* are planning heuristics, not standards.

---

## 1. Source-text rules

| Rule | Bad | Good |
|---|---|---|
| Never concatenate sentences from fragments | `"You found " + count + " " + item` | One string with placeholders: `"You found {count, plural, one {# {item}} other {# {item_plural}}}"` |
| Use named placeholders, not positional | `"%s gave %s to %s"` | `"{giver} gave {item} to {receiver}"` with a translator note for each |
| Plan for plurals beyond one/other | `"1 coins"` bugs | ICU MessageFormat plural categories (Arabic and Polish need more than two forms) |
| Plan for grammatical gender | `"The {npc} is angry"` | Store gender per noun/character; use `select` forms; or rewrite to avoid agreement |
| Avoid embedding text in art | Text in textures | Text rendered by the UI system from the string table |
| Avoid idioms and puns unless you budget transcreation | "It's raining cats and dogs" | Write the meaning; mark intentional wordplay `#loc:transcreate` |
| Keep one idea per string | A tooltip with three sentences joined in code | Three strings, or one string the translator can restructure |
| Do not reuse a string for two contexts | "Open" for a door and a menu | Two IDs: `door_open`, `menu_open` |
| Give every line a stable ID | Line text as key | `scene_speaker_nnn`, never reused after deletion |

ICU MessageFormat example:
```
quest_reward_coins = {count, plural,
  =0 {No coins this time.}
  one {You earned # coin.}
  other {You earned # coins.}}
```
Unity Localization, Godot's translation system (gettext PO/CSV), Unreal's localization dashboard
and web libraries (for example i18next or FormatJS) each support placeholders and plurals in
their own syntax; agree on one source format and convert in the pipeline.

---

## 2. Space and timing budgets

- **Text expansion** (*rule of thumb*): plan UI for translations 30% or more longer than English,
  and much more for very short strings (a 4-character English button can double). German, French,
  Russian and Brazilian Portuguese routinely run long; CJK runs shorter in characters but needs
  larger font sizes.
- **Hard limits** go in the line database per string: `max_chars`, or better, `max_width_px` at
  the target font size. Writers get a warning when the source already uses most of the budget.
- **Right-to-left** languages (Arabic, Hebrew) need mirrored layouts and bidirectional text
  support; decide early whether they are in scope.
- **Fonts:** confirm glyph coverage for every target script before writing stylized text that
  depends on a display font. Pixel fonts rarely cover CJK.
- **VO timing:** lip-synced or time-boxed lines need a duration budget; translated VO may run
  longer. Mark lines `#vo:timed` when animation or gameplay waits on them.

---

## 3. Context for translators (the cheapest quality win)

Every line record carries:
```
| ID | Speaker | Listener | Text | Context note | Tone | Max width | Placeholders | VO | Tags |
|---|---|---|---|---|---|---|---|---|---|
| dock_mara_002 | Mara | Player | Gone before dawn. | Mara lies; she helped the ship leave | curt, evasive | 420px | - | yes | branch:act1 |
```
- Context notes explain intent, subtext and who is speaking to whom; translators cannot see the
  scene.
- Mark lies, jokes, callbacks and foreshadowing explicitly; they are the lines most often
  flattened in translation.
- Maintain a **glossary** (names, invented terms, factions, items) with "translate / do not
  translate / transliterate" per entry, and a **style guide** per character (formality level,
  tu/vous choices, dialect).
- Screenshots or short clips for UI strings and key scenes cut query rounds dramatically.

---

## 4. Script-format specifics

- **ink:** no built-in string-table localization. Tag every line and choice with `#id:`; export
  text and IDs to your localization format; at runtime, swap text by ID. Avoid building sentences
  from ink variables inline; use placeholders resolved by the localization layer.
- **Yarn Spinner:** `#line:` tags generate string tables and VO file names; 3.2 adds descriptive
  line IDs. Use Yarn's built-in localization and markup for placeholders and plurals.
- **Dialogic 2:** uses Godot's translation system; check each alpha release's notes for
  translation changes before upgrading.
- **articy:draft X:** manages localization and VO states in the database; export per language.
- **Custom data:** store `{id, text, context, speaker, max_width, tags}` from day one; retrofitting
  context is the most expensive localization task there is.

---

## 5. Pseudo-localization and checks the agent can automate

Ask the agent to add (CI via `/gameforge:game-ci-pipeline`):
- **Pseudo-locale build:** replaces text with accented, padded strings (for example 35% longer,
  wrapped in brackets) to expose truncation, hard-coded strings and concatenation.
- **Hard-coded string scan:** grep UI and gameplay code for user-facing literals.
- **Placeholder parity:** every translation contains the same placeholders as the source.
- **Length check:** translated strings within `max_width_px` at the target font.
- **Missing ID check:** every scripted line has an ID; no duplicates; no orphans in string tables.

---

## 6. AI translation and disclosure

- Hybrid pipelines are common in 2026: machine translation for volume, LLM passes for tone and
  consistency against the glossary, human review for humor, culture and anything on the critical
  path. Platforms such as Gridly, Crowdin and Lokalise offer these workflows.
- **Steam treats AI-generated localization as disclosable content** (content survey rewritten
  2026-01-16). Log which languages and which string ranges used machine or LLM translation, and
  the human review level, so the disclosure is accurate.
- Never ship unreviewed machine translation for story-critical text; a mistranslated clue breaks
  the game, not just the sentence.
