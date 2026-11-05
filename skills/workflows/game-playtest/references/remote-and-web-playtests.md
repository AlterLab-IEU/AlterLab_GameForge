# Remote and Browser-Build Playtests

Most indie playtests are remote. Done well, they reach the real audience on real hardware; done
carelessly, they leak builds and measure testers' internet connections instead of your design.
Platform details below were checked on 2026-11-05.

## 1. Distribution options

| Channel | How access works | Good for | Watch out for |
|---|---|---|---|
| **itch.io, Restricted page** | Only people you approve can open the page. You grant access by sending a download key they attach to their itch.io account; revoking the key removes access. An optional password can be added on top. (itch.io creator docs, "Access control") | Small invited rounds, browser builds, downloadable builds | Testers need an itch.io account to redeem keys; keep one key per tester so you can revoke a leaker |
| **itch.io, Draft page** | Default state; visible to editors and anyone with the secret link | Quick internal checks | A secret link spreads; not for strangers |
| **Steam Playtest** | A free companion app on your Steam page; players request access and you decide how many get in and when the test ends | Larger rounds of strangers, Steam-native telemetry, Deck testing | You need a Steam app; requests come from people who already found your page (self-selected fans) |
| **Steam beta branch + keys** | Password-protected branch or keys to the main app | Closed rounds with an existing community | Keys can be resold or leaked; revoke unused ones |
| **Your own host** | Static web build at an unlisted URL behind basic auth or a short-lived token | Browser games, very fast iteration | Unlisted is not private; expire links after the round |
| **Direct download (zip)** | Cloud drive link | Last resort | Unsigned executables trigger antivirus warnings, which poison first impressions |

Never email executables.

## 2. Browser builds for playtests

Browser builds remove install friction, which makes them the fastest way to get strangers playing.
They also change what you are testing.
- **Build hygiene**: production build with test hooks and debug UI off, build ID on screen, no
  console spam. Ask `game-qa-lead` for the playtest-build gate.
- **Load time is part of the test.** Note each tester's time to first input. A slow first load
  on a tester's connection is a real finding for a web game, and noise for a desktop game.
- **Device spread**: ask testers for browser, OS, device and whether they used touch, mouse or a
  gamepad. Mobile Safari needs audio started from a tap; mid-range Android phones can stutter
  where an iPhone is smooth. Separate findings by device class.
- **itch.io HTML5 upload**: ZIP with `index.html` at the root; enable the SharedArrayBuffer option
  only if the build needs it (it requires cross-origin isolation).
- **Storage**: private browsing and some embedded frames drop `localStorage`; give testers a fresh
  start or a scenario parameter, not a save they might lose halfway.

## 3. Telemetry for remote sessions

Telemetry tells you *where* players struggle at scale; observation tells you *why*. Keep the event
list short and disclosed:

```
session_start   {build, device_class, input_type}
level_start     {level_id, t}
death           {level_id, t, x, y, cause}
level_complete  {level_id, t, deaths}
setting_changed {setting, value}
quit            {level_id, t, menu_or_alt_f4}
```

- No names, emails, IP logging, free-text fields or device fingerprints.
- A privacy-friendly option for small rounds: write events to a local JSON file (or `localStorage`)
  and give testers an "Export session log" button in the pause menu. They choose to send it.
- For anything larger or ongoing, route to `/gameforge:game-analytics-setup`.

## 4. Recording setup (moderated remote)

- **Call**: any video tool the tester already has (Discord, Zoom, Google Meet). Keep your mic muted
  during play; your breathing and typing change their behavior.
- **Screen**: ask testers to share the game window, or record locally with OBS Studio, Xbox Game
  Bar (Windows) or the macOS screen recorder and upload afterward. Send written setup steps a day
  ahead; do not spend the session debugging capture software.
- **Webcam**: optional and opt-in. Even low-quality video catches delight and frustration that
  testers never mention. Respect a "no."
- **Session timer**: show elapsed time on screen or in the HUD of the playtest build so recordings,
  notes and telemetry line up.

Block about 90 minutes for a moderated session: 10 setup, 45-60 play, 7 debrief, 5-10 survey.

## 5. Unmoderated (async) protocol

When testers play on their own time:
- Give one page of instructions: how to get in, how long to play, what not to worry about (known
  issues), and how to send the survey and optional session log.
- Ask for three notes right after playing: one moment that surprised them, one moment they felt
  confused, one moment they were most engaged. Raw reactions beat considered essays.
- Add 2-3 targeted questions tied to this round's research questions.
- Expect lower completion: send to more people than you need and track who finished.
- Watch recordings when testers offer them; prioritize testers whose telemetry shows quits or
  repeated deaths.

## 6. Leak, clone and community risk

Kotaku reported in October 2026 that some studios had cancelled public playtests amid AI cloning
and extortion attempts, and developers have described receiving threats to clone their game unless
they paid. Plan for leaks rather than hoping:
- Prefer restricted access (per-tester keys) over open links; revoke keys after the round.
- Show a per-tester ID or watermark in the playtest build if you are worried about leaks.
- Test the hook and the loop, not the whole content plan; hold back late-game content.
- Keep the build time-limited where the platform supports it (end the Steam Playtest, revoke
  itch.io keys, expire links).
- A public demo is marketing, not a playtest; plan it with `/gameforge:game-launch`.

## 7. What remote testing cannot capture

- Facial expressions and posture without webcam (some testers decline, correctly).
- The tester's environment: distractions, audio setup, hardware quality, dropped frames you cannot see.
- True cold start, if they watched your trailer first. Ask, and segment by it.

For first-impression and onboarding questions, an in-person session (a friend's living room, a
local meetup, a game-dev night) is still worth the effort when you can get it.
