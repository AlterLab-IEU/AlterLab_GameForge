---
name: narrative-brainstorm-variant
genre: narrative
version: "2.0"
description: Genre-tailored ideation prompts and constraint generators for narrative game brainstorming
---

# Narrative Brainstorm Variant

Extension prompts for `game-brainstorm` when the target genre is narrative-driven. These prompts replace generic ideation with narrative-specific constraints that produce tighter, more emotionally grounded concepts.

---

## 1. Core Narrative Prompts

These prompts define the emotional and thematic foundation of your narrative game. Answer all four before moving to systems design.

### The Central Question
> **What is the central question the player explores through gameplay?**
>
> Every great narrative game orbits a question:
> - Disco Elysium: "Who am I, and can I be someone better?"
> - Outer Wilds: "What happened to the Nomai, and what does it mean for us?"
> - Undertale: "Is violence the only way to progress in a game?"
> - Pentiment: "Can we ever truly know the truth about the past?"
> - Hades: "What does it mean to defy your family to find yourself?"
>
> Your question should be answerable in multiple ways. If there's one right answer, you're writing a lecture, not a game.

### The Emotional Arc
> **What is the emotional journey from the first minute to the last?**
>
> Map the intended emotional arc:
> ```
> Emotion
>   |
>   |
>   |
>   |
>   +────────────────────────→ Time
>     Opening    Midpoint    Climax    Resolution
> ```
>
> Label the emotions at each point. What does the player feel at the start? (Curiosity? Dread? Wonder?) What do they feel at the climax? (Grief? Triumph? Revelation?) What lingers after the credits?
>
> **Reference**: Outer Wilds goes Curiosity -> Wonder -> Dread -> Acceptance -> Peace. That arc is deliberate and drives every design decision.

### The Agency Question
> **How does player agency serve the story?**
>
> Agency is not free. Every choice you give the player is a branch you must author, test, and maintain. What does agency buy your story?
>
> - **Identity**: The player defines who the protagonist is (Disco Elysium)
> - **Moral weight**: The player bears responsibility for outcomes (The Walking Dead)
> - **Perspective**: The player chooses what to pay attention to (Outer Wilds)
> - **Complicity**: The player is forced to participate in the story's themes (Undertale, Spec Ops: The Line)
>
> If you can't articulate what agency adds, consider whether your story is better as a linear experience.

### The Unsayable
> **What can't be communicated through gameplay alone?**
>
> Some things are better left to text, voice, music, or silence. Identify what your game communicates through mechanics and what it communicates through other channels:
>
> | Through Gameplay | Through Other Channels |
> |-----------------|----------------------|
> | (e.g., time pressure creates urgency) | (e.g., voice acting conveys grief) |
> | (e.g., resource scarcity creates desperation) | (e.g., music shift signals tone change) |
> | (e.g., repeated failure conveys helplessness) | (e.g., environmental art shows history) |
>
> The most powerful moments in narrative games happen when gameplay and narrative channels align. Celeste's platforming difficulty IS the story about anxiety.

---

## 2. Genre Constraint Prompts

### For Visual Novels
> - How many routes does your game have? (2-5 is manageable; 6+ requires a dedicated routing system)
> - What gates route access? (Relationship values, knowledge flags, completion of other routes)
> - How long is a single route? (2-6 hours is typical for a full route)
> - What is the "true" route, and how does the player unlock it?
> - How do you handle the common route (shared content across all routes)? Does it feel fresh on replay?
>
> **Key tension**: Visual novels live or die on the strength of their characters. If the player doesn't care about the characters by the end of the common route, no amount of branching saves the game.

### For Walking Sims / Exploration Narratives
> - What draws the player forward? (Curiosity about the next room? Fear of what's behind them? A mystery to solve?)
> - How do you prevent "walking simulator fatigue" -- the feeling of walking between content with nothing happening?
> - What is the relationship between movement and narrative? (Is walking meditative? Tense? Exploratory?)
> - How do you handle pacing when the player controls their own speed?
>
> **Key tension**: The player must feel like an active participant, not a tourist. Gone Home succeeds because you're a detective piecing together clues. Dear Esther struggles because you're a passenger.

### For Narrative RPGs
> - How does the RPG combat system serve the narrative? (Is combat thematic, or is it filler between story beats?)
> - How do stats and skills create narrative options? (Disco Elysium's skills ARE the narrative. Baldur's Gate 3's stats gate dialogue.)
> - How much narrative content is gated behind combat vs accessible to all paths?
> - What is the relationship between character build and story identity?
>
> **Key tension**: Combat and narrative compete for player attention and development resources. Every hour spent on combat systems is an hour not spent on dialogue. Find the ratio that serves your story.

### For Interactive Fiction (Twine/Ink/ChoiceScript)
> - What is your word budget? (20,000 words for short, 60,000 for medium, 100,000+ for long)
> - How do you manage the reader's pace? (Timed text, page breaks, click-to-continue, automatic advancement)
> - What visual/audio elements supplement the text? (Minimal: background color changes. Moderate: character portraits. Rich: full illustrations.)
> - How do you handle save/checkpoint in a text-based medium?
>
> **Key tension**: Text is cheap to produce but expensive to read. Every word must earn its place. Interactive fiction rewards tight, evocative writing over verbose description.

---

## 3. Character Design Prompts

### The Character Identity Test
> **For each major character, answer:**
> 1. What do they want? (External goal)
> 2. What do they need? (Internal growth)
> 3. What are they afraid of? (Drives their behavior under pressure)
> 4. How do they speak? (One sentence that captures their voice)
> 5. What would they never do? (Defines their limits -- and what breaking those limits means)

### The Relationship Map
> **Draw the relationships between your 3-5 most important characters:**
> ```
> Character A ──[trust]──── Character B
>      |                        |
>   [rivalry]              [mentorship]
>      |                        |
> Character C ──[secrets]── Character D
> ```
>
> Every relationship line should create narrative tension. If two characters have a purely positive relationship with no tension, one of them is redundant.

### The Voice Differentiation Test
> **Write the same line of dialogue for each major character:**
>
> Prompt: "The bridge is out."
> - Character A: ____________
> - Character B: ____________
> - Character C: ____________
>
> If you can't tell which character said which line, their voices aren't distinct enough.

---

## 4. World-Building Prompts

### The Iceberg Principle
> **Define three layers of your world:**
>
> 1. **Surface** (what every player sees): The visible world, main characters, central conflict. 100% of this content is experienced.
> 2. **Depths** (what curious players find): Lore documents, side conversations, environmental details. 30-50% of players engage with this.
> 3. **Abyss** (what only dedicated players discover): Hidden connections, secret areas, meta-narrative. 5-10% of players find this.
>
> Each layer should be satisfying on its own. The surface tells a complete story. The depths enrich it. The abyss recontextualizes it.

### The Rule of Three Details
> **For every location, describe exactly three sensory details:**
>
> - What does the player SEE first?
> - What do they HEAR?
> - What is one unexpected detail that tells a story?
>
> Example (Disco Elysium's Whirling-in-Rags):
> - SEE: A decrepit hotel lobby, disco ball still hanging from the ceiling
> - HEAR: Muffled karaoke from upstairs, seagulls outside
> - UNEXPECTED: A tie hanging from the ceiling fan -- your tie, from last night

---

## 5. Structural Design Prompts

### The Branching Budget
> **Before writing a single line, establish your branching budget:**
>
> | Resource | Budget |
> |----------|--------|
> | Total word count | _______ words |
> | Words per playthrough | _______ words |
> | Number of endings | _______ |
> | Major branch points | _______ |
> | Maximum active branches | _______ |
> | Content multiplier (total / per-playthrough) | _______x |
>
> This is your scope. Every branch point you add increases total word count. If your budget is 60,000 words and your content multiplier is 1.5x, each player reads ~40,000 words. That's ~8 hours of narrative content.

### The Ending Design Prompt
> **For each ending, answer:**
> 1. What choices lead here? (The path)
> 2. What emotional tone does this ending have? (Bittersweet, tragic, triumphant, ambiguous)
> 3. Does this ending answer the central question? (It should, even if the answer is "there is no answer")
> 4. Would a player who reaches this ending feel their journey was respected? (Even "bad" endings should feel earned, not punishing)
>
> **Design rule (Pentiment principle)**: There should be no "wrong" ending. Every ending is a valid conclusion to a valid path. The player's journey is the story, not the destination.

---

## 6. Market Positioning Prompts

> **What emotional experience does your game offer that players can't get from a book, film, or TV show?**
>
> Games have one advantage over other narrative media: agency. If your narrative game offers the same experience as reading a book, the player will read the book. Your answer must involve the player's participation.
>
> - Disco Elysium: You ARE the amnesiac detective. Your skill choices create your personality. A book can't do that.
> - Outer Wilds: You explore at your own pace, in your own order. The discovery is yours, not the author's.
> - Undertale: Your choice to kill or spare is yours, and the game judges you for it. A film can't judge its audience.

> **Complete this sentence: "Players will talk about my game because _______."**
>
> The answer should be a specific moment, mechanic, or feeling -- not a feature list.
>
> - Disco Elysium: "...they failed a skill check and it became the best moment of the game."
> - Outer Wilds: "...they figured out the sun station puzzle and wanted to tell everyone."
> - Undertale: "...they killed Toriel and couldn't take it back."

---

*This document extends `game-brainstorm` with narrative-specific prompts. Use after the initial brainstorm session to deepen the concept with genre-appropriate emotional and structural constraints. See `@genre-packs/narrative/PATTERNS.md` for design pattern reference.*
