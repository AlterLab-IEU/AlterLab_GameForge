# Release Gates and Compliance Checks (snapshot: November 2026)

Use when assessing a demo, release-candidate or gold gate. Platform rules change; every item
below names its source and date so you can re-check it. Store submission logistics belong to
`/gameforge:game-launch`; web portal packaging to `/gameforge:game-web-publish`.

## 1. Gate checklists

Copy the relevant block into `tests/gates/criteria.md` and adjust thresholds per project.

**Playtest build**
- [ ] Quick suite green on the exact build being sent
- [ ] No S1 bugs on the tested path; known issues listed for facilitators
- [ ] Debug overlays, cheats and test hooks disabled; build ID visible on screen
- [ ] Telemetry (if any) disclosed in the consent form (see `/gameforge:game-playtest`)

**Demo / festival build (for example Steam Next Fest)**
- [ ] Zero P0; zero P1 on the demo path
- [ ] First input reachable within the load budget on minimum-spec hardware
- [ ] Save data from the demo either carries over cleanly or is explicitly discarded
- [ ] Store-page claims (features, controller support, Steam Deck) verified on the build
- [ ] AI content disclosure answered for everything player-facing in the demo and its marketing

**Alpha**
- [ ] All core systems functional; critical path playable end to end
- [ ] Zero P0; performance within 150% of budget on target hardware
- [ ] Save format versioned; migration test exists

**Beta**
- [ ] Content complete; all systems feature-complete
- [ ] P1 count below team threshold; performance within 120% of budget
- [ ] First accessibility pass done with `game-accessibility-specialist`
- [ ] Localization pipeline exercised end to end (pseudo-localization at minimum)

**Release candidate**
- [ ] Zero P0; any P1 has an approved workaround and owner sign-off
- [ ] Performance at target on every platform's minimum spec, including 1% lows
- [ ] Full regression green; zero quarantined tests on critical paths
- [ ] Compliance sections 2-6 below complete for every target
- [ ] Asset provenance log complete; disclosures match it

**Gold / submission**
- [ ] Zero P0 and P1
- [ ] Final build hash matches the build that passed full regression
- [ ] Platform and portal requirements met (or written exemption obtained)
- [ ] Rollback plan: previous build kept, branch tagged, patch pipeline tested

GameForge's `release-checklist.md` template (in the plugin's `templates/`) is the full ship
checklist; this file adds the platform, portal and regulatory checks it does not spell out.

## 2. Console certification awareness

Sony (TRC), Microsoft (Xbox Requirements) and Nintendo (Lotcheck) publish their requirements only
to registered developers under NDA. Do not guess at them; get the current checklist through the
platform's developer portal or your publisher. Categories that commonly fail first submissions and
are worth testing early on any platform:
- Suspend/resume and sleep mode; network loss and reconnection mid-session.
- Save data: corruption handling, storage-full, user switching, cloud sync conflicts.
- Account and user identity display, parental controls, age-gated features.
- Error message wording and controller disconnect handling.
- Achievements/trophies unlock correctly and never retroactively fail.
- Accessibility features the platform expects to be discoverable.

Budget calendar time for at least one resubmission when planning with `game-producer`.

## 3. Steam

- **Review timing.** Engadget reported on 2026-11-04 that Steam build reviews were taking up to
  12 business days against a 3-5 day target, with new pre-review checks applying from that date. Submit release candidates early enough to absorb that.
- **AI disclosure** (Steamworks Content Survey, rewritten 2026-01-16): disclose generative-AI
  content that ships and is consumed by players, explicitly including artwork, sound, narrative and
  localization, plus marketing assets. Efficiency tools such as code assistants are exempt.
  **Live-generated** content requires a description of your guardrails. QA verifies the answers
  match the provenance log, not memory.
- **Steam Deck**: if the store page or marketing claims Deck support, test on hardware: text
  legibility at 1280x800, controller-only navigation including launchers and text entry, suspend
  and resume.
- Steam Playtest (a separate free app entry) is the low-friction way to run external tests; see
  `/gameforge:game-playtest`.

## 4. Web portals and itch.io

Values from each portal's documentation, accessed 2026-11-05. Re-check before submission.

| Target | QA checks |
|---|---|
| CrazyGames | Initial download 50 MB or less up to the gameplay-start event; 20 MB or less for the mobile homepage; 250 MB and 1,500 files total; smooth on 4 GB Chromebooks; ads only through their SDK; fire the `gameplayStart` event |
| Poki | Players leave if loading takes more than about 10 seconds; `gameplayStart()` on first input; no external requests; works with ad blockers and in incognito storage; no debug code |
| YouTube Playables | Initial bundle under 30 MiB (15 MiB recommended); total under 250 MiB; each file under 30 MiB; saves under 3 MiB; JS heap capped at 512 MB |
| itch.io | ZIP with `index.html`; SharedArrayBuffer only with the cross-origin isolation toggle; generative-AI disclosure feeds the "no AI" filter, which itch.io extended to search on 2026-11-03 |

Always test: first load on a throttled connection, iOS Safari audio starting after the first tap,
mid-range Android performance, portrait and landscape, focus loss and tab switching, and storage
that disappears in private browsing.

## 5. Mobile

- **Apple App Review**: privacy labels match actual data collection (including analytics SDKs);
  in-app purchases through Apple's system where required; no downloading and executing new code.
  In March 2026 Apple blocked updates to vibe-coding apps under guideline 2.5.2 (Heise,
  2026-03-18), so an in-app game *maker* is a review risk.
- **Google Play**: target API level requirement for the year, Data safety form matches behavior,
  content rating questionnaire, and the AI-Generated Content policy if the game generates content
  at runtime (no offensive or deceptive output).
- Test on at least one low-end and one current device per OS; check thermal behavior after
  30 minutes.

## 6. Ratings, accessibility and AI regulation

**Age ratings**
- **PEGI** announced new interactive-risk criteria on 2026-03-12, applying to games submitted from
  June 2026: paid random items (loot boxes, card packs, gacha, keys for random rewards) default to
  at least PEGI 16, and higher in some implementations; criteria also cover in-game purchases,
  communication features and features that push continued play (VGC, Engadget, March 2026).
  Reports disagree on whether existing titles will be reclassified; check PEGI's own guidance.
- Answer IARC and ESRB questionnaires from the build, not the design doc. Recheck after any
  monetization or chat change.

**Accessibility**
- **European Accessibility Act** (in force since 2025-06-28): in scope are consoles, e-commerce
  (which covers in-game purchase flows) and electronic communications (the basis for arguing that
  in-game chat is covered). Games as such are not named. Microenterprises (fewer than 10 staff and
  no more than EUR 2M turnover) are exempt for services. Scope questions go to
  `game-accessibility-specialist`.
- **US CVAA**: communication features (text, voice and video chat) must be accessible.
- **Xbox Accessibility Guidelines (XAG)**: a public, practical checklist even for non-Xbox games.

**AI-specific**
- **EU AI Act Article 50** applies from 2026-08-02. AI agents and avatars, including AI NPCs, must
  tell users they are AI unless that is obvious (50(1)); runtime generative systems need
  machine-readable marking of output (50(2)), with a grace period to 2026-12-02 only for systems
  already on the market. Test that the disclosure appears where players first meet the AI feature.
- **Microsoft Store policy 11.16** (live generative AI): disclose in metadata and Partner Center,
  keep output within store policy, and give players a way to report content. QA tests the report
  flow end to end.
- **Live-generated content guardrails**: test the guardrails as features. Attempt prompt injection
  and jailbreaks against AI NPCs (players exploited AI chat NPCs in *Where Winds Meet* soon after
  launch, per press reports), log failures as Security / exploit bugs.
- Keep the AI content policy (`ai-content-policy.md` template) and the asset provenance log current;
  disclosure answers are generated from the log, then QA spot-checks a sample of assets against it.

## 7. Gate report hygiene

- Attach evidence: suite output, the build hash, screenshots of portal checks, device list.
- Record every waived criterion with who approved it and why.
- Update `production/session-state/active.md` with the gate result and the next gate date.
