# Security Policy

## Understanding Skill Security

GameForge skills are **markdown instruction files** that guide Claude's behavior during game development sessions. They do not execute code directly. However, skills can instruct Claude to:

- **Read and write files** in your project directory
- **Execute shell commands** via the Bash tool (builds, tests, git operations)
- **Create and modify source code** based on your requests

This means a maliciously crafted skill could potentially instruct Claude to perform unwanted file operations or execute harmful commands within your project.

## Before Installing

1. **Review skill content** — Every skill is a readable `.md` file. Check the `SKILL.md` content before use.
2. **Check `allowed-tools`** — This frontmatter field lists tools a skill may use *without asking you* while it runs. GameForge never pre-approves unscoped `Bash`; shell access is limited to patterns such as `Bash(git diff *)` or `Bash(godot --headless *)`, and the validator enforces this.
3. **Trust the source** — Skills from this repository are reviewed by AlterLab maintainers. Third-party skills should be inspected carefully.
4. **Use Claude Code permissions** — Configure `settings.json` to deny destructive operations. See `starters/claude-config/settings.json` for a recommended permission set.

## What the Hooks Do

GameForge ships seven hooks (`hooks/hooks.json`) that run automatically when the plugin is enabled.
They are POSIX shell scripts you can read in full, they make no network requests, they do nothing
outside game projects, and they write files only under `production/session-state/` and
`production/session-logs/` after a project opts in. Two of them can block a tool call: one stops
commits of large binaries that Git LFS is not tracking (and, once you opt in, commit messages that do
not match the convention), the other stops edits to engine-generated files. Details and opt-outs:
[docs/hooks.md](docs/hooks.md). `GAMEFORGE_HOOKS=off` disables all of them.

## MCP Servers and Engine Integrations

Skills recommend engine MCP servers (Unity, Unreal, Godot, Blender) but never install them. Several of
these servers execute arbitrary code in your editor and some have no authentication: keep them bound to
localhost, enable only the tools you need, and review what they change. See
[docs/mcp-integrations.md](docs/mcp-integrations.md).

## Reporting a Vulnerability

If you discover a security concern in any GameForge skill (e.g., a skill that could be exploited to exfiltrate data, execute harmful commands, or bypass permission boundaries):

1. **Do NOT open a public issue**
2. **Email:** cem.ipek@ieu.edu.tr
3. **Include:** Skill name, description of the concern, potential impact, steps to reproduce

We will acknowledge receipt within 48 hours and provide a fix or mitigation within 7 days for confirmed issues.

## Supported Versions

| Version | Supported          |
|---------|--------------------|
| 3.0.x   | Yes                |
| 2.0.x   | Security fixes only |
| < 2.0   | No                 |

## Scope

This policy covers the skill content, hooks, templates, and documentation in this repository. It does **not** cover:

- **Claude Code itself** — Report to [Anthropic](https://www.anthropic.com)
- **Third-party MCP servers** referenced in `docs/mcp-integrations.md` — Report to their respective maintainers
- **User-modified skill content** — You are responsible for changes you make to skills

## Best Practices

- Keep Claude Code updated to the latest version
- Use the principle of least privilege in your `settings.json` permissions
- Review hook scripts (`hooks/`) before enabling the plugin in a sensitive project
- Never commit `.env` files or credentials to your game project

---

*AlterLab GameForge — Built by [AlterLab Creative Technologies Laboratory](https://github.com/AlterLab-IEU)*
