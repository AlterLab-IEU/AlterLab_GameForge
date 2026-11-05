# Branching and Dialogue Tooling -- 2026 Field Guide

Load this when choosing a dialogue tool, setting up a narrative pipeline, or writing scripts an
agent will integrate. Versions were checked on 2026-11-05 against the projects' own release
pages and package registries. Re-check before you commit; these tools ship often.

---

## 1. Current state of the main tools

| Tool | What it is | Version facts (checked 2026-11-05) | Engines |
|---|---|---|---|
| **ink** (inkle) | Open-source markup-style scripting language for branching text; used in inkle's own games (*80 Days*, *Heaven's Vault*). Editor: **Inky**. | ink **1.2.x** is the current line (1.2.1 is the latest release on GitHub). **inkjs 2.4.0** published to npm 2026-02-17. | Unity (official ink-unity-integration), Unreal (**Inkpot** by The Chinese Room, UE 5.4+ per its README), Godot (**GodotInk**, C#-first, callable from GDScript), web (inkjs) |
| **Yarn Spinner** (Yarn Spinner Pty) | Screenplay-style dialogue language with nodes, variables, commands, line tags for localization. | **v3.0** (May 2025), **v3.1** (Dec 2025), **v3.2** (Mar 2026: descriptive line IDs, enum parameters, editor overhaul) per the official timeline. Core NuGet package at 3.2.2. A 3.3 release with a rewritten virtual machine is announced, undated. | Unity (2022.3+, feature-complete), Godot C# (4.6+, supported), Godot GDScript (4.6+, **early access**), Unreal (5.7+, **alpha**) per yarnspinner.dev/install |
| **Dialogic 2** | Godot-native visual dialogue and visual-novel editor (timelines, characters, portraits). | **2.0 Alpha 20** (July 2026) is the latest release: requires Godot 4.5+, 4.6+ recommended, fixes Godot 4.7 breakage, and introduced breaking changes. Still alpha; maintainers say beta waits until no breaking changes are planned. | Godot only |
| **articy:draft X** (Articy Software) | Commercial narrative database: flow graphs, entities, variables, localization and VO management. Mac version launched April 2025. | Unity importer 1.3.1 on the Asset Store (2026-03-06). Unreal importer and generic JSON export available. A September 2025 update added AI-assisted VO prototyping (third-party coverage). | Unity, Unreal, generic export for others |
| **Twine** | Free browser-based hypertext tool | Use for fast branching sketches and paper prototypes; not usually a shipping runtime. | Export HTML; port to a runtime tool |
| **Custom JSON/YAML** | Your own node graph format | Only when tools above cannot express your structure (systemic storylets, procedural barks). Budget for editor, validator and localization export. | Any |

Notes:
- Dialogic's alpha status matters for production: pin the exact release, read release notes on
  every Godot upgrade, and keep dialogue content in its files under version control.
- For Godot projects that need a stable, testable language, Yarn Spinner (C#) or ink via
  GodotInk (C#) are the safer bets today; GDScript-only teams can use Yarn Spinner's early-access
  GDScript runtime or Dialogic with the caveats above.
- Unreal teams: Inkpot is open source and maintained by a shipping studio; Yarn Spinner's Unreal
  runtime is alpha. articy:draft X has the most mature commercial Unreal pipeline.
- Web teams: inkjs is the most direct path (Three.js, Phaser, PixiJS, Kaplay all just call into
  the story object).

---

## 2. Selection matrix

| Need | First choice | Why |
|---|---|---|
| Prose-heavy branching, interactive fiction | ink | Terse syntax for weaving choices into text; strong state (variables, lists, tunnels) |
| Character dialogue with commands and VO lines | Yarn Spinner | Screenplay feel, line IDs for localization and VO, command hooks to the engine |
| Godot visual novel, small team, artists edit scenes | Dialogic 2 | In-editor visual timelines, portraits, no code for writers (alpha risk accepted) |
| Large cast, quests, database of entities, many writers | articy:draft X | Shared database, flow view, localization and VO tracking |
| Systemic storylets (quality-based narrative) | Custom data + validator, or ink/Yarn with a storylet layer | Preconditions and effects over world state; needs your own selection logic |
| Game jam | ink (web/Unity) or Yarn Spinner (Unity/Godot C#) | Fast to write, easy for agents to integrate |

---

## 3. Patterns that make scripts testable and agent-friendly

Plain-text scripts (`.ink`, `.yarn`) diff cleanly, can be compiled in CI, and are easy for an
agent to read and edit. Keep them in `design/narrative/scripts/` or the engine's content folder,
never only inside an editor database without export.

### ink: state and IDs
```ink
VAR trust_mara = 0
=== dock_meeting ===
Mara watches the harbor, not you. #id:dock_mara_001 #speaker:mara
* [Ask about the ship] #id:dock_choice_ship
    "Gone before dawn." #id:dock_mara_002 #speaker:mara
    ~ trust_mara += 1
* [Say nothing] #id:dock_choice_silent
    She nods, as if you passed a test. #id:dock_mara_003
    ~ trust_mara += 2
- -> harbor_hub
```
ink has no built-in string-table localization; tag every line with a stable ID and export text
through your pipeline (see `localization-ready-writing.md`).

### Yarn Spinner: line tags and commands
```yarn
title: Dock_Meeting
---
Mara: The harbor's quiet tonight. #line:dock_mara_001
-> Ask about the ship #line:dock_choice_ship
    Mara: Gone before dawn. #line:dock_mara_002
    <<set $trust_mara to $trust_mara + 1>>
-> Say nothing #line:dock_choice_silent
    <<set $trust_mara to $trust_mara + 2>>
<<camera_focus Mara 0.5>>
===
```
Yarn's line tags drive string tables and VO file names. Commands (`<<camera_focus>>`) are the
contract with engine code: list every command and its parameters in the narrative design doc.

### Narrative state registry
Every variable a script reads or writes is declared once, in `design/narrative/state-registry.md`:
```
| Variable | Type | Range | Written by | Read by | Purpose |
|---|---|---|---|---|---|
| trust_mara | int | 0-10 | dock_meeting, storm_scene | finale_choice | Mara joins only if >= 6 |
| knows_ship_gone | bool | | dock_meeting | captain_interrogation | Unlocks accusation |
```
A variable that is written but never read is narrative debt with no payoff. A variable read but
never written is a bug.

---

## 4. Automated checks for narrative scripts

Ask the agent to add these to CI (see `/gameforge:game-ci-pipeline`):

| Check | ink | Yarn Spinner | Dialogic / articy |
|---|---|---|---|
| Compiles without errors | `inklecate` compile | Yarn Spinner compiler (Unity/CLI) | Editor export succeeds |
| Every line has a unique stable ID | Lint for `#id:` tags | Line tags present and unique | Export IDs unique |
| No unreachable knots/nodes | Random-walk or exhaustive traversal script over inkjs | Node graph traversal | Flow export analysis |
| No dead ends (unless an ending) | Traversal flags knots with no exit | Same | Same |
| Every state variable in the registry | Parse `VAR` and `~` assignments | Parse `<<declare>>` and `<<set>>` | Variable export |
| Every engine command exists | Grep external function calls | Grep `<<command>>` names vs registry | Same |
| Line length within UI/VO limits | Measure per speaker | Same | Same |

Coverage report format:
```
Narrative coverage, build 2026-11-05, 5,000 random walks (seed 7)
Knots visited: 214/220 (97%). Unvisited: harbor_secret_1, harbor_secret_2 (gate: trust_mara >= 9, max reachable 8)
Endings reached: 4/4. Dead ends: 0. Missing line IDs: 3 (storm_scene.ink: 41, 57, 88)
```

---

## 5. Integration contract with engineering

Write this table into the narrative design doc so engineers and agents build the same thing:
| Element | Decision |
|---|---|
| Runtime | [ink / Yarn Spinner / Dialogic / articy / custom], exact version pinned |
| Script location | [path] |
| Line ID scheme | `<scene>_<speaker>_<nnn>`, never reused after deletion |
| Commands / external functions | [name(params) -> effect], owned by [system] |
| Variables | Source of truth: [script runtime / game save], sync direction |
| Save/load | What is saved (story state JSON, variable snapshot), when |
| VO | File naming = line ID; missing VO falls back to text |
| Localization export | Format (CSV/XLIFF/PO/JSON), cadence, owner |
| Barks | Separate system or script runtime? Priority and cooldown table location |
