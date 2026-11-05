#!/usr/bin/env python3
"""GameForge repository validator.

Checks the things that silently break a Claude Code plugin, not just line counts:

  manifests    .claude-plugin/plugin.json + marketplace.json exist, agree on version,
               and every skills/ directory they list exists
  frontmatter  only documented skill fields; name == directory; description length;
               context: fork never combined with AskUserQuestion (subagents cannot ask);
               no unscoped Bash pre-approval
  size         per-category minimum lines, 500-line soft / 550-line hard cap per SKILL.md
               (deep material belongs in references/ loaded on demand)
  references   every ${CLAUDE_PLUGIN_ROOT}/ and ${CLAUDE_SKILL_DIR}/ path resolves, no
               legacy @docs/ imports, every references/*.md file is linked, every
               /gameforge:<skill> and `game-*` mention names a real skill or agent
  docs         relative markdown links resolve; skill/agent/template counts quoted in
               README, CLAUDE.md and docs match the filesystem
  hooks        hooks.json is valid and every hook script is wired
  agents       plugin subagents use supported fields and point at an existing skill
  genre packs  required files present

Usage: python3 scripts/validate.py [--verbose]
Exit status 0 when there are no errors (warnings allowed).
"""
from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VERBOSE = "--verbose" in sys.argv or "-v" in sys.argv

CATEGORY_MIN_LINES = {"agents": 200, "workflows": 150, "engine-specialists": 200}
SOFT_MAX_LINES, HARD_MAX_LINES = 500, 550
DESC_SOFT_MAX, DESC_HARD_MAX = 600, 1024

SKILL_FIELDS = {
    "name", "description", "when_to_use", "argument-hint", "arguments", "allowed-tools",
    "disallowed-tools", "effort", "context", "agent", "background", "disable-model-invocation",
    "user-invocable", "paths", "hooks", "shell", "metadata", "license", "compatibility",
}
SKILL_POLICY_FORBIDDEN = {
    "version": "skills are versioned by the plugin; remove the per-skill version",
    "memory": "memory is a subagent field; put persistent roles in agents/",
    "model": "GameForge skills respect the user's model choice; remove model",
}
AGENT_FIELDS = {
    "name", "description", "tools", "disallowedTools", "model", "permissionMode", "maxTurns",
    "autoCompactWindow", "skills", "mcpServers", "hooks", "memory", "background", "omitClaudeMd",
    "effort", "isolation", "color", "initialPrompt", "experimental",
}
AGENT_IGNORED_IN_PLUGINS = {"hooks", "mcpServers", "permissionMode", "initialPrompt"}
COUNT_FILES = ["README.md", "CLAUDE.md", "CONTRIBUTING.md", "starters/README.md", "package.json",
               ".claude-plugin/plugin.json", ".claude-plugin/marketplace.json"]

errors: list[str] = []
warnings: list[str] = []
passes = 0


def ok(msg: str) -> None:
    global passes
    passes += 1
    if VERBOSE:
        print(f"  PASS {msg}")


def err(msg: str) -> None:
    errors.append(msg)
    print(f"  FAIL {msg}")


def warn(msg: str) -> None:
    warnings.append(msg)
    print(f"  WARN {msg}")


def section(title: str) -> None:
    print(f"\n[{title}]")


def rel(p: Path) -> str:
    return str(p.relative_to(ROOT))


def parse_frontmatter(text: str) -> tuple[dict, str] | None:
    """Minimal YAML subset: scalars, quoted scalars, folded/literal blocks, simple lists."""
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---\n", 4)
    if end == -1:
        return None
    raw, body = text[4:end], text[end + 5:]
    data: dict = {}
    key = None
    block: list[str] | None = None
    for line in raw.split("\n"):
        m = re.match(r"^([A-Za-z][A-Za-z0-9_-]*):(?:\s+(.*))?$", line)
        if m:
            key, val = m.group(1), (m.group(2) or "").strip()
            if val in (">", "|", ">-", "|-", ">+", "|+"):
                block = []
                data[key] = block
            elif val == "":
                block = []
                data[key] = block
            else:
                block = None
                if len(val) >= 2 and val[0] == val[-1] and val[0] in "\"'":
                    val = val[1:-1]
                data[key] = val
        elif key is not None and block is not None:
            block.append(line.strip())
    for k, v in list(data.items()):
        if isinstance(v, list):
            items = [x[2:].strip() for x in v if x.startswith("- ")]
            data[k] = items if items and len(items) == len([x for x in v if x]) else " ".join(x for x in v if x)
    return data, body


def split_tools(value: str) -> list[str]:
    out, depth, cur = [], 0, ""
    for ch in value:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch == "," and depth == 0:
            out.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


# ---------------------------------------------------------------- inventory
skill_files = sorted(ROOT.glob("skills/*/*/SKILL.md"))
skills = {f.parent.name: f for f in skill_files}
agent_files = sorted((ROOT / "agents").glob("*.md")) if (ROOT / "agents").is_dir() else []
agents = {f.stem: f for f in agent_files}
templates = sorted((ROOT / "templates").glob("*.md"))
docs = sorted((ROOT / "docs").glob("*.md"))
hook_scripts = sorted((ROOT / "hooks").glob("*.sh"))
genre_packs = sorted(p for p in (ROOT / "genre-packs").glob("*") if p.is_dir())
by_cat: dict[str, list[str]] = {}
for name, f in skills.items():
    by_cat.setdefault(f.parent.parent.name, []).append(name)
template_stems = {t.stem for t in templates}
doc_stems = {d.stem for d in docs}

# ---------------------------------------------------------------- manifests
section("Plugin manifests")
plugin_json = ROOT / ".claude-plugin" / "plugin.json"
market_json = ROOT / ".claude-plugin" / "marketplace.json"
versions = {}
try:
    pj = json.loads(plugin_json.read_text())
    ok("plugin.json is valid JSON")
    versions["plugin.json"] = pj.get("version")
    if pj.get("name") != "gameforge":
        err(f"plugin.json name is {pj.get('name')!r}, expected 'gameforge'")
    listed = pj.get("skills", [])
    for d in listed:
        p = (ROOT / d).resolve()
        (ok if p.is_dir() else err)(f"plugin.json skills path {d} {'exists' if p.is_dir() else 'is missing'}")
    for cat in by_cat:
        if not any(Path(d).name == cat for d in listed):
            err(f"plugin.json does not list ./skills/{cat}; its skills will not load")
except Exception as e:  # noqa: BLE001
    err(f"plugin.json: {e}")
try:
    mj = json.loads(market_json.read_text())
    ok("marketplace.json is valid JSON")
    for k in ("name", "owner", "plugins"):
        (ok if k in mj else err)(f"marketplace.json has '{k}'")
    for p in mj.get("plugins", []):
        if p.get("name") == "gameforge":
            versions["marketplace.json"] = p.get("version")
except Exception as e:  # noqa: BLE001
    err(f"marketplace.json: {e}")
try:
    versions["package.json"] = json.loads((ROOT / "package.json").read_text()).get("version")
except Exception as e:  # noqa: BLE001
    err(f"package.json: {e}")
if len(set(versions.values())) == 1:
    ok(f"versions agree: {versions}")
    v = next(iter(versions.values()))
    changelog = ROOT / "CHANGELOG.md"
    if changelog.exists() and f"[{v}]" not in changelog.read_text():
        err(f"CHANGELOG.md has no entry for [{v}]")
else:
    err(f"version mismatch: {versions}")
if (ROOT / "marketplace.json").exists():
    err("root marketplace.json is not read by Claude Code; use .claude-plugin/marketplace.json")

# ---------------------------------------------------------------- skills
section("Skills")
known_names = set(skills) | set(agents)
for name, f in skills.items():
    cat = f.parent.parent.name
    text = f.read_text()
    parsed = parse_frontmatter(text)
    if not parsed:
        err(f"{name}: missing or malformed frontmatter")
        continue
    fm, body = parsed
    for k in fm:
        if k in SKILL_POLICY_FORBIDDEN:
            err(f"{name}: '{k}' -- {SKILL_POLICY_FORBIDDEN[k]}")
        elif k not in SKILL_FIELDS:
            err(f"{name}: unknown frontmatter field '{k}' (Claude Code ignores it)")
    for k in ("name", "description", "argument-hint", "allowed-tools"):
        (ok if fm.get(k) else err)(f"{name}: has {k}")
    if fm.get("name") and fm["name"] != name:
        err(f"{name}: frontmatter name {fm['name']!r} != directory name")
    desc = fm.get("description", "")
    if isinstance(desc, str):
        if len(desc) > DESC_HARD_MAX:
            err(f"{name}: description is {len(desc)} chars (max {DESC_HARD_MAX})")
        elif len(desc) > DESC_SOFT_MAX:
            warn(f"{name}: description is {len(desc)} chars; every description is loaded in every session, aim for <= {DESC_SOFT_MAX}")
    tools = split_tools(fm.get("allowed-tools", "")) if isinstance(fm.get("allowed-tools"), str) else fm.get("allowed-tools", [])
    if "Bash" in tools:
        err(f"{name}: allowed-tools pre-approves unrestricted Bash; scope it, e.g. Bash(git log *)")
    if fm.get("context") == "fork":
        if "AskUserQuestion" in tools:
            err(f"{name}: context: fork runs as a subagent, which cannot use AskUserQuestion")
    elif fm.get("context"):
        err(f"{name}: context must be 'fork' if set")
    lines = text.count("\n") + 1
    lo = CATEGORY_MIN_LINES.get(cat, 150)
    if lines < lo:
        err(f"{name}: SKILL.md has {lines} lines (min {lo} for {cat})")
    elif lines > HARD_MAX_LINES:
        err(f"{name}: SKILL.md has {lines} lines (max {HARD_MAX_LINES}); move deep material to references/")
    elif lines > SOFT_MAX_LINES:
        warn(f"{name}: SKILL.md has {lines} lines (target <= {SOFT_MAX_LINES})")
    else:
        ok(f"{name}: {lines} lines")
    if re.search(r"(?<![\w/])@(docs|templates|genre-packs)/", body):
        err(f"{name}: legacy @docs/@templates import; use ${{CLAUDE_PLUGIN_ROOT}}/...")
    for m in re.finditer(r"\$\{CLAUDE_PLUGIN_ROOT\}/([^\s`)'\"\]>]+)", body):
        target = m.group(1).rstrip(".,;:*")
        (ok if (ROOT / target).exists() else err)(f"{name}: ${{CLAUDE_PLUGIN_ROOT}}/{target} {'exists' if (ROOT / target).exists() else 'NOT FOUND'}")
    linked = set()
    for m in re.finditer(r"\$\{CLAUDE_SKILL_DIR\}/([^\s`)'\"\]>]+)", body):
        target = m.group(1).rstrip(".,;:*")
        linked.add(target)
        (ok if (f.parent / target).exists() else err)(f"{name}: ${{CLAUDE_SKILL_DIR}}/{target} {'exists' if (f.parent / target).exists() else 'NOT FOUND'}")
    for ref in sorted((f.parent / "references").glob("*.md")) if (f.parent / "references").is_dir() else []:
        r = f"references/{ref.name}"
        (ok if r in linked else err)(f"{name}: {r} {'is linked' if r in linked else 'is never linked from SKILL.md'}")
        rl = ref.read_text().count("\n") + 1
        if rl > 450:
            warn(f"{name}: {r} has {rl} lines; split it")
    mentioned = set(re.findall(r"/gameforge:([a-z0-9-]+)", body)) | set(re.findall(r"`(game-[a-z0-9-]+)`", body))
    for ref_name in sorted(mentioned):
        if ref_name in known_names:
            ok(f"{name}: cross-ref {ref_name}")
        elif ref_name in template_stems or ref_name in doc_stems:
            ok(f"{name}: names template/doc {ref_name}")
        else:
            err(f"{name}: references unknown skill or agent '{ref_name}'")

# ---------------------------------------------------------------- agents
section("Plugin subagents")
for name, f in agents.items():
    parsed = parse_frontmatter(f.read_text())
    if not parsed:
        err(f"agents/{f.name}: missing frontmatter")
        continue
    fm, body = parsed
    if fm.get("name") != name:
        err(f"agents/{f.name}: name {fm.get('name')!r} != filename")
    if not fm.get("description"):
        err(f"agents/{f.name}: missing description")
    for k in fm:
        if k in AGENT_IGNORED_IN_PLUGINS:
            err(f"agents/{f.name}: '{k}' is ignored for plugin subagents")
        elif k not in AGENT_FIELDS:
            err(f"agents/{f.name}: unknown field '{k}'")
    for m in re.finditer(r"\$\{CLAUDE_PLUGIN_ROOT\}/([^\s`)'\"\]>]+)", body):
        target = m.group(1).rstrip(".,;:*")
        (ok if (ROOT / target).exists() else err)(f"agents/{f.name}: {target} {'exists' if (ROOT / target).exists() else 'NOT FOUND'}")

# ---------------------------------------------------------------- hooks
section("Hooks")
try:
    hj = json.loads((ROOT / "hooks" / "hooks.json").read_text())
    wired = set()
    for event, groups in hj.get("hooks", {}).items():
        for g in groups:
            for h in g.get("hooks", []):
                m = re.search(r"\$\{CLAUDE_PLUGIN_ROOT\}/hooks/([\w.-]+\.sh)", h.get("command", ""))
                if not m:
                    err(f"hooks.json {event}: command does not use ${{CLAUDE_PLUGIN_ROOT}}/hooks/<script>.sh")
                    continue
                wired.add(m.group(1))
                (ok if (ROOT / "hooks" / m.group(1)).exists() else err)(f"hooks.json {event} -> {m.group(1)}")
    for s in hook_scripts:
        (ok if s.name in wired else err)(f"hook script {s.name} {'is wired' if s.name in wired else 'is not wired in hooks.json'}")
        if s.read_text().startswith("#!/usr/bin/env bash"):
            err(f"hook script {s.name} requires bash; hooks must be POSIX sh")
except Exception as e:  # noqa: BLE001
    err(f"hooks/hooks.json: {e}")

# ---------------------------------------------------------------- docs links & counts
section("Docs links")
md_files = [p for p in ROOT.rglob("*.md") if ".git" not in p.parts and "node_modules" not in p.parts
            and not str(p.relative_to(ROOT)).startswith("skills/")]
for p in md_files:
    text = p.read_text()
    prose = re.sub(r"```.*?```", "", text, flags=re.S)       # fenced code blocks
    prose = re.sub(r"`[^`\n]*`", "", prose)                    # inline code spans
    for m in re.finditer(r"\]\(([^)#\s]+)(?:#[^)]*)?\)", prose):
        link = m.group(1)
        if re.match(r"^[a-z]+:", link) or link.startswith("#"):
            continue
        target = (ROOT / link.lstrip("/")) if link.startswith("/") else (p.parent / link)
        if not target.exists():
            err(f"{rel(p)}: broken link {link}")
    if re.search(r"(?<![\w/])@(docs|templates)/", prose) and p.name not in ("CHANGELOG.md", "ROADMAP.md"):
        warn(f"{rel(p)}: uses @docs/@templates shorthand that only resolves inside this repo")
ok("relative links checked")

section("Counts quoted in docs")
total = len(skills)
cats = {k: len(v) for k, v in by_cat.items()}
real = {
    "agents": cats.get("agents", 0), "workflows": cats.get("workflows", 0),
    "engines": cats.get("engine-specialists", 0), "templates": len(templates), "hooks": len(hook_scripts),
    "docs": len(docs), "genre": len(genre_packs), "subagents": len(agents),
}
patterns = [
    (r"\b(\d+)\s+(?:production-grade\s+)?(?:Claude\s+(?:AI\s+|Code\s+)?)?skills\b", "skills"),
    (r"\b(\d+)\s+studio agents\b", "agents"),
    (r"\b(\d+)\s+workflow(?: skill)?s\b", "workflows"),
    (r"\b(\d+)\s+engine specialists\b", "engines"),
    (r"\b(\d+)\s+(?:starter\s+)?templates\b", "templates"),
    (r"\b(\d+)\s+(?:session\s+|lifecycle\s+)*hooks\b", "hooks"),
    (r"\b(\d+)\s+(?:shared\s+)?(?:knowledge[- ]base\s+)?(?:docs|documents)\b", "docs"),
    (r"\b(\d+)\s+genre packs\b", "genre"),
]
count_targets = [ROOT / f for f in COUNT_FILES] + docs
for p in count_targets:
    if not p.exists():
        continue
    for i, line in enumerate(p.read_text().splitlines(), 1):
        if "count-ok" in line:
            continue
        for pat, kind in patterns:
            for m in re.finditer(pat, line, flags=re.I):
                n = int(m.group(1))
                valid = {total, real["agents"], real["workflows"], real["engines"]} if kind == "skills" else {real[kind]}
                if n not in valid:
                    err(f"{rel(p)}:{i}: says '{m.group(0)}' but the repo has {sorted(valid) if kind == 'skills' else real[kind]}")
ok(f"counts: {total} skills {cats}, {real}")

# ---------------------------------------------------------------- templates / genre packs
section("Templates and genre packs")
corpus = "\n".join(f.read_text() for f in skill_files) + "\n".join(d.read_text() for d in docs)
for t in templates:
    (ok if t.name in corpus else warn)(f"templates/{t.name} {'referenced' if t.name in corpus else 'is not referenced by any skill or doc'}")
for gp in genre_packs:
    for req in ("README.md", "PATTERNS.md"):
        (ok if (gp / req).exists() else err)(f"genre-packs/{gp.name}/{req}")
    pat = gp / "PATTERNS.md"
    if pat.exists() and pat.read_text().count("\n") < 100:
        err(f"genre-packs/{gp.name}/PATTERNS.md is under 100 lines")

# ---------------------------------------------------------------- summary
print("\n" + "=" * 46)
print(f" skills: {total} {cats} | subagents: {len(agents)} | hooks: {len(hook_scripts)}")
print(f" checks passed: {passes} | errors: {len(errors)} | warnings: {len(warnings)}")
print("=" * 46)
sys.exit(1 if errors else 0)
