---
name: "game-start"
description: >
  Use when the user asks about "starting a new game project", "setting up a game project",
  "project onboarding", or needs initial project scaffolding and state assessment. Part of
  the AlterLab GameForge collection.
argument-hint: "[engine: godot|unity|unreal]"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
---

# AlterLab GameForge -- Project Onboarding Workflow

Every game project has a beginning, but not every beginning looks the same. You might be
standing in front of an empty folder with nothing but ambition. You might have a thick design
document but zero lines of code. You might be stepping into a codebase someone else started
six months ago. This workflow detects where you are and gets you moving in the right direction
without wasting time on steps you have already completed.

The core philosophy: meet the project where it lives. Do not prescribe a rigid path. Diagnose
the current state, fill in the gaps, and point toward the next meaningful action.

### Purpose & Triggers

Use this workflow when:
- A developer says "I want to start a new game" or "help me set up my project"
- Someone joins an existing project and needs to get oriented
- A team wants a health check on their current project structure
- A solo dev has scattered files and wants to organize into a production-ready layout
- Anyone asks "where do I even begin?" in a game development context

Problems this solves:
- Analysis paralysis at the start of a new project
- Disorganized file structures that become unmanageable at scale
- Missing documentation that causes confusion later
- Skipped foundational decisions that create technical debt from day one
- New team members spending days figuring out where things live

### Critical Rules

1. **Never overwrite existing work.** If the project already has files, structures, or docs,
   preserve them. Suggest reorganization, never deletion without explicit confirmation.

2. **Detect before prescribing.** Always scan the project state before recommending actions.
   Do not assume an empty project. Do not assume an existing one is well-organized.

3. **Engine-agnostic until confirmed.** If no engine is detected from project files, ask.
   Do not guess. The wrong engine assumption wastes enormous time.

4. **Documents are not optional.** Every project needs at minimum: a concept document, a
   technical architecture note, and a task tracking system. These are not bureaucracy. They
   are the memory your future self will desperately need.

5. **Scope honesty from minute one.** If someone describes a 200-hour project and says they
   have 3 weekends, flag it immediately. Kindly, but immediately.

6. **Reference shared standards.** All structural decisions should align with the conventions
   documented in `docs/collaboration-protocol.md`. All design terminology should follow
   `docs/game-design-theory.md`.

### Workflow

**Step 0: Project State Detection**

Before any recommendations, assess the current state by scanning for these signals:

```
STATE DETECTION MATRIX
---------------------------------------------------------------
Signal                          | Indicates
---------------------------------------------------------------
No files / empty directory      | State 1: Empty Project
Design docs but no source code  | State 2: Concept Exists
Source code + design docs       | State 3: In-Progress
Mature codebase + CI + tests    | State 4: Existing Project
---------------------------------------------------------------

Engine Detection Signals:
- project.godot, *.gd, *.tscn        --> Godot Engine
- *.unity, *.cs, ProjectSettings/     --> Unity
- *.uproject, *.cpp + UE macros       --> Unreal Engine
- package.json + Phaser/PixiJS        --> Web-based engine
- Cargo.toml + Bevy/macroquad         --> Rust-based engine
- No recognizable engine files        --> Ask the user
```

Run the detection, report findings, then branch to the appropriate state handler.

---

**State 1: Empty Project**

The blank canvas. This is where most solo devs and small teams start.

Step 1.1 -- Choose your engine (if not already decided):
- Present tradeoffs honestly, not engine fanboyism
- Consider: team familiarity, target platform, game genre, performance needs
- For 2D pixel art: Godot is lightweight and fast to prototype
- For 3D with asset store needs: Unity has the broadest ecosystem
- For AAA-quality visuals: Unreal delivers but demands more hardware and expertise
- For web distribution: Phaser, PixiJS, or PlayCanvas
- Route to the appropriate engine specialist skill after selection

Step 1.2 -- Define the concept (route to `game-brainstorm` if needed):
- At minimum capture: working title, genre, platform, core mechanic, target audience
- If the user already has a concept, capture it in structured format
- If the user has no concept, route them to `game-brainstorm` before continuing

Step 1.3 -- Create the initial file structure:

```
project-root/
  design/
    gdd/                  -- Game Design Document and sub-documents
    narrative/            -- Story outlines, dialogue scripts, lore bibles
    levels/               -- Level layouts, progression maps, zone designs
    balance/              -- Economy spreadsheets, difficulty curves, tuning tables
  docs/
    architecture/         -- Technical architecture decisions and diagrams
    api/                  -- Internal API documentation for game systems
  src/
    core/                 -- Engine initialization, main loop, global managers
    gameplay/             -- Player mechanics, enemy behaviors, interaction systems
    ai/                   -- NPC behavior trees, pathfinding, decision-making
    ui/                   -- Menus, HUD, in-game UI components
    tools/                -- Editor extensions, debug tools, dev utilities
  assets/
    art/                  -- Sprites, textures, models, animations
    audio/                -- Music tracks, sound effects, ambient loops
    vfx/                  -- Particle systems, shader effects, post-processing
    shaders/              -- Custom shader files
    data/                 -- JSON/XML config files, localization strings, data tables
  tests/
    unit/                 -- Isolated component tests
    integration/          -- System interaction tests
    playtest/             -- Playtest session logs and feedback forms
  production/
    sprints/              -- Sprint plans, retrospectives, velocity charts
    milestones/           -- Milestone definitions and completion criteria
  prototypes/             -- Throwaway prototypes (never promote to production code)
```

Step 1.4 -- Generate starter documents:
- Create a minimal Game Concept Document (reference `templates/game-concept.md`)
- Create a Technical Architecture Note with engine choice rationale
- Create a `TODO.md` with immediate next steps
- Set up a basic `.gitignore` appropriate for the chosen engine

Step 1.5 -- Suggest next steps:
- Run `game-brainstorm` to flesh out the concept if it is thin
- Define 3-5 design pillars (reference `docs/game-design-theory.md` for methodology)
- Build the first throwaway prototype to test the core mechanic
- Estimate scope and plan a first sprint with `game-sprint-plan`

---

**State 2: Concept Exists (Docs, No Code)**

The user has thought about their game but has not started building it yet.

Step 2.1 -- Review existing documentation:
- Read all design docs and assess completeness
- Check against the 8 required GDD sections (reference `docs/game-design-theory.md`)
- Identify what is well-defined and what has gaps

Step 2.2 -- Gap analysis:
- Flag missing sections: core loop definition, pillar statements, scope estimate,
  technical requirements, art style reference, audio direction, UI wireframes, progression
- Rate each gap as Critical (blocks development), Important (causes confusion later),
  or Nice-to-have (polish item)

Step 2.3 -- Structural assessment:
- Are the docs organized in the standard structure, or scattered?
- If scattered, propose reorganization into the `design/` hierarchy
- Check for contradictions between documents

Step 2.4 -- Recommend next actions:
- Fill critical gaps first (usually: core loop and technical architecture)
- Route to `game-design-review` for a thorough design document review
- Create the file structure from State 1, Step 1.3 if it does not exist
- Identify the right moment to start coding (usually: after core loop is defined and
  one pillar mechanic is well-specified)

---

**State 3: In-Progress (Code and Docs)**

Development is underway. The goal is to assess health and recommend priorities.

Step 3.1 -- Codebase scan:
- Count source files, estimate project size
- Identify the primary language and engine
- Check for test files (any testing at all?)
- Look for configuration files, build scripts, CI setup
- Scan for TODOs, FIXMEs, HACKs in the codebase and report counts

Step 3.2 -- Documentation coverage:
- Does a GDD exist? How complete is it?
- Is there technical documentation?
- Are there inline code comments on complex systems?
- Is there a README that helps a new contributor get started?

Step 3.3 -- Structural health:
- Does the file structure follow a logical organization?
- Are there any massive god-files that need decomposition?
- Is there separation between gameplay logic and engine-specific code?
- Are assets organized or dumped in flat directories?

Step 3.4 -- Priority recommendations:
- Rank findings by impact: what is most likely to cause pain next?
- Suggest specific refactoring targets if the structure is problematic
- Recommend documentation tasks that will save time in the next month
- If testing is absent, recommend starting with the most critical system

---

**State 4: Existing Project (Mature Codebase)**

A well-established project. The goal is an honest audit, not a rubber stamp.

Step 4.1 -- Architecture audit:
- Map the high-level architecture: what systems exist and how do they communicate?
- Check dependency directions: are there circular dependencies?
- Assess the state management pattern: clean state machines or boolean soup?
- Evaluate the data pipeline: are gameplay values data-driven or hardcoded?

Step 4.2 -- Documentation audit:
- Rate doc coverage from 0-100%: what percentage of systems have documentation?
- Check doc freshness: are docs up to date or describing the game from 6 months ago?
- Identify the most dangerous undocumented system (highest complexity, lowest docs)

Step 4.3 -- Technical health check:
- Test coverage assessment: what is tested, what is not?
- Performance scan: any obvious hot-path concerns?
- Dependency audit: outdated packages, security issues?
- Build health: does the project build cleanly? Any warnings being ignored?

Step 4.4 -- Recommendations:
- Produce a prioritized action list organized by effort vs. impact
- Focus on risks: what is most likely to cause a production incident?
- Suggest process improvements (CI, testing, code review practices)
- Identify technical debt that should be addressed before the next major feature

### Output Format

The workflow produces a **Project State Report** structured as follows:

```markdown
# Project State Report
**Project:** [name]
**Date:** [date]
**Detected State:** [Empty / Concept / In-Progress / Existing]
**Engine:** [detected or user-specified]

## Current State Assessment
[Summary of what was found]

## Completed Items
- [What is already in good shape]

## Gaps & Issues
| Item | Severity | Category | Recommended Action |
|------|----------|----------|-------------------|
| ...  | Critical | Docs     | ...               |

## File Structure
[Current structure vs. recommended structure, with specific changes needed]

## Recommended Next Steps
1. [Highest priority action]
2. [Second priority]
3. [Third priority]

## Suggested Workflow Sequence
- [ ] [First workflow to run, e.g., game-brainstorm]
- [ ] [Second workflow, e.g., game-design-review]
- [ ] [Third workflow, e.g., game-sprint-plan]
```

### Quality Criteria

A successful project onboarding meets all of these:
- The detected state accurately reflects reality (no false assumptions)
- Every critical gap is identified and has a concrete recommended action
- The file structure is either created or a reorganization plan is provided
- The user knows exactly what to do next -- no ambiguity
- Engine-specific guidance matches the actual engine in use
- The recommended workflow sequence is logical and actionable
- Time estimates for next steps are honest, not optimistic
- The report is specific to this project, not generic boilerplate

### Example Use Cases

1. **"I want to make my first game."**
   Detects empty project, asks about engine preference and concept, scaffolds the full
   directory structure, creates starter documents, and routes to `game-brainstorm`.

2. **"I have a GDD but haven't started coding yet. What now?"**
   Detects State 2, reviews the GDD for completeness, identifies gaps, recommends filling
   critical sections before writing code, and suggests when to start prototyping.

3. **"I inherited this project from a teammate who left. Help me understand it."**
   Detects State 4, performs a full architecture audit, maps the systems, identifies
   undocumented areas, and produces an orientation guide for the new developer.

4. **"We have a prototype but it's getting messy. Should we restructure?"**
   Detects State 3, scans the codebase for structural issues, counts TODOs and FIXMEs,
   assesses test coverage, and recommends specific refactoring priorities.

5. **"Set up a new Godot project for a 2D roguelike."**
   Detects empty project with a known engine and genre, creates the directory structure
   with Godot-specific conventions, generates a concept doc stub with roguelike-relevant
   sections, and routes to the Godot engine specialist for setup guidance.
