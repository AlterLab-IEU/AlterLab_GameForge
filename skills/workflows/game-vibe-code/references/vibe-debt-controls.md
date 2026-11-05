# Vibe-Debt Controls Reference

Read this at every refactor checkpoint (every five iterations, and before a jam's halfway point)
and before anything goes online. It turns "keep the code healthy" into checks that pass or fail.

## Why this exists

- An arXiv lifecycle study (Liu et al., arXiv 2603.28592, Mar 2026) tracks issues that AI agents
  introduce over time; secondary write-ups say most are code smells. Its exact figures were not
  verified for GameForge.
- Waseem et al. (arXiv 2512.11922) describe repeated regeneration leaving code without
  "structural rationale."
- A Vibe Jam 2026 entrant put it plainly: agents "are bad at knowing when the structure underneath
  needs to change" (R. Fitzpatrick, 12 Apr 2026).
- Simon Willison says he reviewed "almost none of the code" behind Battle Drones (20 Oct 2026),
  a game he calls "actually fun to play." Fun and unreviewed can coexist; the risk shows up the
  first time something must change.

None of this argues against agents. It argues for the human owning structure while the agent
owns typing.

## Module map

| Module | Owns | May import | Must not |
|---|---|---|---|
| `src/core/` | Loop, input, seeded rng, test hooks, overlay | Browser APIs | Game rules |
| `src/game/` | Rules on plain data: step, collisions, scoring | `src/game/`, `src/tuning.ts`, rng types | DOM, `window`, three/phaser, `Math.random` |
| `src/render/` | Meshes, sprites, effects driven by state | `src/game/` types, engine | Writing game state |
| `src/ui/` | Menus, HUD, settings | State read-only, engine | Rules |
| `src/net/` | Client side of the protocol | Message types | Trusting anything the server did not confirm |
| `src/tuning.ts` | Every feel number | Nothing | Logic |

Write the map's first two columns into `CLAUDE.md`. Agents follow boundaries they can read.

## Size limits (rules of thumb)

- A source file passes ~400 lines: split by responsibility before the next feature.
- A function passes ~60 lines: extract the steps it narrates in comments.
- A fly.pieter.com recreation's notes cite a warning from its creator that single-file games pass
  3,000 lines (secondary source). Split early; it is cheaper at 400 than at 3,000.

## The debt check: `tests/structure.mjs`

Add `"debt": "node tests/structure.mjs"` to `package.json`. Run it at each checkpoint and before
shipping; it exits 1 on any flag.

```js
// tests/structure.mjs: fails on vibe-debt red flags. Usage: npm run debt (after npm run build)
import { existsSync } from 'node:fs';
import { readdir, readFile } from 'node:fs/promises';
import { join, sep } from 'node:path';

const MAX_LINES = 400;
const SECRET = /(sk_live_[0-9A-Za-z]{10,}|sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----)/;
const problems = [];

async function* walk(dir) {
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) yield* walk(path);
    else yield path;
  }
}

for await (const file of walk('src')) {
  if (!/\.(ts|tsx|js|mjs)$/.test(file)) continue;
  const text = await readFile(file, 'utf8');
  const lines = text.split('\n').length;
  if (lines > MAX_LINES) problems.push(`${file}: ${lines} lines; split it (max ${MAX_LINES})`);
  if (file.startsWith(`src${sep}game${sep}`) && /from ['"](three|phaser)|\bdocument\.|\bwindow\./.test(text)) {
    problems.push(`${file}: src/game must stay pure (no engine imports, no DOM)`);
  }
  if (/Math\.random\(/.test(text)) problems.push(`${file}: Math.random(); use the seeded rng`);
}

if (existsSync('dist')) {
  for await (const file of walk('dist')) {
    if (!/\.(js|html|json|map)$/.test(file)) continue;
    if (SECRET.test(await readFile(file, 'utf8'))) problems.push(`${file}: looks like a secret key in the shipped bundle`);
  }
}

for (const p of problems) console.log(`FLAG ${p}`);
console.log(problems.length ? `${problems.length} vibe-debt flags` : 'No vibe-debt flags');
process.exit(problems.length ? 1 : 0);
```

The secret pattern catches common key shapes only. It is a tripwire, not a scanner; the real rule
is that keys never enter client code at all.

## Refactor checkpoint protocol

1. **Snapshot behavior.** Run `npm run verify` and copy `tests/e2e/out/` aside. With fixed seeds,
   the state JSON is a golden master.
2. **Run `npm run debt`.** Fix every flag first.
3. **Explain-this-file reviews** for the three files changed most in the last 20 commits
   (`git log --stat -20`), using the prompt in SKILL.md. Anything Claude cannot explain in one
   sentence gets split or rewritten.
4. **Delete dead code.** Prompt: "List exports nothing imports, files in public/ nothing loads,
   commented-out blocks, and flags that are always on or always off. Delete them; change no
   behavior." Commit as `chore: remove dead code`.
5. **Refresh the module map** in `CLAUDE.md` (boundaries only, never a file listing).
6. **Prove nothing changed.** Re-run verify; diff the new state JSON against the snapshot. Any
   difference in a refactor commit is a bug, not a feature.
7. Commit as `refactor: <what moved>`, and log the checkpoint in `docs/iteration-log.md`.

## Review prompts

- **Spec-gap review (fresh context):** "Use a subagent to review the diff since <tag> against
  design/vibe-spec.md. Check every done-criterion and that each feature has a scenario. Report
  gaps that affect correctness and skip style." Anthropic's docs warn that dropping "skip style"
  gets you abstraction layers and tests for cases that cannot happen.
- **Built-in review:** `/code-review` reviews the diff in a fresh subagent that never saw your
  conversation. For a full architecture pass, run `/gameforge:game-code-review`.
- **Delete before add:** "Before adding <feature>, find code that already does part of it, or that
  it makes obsolete. Propose reuse or deletion first."
- **Why is this here:** "For each dependency in package.json, say which file uses it and what
  breaks without it. Flag any we can remove."

## Licenses: dependencies and assets

`tests/licenses.mjs` reads the npm lockfile (npm writes each package's declared license there) and
fails on anything outside an allowlist. Add `"licenses": "node tests/licenses.mjs"`.

```js
// tests/licenses.mjs: production dependency licenses from package-lock.json. Usage: npm run licenses
import { readFile } from 'node:fs/promises';

const ALLOWED = new Set(['MIT', 'ISC', 'BSD-2-Clause', 'BSD-3-Clause', 'Apache-2.0', '0BSD', 'Zlib', 'CC0-1.0', 'Unlicense', 'BlueOak-1.0.0']);
const lock = JSON.parse(await readFile('package-lock.json', 'utf8'));
const counts = {};
const review = [];

for (const [path, pkg] of Object.entries(lock.packages ?? {})) {
  if (path === '' || pkg.dev || pkg.devOptional) continue; // root project and dev-only tools
  const license = typeof pkg.license === 'string' ? pkg.license : 'UNKNOWN';
  counts[license] = (counts[license] ?? 0) + 1;
  if (!ALLOWED.has(license)) review.push(`${path.replace(/^.*node_modules\//, '')}@${pkg.version}: ${license}`);
}

console.log(counts);
if (review.length) {
  console.log(`Review before shipping:\n  ${review.join('\n  ')}`);
  process.exit(1);
}
console.log('All production dependency licenses are on the allowlist.');
```

SPDX expressions such as `(MIT OR Apache-2.0)` land in "review"; read them and extend the
allowlist deliberately. This works with npm's lockfile only; pnpm and Yarn need their own tools.

Licenses worth knowing in late 2026 (from the GameForge research briefs):

| Item | Watch for |
|---|---|
| GSAP 3.13+ | Free, including former paid plugins, but not MIT: the Webflow "Standard License" forbids using it in tools that let users build animations without code |
| Phaser AE | A separate, agent-oriented product under PolyForm Shield with paid tiers; Phaser 4 itself is MIT |
| Theatre.js, Howler.js | Theatre.js no longer recommended (public repo idle since Aug 2024); Howler.js works but has had no npm release since 2023 |
| Hunyuan3D 2.1 (open weights) | License does not apply in the EU, UK or South Korea, outputs included |
| TRELLIS.2 | MIT |
| Suno, Udio output | UMG and Sony are still suing Suno; Udio settled with UMG and disabled downloads. Treat both as legally unsettled for shipped games |

Generated assets, their licenses and their disclosure belong to `game-ai-assets`. Every asset gets
a row in `design/ai-asset-log.md` (copied from the plugin's `templates/ai-asset-log.md`) when it is
made or added, not when it ships. Third-party non-AI assets (CC0, bought, licensed) get a row too,
with disclosure `none`, so the license travels with the file:

```markdown
| ID | Path | Type | Tool + model/version | Date | Prompt / input summary | Reference inputs and rights | Output license | Human modifications | Reviewer | Disclosure | Status | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| PACK-001 | `public/sprites/tiles.png` | 2D tileset | <pack name + URL> | 2026-11-05 | — | n/a | CC0-1.0 | Recolored to the game palette | <name> 2026-11-05 | none | shipped (0.1.0) | License text saved beside the source files |
```

## Bundle budget: `tests/budget.mjs`

Files under `public/lazy/` (copied to `dist/lazy/`) are loaded after gameplay starts; everything
else counts as the initial download. Add `"budget": "node tests/budget.mjs"`.

```js
// tests/budget.mjs: initial and total download budgets for dist/.
// Usage: npm run build && node tests/budget.mjs [initialMB=20] [totalMB=250] [maxFiles=1500]
import { readdir, stat } from 'node:fs/promises';
import { join, sep } from 'node:path';

const [initialMB = 20, totalMB = 250, maxFiles = 1500] = process.argv.slice(2).map(Number);
const MB = 1024 * 1024;
const files = [];
for (const rel of await readdir('dist', { recursive: true })) {
  const info = await stat(join('dist', rel));
  if (info.isFile()) files.push({ rel, bytes: info.size, lazy: rel.startsWith(`lazy${sep}`) });
}
const total = files.reduce((n, f) => n + f.bytes, 0);
const initial = files.filter((f) => !f.lazy).reduce((n, f) => n + f.bytes, 0);
const fail = [];
if (initial > initialMB * MB) fail.push(`initial ${(initial / MB).toFixed(1)} MB > ${initialMB} MB`);
if (total > totalMB * MB) fail.push(`total ${(total / MB).toFixed(1)} MB > ${totalMB} MB`);
if (files.length > maxFiles) fail.push(`${files.length} files > ${maxFiles}`);

console.log(`initial ${(initial / MB).toFixed(2)} MB, total ${(total / MB).toFixed(2)} MB, ${files.length} files`);
for (const f of files.sort((a, b) => b.bytes - a.bytes).slice(0, 8)) console.log(`  ${(f.bytes / MB).toFixed(2)} MB  ${f.rel}`);
for (const f of fail) console.log(`OVER BUDGET ${f}`);
process.exit(fail.length ? 1 : 0);
```

Defaults match CrazyGames' mobile-homepage initial cap and its total limits. Pass other numbers
for other targets (see `jam-and-portal-checklist.md`), for example `node tests/budget.mjs 30 250`
for YouTube Playables' initial cap. Raw bytes overstate what gzip or Brotli serve, so a pass here
is conservative.

## Runtime performance budget

- **Test on a mid-range Android phone,** not only a flagship iPhone. A 2026 practitioner write-up
  reports a game smooth on iPhone that stuttered on mid-range Android. CrazyGames disables games
  that are not smooth on 4 GB Chromebooks.
- **Show the numbers in the overlay:** FPS, plus draw calls (`renderer.info.render.calls` in
  three.js) and entity counts.
- **Heuristics, not standards:** about 100 to 200 draw calls on mobile, textures up to 2048 px in
  KTX2, device pixel ratio capped at 1.5 to 2, instancing or batching for repeated meshes.
- **Audio:** an `AudioContext` must be resumed from a user gesture (iOS), and Firefox blocks Web
  Audio until the page has sticky activation. Unlock on the first input.
- Deep rendering budgets go to `game-threejs-specialist` or `game-web2d-specialist`.

## Security checklist for anything online

- [ ] **The server owns** state, scores, matchmaking and purchases. Clients send inputs; the
      server validates type, range and rate for every message. Netcode design goes to
      `game-multiplayer`.
- [ ] **Scores are recomputed or validated server-side.** With a deterministic simulation, the
      client can submit seed plus inputs and the server replays them.
- [ ] **No secrets in the bundle.** Anything in a `VITE_*` environment variable is compiled into
      client code. Calls to paid APIs (including AI models) go through your server with per-user
      rate limits. `npm run debt` scans `dist/` for common key shapes.
- [ ] **No authority on `window`.** Release builds compile out test hooks and debug globals (the
      `DEBUG_BUILD` flag in `game-test-hooks.md`); never deploy the test build. The
      fly.pieter.com flight sim (Feb 2025) kept game state in page globals; its creator published
      a mod that overrides `checkCollisions` and `animate`, a player reported someone "constantly
      hitting everyone at the same time" (6 Mar 2025), and a researcher demonstrated an AI-assisted
      hack.
- [ ] **Purchases and entitlements verified server-side.** Discord's guidance for Activities:
      "Trust (the SDK), but Verify (via the API)."
- [ ] **Abuse and load:** rate limits per IP and per session; the static client on a CDN so a
      flood hits your edge, not your game server.
- [ ] **MCP and agent tools stay local.** Keep MCP servers on localhost; treat any tool that
      executes code (Blender MCP runs arbitrary Python over an unauthenticated socket; Unreal 5.8's
      MCP is loopback-only with no auth) as arbitrary code execution.
- [ ] **Dependencies pinned** with the lockfile committed; review `npm audit` output after installs.
- [ ] **Personal data:** jams need a username at most. Anything more (accounts, analytics) goes
      through `game-analytics-setup` first.
