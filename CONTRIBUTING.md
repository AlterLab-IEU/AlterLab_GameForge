# Contributing to AlterLab GameForge

Thank you for your interest in improving GameForge. This guide covers how to contribute effectively.

---

## Getting Started as a Contributor

New here? Pick one of these quick wins to make your first PR:

1. **Fix a typo or broken link** -- browse any `SKILL.md` or doc file, fix what you find, submit a PR. Low effort, real impact.
2. **Improve a skill section** -- pick a skill you've used, find a section that could be clearer or more detailed, and expand it with better examples or frameworks.
3. **Add a FAQ entry** -- if you had a question that wasn't answered in [docs/FAQ.md](docs/FAQ.md), add it with a clear answer.

All three are valid `fix:` or `improve:` commits. No issue required for small fixes.

---

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

Open an issue first describing the skill's purpose, target user, and how it fits the existing roster. New skills must follow the AlterLab skill format. Use the issue templates in `.github/` if available, or describe:
- What the skill does (one paragraph)
- Who uses it and when
- Which existing skills it overlaps with or complements
- Estimated line count and category (agent / workflow / engine specialist)

### Contributing Starters

Starters are engine-specific configuration files in the `starters/` directory. To contribute:

1. **New engine starter:** Create a directory under `starters/` with a `CLAUDE.md` (engine conventions, commands, `.gitignore` and Git LFS blocks, the agent verification loop). Starters are copied into users' projects, so refer to skills as `/gameforge:<skill>` and never link to files in this repository. Follow the existing Godot, Unity, Unreal, Three.js and 2D web starters.
2. **Improving existing starters:** Update conventions to match the latest engine version. Keep configurations opinionated but not rigid -- starters are starting points, not mandates.
3. **Test your starter** by copying it into an actual game project and running several GameForge skills to verify they produce engine-appropriate output.

### Contributing Documentation

Documentation lives in three places:

| Location | What goes here |
|---|---|
| `docs/` | Shared knowledge base -- design theory, coding standards, integration guides |
| `docs/FAQ.md` | Common questions and answers |
| `docs/workflow-examples.md` | End-to-end workflow walkthroughs |

When contributing docs:
- Keep answers direct. 3--5 sentences per FAQ entry. No fluff.
- Workflow examples must show real commands (`/gameforge:game-start`) and concrete outputs, not abstract descriptions.
- Docs use ordinary relative links (`[hooks](hooks.md)`); `${CLAUDE_PLUGIN_ROOT}` is only substituted inside `SKILL.md` and `agents/*.md`.
- Reference existing skills and templates by their actual names and paths.

---

## Commit Convention

All commits must use conventional prefixes:

| Prefix | Use When |
|---|---|
| `feat:` | Adding a new skill, hook, template, starter, or doc |
| `improve:` | Enhancing an existing skill or workflow |
| `fix:` | Correcting errors, broken references, typos |
| `docs:` | README, CONTRIBUTING, FAQ, or docs/ changes only |
| `chore:` | Scripts, CI, config, repo maintenance |

Examples:
```
feat: add game-economy-designer agent skill
improve: expand game-designer balance frameworks with MDA analysis
fix: correct hook path in marketplace.json
docs: add sprint workflow example to workflow-examples.md
chore: add validation script for skill frontmatter
```

---

## Quality Bar (v3.0)

Two layers: an automated gate that must pass, and the [5-dimension rubric](docs/skill-quality-rubric.md)
(8+ on every dimension) applied in review.

**Automated gate** (`python3 scripts/validate.py`, `bash tests/hooks.test.sh`,
`claude plugin validate . --strict`):

- `SKILL.md` length: 200+ lines for agents and engine specialists, 150+ for workflows, **at most 500**
  (hard cap 550). Long code samples, catalogs and per-engine variants go in `references/*.md` inside
  the skill directory, each linked from `SKILL.md` with an instruction saying when to read it.
- Frontmatter uses only documented Claude Code fields. Required: `name` (equals the directory),
  `description` (at most 400 characters), `argument-hint`, `allowed-tools`. Usual: `effort` (`max`
  for the three directors, `high` for leads, specialists and heavy workflows, `medium` otherwise).
  Not allowed: `version`, `model`, `memory`.
- `allowed-tools` pre-approves tools while the skill runs, so never list bare `Bash`; scope it, for
  example `Bash(git diff *)` or `Bash(godot --headless *)`.
- `context: fork` only for report generators that need no conversation; a forked skill runs as a
  subagent and cannot use `AskUserQuestion`.
- Every `${CLAUDE_PLUGIN_ROOT}/...` and `${CLAUDE_SKILL_DIR}/...` path resolves, every skill you name
  exists, and every count you quote in docs matches the repository.

**Content** (reviewed):

- Versions, policies and dates are current and dated ("as of Unity 6.3 LTS"), with sources for
  anything non-obvious.
- Claims about named games or studios are public record and attributed. Statistics are sourced or
  labelled as rules of thumb.
- Code is correct for the engine versions it names.
- Each skill has a "When NOT to use me" boundary list, a section on working with AI coding agents for
  its role, and at least one concrete output template.
- Skills help users make original games; none helps recreate a specific existing game.

---

## Skill Format Reference

```markdown
---
name: game-example
description: >
  What the skill does, when to use it, its strongest trigger phrases, and one
  "Not for X (use game-y)" boundary. Third person, at most 400 characters.
argument-hint: "[what to pass]"
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(git diff *)
effort: high
---

# AlterLab GameForge -- Skill Title

You are **Persona Name**, ... (agents and specialists)

### When NOT to Use Me
## Process / Core Capabilities
## Frameworks & Methods
## Working with AI Coding Agents
## Output Templates
## Quality Standards
```

Path conventions inside `SKILL.md`:

| Refer to | Write |
|---|---|
| A shared doc | `${CLAUDE_PLUGIN_ROOT}/docs/game-design-theory.md` |
| A template | `${CLAUDE_PLUGIN_ROOT}/templates/sprint-plan.md` |
| A genre pack file | `${CLAUDE_PLUGIN_ROOT}/genre-packs/roguelike/PATTERNS.md` |
| This skill's reference file | `${CLAUDE_SKILL_DIR}/references/topic.md` |
| Another skill, for the user to run | `/gameforge:game-designer` |
| A file in the user's game project | plain relative path, e.g. `design/gdd/combat.md` |

Never use `@docs/...`; that import syntax only works in a CLAUDE.md.

---

## Testing Your Changes

1. **Run the checks:**
   ```bash
   python3 scripts/validate.py
   bash tests/hooks.test.sh
   claude plugin validate . --strict
   ```
2. **Load your working copy** in Claude Code: `claude --plugin-dir /path/to/AlterLab_GameForge`.
3. **Run 3+ prompts** that exercise the skill: its primary job, an edge case, and a request that
   should route to a sibling skill instead (it should not trigger).
4. **Check the cost:** after installing locally, `claude plugin details gameforge` shows the always-on
   and on-invoke token cost of each skill.
5. **Hooks:** add a case to `tests/hooks.test.sh` for any behaviour change. Hooks must parse under
   `dash` and stay silent outside game projects.

---

## Pull Request Checklist

- [ ] `python3 scripts/validate.py` passes
- [ ] `bash tests/hooks.test.sh` passes (if hooks changed)
- [ ] `claude plugin validate . --strict` passes
- [ ] Tested with 3+ prompts in Claude Code via `--plugin-dir`
- [ ] Versions, policies and claims about real games are sourced and dated
- [ ] Commit messages follow the convention above
- [ ] No secrets, API keys or personal data
- [ ] Starters tested in an actual game project (if applicable)

---

## Contributing a Genre Pack

Genre packs are in-repo reference material that enrich existing skills with genre-specific knowledge. They are not new skills and do not affect the skill count. See [docs/genre-pack-spec.md](docs/genre-pack-spec.md) for the full format specification.

### Contribution Levels

| Level | Type | Barrier | Review Required |
|-------|------|---------|----------------|
| 1 | Fix typos, broken links, improve wording in existing packs | None | Maintainer quick-review |
| 2 | Add reference games, expand anti-patterns, improve balance formulas | Low | Maintainer review |
| 3 | Contribute a new genre pack (3 files minimum) | Medium | Full quality review (5 dimensions) |

### How to Contribute a New Genre Pack

1. **Open an issue** describing the genre pack you want to create. Include:
   - Target genre name
   - 5+ reference games you will analyze
   - Bullet list of core patterns you plan to document (at least 5)
   - Rationale for why this genre is underserved

2. **Fork the repo** and create a branch:
   ```bash
   git checkout -b feat/genre-pack-{genre}
   ```

3. **Create the directory and required files**:
   ```
   genre-packs/{genre}/
     README.md              # Pack overview, when to use, workflow
     PATTERNS.md            # 200+ lines: design patterns, anti-patterns, MDA analysis, reference games
     balance-template.md    # 100+ lines: tuning parameters, scaling formulas, simulation guidance
     brainstorm-variant.md  # 80+ lines: ideation prompts, genre constraints, subgenre exploration
   ```

4. **Follow the format spec**: All files must have YAML frontmatter (`name`, `genre`, `version`, `description`). See [docs/genre-pack-spec.md](docs/genre-pack-spec.md) for exact structure and minimum content requirements.

5. **Self-check before submitting**:
   - [ ] PATTERNS.md has 5+ core patterns, 4+ anti-patterns, 6+ reference games with MDA analysis
   - [ ] balance-template.md has concrete numerical ranges (not placeholders) and at least one simulation methodology
   - [ ] brainstorm-variant.md prompts produce usable output within 5 minutes
   - [ ] All cross-references resolve to existing files
   - [ ] Pack is internally consistent (patterns referenced in balance template exist in PATTERNS.md)

6. **Submit a PR** against `main`. Your pack will be reviewed against the [5-dimension quality rubric](docs/skill-quality-rubric.md) with a minimum score of 8+ on all dimensions.

### Genre Pack Quality Dimensions

| Dimension | What It Measures |
|-----------|-----------------|
| **Accuracy** | Are patterns correct and grounded in shipped games? |
| **Actionability** | Can a developer apply this immediately? |
| **Completeness** | Does it cover core patterns, not just surface tropes? |
| **Integration** | Does it work with existing GameForge skills and frameworks? |
| **Originality** | Does it add value beyond what a web search provides? |

### Genre Pack Issue Template

When opening a genre pack proposal issue, use this format:

```markdown
## Genre Pack Proposal: [Genre Name]

### Target Genre
[Genre name and brief description]

### Reference Games (5+ required)
1. [Game] -- [Why it's a key reference]
2. [Game] -- [Why it's a key reference]
3. [Game] -- [Why it's a key reference]
4. [Game] -- [Why it's a key reference]
5. [Game] -- [Why it's a key reference]

### Core Patterns (outline)
- [Pattern 1]
- [Pattern 2]
- [Pattern 3]
- [Pattern 4]
- [Pattern 5]

### Why This Genre
[Why is this genre underserved? What indie market demand exists?]

### Estimated Timeline
[When you expect to submit the PR]
```

---

## Reporting Issues with Specific Skills

If you encounter a problem with a specific skill (incorrect advice, broken cross-references, outdated information, or routing issues), open an issue with:

1. **Skill name**: Which skill has the issue (e.g., `game-designer`, `game-balance-check`)
2. **Issue type**: Incorrect content, broken reference, routing problem, outdated information, or missing coverage
3. **Reproduction**: The prompt or workflow that exposed the issue
4. **Expected behavior**: What the skill should have done
5. **Actual behavior**: What it did instead
6. **Suggested fix** (optional): If you know how to fix it, describe the change

For small fixes (typos, broken links), skip the issue and submit a PR directly.

---

## Code of Conduct

Be respectful, constructive, and focused on improving the skills. We welcome contributors of all experience levels. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for the full code of conduct.

## Questions?

Open an [issue](https://github.com/AlterLab-IEU/AlterLab_GameForge/issues) or reach out to the maintainers. We are happy to help you get started.

---

Built with care at [AlterLab Creative Technologies Laboratory](https://github.com/AlterLab-IEU).
