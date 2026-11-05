# GameForge Starters

Files you copy into your **game project** so Claude Code knows your engine, your conventions and how
to verify its own work. The GameForge plugin provides the skills; a starter provides the project
context.

The easiest path is `/gameforge:game-start`, which picks the right starter, copies it, creates
`.gameforge/project.json`, sets up Git LFS and the `.gitignore` entries GameForge needs. Use this page
if you prefer to do it by hand.

## Pick your starter

| Your project | Copy | To |
|---|---|---|
| Godot 4.7 / 4.8 | `starters/godot/CLAUDE.md` | `CLAUDE.md` |
| Unity 6.3 LTS / 6.6 | `starters/unity/CLAUDE.md` | `CLAUDE.md` |
| Unreal Engine 5.8 | `starters/unreal/CLAUDE.md` | `CLAUDE.md` |
| Three.js / React Three Fiber (Vite) | `starters/threejs/CLAUDE.md` | `CLAUDE.md` |
| Phaser 4 / PixiJS / Kaplay (Vite) | `starters/web2d/CLAUDE.md` | `CLAUDE.md` |
| Anything else | `starters/claude-config/CLAUDE.md` | `CLAUDE.md` |
| Any project, shared with a team | `starters/claude-config/settings.json` | `.claude/settings.json` |

Each engine starter is self-contained: stack and versions, run/build/test commands, folder layout,
coding rules, `.gitignore` and Git LFS blocks, the commit convention GameForge's hook checks, the
verification loop for AI agents, and which `/gameforge:` skills to use for what. Fill in the
`[BRACKETED PLACEHOLDERS]` (name, genre, one-line pitch) and adjust anything that does not fit.

```bash
# Example: a Godot project
cp AlterLab_GameForge/starters/godot/CLAUDE.md my-game/CLAUDE.md
mkdir -p my-game/.claude
cp AlterLab_GameForge/starters/claude-config/settings.json my-game/.claude/settings.json
```

If your project already has a `CLAUDE.md`, merge the starter's sections into it rather than
overwriting it.

## What `settings.json` does

- Declares the `alterlab-gameforge` marketplace and enables the `gameforge` plugin, so teammates who
  open the repository in Claude Code are prompted to install it.
- Allows routine read-only git commands without prompts, asks before pushes, merges, rebases,
  checkouts and stashes, and denies force-pushes, `git reset --hard`, `git clean`, `rm -rf`, `sudo`,
  and reading `.env` files or signing keys.

Edit the lists to match how your team works.

## FAQ

**Do these replace installing GameForge?**
No. Install the plugin for the skills (`/plugin install gameforge --marketplace AlterLab-IEU/AlterLab_GameForge`);
the starter configures your project for them.

**Why do starters never link to GameForge files?**
They live in your repository, not in the plugin. They refer to skills by name
(`/gameforge:game-designer`), which works wherever the plugin is installed.

**A custom engine or framework?**
Start from `claude-config/CLAUDE.md` and add an engine section modelled on the closest starter.
