# AI Content Policy

## Project
- **Studio/Developer**: [name]
- **Game Title**: [name]
- **Date**: [date]
- **Policy Version**: [number]

## AI Usage Inventory (Three-Tier Classification)

Categorize ALL AI usage in your project according to Steam's January 2026 three-tier framework. This classification determines disclosure obligations per storefront.

### Tier 1: Developer Tools (EXEMPT from disclosure)
AI tools used during development that do not produce player-facing content.

| Tool | Use Case | Quality Gate |
|------|----------|-------------|
| [e.g., Claude Code] | [implementation assistance, debugging] | Code review required |
| [e.g., GitHub Copilot] | [code completion] | Code review required |
| [e.g., internal LLM] | [test case generation, documentation] | None required for disclosure |

### Tier 2: Pre-Generated AI Content (DISCLOSE on store page)
AI-generated assets baked into game files that players consume directly.

| Category | Tool | License | Use Case | Quality Gate |
|----------|------|---------|----------|-------------|
| Visual Art | [e.g., Scenario] | [license] | [concept art, texture generation] | Art Director approval required |
| Music | [e.g., Suno] | [license] | [prototype only / production] | Audio Director approval required |
| Voice | [e.g., ElevenLabs] | [license] | [PROTOTYPE ONLY -- not for shipping] | SAG-AFTRA compliance check |
| 3D Assets | [e.g., Meshy] | [license] | [props, environment pieces] | Technical art review |
| Narrative | [e.g., local LLM] | [license] | [pre-written dialogue, lore text] | Narrative Director review |

### Tier 3: Live-Generated AI Content (DISCLOSE + GUARDRAILS required)
AI creating content at runtime that players interact with dynamically.

| Feature | Model/Service | Guardrails | Reporting Mechanism |
|---------|--------------|------------|-------------------|
| [e.g., dynamic NPC dialogue] | [model/API] | [content filter, blocklist, safety layer] | [player report button location] |
| [e.g., procedural quest generation] | [model/API] | [output validation, content bounds] | [player report mechanism] |

**Guardrail requirements for Tier 3 (Steam):**
- Safety system preventing illegal, offensive, or harmful output
- Player reporting mechanism for AI-generated content
- Content filtering and moderation pipeline
- Logging of AI outputs for review

## Prohibited Uses
- [ ] No AI-generated content shipped without human review
- [ ] No AI voice acting in shipping product without performer consent (SAG-AFTRA IMA)
- [ ] No training AI models on copyrighted work without license
- [ ] No AI-generated content presented as human-created without disclosure

## Quality Gates (5-Stage)
1. **AI Generation**: Tool produces raw output
2. **Automated QA**: Technical validation (resolution, format, performance)
3. **Domain Expert Review**: Art/Audio/Narrative Director approves quality and fit
4. **Integration Testing**: Asset works correctly in-engine
5. **Playtest Validation**: Players don't perceive quality gap

## Copyright Documentation
For each AI-generated asset, record:
- Tool used and version
- Prompt or input provided
- Human modifications made (describe creative decisions)
- Final human authorship percentage estimate
- NOTE: Purely AI-generated content cannot be copyrighted (U.S. Copyright Office). Document human creative contribution.

## Per-Storefront Disclosure Requirements

| Storefront | Tier 1 (Dev Tools) | Tier 2 (Pre-Generated) | Tier 3 (Live-Generated) |
|------------|-------------------|----------------------|------------------------|
| **Steam** | Exempt -- no disclosure required | Flag in store page content descriptor | Flag in content descriptor + document guardrails + player reporting mechanism |
| **itch.io** | Exempt | Tag as AI content (hand-edited outputs STILL must be tagged; non-tagged = delisted from browse/search; tagged projects appear on segregated "AI Assisted" browse page) | Tag as AI content + document guardrails |
| **App Store** | Exempt | Enhanced privacy disclosures if AI shares personal data with third parties | Enhanced privacy disclosures + explicit user permission for AI data sharing |
| **Google Play** | Exempt | Data safety section must reflect AI data usage | Data safety section + content policy compliance |
| **Epic Games Store** | Exempt | No specific AI policy announced (follow general content policies) | No specific AI policy announced |
| **Credits** | Optional | List AI tools in game credits under "AI-Assisted Production" | List AI tools and disclose live generation in credits |
| **Marketing** | N/A | Do not claim AI-generated content as hand-crafted | Do not claim AI-generated content as hand-crafted |

## SAG-AFTRA Compliance (if using AI voice)
- [ ] Informed consent obtained from any performers whose voice/likeness is used
- [ ] Disclosure of AI usage in credits
- [ ] Usage reports filed as required
- [ ] Fair compensation provided per IMA terms (15.17% increase over base)
