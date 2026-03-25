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

### Web (Phaser, PixiJS, PlayCanvas)

Web projects typically follow JavaScript/TypeScript conventions:

| GameForge Concept | Web Path                            |
|-------------------|-------------------------------------|
| Source code       | `src/`, `lib/`                      |
| Assets            | `public/`, `assets/`, `static/`     |
| Config            | Root-level `package.json`, config files |

## How GameForge Hooks Adapt

All hooks use a `find_source_dirs()` function that checks multiple conventional locations before operating on source code:

```
Checked directories: src, scripts, Scripts, Source, Assets/Scripts, lib
```

Similarly, design directories are detected across: `design`, `design/gdd`, `docs/design`, `Documentation`.

Test directories are detected across: `tests`, `test`, `Tests`.

This means hooks work regardless of which engine convention your project follows. No configuration is needed.

## Customizing for Your Project

If your project uses a non-standard layout:

1. **Keep your existing structure.** Do not reorganize source code to match GameForge defaults.
2. **Add the overlay directories** where they make sense: `design/`, `docs/`, `production/`.
3. **Hooks are read-only.** They scan for files but never create or move source code.
4. If your source directory is not in the detection list above, the hooks will still run -- they will simply skip source-dependent checks gracefully.

The `design/`, `docs/`, and `production/` directories are the only ones GameForge expects to manage. Everything else belongs to your engine and your team's conventions.
