---
name: "game-localization-manager"
description: >
  Use when the user asks about "localization", "translation", "i18n", "internationalization",
  "string extraction", "cultural adaptation", "RTL support", "CJK text", "EFIGS",
  or needs to prepare a game for global markets. Part of the AlterLab GameForge collection.
argument-hint: "[localization-scope or target-languages]"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
---

# AlterLab GameForge -- Localization Manager

This workflow guides indie teams through the full localization lifecycle: from writing localization-ready code on day one, through string extraction, translation management, cultural adaptation, and localization QA. Localization is not a post-launch bolt-on -- it is an architecture decision that costs 10x more to retrofit than to build in from the start.

---

## When to Start Localizing

The short answer: **now.** The long answer depends on what "localizing" means at each stage.

| Development Phase | Localization Work | Why Now |
|---|---|---|
| Pre-production | Choose an i18n framework. Establish string externalization conventions. Define a locale folder structure. | Retrofitting hardcoded strings into a localization system after 50K lines of code is brutal. Disco Elysium's 1M+ word script was localization-ready from the beginning -- and it still took years to localize fully. |
| Production (Alpha) | Extract all player-facing strings. Build the string pipeline (source file, export format, reimport flow). Set up pseudolocalization testing. | Strings added during production without going through the pipeline create "loc debt" that compounds. Every hardcoded string is a future bug. |
| Production (Beta) | Lock source strings (content freeze for localization). Send to translators. Begin cultural adaptation review. | Translators need stable strings. Changing source text after translation starts means paying for rework -- and rework introduces errors. |
| Polish | Localization QA (LQA). In-context review. Fix truncation, overflow, font rendering, and layout issues. | Text that fits in English will overflow in German (30% longer on average), collapse in CJK (different line-breaking rules), and reverse in Arabic/Hebrew (RTL). You will not find these issues without testing in every target language. |
| Post-launch | Community feedback. Patch localization bugs. Consider additional languages based on sales data. | Stardew Valley added languages post-launch driven by community demand and sales geography. Data tells you where to invest. |

**The Hades approach**: Supergiant built Hades with localization infrastructure from early access. By 1.0, it shipped in 10+ languages simultaneously. The key was not translating early -- it was building the pipeline early so translation could slot in cleanly when the text stabilized.

---

## Phase 1: String Extraction Pipeline

The foundation of localization is separating text from code. Every player-facing string must live in an external resource file, never inline in source code.

### Architecture: Localization-Ready Code from Day One

**The rule**: No player-facing string literal in source code. Ever.

```
BAD:  label.text = "Press any key to continue"
GOOD: label.text = tr("PROMPT_PRESS_ANY_KEY")
```

**String key conventions**:
- Use SCREAMING_SNAKE_CASE for keys: `MENU_START_GAME`, `DIALOGUE_NPC_GREETING_01`
- Prefix by context: `UI_`, `DIALOGUE_`, `ITEM_`, `TUTORIAL_`, `ERROR_`, `ACHIEVEMENT_`
- Never use the English text as the key. `tr("Press Start")` breaks when the English text changes. `tr("UI_PRESS_START")` survives any rewording.
- Include context comments for translators: a string like "Spring" could mean the season or the metal coil. Translators need to know which.

**String file formats by engine**:

| Engine | Native Format | Recommended Format | Notes |
|---|---|---|---|
| Godot | `.translation` / CSV | CSV or PO (gettext) | CSV is simple. PO supports plurals and context natively. |
| Unity | No native system | JSON, CSV, or PO via a plugin (I2 Localization, Lean Localization) | Unity's built-in localization package exists but is verbose. Most teams use a third-party asset. |
| Unreal | `.locres` / string tables | FText + string tables | Unreal's localization dashboard is powerful but has a learning curve. Use FText for all player-facing strings. Never use FString for displayed text. |
| Custom engine | Whatever you build | JSON or PO | JSON is easy to parse. PO is the industry standard with better tooling for translators. |

**Folder structure**:
```
localization/
  en/                    # Source language (English)
    ui.csv
    dialogue.csv
    items.csv
    achievements.csv
  de/                    # German
    ui.csv
    dialogue.csv
    ...
  ja/                    # Japanese
    ...
  ar/                    # Arabic
    ...
  _context/              # Context files for translators
    string_context.csv   # Key, context description, screenshot reference
  _tools/
    pseudoloc.py         # Pseudolocalization generator
    validate.py          # String validation (missing keys, format mismatches)
```

**Parameterized strings**: Never concatenate translated fragments. Word order varies by language.

```
BAD:  tr("You found") + " " + str(count) + " " + tr("coins")
GOOD: tr("LOOT_FOUND_COINS").format(count=count)
      # English: "You found {count} coins"
      # Japanese: "{count}枚のコインを見つけた" (coins comes first)
      # German: "Du hast {count} Munzen gefunden" (verb at end)
```

**Pluralization**: English has two forms (1 coin, 2 coins). Russian has three. Arabic has six. Use a pluralization system from the start -- gettext/PO handles this natively, JSON requires a custom solution.

---

## Phase 2: Translation Management Workflow

### Choosing a Translation Approach

| Approach | Cost | Quality | Speed | Best For |
|---|---|---|---|---|
| Professional agency | $0.10-0.25/word | High (with game context) | 2-6 weeks for EFIGS | Launch languages, marketing text, narrative-heavy games |
| Freelance translators | $0.05-0.15/word | Variable (vet carefully) | 1-4 weeks | Smaller scope, less common languages |
| Community translation | Free (but not zero-cost) | Variable (needs QA) | Unpredictable | Post-launch languages, community-driven games |
| Machine translation + human review | $0.02-0.05/word | Medium (with good reviewers) | Days | First draft, rapid iteration, non-narrative text |
| AI translation (LLM) | Near-zero marginal cost | Medium (improving rapidly) | Hours | UI strings, system messages, early prototyping. Not yet reliable for narrative or humor. |

**The Stardew Valley model**: ConcernedApe used a hybrid approach -- professional translation for initial EFIGS languages, then community-driven localization for additional languages (Korean, Turkish, Hungarian, etc.). Community translators were passionate fans who understood the game's tone. Quality was high because the community self-policed.

**The Genshin Impact model**: miHoYo runs 13 simultaneous language versions with a professional localization team embedded in the development pipeline. Every content update ships in all languages simultaneously. This requires an industrial-scale pipeline with dedicated localization producers, terminology databases, and automated QA -- realistic for a game earning $1B+/year, not for an indie team of five.

### Translation Management Tools

| Tool | Type | Pricing | Best For |
|---|---|---|---|
| Crowdin | Cloud TMS | Free for open-source, paid plans from $40/mo | Community + professional hybrid |
| Lokalise | Cloud TMS | From $120/mo | Professional workflow, API-first |
| POEditor | Cloud TMS | Free tier, paid from $15/mo | Small teams, budget-conscious |
| Weblate | Self-hosted (open source) | Free (hosting cost) | Full control, open-source projects |
| Google Sheets | Spreadsheet | Free | Absolute minimum viable approach (no TMS features) |

**Minimum viable pipeline**:
1. Export source strings to CSV/PO
2. Upload to TMS (or share spreadsheet with translators)
3. Translators work in TMS with context screenshots and glossary
4. Export translated strings back to locale files
5. Automated validation: check for missing keys, broken format strings, length violations
6. In-game review by native speakers

### Terminology Management

Create a glossary before translation begins. Game-specific terms must be consistent across the entire translation.

| Term Type | Example | Why It Matters |
|---|---|---|
| Game mechanics | "Boon" (Hades), "Perk" (Dead by Daylight) | Must be translated consistently everywhere -- UI, dialogue, tutorials, tooltips |
| Proper nouns | Character names, place names | Decide upfront: transliterate, translate, or keep original? |
| UI labels | "Inventory", "Save", "Load" | Platform conventions vary. Japanese console games use specific kanji for these. |
| Genre terms | "Roguelike", "Metroidvania" | Some communities keep English terms. Others have established local equivalents. |

---

## Phase 3: Cultural Adaptation Beyond Translation

Translation converts words. Localization converts meaning. Cultural adaptation converts experience.

### What Changes Beyond Text

| Element | Adaptation Needed | Example |
|---|---|---|
| Color symbolism | Red = luck (China), danger (West), mourning (South Africa) | UI color coding must be reviewed per market |
| Number formatting | 1,000.50 (US) vs 1.000,50 (Germany) vs 1 000,50 (France) | Every number display needs locale-aware formatting |
| Date formatting | MM/DD/YYYY (US) vs DD/MM/YYYY (EU) vs YYYY/MM/DD (Japan, ISO) | Date displays, save file timestamps, event schedules |
| Currency symbols | Position varies: $10 (US) vs 10 EUR (EU) vs 10,- (Netherlands) | In-game store, if showing real-money prices |
| Gesture meaning | Thumbs up is offensive in parts of the Middle East | Character animations, emotes, icons |
| Religious/political sensitivity | Skulls, crosses, blood, certain symbols | China requires removal of skulls/skeletons in some contexts. Germany has specific rules on Nazi symbolism. |
| Name entry | Fixed-length fields break for CJK. Some cultures use family name first. | Character creation, leaderboards, save files |
| Humor and idioms | Puns do not translate. Cultural references are local. | Undertale's humor required creative reimagining in every language, not direct translation. Fan translators spent months finding equivalent jokes. |

**The Disco Elysium challenge**: A 1M+ word game where the writing IS the gameplay. Translation was not just converting words -- it was recreating literary voice, political satire, and philosophical discourse in each target language. The Chinese localization team spent over a year on it. Some jokes and references were replaced with culturally equivalent ones rather than literally translated. This is localization at its hardest and most important.

### Content Sensitivity Review

Before entering a market, review content against local standards:

| Market | Key Sensitivities | Action |
|---|---|---|
| China | Skulls/skeletons, blood color, political content, religious imagery, gambling depiction | May require art modifications, not just text changes |
| Germany | Glorification of violence (less restricted since USK reclassification), Nazi symbols (strictly prohibited) | Review all historical/military content |
| Japan | CERO rating sensitivities, specific depictions of crime against minors | Rating review with local consultant |
| Middle East | Alcohol depiction, revealing clothing, LGBTQ+ content, religious references | Significant content review needed |
| South Korea | GRAC requirements, loot box probability disclosure, depictions of Japanese imperial imagery | Regulatory compliance review |

---

## Phase 4: RTL and CJK Support

These are the two hardest technical localization challenges. Plan for them early or pay for them later.

### Right-to-Left (RTL) Support: Arabic, Hebrew, Persian, Urdu

RTL is not "just flip the text." It requires rethinking your entire UI layout.

**What flips**:
- Text direction (obvious)
- UI layout (menus, HUD elements, progress bars fill right-to-left)
- Navigation flow (back button goes right, forward goes left)
- Icons with directional meaning (arrows, progress indicators)
- Scroll direction in horizontal lists

**What does NOT flip**:
- Numbers (Arabic numerals read left-to-right even in RTL text)
- Phone numbers, timestamps, mathematical expressions
- Media playback controls (play/pause/skip are universal)
- Game world (characters do not walk backward)

**Bidirectional (BiDi) text**: When RTL text contains English words, numbers, or LTR content, the text engine must handle mixed direction within a single line. This is where most custom text renderers break. Use a text engine with Unicode BiDi algorithm support (ICU library, HarfBuzz, or engine-native solutions).

**Engine-specific RTL support**:

| Engine | RTL Status | Notes |
|---|---|---|
| Godot 4.x | Native RTL support via TextServer | Uses HarfBuzz and ICU. Best built-in RTL support of the three major engines. Set `text_direction = RTL` on controls. |
| Unity | Via TextMeshPro + RTL plugin | TMP supports RTL but requires the Arabic Support asset or similar for proper shaping. |
| Unreal | Partial via Slate/UMG | UMG text blocks support RTL but layout mirroring requires manual work. |

### CJK (Chinese, Japanese, Korean) Support

CJK scripts have fundamentally different text properties than Latin scripts.

**Font requirements**:
- CJK fonts are massive (10,000+ glyphs vs. ~200 for Latin). Budget 5-20 MB per CJK font.
- You need separate fonts or a font with full CJK coverage. Latin fonts do not contain CJK glyphs.
- Noto Sans CJK (Google) is a free, high-quality option covering Simplified Chinese, Traditional Chinese, Japanese, and Korean.

**Line breaking**: CJK text does not use spaces between words. Line breaks can occur between almost any two characters, but there are complex rules about characters that cannot start or end a line (kinsoku shori in Japanese). Your text engine must implement CJK line-breaking rules or text will break in visually wrong places.

**Text length**: CJK translations are typically 30-50% shorter than English for the same meaning. German is 30% longer. Russian is 20% longer. Your UI must handle both extremes.

| Language | Typical Length vs. English | UI Impact |
|---|---|---|
| German | +30% | Buttons overflow, labels truncate |
| French | +20% | Minor overflow |
| Spanish | +15% | Minor overflow |
| Italian | +15% | Minor overflow |
| Japanese | -30% | Excess whitespace in fixed-width layouts |
| Chinese (Simplified) | -40% | Excess whitespace |
| Korean | -20% | Minor whitespace |
| Arabic | -10% to +10% | Varies; RTL layout is the bigger issue |

**Input methods**: CJK players use IME (Input Method Editor) for text entry. If your game has a name entry screen, chat, or any text input, it must support IME. This is a common failure point -- many games freeze or crash when an IME is activated.

---

## Phase 5: Localization Testing

### Pseudolocalization

Pseudolocalization replaces source strings with modified versions that simulate localization challenges WITHOUT requiring actual translation. Run it before sending anything to translators.

**What pseudolocalization catches**:
- Hardcoded strings that were not externalized (they appear in English while everything else is pseudolocalized)
- Truncated text (pseudoloc adds length to simulate German/French expansion)
- Broken layout from longer strings
- Concatenated strings that break in other word orders
- Missing Unicode support (pseudoloc uses accented characters)

**Pseudolocalization recipe**:
```
Original:  "Press Start"
Pseudo:    "[~Presses Startte~]"     # Brackets show string boundaries
                                      # Extra characters simulate expansion
                                      # Accents/tildes test Unicode rendering
                                      # Wrapping markers catch concatenation
```

**Tools**:
- Pseudolocalization libraries exist for most languages (Python: `pseudol10nutil`, JS: `pseudo-localization`)
- Crowdin and Lokalise have built-in pseudoloc generation
- Build your own with a simple character substitution script (a to a with accent, add 30% padding)

### Linguistic QA (LQA)

After receiving translations, native speakers must review every string in context -- not in a spreadsheet.

**LQA checklist**:
- [ ] Every string appears correctly in-game (no raw keys like `UI_PRESS_START` visible)
- [ ] No truncated text in any UI element
- [ ] All parameterized strings display correctly (`{count}` replaced with actual values)
- [ ] Pluralization works correctly (1 item, 2 items, 5 items -- test all plural forms for each language)
- [ ] Font rendering is correct for all scripts (no tofu/missing glyph boxes)
- [ ] RTL layout is mirrored correctly (if applicable)
- [ ] CJK line breaking looks natural (if applicable)
- [ ] Cultural adaptation is appropriate (colors, symbols, references)
- [ ] Terminology is consistent across all strings (same game term always translated the same way)
- [ ] No machine-translation artifacts (unnatural phrasing, false friends, literal translations of idioms)
- [ ] Audio/text synchronization (if voiced -- subtitle timing matches new text length)

---

## Phase 6: Market Prioritization

Not every language is worth localizing into at launch. Use data to prioritize.

### Language Tiers by Market Size (Steam, 2024-2025 data)

| Tier | Languages | Est. % of Global Steam Revenue | Notes |
|---|---|---|---|
| Tier 1 (Essential) | English, Simplified Chinese | ~55% combined | English is the lingua franca. Chinese is the largest single-language market on Steam. |
| Tier 2 (EFIGS minus E) | French, Italian, German, Spanish (EU + LATAM), Brazilian Portuguese | ~20% combined | The traditional "EFIGS" bundle plus Brazil. Standard for any game targeting global release. |
| Tier 3 (High-value) | Japanese, Korean, Russian, Turkish, Polish | ~15% combined | Large gaming populations. Japanese market values localization quality extremely highly. |
| Tier 4 (Emerging/Niche) | Thai, Vietnamese, Indonesian, Arabic, Hindi, Ukrainian | ~5% combined | Growing markets. Arabic requires RTL investment. Southeast Asian markets are growing fast. |
| Tier 5 (Community-driven) | All others | ~5% combined | Let community demand and sales data guide. Stardew Valley's Hungarian and Turkish localizations were community-initiated. |

### Decision Matrix

| Factor | Weight | How to Evaluate |
|---|---|---|
| Market revenue potential | High | Steam Spy regional data, VG Insights genre breakdown by country |
| Localization cost | Medium | Word count * per-word rate * number of languages. CJK and RTL add technical cost. |
| Genre fit | High | Visual novels and RPGs benefit enormously from localization. Action games with minimal text get less ROI per language. |
| Community demand | Medium | Wishlist geography, community requests, fan translation activity |
| Competitive gap | Medium | If competing games are not localized in a language, you gain advantage by being there first |
| Technical cost | Medium | RTL and CJK require engineering investment beyond translation fees |

---

## Output Template

When completing a localization assessment, produce this document:

```
## Localization Assessment: [Game Title]
## Date: [YYYY-MM-DD]

### Current State
- Total player-facing string count: [X]
- String externalization status: [All externalized / Partial / Not started]
- Current languages supported: [list]
- i18n framework: [name or "none"]
- Known hardcoded strings: [count or "audit needed"]

### Recommended Language Priority
| Priority | Language | Rationale | Est. Word Count | Est. Cost | Technical Notes |
|----------|----------|-----------|-----------------|-----------|-----------------|
| 1        | [lang]   | [why]     | [X words]       | [$X]      | [RTL/CJK/none]  |
| 2        | [lang]   | [why]     | [X words]       | [$X]      | [notes]          |
| ...      | ...      | ...       | ...             | ...       | ...              |

### String Pipeline Architecture
- Source format: [CSV/PO/JSON/engine-native]
- TMS tool: [recommendation]
- Export/import workflow: [description]
- Pseudolocalization: [implemented / needed]
- Automated validation: [what checks run]

### Cultural Adaptation Notes
| Market | Content Sensitivity | Required Changes | Effort |
|--------|-------------------|------------------|--------|
| [market] | [issue] | [change needed] | [Low/Med/High] |

### Technical Requirements
- [ ] RTL support needed: [Yes/No -- which languages]
- [ ] CJK font integration: [Yes/No -- which fonts]
- [ ] IME support for text input: [Yes/No]
- [ ] Plural form handling: [implemented / needed]
- [ ] Date/number/currency formatting: [implemented / needed]
- [ ] UI layout flexibility for text expansion: [tested / needed]

### Timeline
| Phase | Duration | Dependencies |
|-------|----------|-------------|
| String externalization | [X weeks] | [engineering capacity] |
| Pipeline setup | [X weeks] | [TMS selection] |
| Translation (Tier 1) | [X weeks] | [content freeze] |
| LQA | [X weeks] | [native speaker availability] |
| Integration and polish | [X weeks] | [LQA completion] |

### Budget Estimate
| Item | Cost |
|------|------|
| Translation (all languages) | [$X] |
| TMS tooling | [$X/year] |
| LQA testing | [$X] |
| CJK font licensing (if applicable) | [$X] |
| RTL engineering (if applicable) | [$X] |
| **Total** | **[$X]** |

### Risk Register
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| String freeze slips, causing rework | [H/M/L] | [H/M/L] | [plan] |
| CJK rendering issues at launch | [H/M/L] | [H/M/L] | [plan] |
| Community backlash over translation quality | [H/M/L] | [H/M/L] | [plan] |
```

---

## Cross-References

- **String UI/UX**: Route to `game-ux-designer` for text display, font selection, and UI layout that accommodates variable text length
- **Audio localization**: Route to `game-audio-director` for voiceover localization, subtitle timing, and audio language switching
- **Store page localization**: Route to `game-launch` for platform store listing translation (Steam, Epic, console storefronts)
- **Cultural content review**: Route to `game-creative-director` for decisions about content modification vs. market exclusion
- **Technical architecture**: Route to `game-technical-director` for i18n framework selection, font pipeline, and RTL rendering implementation
- **Coding conventions**: Reference `@docs/coding-standards.md` for string externalization patterns by engine
- **Engine specifics**: Route to the appropriate engine specialist (`game-godot-specialist`, `game-unity-specialist`, `game-unreal-specialist`) for engine-native localization APIs
