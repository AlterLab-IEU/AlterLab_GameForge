# GDD Section Guide: Question Bank and Examples

Read the entry for a step before running it. Each entry has the full question bank, extra red
flags, and a good and a bad example. The running example is an original concept, *Ashenmere*: a
roguelike deckbuilder in which you play a public defender in a corrupt fantasy court.

---

## Step 1: Pitch, audience, pillars

**Questions**
1. "If you had one sentence to explain the game to a stranger, what would you say?"
2. "Name three games your target player already loves. What do they have in common?"
3. "Name three things this game will absolutely not be."
4. "Who is the player? Age range, what they play now, platform, typical session length."
5. "If the game succeeds, what do players write in reviews?"

**Extra red flags**
- Pillars that never say no to anything.
- Two pillars that always agree (you have one pillar).
- A pillar that only the art team or only the programmers can apply.

**Good**
> **Pitch:** A roguelike deckbuilder where you defend clients in a corrupt fantasy court. Build
> your case on investigation runs, then argue it in generated trials where your evidence deck is
> your arsenal. Lose the case, lose the client, permanently.
>
> **Pillars:**
> 1. **Consequence** -- Every decision sticks. Lost clients are gone; failed evidence is destroyed.
>    *Excludes:* undo, respec, save-scumming. *Test:* can the player reverse this choice for free? If yes, it violates the pillar.
> 2. **Discovery** -- The case unfolds through investigation, not exposition.
>    *Excludes:* narrator summaries of what happened. *Test:* does the player learn this by doing?
> 3. **Rhetoric** -- Words are weapons. Arguments have damage types, objections are interrupts,
>    the judge's patience is a shared health bar. *Excludes:* physical combat.
>
> **Audience:** Strategy players aged 22-40 who like deckbuilders and courtroom mysteries; 30-60
> minute sessions on PC and handheld PC.

**Bad**
> A really cool open-world RPG with crafting, base building and multiplayer. Pillars: fun
> gameplay, great graphics, lots of content. Audience: everyone.

---

## Step 2: Player fantasy

**Questions**
1. "Finish this sentence: while playing, I am ____."
2. "How should the player feel in hour one, and how differently in the final hour?"
3. "What would an onlooker see that tells them the player has mastered the game?"
4. "Which moment would you put in the trailer?"

**Good**
> **Fantasy:** You are the last honest lawyer in a city that profits from injustice.
> **Arc:** overwhelmed and outmatched, then cunning, then feared by the prosecution.
> **Mastery signal:** the player wins trials by turning the prosecution's own evidence against it.

**Bad**
> You fight enemies and collect cards.

---

## Step 3: Core loop

**Questions**
1. "What is the first interactive action, not a cutscene or menu?"
2. "What is the repeating cycle, and what restarts it?"
3. "After 30 minutes, what has the player accomplished? Why play 30 more?"
4. "Is the 30-second loop fun with zero progression, unlocks or story? If not, why not?"
5. "Draw the loop: what feeds into what?"

**Extra red flags**
- A meta loop that is the only reason to keep playing (the core loop is not carrying weight).
- A session loop longer than the target session length.

**Good**
> **Micro (30 s):** Examine a piece of evidence; keep, discard or investigate further. Each card
> has reliability and relevance; reliable-but-irrelevant is safe and useless, relevant-but-shaky
> can backfire in court.
> **Core (5 min):** Search a scene (3-6 cards), interview a witness, return to the office and
> reorder the case deck.
> **Session (30 min):** One investigation run (3-5 scenes), then the trial. Win or lose;
> consequences apply; the next case unlocks or the client is gone.
> **Loop chain:** examine -> judge reliability -> build deck -> argue -> verdict -> consequence -> next case.
> **Playtest check (T1, Manual):** in a greybox build, 4 of 5 testers voluntarily start a second trial.

**Bad**
> The player fights enemies, collects loot, levels up and does quests.

---

## Step 4: Systems and rules

**Questions**
1. "List every verb the player can perform."
2. "For each major mechanic, what should the player feel? That maps to an MDA aesthetic."
3. "If you removed mechanic X, what would break?"
4. "Which mechanics do you want because they are cool but cannot yet justify?"
5. "What is the simplest version of each system that is still fun?"

**MDA reference**

| Aesthetic | Meaning | Example mechanic |
|---|---|---|
| Sensation | Sensory pleasure | Hit-stop and screen shake on a decisive objection |
| Fantasy | Inhabiting a role | Lawyer-specific techniques and wardrobe |
| Narrative | Story unfolding | Witness testimony branching |
| Challenge | Overcoming obstacles | Judge patience as a shared health bar |
| Fellowship | Social connection | Co-op defence, shared world events |
| Discovery | Exploring the unknown | Hidden evidence, contradictory testimony |
| Expression | Self-expression | Deck archetypes, courtroom style |
| Submission | Relaxation | Office decoration between cases |

**Good**
> **SYS-001 Evidence Examination (T1)**
> - *Rules:* each card has Reliability 1-5 and Relevance 1-5. Keeping a card costs one deck slot
>   (max DECK_SIZE). Investigating further costs one scene action and reveals the true Reliability.
> - *Aesthetic:* Discovery, Challenge. *Pillars:* Discovery, Consequence.
> - *Inputs:* scene search. *Outputs:* case deck. *Depends on:* SYS-000 Scene Interaction.
>
> **SYS-003 Witness Interrogation (T1)**
> - *Rules:* choose an approach (sympathetic, aggressive, logical). Each witness has an
>   approach affinity; matching it reveals one hidden fact; mismatching lowers Trust by TRUST_PENALTY.
>   Witnesses remember Trust across cases.
> - *Aesthetic:* Narrative, Challenge, Discovery. *Pillars:* all three.

**Bad**
> Combat system. Inventory. Crafting. Leveling up.

---

## Step 5: Formulas and tuning knobs

**Questions**
1. "Read me every number in the rules. Which ones will you want to change during playtests?"
2. "What range is sensible for each, and what happens at each end?"
3. "Which formula decides success or failure in the core loop? Walk me through one example."
4. "Is any number derived from another? Then only one of them is a knob."

**Good**
> | Formula | Expression | Example |
> |---|---|---|
> | Argument damage | `card.relevance * ARG_BASE * (1 + style_bonus)` | `4 * 3 * 1.25 = 15` |
> | Backfire chance | `max(0, (3 - card.reliability) * BACKFIRE_STEP)` | reliability 1 -> 40% |
>
> | Knob | Default | Range | Unit | Effect when raised |
> |---|---|---|---|---|
> | ARG_BASE | 3 | 1-6 | patience pts | Trials end faster |
> | BACKFIRE_STEP | 0.20 | 0.05-0.35 | probability | Shaky evidence riskier |
> | DECK_SIZE | 12 | 8-20 | cards | More forgiving deck building |

**Bad**
> Damage is based on how good the card is.

---

## Step 6: Edge cases

**Questions**
1. "What happens at zero and at the maximum of every resource?"
2. "What if two events resolve on the same frame or turn?"
3. "What if the player skips the tutorial or does things out of order?"
4. "What if the player quits mid-action, mid-trial or mid-save?"
5. "What if a resource the design assumes is renewable runs out?"

**Good**
> - *Deck has zero cards at trial start:* the trial opens with a forced "Request recess" card; if
>   used, the client is lost. (Consequence pillar; test: start a trial with an empty deck.)
> - *Judge patience and prosecution credibility reach zero on the same turn:* the defence wins ties.
> - *Quit during a trial:* the trial resumes at the start of the current turn; no reroll.

**Bad**
> Edge cases will be handled during development.

---

## Step 7: Progression and economy

**Questions**
1. "After session one, what does the player have that they did not have at the start?"
2. "Is growth horizontal (new options), vertical (bigger numbers), or both?"
3. "Pacing: time to first meaningful reward, first major milestone, credits?"
4. "List every resource. For each, where does it come from and where does it go?"
5. "Is there real-money monetization? What can it never sell?"

**Good**
> **Between runs (T1):** each case unlocks one investigation tool. Won cases add the client's
> testimony as a reusable card; lost clients are removed from the roster.
> **Long arc (T2):** a corruption meter raises case difficulty; the ending adapts to who was saved.
> **Pacing:** first case 20 min; first lost client 45-60 min; corruption reveal 2 h; ending 8-12 h.
> **Credibility (T1):** trial-scoped. Source: won arguments. Sink: objections and failed evidence.
> **Reputation (T2):** persistent. Source: won cases. Sink: expert witnesses, restricted archives.
> **Monetization:** none; premium game.

**Bad**
> You level up and get stronger. There are coins and gems you can buy stuff with.

---

## Step 8: Narrative, art and audio direction

**Questions**
1. "Where and when is the game set? Describe it in one sentence each for sight and sound."
2. "Is the story linear, branching, emergent, or absent? How is it delivered?"
3. "Show me three reference images or games. What do they have in common?"
4. "Can a player read game state from visuals alone? From audio alone?"
5. "Where are the deliberate silences?"

**Good**
> **Setting (T1):** Ashenmere, an overcast fantasy-noir city where noble houses use trials as
> political weapons. Absurd bureaucracy over real tragedy.
> **Delivery (T1):** dialogue during investigation and arguments in court; no cutscenes.
> **Art (T1):** hand-painted 2D, deep shadows with pools of warm light. Accent colours carry
> meaning and are always paired with an icon: amber evidence, crimson danger, teal truth.
> **Audio (T1/T2):** solo piano during investigation, ensemble layers in as trial tension rises
> (T2 adaptive); two seconds of silence before the court reacts to decisive evidence (T1).

**Bad**
> Fantasy world with magic. Good graphics, maybe pixel art. Music and sound effects.

---

## Step 9: Player welfare and accessibility

**Questions**
1. "What is the target session length, and where are the natural stopping points?"
2. "Which accessibility options are T1? Which input actions are hold-only?"
3. "Does the game have a purchase flow, player chat, or a console release?"
4. "What is the target age rating, and what content drives it?"

**Good**
> **Session:** 30-45 min; every case end is a save point with a session summary.
> **T1 options:** full remapping; toggle for every hold; text size 100-200%; colour never the only
> carrier of meaning; subtitles with speaker names; trial timer can be disabled.
> **Checks:** AC-ACC-1 every action rebindable (Auto: input map test); AC-ACC-2 all evidence
> categories distinguishable in greyscale screenshots (Manual review).
> **Rating target:** PEGI 12 / ESRB T (mild violence references, crime themes).

**Bad**
> We'll add accessibility after launch if people ask.

---

## Step 10: Technical approach

**Questions**
1. "What engine or web stack, and what does it give you that others do not?"
2. "Which platforms at launch? Which are stretch goals?"
3. "Performance targets: frame rate on which hardware, load time, memory, download size?"
4. "Networking? If yes, what authority model?"
5. "What is the one technical risk that could force a rewrite?"
6. "What single command proves the build works?"

**Good**
> **Engine (T1):** Godot 4.7 (current stable as of November 2026), GDScript. Chosen for 2D tooling,
> plain-text scenes an agent can edit, and no licence cost.
> **Platforms:** Windows/Linux on Steam (T1); Steam Deck verified (T2); a web demo (T2); no mobile.
> **Budgets:** 60 fps on integrated graphics (Intel UHD 620 class); scene loads under 2 s; 2 GB RAM.
> **Risk:** generated trials producing incoherent evidence chains. Mitigation: hand-authored cases
> are T1; generation is T2 behind a validator that rejects any case without a solvable chain.
> **Check command:** `godot --headless -s addons/gut/gut_cmdln.gd -gexit` (GUT test run).

**Bad**
> Unity. PC and maybe console.

---

## Step 11: AI use and originality

Use `ai-use-policy.md` (next to this file) for the section template and facts.

**Questions**
1. "Which content types will use generative AI: code, placeholder art, shipped art, music, SFX,
   voice, localisation, store page and marketing?"
2. "Will anything be generated while the game runs?"
3. "Which storefronts and regions are you targeting?"
4. "What makes this design yours rather than a variation of one specific game?"
5. "Who reviews AI output before it ships, and where is the provenance log?"

**Good**
> Code: agent-assisted, reviewed by a human (no Steam disclosure required for code assistants).
> Placeholder art: generated, replaced before beta. Shipped art: hand-painted, no AI. Music:
> commissioned. Voice: none. Localisation: machine draft plus human review, disclosed on Steam.
> Runtime AI: none. Originality: courtroom-as-combat with evidence decks; no assets, names or
> rules taken from existing courtroom games.

**Bad**
> We'll use AI for everything and figure out the rules later.

---

## Step 12: Acceptance criteria, tiers and milestones

**Questions**
1. "How many people, in which roles, at what availability?"
2. "Is the release date hard or aspirational?"
3. "What must the vertical slice prove?"
4. "What are the top three risks, and what do you do if each happens?"
5. "If you had to ship in half the time, what would you cut?"

**Good**
> **Team:** 1 developer full-time (agent-assisted), 1 artist part-time, 1 composer on contract.
> **M1 Prototype (months 1-2):** one hand-authored case; examination, interrogation and trial
> systems at greybox. Done when: AC-001-*, AC-003-*, AC-005-* pass and 4/5 testers start a second trial.
> **M2 Vertical slice (months 3-5):** three cases with final art, save/load, progression between cases.
> **M3 Content complete (months 6-9):** all T1 and T2 content, full soundtrack, accessibility options.
> **M4 Launch (months 10-11):** bug fixing, performance, store page, platform submission.
>
> | Risk | Likelihood | Impact | Mitigation |
> |---|---|---|---|
> | Trial generation incoherent | High | Medium | Hand-authored cases are T1 |
> | Art bottleneck | Medium | High | Fewer T1 cases; reusable scene kits |
> | Feature creep | High | High | Weekly tier review; every addition needs a pillar and a tier |

**Bad**
> We'll work on it until it's done. Probably about a year.
