# AlterLab GameForge -- Ethical Monetization Framework

This document is the canonical monetization reference for all GameForge agents. It defines the spectrum of monetization models, identifies exploitative dark patterns, maps the regulatory landscape, and establishes the AlterLab standard for ethical revenue design. Agents evaluating monetization decisions must ground their reasoning in these frameworks.

---

## 1. Monetization Models Spectrum

Monetization models exist on a spectrum from player-respecting to player-exploiting. The position on this spectrum is not a matter of opinion -- it is measurable by the degree to which a model relies on informed consent versus psychological manipulation.

### Tier 1: Fully Ethical (Player-Respecting)

**Premium (One-Time Purchase)**

The cleanest model. Player pays once, gets the full game.

| Aspect | Detail |
|--------|--------|
| How it works | Fixed price, all content included, no additional purchases required or offered |
| Player trust | Maximum -- no suspicion of withholding content for later sale |
| Revenue risk | All revenue front-loaded at launch; no recurring income without new releases |
| Best for | Narrative-driven games, short-to-medium experiences, games with finite content |
| Real examples | Hollow Knight ($15, 50+ hours of content), Celeste ($20, no DLC needed), Stardew Valley ($15, years of free updates), Hades ($25), Outer Wilds ($25) |
| Why it works | Eliminates all monetization friction from the player experience. The player never thinks about money after purchase. Every design decision serves the game, not the revenue model. |

**Premium + Fair DLC/Expansion**

One-time purchase with substantial paid expansions that deliver real new content.

| Aspect | Detail |
|--------|--------|
| How it works | Base game is complete and satisfying on its own. DLC adds genuinely new content (areas, story, mechanics), not content carved from the base game |
| Player trust | High -- if the base game feels complete. Erodes fast if DLC feels like cut content |
| Revenue risk | Moderate -- DLC extends the revenue tail, but each expansion requires real development investment |
| Best for | Games with expandable worlds, ongoing narratives, or deep systems that benefit from new content |
| Real examples | Dead Cells (multiple DLC packs, each adding weapons, biomes, and enemies), Slay the Spire (base game complete, The Watcher added as free update), Shovel Knight (free expansions delivered on original Kickstarter promise) |
| The line | DLC is ethical when the base game is a complete experience. It is unethical when the base game is deliberately incomplete to sell the "real" ending. If you planned the DLC content before shipping the base game, ask whether it belongs in the base game. |

### Tier 2: Conditionally Ethical (Requires Discipline)

**Cosmetic-Only Free-to-Play**

Free game, monetized through optional cosmetic purchases that do not affect gameplay.

| Aspect | Detail |
|--------|--------|
| How it works | Full game accessible for free. Revenue from skins, emotes, visual effects, and other non-gameplay items |
| Player trust | High if truly cosmetic. Erodes if "cosmetic" items provide subtle gameplay advantages (e.g., skins with smaller hitboxes, pay-to-stand-out in competitive contexts) |
| Revenue risk | High -- requires massive player base. Typical conversion rate: 2-5% of players spend money |
| Best for | Multiplayer games, games-as-service, community-driven games where self-expression matters |
| Real examples | Warframe (free, cosmetic store, player-tradeable premium currency), Path of Exile (free, cosmetic MTX, stash tabs are the ethical gray area), Fortnite (cosmetic Battle Pass, no gameplay-affecting purchases) |
| The line | "Cosmetic only" must mean truly zero gameplay impact. Inventory space, stash tabs, loadout slots, and convenience features that affect efficiency are not cosmetic -- they are soft pay-to-win. Call them what they are. |

**Season Pass / Battle Pass**

Time-limited progression tracks with free and paid tiers.

| Aspect | Detail |
|--------|--------|
| How it works | Seasonal content with a free reward track and a paid premium track. Players progress by playing. |
| Player trust | Medium -- depends on free track generosity, FOMO design, and whether progression feels achievable |
| Revenue risk | Moderate -- recurring revenue if seasons are compelling. Player fatigue is real; battle pass burnout is a documented phenomenon |
| Best for | Live-service games with regular content updates and an engaged recurring player base |
| Real examples | Fortnite (popularized the modern battle pass: 100-tier track, mix of free and paid rewards), Halo Infinite (non-expiring battle passes -- ethical evolution), Deep Rock Galactic (free cosmetic seasons, no paid pass -- maximum goodwill) |
| The ethical version | Pass does not expire (or has generous completion windows). Free track is rewarding. Paid track is cosmetic only. Progression rate is achievable through normal play without requiring daily grinding. No "buy levels" option that undermines the play-to-earn ethos. |
| The unethical version | Pass expires to create FOMO. Progression rate requires daily play or money. Free track is deliberately unrewarding. "Buy levels" prominently marketed. Pass contains gameplay-affecting items. |

### Tier 3: Ethically Hazardous (Requires Extreme Caution)

**Gacha / Loot Boxes**

Randomized purchases where the player pays money without knowing what they will receive.

| Aspect | Detail |
|--------|--------|
| How it works | Player purchases a randomized reward. Odds are typically stacked heavily toward low-value outcomes. |
| Player trust | Low -- the model is structurally identical to gambling. Even transparent odds do not eliminate the psychological exploitation |
| Revenue risk | Paradoxically low risk for the developer (whales drive disproportionate revenue) but high regulatory and reputational risk |
| Best for | Nothing. This model exploits psychological vulnerabilities. If your game needs loot boxes to survive financially, the game design or business model is the problem |
| Real examples | Genshin Impact (gacha character acquisition; its developer settled FTC charges over loot box marketing to minors in 2025, see 3.1), FIFA/EA FC Ultimate Team (loot boxes for player cards, subject to multiple lawsuits), Star Wars Battlefront II (loot boxes with gameplay advantages, caused massive backlash and regulatory attention) |
| Why it is dangerous | Variable ratio reinforcement schedules (the same mechanism that makes slot machines addictive) are the most powerful behavioral conditioning tool known to psychology. Applying them to spending real money is exploitation, regardless of whether odds are disclosed. |

### Tier 4: Exploitative (Do Not Ship)

These models are designed to extract maximum revenue from vulnerable players. They have no place in ethical game development.

| Model | Mechanism | Why It Is Exploitative |
|-------|-----------|----------------------|
| Pay-to-win | Real money buys gameplay advantages | Destroys competitive integrity, punishes non-paying players |
| Energy systems / stamina gates | Play is limited by a timer; pay to refill | Monetizes the basic act of playing the game |
| Predatory VIP systems | Spending tiers that unlock exclusive benefits | Creates a spending treadmill and social pressure to spend more |
| NFT / blockchain monetization | Crypto-backed item ownership with real-money speculation | Introduces financial risk to players, regulatory minefield, community toxicity |

---

## 2. Dark Pattern Identification

Dark patterns are design choices that manipulate player behavior to drive spending against the player's best interest. Every dark pattern below is a deliberate design choice, not an accident. Recognizing them is the first step to refusing to implement them.

### 2.1 Catalog of Dark Patterns

#### Artificial Scarcity (FOMO Exploitation)

**What it looks like**: "Limited time offer! 24 hours only!" "This skin will never return!" "Only 500 remaining!"

**How it works**: Creates urgency by threatening permanent loss. Players buy out of fear of missing out, not desire for the item. The "limited time" offer often returns, but the player has already spent under pressure.

**Real examples**: Fortnite's rotating item shop (items leave after 24 hours -- but most return eventually), mobile games with countdown timers on "exclusive" bundles.

**The test**: If the item would not sell at its price without the time pressure, the time pressure is doing the selling, not the item's value.

#### Pay-to-Skip (Artificial Friction)

**What it looks like**: Grind timers that can be skipped with premium currency. Build queues that take hours/days but can be rushed for money. Intentionally tedious loops that premium removes.

**How it works**: The game is deliberately designed to be frustrating at the free tier. Paying removes the frustration the developer intentionally created. The player is paying to fix a problem the developer manufactured.

**Real examples**: Clash of Clans (build timers measured in days, skip for gems), Dungeon Keeper Mobile (infamously charged real money to dig through rock -- a core gameplay action in the original).

**The test**: Remove the monetization. Is the pacing still fun? If the free experience is intentionally bad to make the paid experience look good, you have built a pay-to-skip dark pattern.

#### Predatory Pricing (Currency Obfuscation)

**What it looks like**: Gem bundles available in amounts of 80, 500, 1100, 2800, but items cost 950 gems. Every purchase leaves unusable remainder, driving the next purchase.

**How it works**: Intermediate currencies break the psychological link between real money and in-game spending. Odd amounts ensure leftover currency that nags the player into buying again. The conversion math is deliberately hard to do mentally.

**Real examples**: Almost every mobile F2P game. Microsoft Points (discontinued, but a textbook example of obfuscation). V-Bucks in Fortnite are priced to leave remainders.

**The test**: Show the real-money equivalent next to every price. "This skin costs 1200 V-Bucks ($12.00)." If this level of transparency would reduce sales, the pricing structure is predatory.

#### Social Pressure Spending

**What it looks like**: Purchased items are highly visible to other players. "Gift" mechanics where spending is public. Leaderboards that reward spending. Clan/guild systems where non-spenders are perceived as freeloaders.

**How it works**: Social comparison and belonging pressure drive spending. Players buy not because they want the item, but because they do not want to be the person without it.

**Real examples**: Mobile game alliances where spending is tracked and low spenders are kicked. Fortnite's prominence of purchased skins in the lobby. Any game where purchased items are displayed more prominently than earned items.

**The test**: If removing the social visibility of purchases would significantly reduce revenue, the social pressure is the product, not the item.

#### Sunk Cost Exploitation

**What it looks like**: Escalating investment mechanics where quitting means losing everything previously invested. "You have spent 200 hours and $50. Are you sure you want to stop?" Declining rewards that punish breaks from the game.

**How it works**: The player has invested time and money. Quitting means accepting that investment as loss. The game design leverages this psychological inertia to prevent churn and encourage continued spending.

**Real examples**: MMO subscription models where unsubscribing means losing access to paid-for characters and progress. Gacha games where accumulated "pity" counters reset if you stop playing.

**The test**: Can a player return after a 6-month break and still access everything they previously earned or purchased? If not, you are exploiting sunk cost.

#### Confirmshaming

**What it looks like**: "Are you sure you want to miss out on this incredible deal?" Decline buttons labeled "No thanks, I don't like saving money." Popup frequency that increases after declining.

**How it works**: Makes the player feel stupid or irresponsible for not spending.

**The test**: Is the "No" option as easy and neutral as the "Yes" option? If declining requires extra clicks, passive-aggressive copy, or navigating repeated prompts, it is confirmshaming.

### 2.2 Dark Pattern Audit Checklist

Run this audit on every monetization feature before implementation:

- [ ] Does this feature create artificial urgency? (Time limits, countdown timers, limited quantity)
- [ ] Does this feature manufacture a problem that spending solves? (Friction designed to be removed by payment)
- [ ] Does the pricing structure obscure real-money costs? (Intermediate currencies, odd amounts, leftover balances)
- [ ] Does this feature leverage social pressure to drive spending? (Public spending, visible purchased items, clan expectations)
- [ ] Does this feature exploit sunk cost to prevent churn? (Lost progress, expiring investments, reset mechanics)
- [ ] Does the decline option carry emotional or social cost? (Confirmshaming, public opt-out, repeated prompting)
- [ ] Would this feature's revenue drop significantly if players had perfect information? (If so, the revenue depends on confusion, not value)
- [ ] Would I be comfortable if a journalist detailed this feature's psychological mechanisms in a public article? (The daylight test)

If any answer is "yes," redesign the feature.

---

## 3. Regulatory Landscape

Between 2024 and 2026 the rules on loot boxes and in-game spending moved mostly through consumer-protection, child-protection and age-rating systems rather than gambling law. Every entry below carries a date and a source (listed in 3.3, all accessed 2026-11-05). This section maps risk for design decisions; it is not legal advice. Check current rules for each market before you ship.

### 3.1 Current Regulations by Region

#### Belgium

| Status | Detail |
|--------|--------|
| Loot box classification | The Belgian Gaming Commission concluded in 2018 that paid loot boxes can fall under the gambling law |
| Enforcement | Several publishers withdrew paid loot boxes for Belgian players in 2018-2019 (Blizzard in Overwatch, Valve's CS:GO case opening, EA's FIFA Points). Enforcement since then has been weak: a peer-reviewed study (Xiao, *Collabra: Psychology*, 2023) found 82% of the 100 highest-grossing iPhone games in Belgium still sold randomized items [B1] |
| Impact on developers | The legal risk sits with the seller. Weak enforcement is not permission |
| Action required | Remove paid randomized purchases for Belgian players, or do not sell the game in Belgium |

#### Netherlands

| Status | Detail |
|--------|--------|
| Loot box classification | The Kansspelautoriteit (Dutch Gaming Authority) found in 2018 that some loot boxes with transferable, cash-out-able rewards breached the Betting and Gaming Act |
| Current status | On 2022-03-09 the Council of State overturned the authority's EUR 10 million penalty against EA over FIFA Ultimate Team packs, finding that the packs were not a separate game of chance |
| Impact on developers | Legal gray zone. Paid loot boxes with tradeable or sellable rewards remain the highest risk |
| Action required | Legal review for any paid randomized mechanic distributed in the Netherlands |

#### China

| Status | Detail |
|--------|--------|
| Gacha probability disclosure | **Mandatory** since 2017-05-01 (Ministry of Culture notice). Odds for all randomized purchases must be published |
| Minor restrictions | Since 2021-09-01 (NPPA notice), players under 18 may play online games only 20:00-21:00 on Fridays, weekends and public holidays. Spending caps since 2019: no payments under age 8; ages 8-16 at most CNY 50 per transaction and 200 per month; ages 16-18 at most CNY 100 and 400 |
| Real-name registration | Required for all players |
| Impact on developers | Publishing in China requires a licensed local publisher, published drop rates, and age and identity verification |
| Action required | Display probability tables in-game. Implement minor protections through your Chinese publisher |

#### South Korea

| Status | Detail |
|--------|--------|
| Probability disclosure | **Mandatory** under the amended Game Industry Promotion Act since **2024-03-22**: item types and odds for every paid probability-type item, shown in the game and on the purchase screen. Items obtainable only for free are exempt [K1][K2] |
| Enforcement | Corrective orders from the Ministry of Culture, Sports and Tourism, with GRAC monitoring compliance; punitive damages of up to three times the loss for disclosure violations apply since August 2025. The Korea Fair Trade Commission separately fines misrepresented odds under e-commerce consumer law [K2][K3] |
| Pending | Bills proposing revenue-based fines (up to 3% of sales) were introduced in 2025; enactment not confirmed |
| Action required | Publish exact per-item odds on the purchase screen, keep server-side odds identical to the published table, and log every change |

#### Brazil

| Status | Detail |
|--------|--------|
| Law | Law 15.211/2025, the Digital Statute of Children and Adolescents ("ECA Digital"), signed 2025-09-17, **in force since 2026-03-17** [BR1][BR2] |
| Loot boxes | Prohibits loot boxes in electronic games aimed at children and adolescents or likely to be accessed by them [BR2] |
| Other duties | Applies to any IT product or service intended for or likely to be accessed by minors: reliable age verification, parental supervision tools, and child-protective design, default settings and data use. Read the text for your case [BR2][BR3] |
| Industry response | Ahead of the deadline, Blizzard reportedly removed paid loot boxes from Overwatch in Brazil and Riot added age verification to League of Legends [BR3] |
| Action required | If minors can plausibly access the game in Brazil, sell no paid randomized items there and implement age assurance |

#### United States

| Status | Detail |
|--------|--------|
| Federal legislation | No federal loot box law. The Protecting Children from Abusive Games Act (2019) was introduced but did not pass |
| FTC enforcement | The FTC acts through the FTC Act and COPPA. Epic Games (Fortnite) settled for US$520 million in December 2022: a US$275 million COPPA penalty and US$245 million in refunds over dark patterns. On **2025-01-17** the FTC filed a complaint and proposed court order against Cognosphere (HoYoverse, *Genshin Impact*): a US$20 million penalty, no loot box sales to players under 16 without parental consent, mandatory loot box disclosures, and no loot boxes sold for virtual currency unless players can also buy them directly with US dollars. The FTC alleged misleading odds, obscured costs and COPPA violations; the company did not admit wrongdoing, and the order takes effect only once a federal judge approves it [US1] |
| COPPA amended rule | Published 2025-04-22, effective 2025-06-23, **compliance required since 2026-04-22**. Adds separate verifiable parental consent before disclosing children's data to third parties (including for targeted advertising), a written data-retention policy and a written security program [US2] |
| State-level action | Several states have proposed loot box bills since 2018 (for example Hawaii and Minnesota). Check current status before relying on any of them |
| ESRB response | "In-Game Purchases (Includes Random Items)" notice since April 2020 |
| Action required | Disclose odds and real-money prices. Treat the HoYoverse terms (parental consent for random purchases by under-16s) as the practical benchmark. Comply with the amended COPPA rule for any child-directed or mixed-audience game |

#### European Union

| Status | Detail |
|--------|--------|
| In-game virtual currencies (CPC Network) | The Consumer Protection Cooperation Network adopted Key Principles on in-game virtual currencies in **March 2025**, alongside an enforcement action against Star Stable: show real-money prices for currency and for items, avoid practices that obscure costs, do not force players to buy currency they do not need, respect withdrawal rights, and protect children. The principles are non-binding guidance on existing consumer law. On **2026-09-30** the network reported that many companies had made no substantive changes and opened eleven coordinated actions against ten publishers, including Riot, Supercell, Mojang and Ubisoft, with particular attention to loot boxes offered to children [EU1][EU2] |
| Digital Fairness Act | **Proposal not yet adopted.** The Commission's 2026 work programme lists it for Q4 2026; as of early November 2026 it had not been tabled (a European Parliament briefing of 2026-10-05 reported mid-November). Parliament's November 2025 resolution asked it to address loot boxes and in-app currencies; whether it will is not yet known. Nothing applies until Parliament and Council adopt a final text [EU3] |
| Digital Services Act (DSA) | Fully applicable since 2024-02-17. Bans dark patterns on online platforms and requires measures to protect minors; mainly affects storefronts and platforms with user content |
| Digital Markets Act (DMA) | Applies to designated gatekeepers, including Apple's App Store and Google Play (Steam is not designated). Opened alternative payment and distribution routes on iOS and Android in the EU |
| European Accessibility Act (EAA) | In force since 2025-06-28. E-commerce services, including in-game purchase flows, must be accessible; microenterprises are exempt for services |
| GDPR | Consent requirements for data collection. Behavioral monetization targeting requires explicit opt-in. Children's data has stricter rules |
| European Parliament | Its 2023-01-18 resolution on consumer protection in online video games called for EU action on loot boxes and virtual currencies |
| Action required | Show real-money prices for everything bought with virtual currency now; the CPC principles are already being enforced. Design monetization that still works if paid randomized purchases are restricted for minors |

#### United Kingdom

| Status | Detail |
|--------|--------|
| Gambling law | The government's July 2022 response to its loot box call for evidence kept loot boxes outside the Gambling Act and asked industry to self-regulate, keeping legislation as an option |
| Industry principles | Ukie published 11 principles and guidance on paid loot boxes in July 2023, including technical controls so under-18s cannot buy loot boxes without parental consent, disclosure before purchase, and the PEGI random-items descriptor [UK1] |
| Current trajectory | Voluntary compliance under government review. The Gambling Commission's view is that the Gambling Act does not cover loot boxes |
| Action required | Implement the Ukie principles for UK players and monitor the government's review |

#### Australia

| Status | Detail |
|--------|--------|
| Classification | For games classified from **2024-09-22**: in-game purchases linked to chance (paid loot boxes) require a minimum **M**; simulated gambling (for example social casino games) requires a mandatory minimum **R18+** [AU1] |
| Scope | Existing classifications are not revisited unless the game is modified or its classification is revoked |
| Impact on developers | M is advisory; R18+ is legally restricted. Reporting on the Board's guidance indicates that even a minor simulated-gambling element can lead to R18+ |
| Action required | Leave simulated gambling out of any game meant for a general audience |

### 3.2 Age Rating Implications

Monetization choices directly affect your game's age rating, which directly affects your addressable audience.

| Rating Body | Monetization Trigger | Rating Impact |
|-------------|---------------------|---------------|
| ESRB | "In-Game Purchases (Includes Random Items)" notice | Applied to any game with paid randomized content. A notice, not a rating change |
| PEGI | New criteria announced 2026-03-12, applied to games submitted from **June 2026** [P1] | Paid random items: **minimum PEGI 16** by default. Time- or quantity-limited purchase offers: minimum PEGI 12. Play-by-appointment rewards: minimum PEGI 7 (PEGI 12 if missing a session costs content or progress). NFT or blockchain mechanics: **PEGI 18**. Fully unrestricted communication (no blocking or reporting): **PEGI 18**. Existing ratings stand unless an update warrants reclassification |
| USK (Germany) | In-game purchases, paid random items, simulated gambling, chat | Since 2023-01-01, under the amended Youth Protection Act, these usage risks appear as descriptors and can raise the rating |
| CERO (Japan) | Gacha mechanics | CERO does not rate up for gacha specifically. "Complete gacha" (kompu gacha) has been banned since 2012 under the Act against Unjustifiable Premiums, and JOGA's industry guidelines call for probability disclosure |
| GRAC (South Korea) | Paid probability-type items | Ratings plus monitoring of the disclosure law (see 3.1); non-compliance leads to corrective orders and damages |
| Australian Classification | Paid loot boxes; simulated gambling | Minimum M; mandatory minimum R18+ (since 2024-09-22) |
| IARC | Loot boxes, real-money gambling simulation | Flags in the IARC questionnaire affect the generated rating across multiple regions simultaneously |

**Practical impact**: Under PEGI's 2026 criteria, paid loot boxes alone put a game at PEGI 16, and limited-time offers alone at PEGI 12. In Australia they mean M. For an indie game aiming at broad appeal, paid randomized items are not worth the rating cost, even before ethics enters the conversation.

### 3.3 Sources

All accessed 2026-11-05.

- [B1] Xiao, L. Y. (2023), "Breaking Ban: Belgium's Ineffective Gambling Law Regulation of Video Game Loot Boxes", *Collabra: Psychology*: https://pure.itu.dk/en/publications/breaking-ban-belgiums-ineffective-gambling-law-regulation-of-vide/
- [K1] Chambers, Gaming Law 2024: South Korea: https://practiceguides.chambers.com/practice-guides/gaming-law-2024/south-korea
- [K2] Shin & Kim newsletter on loot box probability disclosure: https://www.shinkim.com/eng/media/newsletter/3206
- [K3] Korea JoongAng Daily, Krafton and Com2uS fined for misrepresenting odds: https://www.koreajoongangdaily.com/business/game-publishers-krafton-com2us-fined-for-misrepresenting-odds-of-in-game-chance-items/12386306
- [BR1] Digital Policy Alert, Law No. 15.211 enters into force (timeline: signed 2025-09-17, in force 2026-03-17): https://digitalpolicyalert.org/event/33580-bill-on-protection-of-children-and-adolescents-in-digital-environments-including-obligations-for-electronic-games-law-no-15211-enters-into-force
- [BR2] Demarest Advogados client alert on the ECA Digital: https://www.demarest.com.br/?p=166185
- [BR3] IAPP, "Brazil's Digital ECA: rethinking monetization and design in games": https://iapp.org/news/a/brazil-s-digital-eca-rethinking-monetization-and-design-in-games ; GamesBeat, "Preparing for the global implications of Brazil's Digital ECA": https://gamesbeat.com/preparing-for-the-global-implications-of-brazils-digital-eca/
- [US1] FTC business guidance, "Level up: Tips for businesses from the FTC's settlement with Genshin Impact developer HoYoverse" (January 2025): https://ftc.gov/business-guidance/blog/2025/01/level-tips-businesses-ftcs-settlement-genshin-impact-developer-hoyoverse
- [US2] Federal Register, Children's Online Privacy Protection Rule, final rule (2025-04-22): https://www.federalregister.gov/documents/2025/04/22/2025-05904/childrens-online-privacy-protection-rule
- [EU1] European Commission, Key Principles on in-game virtual currencies and Star Stable action: https://commission.europa.eu/topics/consumers/consumer-rights-and-complaints/enforcement-consumer-protection/coordinated-actions/social-media-online-games-and-search-engines_en
- [EU2] CPC Network, Joint Statement on Stronger Consumer Protection in Video Games (2026-09-30): https://commission.europa.eu/document/download/75ff33d4-77a6-4f14-916a-766a8c6c281c_en?filename=CPC+Network+Joint+Statement+of+the+Consumer+Protection+Cooperation+Network+on+online+games.pdf
- [EU3] European Parliamentary Research Service, "Towards a digital fairness act" (2026-10-05): https://eprs.europarl.europa.eu/contents/publications/EPRS/2026/10/EPRS_BRI(2026)791529.html
- [UK1] Lewis Silkin, "New UK principles and guidance on loot boxes published" (2023-07-24): https://www.lewissilkin.com/insights/2023/07/24/new-uk-principles-and-guidance-on-loot-boxes-published-102ik8a
- [AU1] Australian Classification, "New mandatory minimum classifications for gambling-like content": https://www.classification.gov.au/about-us/media-and-news/news/new-mandatory-minimum-classifications-for-gambling-games-content
- [P1] Reed Smith, "PEGI launches interactive risk categories" (2026-03-23): https://www.reedsmith.com/articles/pegi-launches-interactive-risk-categories-overhauls-age-ratings-for-loot-boxes-in-game-spending-and-communication-features/ ; Lewis Silkin (2026-03-18): https://www.lewissilkin.com/insights/2026/03/18/pegi-announces-major-update-to-age-rating-criteria-what-games-businesses-need-to-102mn9y

---

## 4. The AlterLab Standard

### Our Position

**Cosmetic monetization is the ethical ceiling for indie games.**

This is not a suggestion. It is a standard. GameForge agents must apply this principle when advising on monetization design.

The reasoning:

1. **Indie games do not need predatory monetization to be profitable.** Hollow Knight sold 3+ million copies at $15. Stardew Valley sold 30+ million copies at $15. Hades sold 6+ million copies at $25. None of them used loot boxes, gacha, or pay-to-win mechanics. The evidence is overwhelming: great games with fair pricing make money.

2. **If your game needs predatory monetization to survive, the game design is the problem.** A game that cannot sustain itself on the quality of its experience is a game that needs better design, not darker monetization. Revenue problems are design problems in disguise.

3. **Player trust is a studio's most valuable asset.** Indie studios live and die by community trust. One predatory monetization decision can permanently damage a studio's reputation. The revenue from loot boxes never compensates for the trust destroyed.

4. **The regulatory trajectory is toward restriction.** Every year, more jurisdictions restrict or ban exploitative monetization. Designing ethically now avoids costly redesigns later. Building on a foundation of fair monetization is future-proofing your business.

### The AlterLab Monetization Hierarchy

In order of preference:

1. **Premium (one-time purchase)** -- First choice for any game with finite content
2. **Premium + fair DLC** -- When the game naturally supports expansion content
3. **Cosmetic-only F2P** -- When the game requires a large player base (multiplayer, community-driven)
4. **Ethical battle pass** -- Only with non-expiring passes, achievable free progression, and cosmetic-only paid rewards
5. **Everything below this line is off-limits** -- Gacha, loot boxes, pay-to-win, energy systems, predatory pricing

---

## 5. Decision Framework

Use this framework to evaluate whether a monetization feature crosses the ethical line.

### 5.1 The Five Tests

Every monetization feature must pass all five tests. Failing any one is a redesign trigger.

#### Test 1: The Informed Consent Test

> "Does the player know exactly what they are buying, at what real-money cost, before they commit?"

- Passes: Fixed-price cosmetic store with clear previews and real-money prices displayed
- Fails: Loot boxes (outcome unknown), obfuscated currency pricing (real cost unclear), bundle-only items where you pay for things you don't want to get the thing you do

#### Test 2: The Gameplay Integrity Test

> "Can a player who never spends money experience the full game without artificial disadvantage?"

- Passes: All gameplay content accessible without payment. Paid items are cosmetic or supplementary
- Fails: Pay-to-win advantages, content gated behind premium currency, difficulty intentionally tuned to push spending

#### Test 3: The Vulnerability Test

> "Does this feature disproportionately exploit children, people prone to addiction, or players in emotional distress?"

- Passes: Spending caps, purchase confirmations, parental controls, no variable-ratio reinforcement schedules
- Fails: Gacha targeting dopamine cycles, unlimited spending with no friction, targeting moments of emotional high (post-victory) or low (post-defeat) with purchase prompts

#### Test 4: The Removal Test

> "If we removed the monetization, would the underlying game be worse?"

- Passes: The game is a complete, satisfying experience without any monetization. Monetization adds optional extras
- Fails: Removing the monetization reveals a deliberately degraded free experience (slow progression, artificial friction, missing content)

#### Test 5: The Daylight Test

> "Would we be comfortable explaining this monetization model in a public investor letter, a player Q&A, and a regulatory inquiry -- using the same description for all three audiences?"

- Passes: The same honest description works for all audiences because the model has nothing to hide
- Fails: You would describe the model differently depending on the audience. Internal language uses euphemisms ("surprise mechanics") instead of accurate descriptions ("randomized paid loot boxes")

### 5.2 Decision Flowchart

```
Does the player know exactly what they're buying?
  |
  +-- No --> REJECT. Add transparency or redesign.
  |
  +-- Yes --> Does it affect gameplay balance?
                |
                +-- Yes --> REJECT. Make it cosmetic or remove it.
                |
                +-- No --> Could it exploit vulnerable players?
                            |
                            +-- Yes --> REJECT. Add protections or remove the feature.
                            |
                            +-- No --> Would the game be worse without monetization?
                                        |
                                        +-- Yes --> REJECT. Fix the base game design.
                                        |
                                        +-- No --> Can you describe it honestly to any audience?
                                                    |
                                                    +-- Yes --> APPROVED.
                                                    |
                                                    +-- No --> REJECT. Redesign for daylight.
```

### 5.3 Revenue Viability Check

Ethics without viability is wishful thinking. Validate that your ethical model can sustain the project.

| Question | Your Answer |
|----------|-------------|
| What is the total development cost (including living expenses)? | [$X] |
| What is the minimum unit sales needed to break even at your price point? | [X units at $Y] |
| What is the realistic sales estimate for your genre/subgenre? (Use VG Insights genre median) | [X units] |
| Does break-even require above-median performance? | [Yes = high risk / No = viable] |
| What is the DLC/expansion revenue tail? (If applicable) | [$X additional over 12 months] |
| What is the total 24-month revenue projection? | [$X] |

**If the numbers do not work**: Reduce scope, reduce development cost, increase price (if justified by content), or find supplementary revenue (Kickstarter, publisher, grants). Do not solve a business model problem with predatory monetization. The answer to "We need more money" is never "Exploit the player."

---

## 6. Implementation Checklist

When implementing monetization, verify every item:

### Transparency
- [ ] All prices displayed in real-money equivalent alongside any virtual currency
- [ ] No intermediate currencies designed to obscure real-money cost (or if used, conversion rate is simple and prominently displayed)
- [ ] All randomized content odds publicly disclosed (even if not legally required in your jurisdiction)
- [ ] Purchase history and total spending accessible to the player at any time
- [ ] Clear refund policy communicated before first purchase

### Player Protection
- [ ] Parental controls available (spending limits, purchase approval, time limits)
- [ ] Purchase confirmation required for all transactions over $[X]
- [ ] Spending caps available (daily/weekly/monthly)
- [ ] Cool-down period after large purchases (prompt: "You have spent $X in the last hour")
- [ ] No purchase prompts during emotional peaks (post-victory, post-defeat, post-narrative-climax)

### Design Integrity
- [ ] Free players experience the complete core game without artificial degradation
- [ ] No paid gameplay advantages in competitive or cooperative contexts
- [ ] Cosmetic items are clearly previewed before purchase (no bait-and-switch)
- [ ] No artificial scarcity (time-limited offers that create FOMO)
- [ ] No currency bundles designed to leave unusable remainder

### Legal Compliance
- [ ] PEGI rating impact assessed for all monetization features (2026 criteria: paid random items 16+, limited-time offers 12+)
- [ ] Regional loot box regulations reviewed (Belgium, Netherlands, China, South Korea, Brazil, Australia)
- [ ] Real-money prices shown for everything bought with virtual currency (EU CPC Key Principles)
- [ ] ESRB "In-Game Purchases" labels applied correctly
- [ ] GDPR consent obtained for behavioral data used in monetization targeting
- [ ] COPPA compliance for any game accessible to under-13 players (amended rule, compliance required since 2026-04-22)
- [ ] Tax compliance for virtual currency sales in all distribution regions
