# Jam Submission Checklist

> Start this checklist 2 hours before the deadline. Submissions that fail are always last-minute.

---

## Build Preparation

- [ ] **Test the build on a clean machine** (or at least a different browser for web builds)
- [ ] **Remove debug features** — god mode, level skip, console output
- [ ] **Set starting state correctly** — game starts at menu/intro, not a debug level
- [ ] **Test game loop end-to-end** — start → play → win/lose → restart works
- [ ] **Check audio levels** — nothing blasting, nothing silent
- [ ] **Verify controls work** — test every input the player needs

## Export / Build

- [ ] **Web build** (recommended for maximum plays):
  - Godot: Export → HTML5, test in browser
  - Unity: Build → WebGL, test with local server
- [ ] **Windows build** (backup):
  - Zip the entire build folder (exe + data)
  - Test the zip on a different machine if possible
- [ ] **Mac/Linux build** (optional, time permitting)

## itch.io Submission

- [ ] **Create or update itch.io page**
- [ ] **Upload build files** — drag and drop or use butler:
  ```bash
  butler push ./build username/game-name:html5
  butler push ./build-win username/game-name:windows
  ```
- [ ] **Write game description:**
  - One sentence: what is this game?
  - Theme connection: how does it interpret the jam theme?
  - Controls: list every input
  - Known issues: be honest about bugs
  - Credits: list all team members, asset sources
- [ ] **Add screenshots** (3-5) — title screen, gameplay, key moments
- [ ] **Set game to "In Jam"** — link to the jam page
- [ ] **Tags:** jam name, genre, engine, theme, "short", "browser"
- [ ] **Test the published page** — play the game from the itch.io page itself

## Ludum Dare Submission (if applicable)

- [ ] **Submit on ldjam.com** before deadline
- [ ] **Link to itch.io page** or upload directly
- [ ] **Write description** with theme connection
- [ ] **Add screenshots**
- [ ] **Compo vs Jam:** Compo = solo, all assets from scratch, 48h. Jam = teams allowed, 72h.

## GMTK Jam Submission (if applicable)

- [ ] **Submit via GMTK submission form** (usually Google Form or itch.io)
- [ ] **Verify game is playable in-browser** (GMTK strongly prefers web builds)

## Post-Submission

- [ ] **Post on social media** — screenshot + link + jam hashtag
- [ ] **Play and rate other jam games** — community participation matters for rankings
- [ ] **Write a short post-mortem** while it's fresh:
  - What worked?
  - What didn't?
  - What would you do differently?
  - Is this worth continuing as a full project?
- [ ] **Sleep.** You've earned it.

---

*Template from [AlterLab GameForge](https://github.com/AlterLab-IEU/AlterLab_GameForge) -- use with `/game-jam-mode`*
