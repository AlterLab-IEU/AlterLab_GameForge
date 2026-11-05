# Generators for 5-10 Minute Web Hooks

For the fast lane: small browser games for a weekend, a portal, or an AI-friendly jam, usually built
with a coding agent. The shape that works is consistent across the 2026 Vibe Jam winners and the
guides that followed: one hook a player understands in about five seconds, one mechanic, about
5-10 minutes of play, near-instant load, and no login. Everything below serves that shape.

Run two or three generators, produce six to ten rough hooks, filter with the tests at the end, and
write the best three as concept cards (template in SKILL.md).

---

## Generator 1: Toy first

Start from something that is fun to poke before it is a game. Add a goal last.

| Step | Prompt |
|---|---|
| 1 | Pick a satisfying interaction: drag, fling, stack, slice, paint, pour, stretch, pop, steer, sweep |
| 2 | Pick a material with personality: jelly, sand, rope, ice, magnets, light, water, paper, crowds |
| 3 | Make it respond in an unexpected but readable way |
| 4 | Add one goal and one pressure: a timer, a rising threat, a limited resource, a fragile thing |

Examples (original):
- **Fling + rope + "the knot tightens":** untangle a ship's rigging before the storm; every fling
  tightens a knot somewhere else.
- **Pour + light + "light stains":** pour lantern light into a dark harbor to guide boats; light
  dries and stains the water, blocking later routes.

## Generator 2: One screen, one rule

The whole game fits on one screen. One rule bends everything.

| Rule twist | Starter |
|---|---|
| Everything moves when you move | A tile-sliding courier where the city shifts with each step |
| You control the level, not the hero | Rotate the room; a sleepwalker walks on regardless |
| Your past self repeats | Each attempt leaves a ghost that repeats your last run; cooperate with them |
| Inputs are shared | One button jumps every character on screen at once |
| The camera is the weapon | Whatever stays in frame for two seconds freezes |
| Only the edges matter | Play happens on the border of the screen; the center is a hazard |

## Generator 3: The share moment

Work backward from the screenshot, clip or score people will post.

| Share moment | Ask |
|---|---|
| A ridiculous chain reaction | What small input triggers a huge, readable cascade? |
| A personal artifact | What does the player make that is uniquely theirs (a skyline, a song, a map)? |
| A near miss | Where can the player survive by a pixel, and the game shows it? |
| A daily score | What single run could everyone play today and compare? |
| A visible social trace | What does a player leave behind that the next player sees? |

The last row is how lightweight "multiplayer" often works on the web: asynchronous traces
(ghosts, notes, shared leaderboards) need far less infrastructure than real-time play.

## Generator 4: Constraint twist on a familiar verb

Take a verb every player already understands, then remove or invert one assumption.

| Familiar verb | Removed or inverted assumption | Hook |
|---|---|---|
| Shoot | You cannot aim; only time when to fire | A lighthouse beam that sweeps on its own |
| Jump | You do not control when, only where you land | Mark landing spots for a frog who jumps every beat |
| Build | Everything you build decays in 30 seconds | Keep a bridge standing for a parade |
| Hide | The seeker is the player's own cursor trail | Erase your own tracks as you sneak |
| Drive | Steering is shared with the passengers | Each passenger pulls the wheel toward their stop |

## Generator 5: Real-world system in miniature

A small, honest model of something real is a reliable source of original hooks.

Pick a system (tides, traffic lights, beehives, kitchen tickets, air-traffic stacks, train
couplings, laundry rounds, a bakery's morning) and ask:
1. What is the core tension? (too much at once, the wrong order, timing)
2. What does the player control? (one lever, one queue, one route)
3. What visibly goes wrong? (overflow, collisions, cold food)
4. How does it escalate over ten minutes?

## Generator 6: Multiplayer-lite (only if the user wants online play)

Real-time multiplayer is feasible for small web games built with agents (the 2026 Vibe Jam Gold
winner described it as "simpler than expected for a jam"), but every backend is a dependency that can
die: a secondary analysis of Vibe Jam entries found that games depending on a backend went offline
fastest. Prefer, in order:

1. Asynchronous traces: ghosts, shared daily seed, leaderboard.
2. Couch or same-device play: two players, one keyboard or one touch screen.
3. Small-room real-time play on a hosted room service, with the server authoritative for scores and
   hits. Route the design to `/gameforge:game-multiplayer`.

---

## Filters (apply to every hook)

| Test | Fail signal |
|---|---|
| Five-second read | You need a sentence of instructions before anyone can start |
| One mechanic | The pitch contains "and also" |
| Ten-minute arc | No escalation or no end state inside ten minutes |
| Share moment | Nothing worth posting happens in a normal run |
| Input | Needs more than a mouse, a touch, or three or four keys |
| Static hosting | Needs a mandatory account, a database or a server to be playable at all |
| Originality | The closest existing game can be named in one breath and the differences are cosmetic |
| Buildable | An agent cannot reach a playable core loop in the first hour or two |

## Portal and jam reality checks

If the hook will go to a portal or a jam, check the target's rules before falling in love with it:
- Vibe Jam 2026 required at least 90% AI-written code, web-only, free, no login, signup or loading
  screens, and a mandatory `widget.js` snippet. Details: `/gameforge:game-jam-mode`.
- Portals cap initial downloads (CrazyGames: 20 MB or less for its mobile homepage; YouTube
  Playables: under 30 MiB initial), so a hook that needs huge assets is the wrong hook for them.
  Details: `/gameforge:game-web-publish`.
- Mobile players: test the hook with touch, and plan for audio that only starts after the first tap
  (browsers require a user gesture before audio plays).

## Hand-off

Write the chosen hook as a concept card and hand it to `/gameforge:game-vibe-code`, which turns it
into a one-page spec and a build loop with a pass/fail check per iteration.
