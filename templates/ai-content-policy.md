# AI Content Policy

> Owned by the Creative Director (stance) and Technical Director (tooling and security).
> Every generated asset is recorded in the provenance log (`design/ai-asset-log.md`, from the
> [AI asset log template](ai-asset-log.md)); store disclosures are drafted from that log.
> Facts below are current as of November 2026. Re-check each platform's own pages before filing.

## Project
- **Studio/Developer**: [name]
- **Game Title**: [name]
- **Date**: [date]
- **Policy Version**: [number]
- **Owners**: Creative Director [name], Technical Director [name]

## Stance Level

Pick one and state it in a sentence. Changing the level is a creative decision record.

| Level | What AI may touch | Chosen |
|---|---|---|
| 0 Hand-made | Nothing player-facing. Code assistants allowed | [ ] |
| 1 Tool-assisted (default) | Code, tools, internal ideation; placeholders logged and replaced before any public build | [ ] |
| 2 Assisted assets | Level 1 plus named asset classes a human finishes, all disclosed | [ ] |
| 3 AI as feature | Level 2 plus live-generated runtime content with guardrails, reporting and disclosure | [ ] |

**Stance in one sentence:** [e.g. "Level 1: agents help write code and tools; everything players see
or hear is made by our team."]

## AI Usage Inventory

Steam's content survey (rewritten 2026-01-16) distinguishes **pre-generated** and
**live-generated** AI content and exempts efficiency tools such as code assistants. The three
groups below map onto that.

### Development tools (exempt from Steam disclosure)
Tools that never produce player-facing content.

| Tool | Use case | Guardrail |
|------|----------|-----------|
| [e.g. Claude Code] | [implementation, debugging, tests] | Human review of every merged change |
| [e.g. engine MCP server] | [editor automation] | Localhost only; commit before each session |

### Pre-generated content (disclose)
Generated during development and shipped or shown to players, including store-page and marketing
assets and localization.

| Asset class | Tool and model | Licence / terms (date read) | Human finishing | Approver |
|---|---|---|---|---|
| [e.g. background props] | [tool, model version] | [terms, YYYY-MM-DD] | [retopology, repaint] | Art Director |
| [e.g. ambient SFX] | [tool] | [terms] | [edit, mix, loop] | Audio Director |
| [e.g. localization drafts] | [tool] | [terms] | [native-speaker review] | Localization lead |

### Live-generated content (disclose and add guardrails)
Content an AI system generates while the game runs.

| Feature | Model / service | Guardrails | Player reporting | Logging |
|---|---|---|---|---|
| [e.g. NPC dialogue] | [model, on-device or API] | [content filter, topic bounds, prompt-injection hardening] | [in-game report button] | [what is logged, retention] |

Requirements for live generation:
- Steam: describe your guardrails in the content survey; live-generated adult-only sexual content is
  not allowed.
- Microsoft Store policy 11.16: disclose live generative AI in metadata and Partner Center, keep
  output within Store policy, and provide a way to report content and act on reports.
- EU AI Act Article 50 (applies from 2026-08-02): AI NPCs and agents must tell players they are AI
  unless that is obvious; runtime generative systems need machine-readable marking (grace to
  2026-12-02 only for systems already on the market). This is our reading, not legal advice.

## Prohibited Without a Written Exception and Legal Review
- [ ] A real performer's voice or likeness (SAG-AFTRA 2025 Interactive Media Agreement: consent and
      disclosure for digital replicas)
- [ ] Music from services whose training data is in active litigation
- [ ] Prompts naming living artists, existing characters, brands, or other games
- [ ] AI output as the final logo, key art or main characters (keep identity assets human-made)
- [ ] Shipping any generated content without human review and a log entry

## Quality Gates
1. **Generate** with the approved tool; log it immediately.
2. **Technical check**: resolution, format, topology, loudness, performance budget.
3. **Domain review**: the owning director approves fit and quality.
4. **In-engine test**: the asset works in the build.
5. **Disclosure check**: the log entry has its disclosure category.

## Copyright Documentation
For each generated asset the log records the tool and version, inputs, and the human modifications
made. The US Copyright Office's Part 2 report (2025-01-29) found prompts alone insufficient for
protection while human selection, arrangement and modification can be protected; the Supreme
Court declined *Thaler* on 2026-03-02, so human authorship remains required.

## Per-Platform Disclosure

| Platform | Development tools | Pre-generated | Live-generated |
|---|---|---|---|
| **Steam** | Exempt | Disclose in the content survey (in-game, store page, marketing, localization) | Disclose plus describe guardrails |
| **Microsoft Store / Xbox** | Not covered | Not covered by 11.16 | Disclose in metadata and Partner Center; reporting mechanism |
| **itch.io** | Not required | Generative-AI disclosure on the project; it feeds itch.io's "no AI" filter, which covers search since 2026-11-03 | Disclose |
| **EU players (AI Act Art. 50)** | Not covered | Fictional and artistic works: disclosure must not hamper the work | AI interaction notice; machine-readable marking |
| **PlayStation, Nintendo, Epic** | No public AI-specific store rule found as of Nov 2026; follow general content policies and check current partner documentation | | |
| **Credits** | Optional | List AI tools and what they were used for | List tools and the live features |
| **Marketing** | — | Never present generated content as hand-made | Never present generated content as hand-made |

## Review
- **Last reviewed**: [date] by [name]
- **Next review**: before each public build and each store submission
