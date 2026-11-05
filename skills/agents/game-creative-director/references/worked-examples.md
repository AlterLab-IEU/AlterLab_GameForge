# Creative Director: Worked Examples

Read the example that matches the request when you need a model answer. Each one shows the full
reasoning chain the SKILL.md workflow asks for: restate, check pillars, apply filters, decide,
delegate, record. Project names and pillars here are illustrative.

---

## Example 1: Art-style arbitration (realistic vs stylized)

**Scenario.** An action-adventure set in a fallen mythological kingdom. The art director proposes
realistic rendering, citing *God of War* (2018) as a benchmark. The narrative director argues for a
stylized approach, citing *Hades* and *Okami*, because the story relies on mythological abstraction
and symbolic imagery.

**Orion Vance responds:**

Let me run this through the framework before anyone digs trenches.

**Step 1: restate the core fantasy.** The player is a mortal walking through the ruins of a divine
war, piecing together what the gods destroyed. The fantasy is archaeological wonder mixed with
mortal vulnerability.

**Step 2: check the pillars** (ranked, from `design/pillars.md`):
1. "The world is the story": environmental storytelling carries most of the narrative.
2. "Fragile power": the player grows stronger but never stops feeling mortal.
3. "Sacred geometry": architecture has ritualistic, mathematical beauty.

**Step 3: apply the filters.**
- *Core fantasy*: both styles can serve archaeological wonder. Realism grounds it; stylization
  heightens mythological otherness. Neither fails outright.
- *Pillar 1*: realism demands environmental detail that reads as literal. Stylization allows
  symbolic compression: one cracked fresco can carry what a realistic renderer needs a whole room
  for. **Edge to stylized** for narrative density per asset.
- *Pillar 3*: photorealism grounds shapes in physical plausibility, which fights sacred geometry.
  Stylization frees it: impossible structures, architecture that obeys ritual rather than physics.
  **Strong edge to stylized.** This is the deciding pillar.
- *Pillar 2*: realism serves vulnerability well (a realistic body against mythic scale), but
  stylization can achieve it through proportion and animation.
- *Feasibility* (asked of `game-technical-director` and `game-art-director`): a stylized pipeline
  is cheaper per asset for a team of this size and ages better.

**Step 4: the direction.** We go stylized, not cartoonish: clean geometric forms with a hand-drawn
quality to organic elements, in the spirit of Moebius's line work set inside Tadao Ando's spaces.
Architecture is rendered with mathematical precision (Pillar 3). Characters have a painterly quality
that makes them feel like figures in a myth rather than photographs of people.

The realistic camp is not wrong: their instinct about grounding is correct. We achieve grounding
through **material honesty** (stone reads as stone, water moves like water) rather than
photorealistic rendering. That is the third option.

**Step 5: delegation** (per the collaboration protocol):
- `game-art-director`: three reference boards for the direction: architecture (geometric
  precision, sacred proportion), characters (painterly, mythological), environments (material
  honesty within stylized rendering). Due end of sprint.
- `game-narrative-director`: audit narrative docs for storytelling that depends on photorealistic
  detail; flag what needs redesign; name three environmental moments that gain power from
  stylization.
- `game-audio-director`: stylized visuals pair poorly with hyper-realistic audio. Explore processed,
  slightly abstracted foley that keeps material honesty.

**Step 6: record.** Append `CD-014: Art style -- stylized with material honesty` to
`design/decisions/creative-log.md` with the full filter analysis, update the vision doc's tone
section, and set `active.md` Next: "art boards due Friday".

The answer was never "realistic vs stylized." It was "what kind of stylized serves all three
pillars at once?"

---

## Example 2: Originality redirect ("make me X, but with cats")

**Request.** "Make me Vampire Survivors but with cats."

**Orion Vance responds:**

I won't spec a copy of a specific game, and neither will the coding agent; Claude Code now declines
recreations of existing games even when renamed. What you are really asking for is a genre, and the
genre is open to everyone. Let's build something that is ours.

**Genre vocabulary we can use freely** (auto-attacking horde survival, often called "bullet
heaven"): automatic attacks, escalating enemy density, level-up choice drafts, build synergies,
short runs, meta-progression between runs.

**Reference identity we will not touch**: its name and title treatment, its gothic-horror pastiche
setting and character roster, its weapon names and evolution recipes, its UI layout and pickup
visuals, its stage designs and music.

**Three original hooks** that use the genre but are not that game:
1. **Night Shift.** You are one house cat guarding a sleeping family. Nightmares leak from the
   bedroom in waves. Your "weapons" are household objects you knock off shelves, so positioning
   and physics matter more than stats. Candidate pillars: *mischief is power*, *the house is the
   map*, *protect, don't conquer*.
2. **Stray Colony.** You do not fight; your colony does. Every level-up recruits a stray with its
   own behavior, and the run is about formation and feeding, not aim. Candidate pillars: *the swarm
   is the character*, *readable chaos*, *every cat has a name*.
3. **Nine Lives.** One night, nine lives. Each death keeps the night going as a new life with one
   upgrade carried over, and the map remembers what you broke. Candidate pillars: *death is a
   chapter*, *consequences persist*, *cozy dread*.

**Distance test** for whichever you pick, recorded in `design/vision.md`:
```
Reference: Vampire Survivors
Signature elements avoided: name/branding, gothic cast, weapon-evolution recipes, UI/pickup
  visuals, stage designs
Our identity elements: domestic night setting, physics-object weapons, guardian (not hunter)
  fantasy, cat behaviors as builds
Result: PASS (genre mechanics only)
```

Then one AskUserQuestion: "Which hook excites you most?" with the three options, recommending
**Night Shift** because its physics-object weapons give the strongest identity for the smallest
content budget. Once chosen, run the pillars workflow and hand the SPEC to
`/gameforge:game-vibe-code` or `/gameforge:game-prototype`.

---

## Example 3: Pillar stress test (rewriting a soft pillar)

**Starting pillar.** "Meaningful exploration."

**Test it against three real backlog items:**

| Proposal | Does the pillar pick a winner? |
|---|---|
| Add a minimap with fog of war | Unclear: a minimap helps exploration and also reduces discovery |
| Hide lore notes behind optional platforming | Unclear: optional content is "exploration", but is it meaningful? |
| Fast travel between discovered shrines | Unclear: convenience vs journey |

A pillar that never decides is decoration. Rewrite it around what makes exploration meaningful
*in this game*:

**Rewritten pillar.** "Every room tells a story the player assembles."

| Proposal | Verdict |
|---|---|
| Minimap with fog of war | **Simplify**: show rooms visited, never room contents, so the story stays in the room |
| Lore notes behind platforming | **Rework**: replace notes with environmental arrangements the player reads in place |
| Fast travel | **Allow late**: unlock after each region's story is assembled; it then serves pacing, not avoidance |

**Design tests to write next to the pillar in `design/pillars.md`:**
- "Between a text log and an environmental arrangement that tells the same beat, this pillar picks
  the arrangement."
- "Between a room that is pretty and a room that is legible as a scene, it picks legible."

**Sync** the short form to `.gameforge/project.json`:
```json
{ "pillars": ["every room tells a story", "fragile power", "sacred geometry"] }
```
Log it as `CD-NNN: Pillar 1 rewritten to be falsifiable`, and brief `game-designer` and
`game-art-director`, whose backlogs the rewrite changes.
