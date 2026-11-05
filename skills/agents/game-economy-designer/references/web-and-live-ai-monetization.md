# Web-Game Monetization and Pricing Live-AI Features

Load this before planning revenue for a browser game (portals, own domain, Discord, YouTube,
Telegram, Reddit) or before pricing any feature that calls a generative AI service at runtime.
Facts are from portal documentation and reporting checked 2026-11-05. Revenue figures that are
self-reported are labelled; there is no reliable public data on typical web-game earnings, so
plan with ranges and measure.

---

## 1. Channels and how they pay

| Channel | Technical gate | How money flows | Watch out for |
|---|---|---|---|
| **Own domain** | Instant load, no login; your hosting bill | Direct sponsors, in-world ads, cosmetics via Stripe or similar | Spikes then decays (section 2); you carry payments, VAT/sales tax and fraud |
| **itch.io** | ZIP with `index.html`; generative-AI disclosure feeds itch's "no AI" filter (extended to search 2026-11-03) | Paid or pay-what-you-want; itch's open revenue share lets creators choose the platform cut (default 10%) | Discoverability collapsed under AI-upload volume in late 2026; itch deleted "a couple terabytes" of AI uploads |
| **Poki** (curated) | Desktop, mobile, tablet; incognito-safe storage; no external requests or other ad SDKs; works with ad blockers; no debug code; players leave if loading takes more than about 10 s | Revenue share, reported as **50/50 on Poki-sourced traffic** (secondary sources; confirm in your agreement); web-exclusive titles preferred | Curated acceptance; your own ads and analytics SDKs are not allowed |
| **CrazyGames** | Initial download 50 MB or less (20 MB or less for the mobile homepage); 250 MB and 1,500 files total; PEGI 12 content; `gameplayStart` event | Ad revenue share through its SDK only; IAP by invitation via Xsolla (secondary sources) | Disables games that are not smooth on 4 GB Chromebooks |
| **YouTube Playables** | Initial bundle under 30 MiB (under 15 preferred); total under 250 MiB; saves under 3 MiB; 512 MB JS heap cap | Program-based; terms by agreement | Certification requirements are strict and change |
| **Discord Activities** | Embedded App SDK iframe; your own server | SKUs and entitlements; **verify entitlements server-side** | Discord's fee terms for Activities were not verified |
| **Reddit (Devvit Web)** | Phaser template available; social hooks | Developer Funds paid on engagement milestones | Terms after July 2026 not verified |
| **Telegram Mini Apps** | Web app inside Telegram | **Telegram Stars** for digital goods (since June 2024), convertible to TON | Crypto conversion adds accounting and regulatory work |
| **Steam (web tech)** | Electron + steamworks.js is the common path (`steamworks.js` last released 0.4.0, 2024-08-06) | Premium price or DLC; Valve's standard revenue share | AI content disclosure; review times stretched in late 2026 |

Ad economics: no trustworthy public eCPM figures for web portals exist. Model ad revenue as
`sessions x ad_impressions_per_session x fill_rate x eCPM / 1000 x your_share`, fill the inputs
from a soft launch, and present results as low / expected / high bands.

Design implications for web economies:
- Sessions are short (minutes), often anonymous and often in incognito windows: progression must
  survive lost saves (cloud saves keyed to a portal account where offered, or short runs).
- Rewarded ads are the main "premium currency" on portals. Treat a rewarded ad like a price:
  cap views per session, never gate core progression behind them, and never show them to
  players flagged as children where the portal forbids it.
- Server-authoritative purchases always: client-side currency in a web game is editable by any
  player with devtools. fly.pieter.com's own code exposed gameplay functions on page globals, and
  players reported others "constantly hitting everyone at the same time" within weeks.

---

## 2. Sponsorships and viral spikes: plan for decay

Reference case, *fly.pieter.com* (Pieter Levels, browser flight sim built with Cursor, Feb 2025):
- Revenue came from in-world ad blimps sold directly to startups, plus a US$29.99 jet.
- **Self-reported** on X: about US$38,000/month on 2025-03-03, then "$87,000 MRR" on 2025-03-11.
  404 Media reported the claims without verifying them.
- By mid-2026 his bio reportedly listed the sim at "$0/m" (unverified): the sponsor slots did not
  renew.

What to take from it: a large existing audience plus a novel ad format produced a spike, not a
business model. When a user cites it, model three scenarios:
```
| Month | Viral (sponsor sell-out) | Typical (small sponsor or none) | Floor (ads only) |
|---|---|---|---|
| 1 | [your audience x sponsor CPM] | [..] | [..] |
| 3 | decay to [x]% | [..] | [..] |
| 6 | [..] | [..] | [..] |
```
Ask: who sells the sponsor slots and renews them? What happens when novelty fades? Is there a
retention loop that brings players back without new press? Distribution, community and retention
outlast novelty, especially in a market flooded with AI-made games (Steam's October 2026 Next
Fest had roughly 7,300 demos against roughly 4,400 in June).

---

## 3. Pricing live-AI features

Any runtime call to an LLM, TTS or image model costs money per use (cloud) or raises the
hardware floor (on-device). The economy must pay for it without turning into a slot machine.

### Step 1: measure the cost
```
cost_per_session = turns x (in_tokens x price_in + out_tokens x price_out) + tts_chars x price_char
cost_per_player_month = cost_per_session x sessions_per_month
```
- Take token counts from a prototype's logs, not guesses; take prices from the vendor's page on
  the day you decide.
- TTS reference point: Inworld TTS-1.5 is listed at roughly US$5-10 per million characters
  (third-party pricing page, read 2026-10-09).
- On-device models (for example NVIDIA ACE's local stack) have no per-call cost; their cost is a
  higher minimum spec and a smaller addressable market. Price that as lost sales, not zero.
- Report the heavy-user tail: the p95 player may cost ten times the median.

### Step 2: choose a recovery model (Valve's four options, from the Steamworks FAQ)
| Option | Fits when | Risk | Guardrails |
|---|---|---|---|
| **Fold into the base price** | Cost per player is small and bounded (turn caps, on-device) | Heavy users erode margin forever | Diegetic daily caps; cheaper model for barks; cache |
| **Microtransactions** (pay per use or AI credits) | Usage varies wildly between players | Feels like paying per sentence; credits become a premium currency | Show real-money price per credit pack; sell packs that match usage (CPC principles); no randomness; never sell AI credits to minors without parental controls |
| **Subscription** for ongoing access | Heavy, recurring use (companions, sandbox sims) | Subscription fatigue; cancellation dark patterns are FTC and EU targets | One-click cancel; clear renewal notice; fair-use limits disclosed up front |
| **One-time DLC** unlocking unlimited use | Bounded content where usage per player is predictable | Unlimited plus cloud cost is an open liability | Fair-use cap in terms; on-device or cheap model behind it; plan for service shutdown |

### Step 3: worked example (assumptions labelled; replace with your measurements)
```
Assumptions (illustrative, not vendor quotes):
  12 conversations/session, 600 input + 80 output tokens each, 8 sessions/month
  price_in = $0.50 / 1M tokens, price_out = $2.00 / 1M tokens, TTS 400 chars/turn at $7.50 / 1M chars
Per session: 12 x (600 x 0.0000005 + 80 x 0.000002) + 12 x 400 x 0.0000075 = $0.0055 + $0.036 = ~$0.042
Per player-month: ~$0.33 median; p95 player at 10x usage: ~$3.30
Decision: TTS dominates; fold text into base price with a 30-turn diegetic daily cap, sell voiced
companion mode as a $4.99 DLC with a stated fair-use limit, or use on-device TTS on capable hardware.
```

### Step 4: disclose and protect
- Steam: live-generated content is a disclosed category; describe guardrails. Microsoft Store
  11.16: in-product reporting. EU AI Act Art. 50(1): tell players the character is AI.
- Server-side quotas per account so scripts cannot burn your API budget.
- A refund and shutdown plan: what buyers keep if the AI service changes price or closes.
- Never let generated dialogue set prices, grant currency or offer discounts outside
  deterministic rules (coordinate the function-call boundary with `game-designer`).

---

## 4. Revenue-share math checklist

For every channel, write down: platform share, payment-processor fees, taxes collected by the
platform vs by you, refund window, payout threshold and currency, and whether you may link to
external payment. Compute net revenue per US$1 of player spend per channel before comparing
channels; gross numbers mislead.
