# GameForge Starters

Ready-to-copy configuration files that make GameForge skills work in your actual game project.

## What Are Starters?

After you install GameForge (`claude install github:AlterLab-IEU/AlterLab_GameForge`), the skills are available as slash commands. But Claude Code does not know anything about *your* game project -- your engine, your conventions, your file structure. Starters bridge that gap.

Each starter is a configuration file you copy into your game project. Once in place, Claude Code understands your project context and routes GameForge skills correctly.

## How to Use Them

### Step 1: Pick Your Engine

| Your Engine | Copy From |
|---|---|
| Any engine (start here) | `starters/claude-config/` |
| Godot 4.x | `starters/godot/` |
| Unity 6.x | `starters/unity/` |
| Unreal Engine 5.x | `starters/unreal/` |

### Step 2: Copy the Base Config

Every project needs the base config. Copy these into your game project root:

```bash
# Copy CLAUDE.md to your project root
cp starters/claude-config/CLAUDE.md /path/to/your-game/CLAUDE.md

# Copy settings.json to your project's .claude/ directory
mkdir -p /path/to/your-game/.claude
cp starters/claude-config/settings.json /path/to/your-game/.claude/settings.json
```

### Step 3: Add Your Engine Config

Copy the engine-specific CLAUDE.md content and append it to your project's CLAUDE.md, or use it as a reference to add engine-specific sections.

```bash
# Option A: Append engine config to your CLAUDE.md
cat starters/godot/CLAUDE.md >> /path/to/your-game/CLAUDE.md

# Option B: Use the engine CLAUDE.md standalone (if you prefer a clean start)
cp starters/godot/CLAUDE.md /path/to/your-game/CLAUDE.md
```

Copy the engine-specific .gitignore if you do not already have one:

```bash
cp starters/godot/.gitignore /path/to/your-game/.gitignore
```

### Step 4: Fill in Placeholders

Open your CLAUDE.md and replace the `[BRACKETED PLACEHOLDERS]` with your game's details. There are only a few -- project name, genre, and a one-liner description. Everything else works out of the box.

## What Each File Does

| File | Purpose | Goes Where |
|---|---|---|
| `claude-config/CLAUDE.md` | Tells Claude about your game, routes skills, sets coding standards | Project root |
| `claude-config/settings.json` | Permissions and safety rules for Claude Code | `.claude/settings.json` |
| `godot/CLAUDE.md` | Godot 4.x conventions, GDScript standards, scene patterns | Append to project CLAUDE.md |
| `godot/.gitignore` | Godot-specific ignore rules | Project root |
| `unity/CLAUDE.md` | Unity 6.x conventions, C# standards, assembly definitions | Append to project CLAUDE.md |
| `unity/.gitignore` | Unity-specific ignore rules | Project root |
| `unreal/CLAUDE.md` | UE 5.x conventions, C++/Blueprint standards, GAS patterns | Append to project CLAUDE.md |
| `unreal/.gitignore` | Unreal-specific ignore rules | Project root |

## FAQ

**Do I need all the files?**
No. You need the base config (`claude-config/`) plus your engine's files. A Godot developer copies `claude-config/CLAUDE.md`, `claude-config/settings.json`, `godot/CLAUDE.md`, and `godot/.gitignore`.

**Can I modify these files?**
Absolutely. These are starting points. Customize them for your project -- add your own conventions, remove sections that do not apply, adjust permissions.

**Do these replace GameForge installation?**
No. You still need to install GameForge for the skills. These files configure your *game project* to work well with those skills.

**What if I use a custom engine or framework?**
Use the base config (`claude-config/`). The engine-agnostic CLAUDE.md works with any technology. Add your own engine-specific section following the pattern in the engine starters.
