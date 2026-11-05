# Jam Rulesets, Platforms and AI Disclosure

Facts are as of 2026-11-05 and come from the jams' own pages and press coverage (sources at the end).
Jam rules change every edition: fetch the current rules page before relying on anything here, and
record the fetch date in `JAM.md`.

---

## 1. Ruleset checklist

Extract every item below from the rules page. Anything the page does not say goes in `JAM.md` as
"not stated" with a question for the organizers' Discord or FAQ.

| Area | Questions | Typical traps |
|---|---|---|
| Schedule | Start and end, time zone, grace period for uploads, rating period | Deadlines in UTC or the organizer's local time; "submission" vs. "upload" deadlines |
| Theme | Revealed when, mandatory or optional, judged as a category | Optional themes that are still scored |
| AI policy | Is AI required, allowed, disclosed, limited to code, banned for art or audio? How is it measured? | "Made with AI" jams that measure code share; human-only jams that ban generated assets |
| Platform | Web only? Downloads allowed? Which browsers? Mobile? | "Instantly playable" excludes loading screens and logins |
| Size and format | Byte limits, file counts, ZIP layout | js13kGames counts the zipped entry; portals count initial download |
| Content provenance | Must everything be made during the jam? Pre-made code or engines allowed? Asset packs with credit? | Ludum Dare Compo vs. Jam rules differ |
| Mandatory additions | Badges, widgets, links, credits screens, analytics snippets | Vibe Jam 2026 disqualified entries without `widget.js` |
| Team | Solo only? Max team size? One entry per person? | Joining two teams |
| Hosting | Jam platform, own domain, specific host | Own-domain requirement for some web jams |
| Judging | Categories, who rates, minimum ratings | Entries unranked without enough ratings |
| Licensing | Rights you grant the organizer; open-source requirement | Source-code submission (Ludum Dare Compo) |
| Conduct | Content restrictions, rating age | Portal-style content rules for family audiences |

## 2. Cursor Vibe Jam (AI-native web jam)

Organized by Pieter Levels, with @s13k_ as co-host and lead judge.

| | 2025 | 2026 ("Cursor Vibe Jam") |
|---|---|---|
| Dates | March-April 2025 (exact dates unverified) | 1 Apr to 1 May 2026, 13:37 UTC |
| AI rule | "at least 80% written by AI (code, assets, etc)" | "At least 90% of the code has to be written by AI" |
| Access | "instantly playable on web -- no logins, signups or loading screens"; free; own domain or subdomain | Same; a username prompt was allowed; the game had to be new after 1 April; one entry per person |
| Engine | Any; Three.js recommended | Same; multiplayer preferred |
| Mandatory snippet | A participant code snippet | `https://vibejam.com/2026/widget.js` ("games without it are disqualified") |
| Portals | "Vibeverse Portal" | Optional webring: exit to `vibejam.com/portal/2026?username=&color=&speed=&ref=`; when a game is opened with `?portal=true`, show a return portal |
| Sponsors | Bolt.new; CodeRabbit credited | Cursor (title), Bolt.new, Glif, Tripo AI |
| Prizes | US$10k / $5k / $2.5k | US$25k / $10k / $5k plus twelve $1k specials |
| Scale | 1,000+ games | 945 games, 242,212 players |
| Winners | *The Great Taxi Assignment*, *Vibeware*, *Vector Tango* | *A Game About Capybaras Delivering Food* (Gold), *Fanto's Mega-Mart*, *WenWare* (also Most Played) |

**What the 2026 Gold winner reported** (Wccftech interview, 2026-07-13): built in about two weeks
with Claude Code; about 27,000 lines and 188+ commits; two or three Claude Code sessions in parallel
on separate subsystems, a fresh session per feature, and one long-lived session for context-heavy
bugs; most human time on brainstorming, planning and playing; the 3D map built by hand in an editor;
multiplayer through a single Cloudflare WebSocket lobby, "simpler than expected for a jam"; about
5-10 minutes of play.

**Quality bar:** judge Tim Soret rated the best 2026 entries at "3rd year student" level. Novelty
gets attention; craft wins.

**Compliance notes for a Vibe-Jam-style ruleset:**
- "No loading screens" means a tiny initial payload and progressive loading behind a playable
  first screen, not a spinner.
- Keep the widget script in `index.html` and verify it is present in the built `dist/index.html`.
- A portal webring entry must read its query parameters and offer a way back; test it with
  `?portal=true&username=test`.
- Track the AI share honestly (git co-author trailers; see SKILL.md).

## 3. Other AI-related jams in 2026

| Jam | Dates | Shape | AI stance |
|---|---|---|---|
| **Epic AI MegaJam** | 12-15 Nov 2026 | Unreal Engine or UEFN; cash prizes and grants | Coding agents unlimited but AI is optional; Epic's prep guide says to set up coding agents and MCP tools before the start |
| **Reddit x Phaser "Games with a Hook"** | Jun-Jul 2026 | Devvit Web games for Reddit, Phaser template | Organizers explicitly rejected "obvious AI slop" |

For an Unreal jam, set up the UE 5.8 Unreal MCP plugin (experimental, editor-only, localhost) before
the start; see `/gameforge:game-start` and `/gameforge:game-unreal-specialist`.

## 4. Common jam platforms

| Jam | Where | Format | Notes |
|---|---|---|---|
| **Ludum Dare** | ldjam.com | **Compo:** 48 hours, solo, all content made during the event, source required. **Jam:** 72 hours, teams allowed, fewer content restrictions | Scheduled events were cancelled in 2025 while the organizer took a break; in April 2026 he announced that LD 64 (October 2028) will be the last scheduled event, with ad hoc returns possible. LD 59 ran in April 2026. Entries need enough ratings to be ranked; rating others raises your entry's visibility. |
| **GMTK Game Jam** | itch.io | Annual, summer, multi-day | Thousands of entries per year; the 2026 edition opened on 22 July (PT). Web builds strongly preferred because hosts and players browse entries in the browser. |
| **Global Game Jam** | globalgamejam.org | 48 hours, chosen by each site within a one-week window; physical and online sites | 2026 window: 26 Jan to 1 Feb; theme revealed in a livestream at the start. Register with a site. |
| **Brackeys Game Jam** | itch.io | Numbered editions (for example 2026.1, February 2026) | Standard itch.io submission; active Discord. |
| **js13kGames** | js13kgames.com | About a month, traditionally 13 Aug to 13 Sep | Whole entry at most 13 KB zipped (13,312 bytes), with `index.html`; external libraries and services are generally not allowed unless they fit inside the limit. Check the current year's rules. |
| **itch.io jams in general** | itch.io/jams | Any length | The host writes the rules; read each page. |

## 5. AI disclosure for jam pages

**Platform rules (as of 2026-11-05):**
- **itch.io:** creators answer a generative-AI disclosure on the project page; the answer feeds the
  "no AI" filter, which reaches search since 2026-11-03, when itch.io also deleted a large volume of
  AI uploads and treats bulk AI uploads as spam. Coverage of the rollout reported that undisclosed
  AI projects can lose search indexing. Answer accurately; check the current wording on whether code
  assistance counts.
- **Steam** (if the jam game moves to Steam later): code assistants are exempt; player-facing
  generated content, including marketing assets, is disclosed.
- **EU AI Act Article 50** (applies since 2026-08-02): an AI character that talks to players must
  say it is AI unless that is obvious. Relevant if the jam game has a live LLM NPC. Not legal advice.

**Write the disclosure per content type** (template in SKILL.md): code, art, audio, text, voice,
and any live-generated content. Name the tools. Say what humans did (design, editing, level layout,
playtesting). Vague lines like "some AI was used" help nobody and invite suspicion.

**Measuring AI code share** (only when a rule needs a number): count lines added in commits made by
the agent (Claude Code's default `Co-Authored-By` trailer marks them) against all lines added, with
`git log --numstat`. State the method next to the number.

## 6. Sources

Cursor Vibe Jam 2026 site (vibejam.com, rules, judges, sponsors; accessed 2026-11-05); Vibe Jam
2025 archive (vibejam.com/2025); @levelsio X post, 2026-05-01 (945 games, 242,212 players);
levels.io, "Vibe Jam 2026 winners", 2026-06-17; Wccftech, capybara winner workflow, 2026-07-13;
Beebom and Digital Trends on Epic AI MegaJam, 2026-10-23; Phaser News on the Reddit hackathon, June
2026; 80.lv, "Ludum Dare to officially end in October 2028", 2026-04-17; Synty "Community Jam
Spotlight: GMTK Jam 2026", 2026-07-14; Global Game Jam 2026 announcements (January 2026);
js13kGames rules (long-standing, per js13kgames.com and coverage); VGC and Heise on itch.io,
2026-11-03; Steamworks content survey documentation; EU AI Act Article 50.
