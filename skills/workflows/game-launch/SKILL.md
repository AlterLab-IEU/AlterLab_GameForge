---
name: "game-launch"
description: >
  Use when the user asks about "launch preparation", "release checklist", "store submission",
  "go/no-go decision", "day-one patch", "launch readiness", or needs to manage the full
  pre-release pipeline from final build to public availability. Part of the AlterLab GameForge collection.
---

# AlterLab GameForge -- Pre-Release Launch Pipeline

The distance between "done" and "launched" is longer than most teams expect. A game that is feature-complete, bug-free, and fun can still fail at launch because the store page was not optimized, the press kit was missing, the age rating was not filed, or the day-one patch pipeline was not tested. This workflow is an exhaustive, phase-gated checklist that ensures nothing falls through the cracks between your final build and the moment players can buy and play your game. Every phase has a clear completion gate, and the final go/no-go decision is made with full visibility into remaining risks.

### Purpose & Triggers

**Invoke this workflow when:**
- The game is entering the final milestone before release and a structured launch plan is needed
- A storefront submission deadline is approaching and the team needs to verify all requirements are met
- Marketing assets need to be prepared and coordinated across platforms
- Legal and compliance requirements (age ratings, privacy policies, licenses) need auditing
- The team needs a go/no-go framework for making the launch decision
- A soft launch or early access release is being planned (same process, adjusted scope)
- Post-launch support infrastructure needs to be established before launch day

**Do NOT use this workflow when:**
- The game is still in active development with significant features incomplete (finish building first)
- You are launching an internal playtest build (use `game-playtest` instead)
- The game is a game jam submission with no commercial intent (streamline to just build validation)

### Critical Rules

1. **Every phase is gated.** Do not advance to the next phase until the current phase is signed off. Skipping a phase to save time is how launches implode.
2. **Storefronts are not optional.** Even if the game is technically ready, a store page that is missing screenshots, has a vague description, or uses the wrong tags will kill discoverability. The store page IS the game's first impression.
3. **Legal compliance is not a suggestion.** Missing an age rating, an open-source license attribution, or a privacy policy can result in the game being pulled from a storefront post-launch. This is a catastrophic outcome that is entirely preventable.
4. **Plan for failure.** The launch plan must include a rollback strategy. If something goes catastrophically wrong on launch day, what do you do? If the answer is "panic," your launch plan is incomplete.
5. **Day-one patches are expected, not shameful.** Between going gold and launch day, new issues will be found. Plan for a day-one patch pipeline from the start. The question is not "will we need one?" but "how fast can we deploy one?"
6. **Reference `docs/game-design-theory.md`** for player psychology considerations in storefront presentation and first-time user experience.

### Workflow

**Phase 1: Build Validation**

This is the final technical gate. The game must be provably stable, performant, and complete before any launch activities begin.

**Clean Build Verification:**
- Perform a clean build from source control on a machine that has never built the project before. This catches missing dependencies, local-only files, hardcoded paths, and environment-specific configurations.
- Verify that the build process is documented and reproducible. A build that only one person on the team can create is a single point of failure.
- Confirm the build version string is correct and matches the intended release version.
- If the game has a launcher or auto-updater, verify it points to the correct update servers.

**Automated Test Suite:**
- All unit tests passing: zero failures, zero skipped (unless permanently excluded with documented reason).
- All integration tests passing: game systems interact correctly.
- All platform-specific tests passing: each target platform builds and runs without platform-specific failures.
- Smoke tests for critical paths: new game start, save/load cycle, all main menu options, final boss completion, credits roll.

**Performance Validation:**
- Frame rate meets target on minimum specification hardware. Test on actual min-spec hardware, not a developer workstation set to reduced settings.
- Load times are within budget. First load, level transitions, and respawn times should all be measured and logged.
- Memory usage stays within platform limits across a full play session. Run a 2+ hour continuous play session and track memory allocation. If memory grows monotonically, there is a leak.
- Disk space usage is within platform limits (particularly relevant for console and mobile).
- Network performance (if applicable): latency, bandwidth usage, reconnection handling.

**Bug Triage:**
- Zero P0 bugs (game-breaking: crashes, data loss, progression blockers).
- Zero P1 bugs (severe: major features broken, significant visual glitches, frequent soft locks).
- All P2 bugs (moderate) reviewed and either fixed or explicitly accepted as shippable with documented reasoning.
- P3 bugs (minor: cosmetic issues, edge cases) catalogued for day-one patch consideration.

**Save/Load Integrity:**
- Save files created on the release build load correctly.
- Save files from the most recent public build (if applicable, for early access) migrate correctly.
- Corrupted save file handling: the game recovers gracefully, does not crash, and informs the player.
- Cloud save synchronization works across devices (if applicable).

**Extended Play Session:**
- One team member plays the complete game start-to-finish on the release build. This catches issues that only manifest in long play sessions: memory leaks, cumulative state corruption, softlocks from unusual player choices.
- Record the full session and note any anomalies, even minor ones.

**Phase 1 Gate:** All automated tests pass. Zero P0/P1 bugs. Performance within budget on target hardware. Extended play session completed without critical issues.

---

**Phase 2: Storefront Requirements**

Each storefront has specific asset requirements. Missing or non-compliant assets will delay submission or cause rejection.

**Steam:**
- Store page header capsule image (460x215, 231x87 for small capsule)
- Large capsule image (616x353)
- Hero graphic (3840x1240) for top of store page
- Capsule artwork for library (600x900)
- At least 5 screenshots (1280x720 minimum, 1920x1080 recommended). These should be curated moments that communicate the core experience -- not random gameplay captures.
- At least one gameplay trailer (60-90 seconds, embedded or YouTube link)
- Store description: hook paragraph, feature list, system requirements. Write this as marketing copy, not a design document. Lead with the emotional experience, not the feature list.
- Tag selection: choose tags that match your game accurately. Mis-tagging for visibility backfires when players expecting genre X find genre Y.
- System requirements (minimum and recommended): test these on actual hardware that matches the stated specs.
- Review/community settings: configure discussion boards, review visibility, and beta branch settings.
- Steamworks integration: achievements, cloud saves, trading cards (if applicable), Remote Play Together (if applicable).
- Coming Soon page should be live at least 2 weeks before launch for wishlist accumulation.

**itch.io:**
- Page banner image (630x500 recommended)
- At least 3 screenshots
- Cover image for browse pages (315x250)
- Short description (1-2 sentences for browse) and long description (full page)
- Pricing configuration (paid, PWYW, free)
- Download file upload with platform labels (Windows, macOS, Linux)
- Community settings (comments, devlog, forum)

**Mobile -- App Store (iOS):**
- App icon (1024x1024, no transparency, no rounded corners -- Apple applies the rounding)
- Screenshots for every supported device size (iPhone 6.7", 6.5", 5.5"; iPad Pro 12.9", 11")
- App preview video (15-30 seconds, optional but strongly recommended)
- App name (30 character limit), subtitle (30 character limit), keywords (100 characters total)
- App description (4000 character limit, first 3 lines are critical since the rest is hidden behind "more")
- Privacy policy URL (mandatory)
- Age rating questionnaire (Apple's proprietary system)
- App Store Connect configuration: pricing, availability, in-app purchases, subscription groups

**Mobile -- Google Play Store:**
- App icon (512x512 PNG, 32-bit with alpha)
- Feature graphic (1024x500) for store feature placement
- Screenshots: minimum 2, maximum 8, at least one for each supported form factor (phone, tablet)
- Short description (80 characters), full description (4000 characters)
- Content rating questionnaire (IARC-based)
- Privacy policy URL (mandatory)
- Data safety section: declare all data collection, storage, and sharing practices
- Target API level must meet Google's current minimum requirement (check annually -- this changes)

**Console -- First-Party Certification:**
- **PlayStation (TRC)**: Technical Requirements Checklist. Covers controller behavior, system software interaction, trophy implementation, save data handling, network features. Allow 2-4 weeks for Sony QA review.
- **Xbox (XR)**: Xbox Requirements. Covers achievement implementation, rich presence, controller input, accessibility features. Allow 2-4 weeks for Microsoft certification.
- **Nintendo Switch (Lotcheck)**: Nintendo's compliance testing. Covers button prompts matching controller layout, handheld/docked mode switching, sleep mode handling. Allow 2-4 weeks for Nintendo review.
- All console submissions should be preceded by a pre-certification internal audit against the published requirements checklist.

**Phase 2 Gate:** All storefront assets prepared and reviewed. All submission requirements met per platform. Store pages drafted and reviewed by at least two people (one for accuracy, one for marketing effectiveness).

---

**Phase 3: Marketing Asset Checklist**

These assets should be prepared in parallel with Phase 2 but are tracked separately because they serve different distribution channels.

**Press Kit:**
- Fact sheet: game title, developer, publisher (if applicable), release date, platforms, price, one-sentence description, 100-word description, key features (5-7 bullet points)
- Key art: at minimum the game's primary promotional image at the highest resolution available (300 DPI for print, 72 DPI for web, both versions)
- Screenshot pack: 10-15 curated screenshots showing variety (gameplay, exploration, combat, narrative, environments). Organize by theme. Include both HUD-on and HUD-off versions.
- GIF captures: 3-5 short loops (5-10 seconds each) showing satisfying game moments. These are critical for social media and messaging platforms where video autoplay is unreliable.
- Logo pack: game logo in full color, white, and black versions. SVG or high-res PNG with transparency. Include the developer/studio logo.
- Team bio: short description of the studio, team size, notable previous work, contact information for press inquiries
- All assets should be downloadable from a single URL (Google Drive, Dropbox, or a dedicated press page on the studio website)

**Trailer Production:**
- **Gameplay trailer** (60-90 seconds): shows actual gameplay, not cinematic renders. Players want to see what they will experience. Lead with the most visually impressive or mechanically unique moment. End with a clear call-to-action (release date, platforms, wishlist/pre-order link).
- **Launch trailer** (30-60 seconds): shorter, more emotionally impactful, designed for social media. Can use a mix of gameplay and cinematic moments. Optimized for autoplay-without-audio (use text overlays for key messages).
- **Platform-specific trailers**: some platforms (Steam, App Store, Nintendo eShop) have specific requirements for trailer format, resolution, and content restrictions. Verify before uploading.

**Social Media Launch Assets:**
- Launch announcement posts drafted for each platform (Twitter/X, Instagram, TikTok, Reddit, Discord, YouTube Community)
- Hashtag strategy: primary game hashtag, genre hashtag, event hashtags (if launching during a festival)
- Community notification plan: Discord announcement, mailing list, Steam update post
- Launch day posting schedule: coordinate timing across platforms for maximum reach

**Press Outreach:**
- Press/media list: minimum 50 relevant outlets, YouTubers, streamers, and journalists. Prioritize those who cover your genre.
- Review code distribution: prepare Steam keys, console codes, or direct builds for press. Use a key management service (Keymailer, Woovit, or manual spreadsheet tracking).
- Embargo management: set a clear embargo date and communicate it explicitly. Standard practice is to lift the embargo 1-3 days before launch to allow reviews to publish and drive wishlists.
- Press outreach email: personalized (not mass-blast), concise, includes a press kit link, key/code, and embargo date. Send 2-3 weeks before launch.

**Phase 3 Gate:** Press kit complete and hosted. All trailers produced and uploaded. Social media posts drafted and scheduled. Press outreach initiated with embargo communicated.

---

**Phase 4: Compliance and Legal**

This phase is non-negotiable. Skipping or deferring compliance tasks creates legal liability and storefront removal risk.

**Age Rating:**
- **ESRB** (North America): submit content questionnaire through ESRB's online tool. Processing time: typically 1-3 business days for digital-only releases. Required for major storefronts selling in the US.
- **PEGI** (Europe): submit through the IARC (International Age Rating Coalition) portal. Most digital storefronts use IARC for automated PEGI ratings.
- **CERO** (Japan): required for any release in Japan. Longer processing time (2-4 weeks). Submit well in advance.
- **USK** (Germany): handled through IARC for digital releases.
- Retain rating certificates for all regions where the game will be sold.

**Accessibility Statement:**
- Document the accessibility features the game supports: remappable controls, colorblind modes, subtitle options, screen reader support, difficulty options, motor accessibility settings.
- Reference WCAG 2.1 AA guidelines and the Game Accessibility Guidelines (gameaccessibilityguidelines.com).
- Be honest about what is NOT supported. An incomplete but honest accessibility statement is far better than a fabricated comprehensive one.

**Privacy Policy:**
- Mandatory for any game that collects ANY data (including analytics, crash reports, cloud saves, or account creation).
- Must specify: what data is collected, how it is used, who it is shared with, how long it is retained, and how players can request deletion (GDPR right to erasure).
- Must be accessible from within the game (typically linked from the settings or main menu).
- If the game targets players under 13 (ESRB E or E10+), COPPA compliance is mandatory (parental consent for data collection).

**EULA / Terms of Service:**
- Required for online-enabled games. Recommended for all commercial releases.
- Cover: license grant, restrictions, limitation of liability, dispute resolution, termination conditions.
- If the game has user-generated content, the EULA must address content ownership and moderation rights.

**Copyright and License Verification:**
- Audit ALL third-party assets: music, sound effects, fonts, middleware, textures, models.
- Verify license terms for every asset: is commercial use permitted? Is attribution required? Are there revenue thresholds?
- Check all middleware licenses: physics engines, networking libraries, UI frameworks, analytics SDKs. Some have per-title or revenue-based licensing.
- Open-source license compliance: if the game uses any open-source code, verify license obligations. MIT and BSD are permissive. GPL requires source code disclosure. Apache 2.0 requires a NOTICE file.
- Create a credits screen or text file that includes all required attributions.

**Phase 4 Gate:** All age ratings obtained. Privacy policy published and accessible in-game. EULA reviewed by someone with legal knowledge (ideally a lawyer). All third-party assets verified for license compliance. Credits complete.

---

**Phase 5: Day-One Patch Planning**

The build you submit for certification or storefront review is almost never the build players will experience on day one. Between submission and launch, issues will be found. Plan for this.

**Known Issues List:**
- Compile a list of every known issue that shipped in the gold build. Categorize by severity and player visibility.
- Mark which issues will be addressed in the day-one patch and which are accepted as-is (with reasoning).
- This list is also valuable for community management -- if players report a known issue on launch day, the support team can respond immediately with "We're aware of this and a fix is included in the day-one patch."

**Day-One Patch Scope:**
- Define the patch contents BEFORE launch, not reactively on launch day.
- Typical day-one patch scope: bug fixes found during certification period, final balance tuning based on late playtests, localization corrections, last-minute performance optimizations.
- Do NOT use the day-one patch to add features. Feature additions belong in a post-launch update, not a patch.
- Test the day-one patch through the same validation process as the gold build (Phase 1, abbreviated). A day-one patch that introduces new bugs is worse than no patch.

**Hotfix Process:**
- Establish the emergency hotfix pipeline: code fix, build, test, deploy. What is the minimum time from "critical bug reported" to "fix live on all platforms"?
- For PC (Steam): hotfixes can typically be deployed within hours. Document the process for pushing a Steam build update.
- For console: hotfixes must go through certification (abbreviated fast-track process if the issue is severe). Know each platform's expedited certification process and contact.
- For mobile: App Store review can take 24-48 hours. Google Play is typically faster (hours). Factor this into your response time estimates.
- Designate who has authority to approve an emergency hotfix deployment. This should not require a full team meeting -- one decision-maker with 24/7 availability on launch week.

**Monitoring Infrastructure:**
- Crash reporting: integrate a crash reporting service (Sentry, Backtrace, Crashlytics, or engine-native). Verify it is active in the release build.
- Analytics: basic telemetry for player progression, session length, and drop-off points. This data is invaluable for post-launch balance tuning and content planning.
- Community sentiment tracking: monitor Steam reviews, social media mentions, Discord activity, and Reddit posts. Assign a community manager or team member to this role for launch week.
- Server monitoring (if applicable): dashboard for player count, server load, error rates, and latency. Alert thresholds configured for anomalous behavior.

**Phase 5 Gate:** Known issues list complete. Day-one patch scoped and tested. Hotfix pipeline tested end-to-end (deploy a test patch to a staging environment). Monitoring infrastructure active and verified.

---

**Phase 6: Go/No-Go Decision**

This is the final gate. The launch decision is made collectively with full visibility into the state of every prior phase.

**Checklist Review:**
- Each phase owner presents their completion status: fully complete, complete with exceptions (list them), or incomplete (list blockers).
- All exceptions are reviewed and explicitly accepted or escalated.
- Any incomplete phase is a potential launch blocker. The team must agree that the risk of launching with the incomplete item is acceptable.

**Risk Assessment:**
Evaluate the following risk categories:

| Risk Category | Question | Impact if Realized |
|--------------|----------|-------------------|
| Technical | Could the game crash on common hardware configurations? | Reviews destroyed. Refund spike. |
| Performance | Could frame rate drop below acceptable on min-spec? | Negative first impressions. Steam review bombing. |
| Content | Is there offensive, misleading, or missing content? | PR crisis. Storefront removal. |
| Legal | Are there unresolved licensing or compliance issues? | DMCA takedown. Legal liability. |
| Server (if applicable) | Could launch-day traffic overwhelm infrastructure? | Players unable to play. Refund requests. |
| Marketing | Is the game discoverable on the storefront? | Low sales despite game quality. |

For each risk, assign likelihood (Low/Medium/High) and impact (Low/Medium/High). Any High-High risk should be a launch blocker unless explicitly accepted by the team lead.

**Rollback Plan:**
Define what happens if launch goes catastrophically wrong:
- Can the storefront listing be taken down temporarily? What is the process?
- Can a broken build be reverted to the previous version? How quickly?
- Who communicates with players? What is the messaging? Draft a template post for "we are aware of issues and are working on a fix."
- At what point is a launch "aborted" versus "rough but proceeding"? Define the threshold.

**Launch Day War Room:**
- Designate who is on-call for launch day and the 48 hours following. Cover all time zones if the team is distributed.
- Establish communication channels: primary (Slack/Discord channel), escalation (phone calls), and public (social media, community forums).
- Define the escalation path: who makes the call to deploy a hotfix? Who makes the call to pull the build?
- Schedule check-in points: launch +1 hour, +4 hours, +12 hours, +24 hours, +48 hours. At each check-in, review crash reports, player feedback, sales data, and server health.

**The Decision:**
- **GO**: All phases complete (or complete with explicitly accepted exceptions). No High-High risks. Rollback plan in place. War room staffed.
- **CONDITIONAL GO**: Launch proceeds but with specific conditions. Example: "GO, contingent on the day-one patch deploying successfully by 6 AM launch day." Define what happens if the condition is not met.
- **NO-GO**: One or more launch blockers remain unresolved. Identify the new target date and the path to resolution. Communicate the delay transparently -- a delayed game that launches well is remembered more fondly than a rushed game that launches broken.

### Output Format

```
## Launch Readiness Report: [Game Title]
## Target Launch Date: [YYYY-MM-DD]
## Report Date: [YYYY-MM-DD]
## Report Author: [Name/Role]

### Executive Summary
[3 sentences: Overall readiness state, biggest remaining risk, recommendation (GO/CONDITIONAL GO/NO-GO)]

### Phase Completion Status

| Phase | Status | Exceptions | Owner |
|-------|--------|-----------|-------|
| 1. Build Validation | Complete / With Exceptions / Incomplete | [list] | [name] |
| 2. Storefront Requirements | Complete / With Exceptions / Incomplete | [list] | [name] |
| 3. Marketing Assets | Complete / With Exceptions / Incomplete | [list] | [name] |
| 4. Compliance & Legal | Complete / With Exceptions / Incomplete | [list] | [name] |
| 5. Day-One Patch | Complete / With Exceptions / Incomplete | [list] | [name] |

### Blocking Issues
| ID | Issue | Phase | Severity | Resolution Path | ETA |
|----|-------|-------|----------|----------------|-----|
| L1 | [desc] | [phase] | Blocker | [plan] | [date] |

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation | Accepted? |
|------|-----------|--------|-----------|-----------|
| [risk] | H/M/L | H/M/L | [plan] | Y/N |

### Rollback Plan
- Build reversion process: [description]
- Storefront takedown process: [description]
- Public communication template: [drafted message]
- Abort threshold: [criteria]

### War Room Configuration
- On-call team: [names and roles]
- Communication channels: [primary, escalation, public]
- Check-in schedule: [times]
- Escalation path: [who decides what]

### Decision: [GO / CONDITIONAL GO / NO-GO]
**Conditions (if CONDITIONAL GO):** [list]
**Reasoning:** [2-3 sentences]
**Next Steps:** [immediate action items]
```

### Quality Criteria

- **Phase completeness**: Every phase has been addressed, even if the conclusion is "not applicable to this project" (with reasoning).
- **No hand-waving**: Every exception and every accepted risk is explicitly documented with reasoning. "We'll figure it out" is not a valid entry in a launch readiness report.
- **Rollback plan tested**: The rollback plan is not theoretical -- it has been tested in a staging environment. A rollback plan that has never been executed is a hope, not a plan.
- **War room staffed**: Every critical function (engineering, community management, platform relations) has a named individual on-call with confirmed availability.
- **Legal verification complete**: No third-party asset remains unverified. No compliance requirement remains unmet. Zero ambiguity in this area.
- **Decision traceability**: The go/no-go decision can be traced back to specific completion states and risk assessments. A future post-mortem should be able to reconstruct exactly what was known at decision time.

### Example Use Cases

1. "Our indie game is feature-complete and we want to launch on Steam in 6 weeks. Walk me through the full launch pipeline and help me build a timeline."
2. "We're submitting to the App Store for the first time. What are the specific requirements we need to meet, and what are the common rejection reasons to avoid?"
3. "Our game launches next Friday and we just found a significant bug. Help me evaluate whether this is a launch blocker or a day-one patch item."
4. "We need to prepare a press kit for our upcoming release. What should be in it and how should it be organized?"
5. "We're debating whether to delay our launch by two weeks to fix remaining bugs or ship on time with a day-one patch. Help me frame this as a go/no-go decision with a proper risk assessment."
