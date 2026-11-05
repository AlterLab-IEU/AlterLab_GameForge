# AI Feedback Summarization, Validated on Your Own Data

Read this before summarizing player feedback with an LLM. The goal is a theme report the team can
trust enough to act on, with an audit trail back to real player words.

## 1. Why validate

LLMs cluster hundreds of reviews in seconds. They also merge distinct complaints, over-weight vivid
posts, invent consensus, translate away nuance, and occasionally fabricate a quote that sounds right.
Commercial tools (FirstLook aggregates Steam and Discord feedback and offers an MCP agent; Accord
analyzes community feedback) did not publish accuracy benchmarks as of November 2026. So the
validation has to be yours, on your data.

## 2. Collect

| Source | How | Privacy note |
|---|---|---|
| Steam reviews | Valve's public user-reviews endpoint (`store.steampowered.com/appreviews/<appid>?json=1` with `cursor`, `filter`, `language`, `num_per_page` parameters) | Public, but keep only review text, language, playtime, recommendation, timestamp; drop author IDs |
| Discord | Export from channels you moderate, per your server rules | Tell the community feedback channels may be analyzed; strip handles |
| Surveys and playtests | `game-playtest` forms | Covered by the survey's own notice |
| Store and portal comments, emails | Manual export | Strip names and emails |

Give every item a stable ID (`R-0193`, `D-0042`) and keep the raw text locally. Strip PII before
anything goes to a model provider, and check that provider's data-processing terms (retention,
training use).

## 3. Build the gold set

1. Sample 100-200 items at random, stratified by source and language.
2. Two people hand-code them into a codebook: 8-20 themes with one-line definitions and an example
   each (for example "Room 4 spike unfair", "Dash feels floaty", "Crash on Steam Deck",
   "Wants co-op"). Allow multiple themes per item.
3. Reconcile disagreements and freeze codebook v1. Human agreement on the sample is your ceiling;
   do not expect the model to beat it.

## 4. Run the summarizer

Prompt skeleton:

```
You are classifying player feedback for [game]. Use ONLY the themes in the codebook below.
For each item, return JSON: {"id": "...", "themes": ["..."], "sentiment": "pos|neg|mixed",
"quote": "<exact substring of the item text that supports the first theme>"}.
If no theme fits, use "other" and propose a new theme name in "proposed".
Never paraphrase inside "quote". Never invent items.

CODEBOOK v1:
- room4_spike: complaints that room 4 difficulty jumps before the needed skill is taught
- dash_feel: comments on dash responsiveness, distance or float
...
ITEMS:
[{"id": "R-0193", "lang": "en", "text": "..."}, ...]
```

Then aggregate counts in code, not in the model: shares per theme, by source, language and
playtime bucket.

## 5. Validate

| Check | Method | Pass rule (house defaults; set your own) |
|---|---|---|
| Quote fidelity | Exact substring match of every `quote` against its item | 100%; any miss blocks the report |
| Theme agreement | Model vs gold labels on the gold set (per-theme precision and recall) | Close to the human-human agreement; no major theme under 0.7 recall |
| Coverage | Share of items labelled `other` | Under 10%; otherwise extend the codebook |
| Language parity | Agreement on non-English items vs English items | No large gap; otherwise review non-English items by hand |
| Stability | Re-run on the same sample | Same top themes and similar shares |

Re-validate when the model, the prompt, the codebook or the source mix changes, and at least once
per major release.

## 6. Link themes to metrics

A theme matters more when behavior agrees with it. For each top theme, look for the matching
telemetry: "room 4 spike" next to room 4 quit-after-fail rate; "crash on Steam Deck" next to
crash-free sessions by platform. Where telemetry and feedback disagree, say so; vocal minorities and
silent majorities are both real.

## 7. Report format

```markdown
## Player Feedback Summary: [build / date range]
**Sources:** [counts by source] | **Languages:** [list] | **PII stripped:** yes
**Validation:** gold set [n], quote fidelity [x%], theme agreement [summary], codebook v[n]

| Theme | Share | Trend vs last report | Sentiment | Quote (ID) | Linked metric |
|---|---|---|---|---|---|

### Proposed new themes (from "other")
### What this data cannot show
- Players who left without writing anything; refund reasons live in Steamworks
- Channels not included: [list]
### Recommended investigations (not decisions)
1. [theme] -> [what to check in playtest or telemetry] -> owner
```

## 8. Guardrails

- Summaries inform investigations; designers decide fixes (rule 4 of the skill).
- Never present model-estimated percentages as survey statistics; they are shares of a non-random
  sample of vocal players.
- Keep raw items and the model output for every report, so anyone can audit a claim.
- Do not use feedback analysis to profile individual players.
