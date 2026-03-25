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

## 2. Player Fantasy

[What does the player *feel* like while playing? Write this from the player's emotional perspective. This section drives every other decision.]

- **Core fantasy in one sentence:** [e.g., "You are a lone inventor who builds impossible machines to save a dying world."]
- **Emotional arc:** [How should the player's feelings change from start to end?]
- **Power progression feel:** [How does mastery manifest? What changes for the player?]

---

## 3. Core Loop

[Describe the moment-to-moment, session, and meta loops.]

- **Micro loop (seconds):** [The core action — move, shoot, place, solve]
- **Core loop (minutes):** [The repeating gameplay cycle — explore, fight, loot, upgrade]
- **Session loop (30-60 min):** [What does one play session accomplish?]
- **Meta loop (days/weeks):** [Long-term progression — unlocks, story, mastery, social]

---

## 4. Detailed Rules

[Formal, unambiguous rules for each game system. Write these as if for a board game rulebook.]

### 4.1 [System Name, e.g., Combat]

- **Rule 1:** [Precise description]
- **Rule 2:** [Precise description]
- **Interactions:** [How this system connects to others]

### 4.2 [System Name, e.g., Movement]

- **Rule 1:** [Precise description]
- **Rule 2:** [Precise description]

[Add subsections for each major system.]

---

## 5. Formulas & Numbers

[Every formula that drives gameplay balance. Use actual math notation.]

| Formula | Expression | Example |
|---------|-----------|---------|
| Damage dealt | `base_damage * weapon_mult * (1 + crit_bonus)` | `10 * 1.5 * 1.0 = 15` |
| XP to next level | `floor(100 * level^1.5)` | Level 5 = 1118 XP |
| Enemy health scaling | `base_hp * (1 + 0.15 * zone_level)` | Zone 3 = 145 HP |
| [Add more] | | |

---

## 6. Edge Cases

[What happens in unusual situations? List them explicitly to prevent design gaps.]

- **What if the player has zero health but a revive item?** [Resolution]
- **What if two players trigger the same event simultaneously?** [Resolution]
- **What if the player skips the tutorial?** [Resolution]
- **What if inventory is full when a quest rewards an item?** [Resolution]
- [Add project-specific edge cases]

---

## 7. Dependencies

[Map system dependencies to reveal coupling and critical paths.]

| System | Depends On | Depended On By |
|--------|-----------|----------------|
| Combat | Input, Animation, Stats | Loot, Progression, AI |
| UI | Stats, Inventory, Events | None (leaf) |
| Progression | Combat, Quests | Unlocks, Difficulty |
| [Add more] | | |

---

## 8. Tuning Knobs

[Every value that designers should be able to change without code modification.]

| Knob | Default | Range | Effect |
|------|---------|-------|--------|
| Player move speed | 6.0 | 3.0 - 12.0 | How fast the character walks |
| Enemy spawn rate | 2.0s | 0.5s - 10.0s | Seconds between enemy spawns |
| XP multiplier | 1.0 | 0.5 - 3.0 | Global XP scaling |
| [Add more] | | | |

---

## 9. Systems Breakdown

[Detailed design for each game system. Add a subsection per system.]

### 9.1 [System: e.g., Inventory]

- **Purpose:** [Why does this system exist?]
- **Player interaction:** [How does the player use it?]
- **Data model:** [What data does it track?]
- **UI requirements:** [What does the player see?]
- **Constraints:** [Limits, caps, rules]

### 9.2 [System: e.g., AI]

[Same structure as above.]

---

## 10. Progression Design

- **Horizontal progression:** [New options without power increase — cosmetics, sidegrades, abilities]
- **Vertical progression:** [Power increase — stats, gear tiers, level-ups]
- **Milestone unlocks:** [Key progression gates and what they unlock]
- **Pacing targets:** [Time-to-first-kill, time-to-first-boss, time-to-credits]

---

## 11. Acceptance Criteria

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
