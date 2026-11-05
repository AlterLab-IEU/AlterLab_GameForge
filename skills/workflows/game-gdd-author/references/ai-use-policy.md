# GDD §16: AI Use & Originality

Read before running Step 11. This file holds the section template and the platform and legal
facts it depends on, as of 2026-11-05. Facts change; keep the dates when you quote them and tell
the user to re-check before launch (`/gameforge:game-launch` runs the full compliance pass).

This is design guidance, not legal advice. Flag anything with real legal exposure (voice
replicas, licensed IP, runtime AI aimed at minors) for professional review.

## Section template

```markdown
## 16. AI Use & Originality

### 16.1 Policy by content type
| Content | AI allowed? | Tool and licence | Human review owner | Ships to players? | Disclosure |
|---|---|---|---|---|---|
| Game code | Yes, agent-assisted | Claude Code | Lead dev reviews every diff | No (code) | Not required on Steam (code assistants exempt) |
| Placeholder art | Yes | [tool, licence] | Art lead | No; replaced before [milestone] | None if fully replaced; track in log |
| Shipped 2D/3D art | [No / Yes with review] | [tool, licence, region limits] | Art lead | Yes | Steam pre-generated; itch.io AI tag |
| Music | [No / Yes] | [licensed-data model or composer] | Audio lead | Yes | Steam pre-generated if AI |
| SFX | [..] | [..] | [..] | [..] | [..] |
| Voice | [No / Yes with written consent] | [..] | Audio lead + producer | Yes | Steam; performer consent and disclosure |
| Localisation | [MT draft + human review] | [..] | Loc lead | Yes | Steam counts AI localisation as disclosable |
| Store page and marketing | [..] | [..] | Producer | Yes | Steam counts marketing assets |
| Runtime generation (AI NPCs etc.) | [None / describe] | [model, on-device or cloud] | Design + tech leads | Yes, live | Steam live-generated + guardrails; EU AI Act Art. 50 |

### 16.2 Runtime AI (only if any row above is live)
- What is generated, by which model, on-device or cloud, cost per player-hour.
- Guardrails: input filtering, output filtering, prompt-injection hardening, logging.
- Player-facing disclosure: how players learn they are talking to an AI.
- Reporting: in-game report button and who acts on reports.

### 16.3 Provenance and disclosure plan
- Provenance log location: [path]; one row per AI-assisted asset (tool, version, prompt,
  human changes, licence, date).
- Disclosure text owner: [role]; reviewed at each milestone and before store submission.

### 16.4 Originality
- What is ours: [the twist, the rules, the world, the assets].
- Comparisons used in pitching: [X meets Y]; no names, assets, characters, level layouts or
  UI trade dress taken from them.
- Asset sources: made by the team, licensed (licence recorded), or generated (logged).
```

## Facts the section depends on (as of 2026-11-05)

**Steam** (rules rewritten 2026-01-16)
- Disclosure covers AI-generated content that ships and is consumed by players (artwork, sound,
  narrative, localisation) and marketing assets on the store page.
- Efficiency tools such as code assistants are exempt. Agent-written code with hand-made assets
  needs no AI disclosure.
- Two categories: **pre-generated** (reviewed like other content) and **live-generated**
  (you must describe your guardrails; live-generated adult-only sexual content is not allowed).

**itch.io**
- Generative-AI content must be disclosed; the disclosure feeds the "no AI" filter, which was
  extended to search on 2026-11-03.
- Bulk AI uploads are treated as spam; itch removed "a couple terabytes" of them in early
  November 2026.

**Microsoft Store / Xbox** (policy 11.16): products with live generative AI must disclose it, keep
output within store policy, and give players a way to report content. Pre-generated assets are
not covered by 11.16.

**PlayStation, Nintendo, Epic Games Store:** no public AI-specific store rule was found as of
November 2026 (absence of evidence, not a guarantee).

**EU AI Act, Article 50** (obligations apply since 2026-08-02)
- 50(1): AI systems that interact with people, including AI NPCs, must disclose that they are AI
  unless that is obvious from context. The exception is read narrowly.
- 50(2): providers of generative systems must mark output in a machine-readable way; systems
  already on the market have until 2026-12-02. Source code is excluded.
- 50(4): for evidently artistic, creative, satirical or fictional works, deepfake disclosure must
  simply not hamper the work.
- Fines up to EUR 15M or 3% of worldwide turnover.

**European Accessibility Act** (in force since 2025-06-28): consoles, e-commerce including
in-game purchase flows, and electronic communications are in scope; microenterprises are exempt
for services. Relevant here because AI-NPC disclosure is also a UX element.

**US copyright**
- Copyright Office report Part 2 (2025-01-29): prompts alone are not enough for protection; human
  selection, arrangement and modification can be protected.
- The Supreme Court denied certiorari in *Thaler* on 2026-03-02; human authorship remains required.
- Practical effect: document the human contribution to every AI-assisted asset you want to own.

**Voice:** the 2025 SAG-AFTRA Interactive Media Agreement (ratified 2025-07-09) requires informed
consent and disclosure for digital voice replicas, with a reasonably specific description of each
use. Treat any cloned or synthetic performer voice as a consent-and-contract task, not a tool choice.

**Music:** UMG and Sony litigation against Suno is unresolved; treat Suno and Udio output as
legally unsettled for shipped games. Prefer a composer or models trained on licensed data.

**3D asset generators**
- Hunyuan3D 2.1: the licence does not apply in the EU, UK or South Korea, and the restriction
  covers outputs. Do not use it for a game sold there.
- TRELLIS.2: MIT licence.
- Auto-retopology and auto-rigging are fine for props and background pieces; hero meshes still
  need manual retopology.

**Reputation:** in December 2025 the Indie Game Awards rescinded awards given to *Clair Obscur:
Expedition 33* over generative-AI placeholder textures, even though they had already been patched
out. Placeholders must be tracked and replaced before anything ships, not forgotten.

**Originality and agents:** in late October 2026 Anthropic added a Claude Code rule against
building recreations of specific existing games "even if it is renamed or called original", while
stating that original games, genre games and games built from the user's own designs and assets
keep working. Activision issued DMCA takedowns against AI-built browser ports of Call of Duty that
used assets exported from the original games (October 2026).

## Decision rules for Step 11

1. If any player-facing content is AI-generated, the GDD names a disclosure owner and a
   provenance log location. No exceptions.
2. If anything is generated at runtime, §16.2 is T1, not T2: guardrails, disclosure and reporting
   ship with the feature or the feature does not ship.
3. AI voice needs a consent plan before a single line is generated for the shipped game.
4. Region-restricted licences (Hunyuan3D) are incompatible with a worldwide release.
5. If the pitch only works as "[existing game] but [small change]", return to Step 1 and find the
   design's own pillar.
6. Hand asset generation to `/gameforge:game-ai-assets` and store compliance to
   `/gameforge:game-launch`. The GDD records the policy; those skills execute it.
