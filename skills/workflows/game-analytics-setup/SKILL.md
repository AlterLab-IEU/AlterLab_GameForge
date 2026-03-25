---
name: "game-analytics-setup"
description: >
  Use when the user asks about "analytics", "telemetry", "KPIs", "metrics", "player data",
  "retention", "DAU", "dashboards", "A/B testing", "funnel analysis", or needs to set up
  data-driven design. Part of the AlterLab GameForge collection.
argument-hint: "[analytics-goal or kpi-question]"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
---

# AlterLab GameForge -- Analytics Setup

This workflow guides indie teams through implementing game analytics: what to track, how to track it without violating player trust, which KPIs actually matter, and how to build dashboards that inform design decisions instead of just generating noise. Analytics should make your game better. When it starts making your game more addictive instead of more fun, you have crossed a line.

**The cautionary tale**: Zynga circa 2012 optimized every metric -- DAU, retention, ARPU, virality -- and built a company valued at $10 billion. Then players realized the games were not fun, they were compulsion loops engineered by dashboards. The stock crashed 80%. Optimizing metrics without design vision produces games that nobody loves and everyone quits.

**The aspirational model**: Supercell uses analytics extensively but famously kills games that have good metrics but are not fun. Data informs design; design leads. Hades used boon pickup data and death location heatmaps to tune difficulty -- not to maximize retention, but to ensure every player experienced the narrative. Riot balances League of Legends with telemetry across millions of matches, but the balance team makes judgment calls that override the data when the data says something is balanced but players say it is not fun.

---

## When Analytics Hurts

Before setting up analytics, understand when it causes harm:

| Anti-Pattern | What It Looks Like | Why It Is Harmful |
|---|---|---|
| Metric worship | "Retention is down 2%, redesign the tutorial" without asking WHY retention dropped | Treating symptoms instead of causes. The tutorial might be fine; the game after the tutorial might be boring. |
| Goodhart's Law | Team optimizes for D1 retention specifically, so the tutorial is made trivially easy. D1 goes up. D7 crashes because players never learned the actual game. | When a measure becomes a target, it ceases to be a good measure. |
| Engagement dark patterns | Data shows players who play 4+ hours have higher retention. Team adds daily login streaks and FOMO events to push session length. | You are not increasing fun. You are increasing compulsion. Players will resent it. |
| Privacy violations | Tracking player behavior without consent, selling data to third parties, building psychological profiles for monetization targeting | Unethical and increasingly illegal. GDPR fines start at 4% of global revenue. |
| Analysis paralysis | 500 events tracked, 12 dashboards built, zero design decisions changed | Analytics that nobody acts on is wasted engineering effort and wasted player trust (you collected their data for nothing). |

**The rule**: Track only what you will act on. Every event you track should answer a specific design question. If you cannot name the question, do not track the event.

---

## Phase 1: Telemetry Architecture

### Privacy-First Design

Player data is a trust deposit. Spend it wisely.

**Consent tiers**:

| Tier | Data Type | Consent Required | Example |
|---|---|---|---|
| Essential | Crash reports, critical errors | Implicit (required for game function) | Unity crash reporter, Unreal crash analytics |
| Functional | Settings preferences, save data | Implicit (required for game function) | Resolution, key bindings, accessibility settings |
| Analytics | Gameplay telemetry, session data | **Explicit opt-in** | Play session length, level completion rates, death locations |
| Marketing | Player demographics, spending patterns | **Explicit opt-in + separate consent** | Age, region, purchase history, ad engagement |

**Implementation requirements**:
- Display a clear analytics consent prompt on first launch. No pre-checked boxes. No "by continuing you agree" dark patterns.
- Provide an in-game toggle to disable analytics at any time.
- Anonymize all data. Never store player-identifiable information in analytics events unless legally required and explicitly consented.
- Data retention policy: define how long you keep data and communicate this to players.
- GDPR Article 17: players can request deletion of their data. Build the deletion pipeline before you need it.

**Regulatory compliance matrix**:

| Regulation | Scope | Key Requirements | Penalty |
|---|---|---|---|
| GDPR (EU) | All EU residents | Explicit consent, right to deletion, data portability, DPO for large-scale processing | Up to 4% of global revenue or 20M EUR |
| COPPA (US) | Children under 13 | Parental consent for data collection, no behavioral advertising to children | Up to $50,000 per violation |
| ATT (Apple) | iOS users | App Tracking Transparency prompt required before cross-app tracking | App Store rejection |
| CCPA/CPRA (California) | California residents | Opt-out of sale/sharing, right to deletion, right to know what is collected | Up to $7,500 per intentional violation |
| LGPD (Brazil) | Brazilian residents | Similar to GDPR: consent, purpose limitation, data minimization | Up to 2% of revenue in Brazil |
| PIPA (South Korea) | South Korean residents | Consent, data minimization, breach notification within 72 hours | Criminal penalties possible |

### What to Track

Organize events into a taxonomy that maps to design questions.

**Session events** (answer: "How do players engage with the game?"):

| Event | Properties | Design Question |
|---|---|---|
| `session_start` | platform, version, locale, session_number | How often do players return? On what platforms? |
| `session_end` | duration, reason (quit/crash/alt-tab) | How long are sessions? Why do they end? |
| `tutorial_step` | step_id, time_in_step, skipped | Where do players struggle or disengage in onboarding? |
| `first_session_complete` | total_duration, furthest_point | How far do new players get? Is the first impression working? |

**Progression events** (answer: "Is the difficulty and pacing right?"):

| Event | Properties | Design Question |
|---|---|---|
| `level_start` | level_id, attempt_number, loadout | What levels do players attempt and with what builds? |
| `level_complete` | level_id, duration, score, deaths | How hard is each level in practice vs. design intent? |
| `level_abandon` | level_id, duration, reason_if_known | Where do players give up? This is your churn signal. |
| `death` | location, cause, player_health, time_in_level | Hades used death data to identify unfair enemy placements and tune boon drop rates |
| `checkpoint_reach` | checkpoint_id, time_from_last, health | Is pacing between checkpoints appropriate? |

**Economy events** (answer: "Is the economy healthy?" -- reference `game-economy-designer`):

| Event | Properties | Design Question |
|---|---|---|
| `currency_earn` | currency_type, amount, source | Are faucets producing as modeled? |
| `currency_spend` | currency_type, amount, sink | Are sinks attractive enough? |
| `purchase_real_money` | item_id, price, currency_used | What do paying players buy? At what price points? |
| `store_view` | items_displayed, time_spent | Do players browse the store? What catches their eye? |

**Engagement events** (answer: "What do players actually enjoy?"):

| Event | Properties | Design Question |
|---|---|---|
| `feature_use` | feature_id, frequency, context | Which features are players engaging with? Which are being ignored? |
| `content_discover` | content_id, discovery_method | Are players finding the content you built? |
| `social_interaction` | type (coop/pvp/trade/chat), duration | Is the social layer working? |

### Event Naming Convention

Consistency matters. A messy event taxonomy becomes unusable within months.

```
Format:  [category]_[action]_[target]
Examples:
  session_start
  level_complete_boss
  economy_spend_upgrade
  ui_click_settings
  progression_unlock_ability
```

Rules:
- All lowercase, underscore-separated
- Past tense for completed actions (`level_completed`), present for states (`player_in_menu`)
- Never include PII in event names or properties
- Version your schema: add a `schema_version` property so you can evolve the taxonomy without breaking dashboards

---

## Phase 2: Core KPIs with Indie Benchmarks

Track what matters. These are the KPIs that actually inform design decisions for indie games.

### Retention (The Only Metric That Cannot Lie)

| Metric | Definition | Indie Benchmark (Premium) | Indie Benchmark (F2P) | What It Tells You |
|---|---|---|---|---|
| D1 Retention | % of new players who return the day after first play | 40-60% | 30-45% | Is the first impression compelling? |
| D7 Retention | % of new players who return 7 days after first play | 20-35% | 12-20% | Does the core loop sustain interest past the tutorial? |
| D30 Retention | % of new players who return 30 days after first play | 10-20% | 5-10% | Is there enough depth for long-term engagement? |

**How Valve used retention data**: TF2's economy was tuned based on retention curves. When retention dipped at specific progression points, the team introduced new item drops and cosmetics at those exact moments -- not to manipulate, but to reward continued engagement.

### Engagement

| Metric | Definition | Indie Benchmark | What It Tells You |
|---|---|---|---|
| DAU (Daily Active Users) | Unique players per day | Depends on total players; trend matters more than absolute | Is the player base growing, stable, or shrinking? |
| Session Length | Average play session duration | 20-45 min (mobile), 45-90 min (PC/console) | Are sessions a healthy length? Too short = not engaging. Too long = potentially compulsive. |
| Sessions per Day | Average sessions per player per day | 1-2 (premium), 2-4 (F2P/mobile) | Are players returning multiple times a day? |
| Stickiness (DAU/MAU) | Daily active as % of monthly active | 15-25% (good), 25%+ (excellent) | What fraction of your players are daily players? |

### Monetization (F2P / Hybrid Only)

| Metric | Definition | Indie Benchmark | What It Tells You |
|---|---|---|---|
| Conversion Rate | % of players who make any purchase | 2-5% (healthy), <1% (problem) | Is the free-to-paid transition working? |
| ARPU | Average Revenue Per User (all users) | $0.50-$3.00/month (mobile F2P) | Revenue health per player |
| ARPPU | Average Revenue Per Paying User | $10-$50/month (mobile F2P) | Are paying players spending reasonable amounts? |
| Whale Concentration | % of revenue from top 1% of spenders | <30% (healthy), >50% (dangerous) | Over-reliance on whales is a business risk and an ethical red flag |

### Funnel Analysis

Track the player journey as a conversion funnel:

```
Download/Purchase                  100%
  |
  v
First Launch                       95%   (5% never launch -- install issues)
  |
  v
Complete Tutorial                  70%   (30% drop in tutorial -- too long? too hard?)
  |
  v
Complete First Meaningful Session  55%   (15% drop -- core loop not compelling)
  |
  v
Return Next Day (D1)              35%   (20% drop -- first impression was not sticky)
  |
  v
Return Day 7 (D7)                 18%   (17% drop -- mid-term engagement gap)
  |
  v
Return Day 30 (D30)              10%   (8% drop -- normal long-term attrition)
```

Every drop in the funnel is a design question. The steepest drops are your highest-priority problems.

---

## Phase 3: Dashboard Design

A dashboard nobody looks at is worse than no dashboard -- it cost engineering time and generates false confidence.

### Dashboard Hierarchy

| Dashboard | Audience | Update Frequency | Key Widgets |
|---|---|---|---|
| Health Overview | Everyone on the team | Real-time or daily | DAU trend, D1/D7/D30 retention, crash rate, active version distribution |
| Engagement Deep Dive | Designer, Producer | Weekly | Session length distribution, level completion rates, feature usage heatmap, drop-off funnel |
| Economy Dashboard | Economy Designer | Daily (live game) | Currency supply, sink engagement, inflation rate, store conversion -- reference `game-economy-designer` |
| Monetization Dashboard | Producer, Economy Designer | Daily (F2P/hybrid) | Revenue, ARPU, conversion rate, whale concentration, purchase funnel |
| Technical Health | Technical Director, QA | Real-time | Crash rate by platform/version, load times, FPS distribution, error rates |

### Dashboard Tools for Indies

| Tool | Cost | Best For | Limitations |
|---|---|---|---|
| GameAnalytics | Free (up to 1M MAU) | Indie default. Pre-built game KPI dashboards. | Limited custom event depth. Retention and progression views are solid. |
| Unity Analytics | Free with Unity | Unity projects. Built-in integration. | Unity-only. Less flexible than dedicated tools. |
| Amplitude | Free tier (10M events/mo) | Product analytics with strong funnel and cohort tools. | Not game-specific; requires custom setup for game KPIs. |
| Mixpanel | Free tier (20M events/mo) | Event-based analytics with good visualization. | Not game-specific. Pricing scales fast past free tier. |
| PostHog | Free (self-hosted), cloud free tier | Open-source, self-hosted option. Full control over data. | Requires infrastructure to self-host. No game-specific features. |
| Grafana + InfluxDB | Free (self-hosted) | Custom dashboards for technical metrics. | Requires significant setup. Best for teams with backend experience. |
| Google BigQuery + Looker Studio | Free tier generous | Massive-scale analysis, SQL-based queries. | High setup cost. Overkill for most indie games pre-launch. |

**Recommendation for most indie teams**: Start with GameAnalytics (free, game-specific, fast to integrate). Add a custom dashboard (Grafana or Looker Studio) only when you have specific questions that GameAnalytics cannot answer.

---

## Phase 4: A/B Testing

A/B testing lets you make design decisions with evidence instead of arguments. But it requires enough players to produce statistically significant results.

### When A/B Testing Works for Indies

| Situation | A/B Test Viable? | Why |
|---|---|---|
| F2P game with 10K+ DAU | Yes | Enough traffic to reach significance in days |
| Live-service game in early access | Maybe | If you have 1K+ DAU and can run tests for 2-4 weeks |
| Premium game pre-launch (playtest) | Limited | Small sample sizes make significance hard. Use qualitative feedback instead. |
| Premium game post-launch | Rarely | Players expect a consistent experience. Opt-in beta branches work better. |

### What to A/B Test

| Good Candidates | Bad Candidates |
|---|---|
| Tutorial flow and onboarding sequence | Core mechanic feel (too subjective for metrics) |
| Difficulty curve (enemy health, damage numbers) | Art style or narrative tone (not measurable by retention) |
| Store layout and pricing (F2P) | Anything that affects competitive fairness |
| UI layout and information hierarchy | Features that require long-term evaluation (weeks+) |
| Reward pacing and drop rates | Anything that fragments the player community |

### Statistical Rigor

- **Sample size**: Use a power calculator. For a 5% change in a metric with 95% confidence, you typically need 1,000+ players per variant.
- **Duration**: Run tests for at least one full week to account for day-of-week effects.
- **One variable at a time**: Changing tutorial length AND difficulty simultaneously tells you nothing about which change mattered.
- **Do not peek**: Checking results before the test period ends and stopping early when you see a positive result inflates false positive rates. Set a duration and honor it.

---

## Output Template

When setting up analytics for a project, produce this document:

```
## Analytics Plan: [Game Title]
## Date: [YYYY-MM-DD]

### Design Questions
List the specific questions analytics will answer:
1. [Question -- e.g., "Where do new players drop off in the first 30 minutes?"]
2. [Question -- e.g., "Which weapons/abilities are underused?"]
3. [Question -- e.g., "Is the economy inflating faster than modeled?"]

### Event Taxonomy
| Category | Event Name | Properties | Design Question Answered |
|----------|-----------|------------|--------------------------|
| session  | session_start | platform, version, locale | [question] |
| ...      | ...       | ...        | ...                      |

### KPI Targets
| KPI | Target | Alert Threshold | Measurement Frequency |
|-----|--------|-----------------|----------------------|
| D1 Retention | [X%] | < [Y%] | Daily |
| D7 Retention | [X%] | < [Y%] | Weekly |
| Session Length (median) | [X min] | < [Y min] | Daily |
| Crash Rate | < [X%] | > [Y%] | Real-time |
| [Economy KPI] | [target] | [threshold] | [frequency] |

### Dashboard Specification
| Dashboard | Tool | Widgets | Refresh Rate |
|-----------|------|---------|-------------|
| Health Overview | [tool] | [list] | [rate] |
| ...       | ...  | ...     | ...         |

### Privacy Implementation
- [ ] Consent prompt implemented (opt-in, no pre-checked boxes)
- [ ] In-game analytics toggle available
- [ ] Data anonymization pipeline verified
- [ ] Data retention policy defined: [X months]
- [ ] GDPR deletion endpoint implemented
- [ ] COPPA compliance verified (if applicable)
- [ ] ATT prompt implemented (if iOS)

### A/B Testing Plan (if applicable)
| Test | Hypothesis | Metric | Sample Size Needed | Duration |
|------|-----------|--------|-------------------|----------|
| [test name] | [hypothesis] | [primary metric] | [N per variant] | [weeks] |

### Integration Architecture
- Analytics SDK: [GameAnalytics / Amplitude / custom]
- Event dispatch: [batched / real-time]
- Data pipeline: [SDK -> cloud -> dashboard]
- Offline handling: [queue events, send on reconnect]
- Build flags: [analytics disabled in dev builds, enabled in release]
```

---

## Cross-References

- **Economy metrics**: Route to `game-economy-designer` for currency flow modeling, inflation tracking, and monetization health KPIs
- **Playtest analytics**: Route to `game-playtest` for structured playtesting that combines analytics data with qualitative observation
- **Technical health**: Route to `game-technical-director` for crash reporting, performance profiling, and infrastructure monitoring
- **Balance tuning**: Route to `game-balance-check` for using analytics data to inform difficulty and system balance adjustments
- **Launch analytics**: Route to `game-launch` for store analytics, wishlist conversion, and launch window performance tracking
- **Privacy and ethics**: Reference `@docs/monetization-ethics.md` for the ethical framework on player data collection
- **Workflow integration**: Reference `@docs/workflow-guide.md` for where analytics setup fits in the 11-phase development lifecycle
