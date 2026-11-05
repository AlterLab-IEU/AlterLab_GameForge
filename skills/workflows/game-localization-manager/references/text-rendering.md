# Fonts, Text Expansion, RTL, CJK and Complex Scripts

Read this before adding a new script (CJK, Arabic/Hebrew, Thai, Devanagari) or fixing overflow.
Engine-specific settings are summarized here; exact steps live in `engine-string-extraction.md`.

## 1. Text expansion

Translations from English usually run longer, and short strings expand the most. A widely used
industry rule of thumb (not a standard; measure your own pseudo-loc and real translations):

| English source length | Allow for expansion of |
|---|---|
| up to 10 characters | 100-200% |
| 11-20 | 80-100% |
| 21-30 | 60-80% |
| 31-50 | 40-60% |
| 51-70 | about 30-40% |
| over 70 | about 30% |

Design rules: containers auto-size or wrap; buttons grow horizontally; avoid fixed-width labels in
tight HUDs; give every string a `max_chars` only where layout truly cannot flex (controller prompts,
radial menus), and let translators see it. Chinese and Japanese often get shorter in characters
but need larger glyphs, so height, not width, becomes the constraint.

## 2. Fonts

- **Coverage:** list every script per target language and confirm glyph coverage (including
  punctuation, currency symbols, and accented capitals). Missing glyphs render as boxes ("tofu").
- **Licensing:** Noto fonts and Source Han Sans/Serif (also published as Noto Sans/Serif CJK) are
  under the SIL Open Font License, which allows embedding in games. Check every other font's EULA
  for game embedding and for web font serving.
- **Size:** full CJK fonts are large (thousands to tens of thousands of glyphs). Subset to the
  characters your shipped text uses, but keep a full or broad fallback for player names, chat and
  user-generated text. A subsetting pass with fonttools:

  ```bash
  # all_strings_ja.txt = every Japanese string in the build, plus ASCII and punctuation
  pyftsubset NotoSansJP-Regular.otf --text-file=all_strings_ja.txt \
    --layout-features='*' --output-file=build/fonts/NotoSansJP-subset.otf
  # web: add --flavor=woff2 and serve per-script files with unicode-range in @font-face
  ```

  Regenerate subsets in CI whenever strings change, or a late string will render tofu.
- **Fallback chains:** primary display font -> script-specific fallbacks -> broad Unicode fallback.
  Godot: theme font fallbacks; Unity: TextMeshPro fallback font assets or UI Toolkit font assets;
  Unreal: Composite Font sub-font families; web: `font-family` stacks with `unicode-range` faces.
- **Rendering:** MSDF/SDF atlases suit Latin; large CJK sets usually need dynamic atlases. Watch
  atlas memory on mobile and web.

## 3. CJK

- **Line breaking:** no spaces between words in Chinese and Japanese; breaks may occur between most
  characters, but not before closing punctuation or after opening punctuation. Japanese adds
  kinsoku shori rules (characters that must not start or end a line). Use an implementation of the
  Unicode Line Breaking Algorithm (UAX #14) via the engine's text server or ICU; do not write your
  own. Godot exposes `internationalization/locale/line_breaking_strictness`.
- **Korean** uses spaces between words; break at spaces, not between syllables, for natural text.
- **Size and spacing:** CJK glyphs are dense; increase point size (often 10-25% over the Latin size,
  tuned by eye on target screens) and line height.
- **Punctuation:** full-width punctuation in Chinese and Japanese; numbers usually half-width.
- **Input:** every text field must support IME composition (candidate window, preedit text, commit).
  Test Japanese (kana to kanji conversion), Chinese pinyin input, and Korean Hangul syllable
  composition; the composing state must render.
- **Variants:** Simplified Chinese (mainland, Singapore) and Traditional Chinese (Taiwan, Hong Kong)
  are separate localizations with different glyph preferences and vocabulary, not a converter pass.

## 4. RTL (Arabic, Hebrew, Persian, Urdu)

- **Shaping:** Arabic letters change form by position and ligate; the engine needs a shaping engine
  (HarfBuzz or platform shaping). Hebrew needs no contextual shaping but needs vowel-mark support if
  used.
- **BiDi:** mixed strings (Arabic with an English item name, numbers, a URL) follow the Unicode
  Bidirectional Algorithm (UAX #9). Test every string type that can embed LTR runs: player names,
  numbers with units, key prompts, timers.
- **Mirroring:** UI flow mirrors (navigation right to left, progress bars fill from the right, back
  buttons on the right). Do not mirror media controls, clocks, phone numbers, or gameplay and world
  maps. Icons with direction (arrows, "next") mirror; logos do not.
- **Engines:** Godot mirrors anchors, margins, alignment and container order for RTL and offers a
  global force-RTL setting for testing; Unity UI Toolkit's Advanced Text Generator handles RTL text
  (TextMeshPro needs a community plugin for Arabic shaping); Unreal widgets take a Flow Direction;
  on the web prefer HTML/CSS with `dir="rtl"` for text-heavy UI.

## 5. Complex scripts (Thai, Khmer, Lao, Devanagari and others)

- Thai, Khmer and Lao have no spaces between words; line breaking needs dictionary data (ICU). In
  Godot exports, enable `internationalization/locale/include_text_server_data` (about 4 MB).
- Devanagari and other Indic scripts need shaping for conjuncts and vowel signs; test with real
  text, not pseudo-loc.
- Stacked diacritics (Thai tone marks, Vietnamese) need vertical space; clipped line heights cut them
  off.

## 6. Numbers, dates, names

- Use locale-aware formatting for numbers (decimal and grouping separators), dates, times, currency
  and lists. Some locales use non-Latin digits by default; decide per locale whether to keep Western
  digits in gameplay HUDs, and be consistent.
- Gender and grammatical case vary with names and counts; prefer sentence structures that avoid
  inflecting the player's name, or use the library's select/gender features.
- Sorting (inventories, leaderboards) uses locale collation, not byte order.

## 7. Test matrix per new script

| Test | Pass when |
|---|---|
| Pseudo-loc build (accents + expansion) | No overflow, no plain-English strings |
| Real-text sample screens | Glyphs present, line breaks natural, no clipped diacritics |
| Force-RTL layout (RTL targets) | Every screen mirrors correctly; gameplay unchanged |
| Mixed BiDi strings | Names, numbers and prompts render in correct order |
| IME input (CJK targets) | Composition, candidate selection and commit work in every text field |
| Font fallback | Player names in other scripts render (no tofu) |
| Memory and size | Font atlases and files within platform budgets (web download, mobile memory) |
