# Contributing to AlterLab GameForge

Thank you for your interest in improving GameForge skills. This guide covers how to contribute effectively.

## How to Contribute

### Improving Existing Skills

1. **Fork** the repository and create a feature branch:
   ```bash
   git checkout -b improve/game-designer-balance-section
   ```
2. **Edit** the relevant `SKILL.md` file inside `skills/agents/`, `skills/workflows/`, or `skills/engine-specialists/`.
3. **Test** your changes (see Testing below).
4. **Submit a Pull Request** against `main` with a clear description of what changed and why.

### Proposing New Skills

Open an issue first describing the skill's purpose, target user, and how it fits the existing roster. New skills must follow the AlterLab skill format.

## Commit Convention

All commits must use conventional prefixes:

| Prefix     | Use When                                      |
|------------|-----------------------------------------------|
| `feat:`    | Adding a new skill, hook, template, or doc    |
| `improve:` | Enhancing an existing skill or workflow       |
| `fix:`     | Correcting errors, broken references, typos   |
| `docs:`    | README, CONTRIBUTING, or docs/ changes only   |
| `chore:`   | Scripts, CI, config, repo maintenance         |

Examples:
```
feat: add game-economy-designer agent skill
improve: expand game-designer balance frameworks with MDA analysis
fix: correct hook path in marketplace.json
docs: update architecture section in README
chore: add validation script for skill frontmatter
```

## Quality Bar

Every skill must meet these minimums before merge:

- **Agent skills**: 200+ lines of substantive content (no filler, no stubs)
- **Workflow skills**: 150+ lines of substantive content
- **Engine specialist skills**: 200+ lines with engine-specific code examples
- **No stubs**: Every section referenced in the table of contents must have real content
- **Frontmatter**: Valid YAML frontmatter with `name`, `category`, `version`, `description`
- **Emoji headers**: Follow the AlterLab header convention (see format reference below)

## AlterLab Skill Format Reference

Every SKILL.md follows this structure:

```markdown
---
name: skill-name
category: agents | workflows | engine-specialists
version: "1.0"
description: One-line description
---

# Emoji Skill Title

## Role & Identity (agents) or Purpose (workflows)
## Core Capabilities / Workflow Steps
## Frameworks & Methodologies
## Output Templates / Deliverables
## Quality Standards
## Integration Points
```

Key conventions:
- Use emoji prefixes in H1 headers to signal skill type
- Reference shared docs with `@docs/filename.md` notation
- Include concrete output templates, not abstract descriptions
- Specify which other skills this one collaborates with

## Testing Your Changes

Before submitting a PR, validate your skill works in practice:

1. **Load into Claude Code**: Copy the SKILL.md content into a Claude Code session as a custom instruction or slash command.
2. **Run 3+ test prompts** that exercise different sections of the skill:
   - A basic prompt that triggers the skill's primary function
   - An edge case or complex scenario
   - A prompt that tests collaboration references with other skills
3. **Check output quality**: Does the agent produce structured, actionable output? Does it follow the frameworks described in the skill?
4. **Run validation** (if available):
   ```bash
   npm run validate
   ```

## Pull Request Checklist

Before requesting review, confirm:

- [ ] Skill meets the minimum line count for its category
- [ ] All sections have substantive content (no TODOs or placeholders)
- [ ] Frontmatter is valid YAML with required fields
- [ ] Tested with 3+ prompts in Claude Code or Claude Projects
- [ ] Commit messages follow the convention above
- [ ] No secrets, API keys, or personal data included
- [ ] Links to shared docs use `@docs/` notation correctly

## Code of Conduct

Be respectful, constructive, and focused on improving the skills. We welcome contributors of all experience levels.

## Questions?

Open an issue or reach out to the maintainers. We are happy to help you get started.

---

Built with care at [AlterLab Creative Technologies Laboratory](https://github.com/AlterLab-IEU).
