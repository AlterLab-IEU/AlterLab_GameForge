# Cut List Playbook

A cut list is an ordered, pre-agreed list of what goes when time runs out, with the trigger for
each tier. Written calmly, it turns a crisis into a scheduled decision. Written in a crisis, it
cuts whatever the loudest person cares least about.

## 1. Hidden-feature checklist (inventory these before cutting anything)

These rarely appear on feature lists and always consume time.

**Table stakes (players and stores expect them)**
- [ ] Settings: audio levels, resolution and window mode, graphics presets, language
- [ ] Input: rebinding, controller support and glyphs, hot-switching, Steam Deck controls
- [ ] Save/load, autosave, save versioning and migration, cloud save if offered
- [ ] Pause, quit, "are you sure" flows, return to title
- [ ] Basic accessibility: subtitles, text size, colorblind-safe cues, hold-to-toggle options
- [ ] Onboarding or tutorial
- [ ] Credits, licenses for fonts, libraries and assets

**Production and release**
- [ ] Crash reporting and logs testers can send
- [ ] Builds per platform (Windows, Linux/Deck, macOS, web, mobile) and their testing
- [ ] Localization hooks (string tables, no baked text), even if only one language ships
- [ ] Achievements, store integration, cloud save setup
- [ ] Store page: capsule art, screenshots, trailer, description, tags
- [ ] Demo build and festival participation
- [ ] AI-use disclosure answers and the asset provenance log (Steam's Content Survey covers
      player-facing AI content including localization and marketing; code assistants are exempt)
- [ ] Rating questionnaires; privacy policy if analytics or accounts exist
- [ ] Community: Discord, devlogs, patch notes

**Web-specific**
- [ ] Load-size budget per portal, mobile performance pass, iOS audio unlock, portal SDK events

## 2. Cut techniques, cheapest damage first

| Technique | What it means | Example |
|---|---|---|
| **Shrink** | Keep the feature, reduce its breadth | 3 biomes instead of 5; 12 enemies instead of 20 |
| **Fake** | Deliver the experience without the system | Scripted "dynamic" weather in two set pieces instead of a weather system |
| **Reuse** | Recombine existing content | Boss 3 reuses boss 2's arena with a new pattern set |
| **Simplify** | Replace a system with a simpler one serving the same pillar | Fixed loadouts instead of a crafting tree |
| **Defer** | Ship later as an update or DLC | Online co-op after 1.0; endless mode in the first patch |
| **Cut** | Remove entirely | Fishing minigame that serves no pillar |

Prefer the top of the table: shrinking and reusing often keep 80% of the player-facing value for
a fraction of the hours. Deferral is a real option only if post-launch time is actually planned.

## 3. Never cut

- Save integrity and crash fixes.
- Basic settings, input remapping and the accessibility basics above.
- Compliance and disclosure work for the platforms you ship on.
- The core loop's feel and readability (cut content around it, not polish on it).
- Buffer. Cutting buffer to keep features is a cut list run backwards.

## 4. Cut list template

```markdown
# Cut List -- [Project] -- [YYYY-MM-DD] (agreed by: [names/roles])

## Tier 1 -- execute when buffer < 20% (or at [date] if behind plan)
| Feature | Technique | Hours saved | What players lose | Pillar affected | Re-add later? |
|---|---|---|---|---|---|
| Weather system | Fake (2 scripted storms) | 22 | Random weather | none | Post-launch maybe |
| Photo mode | Defer | 14 | Photo mode at launch | none | Patch 1.1 |

## Tier 2 -- execute when buffer < 10%
| Biome 5 | Shrink (merge into biome 4) | 40 | One biome | "variety" (minor) | DLC candidate |

## Tier 3 -- date is fixed and buffer < 0%
| Online co-op | Cut | 120 | Co-op | none | Only if 1.0 sells |

## Protected (never on this list)
Save integrity, crash fixes, settings and remapping, subtitles, platform compliance, core-loop feel.

## Triggers are checked
At every sprint review and every scope check. The producer executes the tier; no re-debate unless
the trigger data was wrong.
```

## 5. Communicating cuts

- Announce what the player gains (polish, stability, an earlier date), not only what is gone.
- Do not promise cut features publicly as "coming soon" unless post-launch time is scheduled.
- Record each cut in the GDD's Won't Have section with the reason, so it does not quietly return.
- Thank whoever built cut work; archive it on a branch so the effort is not lost.

## 6. Worked example (abridged)

Situation: solo developer, 15 h/week, 10 weeks to a Next Fest demo. Net capacity after overhead
about 125 h. Calibrated planned work 140 h, plus a 12 h vibe-debt budget (the agent-written
combat code has no tests). Buffer: -27 h (OVER).

Actions:
1. Tier 1: defer photo mode (-14 h), fake the weather (-22 h). Buffer +9 h (7%, RED).
2. Shrink the demo from three levels to two polished ones (-30 h). Buffer +39 h (31%, GREEN).
3. Keep the vibe-debt budget: a smoke test and combat unit tests come first, since a demo crash
   costs more than a missing level.
4. Freeze one week before the festival deadline; record the decisions in
   `production/session-state/active.md`.
