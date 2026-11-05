# Monetization Regulatory Landscape -- Snapshot 2026-11-05

Load this before auditing a monetization design for compliance, choosing regions, or answering
"can we ship this loot box / battle pass / currency in market X?". This is a designer's map, not
legal advice: it tells you where the risk is so you can brief counsel well. Dates were checked
against official releases, court and regulator statements, or law-firm summaries on 2026-11-05.
Where sources disagree, the entry says so.

---

## 1. Design defaults that survive almost every regime

If you adopt these, most of the table below becomes a checklist instead of a redesign:
1. **No paid random items.** Sell known items directly; use earned-only randomness.
2. If you must sell randomness: publish odds per item before purchase, add hard pity, allow
   direct purchase with real money (not only via virtual currency), and gate it behind age
   assurance where minors can play.
3. **Show real-money prices** next to every virtual-currency price; sell currency in amounts
   that match item prices (no forced leftovers).
4. **Spending off by default for minors**, enabled by a parent; per-day and per-month caps.
5. **No countdown pressure on paid offers** and no penalties for missing sessions.
6. **Accessible purchase flows** (the European Accessibility Act covers e-commerce, including
   in-game purchase flows, for businesses above the microenterprise threshold).
7. **Clear pre-purchase information and withdrawal rights** for EU players.

---

## 2. Age ratings

| Body | Rule (effective) | Design impact |
|---|---|---|
| **PEGI** (Europe) | Announced 2026-03-12; applies to games **submitted from June 2026** (existing ratings unchanged): paid random items (loot boxes, card packs, gacha, paid keys) default to a **PEGI 16** minimum; social casino may be PEGI 18 case by case; time- or quantity-limited offers (including paid battle passes with countdowns) **PEGI 12** minimum, reducible to PEGI 7 when spending is disabled by default and a parent must enable it; play-pressure mechanics (daily quests, login streaks) **PEGI 7**, rising to **PEGI 12** if missing a session removes content or progress; required, tradeable NFT/blockchain items **PEGI 18**; unrestricted communication with no reporting or blocking tools **PEGI 18**. | For an indie aiming at PEGI 7 or 12, paid randomness is effectively off the table, and timers and streak penalties have a rating cost. Check PEGI's official criteria document before submission; press summaries differ in detail. |
| **ESRB** (North America) | "In-Game Purchases (Includes Random Items)" interactive-element notice since 2020. | Notice only, no rating change. |
| **Australian Classification** | From **2024-09-22**: games with in-game purchases linked to chance (paid loot boxes) get a minimum **M** (advisory); games with simulated gambling get a minimum **R18+** (legally restricted). Applies to games classified from that date. | Social casino mechanics are adults-only in Australia. |
| **IARC** (digital storefronts) | Questionnaire answers about random paid items and gambling simulation propagate to multiple regional ratings at once. | Answer consistently with the design doc. |

---

## 3. Regions

| Region | Status | Notes |
|---|---|---|
| **Belgium** | Belgian Gaming Commission's 2018 analysis treats paid loot boxes as illegal gambling. | Publishers removed paid loot boxes or blocked sales for Belgian players; enforcement has been documented as inconsistent. Do not rely on lax enforcement. |
| **Netherlands** | The Council of State ruled on **2022-03-09** that FIFA Ultimate Team packs were not a separate game of chance and annulled the regulator's penalty order against EA. | Case-by-case; tradeable items with real-money value remain the highest-risk design. |
| **European Union** | **CPC Network Key Principles on in-game virtual currencies** (March 2025, non-binding interpretation of existing consumer law, issued alongside action against *Star Stable Online*): show prices in real money; do not obscure costs by mixing currencies or forcing exchanges; let players buy only the currency they need; give clear pre-purchase information including the 14-day withdrawal right where it applies; plain-language terms; account for vulnerable players and children with protective defaults. **Digital Fairness Act**: the Commission's July 2025 call for evidence flagged loot boxes, pay-to-win and virtual currencies; a proposal was reported (trade press) as scheduled for 2026-11-11 and had **not been published** as of 2026-11-05. **AI Act Article 50** applies since 2026-08-02 (relevant to live-AI features). **European Accessibility Act** in force since 2025-06-28 (purchase flows; microenterprise exemption for services). | Design to the CPC principles now; they are what enforcement will cite. Re-check DFA status before launch: a European Parliament report on protecting minors online called for banning loot boxes and in-game currencies in games likely accessed by minors, but the Commission's proposal text is unknown. |
| **United Kingdom** | Industry-led: Ukie's 11 principles on paid loot boxes (July 2023), including restricting under-18 purchases without parental consent and odds disclosure. The government said it would review effectiveness; no statutory loot box regulation was found as of 2026-11-05. | Researchers have reported widespread non-compliance with the principles; regulation remains possible. |
| **United States** | **FTC v. Epic Games** (Dec 2022): US$245M for dark patterns in purchase flows (plus a separate COPPA penalty). **FTC v. Cognosphere (HoYoverse, *Genshin Impact*)**, announced **2025-01-17**: US$20M penalty; block under-16 purchases without parental consent; disclose odds; stop selling loot boxes only for virtual currency without a real-money option. **COPPA Rule amendments**: effective 2025-06-23, most obligations enforceable from **2026-04-22**. No federal loot box statute. | The FTC acts through unfairness, deception and children's privacy law; purchase-flow UX and odds honesty are enforcement targets. |
| **Brazil** | **Lei 15.211/2025 (ECA Digital)**, signed 2025-09-17, in force **March 2026** (most sources: 2026-03-17): prohibits loot boxes in games aimed at or likely to be accessed by minors. Decree 12,880/2026 reportedly lets publishers offer loot-box-free versions to minors or disable the features by default. Penalties reported up to R$50M or 10% of Brazilian revenue. | Major publishers added age verification for Brazil. Sources differ on whether parental consent can unlock loot boxes for minors; assume it cannot. |
| **China** | Probability disclosure for paid random items required since 2017; minors' play time restricted (2021 rules: one hour on Fridays, weekends and holidays) and spending capped; real-name registration. | Publishing requires a licensed local partner. |
| **South Korea** | Game Industry Promotion Act amendment in force **2024-03-22**: probabilities shown on the purchase screen, for domestic and foreign companies; a 2025 amendment added punitive damages (reported up to three times the damage) from August 2025. | Regulators found 266 violating games in the first months (Game World Observer, July 2024). |
| **Japan** | "Complete gacha" (kompu gacha) treated as an illegal premium by the Consumer Affairs Agency since 2012; industry guidelines require probability disclosure. | Avoid collect-the-set paid mechanics entirely. |

---

## 4. Platform rules that behave like law

| Platform | Rule |
|---|---|
| Apple App Store | Apps offering loot boxes or other paid randomized items must disclose the odds before purchase (App Review Guidelines, in-app purchase section). |
| Google Play | Randomized virtual items from a purchase require clear odds disclosure before purchase. |
| Steam | AI disclosure covers player-facing content; live-generated AI content needs a guardrails description. Valve's FAQ lists four ways to pay for live-AI costs: base price, microtransactions, subscription, or one-time DLC. |
| Microsoft Store (policy 11.16) | Live generative AI must be disclosed, kept within policy, and reportable in-product. |
| Discord Activities | Purchases use SKUs and entitlements; Discord's guidance is to verify entitlements server-side ("Trust the SDK, but verify via the API"). |
| CrazyGames | Ads only through its SDK; in-app purchases by invitation via Xsolla (per secondary sources). |
| Poki | No external requests or third-party ad SDKs. |

---

## 5. Audit table (copy into the Monetization Audit)

| Market / rating | Requirement | Our design | Status | Evidence |
|---|---|---|---|---|
| PEGI (from June 2026) | Paid random items -> 16; timers -> 12; streak penalties -> 12 | [..] | [OK / Risk / Fail] | [file, screenshot] |
| EU consumer law (CPC principles) | Real-money prices, no forced leftovers, withdrawal info, child defaults | [..] | | |
| EU AI Act Art. 50 | AI interaction disclosed; output marking per vendor | [..] | | |
| EAA | Accessible purchase flow (unless microenterprise) | [..] | | |
| Belgium | No paid random items | [..] | | |
| Brazil | No loot boxes for minors; age assurance | [..] | | |
| US (FTC, COPPA) | Honest odds, no dark-pattern flows, parental consent under 16 for HoYoverse-style models, COPPA if under 13 | [..] | | |
| South Korea / China | Odds on purchase screen; minors' limits (China) | [..] | | |
| Japan | No complete-gacha | [..] | | |
| Apple / Google | Odds disclosed before purchase | [..] | | |

Re-verify every row within 30 days of launch; this area changed in nearly every quarter of
2025 and 2026.
