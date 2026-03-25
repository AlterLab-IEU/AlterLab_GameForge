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
| Real examples | Fortnite (pioneered the modern battle pass, 100-tier track, mix of free and paid rewards), Halo Infinite (non-expiring battle passes -- ethical evolution), Deep Rock Galactic (free cosmetic seasons, no paid pass -- maximum goodwill) |
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
| Real examples | Genshin Impact (gacha character acquisition, extremely profitable, extremely predatory), FIFA/EA FC Ultimate Team (loot boxes for player cards, subject to multiple lawsuits), Star Wars Battlefront II (loot boxes with gameplay advantages, caused massive backlash and regulatory attention) |
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

The legal environment around game monetization is shifting fast. What was unregulated in 2020 faces active legislation in 2025. Ignorance is not a defense.

### 3.1 Current Regulations by Region

#### Belgium

| Status | Detail |
|--------|--------|
| Loot box classification | **Classified as gambling** since 2018 |
| Enforcement | Belgian Gaming Commission actively enforces. FIFA, Overwatch, and CS:GO removed loot box purchases in Belgium |
| Impact on developers | Any game sold in Belgium must remove paid randomized purchases or face prosecution |
| Action required | If your game has paid loot boxes and you sell in the EU, remove them for Belgian players or region-lock Belgium |

#### Netherlands

| Status | Detail |
|--------|--------|
| Loot box classification | Kansspelautoriteit (Dutch Gaming Authority) ruled certain loot boxes are gambling in 2018 |
| Current status | Court overturned the blanket ban in 2022, but individual game enforcement continues case-by-case |
| Impact on developers | Legal gray zone. Paid loot boxes with tradeable items remain highest risk |
| Action required | Legal review recommended for any paid randomized mechanic distributed in the Netherlands |

#### China

| Status | Detail |
|--------|--------|
| Gacha probability disclosure | **Mandatory** since 2017. All randomized purchase odds must be published |
| Minor restrictions | Under-18 players face playtime limits (1 hour per day on holidays, prohibited during school hours) and spending caps |
| Real-name registration | Required for all players |
| Impact on developers | Any game published in China must disclose all drop rates and implement age/identity verification |
| Action required | Probability tables must be publicly displayed in-game. Comply with minor protection regulations through a Chinese publisher |

#### United States

| Status | Detail |
|--------|--------|
| Federal legislation | No federal loot box law as of 2025. The proposed "Protecting Children from Abusive Games Act" was introduced but has not passed |
| State-level action | Multiple states have proposed bills (California, Hawaii, Minnesota, others). None have become law, but the legislative trend is clear |
| FTC involvement | FTC has issued guidelines on disclosing loot box odds and has taken action against deceptive practices |
| ESRB response | ESRB added "In-Game Purchases (Includes Random Items)" label in 2020 |
| Impact on developers | No current legal requirement, but regulatory risk is increasing. Proactive compliance reduces future remediation cost |
| Action required | Disclose odds voluntarily. Implement spending caps for minors. Treat self-regulation as inevitable-law preparation |

#### European Union

| Status | Detail |
|--------|--------|
| Digital Services Act (DSA) | In effect since 2024. Platforms must be transparent about recommendation algorithms and advertising. Indirect impact on in-game stores |
| Digital Markets Act (DMA) | Targets platform gatekeepers (Apple, Google, Steam). May affect in-app purchase requirements and platform fees |
| European Accessibility Act (EAA) | In effect since June 2025. Products sold in the EU must meet accessibility standards. Monetization UI must be accessible |
| GDPR | Consent requirements for data collection. Behavioral monetization targeting requires explicit opt-in. Children's data has stricter rules |
| Proposed EU-wide loot box regulation | European Parliament resolution (2023) called for harmonized loot box regulation. Formal legislation is in discussion |
| Impact on developers | Increasing regulatory pressure. The EU is the most likely jurisdiction to pass comprehensive loot box legislation |
| Action required | Prepare for EU-wide loot box regulation by designing monetization that works without randomized paid purchases. This is not hypothetical -- it is a matter of when, not if |

#### United Kingdom

| Status | Detail |
|--------|--------|
| Post-Brexit status | UK is not bound by EU regulations but tracks closely |
| DCMS Committee | Recommended classifying loot boxes as gambling in 2019. Government rejected the recommendation but committed to monitoring |
| Current trajectory | Industry self-regulation via UKIE and the ISFE. Government intervention remains possible if self-regulation fails |
| Action required | Monitor UK regulatory developments. Voluntary compliance with emerging standards is prudent |

### 3.2 Age Rating Implications

Monetization choices directly affect your game's age rating, which directly affects your addressable audience.

| Rating Body | Monetization Trigger | Rating Impact |
|-------------|---------------------|---------------|
| ESRB | "In-Game Purchases (Includes Random Items)" label | Applied to any game with paid randomized content. Not a rating change but an additional notice |
| PEGI | Paid randomized items (loot boxes) | **PEGI 16 minimum** as of June 2026. Unmoderated chat and NFTs trigger **PEGI 18** |
| USK (Germany) | Paid randomized items, simulated gambling | May trigger higher rating depending on implementation |
| CERO (Japan) | Gacha mechanics | Disclosure requirements. CERO does not currently rate up for gacha specifically, but JOGA (industry body) requires probability disclosure |
| GRAC (South Korea) | Probability disclosure mandatory | All randomized purchase odds must be published. Failure to comply results in rating refusal |
| IARC | Loot boxes, real-money gambling simulation | Flags in the IARC questionnaire that affect the generated rating across multiple regions simultaneously |

**Practical impact**: A PEGI 16 rating instead of PEGI 12 narrows your European audience significantly. For an indie game targeting broad appeal, loot boxes are not worth the rating cost even before considering ethics.

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
- [ ] PEGI rating impact assessed for all monetization features
- [ ] Regional loot box regulations reviewed (Belgium, Netherlands, China, South Korea)
- [ ] ESRB "In-Game Purchases" labels applied correctly
- [ ] GDPR consent obtained for behavioral data used in monetization targeting
- [ ] COPPA compliance for any game accessible to under-13 players
- [ ] Tax compliance for virtual currency sales in all distribution regions
