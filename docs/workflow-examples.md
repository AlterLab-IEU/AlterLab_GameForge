# Workflow Examples

Four end-to-end walkthroughs showing how GameForge skills chain together in real indie dev scenarios. Not sure which applies? Run `/gameforge:game-help`.

---

## Example 1: From Zero to Playable Prototype

You have a vague idea -- "a roguelike where spells have weight." Here's how to get from that to something playable.

### Step 1: Bootstrap the project

```
claude> /gameforge:game-start
```

**What it does:** Asks you 5--8 questions about your game (genre, target platform, team size, timeline). Then sets up `.gameforge/project.json`, copies the engine starter `CLAUDE.md`, configures Git LFS, and generates:
- A GDD skeleton with your concept, pillars, and scope
- A tech stack recommendation (engine, tools, version control)
- A 3-milestone plan with deliverables and dates

**What you get:** A `game-design-document.md` file in your project and a clear picture of what you're building.

**Tip:** If you already know your engine, say so up front -- "Start a Godot 4.7 roguelike about weighted spells." The skill adapts.

### Step 2: Explore and refine the concept

```
claude> /gameforge:game-brainstorm
```

**What it does:** Runs a structured ideation session in two phases:
1. **Diverge** -- generates 10+ mechanic variations on your core concept (weighted spells could mean inventory weight, casting cost, physical impact, spell momentum)
2. **Converge** -- scores each concept on innovation, feasibility, and market fit, then ranks them

**What you get:** A scored concept matrix and a recommendation for which direction to pursue. Also flags potential market conflicts ("there are 3 weight-based roguelikes releasing this quarter").

### Step 3: Lock in the design

```
claude> /gameforge:game-designer
```

**What it does:** Takes your chosen concept and designs the core systems:
- Core gameplay loop (what the player does every 30 seconds, 5 minutes, 30 minutes)
- Progression system (how the player grows across runs)
- Economy model (currency, upgrades, unlocks)
- Balance targets (damage curves, difficulty ramp, expected run length)

**What you get:** A detailed systems design section added to your GDD with concrete numbers, not hand-waving.

### Step 4: Build the minimal playable

```
claude> /gameforge:game-prototype
```

**What it does:** Scopes your prototype to the absolute minimum needed to test the core loop:
- Identifies the one mechanic that *must* work for the game to be fun
- Strips everything else (no menus, no saving, no polish)
- Provides a build checklist with 1--2 day tasks
- Defines the "done" criteria -- what does a successful prototype look like?

**What you get:** A focused prototype plan. Build it, play it, and you'll know within a week if the core idea works.

**Next steps:** Once the prototype is playable, run `/gameforge:game-playtest` to structure a feedback session, or `/gameforge:game-code-review` to clean up the code before building on it.

---

## Example 2: Sprint Planning and Execution

You have a working prototype and a 2-week sprint ahead. Here's how to plan, execute, and learn from it.

### Step 1: Plan the sprint

```
claude> /gameforge:game-sprint-plan
```

**What it does:** Analyzes your project state (reads your repo if available) and helps you plan:
- Breaks features into tasks with hour estimates
- Maps dependencies ("UI polish depends on the inventory refactor")
- Flags risks ("the networking layer has no tests -- adding multiplayer here is dangerous")
- Sets a velocity target based on team size and history

**What you get:** A sprint plan with prioritized tasks, assignments, and a burndown target. Written to `sprint-plan.md`.

### Step 2: Build (you do this part)

This is the part where you write code, make art, compose music. GameForge doesn't build your game for you -- but when you get stuck:

- `/gameforge:game-godot-specialist` -- "How do I structure this scene tree for my inventory?"
- `/gameforge:game-designer` -- "Is this progression curve too steep?"
- `/gameforge:game-narrative-director` -- "Write dialogue for this NPC encounter"

### Step 3: Review the code

```
claude> /gameforge:game-code-review
```

**What it does:** Reviews your game code (point it at specific files or let it scan) for:
- Architecture problems ("this player script is doing input, physics, and UI -- split it")
- Performance risks ("you're allocating in _process -- cache this")
- Engine anti-patterns ("use signals instead of polling for this")
- Missing error handling, edge cases, resource leaks

**What you get:** A structured review with severity ratings (critical / warning / suggestion) and concrete fix recommendations.

### Step 4: Playtest the build

```
claude> /gameforge:game-playtest
```

**What it does:** Structures a playtest session:
- Defines what you're testing (is the new inventory system intuitive?)
- Creates an observer checklist (what to watch for, what to write down)
- Generates a post-session survey for playtesters
- Synthesizes feedback into actionable items

**What you get:** A playtest report with prioritized findings. Not just "players were confused" but "3/5 players couldn't find the equip button -- move it to the main action bar."

### Step 5: Reflect

```
claude> /gameforge:game-retrospective
```

**What it does:** Runs a GDC-format retrospective:
- What went well (keep doing)
- What went badly (stop doing)
- What to try next sprint (experiments)
- Kill list review -- which features should be cut entirely?
- Single-lesson forcing function -- "If you could only take one lesson from this sprint, what is it?"

**What you get:** A retrospective report that feeds directly into your next `/gameforge:game-sprint-plan`. The cycle continues.

---

## Example 3: Preparing for Launch

Your game is feature-complete. You have 3--4 weeks before release. Here's the final push.

### Step 1: Check the balance

```
claude> /gameforge:game-balance-check
```

**What it does:** Audits your game's balance using statistical methods:
- Runs Monte Carlo analysis on your combat/economy numbers
- Checks distribution curves for fairness (is RNG too swingy?)
- Calculates expected values for key player choices (is option A always better than option B?)
- Flags degenerate strategies ("stacking poison is 3x better than any other build")

**What you get:** A balance report with specific tuning recommendations and the math behind them.

### Step 2: QA pass

```
claude> /gameforge:game-qa-lead
```

**What it does:** Builds a comprehensive test plan:
- Critical path testing (can you get from start to credits without crashing?)
- Edge case matrix (what happens when inventory is full? what about 0 HP?)
- Platform-specific checks (controller support, resolution scaling, save/load)
- Regression suite for known bugs

**What you get:** A test plan document and a bug tracking template. Work through it systematically.

### Step 3: Prepare the launch

```
claude> /gameforge:game-launch
```

**What it does:** Prepares everything around the release:
- Store page copy (Steam description, tags, system requirements)
- Release checklist (builds, keys, press copies, trailer, screenshots)
- Day-1 patch plan (what to fix first based on early feedback)
- Post-launch ops (patch cadence, community channels, metrics to watch)
- Pricing strategy with regional pricing recommendations

**What you get:** A launch playbook. Follow it step by step on release day and the week after.

### Step 4: Know your market

```
claude> /gameforge:game-market-research
```

**What it does:** Analyzes your competitive landscape:
- Identifies comparable titles and their performance
- Estimates your total addressable market (TAM/SAM/SOM)
- Profiles your target audience (demographics, buying behavior, discovery channels)
- Recommends positioning -- how to differentiate in store listings and marketing

**What you get:** A market research report that informs your store page copy, pricing, and marketing spend.

**After launch:** Use `/gameforge:game-analytics-setup` to track KPIs, `/gameforge:game-postmortem` to review what worked, and `/gameforge:game-retrospective` for ongoing sprint cycles.

---

## Example 4: A Browser Game in a Weekend with an AI Agent

You want a small, original 3D browser game you can share on itch.io by Sunday night: "a lighthouse keeper guiding ships through fog with a sweeping beam."

### Step 1: Spec before code

```
claude> /gameforge:game-vibe-code a lighthouse keeper guides ships through fog with a sweeping beam
```

**What it does:** Interviews you briefly, then writes a one-page spec (core loop, win/lose, controls, what "fun" means for this game, a pass/fail check for each feature) and a short `CLAUDE.md` with the run and test commands first. It proposes the stack (Three.js with Vite and TypeScript here) and pins versions.

### Step 2: Playable in the first hour, verified at every step

The loop runs one feature at a time: implement, run the Playwright check that plays the game and screenshots it, read the `render_game_to_text()` state dump, fix, commit. Tuning constants (beam speed, fog density, ship spawn rate) live in one file so the "make it more fun" passes are quick. `progress.md` records what works, what is next and what is fragile, so a fresh session can pick up cleanly.

When the agent reaches for an outdated API, ask the specialist:

```
claude> /gameforge:game-threejs-specialist the fog looks banded on mobile; WebGPU or WebGL here?
```

### Step 3: Art and sound without losing coherence

```
claude> /gameforge:game-ai-assets low-poly lighthouse, three ship types, foghorn and waves
```

**What you get:** A style reference sheet, generated assets run through a glTF optimization pass, audio normalized and looped, and every asset recorded in `ai-asset-log.md` with tool, date, licence and your edits.

### Step 4: Ship it

```
claude> /gameforge:game-web-publish itch.io
```

**What it does:** Production build within a size budget, a mobile and iOS audio check, the itch.io page settings, a `butler push` command, and the AI disclosure text drafted from your asset log.

**What you get:** A playable link, a repository you can keep building, and nothing you would be embarrassed to open on Monday.

---

## What's Next?

- **Full skill catalog:** [README.md](../README.md#-skill-catalog)
- **FAQ:** [docs/FAQ.md](FAQ.md)
- **Contributing:** [CONTRIBUTING.md](../CONTRIBUTING.md)

---

*Built by [AlterLab](https://github.com/AlterLab-IEU) -- Part of the AlterLab Skills Trilogy*
