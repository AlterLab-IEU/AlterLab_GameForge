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
  - Web stacks (Phaser 4, Three.js, Kaplay on Vite): set `base: './'` in `vite.config` so asset
    paths are relative (itch.io serves HTML5 games from a subpath; the default `base: '/'` gives a
    blank page), run `npm run build`, and zip the *contents* of `dist/` so `index.html` sits at the
    root of the ZIP
  - Godot 4: Export → Web (Compatibility renderer; C# projects cannot export to the web), test
    from a local server
  - Unity 6: Build Profiles → Web, test with a local server
  - Unreal: no official browser export; ship a downloadable build
  - Hardening pass (subpath-safe paths, audio unlocked on first input, no debug keys in the
    bundle): `/gameforge:game-web-publish`
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
  - Credits: list all team members, asset sources and their licenses
  - AI use: what was AI-made (code, art, audio, text, voice), with which tools, and what humans
    changed, copied from `AI-USE.md`
- [ ] **Add screenshots** (3-5) — title screen, gameplay, key moments
- [ ] **Set game to "In Jam"** — link to the jam page
- [ ] **Tags:** jam name, genre, engine, theme, "short", "browser"
- [ ] **Generative-AI disclosure** answered on the itch.io edit page (it feeds itch.io's "no AI"
      filter, which covers search since 2026-11-03)
- [ ] **Test the published page** — play the game from the itch.io page itself

## AI Disclosure

- [ ] **Jam AI rule re-read** and the entry complies (some jams require AI, as Vibe Jam 2026 required
      at least 90% AI-written code; others ban generated art or reject "obvious AI slop")
- [ ] **`AI-USE.md` complete:** every generated asset with tool, prompt summary, terms read and
      human edits
- [ ] **Every AI-touched area disclosed** on the page and the itch.io form; hand-edited output
      still counts
- [ ] **No ripped or extracted assets** from other games, and no recreation of a specific existing
      game; reference games inspired the entry, nothing more
- [ ] If the game continues after the jam, move the `AI-USE.md` rows into the project's provenance
      log ([AI asset log template](ai-asset-log.md))

## Ludum Dare Submission (if applicable)

- [ ] **Submit on ldjam.com** before deadline
- [ ] **Link to itch.io page** or upload directly
- [ ] **Write description** with theme connection
- [ ] **Add screenshots**
- [ ] **Compo vs Jam:** Compo = solo, all assets from scratch, 48h. Jam = teams allowed, 72h.

## GMTK Jam Submission (if applicable)

- [ ] **Submit on the jam's itch.io page**
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

*Template from [AlterLab GameForge](https://github.com/AlterLab-IEU/AlterLab_GameForge) -- use with `/gameforge:game-jam-mode`*
