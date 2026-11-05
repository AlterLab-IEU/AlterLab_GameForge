# Analytics and Telemetry SDK Options (verified November 2026)

Read this when choosing a stack. Names and versions were checked against vendor docs, GitHub tags
and the npm registry in November 2026; re-check before installing, because analytics SDKs change
quickly. Pricing and free-tier limits change even faster and are deliberately not listed: read the
vendor's pricing page on the day you decide.

## Event analytics

| Option | Engines / platforms | Notes |
|---|---|---|
| **GameAnalytics** | Official SDKs for Unity, Unreal, **Godot** (GDExtension addon, requires Godot 4.5+, installed from GitHub, not the Asset Library), Roblox, GameMaker, Defold, Construct, Cocos2D, Flutter, Cordova, Android, plus an open-source **JavaScript** SDK (`gameanalytics` on npm, 5.0.0) and a Collection API | Purpose-built game model (progression, resource, business, design and error events). Initialize only after consent. The Godot web export needs a script tag in the HTML head per GameAnalytics' docs |
| **Unity Analytics** (Unity Gaming Services) | Unity | Tight UGS integration and dashboards. Consent API depends on version: on Unity 6.2+ with Analytics SDK 6.1+, consent goes through the Developer Data framework's EndUserConsent API (set the analytics intent granted or revoked); on older versions call `AnalyticsService.Instance.StartDataCollection()` every session after opt-in. `RequestDataDeletion()` handles erasure. Unity states the SDK does not manage privacy compliance for you |
| **PostHog** | Web (`posthog-js`, 1.446 on npm), Unity (`PostHog/posthog-unity`, v1.1.x), **Godot** (`PostHog/posthog-godot`, 0.1.x, labelled experimental, Godot 4.5+, session replay excluded), server SDKs | Product analytics plus feature flags. Offers EU cloud hosting and self-hosting. For games, disable autocapture and session replay unless the plan says otherwise; start opted out (`opt_out_capturing_by_default`) and opt in on consent |
| **Firebase / Google Analytics** | Android, iOS, Unity, C++, web (`firebase` 13.x) | Strong for mobile; pairs with BigQuery export. Use `setConsent` / Consent Mode for EEA users |
| **Talo** | Godot and Unity plugins; open-source, self-hostable backend (`TaloDev/backend`) | Game backend with events, players, leaderboards and saves; good when you want everything first-party |
| **Own collector** | Anything that can POST JSON | A small endpoint (Cloudflare Worker, serverless function, tiny server) writing to Postgres, ClickHouse or object storage, with Grafana or Metabase on top. Maximum control; you own uptime, security and deletion requests |
| **Cookieless page analytics** (for example Plausible or Umami) | Web pages | Aggregate traffic and referrers for the landing or game page; not gameplay telemetry |

## Crash and error reporting

| Option | Engines | Notes |
|---|---|---|
| **Sentry** | Godot (`getsentry/sentry-godot`, GDExtension, 2.4.0 released 2026-10-21; 1.x and later require Godot 4.5+), Unity, Unreal, browser (`@sentry/browser` 11.x), native | Turn on PII scrubbing; strip user names from file paths; decide with counsel whether crash reports need opt-in in your markets |
| Engine-native | For example Unreal's Crash Reporter pointed at an endpoint you control | Check what each sends by default and whether the service is still supported for your engine version |

## Platform and storefront data (no SDK needed)

| Source | What you get |
|---|---|
| Steamworks reports | Wishlists, sales, refunds with reason codes, regional splits |
| Steam global achievement stats | Public percentages per achievement: a free chapter funnel if achievements map to progress |
| Steam user reviews API | Reviews as JSON for feedback analysis (see `ai-feedback-summarization.md`) |
| Portal dashboards (Poki, CrazyGames, itch.io) | Plays, play time, sometimes retention, for traffic you cannot instrument |

## Portal and platform rules that change the answer

- **Poki** forbids external requests from the game (requirements page, November 2026): no
  third-party analytics in the Poki build. Use the Poki dashboard and compile your wrapper to a no-op.
- **CrazyGames** requires its SDK for ads and a `gameplayStart`-style event; check its current docs
  before adding other network calls.
- **YouTube Playables, Discord Activities, Reddit Devvit:** each has its own SDK and data rules;
  route platform specifics to `game-web-publish`.
- **iOS:** App Store privacy labels and the privacy manifest must describe what your SDKs collect;
  ATT is required only for cross-company tracking.
- **Google Play:** the Data safety form must match the SDKs you ship.

## Choosing quickly

| Situation | Pick |
|---|---|
| Solo dev, premium Steam game, Godot | GameAnalytics (Godot SDK) or PostHog; Sentry for crashes; Steamworks for sales |
| Unity team already using UGS | Unity Analytics with the version-correct consent API; Sentry optional |
| Web game on your own domain | Own collector or PostHog EU, behind the consent-gated wrapper |
| Web game on portals | Portal dashboards; no third-party calls where forbidden |
| Children may play | Minimal first-party aggregate counts, no persistent identifiers without verifiable parental consent; counsel review |
| Strict data sovereignty | Talo or own collector, self-hosted in the region you need |
