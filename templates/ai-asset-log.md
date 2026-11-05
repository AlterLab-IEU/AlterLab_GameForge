# AI Asset Provenance Log

> Copy to `design/ai-asset-log.md` and commit it; do not gitignore it. Add a row when an asset is
> generated, not when it ships. Never delete rows: mark them `removed` instead. Store disclosures,
> credits and copyright evidence are generated from this file, so a missing row means a wrong
> disclosure. Maintained with `/gameforge:game-ai-assets`; the AI-use stance lives in
> `templates/ai-content-policy.md`.

## Project

- **Game:** [title]
- **Log owner:** [name; the person who signs off disclosures]
- **Style authority:** [art director or audio director names]
- **Raw outputs and prompts stored in:** `art-source/ai/<asset-id>/` (Git LFS or external archive; add `.gdignore` in Godot)
- **Ships to:** [Steam / itch.io / web portals / consoles / mobile; EU availability yes/no]
- **Last disclosure sync:** [date + which store forms were updated]

## Tools register

One row per tool, model and plan combination. Asset rows refer to it by ID, so license terms are
recorded once, with the date you read them. When a vendor changes its terms, add a new row and
do not edit the old one.

| Tool ID | Tool + model/version | Plan / tier | Terms URL | Terms read on | Output license summary | Restrictions (territory, revenue/MAU, training, attribution) | Snapshot saved at |
|---|---|---|---|---|---|---|---|
| T1 | Meshy 6 | Pro (paid) | https://www.meshy.ai/pricing | 2026-11-05 | "Private & Customer owned" | None noted on page | `art-source/ai/_terms/meshy-2026-11-05.pdf` |
| T2 | TRELLIS.2-4B (local) | n/a (open weights) | https://huggingface.co/microsoft/TRELLIS.2-4B | 2026-11-05 | MIT | None | `art-source/ai/_terms/trellis2-model-card.pdf` |
| T3 | Stable Audio 3 Medium (local) | Community License | https://stability.ai/stable-audio | 2026-11-05 | Outputs owned by user | Enterprise license above US$1M annual revenue | `art-source/ai/_terms/stability-community-2026-11-05.pdf` |
| T4 | Suno | [plan] | [url] | 2026-10-20 | Legally unsettled (UMG/Sony litigation) | Dev-only: never ship | `art-source/ai/_terms/suno-2026-10-20.pdf` |
| T5 | [tool + model] | [plan] | [url] | [date] | [own / CC BY 4.0 / license name] | [e.g., excludes EU/UK/KR; >$1M revenue; no LoRA training on outputs] | [path] |

## Asset log

**Field guide**
- **ID:** `AI-<TYPE>-<nnn>`, where TYPE is 3D, 2D, TEX, ANIM, SFX, MUS, VO, TXT, LOC or MKT. IDs are never reused.
- **Path:** the shipped file path, or `—` if it never shipped. Raw files live under the ID folder.
- **Tool:** a Tools register ID plus the exact model version, seed and settings when exposed (or "see folder").
- **Prompt / input summary:** one line; the full prompt goes in `art-source/ai/<id>/prompt.txt`.
- **Reference inputs and rights:** each image, audio or model you fed in, and why you may use it:
  `own` (made in-house), `licensed` (license allows AI input), `CC0`, or `consent on file` (people, voices).
  Never list ripped or exported assets from other games; they must not be used.
- **Human modifications:** concrete edits (retopology, repaint, palette remap, edit or mix). This is your copyright evidence.
- **Reviewer:** who approved it on-style and on-license, with the date.
- **Disclosure** (exactly one):
  - `pre-generated`: AI output, edited or not, that ships in the build and is consumed by players.
  - `marketing`: AI output on the store page, capsule, trailer, social posts or press kit.
  - `localization`: AI or machine-translated player-facing text, even if post-edited.
  - `live-generated`: content generated while the game runs (LLM NPCs, runtime TTS or images).
  - `dev-only`: used during development and never shipped or shown publicly (temp music, mood boards).
  - `none`: a non-AI third-party asset (CC0, bought, licensed), logged for completeness.
- **Status:** `candidate` → `approved` → `shipped (build)` → `removed (build)`.

| ID | Path | Type | Tool + model/version | Date | Prompt / input summary | Reference inputs and rights | Output license | Human modifications | Reviewer | Disclosure | Status | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| AI-3D-014 | `assets/models/props/crate_wood_a.glb` | 3D prop | T1, Meshy 6, image-to-3D | 2026-11-05 | Weathered pine supply crate, iron corners, low-poly | `design/art/refs/crate_sketch.png` (own) | T1 | Remeshed to 1.8k tris, re-UV'd, albedo repainted to palette, LOD1–2 | J. Park (art) 2026-11-06 | pre-generated | shipped (0.4.0) | Background only |
| AI-SFX-003 | `assets/audio/amb/tavern_loop.ogg` | SFX ambience | T3, Stable Audio 3 Medium (local), seed 4412 | 2026-11-05 | Quiet tavern murmur, fire crackle, 40 s loop | none | T3 | Trimmed, loop seam cut at zero crossing, loudnorm, mixed with own foley | L. Moreau (audio) 2026-11-06 | pre-generated | approved | |
| AI-MUS-001 | — | Music (temp) | T4, Suno | 2026-10-20 | Placeholder combat track | none | Unsettled (litigation) | none | — | dev-only | removed (never public) | Replaced by commissioned track before demo |
| [id] | [path] | [type] | [Tn, model, seed] | [date] | [one line] | [file (rights)] | [Tn or license] | [edits] | [name date] | [category] | [status] | [notes] |

## Consent records (voice, likeness, performance)

| Person | What was captured or cloned | Consent document | Scope of use described | Usage reports due | Revocation contact |
|---|---|---|---|---|---|
| [name] | [voice clone / mocap / face scan] | `art-source/ai/_consent/[file]` | [which lines, which builds, marketing yes/no] | [cadence] | [email] |

## Turning this log into disclosures

Re-run these steps whenever a build or the store page changes the set of shipped rows.

1. **Filter.** Take rows with status `shipped`, plus `approved` rows that are in the build you are
   submitting. `dev-only` and `none` rows are not disclosed, but they stay as evidence.
2. **Steam (Content Survey, AI section, rewritten 2026-01-16).** Pre-Generated covers
   `pre-generated`, `localization` and `marketing` rows, grouped as artwork, sound, narrative,
   localization and store/marketing. Write what, how much and what humans did. Live-Generated
   covers `live-generated` rows; describe the guardrails: filters, limits on what the model can
   change, the player report path and output logging. Code assistants are exempt.
3. **itch.io (Generative AI Disclosure on the edit page).** Answer yes if any shipped row is AI.
   Tick Graphics (2D, 3D, texture, animation, marketing images), Sound (SFX, music, voice),
   Text & Dialog (text, localization) and Code (if agents wrote meaningful code). Hand-edited
   output still counts.
4. **EU AI Act Art. 50 (applies since 2026-08-02).** `live-generated` rows need machine-readable
   marking of outputs (deadline 2026-12-02 only for systems already on the market). AI NPCs need
   a "you are talking to an AI" notice unless that is obvious. Rows that resemble a real
   person's voice or likeness need a deepfake notice that does not hamper the work. Keep vendor
   marks intact.
5. **Credits.** List every tool in the Tools register that has a shipped row, plus any required
   attribution (for example CC BY 4.0).
6. **Record the sync.** Update "Last disclosure sync" above and commit the log together with the build tag.

Practitioner guidance, not legal advice. Full rules and a worked example are in the
`game-ai-assets` skill's `references/disclosure-guide.md`.
