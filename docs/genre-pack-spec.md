---
name: genre-pack-spec
version: "2.0"
description: Format specification for AlterLab GameForge genre packs
---

# Genre Pack Specification

How to create, structure, and contribute genre-specific enhancement packs for GameForge. This document is the authoritative reference for genre pack format, quality requirements, and contribution workflow.

---

## What Genre Packs Are

Genre packs are **reference material**, not skills. They do not count toward the skill total, do not appear in the skill catalog, and do not require routing. Instead, existing skills like `game-brainstorm`, `game-designer`, and `game-balance-check` load genre pack content when the user specifies a genre. Genre packs add depth without increasing routing complexity.

---

## Directory Structure

```
genre-packs/
  roguelike/
    README.md              # Pack overview, when to use, example workflow
    PATTERNS.md            # Core design patterns, anti-patterns, reference games
    balance-template.md    # Genre-specific balance parameters and tuning framework
    brainstorm-variant.md  # Genre-tailored ideation prompts
  narrative/
    README.md
    PATTERNS.md
    balance-template.md
    brainstorm-variant.md
```

---

## Required Files

Every genre pack must contain at minimum these three files:

### 1. PATTERNS.md (200+ lines)

The core reference document. Must include:

1. **5+ core design patterns** with concrete descriptions, not abstract summaries. Each pattern references at least one shipped game.
2. **4+ anti-patterns** with problem, symptom, fix, and example structure.
3. **6+ reference games** with "Why it matters," "Key patterns," and MDA analysis for each.
4. **MDA analysis** specific to the genre, identifying primary and secondary aesthetics and the dynamics that produce them.
5. **Subgenre reference table** mapping subgenre variants to their defining features and key reference games.

Structure:

```markdown
---
name: "[genre]-patterns"
genre: "[genre name]"
version: "2.0"
description: "Design patterns and frameworks for [genre] game development"
---

# [Genre] Design Patterns

## Core Design Patterns
[5+ patterns unique to this genre with concrete examples from shipped games]

## Anti-Patterns
[4+ common mistakes with Problem/Symptom/Fix/Example structure]

## MDA Analysis
[Which aesthetics (Sensation, Fantasy, Narrative, Challenge, Fellowship,
Discovery, Expression, Submission) dominate this genre and why]

## Reference Games
[6-10 games that define the genre, with "Why it matters" and design takeaways for each]

## Subgenre Reference
[Table of subgenre variants with defining features and key reference games]
```

### 2. balance-template.md (100+ lines)

Genre-specific numerical parameters and tuning guidance. Must include:

1. **Concrete numerical ranges**, not just placeholder tables. Numbers should be derived from analysis of shipped games.
2. **Scaling formulas** with variables, coefficients, and worked examples.
3. **At least one simulation or testing methodology** (Monte Carlo, A/B testing framework, playtest protocol).
4. **Quality metrics** with target ranges and red flags.

```markdown
---
name: "[genre]-balance"
genre: "[genre name]"
version: "2.0"
description: "Balance parameters and tuning framework for [genre] games"
---

# [Genre] Balance Framework

## Key Parameters
[What numbers matter in this genre -- specific to the genre, not generic]

## Tuning Tables
[Concrete numerical frameworks -- not empty tables, but example values derived from shipped games]

## Scaling Formulas
[Formulas with variables, coefficients, and worked examples]

## Statistical Validation
[How to verify balance for this specific genre -- Monte Carlo, playtest protocol, etc.]
```

### 3. brainstorm-variant.md (80+ lines)

Genre-tailored ideation prompts that extend `game-brainstorm`. Must include:

1. **3+ core prompts** that define the genre's fundamental design questions.
2. **Genre constraint prompts** that force the designer to confront genre-specific tensions.
3. **Subgenre exploration prompts** for at least 3 subgenre variants.
4. **Market positioning prompts** that help differentiate the concept from established titles.

```markdown
---
name: "[genre]-brainstorm"
genre: "[genre name]"
version: "2.0"
description: "Genre-specific ideation prompts for [genre] game concepts"
---

# [Genre] Brainstorm Variant

## Core Prompts
[3+ fundamental design questions for this genre]

## Genre Constraint Prompts
[Questions that force designers to confront genre-specific tensions]

## Subgenre Exploration
[Prompts for at least 3 subgenre variants]

## Market Positioning
[Prompts that differentiate from established titles in the genre]
```

---

## Optional Files

| File | Purpose | When to Include |
|------|---------|-----------------|
| `README.md` | Pack overview with example workflow | Recommended for all packs |
| `gdd-template.md` | Genre-specific GDD extending the base template | Genres with unique document needs |
| `economy-template.md` | Genre-specific economy model | Genres with distinct economies (RPG, survival, idle) |
| `level-design-guide.md` | Genre-specific level design methodology | Spatial genres (metroidvania, platformer, tower defense) |

---

## How Genre Packs Integrate with Skills

Genre packs are consumed by existing skills, not loaded independently:

| Skill | Loads | Purpose |
|-------|-------|---------|
| `game-brainstorm` | `brainstorm-variant.md` | Genre-constrained ideation |
| `game-designer` | `PATTERNS.md` | Genre-specific mechanical guidance |
| `game-balance-check` | `balance-template.md` | Genre-specific tuning parameters |
| `game-economy-designer` | `economy-template.md` (if present) | Genre-specific economy models |
| `game-start` | Pack selection during project initialization | Genre awareness from day one |
| `game-gdd-author` | `PATTERNS.md` | Genre-specific GDD authoring guidance |

---

## Frontmatter Format

Every file in a genre pack begins with YAML frontmatter:

```yaml
---
name: {genre}-{file-type}    # e.g., roguelike-patterns, narrative-balance-template
genre: {genre}                # e.g., roguelike, narrative, survival-crafting
version: "2.0"                # Matches the GameForge version that introduced the pack
description: One-line description of the file's purpose
---
```

---

## Cross-Reference Conventions

- Reference other genre pack files: `@genre-packs/{genre}/filename.md`
- Reference shared docs: `@docs/filename.md`
- Reference templates: `@templates/filename.md`
- Reference skills by their frontmatter name: `game-designer`, `game-brainstorm`, etc.

---

## Quality Standards

Genre packs are evaluated on 5 dimensions, each scored 1-10. The minimum for merge is **8+ on all 5 dimensions**:

| Dimension | What It Measures |
|-----------|-----------------|
| **Accuracy** | Are patterns correct and grounded in shipped games? No fabricated claims. |
| **Actionability** | Can a developer read this and immediately apply it? Concrete numbers, formulas, examples. |
| **Completeness** | Does it cover the genre's core patterns? At least 5 patterns, 4+ anti-patterns, 6+ reference games. |
| **Integration** | Does it work with existing GameForge skills and use MDA/DDE framework language? |
| **Originality** | Does it add value beyond what a web search provides? Synthesis and insight, not just lists. |

See `@docs/skill-quality-rubric.md` for the full scoring guide.

Additional standards:

1. **PATTERNS.md** references at least 6 real, named games with specific design takeaways
2. **balance-template.md** contains concrete numerical examples derived from shipped games, not empty tables
3. **brainstorm-variant.md** contains at least 3 core prompts and produces usable output within 5 minutes
4. All files have valid YAML frontmatter with `name`, `genre`, `version`, `description`
5. MDA analysis uses the correct 8 aesthetic categories from `@docs/game-design-theory.md`
6. Anti-patterns follow the Problem/Symptom/Fix/Example structure
7. No overlap with content already in the base skills -- genre packs ADD, they don't duplicate

---

## Contributing a Genre Pack

See [CONTRIBUTING.md](../CONTRIBUTING.md) for the full contribution workflow. The short version:

1. Open an issue describing the genre pack you want to create
2. Fork the repo and create a branch: `feat/genre-pack-[genre]`
3. Create the directory under `genre-packs/[genre]/`
4. Write the three required files following the format above
5. Submit a PR with a description of why this genre needs a pack

---

*Built by [AlterLab](https://github.com/AlterLab-IEU) -- Part of the AlterLab Skills Trilogy*
