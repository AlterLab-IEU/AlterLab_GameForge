# Estimating Game Work with AI Coding Agents

Read before estimating any agent-assisted (A) or agent-led (AL) task. It separates what is
documented from what is a GameForge rule of thumb, gives verify checklists per task type, and
shows how to replace the rules of thumb with your own numbers.

## What is documented (late 2026)

There is no published, controlled measurement of agent speed-ups for game development. What
exists are well-documented builds and practitioner reports:

| Source | What it shows |
|---|---|
| Simon Willison, *Battle Drones* (blog, 2026-10-20) | A browser RTS built through 321 agent commits; he reviewed "almost none of the code". He had the agent build instruments (a "Radio Probe" debug tool, 1,200+ AI-vs-AI balance matches) and calls them "effectively free". Chrome vs Safari `Math.sin`/`Math.cos` differences desynced replays until replaced with custom functions. He asked the agent to research and critique the design before building. |
| 2026 Vibe Jam Gold winner (Wccftech, 2026-07-13) | About two weeks, roughly 27k lines and 188+ commits with Claude Code. Ran 2-3 sessions on separate subsystems, a fresh session per feature, one long-lived session for context-heavy bugs. Most human time went to brainstorming, planning and playing. The 3D map was built by hand in an editor. Scope: about 5-10 minutes of play. |
| Vibe Jam 2026 judging (levels.io, 2026-06-17) | Judge Tim Soret rated the best entries at "3rd year student" level: agents raise the floor, not the ceiling. |
| R. Fitzpatrick, Vibe Jam write-up (2026-04-12) | Agents "are bad at knowing when the structure underneath needs to change". |
| VL Studio (updated 2026-11-02) | A game smooth on an iPhone stuttered on a mid-range Android phone; keep diffs small and undo regressions rather than patching over them. |
| Waseem et al., arXiv 2512.11922 | Repeated regenerations leave code without "structural rationale". |

Implications for planning:
- Generation is cheap; judgment, play and verification are not.
- Instruments (debug tools, simulators, editors) are the best return on agent time. Plan them early.
- Hand-authored content and feel still need human hours.
- Cross-platform behavior (browsers, devices) must be verified on the targets, not assumed.

## Task-type table

Speed-up labels are qualitative and relative to hand-building by the same person. They are
GameForge rules of thumb, not measurements.

| Task type | Speed-up | Main verification risk | Verify checklist |
|---|---|---|---|
| UI screens, menus, HUD wiring | High | Wrong states, focus/navigation gaps, missing controller support | Navigate every screen with keyboard, gamepad and touch where targeted; check text scaling |
| Save/load, serialization | High | Silent data loss, version migration | Round-trip test with a populated save; load an old save; corrupt-file handling |
| Editor tools, debug overlays, cheats | High | Shipping debug code | Confirm gated out of release builds |
| Test harnesses, balance simulators | High | Tests that pass trivially | Break the code on purpose; the test must go red |
| Greybox prototypes, spikes | High | Mistaking a spike for production code | Spike output is a decision note; code goes to `prototypes/` |
| Gameplay system with spec and checks | Medium | Invented rules, literals, extra features | Acceptance checks green; diff read for out-of-scope additions; knobs in the tuning file; play it |
| Bug fix with reliable repro | Medium | Fixing the symptom; regressions elsewhere | Repro now passes; full check command; related systems played |
| Shader / VFX tweak | Medium | Looks right on one GPU or browser only | Screenshots on each target renderer; performance on the low-end target |
| Refactor covered by tests | Medium | Tests too thin to protect behavior | Coverage of touched paths; play the affected loop |
| Porting between frameworks | Medium | Subtle behavior differences | Side-by-side captures; same seeds, same outcomes |
| Game feel, tuning | Low | Numbers chosen by the agent, not by play | Human playtest with the knob panel; record final values in the GDD |
| Level and content authoring | Low | Generic, samey content | Designer review against pillars; playtest |
| Performance on target hardware | Low | Desktop-only testing | Profile on the weakest target device |
| Multiplayer authority, anti-cheat | Low | Client-trusted state | Server validates state, scores and purchases; no secrets on the client; audit exposed globals |
| Architecture changes | Low | Agent patches around a structure that should change | Human-written design note first; agent implements the plan |
| Platform certification, store submission | Low | Policy details | Checklist from `/gameforge:game-launch` or `/gameforge:game-web-publish` |

## Verify budget rules (rules of thumb)

| Build mode | Verify estimate | Notes |
|---|---|---|
| H (by hand) | normal review | Second-person review on teams |
| A (agent-assisted; human drives) | about 30-50% of build | Human already read most of the code while steering |
| AL (agent-led; human verifies) | at least 100% of build | Human sees the code for the first time at verify |

Raise the AL ratio for: gameplay that needs a play session, anything touching save data,
multiplayer, monetization, or code the verifier does not know well. Lower it only after three
sprints of data show your actual verify time is lower.

What "verify" always includes:
1. Run the check command; read the output, do not trust a summary.
2. Read the diff, or for large AL diffs, a targeted review of the risky files.
3. Play the change in a build.
4. Look for out-of-scope additions and new literals.
5. Confirm generated assets, if any, were logged with provenance.

## Capacity effects that are easy to miss

- **Verify queue.** Each concurrent AL task adds verify work for the same person. A solo developer
  running three sessions has three times the verify queue, not three times the capacity.
- **Context switching.** Reviewing three unrelated diffs in an hour costs more than three
  sequential reviews. Group AL tasks by subsystem.
- **Tool limits.** Usage caps, rate limits and API spend are real capacity constraints for
  agent-led sprints. Note them as a risk if the plan depends on long agent runs.
- **Model or tool updates mid-sprint** change behavior. Pin engine and tool versions for the
  sprint where you can.
- **Refusals.** Since late October 2026 Claude Code declines to build recreations of specific
  existing games. A task framed as "make it like [game]" can stall; write the rule itself.

## Calibration worksheet

Keep these columns per task in the sprint file; the retrospective totals them into
`production/sprints/velocity.md`.

```
| Task | Mode | Build est | Build actual | Verify est | Verify actual | Reopened? | Later defect traced here? |
```

After three sprints compute, per mode:
- build accuracy = build actual / build est
- verify ratio = verify actual / build actual
- reopen rate = reopened tasks / done tasks
- agent-traced defect rate = defects traced to AL or A tasks / AL and A tasks done

Use your verify ratio in place of the rules of thumb. If the reopen rate or the agent-traced
defect rate rises, increase verify estimates or move tasks from AL to A.

## Vibe-debt catalog

| Symptom | Paydown task | Check that proves it is paid |
|---|---|---|
| Two code paths do the same thing | Consolidate to one; delete the other | Tests green; one call site |
| File far larger than its peers | Split by responsibility | Agreed size limit met; tests green |
| Gameplay literals in code | Move to the tuning file; add knob rows to the GDD | Search finds no literal for that value |
| Agent commits merged unreviewed | Review them; open fixes | Review notes linked in the sprint file |
| Flaky tests | Seed RNG; deterministic stepping | 10 consecutive green runs |
| Debug hooks reachable in release | Gate them | Release build has no debug entry points |
| Stale `CLAUDE.md` / project notes | Rewrite: check command first, conventions, out-of-bounds files | New session builds a small task without corrections |
| Dead code from abandoned attempts | Delete | Build and tests green |
| No tests around an agent-written system | Add tests for its acceptance checks | Checks automated and green |
