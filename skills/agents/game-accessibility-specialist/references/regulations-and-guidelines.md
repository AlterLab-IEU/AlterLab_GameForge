# Regulations, Standards, and Store Declarations (Accessibility Specialist reference)

Snapshot: November 2026. This maps regulation to design work; it is not legal advice. Before any
compliance sign-off, re-check the status of the standard versions below (WebFetch the official
source) and record the date. Items marked **UNVERIFIED** must not be stated as fact.

---

## 1. European Accessibility Act (Directive (EU) 2019/882)

**In force since 2025-06-28.** Applies to listed products placed on the EU market and listed services
provided to EU consumers.

**How games come into scope** -- games are not named as a category. Scope arrives through:
| Route | What it covers in a game business | Typical features affected |
|---|---|---|
| Consumer computer hardware, operating systems, and interactive terminal equipment (product categories) | Consoles and their system software (the hardware maker's obligation) | Platform-level; matters for console makers, not most indies |
| E-commerce services | Selling to consumers online, including **in-game purchase flows** and storefronts you operate | Store screens, checkout, price and product information, account steps in the purchase |
| Electronic communication services | The basis for arguments that **in-game text, voice, and video chat** are covered | Chat UI, real-time text, voice-to-text |

**Microenterprise exemption**: enterprises with **fewer than 10 persons and annual turnover or balance
sheet total of at most EUR 2 million** are exempt from the requirements **for services** (such as
e-commerce). The exemption does not cover products. A three-person studio selling its own in-game
store is likely exempt for that service; a 12-person studio is not.

**Enforcement**: by national market surveillance authorities; penalties are set per member state.
Do not quote specific fine amounts without the member state's current law.

**Presumption of conformity -- EN 301 549**
- **V3.2.1 (2021)**, built on WCAG 2.1 Level AA, is the version currently cited.
- **V4.1.1** was published on **2026-09-02**. It adopts WCAG 2.2 Level AA plus additional criteria and
  updated real-time communication requirements. It carries presumption of conformity only once cited
  in the Official Journal; Deque (2026-09-08) reported it on track for citation around 2026-11-30,
  and Ireland's National Disability Authority gave 2026-12-16. Check before signing off.
- Meeting WCAG 2.2 AA alone does not satisfy V4.1.1.

**What auditors look at in a game's purchase flow (practical mapping)**
- [ ] Every purchase step operable by keyboard and controller; focus order logical; focus visible
- [ ] Prices, contents, and totals available as text (not only in images), readable by screen readers
- [ ] Text scalable; contrast sufficient; no information by color alone
- [ ] Time limits on offers or checkout adjustable or not essential
- [ ] Errors identified in text with recovery instructions
- [ ] Accessibility information about the service published (store page or website)

---

## 2. United States

- **CVAA** (21st Century Communications and Video Accessibility Act): advanced communications services
  in games -- text chat, voice chat, video chat, in-game messaging -- must be accessible to people
  with disabilities unless not achievable. No communication features, no CVAA scope.
  Typical requirements: text-to-speech for text chat, speech-to-text for voice chat, accessible UI for
  every communication feature, visual indicators of who is speaking.
- **ADA and Section 508**: case law on websites and apps continues; game-specific obligations are
  unsettled. Treat store websites and account portals as in scope for good practice.

---

## 3. Other regions (high level)

| Region | Instrument | Note |
|---|---|---|
| UK | Equality Act 2010 | Duty to make reasonable adjustments for service providers |
| Canada | Accessible Canada Act | Federally regulated sectors; game-specific scope limited |
| Australia | Disability Discrimination Act 1992 | Complaint-based |

---

## 4. Xbox Accessibility Guidelines (XAG)

Version 3.2, published 2023-06-08 (page maintained through 2026). Microsoft describes them as best
practices for designers, guardrails for developers, and a checklist for test teams -- **not a checklist
for compliance or legal requirements**. Use them as the design standard; do not call them a legal bar.

| # | Guideline | # | Guideline |
|---|---|---|---|
| 101 | Text display | 113 | UI focus handling |
| 102 | Contrast | 114 | UI context |
| 103 | Additional channels for visual and audio cues | 115 | Error messages and destructive actions |
| 104 | Subtitles and captions | 116 | Time limits |
| 105 | Audio accessibility | 117 | Visual distractions and motion settings |
| 106 | Screen narration | 118 | Photosensitivity |
| 107 | Input | 119 | Speech-to-text and text-to-speech |
| 108 | Game difficulty options | 120 | Communication experiences |
| 109 | Objective clarity | 121 | Accessible feature documentation |
| 110 | Haptic feedback | 122 | Accessible customer support |
| 111 | Audio description | 123 | Mental health best practices |
| 112 | UI navigation | | |

Key numbers (XAG 101 and 104): console text 26 px at 1080p and 52 px at 4K; PC 18 px and 36 px;
mobile 18 px at 100 DPI, 36 px at 200 DPI, 72 px at 400 DPI; scaling to 200%; subtitles at most two
lines of about 40 characters; background opacity adjustable 0-100%.

---

## 5. Game Accessibility Guidelines

A free, widely used developer reference (gameaccessibilityguidelines.com) organized as **basic**
(low effort, wide reach), **intermediate**, and **advanced** guidance across motor, cognitive,
vision, hearing, speech, and general categories. For indie scope: ship every applicable basic item,
then choose intermediate items by genre. XAG pages link to GAG items as resources.

---

## 6. Store accessibility declarations

| Store / initiative | What it is | Status (Nov 2026) |
|---|---|---|
| **Steam** | Accessibility-features questionnaire in Steamworks (store page Basic Info, "Accessibility Feature Wizard"); features show on the store page and in search filters | Live since June 2025; optional but recommended; options chosen from Valve's list |
| **Accessible Games Initiative** (ESA) | 24 standardized accessibility tags with criteria (accessiblegames.com), e.g. clear text, large and clear subtitles, narrated menus, stick inversion, save anytime | Launched 2025-03-20 at GDC; founding members EA, Google, Microsoft, Nintendo of America, Ubisoft; voluntary for publishers and storefronts |
| **Apple Accessibility Nutrition Labels** | Per-device declarations in App Store Connect shown on product pages | Announced May 2025; Apple says they will become required for new apps and updates, with no date announced |
| **Xbox store** | Uses accessibility feature tags aligned with the initiative | Check Partner Center for the current list |

Rules for every declaration: only features that work in the shipped build, verified by QA with the
named assistive technology; re-verify after each major patch.

---

## 7. Related obligations that touch accessibility

- **EU AI Act Art. 50(1)** (from 2026-08-02): AI NPCs must be disclosed unless obvious. The disclosure
  UI must be perceivable and operable by everyone (screen reader, scaling, controller access).
- **Age ratings and photosensitivity**: provide an accurate photosensitivity warning; test intense
  sequences against the three-flashes threshold (WCAG 2.3.1) and fix rather than only warn.

---

## 8. Sources to re-check before sign-off

- European Commission, EAA page (commission.europa.eu, search "European Accessibility Act")
- EN 301 549 status: Deque blog (2026-09-08), National Disability Authority Ireland, the Commission's
  list of harmonised standards
- Xbox Accessibility Guidelines: learn.microsoft.com/gaming/accessibility/guidelines
- Steamworks: partner.steamgames.com/doc/accessibility_features
- Accessible Games Initiative: accessiblegames.com
- Apple: App Store Connect Help, "Overview of Accessibility Nutrition Labels"
