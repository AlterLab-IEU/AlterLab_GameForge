---
name: game-launch
description: >
  Runs the pre-release launch pipeline for Steam, Epic, consoles and mobile: build gates, store page
  and review lead times, Next Fest and wishlists, a dated compliance checklist (AI disclosure, EU AI
  Act, EAA, IARC), day-one patch and go/no-go. Not for browser games (use game-web-publish).
argument-hint: "[platform: steam|epic|console|mobile] [target date YYYY-MM-DD]"
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, WebSearch, WebFetch, Bash(git log *), Bash(git status *), Bash(git describe *)
effort: high
disable-model-invocation: true
---

# AlterLab GameForge -- Pre-Release Launch Pipeline

The distance between "done" and "launched" is longer than most teams expect, and the distance
between "launched" and "sustained" is longer still. A finished, fun game can still stall because the
store page went live too late, the build sat in review during a backlog, the AI disclosure was
wrong, or the hotfix pipeline had never been exercised. This workflow runs the whole path: build
gates, storefront, discoverability, compliance, day-one patch, go/no-go, and the first months after
release.

Late 2026 adds two pressures that did not exist a few years ago. Stores are flooded (Steam reported
review times of up to 12 business days in November 2026, and itch.io purged terabytes of AI-generated
uploads the same month), and AI-related disclosure is now a legal and storefront requirement in
several places. Plan for both from day one of launch prep, not the week before.

## Purpose and Triggers

**Use this workflow when:**
- The game is entering its final milestone and needs a structured launch plan with dates
- A store page, demo, Next Fest slot or submission deadline is coming up
- Compliance needs an audit: age ratings, AI disclosure, accessibility, privacy, licences
- The team needs a go/no-go decision with documented risk
- An Early Access launch or Early Access to 1.0 transition is being planned (same process,
  adjusted scope)
- Post-launch support (hotfixes, community, metrics, roadmap) must be ready before launch day

**When NOT to use me:**

| Situation | Use instead |
|---|---|
| Browser release: itch.io HTML5, Poki, CrazyGames, Discord Activities, YouTube Playables, PWA | `/gameforge:game-web-publish` |
| Game jam submission | `/gameforge:game-jam-mode` |
| Internal or closed playtest build | `/gameforge:game-playtest` |
| Automated builds, signing, Steam depot uploads in CI | `/gameforge:game-ci-pipeline` |
| Positioning, comparable titles, price research | `/gameforge:game-market-research` |
| Translating store page and game text | `/gameforge:game-localization-manager` |
| Full accessibility audit or EAA scoping | `/gameforge:game-accessibility-specialist` |
| Generating or logging AI assets before they ship | `/gameforge:game-ai-assets` |
| Feature still unfinished, scope versus date | `/gameforge:game-scope-check`, then `/gameforge:game-producer` |
| Several roles must sign off in parallel | `/gameforge:game-team-orchestrator` (release pipeline) |

## Critical Rules

1. **Every phase is gated.** Do not advance until the current gate is signed off or the exception is
   written down with an owner. Skipped gates are where launches implode.
2. **Lead times beat effort.** Several steps have fixed minimum durations (Coming Soon visibility,
   store and build review, Next Fest demo review, console certification). Backplan from the launch
   date before doing anything else.
3. **The store page is a design deliverable.** It is the game's first impression and the only one
   most people will see. It must show only what ships at launch.
4. **Compliance is not optional, and it is dated.** Each item in the compliance table below has an
   applicability test and a date. Record "not applicable, because ..." rather than skipping a row.
5. **Disclose from evidence, not memory.** AI-disclosure answers come from the asset provenance log,
   not from recollection the week before submission.
6. **Plan for failure.** The plan must include a rollback path and a tested hotfix pipeline. A
   rollback plan that has never been executed is a hope.
7. **Launch day is day one.** Post-launch cadence, community ownership and metrics are part of the
   launch plan, not a follow-up.
8. **Verify time-sensitive rules before stating them.** Platform rules in this skill are current as
   of November 2026. Before telling the user a deadline, open the official page (Steamworks, Partner
   Center, App Store Connect, Play Console) with WebFetch and confirm it. This skill gives practical
   guidance, not legal advice; recommend counsel for EULA, privacy and AI Act questions.

## Step 0: Intake

Read silently first:
- `.gameforge/project.json` (engine, phase, pillars) and `production/session-state/active.md`
- Any existing `production/releases/` checklist, `design/` store copy, `CHANGELOG`, crash or bug reports
- The AI asset provenance log `design/ai-asset-log.md` (format:
  `${CLAUDE_PLUGIN_ROOT}/templates/ai-asset-log.md`, maintained by `/gameforge:game-ai-assets`) and
  the project's AI content policy (`${CLAUDE_PLUGIN_ROOT}/templates/ai-content-policy.md`)
- `git describe --tags` and `git log` for the release candidate and recent churn

Then ask one AskUserQuestion round (up to four questions, each with a recommended default):

1. **Platforms:** Steam only (default) / Steam + Epic or GOG / plus console / plus mobile
2. **Launch type:** full release / Early Access / Early Access to 1.0
3. **Target date:** firm, flexible, or "tell me the earliest realistic date"
4. **Risk flags (multi-select):** AI-generated content that ships, live AI at runtime (LLM NPCs,
   generated text or voice), in-game purchases or loot boxes, chat or voice between players, sold
   in the EU, likely to attract children

Do not ask what the files already answer. If the date is unknown, compute the earliest realistic
date from the backplan below and propose it.

## Step 1: Backplan from the launch date

Fixed lead times as documented by the platforms (verified November 2026; re-check before relying on
them):

| Milestone | Minimum lead time | Source / note |
|---|---|---|
| Steam store page public as Coming Soon | At least 2 weeks before release; Valve advises going live "as soon as you're ready" | Steamworks release docs. Wishlists accrue only while the page is public. |
| Steam store page review | Submit at least 7 business days before you want it live (typical review 3-5) | Steamworks review process |
| Steam build review | Plan at least 7 business days; reviews took up to 12 business days in Nov 2026 | Steamworks; Engadget, 2026-11-04. Budget 3 weeks in a backlog. |
| Steam release date changes | Locked once Coming Soon and within 14 days of release; contact Valve to change | Steamworks release dates |
| Steam Next Fest (Feb, Jun, Oct) | Demo review submitted at least 3 weeks before the fest (5 weeks for Press Preview); register before the edition deadline | Steamworks Next Fest docs. One Next Fest per game, ever. |
| Steam Direct fee | US$100 per app, recoupable after US$1,000 adjusted gross revenue | Steamworks app fee |
| IARC age rating (Microsoft Store/Xbox, PlayStation Store, Nintendo eShop, Google Play, Epic, Meta) | Questionnaire at submission; free | Microsoft Store policy 11.11; IARC |
| Console certification | Timelines are in each platform's NDA documentation; plan at least one resubmission | Ask your platform account manager |
| Press keys and embargo | Keys out early enough for reviews to land before the launch-week window | Team decision |

Write the backplan as a dated table in the launch report. Any milestone whose start date is already
in the past is a schedule risk: raise it immediately, with the options (slip, cut a platform, skip
Next Fest) and the Producer as decision-maker (`/gameforge:game-producer`).

## Phase 1: Build Validation

The final technical gate. The game must be provably stable, performant and complete.

- **Clean build:** build from source control on a machine that has never built the project.
  Catches missing dependencies, local-only files and hard-coded paths. The build is documented and
  reproducible by more than one person (or by CI via `/gameforge:game-ci-pipeline`).
- **Version:** the version string matches the release tag; symbols are archived for crash reports.
- **Automated tests:** unit, integration and smoke tests green on every target platform; skipped
  tests have a documented reason. Smoke path: new game, save/load, every main-menu option, credits.
- **Performance:** frame-rate and load-time budgets met on real minimum-spec hardware (and on Steam
  Deck if you claim Deck support). A two-hour soak test shows no monotonic memory growth.
- **Bugs:** zero P0 (crash, data loss, progression blocker) and P1 (major feature broken, frequent
  soft lock). Every P2 is fixed or accepted in writing. P3s are catalogued for the patch plan.
- **Saves:** release-build saves load; Early Access saves migrate; a corrupted save is handled
  without a crash; cloud saves sync across devices.
- **Full playthrough:** one person plays start to finish on the release build through the store
  client (on Steam, launch it from the Steam client, not the executable).

**Gate:** all tests pass, no P0/P1, budgets met on target hardware, full playthrough clean.

## Phase 2: Storefront Requirements

Read `${CLAUDE_SKILL_DIR}/references/storefront-requirements.md` before preparing any store page or
submission: it holds the Steam asset sizes and review rules, Next Fest rules, Epic and GOG notes,
console programs, and the Apple and Google build and rating requirements.

Rules that sink submissions most often (Steam, verified November 2026):
- The store page shows only features and content available at launch.
- Capsules carry the game's title or logo and no other text (no quotes, no awards).
- At least five screenshots, 1920x1080 or larger, gameplay only.
- The build starts on every operating system the page lists; every listed feature works.
- In-game transactions use the Steam Wallet.
- Before marking a build ready, play it through the Steam client for at least five minutes, confirm
  redistributables (DirectX, Visual C++), achievements and Steam Cloud paths, and categorize
  screenshots. Valve added these pre-review checks in November 2026 to cut re-reviews (Engadget,
  2026-11-04).

**Gate:** all assets and metadata ready per platform; store copy reviewed by two people (one for
accuracy, one for appeal); store page and build submitted inside the backplan's lead times.

## Phase 3: Discoverability, Marketing and Wishlists

**Wishlist realities (from Valve's own documentation):**
- Wishlisters get an email or push notification when the game releases (and again when it leaves
  Early Access) and when it gets a discount of 20% or more lasting over 8 hours.
- Wishlists are "an important factor" in where a game appears, but Steam is personalized and Valve
  states there is no minimum wishlist count before Steam starts showing a game, and no formula that
  predicts sales from wishlists. Treat any "you need N wishlists" figure as folklore unless it comes
  with data you can inspect.
- Wishlists follow audience-building work (demo, festivals, press, creators, community), so the
  Coming Soon page should go up as early as the game can be shown honestly.

**Store flooding context (late 2026):**
- Steam Next Fest October 2026 had roughly 7,300 demos against roughly 4,400 in June 2026 (press
  and analyst counts; Valve publishes no official total). Next Fest alone no longer guarantees
  attention; arrive with a demo whose first five minutes sell the hook.
- Valve's November 2026 review-process changes respond to a submission backlog; expect slower
  reviews around festivals and seasonal sales.
- itch.io deleted "a couple terabytes" of AI-generated uploads on 2026-11-03 and extended its "no AI"
  filter to search. Undisclosed AI content is a delisting risk there; disclosed AI content is
  filterable by players.
- Players and juries punish undisclosed or careless AI use: the Indie Game Awards rescinded *Clair Obscur*'s awards in
  December 2025 over generative-AI placeholder textures that had already been patched out.

**Marketing deliverables** (detail in the release checklist template):
- Press kit at one URL: fact sheet, key art, 10-15 curated screenshots (HUD on and off), short GIF
  loops, logo pack, studio bio, press contact
- Trailers: a 60-90 second gameplay trailer that opens on the hook and ends with the date and a
  wishlist call to action; a short launch trailer readable without sound
- Press and creator outreach: a curated list of outlets and creators who cover the genre,
  personalized emails, keys through a key-distribution service or a tracked sheet, explicit embargo
- Community: Discord or forum set up and moderated before launch; launch posts drafted per channel

**Gate:** press kit hosted, trailers uploaded, outreach sent with embargo, Coming Soon page live
for at least two weeks, Next Fest decision recorded (entered, skipped, or deferred, with reason).

## Phase 4: Compliance and Legal

Read `${CLAUDE_SKILL_DIR}/references/compliance-checklist.md` before filling this phase: it gives
the applicability test, exact obligations, evidence to keep and sources for every row below. Run
every row; mark it "N/A because ..." when it does not apply.

| # | Item | Applies when | Key dates | Action |
|---|---|---|---|---|
| C1 | **Steam AI disclosure** (Content Survey) | Any AI-generated content that ships and players consume: art, sound, narrative, localization, plus store page and marketing assets. Code assistants and other efficiency tools are exempt. | Required since Jan 2024; rewritten 2026-01-16; checked at pre-release review | Answer Pre-Generated and Live-Generated sections from the asset log. Live-Generated needs a description of your guardrails; live-generated adult sexual content is not allowed. |
| C2 | **Microsoft Store policy 11.16** (covers Xbox-branded stores) | Content generated live by AI in response to user input | Store Policies v7.20 (updated 2026-09-14) | Disclose in metadata and in Partner Center; keep output within Store policy; provide in-game reporting and act on reports. Pre-generated assets are not covered. |
| C3 | **EU AI Act Article 50** | Sold in the EU and the game has AI systems players interact with (AI NPCs) or generates synthetic content at runtime | Applies from 2026-08-02; machine-readable marking (50(2)) grace to 2026-12-02 for generative systems already on the market | Tell players they are talking to an AI unless obvious; mark runtime-generated output; deepfake notices for artistic works must not hamper the work. Fines up to EUR 15M or 3% of turnover. |
| C4 | **European Accessibility Act** | EU sales with in-game purchase flows (e-commerce) or player communication (chat, voice); consoles are in scope as hardware | In force since 2025-06-28 | Scope it with `/gameforge:game-accessibility-specialist`. Microenterprises (under 10 staff and no more than EUR 2M turnover) are exempt for services. |
| C5 | **US copyright and AI** | Any AI-generated content you want to own | Copyright Office Part 2, 2025-01-29; *Thaler* cert. denied 2026-03-02 | Human authorship is required; prompts alone are not enough. Document human selection, arrangement and modification; disclaim AI-generated material when registering. |
| C6 | **Age ratings via IARC** | Microsoft Store/Xbox, PlayStation Store, Nintendo eShop, Google Play, Epic Games Store, Meta Horizon Store | At submission; PEGI criteria change for games submitted from June 2026 | Answer the IARC questionnaire accurately and keep it current. Under PEGI's 2026 criteria, paid random items default to PEGI 16, time-limited offers to PEGI 12, NFTs to PEGI 18. Steam uses its own Content Survey; Apple uses its own questionnaire (13+/16+/18+ tiers since July 2025). Japan's CERO is not part of IARC. |
| C7 | **Children's privacy (COPPA)** | Child-directed game, or actual knowledge of under-13 players in the US | Amended rule: compliance required since 2026-04-22 | Parental consent before collecting personal data; separate consent for non-integral third-party disclosure; written security program. |
| C8 | **Privacy, EULA, store privacy labels** | Any analytics, crash reports, accounts, cloud saves | Ongoing (GDPR, Apple privacy details, Google Play Data safety) | Privacy policy reachable in game and on the store page; EULA for online features; labels match what the SDKs actually collect. |
| C9 | **Licences and provenance** | Every third-party and AI-generated asset, middleware, font, OSS library | Before gold | Verify commercial-use terms per asset, including AI tool licences (some exclude regions or outputs); credits and OSS notices complete. |
| C10 | **Voice replicas and AI voice** | Synthetic or cloned performer voices | SAG-AFTRA Interactive Media Agreement ratified 2025-07-09 | Consent and disclosure for digital replicas, with usage reporting where the agreement applies. |
| C11 | **Mobile build floors** | iOS or Android release | Apple: Xcode 26 / iOS 26 SDK since 2026-04-28. Google Play: target API 36 for new apps and updates since 2026-08-31 | Check the current floors in App Store Connect and Play Console before the build is cut. |
| C12 | **Accessibility statement and tags** | Every release; required tags on some stores | ESA Accessible Games Initiative tags since Mar 2025; Xbox store shows and audits them | Publish an honest feature list; select only tags the shipped build meets. |

PlayStation and Nintendo publish no public AI-specific store rule as of November 2026; follow their
partner documentation. For browser and itch.io HTML5 disclosure, use `/gameforge:game-web-publish`.

**Generate disclosures from the asset log.** Run `/gameforge:game-ai-assets` to produce its
disclosure draft (`production/releases/ai-disclosure-<build>.md`), or read `design/ai-asset-log.md`
directly: tool, licence, where each asset ships (game, store page, trailer, localization), human
edits. Map each entry to C1/C2/C3/C5/C9/C10 and draft the Steam survey answers from that mapping.
If there is no log, build one before submission; do not reconstruct AI use from memory. Code
written with Claude Code or other assistants is not disclosable on Steam; the art, audio, text and
translations it helped generate can be.

**Gate:** every row resolved or marked N/A with a reason; ratings obtained; privacy policy live;
licences verified; AI disclosures drafted from evidence and reviewed by the Creative Director.

## Phase 5: Day-One Patch and Hotfix Pipeline

The build that passes review is rarely the build players get on day one.

- **Known issues list:** every issue in the gold build, with severity, visibility and disposition
  (day-one patch, later patch, accepted). Community support uses it on launch day.
- **Day-one patch scope:** fixed before launch, never reactive. Bug fixes, late balance, localization
  fixes, performance; no new features. It goes through an abbreviated Phase 1.
- **Hotfix pipeline:** fix, build, test, deploy, verify, with a measured end-to-end time per
  platform. On Steam, rehearse pushing a build to a beta branch and promoting it to default.
  Console patches need certification; mobile updates need store review.
- **One decision-maker** with launch-week availability approves emergency hotfixes.
- **Monitoring:** crash reporting active in the release build; basic telemetry for progression and
  drop-off (`/gameforge:game-analytics-setup`); someone owns review and community monitoring;
  server dashboards and alerts if the game is online.

**Gate:** known issues listed, patch scoped and tested, hotfix pipeline exercised end to end on a
non-default branch, monitoring verified in the release build.

## Phase 6: Go/No-Go Decision

Each phase owner reports Complete, Complete with exceptions (listed), or Incomplete (blockers).

| Risk | Question | Impact if realized |
|---|---|---|
| Technical | Could it crash on common hardware or OS versions? | Refunds, review score damage |
| Performance | Does min-spec hold the budget in the heaviest scenes? | Negative first impressions |
| Content and disclosure | Is anything offensive, misleading, or undisclosed (AI use included)? | Removal, backlash, award or feature loss |
| Legal | Any unverified licence or open compliance row? | Takedown, liability |
| Review timing | Is the build approved with margin, or still in a backlog? | Missed date |
| Server (if online) | Can infrastructure take the launch peak? | Unplayable launch |
| Discoverability | Is the page live, tagged accurately, and seen? | Quiet launch despite quality |

Rate each Low/Medium/High for likelihood and impact. Any High-High is a blocker unless the
decision-maker accepts it in writing.

- **GO:** all phases complete or exceptions accepted, no unaccepted High-High, rollback ready, war
  room staffed.
- **CONDITIONAL GO:** proceeds on stated conditions with a fallback if a condition fails ("GO if the
  day-one patch is live on the default branch by 08:00 UTC; otherwise hold the release button").
- **NO-GO:** blockers remain. Set the new date from the backplan (lead times do not shrink) and
  communicate it plainly.

**Rollback and war room:** how to revert the default branch, how to pause sales or pull the page, who
posts the "we are aware" message (draft it now), abort criteria, on-call names and channels,
check-ins at +1h, +4h, +12h, +24h and +48h.

## Phase 7: Post-Launch Operations

Read `${CLAUDE_SKILL_DIR}/references/post-launch-ops.md` when planning patch cadence, community
channels, metrics or the 12-month roadmap; it holds the templates and the platform update notes.

Minimum before launch: a three-tier cadence (hotfixes in days, content patches in weeks, major
updates in months), a named owner per community channel, a metrics dashboard with targets set from
your own playtest and demo data, and a month-by-month roadmap with a sustain-or-sunset decision
point. Public examples worth studying: Supergiant ran *Hades* in Early Access from December 2018 to
its September 2020 1.0 with regular named updates, and ConcernedApe has shipped free major
*Stardew Valley* updates for years after its 2016 release.

## Working with AI Coding Agents

Launch prep is checklist-heavy, which makes it a good fit for an agent, and high-stakes, which
makes verification non-negotiable.

**Delegate to the agent:**
- Building the dated backplan from the target date and the lead-time table
- Diffing the release branch against the gold tag and listing every change since review
- Drafting the known-issues list from the bug tracker or `tests/` reports
- Mapping the asset provenance log to the compliance rows and drafting Steam survey answers
- Checking that every store-page claim matches a feature in the build (search the code and design
  docs for each bullet)
- First drafts of patch notes, press emails and community posts for a human to rewrite

**Verify by hand:**
- Every Steamworks, Partner Center, App Store Connect and Play Console setting; agents do not
  submit builds or press release buttons
- Rating questionnaires and AI disclosures; the developer is accountable for their accuracy
- The clean-machine build and the full playthrough through the store client
- Legal text (privacy policy, EULA, AI Act notices) with counsel

**Guardrails against vibe debt at release:**
- Release freeze: after gold, an agent fix goes through the full Phase 1 gate, never straight to
  the default branch. Small diffs, one fix per change, reviewed by `/gameforge:game-code-review`.
- AI-drafted store copy, capsule art, trailer narration or translations are store-page and
  marketing content under Steam's January 2026 wording; disclose them or have a human redo them.
  Record the decision either way.
- Keep the build reproducible without the agent: document the build and deploy commands in the
  repository, not only in a chat history.

**Prompts that work:**
- "Read `design/ai-asset-log.md` and `production/releases/`. For each Steam Content Survey AI
  question, draft an answer and cite the log rows it relies on. Flag anything you cannot evidence."
- "List every commit since tag v1.0.0-rc2 with a one-line risk rating; mark anything that touches
  save data, input or networking as needs-retest."

## Output Format

Write the checklist from `${CLAUDE_PLUGIN_ROOT}/templates/release-checklist.md` to
`production/releases/<version>-checklist.md` and the report below to
`production/releases/<version>-launch-readiness.md`. The template predates some late-2026 rules;
add the compliance table from Phase 4 to it rather than relying on its older compliance section.

```markdown
## Launch Readiness Report: [Game Title] [version]
Target launch: [YYYY-MM-DD]  |  Report date: [YYYY-MM-DD]  |  Author: [name/role]
Platforms: [Steam, ...]  |  Launch type: [Full / Early Access / EA to 1.0]

### Executive summary
[Readiness state, biggest remaining risk, recommendation: GO / CONDITIONAL GO / NO-GO]

### Backplan
| Milestone | Lead time | Due | Status |
|---|---|---|---|
| Coming Soon page live | >= 2 weeks before release | [date] | [done/at risk] |
| Store page review | >= 7 business days | [date] | |
| Build review | >= 7 business days (plan 3 weeks) | [date] | |
| Next Fest | [edition or "skipped: reason"] | [date] | |
| IARC / platform ratings | at submission | [date] | |

### Phase status
| Phase | Status | Exceptions | Owner |
|---|---|---|---|
| 1 Build validation | Complete / With exceptions / Incomplete | | |
| 2 Storefront | | | |
| 3 Discoverability | | | |
| 4 Compliance | | | |
| 5 Day-one patch | | | |

### Compliance
| # | Item | Applies? | Status | Evidence |
|---|---|---|---|---|
| C1 | Steam AI disclosure | Yes: pre-generated textures, localization | Drafted | asset log rows 12-40 |
| C3 | EU AI Act Art. 50 | No: no AI interaction or runtime generation | N/A | design/systems/npc.md |
| ... | | | | |

### Blocking issues
| ID | Issue | Phase | Resolution path | ETA |
|---|---|---|---|---|

### Risk assessment
| Risk | Likelihood | Impact | Mitigation | Accepted by |
|---|---|---|---|---|

### Rollback and war room
- Revert path: [beta branch / previous build id]
- Pause or pull: [process and owner]
- Holding statement: [drafted text]
- Abort threshold: [criteria]
- On call: [names, channels, check-in times]

### Post-launch plan
- Cadence: [hotfix / content / major]
- Community owners: [channel: owner]
- Metrics and targets: [from playtest/demo data]
- Roadmap: [month 1, 2-3, 4-6, decision point]

### Decision: [GO / CONDITIONAL GO / NO-GO]
Conditions: [...]  |  Reasoning: [2-3 sentences]  |  Next steps: [...]
```

At the end, update `production/session-state/active.md` with the decision, the open blockers and
the next dated milestone, and set `phase` in `.gameforge/project.json` to `release` (or
`post-launch` once the game is out) if the user agrees.

## Optional Connectors

If the user has connected tools, use them only with their go-ahead: GitHub for release tags,
milestones and the hotfix PR flow; a document or task tool (Notion, Linear, Asana) to host the
checklist; email for press outreach drafts; chat (Slack, Discord) for war-room check-ins. Never send
press emails or post publicly without explicit approval of the final text.

## Quality Criteria

- Every phase addressed, including "not applicable" with a reason
- A dated backplan with platform lead times, not a generic timeline
- Every compliance row resolved with evidence; AI disclosures traceable to the asset log
- No unsourced statistics; market numbers carry their source and date
- Rollback tested and war room staffed with named people
- Post-launch plan exists before launch day
- A later post-mortem (`/gameforge:game-postmortem`) can reconstruct what was known at decision time

## Reference Files

- `${CLAUDE_SKILL_DIR}/references/storefront-requirements.md`: read before preparing store pages,
  demos, Next Fest entries or console and mobile submissions.
- `${CLAUDE_SKILL_DIR}/references/compliance-checklist.md`: read before Phase 4 or whenever the
  game uses AI content, live AI, monetization, chat, or ships to the EU or to children.
- `${CLAUDE_SKILL_DIR}/references/post-launch-ops.md`: read when planning cadence, community,
  metrics, refunds or the post-launch roadmap.

Related shared docs: `${CLAUDE_PLUGIN_ROOT}/docs/monetization-ethics.md` (pricing and in-game
purchases), `${CLAUDE_PLUGIN_ROOT}/docs/workflow-guide.md` (where launch sits in the lifecycle).
