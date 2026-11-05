# GameForge Directory Conventions

## Recommended Structure

GameForge suggests a generic project layout that separates concerns into clear top-level directories:

| Directory      | Purpose                                              |
|----------------|------------------------------------------------------|
| `design/`      | Game Design Documents, narrative scripts, balance data |
| `docs/`        | Technical architecture, API docs, shared references  |
| `src/`         | Source code (generic convention)                     |
| `assets/`      | Art, audio, VFX, shaders, data files                 |
| `tests/`       | Unit, integration, and playtest logs                 |
| `production/`  | Sprint plans, milestones, session state (gitignored) |
| `prototypes/`  | Throwaway experiments (never promote to production)  |

This layout works well for engine-agnostic or web-based projects. Real engine projects already have their own conventions, and GameForge adapts to them.

## Engine-Specific Layouts

### Godot

Godot projects use `project.godot` at the root. Source code lives alongside scenes:

| GameForge Concept | Godot Path                          |
|-------------------|-------------------------------------|
| Source code       | `scripts/`, `src/`, or inline with `.tscn` files |
| Scenes            | `scenes/`                           |
| Assets            | `resources/`, `assets/`             |
| Plugins           | `addons/`                           |

Overlay `design/`, `docs/`, and `production/` at the project root alongside `project.godot`.

### Unity

Unity projects use `Assets/` as the primary content root:

| GameForge Concept | Unity Path                          |
|-------------------|-------------------------------------|
| Source code       | `Assets/Scripts/`                   |
| Scenes            | `Assets/Scenes/`                    |
| Prefabs           | `Assets/Prefabs/`                   |
| Assets            | `Assets/Art/`, `Assets/Audio/`      |
| Plugins           | `Assets/Plugins/`                   |

Place `design/`, `docs/`, and `production/` at the project root alongside `Assets/`.

### Unreal Engine

Unreal projects use `*.uproject` at the root:

| GameForge Concept | Unreal Path                         |
|-------------------|-------------------------------------|
| Source code       | `Source/`                           |
| Content           | `Content/`                          |
| Config            | `Config/`                           |
| Plugins           | `Plugins/`                          |

Place `design/`, `docs/`, and `production/` at the project root alongside `Source/`.

### Web (Three.js, React Three Fiber, Phaser, PixiJS, Kaplay)

Web projects follow Vite + TypeScript conventions:

| GameForge Concept | Web Path                                              |
|-------------------|-------------------------------------------------------|
| Source code       | `src/` (`src/game/`, `src/systems/`, `src/scenes/`)   |
| Assets            | `public/assets/` (served as-is), `src/assets/` (bundled) |
| Tests             | `tests/` (Vitest unit tests, Playwright smoke tests)  |
| Build output      | `dist/` (never edit; GameForge's hook blocks it)       |
| Config            | `package.json`, `vite.config.ts`, `tsconfig.json`      |

The starters in `starters/threejs/` and `starters/web2d/` show the full layout.

## GameForge Project Files

These are the only files GameForge itself creates in your project, all through
`/gameforge:game-start` (or by hand):

```
.gameforge/
  project.json                 # per-project config read by hooks and skills
design/                        # GDD, pillars, level docs, balance data
docs/                          # architecture, ADRs, technical references
production/
  sprints/                     # sprint plans
  milestones/                  # milestone reviews, post-mortems
  session-state/               # gitignored: active.md, snapshots, recovery notes
  session-logs/                # gitignored: session and agent logs
CLAUDE.md                      # project instructions, from the engine starter
.claude/settings.json          # optional: permissions + GameForge marketplace
```

### `.gameforge/project.json`

```json
{
  "name": "Ember Drift",
  "engine": "godot",
  "engine_version": "4.7",
  "phase": "prototype",
  "pillars": ["tense", "readable", "short runs"],
  "commit_convention": "conventional",
  "lfs_threshold_mb": 20
}
```

| Key | Used by | Values |
|---|---|---|
| `name` | skills | Working title |
| `engine`, `engine_version` | skills | `godot`, `unity`, `unreal`, `threejs`, `r3f`, `babylon`, `playcanvas`, `phaser`, `pixi`, `kaplay`, `excalibur`, `bevy`, `other` |
| `phase` | session briefing, skills | `concept`, `pre-production`, `prototype`, `vertical-slice`, `production`, `polish`, `release`, `post-launch` |
| `pillars` | creative director, design review | 3-5 short phrases |
| `commit_convention` | commit hook | `conventional` (default), `gameforge`, `off` |
| `lfs_threshold_mb` | commit hook | Integer, default `20` |

Creating `.gameforge/` or `production/session-state/` opts the project into GameForge's
state-writing hooks. Add these lines to `.gitignore`:

```
production/session-state/
production/session-logs/
```

### `production/session-state/active.md`

The hand-off note between sessions and between people. The session-start hook shows its first
lines to Claude at the start of every session and after compaction. Long-running skills update it
when they finish. Keep it short:

```markdown
# Active focus
**Now:** dash ability: tuning the air-dash cancel window
**Decisions:** dash costs stamina (2026-11-02, game-designer); no double jump (pillar: readable)
**Next:** playtest build Friday; fix camera snap on dash end (bug #41)
**Blocked on:** final SFX for dash (audio)
```

### Where skills write

Canonical locations for the documents GameForge skills create. Skills read these paths first and
create them only when the user asks for the deliverable.

| Path | Written by | Contents |
|---|---|---|
| `design/concept.md`, `design/vision.md`, `design/pillars.md` | brainstorm, creative director | Concept, vision, pillars (pillar names mirrored in `project.json`) |
| `design/gdd.md` or `design/gdd/` | `game-gdd-author` | Game design document |
| `design/systems-index.md` | game designer, GDD author | Every system, owner, status, dependencies |
| `design/decisions/creative-log.md` | creative director | Creative decision records |
| `design/vibe-spec.md` | `game-vibe-code` | One-page spec for an agent-built game |
| `design/art-bible.md`, `design/sound-bible.md` | art and audio directors | Style authorities |
| `design/ai-content-policy.md` | creative and technical directors | AI-use stance and rules |
| `design/ai-asset-log.md` | `game-ai-assets`, everyone who generates assets | Provenance log; source of all AI disclosures |
| `design/balance/`, `design/economy/` | balance check, economy designer | Tuning data, changelogs, economy models |
| `design/ux/`, `design/accessibility/` | UX designer, accessibility specialist | Flows, audits, accommodation matrix |
| `design/narrative/` | narrative director | Scripts, characters, lore |
| `design/prototypes/` | `game-prototype` | Prototype questions and reports |
| `docs/architecture/` | technical director, reverse-document, multiplayer | Architecture overviews, `adr-NNN-<slug>.md`, performance budgets |
| `production/reviews/` | `game-code-review` | `code-review-YYYY-MM-DD-<slug>.md` reports |
| `production/sprints/` | `game-sprint-plan`, retrospective | `sprint-NN.md`, `sprint-NN-retro.md`, `velocity.md` |
| `production/milestones/` | producer, retrospective, postmortem | Milestone reviews, gates, post-mortems |
| `production/releases/` | `game-launch`, `game-web-publish` | Release checklists, build reports, AI disclosure drafts |
| `production/risk-register.md`, `production/cut-list.md`, `production/calendar.md` | producer, scope check | Risks, cut lists, external dates |
| `tests/` | QA lead, vibe-code, multiplayer, playtest | Test plans, gates, playtest reports, end-to-end checks |
| `tools/` | balance check, economy designer, vibe-code | Simulators and check scripts |

## How GameForge Hooks Adapt

Hooks detect the engine from its project file (`project.godot`,
`ProjectSettings/ProjectVersion.txt`, `*.uproject`, or `package.json` dependencies) and stay
silent in repositories that are not game projects. The session briefing looks for:

| Signal | Directories checked |
|---|---|
| Source code | `src`, `scripts`, `Scripts`, `Source`, `Assets/Scripts`, `lib`, `game` (engine projects always count as having source) |
| Design docs | `design`, `docs/design`, `Documentation`, `production/gdd` |
| Tests | `tests`, `test`, `Tests`, `Assets/Tests` |

No configuration is needed. See [hooks.md](hooks.md) for the full reference.

## Customizing for Your Project

1. **Keep your existing structure.** Do not reorganize source code to match GameForge defaults.
2. **Add the overlay directories** where they make sense: `design/`, `docs/`, `production/`.
3. **Hooks never move or rewrite your files.** They read project state, write only under
   `production/session-state/` and `production/session-logs/` after you opt in, and block edits
   to engine-generated files.
4. Set `"phase"` in `.gameforge/project.json` if the automatic phase guess is wrong.
