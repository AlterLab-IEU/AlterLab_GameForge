---
name: skill-quality-rubric
version: "2.0"
description: Public 5-dimension quality scoring system for evaluating GameForge skills and genre packs
---

# Skill Quality Rubric

The 5-dimension quality scoring system used to evaluate every GameForge skill and genre pack. All contributions must score **8+ on every dimension** before merge.

---

## The Five Dimensions

### 1. Trigger Precision (T)

Does the skill activate for the right requests and stay silent for wrong ones?

| Score | Description |
|-------|-------------|
| 4 | Triggers on vaguely related keywords; activates when it should not; silent when it should activate |
| 6 | Mostly correct triggers but some false positives or misses; description could be clearer |
| 8 | Clean trigger/anti-trigger keywords; activates reliably for intended use cases; stays silent for adjacent skills |
| 10 | Perfect routing -- never activates incorrectly, never misses its target requests; description is a routing masterpiece |

**What to check:**
- Does the `description` field contain clear trigger keywords?
- Does it include anti-trigger language ("Do NOT invoke for...")?
- Would Claude route to this skill for the right questions?
- Would Claude avoid routing here for adjacent but different questions?

---

### 2. Domain Depth (D)

Does the skill demonstrate genuine expertise or just surface-level advice?

| Score | Description |
|-------|-------------|
| 4 | Generic advice that could come from any AI assistant; no frameworks, no references, no specifics |
| 6 | Some specialized knowledge but inconsistent depth; references frameworks without applying them |
| 8 | Deep, opinionated expertise with real frameworks, concrete examples, and production experience; references real games and tools |
| 10 | World-class expertise -- the kind of advice a 15-year veteran would give; every recommendation backed by evidence from shipped titles |

**What to check:**
- Does it reference real games, tools, and frameworks by name?
- Are code examples complete and runnable (not pseudocode)?
- Does it go beyond "best practices" to explain WHY and WHEN?
- Would a senior game developer learn something from this skill?

---

### 3. Output Consistency (C)

Does the skill produce structured, predictable output formats?

| Score | Description |
|-------|-------------|
| 4 | No clear output format; responses vary wildly between invocations; no templates |
| 6 | Has output templates but does not always follow them; structure varies |
| 8 | Consistent output structure with clear templates; every invocation produces the same format with different content |
| 10 | Production-grade output format that could be committed directly to a project; templates are complete and immediately usable |

**What to check:**
- Are output templates defined explicitly in the skill?
- Is the output format structured (tables, sections, checklists)?
- Would the output be useful as-is, or does it need reformatting?
- Does the skill write to files when appropriate?

---

### 4. Practical Usefulness (U)

Does a game developer walk away with something actionable?

| Score | Description |
|-------|-------------|
| 4 | Theoretical discussion with no actionable output; developer still does not know what to do next |
| 6 | Some actionable items but mixed with filler; developer has to extract the useful parts |
| 8 | Every section leads to action; developer walks away with a concrete artifact, plan, or decision |
| 10 | Transformatively useful -- the developer would pay for this skill if skills cost money; saves hours of work |

**What to check:**
- Does using this skill save the developer time?
- Does it produce a file, plan, or decision they can use immediately?
- Are recommendations specific enough to act on (not "consider accessibility")?
- Would a developer reach for this skill again after the first use?

---

### 5. Voice & Character (V)

Does the skill have a distinct, memorable personality?

| Score | Description |
|-------|-------------|
| 4 | Generic AI assistant voice; no personality, no opinions, no character |
| 6 | Some personality but inconsistent; occasionally opinionated but often falls back to neutral tone |
| 8 | Distinct voice with consistent opinions backed by experience; reads like a specific person, not a template |
| 10 | Unforgettable character -- you could identify this skill by voice alone; opinionated, sharp, and always consistent |

**What to check:**
- Could you tell which skill wrote this output without seeing the name?
- Does it have opinions and defend them with evidence?
- Is the voice consistent throughout the entire skill?
- Does it sound like a game dev veteran or a generic chatbot?

---

## Scoring Process

1. Read the entire SKILL.md file
2. Score each dimension independently (1-10)
3. Note specific evidence for each score (quote lines)
4. A skill with any dimension below 8 needs revision
5. Overall quality = minimum of the five scores (weakest link)

---

## Common Failure Modes

| Issue | Which Dimension It Fails |
|-------|-------------------------|
| "Consider using..." without specifics | Practical Usefulness (U) |
| No real game references | Domain Depth (D) |
| Generic AI voice | Voice & Character (V) |
| No output templates | Output Consistency (C) |
| Triggers overlap with another skill | Trigger Precision (T) |
| All theory, no code | Practical Usefulness (U) |
| Inconsistent formatting | Output Consistency (C) |
| No "When NOT to Use Me" section | Trigger Precision (T) |

---

## Applying the Rubric to Genre Packs

Genre packs are evaluated on the same 5 dimensions, but the interpretation shifts:

| Dimension | Genre Pack Interpretation |
|-----------|-------------------------|
| **Trigger Precision** | Does the pack clearly state when to use it and which skills consume it? Is the genre scope well-defined? |
| **Domain Depth** | Are design patterns grounded in shipped games? Are balance numbers derived from analysis, not guesswork? |
| **Output Consistency** | Do all files follow the frontmatter format? Are cross-references valid? Does the pack match the spec in `@docs/genre-pack-spec.md`? |
| **Practical Usefulness** | Can a developer use the balance template to set initial tuning parameters? Do brainstorm prompts produce concepts within 5 minutes? |
| **Voice & Character** | Is the writing opinionated and grounded? Does it read like genre expertise, not a Wikipedia summary? |

---

## Minimum Score for Merge

**All contributions require 8+ on every dimension.** The overall quality score is the minimum of the five individual scores (weakest link model).

| Score Range | Outcome |
|-------------|---------|
| All dimensions 8+ | Approved for merge |
| Any dimension 6-7 | Revision requested with specific feedback |
| Any dimension below 6 | Rejected with detailed rationale |

---

*Built by [AlterLab](https://github.com/AlterLab-IEU) -- Part of the AlterLab Skills Trilogy*
