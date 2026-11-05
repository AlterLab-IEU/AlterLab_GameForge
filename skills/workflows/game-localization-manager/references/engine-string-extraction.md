# String Extraction and Translation Setup per Engine

Read the section for the project's engine before changing code or files. Facts checked against the
Godot 4.7 docs and class reference, Unity's Localization and UI Toolkit manuals, and npm (November
2026). Unreal details follow Epic's localization tools; verify commandlet flags for your engine
version.

## Godot 4.x

### Translation path
- `tr("KEY")` and `tr("KEY", "context")` (for example `tr("Close", "Actions")`) in GDScript;
  `Tr()` in C#.
- `tr_n("SINGULAR_KEY", "PLURAL_KEY", count)` for plurals (zero or positive integers only), with an
  optional context argument.
- `atr()` / `atr_n()` translate in the context of a node's auto-translate mode.
- Buttons and Labels auto-translate text that matches a key; disable per node with
  Auto Translate > Mode = Disabled (for player names, numbers).
- `TranslationServer` adds/removes translations and switches locale at runtime; test with the
  editor's View > Preview Translation or the `--language` command-line argument.

### CSV (simplest)
- First column is the key; one column per locale (`en`, `de`, `ja`, `zh_CN`).
- **Godot 4.6+** supports a `?context` column and a `?plural` column (with a `?pluralrule` row such as
  `nplurals=2; plural=(n >= 2);`); place them after the key column. Controls do not auto-translate
  contexts or plurals, so use `tr()` / `tr_n()` for those strings.
- Columns whose header starts with `_` are comments and are not imported (use `_context_note`,
  `_max_chars`, `_screenshot`).
- Import options: delimiter and compression; click Reimport after changing them.

### gettext PO (best for translators and TMS tools)
1. Project Settings > Localization > **Template Generation**: add the scenes and scripts, click
   Generate, save `locale/messages.pot`.
2. Create or update languages: `msginit` for new ones, then
   `msgmerge --update --backup=none locale/fr.po locale/messages.pot`.
3. Validate: `msgfmt locale/fr.po --check`. For large projects compile with
   `msgfmt locale/fr.po --no-hash -o locale/fr.mo`.
4. Register `.po`/`.mo` files under Project Settings > Localization > Translations.

Extraction picks up constant strings in `tr()`, `tr_n()`, `atr()`, `atr_n()`, assignments to
`text`, `placeholder_text` and `tooltip_text`, calls like `add_item()`, `add_tab()`,
`set_tab_title()`, and FileDialog filters. Non-constant expressions are skipped. Mark exclusions
with a `NO_TRANSLATE` comment and translator notes with `TRANSLATORS:` on the same line or directly
above. Regenerate the template after adding scenes or scripts. Strings marked fuzzy after a merge
are ignored until reviewed. Other file formats (dialogue resources, JSON) need a custom
`EditorTranslationParserPlugin`.

### Pseudo-localization and RTL testing (project settings)

| Setting | Use |
|---|---|
| `internationalization/pseudolocalization/use_pseudolocalization` | Turn on (advanced settings) |
| `.../expansion_ratio`, `.../replace_with_accents`, `.../double_vowels`, `.../prefix`, `.../suffix`, `.../skip_placeholders` | Shape the pseudo text |
| `.../fake_bidi` | Simulate RTL text runs |
| `internationalization/rendering/force_right_to_left_layout_direction` | Flip all Controls to RTL for layout testing |
| `internationalization/locale/include_text_server_data` | Ship ICU break-iterator data (about 4 MB) needed for line breaking in languages such as Thai and Khmer |
| `internationalization/locale/line_breaking_strictness` | CJK line-break strictness |
| `internationalization/locale/fallback` | Fallback locale |

### Pitfalls
- Strings built with `%` formatting or `+` around `tr()` results: translate the whole sentence with
  named placeholders: `tr("WAVE_N").format({"n": wave})`.
- Translated strings stored in saved games (save keys, not text).
- Fonts: assign fallback fonts in the theme; DynamicFont fallbacks work regardless of locale, which
  suits chat and player names.

## Unity 6 (Localization package)

### Setup
- Package `com.unity.localization` (the docs' current line is 2.0 as of November 2026); it builds on
  Addressables, so check the package's dependencies in Package Manager.
- Create Locales; create **String Table Collections** (text) and **Asset Table Collections**
  (localized sprites, audio, fonts).
- Reference text with `LocalizedString` fields or the `LocalizeStringEvent` component; avoid writing
  `text = "..."` anywhere in UI code.
- **Smart Strings** handle placeholders and plurals (`{count:plural:One item|{} items}` style
  formatters; see the Smart Strings docs for the exact syntax per formatter).
- Built-in **Pseudo-Localization** for overflow and hardcoded-string testing.
- Import/export: **XLIFF**, **CSV** and **Google Sheets** extensions for translators and TMS tools.

### Finding hardcoded text
- Grep C# for `\.text\s*=\s*"` and `SetText\("`.
- Grep scene and prefab YAML for `m_text:` (TextMeshPro) and `m_Text:` (legacy Text) with literal
  content; UI Toolkit `.uxml` for `text="`.

### Text rendering notes
- TextMeshPro ships inside `com.unity.ugui` in Unity 6; use fallback font asset chains for CJK.
  TextMeshPro has no full Arabic shaping; RTL there typically needs a community plugin.
- UI Toolkit's **Advanced Text Generator** (Unity 6.0+; HarfBuzz, ICU and FreeType) supports
  complex scripts and RTL. Enable it in Project Settings > UI Toolkit and per element
  (`-unity-text-generator: advanced` in USS or `TextGeneratorType.Advanced` in C#). It supports
  dynamic font assets only, and the ICU data adds about 4.8 MB.

## Unreal Engine 5.x

### Translation path
- All player-facing text is `FText`, never `FString`, in code that reaches the UI.
- C++: `LOCTEXT("Key", "Source")` with `#define LOCTEXT_NAMESPACE "HUD"`, or
  `NSLOCTEXT("HUD", "Key", "Source")`.
- Formatting: `FText::Format(LOCTEXT("Wave", "Wave {N}"), FFormatNamedArguments{...})`; plurals with
  argument modifiers, for example `{Count} {Count}|plural(one=enemy,other=enemies)`.
- **String Tables** (CSV-backed assets) for shared UI text and data-driven strings.
- Blueprint and asset text is gathered from assets automatically when included in the gather.

### Localization Dashboard
Tools > Localization Dashboard, Game target:
1. Configure gather sources (C++ source paths, content paths, metadata) and cultures.
2. **Gather Text** -> **Export Text** (PO files per culture) -> translate in your TMS ->
   **Import Text** -> **Count Words** -> **Compile Text** (`.locres`).
3. In CI or scripts, the same steps run as commandlets, for example
   `UnrealEditor-Cmd.exe Game.uproject -run=GatherText -config=Config/Localization/Game_Gather.ini`;
   path settings in those configs are relative to different roots (source paths vs include paths),
   a common cause of "no include paths found".
4. Test with in-editor language preview or the `-culture=` command-line argument. Forum answers
   describe a `-leet` debug flag that "leetifies" localized text to expose unlocalized strings;
   confirm it exists in your engine version before relying on it, or import a pseudo-localized PO
   as a test culture instead.

### Text rendering notes
- Slate/UMG shape complex scripts and support bidirectional text; set widget **Flow Direction**
  (Culture, LTR or RTL) and test RTL screens explicitly.
- **Composite Font** assets with sub-font families per character range or culture (Noto CJK for
  CJK ranges, an Arabic face for Arabic).

## Web (Three.js/R3F, Phaser, PixiJS, Kaplay)

### Libraries (npm, November 2026)

| Library | Version | Format | Notes |
|---|---|---|---|
| `i18next` (+ `react-i18next` 17) | 26.7 | JSON; plural suffixes `_one`, `_other` using `Intl.PluralRules`; ICU via an i18next ICU plugin | Most common; framework-agnostic |
| FormatJS `react-intl` | 12.1 | ICU MessageFormat | `formatjs extract` CLI for extraction |
| Lingui (`@lingui/core`) | 6.12 | ICU MessageFormat, PO catalogs | `lingui extract` / `lingui compile`; PO suits TMS tools |
| Fluent (`@fluent/bundle`) | 0.19 (2025) | Fluent syntax | Expressive, slower release cadence |

Prefer ICU MessageFormat or PO-based flows when external translators and TMS tools are involved;
they understand plurals, selects and context.

### Built-in `Intl` APIs
`Intl.PluralRules`, `Intl.NumberFormat`, `Intl.DateTimeFormat`, `Intl.ListFormat` and
`Intl.Segmenter` (grapheme, word and sentence segmentation, needed to wrap CJK and Thai text in
canvas renderers). Never hand-roll number or date formatting.

### Canvas text pitfalls
- Canvas `fillText` gets the browser's shaping, but word wrapping in game frameworks usually splits on
  spaces, which fails for Chinese, Japanese and Thai. Wrap with `Intl.Segmenter` (word granularity)
  or render text-heavy UI as an HTML/CSS overlay, where `lang`, `dir="rtl"`, `line-break` and
  `word-break` work natively.
- Load fonts before drawing (`await document.fonts.load('16px "Noto Sans JP"')`) or the first frames
  render with fallback glyphs and wrong metrics.
- Ship per-script font subsets with `unicode-range` in `@font-face` so players download only what
  they need.
- Locale detection: `navigator.languages`, a user setting stored locally, and the portal or
  platform locale where its SDK provides one.

### Finding hardcoded text
Grep TS/JS/JSX for string literals passed to text objects (`add.text(`, `new Text(`, `textContent =`,
JSX text children) and enforce with a lint rule (for example a "no literal string in JSX" rule) so
agents cannot reintroduce them.
