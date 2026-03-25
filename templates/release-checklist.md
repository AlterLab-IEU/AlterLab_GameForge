# Release Checklist

> **Project:** [Working title]
> **Version:** [Release version, e.g., 1.0.0]
> **Target Release Date:** [Date]
> **Release Manager:** [Name]
> **Status:** [Pre-Alpha / Alpha / Beta / Release Candidate / Gold]

---

## 1. Build Verification

### Build Pipeline
- [ ] Build compiles without errors on all target platforms
- [ ] Build compiles without warnings (or all warnings are known and documented)
- [ ] Build size is within target budget: [X MB/GB per platform]
- [ ] Build versioning is correct and matches release tag
- [ ] Debug symbols are generated and archived for crash reporting
- [ ] Shipping/Release configuration is used (not Development/Debug)

### Platform Builds

| Platform | Build Status | Version | Size | Signed | Notes |
|----------|-------------|---------|------|--------|-------|
| [PC/Windows] | [ ] Built | [Version] | [Size] | [ ] Yes | |
| [PC/macOS] | [ ] Built | [Version] | [Size] | [ ] Yes | |
| [PC/Linux] | [ ] Built | [Version] | [Size] | [ ] Yes | |
| [Console 1] | [ ] Built | [Version] | [Size] | [ ] Yes | |
| [Console 2] | [ ] Built | [Version] | [Size] | [ ] Yes | |
| [Mobile/iOS] | [ ] Built | [Version] | [Size] | [ ] Yes | |
| [Mobile/Android] | [ ] Built | [Version] | [Size] | [ ] Yes | |

### Startup Validation
- [ ] Game launches without crash on all target platforms
- [ ] Loading screens display correctly
- [ ] First-time user experience (FTUE) / tutorial works end-to-end
- [ ] Save/load functions correctly (new save and existing save)
- [ ] Settings (graphics, audio, controls) persist between sessions

---

## 2. Test Coverage

### Automated Tests
- [ ] Unit tests passing: [X/Y tests, Z% coverage]
- [ ] Integration tests passing: [X/Y tests]
- [ ] Smoke tests passing on all target platforms
- [ ] No known flaky tests (or flaky tests are documented and excluded)

### Manual Testing

| Area | Tester | Status | Bugs Found | Blockers |
|------|--------|--------|-----------|----------|
| Core gameplay loop | [Name] | [ ] Complete | [Count] | [Count] |
| All levels / content | [Name] | [ ] Complete | [Count] | [Count] |
| UI / menus / HUD | [Name] | [ ] Complete | [Count] | [Count] |
| Save / load / progression | [Name] | [ ] Complete | [Count] | [Count] |
| Multiplayer (if applicable) | [Name] | [ ] Complete | [Count] | [Count] |
| Accessibility features | [Name] | [ ] Complete | [Count] | [Count] |
| Localization (all languages) | [Name] | [ ] Complete | [Count] | [Count] |
| Edge cases / stress testing | [Name] | [ ] Complete | [Count] | [Count] |

### Regression Testing
- [ ] All previously fixed bugs retested and confirmed fixed
- [ ] No regressions in core systems from last release candidate
- [ ] Full playthrough completed without blocker bugs

---

## 3. Performance Benchmarks

### Frame Rate

| Platform | Target FPS | Achieved FPS (avg) | Achieved FPS (min) | Status |
|----------|-----------|-------------------|-------------------|--------|
| [Platform 1] | [60 fps] | [X fps] | [Y fps] | [ ] Pass |
| [Platform 2] | [30 fps] | [X fps] | [Y fps] | [ ] Pass |
| [Platform 3] | [60 fps] | [X fps] | [Y fps] | [ ] Pass |

### Memory

| Platform | Memory Budget | Peak Usage | Status |
|----------|-------------|-----------|--------|
| [Platform 1] | [X GB] | [Y GB] | [ ] Pass |
| [Platform 2] | [X GB] | [Y GB] | [ ] Pass |

### Loading Times

| Scenario | Target | Achieved | Status |
|----------|--------|---------|--------|
| Initial launch to menu | [X seconds] | [Y seconds] | [ ] Pass |
| Menu to gameplay | [X seconds] | [Y seconds] | [ ] Pass |
| Level transition | [X seconds] | [Y seconds] | [ ] Pass |
| Save file load | [X seconds] | [Y seconds] | [ ] Pass |

### Stability
- [ ] No crashes in [X] hours of continuous play testing
- [ ] No memory leaks detected over extended sessions
- [ ] No hitches or freezes exceeding [X] ms during gameplay

---

## 4. Platform-Specific Requirements

### PC
- [ ] Minimum spec hardware tested and performing within targets
- [ ] Recommended spec hardware tested
- [ ] Graphics settings scale correctly (Low / Medium / High / Ultra)
- [ ] Resolution support: 720p through 4K verified
- [ ] Ultrawide (21:9) and super-ultrawide (32:9) supported (or gracefully handled)
- [ ] Keyboard + mouse controls fully functional
- [ ] Gamepad controls fully functional
- [ ] Key rebinding works correctly
- [ ] Steam / Epic / GOG integration tested (achievements, overlay, cloud saves)

### Console (per platform)
- [ ] Platform certification requirements reviewed and met
- [ ] Controller button prompts match platform conventions
- [ ] Suspend/resume functions correctly
- [ ] Platform-specific features work (Activity Cards, Quick Resume, etc.)
- [ ] TRC/TCR/Lotcheck requirements addressed

### Console Certification Timeline

| Platform | Typical Duration | Notes |
|----------|-----------------|-------|
| PlayStation | 2-3 weeks | |
| Xbox | 1-2 weeks | Faster with ID@Xbox program |
| Nintendo Switch | 2-4 weeks | |

### Mobile (if applicable)
- [ ] Touch controls responsive and well-sized
- [ ] Battery usage within acceptable range
- [ ] Background/foreground transitions handled
- [ ] Notification permissions handled correctly
- [ ] App store age rating requirements met

---

## 5. Store Assets

### Store Page

| Asset | Spec | Status | Approved |
|-------|------|--------|----------|
| Store icon | [Platform-specific size] | [ ] Created | [ ] Approved |
| Header/banner image | [Platform-specific size] | [ ] Created | [ ] Approved |
| Screenshots (minimum 5) | [Platform-specific resolution] | [ ] Created | [ ] Approved |
| Trailer video | [1080p minimum, [X] seconds] | [ ] Created | [ ] Approved |
| Store description (short) | [X characters max] | [ ] Written | [ ] Approved |
| Store description (long) | [Full description] | [ ] Written | [ ] Approved |
| Tags / categories | [Platform-specific] | [ ] Set | [ ] Approved |
| System requirements | [Min/Recommended specs] | [ ] Written | [ ] Approved |

### Store Asset Dimensions (Updated November 2024)

| Asset | Dimensions (px) |
|-------|-----------------|
| Steam Header Capsule | 920 x 430 |
| Steam Small Capsule | 462 x 174 |
| Steam Main Capsule | 1232 x 706 |
| Steam Vertical Capsule | 748 x 896 |
| Steam Hero Graphic | 3840 x 1240 |
| Steam Library Capsule | 600 x 900 |
| itch.io Cover | 630 x 500 (recommended) |

### Pricing
- [ ] Price set for all regions / storefronts
- [ ] Launch discount configured (if applicable): [X% off for Y days]
- [ ] Bundle pricing configured (if applicable)
- [ ] Regional pricing reviewed for purchasing power parity

---

## 6. Marketing Materials

- [ ] Press kit prepared (screenshots, logo, description, key art, team info)
- [ ] Review codes allocated and distribution plan ready
- [ ] Launch trailer finalized and scheduled for upload
- [ ] Social media launch posts drafted and scheduled
- [ ] Launch announcement blog post / newsletter drafted
- [ ] Influencer / streamer outreach completed
- [ ] Community Discord / forums prepared for launch traffic
- [ ] Patch notes for v1.0 written (if applicable)

---

## 7. Compliance & Ratings

- [ ] Age rating obtained: [ESRB: X / PEGI: X / USK: X / CERO: X / GRAC: X]
- [ ] Rating content descriptors reviewed and accurate
- [ ] Privacy policy published and linked in-game and on store page
- [ ] Terms of service published (if applicable)
- [ ] COPPA compliance verified (if applicable)
- [ ] GDPR compliance verified (data collection, consent, deletion)
- [ ] Accessibility statement published
- [ ] EULA reviewed and published (if applicable)
- [ ] Open-source license attributions included (if using OSS libraries)

### Regulatory Compliance

- [ ] **EAA:** EU Accessibility Act compliance verified (communication, e-commerce, distribution features)
- [ ] **CVAA:** Text/voice chat accessibility verified (if applicable)
- [ ] **COPPA:** Age verification and parental consent flow implemented (if targeting under 13)
- [ ] **PEGI 2026:** Rating impact assessed (loot boxes = 16+, NFTs = 18+, unmoderated chat = 18+)
- [ ] **IARC:** Age rating obtained through IARC for digital storefronts

### Accessibility (ESA AGI Tags)

- [ ] ESA Accessible Games Initiative tags selected (pick from 24 standardized tags)
- [ ] Top tags assessed:
  - [ ] Subtitle Options
  - [ ] Difficulty Options
  - [ ] Controller Remapping
  - [ ] Colorblind Mode
  - [ ] Screen Reader Support
  - [ ] One-Handed Play
  - [ ] Adjustable Game Speed
  - [ ] Visual Cues for Audio
  - [ ] Text Size Options

### AI Content Disclosure

- [ ] **Steam:** AI use disclosed for player-facing content
- [ ] **itch.io:** Generative AI content tagged (failure = potential delisting)
- [ ] AI Content Policy document completed (reference: `@templates/ai-content-policy.md`)
- [ ] Human creative contribution documented for copyright protection

---

## 8. Known Issues

[List all known issues shipping with this release. Be transparent.]

| ID | Severity | Description | Workaround | Fix Target |
|----|----------|------------|-----------|------------|
| [BUG-001] | [Critical/High/Medium/Low] | [Brief description] | [Workaround if any] | [Patch version] |
| [BUG-002] | [Severity] | [Description] | [Workaround] | [Target] |
| [BUG-003] | [Severity] | [Description] | [Workaround] | [Target] |

### Known Issue Policy
- **Zero critical bugs** at release
- **Maximum [X] high-severity bugs** at release, all with workarounds documented
- **Medium and low bugs** tracked for first post-launch patch

---

## 9. Day-One Patch Scope

### Planned for Day-One Patch

| Fix/Feature | Priority | Status | ETA |
|-------------|----------|--------|-----|
| [Fix description] | [Must / Should / Could] | [ ] In Progress | [Date] |
| [Fix description] | [Priority] | [ ] Status | [Date] |

### Day-One Patch Logistics
- [ ] Patch build pipeline tested
- [ ] Patch deployment process documented and tested on all platforms
- [ ] Patch size estimated: [X MB]
- [ ] Patch notes written
- [ ] Rollback plan documented in case patch introduces regressions

---

## 10. Go / No-Go Sign-offs

| Department | Lead | Decision | Date | Notes |
|-----------|------|----------|------|-------|
| Engineering | [Name] | [ ] Go / [ ] No-Go | [Date] | [Conditions or concerns] |
| Design | [Name] | [ ] Go / [ ] No-Go | [Date] | [Conditions or concerns] |
| Art | [Name] | [ ] Go / [ ] No-Go | [Date] | [Conditions or concerns] |
| Audio | [Name] | [ ] Go / [ ] No-Go | [Date] | [Conditions or concerns] |
| QA | [Name] | [ ] Go / [ ] No-Go | [Date] | [Conditions or concerns] |
| Production | [Name] | [ ] Go / [ ] No-Go | [Date] | [Conditions or concerns] |
| Marketing | [Name] | [ ] Go / [ ] No-Go | [Date] | [Conditions or concerns] |
| Business / Leadership | [Name] | [ ] Go / [ ] No-Go | [Date] | [Conditions or concerns] |

### Final Decision
- **Decision:** [ ] GO / [ ] NO-GO
- **Date:** [Date]
- **Decided by:** [Name / role]
- **Conditions (if conditional go):** [Any conditions that must be met before or immediately after launch]

---

## Post-Launch Monitoring Plan

- [ ] Crash reporting dashboard set up and monitored
- [ ] Player metrics dashboard set up (DAU, retention, progression funnel)
- [ ] Community channels monitored for bug reports (Discord, forums, social media)
- [ ] Hotfix process documented and team on standby for [X] days post-launch
- [ ] First scheduled patch date: [Date]
- [ ] Post-mortem meeting scheduled: [Date]
