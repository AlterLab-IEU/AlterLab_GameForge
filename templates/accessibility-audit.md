# Accessibility Audit

> **Project:** [Working title]
> **Version:** [Build version tested]
> **Last Updated:** [Date]
> **Auditor:** [Name / role]
> **Status:** [Initial Audit / In Progress / Remediation / Passed]
> **Target Compliance:** [Minimum viable / Good / Platinum -- see Section 7]
> **Platforms:** [PC / PlayStation / Xbox / Switch / Mobile / VR]

---

## How to Use This Template

This audit covers four disability categories, platform-specific requirements, legal compliance, and a priority matrix for implementation. It is designed to be used at three milestones:

1. **Pre-production**: Review the full checklist and decide which accommodations to support. Mark items as "Planned," "Stretch," or "Not Applicable."
2. **Beta**: Audit the build against all planned items. Mark items as "Implemented," "Partial," or "Missing."
3. **Pre-release**: Final verification. All "Planned" items must be "Implemented" or have documented justification for deferral.

**Reference points** (publicly documented): The Last of Us Part II (Naughty Dog, 2020) shipped with more than 60 accessibility settings, grouped into vision, hearing and motor presets (Naughty Dog, PlayStation Blog, June 2020). Celeste (2018) shows how much one well-designed Assist Mode (game speed, invincibility, extra stamina and dashes) can do for a small team's game. Forza Horizon 5 (Playground Games) added picture-in-picture ASL and BSL interpreters to its cutscenes in a March 2022 update (announced on Xbox Wire, November 2021).

**Core principle**: Accessibility is not charity. It is design quality. Every accommodation listed below improves the experience for players with and without disabilities. Subtitles benefit noisy environments. Colorblind modes help in bright sunlight. Remappable controls let everyone find their comfort.

---

## 1. Motor Accessibility

Accommodations for players with limited mobility, dexterity, or fine motor control.

### 1.1 Control Remapping

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| [ ] Full button/key remapping for all inputs | [Planned / Implemented / N/A] | **Critical** | Players must be able to remap every game action |
| [ ] Separate remapping profiles for gameplay and menus | [Status] | High | Menu navigation and gameplay may need different layouts |
| [ ] Multiple saved control profiles | [Status] | Medium | Allow switching between configurations |
| [ ] Default alternative layouts (left-handed, one-handed) | [Status] | High | Pre-built layouts reduce setup friction |
| [ ] No unmappable hardcoded keys | [Status] | **Critical** | Every input must be remappable without exception |

### 1.2 Input Flexibility

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| [ ] Toggle vs. hold option for all sustained inputs (sprint, aim, crouch) | [Status] | **Critical** | Holding buttons is a barrier for many motor disabilities |
| [ ] Adjustable input sensitivity (analog sticks, mouse) | [Status] | High | |
| [ ] Adjustable dead zones for analog inputs | [Status] | High | |
| [ ] Input buffering (queued actions accepted slightly before/after timing window) | [Status] | High | Reduces precision requirements |
| [ ] Adjustable rapid-press/mash requirements (or auto-mash toggle) | [Status] | **Critical** | Button mashing is impossible for many players |
| [ ] Auto-run / auto-move option | [Status] | Medium | Reduces sustained input requirements |
| [ ] Touch/click target size minimum (44x44dp for touch, generous click targets for mouse) | [Status] | High | Small targets are a barrier |

### 1.3 Aim and Combat Assists

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| [ ] Auto-aim / aim assist (adjustable strength) | [Status] | High | Essential for players who cannot aim precisely |
| [ ] Lock-on targeting system | [Status] | High | Alternative to manual aiming |
| [ ] Auto-target nearest enemy option | [Status] | Medium | Reduces aiming requirement entirely |
| [ ] Adjustable combat timing windows | [Status] | Medium | Parry/dodge windows can be widened |
| [ ] One-button combo / simplified combat mode | [Status] | Medium | Keep the fantasy, drop the execution demand |

### 1.4 Navigation Assists

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| [ ] Skip platforming / traversal challenge option | [Status] | Medium | Content accessibility -- do not gatekeep story behind motor skill |
| [ ] Auto-platforming / assisted navigation mode | [Status] | Medium | Comparable to steering and braking assists in racing games |
| [ ] Adjustable movement speed | [Status] | Medium | |
| [ ] Path guidance / breadcrumb system | [Status] | Low | Assists with navigation without removing challenge |

---

## 2. Visual Accessibility

Accommodations for players who are blind, have low vision, or have color vision deficiency.

### 2.1 Colorblind Modes

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| [ ] Protanopia filter/mode (red-green, ~1% of males; the milder protanomaly is another ~1%) | [Status] | **Critical** | Reds read as dark: test red warnings and health bars |
| [ ] Deuteranopia filter/mode (red-green, ~1% of males; the milder deuteranomaly is ~5%) | [Status] | **Critical** | Deutan types are the most common color vision deficiency overall |
| [ ] Tritanopia filter/mode (blue-yellow; tritan types are rare, on the order of 1 in 30,000-50,000 people) | [Status] | High | Rare but still necessary |
| [ ] Color is never the sole information channel | [Status] | **Critical** | Always pair color with shape, pattern, text, or position |
| [ ] Customizable UI colors (enemy/ally/neutral indicators) | [Status] | High | Let players define their own color scheme |
| [ ] Colorblind-safe default palette used throughout | [Status] | High | Design for colorblind players from the start, not as a filter |

Prevalence figures are for inherited color vision deficiency in men of Northern European descent (about 8% in total), per Colour Blind Awareness (colourblindawareness.org).

### 2.2 Low Vision Support

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| [ ] Scalable UI text (minimum 2x scaling option) | [Status] | **Critical** | 100% to 200% at minimum |
| [ ] Scalable HUD elements | [Status] | High | Not just text -- icons, health bars, minimaps |
| [ ] High-contrast mode (UI and gameplay elements) | [Status] | High | Distinct outlines, reduced visual noise |
| [ ] High-contrast subtitle background | [Status] | **Critical** | White text on dark background with opacity control |
| [ ] Adjustable screen magnification | [Status] | Medium | Useful for detailed UI interaction |
| [ ] Default text at or above XAG 101 minimums (26 px on console and 18 px on PC at 1080p, measured as body height), with a sans-serif option | [Status] | High | Avoid decorative fonts for gameplay-critical text |
| [ ] Item/interactable highlighting (glow, outline, ping) | [Status] | High | Helps low-vision players find interactive elements |
| [ ] Minimap with adjustable size and zoom | [Status] | Medium | |

### 2.3 Blind and Screen Reader Support

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| [ ] Screen reader support for all menus and UI | [Status] | High | Platform screen readers (Narrator, VoiceOver, TalkBack) |
| [ ] Audio description for cutscenes | [Status] | Medium | Narrated description of visual action |
| [ ] Audio cues for all visual-only information (enemy position, item pickups, environmental hazards) | [Status] | High | Essential for players who cannot see the screen |
| [ ] Text-to-speech for in-game text (chat, item descriptions, quest text) | [Status] | Medium | |
| [ ] Haptic/audio-only navigation mode | [Status] | Low | Full blind accessibility -- aspirational for most games |

---

## 3. Auditory Accessibility

Accommodations for players who are deaf or hard of hearing.

### 3.1 Subtitles and Captions

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| [ ] Subtitles for all spoken dialogue | [Status] | **Critical** | Non-negotiable baseline |
| [ ] Closed captions for gameplay-relevant sounds (footsteps, gunfire direction, environmental hazards) | [Status] | High | Distinct from subtitles -- captions describe sounds, not speech |
| [ ] Speaker identification in subtitles (name labels, color coding) | [Status] | High | "ELENA: We need to go" not just "We need to go" |
| [ ] Subtitle size options (small, medium, large) | [Status] | **Critical** | |
| [ ] Subtitle background/letterbox options (transparent, semi-opaque, opaque) | [Status] | High | |
| [ ] Subtitle font options or guaranteed readable default | [Status] | Medium | |
| [ ] Subtitle timing and display duration options | [Status] | Medium | Some players read slower |

### 3.2 Visual Sound Indicators

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| [ ] Visual directional indicators for off-screen sounds (enemy footsteps, gunfire, alerts) | [Status] | **Critical** | The HUD equivalent of spatial audio |
| [ ] Visual indicator for music mood/intensity changes | [Status] | Medium | Music often communicates danger or safety to hearing players |
| [ ] Screen flash or visual pulse for rhythm-based gameplay | [Status] | High | If audio timing matters, provide a visual equivalent |
| [ ] Chat-to-text for multiplayer voice chat | [Status] | High | If game has voice chat |

### 3.3 Audio Alternatives

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| [ ] Haptic/vibration feedback as alternative to audio cues | [Status] | High | Controller rumble can substitute for sound effects |
| [ ] Independent volume controls (master, music, SFX, voice, UI) | [Status] | **Critical** | Baseline audio design -- not an accessibility feature, just good design |
| [ ] Mono audio option | [Status] | High | Players deaf in one ear need all audio in both channels |
| [ ] Visual metronome for rhythm-based mechanics | [Status] | Medium | |

---

## 4. Cognitive Accessibility

Accommodations for players with cognitive disabilities, learning differences, ADHD, anxiety disorders, or who simply prefer a less demanding experience.

### 4.1 Difficulty and Pacing

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| [ ] Multiple difficulty levels (minimum 3) | [Status] | **Critical** | Celeste: Assist Mode. The Last of Us Part II: granular difficulty sliders |
| [ ] Granular difficulty sliders (combat, puzzles, navigation, timers separately) | [Status] | High | Do not force a single axis of difficulty |
| [ ] No content gated behind difficulty level | [Status] | **Critical** | Story and areas should be accessible at all difficulty levels |
| [ ] Adjustable game speed | [Status] | High | Celeste's Assist Mode includes game speed slider |
| [ ] Pause available at any moment (including cutscenes) | [Status] | High | |
| [ ] Timer extensions or timer removal options | [Status] | High | Timed challenges are a significant barrier |
| [ ] Skip combat / puzzle option | [Status] | Medium | Controversial but important for narrative-focused players |

### 4.2 Guidance and Clarity

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| [ ] Clear, persistent objective markers | [Status] | High | Player always knows what to do next |
| [ ] Quest/objective log accessible at all times | [Status] | High | |
| [ ] Waypoint/navigation system | [Status] | Medium | Optional, togglable |
| [ ] Tutorial replay / reference available from pause menu | [Status] | High | Players forget -- let them re-learn |
| [ ] Consistent iconography (same icon always means the same thing) | [Status] | **Critical** | |
| [ ] Tooltips and contextual help for all UI elements | [Status] | High | |
| [ ] Simplified UI mode (reduce visual clutter, hide non-essential HUD) | [Status] | Medium | |

### 4.3 Content Sensitivity

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| [ ] Content warnings for potentially triggering material (flashing lights, gore, spiders, body horror) | [Status] | High | |
| [ ] Photosensitivity mode (reduce or eliminate flashing/strobing effects) | [Status] | **Critical** | Epilepsy is a medical risk, not a preference |
| [ ] Arachnophobia mode / phobia-sensitive alternatives | [Status] | Medium | Grounded (Obsidian, 2020) ships an arachnophobia setting that changes how its spiders look |
| [ ] Motion sickness reduction options (reduced camera shake, FOV slider, motion blur toggle) | [Status] | High | |
| [ ] FOV slider (for 3D games) | [Status] | High | 60-120 range minimum (rule of thumb) |
| [ ] Screen shake intensity slider (including off) | [Status] | High | |

### 4.4 Reading and Comprehension

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| [ ] Text-to-speech for UI text and menus | [Status] | Medium | |
| [ ] Dyslexia-friendly font option (OpenDyslexic or similar) | [Status] | Medium | |
| [ ] Adjustable text speed for auto-advancing dialogue | [Status] | High | |
| [ ] Manual advance option for all dialogue (no auto-advance by default) | [Status] | High | |
| [ ] Simple/plain language option for complex game systems | [Status] | Low | |

---

## 5. Platform-Specific Requirements

### 5.1 Xbox Accessibility Guidelines (XAGs)

Microsoft's Xbox Accessibility Guidelines (version 3.2, June 2023) are best-practice guidance, not Xbox certification requirements: Microsoft states they are not intended as a checklist for any compliance or legal requirement. They are the most detailed platform-holder guidance available and worth meeting on every platform. Certification requirements live in each platform's partner documentation.

| XAG Category | Guideline | Status | Notes |
|-------------|-------------|--------|-------|
| Text display (XAG 101) | Default text at least 26 px on console and 18 px on PC/VR at 1080p (52 px and 36 px at 4K), scalable to 200% | [Status] | Measured as body height: ascender to descender |
| Contrast (XAG 102) | 4.5:1 for standard text and important visuals, 3:1 for large text, 7:1 in a high-contrast mode | [Status] | |
| Color independence | No information conveyed by color alone | [Status] | |
| Screen narration | All UI elements navigable by screen reader | [Status] | Use the platform's narrator APIs where available |
| Input | Full remapping, toggle/hold options, copilot support | [Status] | Xbox Copilot allows two controllers on one profile |
| Difficulty | Multiple options that do not gatekeep content | [Status] | |
| Photosensitivity (XAG 118) | No flashes more than about three per second over about 20% or more of the screen (including saturated-red flashes), and no high-contrast striped patterns | [Status] | Remove triggers; a warning screen is not a substitute |
| Audio | Independent volume channels, visual sound indicators | [Status] | |
| Subtitles | Available, resizable, speaker-identified, backgrounded | [Status] | |

**Reference**: [Xbox Accessibility Guidelines](https://learn.microsoft.com/gaming/accessibility/guidelines)

### 5.2 PlayStation Accessibility

| Requirement | Status | Notes |
|-------------|--------|-------|
| System-level accessibility feature support (text-to-speech, zoom, high contrast) | [Status] | PS5 system features must function in-game |
| DualSense haptic accessibility (option to reduce/disable) | [Status] | |
| Adaptive controller support | [Status] | Access controller (PS5) compatibility |
| Subtitle and caption standards (TRC requirements) | [Status] | |
| Button assignment flexibility | [Status] | System-level remapping exists, but in-game is preferred |

### 5.3 Nintendo Switch

| Requirement | Status | Notes |
|-------------|--------|-------|
| Handheld mode text legibility (Switch: 720p on a 6.2-7" screen; Switch 2: 1080p, 7.9") | [Status] | Text must be readable on the small handheld screen |
| Joy-Con single-handed play support | [Status] | If applicable to your input scheme |
| Touch input alternatives (handheld mode) | [Status] | |
| Pro Controller and adaptive controller support | [Status] | |
| Lotcheck accessibility requirements | [Status] | Review Nintendo's current requirements |

### 5.4 PC

| Requirement | Status | Notes |
|-------------|--------|-------|
| Keyboard-only play (full game completable without mouse for navigation/menus) | [Status] | |
| Mouse-only play (where genre-appropriate) | [Status] | |
| Full key rebinding (no hardcoded keys) | [Status] | |
| Resolution scaling (720p to 4K, ultrawide support) | [Status] | |
| UI scaling independent of resolution | [Status] | |
| Steam Input API support (enables hardware-agnostic controller remapping) | [Status] | |
| Screen reader compatibility (NVDA, JAWS, Narrator) | [Status] | |

### 5.5 Mobile (If Applicable)

| Requirement | Status | Notes |
|-------------|--------|-------|
| VoiceOver (iOS) / TalkBack (Android) support | [Status] | |
| Dynamic Type / system font size scaling | [Status] | |
| Switch Access / external controller support | [Status] | |
| Touch target minimum 44x44 points (iOS) / 48x48 dp (Android) | [Status] | |
| Reduced motion support (system preference) | [Status] | |

---

## 6. Legal Compliance

### 6.1 European Accessibility Act (EAA)

In force since **2025-06-28**. Games are not named as a category, but these parts of a game business are in scope:

- **Consumer computing hardware, including consoles** (obligations fall on the hardware maker).
- **E-commerce services**, which covers storefronts and **in-game purchase flows** sold to EU consumers (store screens, currency purchases, checkout, receipts).
- **Electronic communications services**: the basis for arguments that in-game text and voice chat are covered. This reading is contested; get advice if chat is central to your game.
- **Microenterprise exemption:** businesses with fewer than 10 staff and an annual turnover or balance sheet of at most EUR 2 million are exempt for **services** (not for products).
- **Standard:** EN 301 549 V4.1.1, the first version written for the EAA, was published by ETSI, CEN and CENELEC on 2026-09-02. It gives a presumption of conformity only once it is cited in the Official Journal of the EU, which had not happened as of early November 2026. Check the Official Journal before relying on it; until then, auditing against WCAG 2.1 AA (the basis of V3.2.1) is the practical baseline for menus, store and chat UI.

This is practitioner guidance, not legal advice.

| Requirement | Status | Notes |
|-------------|--------|-------|
| Perceivable: information presented in ways all users can perceive | [Status] | Text alternatives, captions, scalable text |
| Operable: UI navigable by all users | [Status] | Keyboard/controller navigation, no timing-dependent-only interaction |
| Understandable: information and UI operation is understandable | [Status] | Clear language, consistent navigation, error prevention |
| Robust: content interpretable by assistive technologies | [Status] | Screen reader compatibility, semantic UI structure |
| Purchase flow accessible end to end (store, currency purchase, confirmation) | [Status] | E-commerce scope; skip if the game sells nothing in-game |
| Accessibility information published for in-scope services | [Status] | How the service meets the requirements, in plain language |

**Risk assessment**: [Low / Medium / High -- based on distribution channels and EU audience size]

### 6.2 Communications and Video Accessibility Act (CVAA)

US law requiring advanced communications services (including in-game text and voice chat) to be accessible.

| Requirement | Applicability | Status | Notes |
|-------------|-------------|--------|-------|
| Text chat accessible via screen reader | [If game has text chat] | [Status] | |
| Voice chat accessible via text-to-speech / speech-to-text | [If game has voice chat] | [Status] | |
| UI for communication features accessible | [If game has social features] | [Status] | |
| Waiver on file (if applicable) | [If claiming undue burden] | [Status] | FCC rules provide waivers and an achievability defense; confirm with counsel before relying on either |

### 6.3 Store Labels and Warnings

| Item | Consideration | Status |
|-------------|----------------------------|--------|
| Photosensitive seizure warning | Shown before play and in store text; it supplements, never replaces, removing triggers (XAG 118) | [Status] |
| ESA Accessible Games Initiative | Select from the 24 standardized accessibility tags (launched March 2025) where storefronts display them | [Status] |
| Storefront accessibility fields | Fill in each store's accessibility-feature declarations where offered | [Status] |

### 6.4 Regional Requirements Summary

| Region | Key Regulation | Deadline | Impact | Action |
|--------|---------------|----------|--------|--------|
| EU | European Accessibility Act | 2025-06-28 (in force) | Consoles, e-commerce incl. in-game purchase flows, electronic communications; microenterprise exemption for services | Audit store, purchase and chat UI (Section 6.1) |
| US | CVAA (Section 255/716) | In effect | Communication features must be accessible | Audit chat/voice systems |
| US (state) | Various state laws | Varies | General disability and consumer-protection laws may apply | Monitor legislative landscape |
| UK | Equality Act 2010 | In effect | Reasonable adjustments for disabled users | Risk assessment for UK distribution |
| Canada | Accessible Canada Act | Phased (2025-2040) | Federal accessibility standards | Monitor regulations |
| Australia | Disability Discrimination Act | In effect | Complaint-based enforcement | Risk assessment |

---

## 7. Priority Matrix

### 7.1 Impact vs. Effort Ratings

Rate each accommodation category by player impact and implementation effort.

| Accommodation | Player Impact | Effort | Priority Tier | Notes |
|--------------|--------------|--------|--------------|-------|
| Subtitles (with customization) | Very High | Low | **Tier 1: Ship with** | About 15% of US adults report some trouble hearing (NIDCD) |
| Remappable controls | Very High | Medium | **Tier 1: Ship with** | Affects all motor-impaired players |
| Colorblind modes | High | Low-Medium | **Tier 1: Ship with** | About 8% of males of Northern European descent |
| Independent volume controls | High | Low | **Tier 1: Ship with** | Basic audio design |
| Toggle vs. hold options | High | Low | **Tier 1: Ship with** | Trivial to implement, large impact |
| Photosensitivity mode | Very High (medical) | Medium | **Tier 1: Ship with** | Seizure risk = must-ship |
| Difficulty options | Very High | Medium | **Tier 1: Ship with** | Broadest audience impact |
| Text scaling | High | Medium | **Tier 1: Ship with** | Low vision is common |
| High-contrast mode | High | Medium | **Tier 2: Target** | Meaningful for low vision |
| Screen reader support (menus) | High | High | **Tier 2: Target** | Important but technically complex |
| Auto-aim / aim assist | Medium-High | Medium | **Tier 2: Target** | Genre-dependent importance |
| Closed captions (sound descriptions) | Medium-High | Medium | **Tier 2: Target** | Beyond subtitles -- sound identification |
| One-handed play mode | Medium | High | **Tier 2: Target** | Affects specific population |
| Game speed adjustment | Medium | Low-Medium | **Tier 2: Target** | Part of Celeste's Assist Mode |
| Dyslexia-friendly font | Medium | Low | **Tier 3: Stretch** | Easy to add, moderate impact |
| Audio description for cutscenes | Medium | High | **Tier 3: Stretch** | Requires narration recording |
| Full blind accessibility | Medium | Very High | **Tier 3: Stretch** | Aspirational for most genres |
| Sign language cutscene interpretation | Low-Medium | Very High | **Tier 3: Stretch** | Forza Horizon 5 added ASL/BSL interpreters in 2022 |

### 7.2 Tier Definitions

| Tier | Meaning | Standard |
|------|---------|----------|
| **Tier 1: Ship with** | Must be in the launch build. No exceptions. | Minimum viable accessibility |
| **Tier 2: Target** | Planned for launch, acceptable in Day-1 patch if necessary | Good accessibility |
| **Tier 3: Stretch** | Plan for post-launch updates if not achievable at launch | Platinum accessibility |

---

## 8. Testing Methodology

### 8.1 Testing by Category

| Category | Testing Method | Tools | Who Tests |
|----------|---------------|-------|-----------|
| Motor | Play full game with one hand, play with limited inputs, test all remapping | Adaptive controller, Xbox Copilot, switch access device | QA + accessibility consultant |
| Visual (colorblind) | Apply colorblind simulation filters, verify all information has non-color channels | Color Oracle (free, desktop), Coblis (web), engine colorblind simulation | QA + colorblind testers |
| Visual (low vision) | Test at minimum resolution, maximum UI scale, with screen magnifier | Platform magnifier, ZoomText, test at 720p on 24"+ monitor | QA + low vision testers |
| Visual (blind) | Navigate all menus with screen reader, attempt gameplay with audio only | NVDA (free, Windows), VoiceOver (macOS/iOS), TalkBack (Android) | Blind accessibility tester |
| Auditory | Play entire game with audio muted, verify all information has visual channel | Mute all audio, remove headphones | QA (anyone can do this) |
| Cognitive | Play without reading any text (icon comprehension), test all difficulty options | Fresh tester unfamiliar with genre, test on easiest settings | QA + fresh testers |
| Photosensitivity | Run Harding Test or PSE analysis on all content with flashing/strobing | Harding FPA (industry standard), manual frame analysis | Specialized QA or third-party service |

### 8.2 Automated Testing Tools

| Tool | Purpose | Cost | Platform |
|------|---------|------|----------|
| [Accessibility Insights](https://accessibilityinsights.io) | UI accessibility testing (web-based tools/menus) | Free | Windows, Web |
| Color Oracle | Desktop colorblind simulation | Free | Windows, macOS, Linux |
| NVDA | Screen reader for Windows | Free | Windows |
| Harding FPA | Photosensitive epilepsy analysis | Paid | Professional |
| WAVE | Web accessibility evaluation (for web-based game UI) | Free | Web |
| Contrast Checker | WCAG contrast ratio verification | Free | Web |

### 8.3 Expert Testing

Automated tools and internal QA catch structural issues. Players with actual disabilities catch experiential issues. Both are necessary.

| Source | What They Provide | How to Engage |
|--------|------------------|---------------|
| AbleGamers Charity | Player panels, accessibility review, INCLUDIFICATION framework | [ablegamers.org](https://ablegamers.org) -- apply for review |
| SpecialEffect | Accessibility consultation, custom controller solutions | [specialeffect.org.uk](https://specialeffect.org.uk) |
| Can I Play That | Accessibility reviews and consulting | [caniplaythat.com](https://caniplaythat.com) |
| Game Accessibility Guidelines | Comprehensive reference checklist | [gameaccessibilityguidelines.com](https://gameaccessibilityguidelines.com) |
| Disabled player communities | Direct feedback from the audience | Reddit r/disabledgamers, accessibility-focused Discord servers |

---

## 9. Audit Summary

### 9.1 Scorecard

| Category | Tier 1 Items | Implemented | Tier 2 Items | Implemented | Tier 3 Items | Implemented |
|----------|-------------|------------|-------------|------------|-------------|------------|
| Motor | [X] | [Y] / [X] | [X] | [Y] / [X] | [X] | [Y] / [X] |
| Visual | [X] | [Y] / [X] | [X] | [Y] / [X] | [X] | [Y] / [X] |
| Auditory | [X] | [Y] / [X] | [X] | [Y] / [X] | [X] | [Y] / [X] |
| Cognitive | [X] | [Y] / [X] | [X] | [Y] / [X] | [X] | [Y] / [X] |
| Platform | [X] | [Y] / [X] | [X] | [Y] / [X] | [X] | [Y] / [X] |
| Legal | [X] | [Y] / [X] | [X] | [Y] / [X] | [X] | [Y] / [X] |
| **Total** | **[X]** | **[Y] / [X]** | **[X]** | **[Y] / [X]** | **[X]** | **[Y] / [X]** |

### 9.2 Overall Compliance Level

- [ ] **Minimum Viable**: All Tier 1 items implemented
- [ ] **Good**: All Tier 1 + all Tier 2 items implemented
- [ ] **Platinum**: All Tier 1 + Tier 2 + Tier 3 items implemented

### 9.3 Outstanding Issues

| Item | Category | Tier | Blocker? | Remediation Plan | Target Date |
|------|----------|------|----------|-----------------|-------------|
| [Item] | [Motor / Visual / etc.] | [1/2/3] | [Yes/No] | [Plan] | [Date] |
| [Item] | [Category] | [Tier] | [Y/N] | [Plan] | [Date] |
| [Item] | [Category] | [Tier] | [Y/N] | [Plan] | [Date] |

### 9.4 Sign-Off

| Role | Name | Approved | Date | Conditions |
|------|------|----------|------|------------|
| UX Designer | [Name] | [ ] Yes / [ ] No | [Date] | [Any conditions] |
| QA Lead | [Name] | [ ] Yes / [ ] No | [Date] | [Any conditions] |
| Producer | [Name] | [ ] Yes / [ ] No | [Date] | [Any conditions] |
| External Accessibility Reviewer | [Name/org] | [ ] Yes / [ ] No | [Date] | [Any conditions] |
