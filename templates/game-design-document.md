# Game Design Document

> **Project:** [Working title]
> **Version:** [Document version, e.g., 0.1]
> **Last Updated:** [Date]
> **Author:** [Name / role]
> **Status:** [Draft / In Review / Approved]

---

## 1. Overview

[2-3 paragraph summary of the game. What is it? Who is it for? What makes it worth building?]

- **Genre:** [Primary genre / secondary genre]
- **Platform(s):** [PC, Console, Mobile, VR]
- **Target Audience:** [Age range, player profile, comparable game audiences]
- **Engine:** [Godot 4 / Unity / Unreal Engine 5]
- **Team Size:** [Number of contributors]
- **Target Release:** [Quarter and year]

---

## 2. Design Pillars

List 3-5 non-negotiable design principles that guide every decision in this project. Good pillars are falsifiable, constraining, and cross-departmental.

| # | Pillar | One-Sentence Statement |
|---|--------|----------------------|
| 1 | [Name] | [Statement] |
| 2 | [Name] | [Statement] |
| 3 | [Name] | [Statement] |

Reference `@templates/game-pillars.md` for detailed pillar development, including how to test features against pillars and examples from published games.

---

## 3. Player Fantasy

[What does the player *feel* like while playing? Write this from the player's emotional perspective. This section drives every other decision.]

- **Core fantasy in one sentence:** [e.g., "You are a lone inventor who builds impossible machines to save a dying world."]
- **Emotional arc:** [How should the player's feelings change from start to end?]
- **Power progression feel:** [How does mastery manifest? What changes for the player?]

---

## 4. Core Loop

[Describe the moment-to-moment, session, and meta loops.]

- **Micro loop (seconds):** [The core action — move, shoot, place, solve]
- **Core loop (minutes):** [The repeating gameplay cycle — explore, fight, loot, upgrade]
- **Session loop (30-60 min):** [What does one play session accomplish?]
- **Meta loop (days/weeks):** [Long-term progression — unlocks, story, mastery, social]

---

## 5. Detailed Rules

[Formal, unambiguous rules for each game system. Write these as if for a board game rulebook.]

### 5.1 [System Name, e.g., Combat]

- **Rule 1:** [Precise description]
- **Rule 2:** [Precise description]
- **Interactions:** [How this system connects to others]

### 5.2 [System Name, e.g., Movement]

- **Rule 1:** [Precise description]
- **Rule 2:** [Precise description]

[Add subsections for each major system.]

---

## 6. Formulas & Numbers

[Every formula that drives gameplay balance. Use actual math notation.]

| Formula | Expression | Example |
|---------|-----------|---------|
| Damage dealt | `base_damage * weapon_mult * (1 + crit_bonus)` | `10 * 1.5 * 1.0 = 15` |
| XP to next level | `floor(100 * level^1.5)` | Level 5 = 1118 XP |
| Enemy health scaling | `base_hp * (1 + 0.15 * zone_level)` | Zone 3 = 145 HP |
| [Add more] | | |

---

## 7. Edge Cases

[What happens in unusual situations? List them explicitly to prevent design gaps.]

- **What if the player has zero health but a revive item?** [Resolution]
- **What if two players trigger the same event simultaneously?** [Resolution]
- **What if the player skips the tutorial?** [Resolution]
- **What if inventory is full when a quest rewards an item?** [Resolution]
- [Add project-specific edge cases]

---

## 8. Dependencies

[Map system dependencies to reveal coupling and critical paths.]

| System | Depends On | Depended On By |
|--------|-----------|----------------|
| Combat | Input, Animation, Stats | Loot, Progression, AI |
| UI | Stats, Inventory, Events | None (leaf) |
| Progression | Combat, Quests | Unlocks, Difficulty |
| [Add more] | | |

---

## 9. Tuning Knobs

[Every value that designers should be able to change without code modification.]

| Knob | Default | Range | Effect |
|------|---------|-------|--------|
| Player move speed | 6.0 | 3.0 - 12.0 | How fast the character walks |
| Enemy spawn rate | 2.0s | 0.5s - 10.0s | Seconds between enemy spawns |
| XP multiplier | 1.0 | 0.5 - 3.0 | Global XP scaling |
| [Add more] | | | |

---

## 10. Systems Breakdown

[Detailed design for each game system. Add a subsection per system.]

### 10.1 [System: e.g., Inventory]

- **Purpose:** [Why does this system exist?]
- **Player interaction:** [How does the player use it?]
- **Data model:** [What data does it track?]
- **UI requirements:** [What does the player see?]
- **Constraints:** [Limits, caps, rules]

### 10.2 [System: e.g., AI]

[Same structure as above.]

---

## 11. Progression Design

- **Horizontal progression:** [New options without power increase — cosmetics, sidegrades, abilities]
- **Vertical progression:** [Power increase — stats, gear tiers, level-ups]
- **Milestone unlocks:** [Key progression gates and what they unlock]
- **Pacing targets:** [Time-to-first-kill, time-to-first-boss, time-to-credits]

---

## 12. Player Welfare & Accessibility

### Break Reminders & Session Length
- **Session length design:** [Target session length and why]
- **Break reminders:** [How and when the game suggests breaks — e.g., loading screen tips, post-session summaries]
- **Healthy play patterns:** [Design features that encourage stopping — natural save points, session summaries, no penalty for logging off]

### Accessibility Preset Planning

| Category | Features to Consider |
|----------|---------------------|
| **Motor** | Remappable controls, one-handed mode, hold-vs-toggle options, adjustable input timing, auto-aim assist |
| **Visual** | Colorblind modes (protanopia, deuteranopia, tritanopia), high contrast mode, scalable UI, screen reader support |
| **Auditory** | Subtitles with speaker identification, visual cues for audio events, adjustable frequency ranges, mono audio option |
| **Cognitive** | Difficulty presets, tutorial replay, objective reminders, simplified UI mode, adjustable game speed |

### Target Age Rating
- **Target rating:** [ESRB: X / PEGI: X]
- **Content considerations:** [What content might affect rating — violence, language, monetization mechanics]
- **Content warnings:** [List any content that warrants player warnings — flashing lights, intense themes, depictions of harm]

---

## 13. Acceptance Criteria

[How do we know each feature is "done"? Write testable criteria.]

| Feature | Acceptance Criteria |
|---------|-------------------|
| Player movement | Player moves in 8 directions, speed matches tuning knob, no clipping through walls |
| Combat | Damage formula matches section 5, hit feedback plays within 50ms, health bar updates |
| Save/Load | Save completes in <1s, load restores exact state, corruption detection works |
| [Add more] | |

---

## Appendix

### A. Reference Games
- [Game 1] — [What to learn from it]
- [Game 2] — [What to learn from it]

### B. Open Questions
- [ ] [Unresolved design question 1]
- [ ] [Unresolved design question 2]

### C. Change Log
| Date | Author | Change |
|------|--------|--------|
| [Date] | [Name] | Initial draft |
