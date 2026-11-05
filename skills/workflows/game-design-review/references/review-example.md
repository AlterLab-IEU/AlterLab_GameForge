# Worked Example: Build-Readiness Review

A filled-in report for an original concept, *Tidebreak*: a 2D browser roguelite on Phaser 4,
built by a solo developer with Claude Code, with an LLM-driven shopkeeper. Use it to calibrate
severity and tone, not as text to copy.

```markdown
# Design Review: Tidebreak GDD v0.3
**Reviewed:** design/gdd.md (§1-§17) | **Mode:** Build-readiness gate, §4-§6 and §16
**Date:** 2026-11-05 | **Phase:** prototype | **Reviewer:** GameForge design review

## Verdict
**Not ready** -- the shopkeeper NPC generates dialogue at runtime with no guardrails, disclosure
or report path (CRIT-01), and the harpoon system has no automatable checks (CRIT-02).
Biggest strength: a tight, falsifiable pillar set with clear exclusions.
Most critical issue: CRIT-01.

## Scorecard
| # | Dimension | Rating | Findings |
|---|---|---|---|
| 1 | Completeness | Concern | MIN-01 |
| 2 | Pillar alignment | OK | -- |
| 5 | Internal consistency | Concern | MAJ-01 |
| 10 | Testability | Fail | CRIT-02, MAJ-02 |
| 11 | Originality & IP | OK | SUG-01 |
| 12 | AI content & disclosure | Fail | CRIT-01, MAJ-03 |
| 13 | Accessibility hooks | Concern | MAJ-04 |

## Findings
### Critical
- **[CRIT-01] Runtime AI shopkeeper has no guardrails or disclosure** (§16.2, dimension 12):
  "Marlo improvises banter and haggles using a hosted LLM." No filtering, no player-facing
  notice, no report button, no cost estimate.
  **Why it matters:** Steam's live-generated category (rules of 2026-01-16) requires describing
  guardrails; EU AI Act Art. 50(1), applying since 2026-08-02, requires telling players they are
  interacting with an AI unless obvious; shipped AI chat NPCs have been exploited by players.
  **Recommendation:** either make Marlo's lines pre-written with LLM-selected variants, or tier
  guardrails, an in-fiction disclosure line, a report button and a per-session token cap as T1
  with the feature. Add a prompt-injection test set to §13.  **Owner:** designer + tech.
- **[CRIT-02] Harpoon (SYS-002) has only Manual checks** (§13, dimension 10): "Harpoon feels
  weighty and satisfying." It is T1 and will be agent-built.
  **Recommendation:** add Auto checks, e.g. "Given a target within HARPOON_RANGE, when fired,
  then the target is pulled HARPOON_PULL units within HARPOON_TIME +/- 1 frame", observed through
  `render_game_to_text()` after `advanceTime(500)`. Keep "weighty" as a playtest check with a
  threshold.  **Owner:** designer.

### Major
- **[MAJ-01] Run length disagrees** (§4 vs §11): §4 says "8-minute runs"; §11 pacing targets a
  first boss at minute 12.  **Recommendation:** pick one; update both sections and the knob
  BOSS_SPAWN_TIME.
- **[MAJ-02] Numbers without knobs** (§5.3): drown timer "about 20 seconds", oxygen refill "a
  bit". **Recommendation:** OXYGEN_MAX, OXYGEN_REFILL_RATE with ranges in §9.
- **[MAJ-03] Placeholder art policy undecided** (§16.1): "AI sprites for now, maybe final."
  **Recommendation:** decide per category, name a replacement milestone, log every generated
  sprite in the provenance log (`/gameforge:game-ai-assets`). itch.io requires generative-AI
  disclosure; Steam counts shipped AI art as pre-generated content.
- **[MAJ-04] Hold-only input** (§5.2): charging the harpoon requires holding a button for up to
  1.5 s, with no toggle or adjustable timing. **Recommendation:** add a toggle mode and a
  HARPOON_CHARGE_TIME range; add an acceptance check that charge works in toggle mode.

### Minor
- **[MIN-01] No §7 entry for quitting mid-run** (dimension 1/7). Specify resume behavior.

### Suggestions
- **[SUG-01]** The pitch leans on "Like [famous roguelite] underwater" in §1. The design already
  stands on its own (oxygen-as-currency, harpoon traversal); lead with that.

## Strengths
- Pillars ("Every breath counts", "Read the current", "Short and brutal") each exclude something
  and are applied consistently in §5 and §14.
- Knobs table in §9 is complete for movement and has ranges.
- Out-of-scope lists on every build brief.

## Next Actions
1. Decide Marlo's architecture (pre-written vs live) and update §16.2 -- designer -- before any build.
2. Add Auto checks for SYS-002 and SYS-004 -- designer -- this week.
3. Resolve run length (MAJ-01) and add oxygen knobs (MAJ-02) -- designer -- this week.
**Suggested skills:** /gameforge:game-gdd-author (§13, §16), /gameforge:game-accessibility-specialist (input review)
```

## Calibration notes

- CRIT-01 is Critical because shipping it as written creates platform and regulatory exposure,
  not because runtime AI is undesirable. A designed, guarded, disclosed version would be fine.
- CRIT-02 is Critical only because the system is T1 and agent-built. The same finding on a
  hand-built T3 system would be Major.
- SUG-01 is a Suggestion, not an IP finding: comparisons in a pitch are normal; the mechanics are
  original.
- The verdict follows the rules: any Critical means Not ready.
