# Hybrid Translation Pipeline: NMT + LLM + Human Review

Read this before commissioning any translation or running machine drafts. The industry pattern as
of 2026 is hybrid: neural machine translation for volume, LLMs for tone-sensitive drafts, and human
review for humor, culture and quality (see Gridly's and other TMS vendors' public guidance). The
pipeline below makes that pattern auditable and honest.

## 1. Inputs every batch needs

| Input | Owner | Format |
|---|---|---|
| Source strings, frozen for the batch | narrative/UI owners | TMS project or PO/XLIFF/CSV export |
| Context per string | localization + designers | screenshot link, speaker, trigger, `max_chars` |
| Glossary (termbase) | localization + narrative director | `localization/glossary.csv`: term, part of speech, definition, do-not-translate flag, approved translation per language |
| Style guide per language | lead linguist | `localization/style-guide-<lang>.md`: formality (tu/vous, du/Sie, keigo level), tone per character, UI capitalization, punctuation, number formats |
| Translation memory | TMS | prior approved segments |
| Character bible excerpt | narrative director | voice notes per speaker |

## 2. Routing rules

| Class | Method | Review depth | Allowed for machine draft? |
|---|---|---|---|
| Narrative, dialogue, humor, poetry, wordplay | Human transcreation | Second linguist | Only if the translator opts in, as a private aid |
| Marketing (store page, capsule text, trailers) | Human transcreation | Native marketing review | Discouraged; if used, disclose as AI-generated marketing on Steam |
| Legal, ratings, privacy, consent, EULA | Human from approved legal source | Legal review per market | No |
| UI, menus, settings, tutorials, system messages | NMT or LLM draft | Full post-edit + in-context check | Yes |
| Items, abilities, achievements, codex flavor | LLM draft with glossary and voice notes | Full post-edit, sampled in-context | Yes |
| Live-ops and patch strings | Same as their class | Same | Same |
| Player-generated content at runtime (chat) | Runtime MT, clearly labelled | None possible per message | Live-generated content: describe guardrails to Steam; report and opt-out paths |

"Full post-edit" means a professional translator reads every segment against the source and edits
it to publishable quality. Light post-edit (fix only errors) is not acceptable for shipped text.

## 3. Drafting with NMT or an LLM

NMT (for example DeepL, Google Cloud Translation, Amazon Translate) is consistent, fast and supports
glossaries; it is weak on tone and on very short UI strings without context. LLMs handle context and
voice better, but can add or drop content, over-localize names, "improve" source text, and drift on
terminology across a long batch. Constrain them:

```
SYSTEM: You are a professional game localizer translating [source] to [target locale] for
[game, genre, rating]. Follow the style guide and glossary exactly. Do not translate
do-not-translate terms. Keep every placeholder ({player_name}, {0}, %s), tag ([b], <color=...>)
and line break exactly as in the source. Respect max_chars. Do not add or remove information.
If a string is ambiguous, still translate it and explain the ambiguity in "note".

STYLE GUIDE: [paste]
GLOSSARY (source -> target): [paste relevant entries only]

INPUT (JSON lines): {"key": "...", "source": "...", "context": "...", "speaker": "...", "max_chars": 24}
OUTPUT (JSON lines): {"key": "...", "target": "...", "note": "", "confidence": "high|medium|low"}
```

Rules: low temperature; batches grouped by screen or scene so context is coherent; never send
unreleased story text to a provider whose terms allow training on it; keep model name and date for
the provenance log.

## 4. Automated QA before humans see it

Run `tools/loc_check.py` (see `pseudoloc-and-qa.md`) plus these checks, failing the batch on errors:

| Check | Error when |
|---|---|
| Placeholder parity | Placeholder set differs from source |
| Tag parity | Rich-text or markup tags differ or are unbalanced |
| Length | Exceeds `max_chars` |
| Glossary | A glossary term in the source lacks its approved translation in the target |
| Do-not-translate | A protected term was translated |
| Untranslated | Target equals source (except allowed cognates and proper nouns) |
| Script | Wrong script for the locale (for example Latin letters dominating a Japanese string) |
| Whitespace and punctuation | Leading/trailing spaces, doubled spaces, wrong quote style for the locale |
| ICU syntax | Plural/select branches missing required categories for the locale (`Intl.PluralRules` categories) |

## 5. Human steps

1. **Post-edit** in the TMS with source, context, glossary hits and the model's notes visible.
2. **Review** by a second linguist for narrative and marketing; sampled review for routed classes.
3. **In-context review** in a build or with screenshots: truncation, tone in situ, gender and number
   agreement with dynamic values.
4. **LQA** by native players on a full build (see `pseudoloc-and-qa.md`).

Tell vendors up front which segments are machine drafts. Post-editing is a distinct service with its
own pricing and throughput; many translators decline it for creative text, and good ones will tell
you when a machine draft is costing more time than it saves.

## 6. Provenance and disclosure

`localization/provenance.csv`:

```
batch_id,keys,language,method,engine_or_model,model_date,post_editor,reviewer,date
B-014,ui.*,de,NMT+full post-edit,[engine name],[version/date],[translator],[reviewer],2026-11-05
B-015,item.*,ja,LLM+full post-edit,[model name],[version/date],[translator],[reviewer],2026-11-07
B-016,dlg.act1.*,fr,human transcreation,-,-,[translator],[reviewer],2026-11-10
```

From this log:
- **Steam Content Survey** (rewritten 2026-01-16): AI-generated content that ships and is consumed
  by players is disclosable, explicitly including localization, as are marketing assets. Any row with
  NMT or LLM drafting of shipped or store text means a "yes" in the pre-generated section, with a
  plain description ("Some UI and item text was machine-translated and then fully edited by
  professional translators"). Tools that only helped write code are exempt.
- **Runtime translation features** are live-generated content: describe guardrails (filters,
  reporting, labelling) in the survey.
- **itch.io:** tick the generative-AI disclosure on the project page.
- **EU AI Act Article 50** applies since 2026-08-02; runtime generative features may carry
  transparency duties, so check with counsel before shipping them.
- Hand the summary to `game-launch` for the release checklist and to `game-ai-assets` if the same
  game also uses AI art, audio or voice.

## 7. Tools

| Tool type | Options (as named in 2026 vendor and review sources) | Fit |
|---|---|---|
| Game-focused TMS | Gridly | Spreadsheet-style, game workflows, MT/LLM integration |
| General TMS with AI | Crowdin (AI agent features), Lokalise (LLM routing and quality scoring), Phrase | Large integrations, vendor marketplaces |
| Open-source TMS | Weblate, Tolgee | Self-hosting, git-based workflows, budget teams |
| Files without a TMS | PO + git + review in pull requests | Very small projects only |

Pick the TMS that reads your engine's export format (PO for Godot, Unreal and Lingui; XLIFF or CSV for
Unity; JSON for i18next) and supports screenshots, glossary enforcement and per-segment provenance.

## 8. Budget structure (no fixed rates here)

Get quotes per language for: transcreation (per word), full post-edit of machine drafts (per word),
review (per word or hour), LQA (per hour), and in-context screenshot capture (internal). Machine
drafting lowers cost per word only where post-editing is genuinely faster; measure the first batch
and adjust the routing table. Keep a delta budget for source changes after content lock.
