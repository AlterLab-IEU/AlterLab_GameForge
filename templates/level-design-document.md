# Level Design Document

> **Level Name:** [Name or codename]
> **Level Number/ID:** [Sequence in progression, e.g., "World 2, Stage 3" or "L_ForestRuins_02"]
> **Version:** [Document version]
> **Last Updated:** [Date]
> **Level Designer:** [Name]
> **Status:** [Blockout / In Production / Polish / Final]

---

## 1. Purpose in Progression

[Why does this level exist? What does it teach, test, or reward?]

- **Introduces:** [New mechanic, enemy type, or concept introduced in this level]
- **Tests:** [Previously learned skills being tested in a new context]
- **Narrative function:** [What story beat happens here? What does the player learn about the world?]
- **Difficulty position:** [Where does this sit in the overall difficulty curve? e.g., "Difficulty 4/10, first real challenge after tutorial"]

### Progression Context
- **Previous level:** [What the player just completed and what skills they acquired]
- **Next level:** [What comes after and what this level needs to prepare the player for]
- **Estimated play time:** [X-Y minutes for first playthrough]

---

## 2. Layout Overview

### High-Level Map

[Describe or sketch the level layout. Include cardinal directions, major landmarks, and flow direction.]

```
[ASCII or text description of the level layout]

  START ──► Arena 1 ──► Corridor ──► Arena 2 ──┐
                                                 ▼
  EXIT ◄── Boss Room ◄── Secret Path ◄── Hub ◄──┘
                                          │
                                          └──► Optional: Treasure Room
```

### Zone Breakdown

| Zone | Purpose | Size | Enemies | Items |
|------|---------|------|---------|-------|
| [Entry/Start] | [Establish mood, orient player] | [Small] | [None or tutorial] | [None or breadcrumb] |
| [Arena 1] | [First combat encounter] | [Medium] | [X enemies of type Y] | [Health pickup after] |
| [Corridor] | [Breathing room, environmental storytelling] | [Linear, narrow] | [None or minimal] | [Lore item] |
| [Arena 2] | [Escalated challenge, combines mechanics] | [Large] | [Mixed enemy types] | [Equipment drop] |
| [Hub] | [Decision point, exploration reward] | [Medium, open] | [None] | [Map, shop, save] |
| [Boss Room] | [Level climax] | [Large, circular/arena] | [Boss + adds] | [Boss reward] |

### Critical Path vs. Optional Content
- **Critical path:** [Entry > Arena 1 > Corridor > Arena 2 > Hub > Boss Room > Exit]
- **Optional:** [Secret Path to Treasure Room, hidden collectible in Corridor, Arena 2 skip for speedrunners]
- **Critical path time:** [X minutes]
- **100% completion time:** [Y minutes]

---

## 3. Key Encounters

### Encounter 1: [Name]

- **Location:** [Zone]
- **Type:** [Combat / Puzzle / Platforming / Stealth / Dialogue]
- **Description:** [What happens? What is the player's challenge?]
- **Win condition:** [How does the player succeed?]
- **Fail state:** [What happens on failure? Respawn, retry, consequence?]
- **Difficulty tuning:** [What knobs control difficulty for this encounter?]
- **New mechanic introduction:** [Does this encounter teach something? If yes, how?]

### Encounter 2: [Name]

[Same structure as above.]

### Boss Encounter: [Name]

- **Location:** [Boss Room]
- **Phases:** [Number of phases and phase transition triggers]
- **Phase 1:** [Boss behavior, attacks, arena hazards]
- **Phase 2:** [How it escalates — new attacks, arena changes]
- **Phase 3 (if applicable):** [Final phase, desperation mechanics]
- **Health pool:** [Total HP, per-phase breakdown]
- **Win condition:** [Deplete HP / Complete objective / Survive timer]
- **Reward:** [What the player earns for winning]

---

## 4. Pacing Graph

[Describe the intensity curve of the level. Ideal pacing alternates between high-intensity moments and breathers.]

```
Intensity
  High │        ■■■           ■■■■■■■
       │      ■■   ■■       ■■       ■■■■■■■
  Med  │    ■■       ■■   ■■
       │  ■■           ■■■■
  Low  │■■
       └──────────────────────────────────────► Time
        Entry   Arena1  Corr  Arena2  Hub  Boss
```

- **Opening:** [Low — establish atmosphere, let the player explore]
- **First peak:** [Medium — Arena 1, first real challenge]
- **Valley:** [Low — Corridor, recovery and storytelling]
- **Second peak:** [Medium-High — Arena 2, escalated challenge]
- **Rest:** [Low — Hub, player prepares for boss]
- **Climax:** [High — Boss encounter, sustained tension]
- **Resolution:** [Drop after boss — reward, transition to next level]

---

## 5. Environmental Storytelling Notes

[What story does the environment tell without dialogue or text?]

- **[Zone/Location]:** [What the player sees and what it implies. e.g., "Abandoned campfire with scattered supplies — someone left in a hurry"]
- **[Zone/Location]:** [Environmental detail. e.g., "Claw marks on walls increase in density approaching the boss room"]
- **[Zone/Location]:** [World-building detail. e.g., "Murals depicting the kingdom's history, progressively damaged deeper in"]

### Key Visual Vignettes
1. [Moment of discovery — e.g., "Player crests a hill and sees the ruins stretching to the horizon for the first time"]
2. [Moment of dread — e.g., "A locked door with something pounding on the other side"]
3. [Moment of reward — e.g., "Sunlight breaking through the canopy into a hidden garden with a chest"]

---

## 6. Collectibles & Secrets

| Item | Location | Hint | Reward |
|------|----------|------|--------|
| [Collectible 1] | [Zone, specific location description] | [How the player might find it — audio cue, visual breadcrumb, puzzle] | [What it gives: lore, currency, achievement] |
| [Collectible 2] | [Zone, specific location description] | [Discovery hint] | [Reward] |
| [Secret area] | [Zone, hidden entrance description] | [Environmental cue — e.g., "Cracked wall near waterfall"] | [Shortcut, bonus loot, lore] |

### Collectible Coverage
- **Total collectibles:** [X items]
- **On critical path:** [Y items (players will naturally find these)]
- **Hidden/secret:** [Z items (require exploration or puzzle-solving)]

---

## 7. Performance Considerations

- **Target framerate:** [30 / 60 fps on target hardware]
- **View distance:** [Maximum draw distance in this level]
- **LOD requirements:** [Which assets need LOD chains?]
- **Occlusion strategy:** [How do we hide what the camera cannot see? Walls, fog, portals]
- **Streaming:** [Does this level need streaming? Where are the streaming boundaries?]
- **Worst-case scenario:** [What is the most expensive frame? Where should profiling focus?]
- **Particle/VFX budget:** [Maximum concurrent effects in combat arenas]
- **AI budget:** [Maximum concurrent AI agents per encounter]

---

## 8. Art Direction Notes

- **Biome/theme:** [e.g., "Overgrown forest ruins, late autumn palette"]
- **Key colors:** [Dominant and accent colors for this level]
- **Lighting mood:** [Time of day, light source, color temperature]
- **Material focus:** [Which materials are prominent — moss-covered stone, rusted iron, etc.]
- **Hero assets:** [Unique or focal-point assets needed for this level — statues, machines, landmarks]
- **Reusable assets:** [Which assets from the shared library are used?]
- **Reference images:** [Link to mood board or reference folder]

---

## 9. Audio Direction Notes

- **Ambient soundscape:** [Dominant sounds — wind, water, creatures, machinery]
- **Music track:** [Which music piece plays? Adaptive layers needed?]
- **Key audio moments:** [Specific sounds tied to scripted events or discoveries]
- **Silence moments:** [Where is silence used intentionally for tension or impact?]
- **Reverb environment:** [Outdoor, cave, cathedral, small room — varies by zone]

---

## 10. Difficulty Tuning

| Parameter | Easy | Normal | Hard |
|-----------|------|--------|------|
| Enemy count (Arena 1) | [X] | [Y] | [Z] |
| Enemy count (Arena 2) | [X] | [Y] | [Z] |
| Boss health | [X] | [Y] | [Z] |
| Boss damage | [X] | [Y] | [Z] |
| Health pickups available | [X] | [Y] | [Z] |
| Checkpoint frequency | [Every encounter] | [Every other encounter] | [Start of level only] |
| Timer (if applicable) | [Generous] | [Standard] | [Tight] |

### Assist Features
- **Invulnerability toggle:** [Available / Not available]
- **Hint system:** [How does the game help stuck players in this level?]
- **Skip option:** [Can the player skip this content? Under what conditions?]

---

## 11. Open Questions

- [ ] [Unresolved design question about this level]
- [ ] [Unresolved design question about this level]
- [ ] [Dependency on another system or level that is not yet complete]

---

## Change Log

| Date | Author | Change |
|------|--------|--------|
| [Date] | [Name] | Initial blockout document |
