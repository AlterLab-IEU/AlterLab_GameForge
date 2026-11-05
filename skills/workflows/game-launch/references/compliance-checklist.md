# Launch Compliance Checklist (snapshot 2026-11-05)

Each row: **applies when** (the test), **obligation**, **evidence to keep**, **owner**, **source**.
This is practical guidance for indie teams, not legal advice. Re-check every date against its source
before launch, and get counsel for the AI Act, privacy and EULA questions when money or children are
involved. Owners refer to GameForge roles; on a solo project they are all you.

## How to run it

1. Answer the intake risk flags (AI content, live AI, purchases, chat, EU, children).
2. Walk C1-C12 in order. Write "Applies: yes/no, because ..." for each.
3. For every "yes", record the evidence file path in the launch report's compliance table.
4. Hand AI-related rows (C1, C2, C3, C5, C9, C10) to the Creative Director for review of the final
   wording; hand C4 and C12 to `/gameforge:game-accessibility-specialist`; hand C6 monetization
   answers to `/gameforge:game-economy-designer`.

---

## C1. Steam AI disclosure (Content Survey)

- **Applies when:** generative AI produced content that ships with the game and is consumed by
  players (artwork, sound, narrative, localization and similar), or content on the store page or in
  marketing assets, or the game generates content with AI while it runs.
- **Exempt:** "AI powered tools" used for efficiency, such as code assistants (Valve's 2026-01-16
  rewrite, reported by Game Developer). Code written with Claude Code needs no Steam disclosure.
- **Two categories:**
  - *Pre-Generated:* content created with AI during development. Valve evaluates it like any other
    content; the Steam Distribution Agreement promise that the game contains no illegal or
    infringing content applies.
  - *Live-Generated:* content created while the game runs. Same rules, plus you must describe the
    guardrails that stop illegal content. Valve does not accept live-generated adult-only sexual
    content.
- **History:** disclosure required since January 2024; rewritten 2026-01-16. AI content is checked
  at pre-release review against what you declared.
- **Grey zones to decide deliberately:** AI-drafted store text that a human rewrote; AI upscaling or
  denoising of human art; AI placeholder assets. Placeholders that slip into the shipped build are
  the classic failure: the Indie Game Awards rescinded *Clair Obscur*'s awards in December 2025 over
  generative-AI placeholder textures that had been patched out. Grep the build for placeholder
  asset names before gold.
- **Evidence:** the asset provenance log `design/ai-asset-log.md` (tool, version, licence, date,
  where used, human edits), the disclosure draft from `/gameforge:game-ai-assets`, and the submitted
  survey text.
- **Owner:** Producer submits; Creative Director approves wording.
- **Source:** Steamworks "Content Survey" (accessed 2026-11-05); Game Developer, 2026-01-16.

## C2. Microsoft Store policy 11.16, Live Generative AI Content

- **Applies when:** the product contains dynamic content created by generative AI models in response
  to user input, sold on the Microsoft Store or Xbox-branded stores. Pre-generated assets are not
  covered by 11.16.
- **Obligations:** disclose live generative AI in the product metadata; note it in Partner Center
  during submission; keep generated content within all Store policies; provide a way for users to
  report inappropriate content to you, and act on reports.
- **Design implications:** an in-game report button on generated text or voice; a moderation queue;
  logs that let you reproduce a reported output; a kill switch that can disable live generation
  server-side.
- **Evidence:** metadata text, Partner Center note, report flow screenshots, moderation runbook.
- **Owner:** Technical Director (systems), UX Designer (report flow), Producer (submission).
- **Source:** Microsoft Store Policies v7.20 (updated 2026-09-14), sections 11.11 and 11.16.

## C3. EU AI Act, Article 50 (transparency)

- **Applies when:** the game is offered in the EU and (a) players interact with an AI system such as
  an LLM-driven NPC or companion, or (b) the game generates synthetic text, images, audio or video at
  runtime, or (c) the game presents AI-generated deepfakes of real people, places or events.
- **Dates:** obligations apply from **2026-08-02**. The Omnibus amendment (Regulation (EU) 2026/1744)
  gives only the Art. 50(2) marking duty a grace period, to **2026-12-02**, and only for generative
  systems already on the market before 2026-08-02. Detection-interoperability measures follow on
  2027-02-02. Not retroactive for media generated before 2026-08-02.
- **Obligations relevant to games:**
  - **50(1):** people must be told they are interacting with an AI system unless that is obvious to
    a reasonably well-informed player in context. The Commission's guidelines read the exception
    narrowly. Treating LLM NPCs as covered is the cautious reading: add a clear, in-fiction-friendly
    notice (settings screen, first-encounter tooltip, store page line).
  - **50(2):** providers of systems that generate synthetic content must mark outputs in a
    machine-readable way. If your game ships a runtime generator under your name, plan for marking
    (metadata or watermark on exported or shareable outputs). Source code is excluded.
  - **50(4):** deepfake disclosure; for evidently artistic, creative, satirical or fictional works it
    is limited to a notice that does not hamper display or enjoyment of the work.
- **Penalties:** up to EUR 15M or 3% of worldwide annual turnover.
- **Code of Practice and guidelines:** Code of Practice published 2026-06-10; final guidelines
  2026-07-20. Read them before designing the notice.
- **Evidence:** where and how the notice appears, marking approach, design doc for AI systems.
- **Owner:** Narrative Director and Game Designer (notice in fiction), Technical Director (marking),
  Producer (sign-off).
- **Source:** European Commission Article 50 FAQ (updated 2026-07-24); Reed Smith (2026-07-28);
  Cooley (2026-08-03); Article 50 text.

## C4. European Accessibility Act (EAA)

- **In force:** since **2025-06-28**.
- **Scope relevant to games:** consumer general-purpose computing hardware including consoles;
  e-commerce services (which is where in-game purchase flows are argued to fall); electronic
  communications services (the basis for arguments that in-game text or voice chat is covered).
  Games as such are not named in the Act.
- **Exemption:** microenterprises (fewer than 10 staff and annual turnover or balance sheet of no
  more than EUR 2M) are exempt for services.
- **Practical floor if in scope:** purchase flows and chat usable with keyboard or controller alone,
  readable contrast and scalable text, screen-reader-friendly purchase confirmation, captions or
  text alternatives for voice. EN 301 549 is the usual technical reference.
- **US counterpart:** the CVAA covers advanced communications in games (the FCC's video game waiver
  expired at the end of 2018): text and voice chat need accessible alternatives.
- **Owner:** Accessibility Specialist advises; Technical Director decides implementation.
- **Source:** European Commission EAA page; Travers Smith (2025-06-27).

## C5. US copyright and AI authorship

- **Rule:** copyright protects human authorship. The Copyright Office's Part 2 report (2025-01-29)
  says prompts alone are not enough; human selection, arrangement and modification of AI output can
  be protected. The Supreme Court denied certiorari in *Thaler v. Perlmutter* on 2026-03-02, leaving
  the human-authorship requirement in place.
- **Actions:** keep human-authored source files (layered art, project files, drafts) alongside AI
  outputs; log what a human changed; when registering a copyright, identify and disclaim
  AI-generated material that is more than de minimis.
- **Why it matters at launch:** you cannot enforce rights in content you do not own. Clone
  takedowns rely on your human-authored work.
- **Owner:** Producer.
- **Source:** US Copyright Office, "Copyright and AI" Part 2; Holland & Knight (Mar 2026).

## C6. Age ratings (IARC, store questionnaires, PEGI 2026 criteria)

- **IARC:** a free questionnaire inside participating storefronts' submission flows that issues
  ratings for member boards (ESRB, PEGI, USK, ClassInd, Australian Classification Board, GRAC and
  others) plus a generic rating elsewhere. Participating stores include Microsoft Store (Windows and
  Xbox), PlayStation Store, Nintendo eShop, Google Play, Epic Games Store and Meta Horizon Store.
  Microsoft Store policy 11.11 makes you responsible for accurate answers and for updating them when
  content changes.
- **Steam:** not an IARC store. The Content Survey's general section generates ratings for several
  regional boards; enter any official ratings you already hold.
- **Apple:** own questionnaire; tiers 4+, 9+, 13+, 16+, 18+ since July 2025; updated answers were
  required by 2026-01-31.
- **Japan:** CERO is not an IARC member; console releases there go through the platform holder and
  CERO.
- **PEGI criteria update:** announced 2026-03-12, applies to games submitted for classification from
  June 2026 (existing ratings stand). As reported: paid random items (loot boxes, card packs, gacha)
  default to PEGI 16 and can reach 18; time- or quantity-limited offers lead to PEGI 12; NFTs and
  blockchain mechanics lead to PEGI 18; reward-based login systems lead to PEGI 7; unrestricted
  communication can push a game to PEGI 18; spending controls that are off by default can lower some
  minimums. Read PEGI's published criteria before answering, because the rating now depends on
  monetization and social design, not only content.
- **Loot boxes elsewhere:** Belgium treats paid loot boxes as gambling; many games disable paid
  random items there. Design review: `${CLAUDE_PLUGIN_ROOT}/docs/monetization-ethics.md`.
- **Owner:** Producer submits; Economy Designer answers monetization questions; Game Designer
  answers content questions.

## C7. Children's privacy (COPPA and equivalents)

- **Applies when:** the game is directed to children under 13 in the US, or you have actual knowledge
  that you collect personal information from under-13 players. Cartoon art alone does not make a
  game child-directed, but audience, marketing and content together can.
- **Amended COPPA Rule:** published 2025-04-22, effective 2025-06-23, full compliance required since
  **2026-04-22**. Highlights: verifiable parental consent before collection; separate consent for
  disclosure to third parties that is not integral to the service; a written information security
  program; data retention limits; biometric identifiers count as personal information.
- **Other regimes:** GDPR age-of-consent rules in the EU (13-16 depending on member state), the UK
  Age Appropriate Design Code.
- **Actions:** decide the audience explicitly; if mixed audience, age-screen neutrally and switch
  off data collection and third-party ad SDKs for children.
- **Owner:** Producer, with the Technical Director for SDK audit.

## C8. Privacy, terms and store privacy labels

- Privacy policy whenever you collect anything (analytics, crash reports, accounts, cloud saves),
  reachable from the main menu and the store page: what is collected, why, who receives it, how long
  it is kept, how to request deletion.
- Apple privacy details and Google Play Data safety must match what your SDKs actually send. Audit
  the network traffic of the release build, not the SDK marketing page.
- EULA or terms for online features and user-generated content (ownership, moderation, termination).
- **Owner:** Producer; Technical Director for the SDK audit.

## C9. Licences and asset provenance

- Every third-party asset: music, SFX, fonts, textures, models, middleware, SDKs. Confirm commercial
  use, attribution, revenue thresholds, and redistribution terms.
- Open source: permissive licences (MIT, BSD) need notices; Apache-2.0 needs its NOTICE file; GPL
  code linked into the game imposes source obligations. Generate a third-party notices file.
- AI tools: check the licence of the model and of its outputs. As of November 2026, Hunyuan3D 2.1's
  licence does not apply in the EU, UK or South Korea (outputs included); TRELLIS.2 is MIT; Suno and
  Udio output remains legally unsettled while UMG and Sony litigation against Suno continues.
  Details and current tool licences: `/gameforge:game-ai-assets`.
- No ripped, decompiled or "inspired by" assets from existing games. Publishers do send takedowns
  (Activision issued DMCA takedowns against AI-built browser ports in October 2026).
- **Evidence:** credits screen, notices file, provenance log.
- **Owner:** Art Director and Audio Director for their assets; Producer signs off.

## C10. Voice performers and synthetic voice

- The SAG-AFTRA 2025 Interactive Media Agreement (ratified 2025-07-09) requires informed consent and
  disclosure for digital voice replicas, with a reasonably specific description of each use and
  usage reports to performers. It binds signatory productions; for everyone else it is the
  reputational baseline.
- Text-to-speech replacing performers draws backlash even when licensed: *ARC Raiders* re-recorded
  many TTS lines with actors after criticism.
- **Owner:** Audio Director.

## C11. Mobile build and policy floors

- Apple: Xcode 26 and iOS 26 SDK required for uploads since 2026-04-28. Guideline 2.5.2 (executing
  downloaded code) puts in-game creation tools that run user code at risk.
- Google Play: target API 36 (Android 16) for new apps and updates since 2026-08-31. The
  AI-Generated Content policy applies to generative features.
- **Owner:** Technical Director.

## C12. Accessibility statement and store tags

- Publish what the game supports and what it does not. Honest and partial beats invented.
- ESA Accessible Games Initiative: 24 standardized tags announced 2025-03-20 (founding members EA,
  Google, Microsoft, Nintendo of America, Ubisoft). Xbox shows them on store pages, lets players
  filter by them, and audits them.
- Reference: Game Accessibility Guidelines; `${CLAUDE_PLUGIN_ROOT}/templates/accessibility-audit.md`.
- **Owner:** Accessibility Specialist; UX Designer.

---

## Platforms without public AI rules (as of 2026-11-05)

PlayStation and Nintendo publish no AI-specific store rule; Epic Games Store has none found either.
Absence of a public rule is not permission: content rules and partner agreements still apply. Keep
the same provenance evidence for every platform so you can answer if asked.

## Disclosure drafting template

```markdown
### AI use disclosure: [Game title] [version]
Code: written with AI coding assistants (not disclosable on Steam; listed here for transparency).
Pre-generated content:
- [Category, e.g. ambient background textures in chapters 2-3]: generated with [tool], then
  repainted by [role]. Ships in game: yes. Store page: no.
- [Category, e.g. machine translation for PT-BR and TR]: [tool] draft, reviewed by native speakers.
Live-generated content: [none | NPC dialogue via [model] with guardrails: system prompt limits,
  blocklist, output classifier, report button, server kill switch].
Player-facing notice (EU Art. 50(1)): [where it appears, exact text].
Evidence: design/ai-asset-log.md rows [ids]; survey text archived in production/releases/.
```

Adapt the same facts to each store's form; keep them consistent across stores.
