# Privacy and Consent for Game Telemetry

Read this before implementing consent or choosing what to collect. This is engineering guidance for
building compliant pipelines, not legal advice; have counsel review the final design, especially
for children's games and for markets you do not know.

## 1. What counts as personal data

Under the GDPR, pseudonymous identifiers are still personal data if they can single out a player or
device. In practice treat all of these as personal: player IDs stored on the device, platform
account IDs (Steam IDs), device and advertising IDs, IP addresses, precise location, free-text
fields (chat, names, feedback), crash reports with file paths or memory contents, and combinations
of fine-grained properties that identify someone.

Aggregate counts with no identifier (for example "room 4 completed: +1") are the low-risk end.

## 2. Regimes that shape game telemetry

| Regime | What it means for telemetry |
|---|---|
| **EU/EEA GDPR + ePrivacy rules** | Storing or reading identifiers on a device for non-essential purposes such as analytics generally needs prior consent; the analytics processing itself needs a lawful basis (usually that consent). Players can withdraw at any time, and access or erasure requests must be answered without undue delay and within one month. Data minimization and purpose limitation apply |
| **GDPR Article 8 (children)** | Where consent is the basis for an online service offered directly to a child, parental consent is needed below the national age, which member states set between 13 and 16 |
| **UK GDPR, PECR and the ICO Children's Code** | Similar consent model; services likely to be accessed by children should be high-privacy by default (profiling and geolocation off by default) |
| **US COPPA (amended rule)** | Applies to services directed at children under 13 or with actual knowledge of under-13 users. Persistent identifiers are personal information. The amended rule was published 2025-04-22, took effect 2025-06-23, and required compliance by 2026-04-22. Behavioral tracking of children needs verifiable parental consent; the "support for internal operations" exception is narrow, so get counsel before relying on it |
| **US state privacy laws** | Several states give opt-out rights and require notices; honor opt-out signals where required |
| **Apple** | ATT prompt only for tracking across other companies' apps and websites (for example ad attribution). App Store privacy "nutrition labels" and a privacy manifest (`PrivacyInfo.xcprivacy`) must describe data your app and SDKs collect |
| **Google Play** | The Data safety section must match what the shipped SDKs collect |
| **Platforms and portals** | Poki forbids external requests; consoles have their own certification rules on data and account linking. Check each target |

## 3. Consent UX that holds up

- Ask before any optional telemetry starts, at first launch or first relevant moment.
- "Decline" is as easy and visible as "Accept"; no pre-ticked boxes; no nagging after a decline.
- Granular choices: gameplay analytics, crash reports, marketing are separate.
- The game is fully playable after declining. Do not reward accepting; incentives undermine
  "freely given" consent.
- A settings entry to change the choice any time; withdrawing stops collection immediately and
  triggers deletion of data tied to the player's ID.
- Store the decision with a version number; re-ask only when the purposes change.
- Plain-language notice: what, why, who processes it, how long, how to delete.
- Consent screens are UI: localize them (`game-localization-manager`) and make them accessible
  (`game-accessibility-specialist`).

## 4. Data minimization defaults

| Setting | Default |
|---|---|
| Autocapture, heatmaps, session replay | Off |
| IP addresses | Not stored, or truncated at ingestion |
| Player ID | Random UUID generated on device after consent; never the Steam ID or email |
| Free text | Never in events; feedback collected separately with its own notice |
| Location | Country from locale or store region, not geolocation |
| Retention | Raw events 13 months, aggregates indefinitely (house default; set yours and enforce it with automatic deletion) |
| Debug logging in release builds | Off |

## 5. SDK consent hooks

| SDK | Pattern |
|---|---|
| Any SDK | Do not initialize until consent; on withdrawal, call the SDK's stop or opt-out method, then its deletion API if it has one, or delete via your backend |
| Unity Analytics | Unity 6.2+ with Analytics SDK 6.1+: Developer Data framework EndUserConsent API (analytics intent granted or revoked). Earlier versions: `AnalyticsService.Instance.StartDataCollection()` after opt-in each session. Both: `AnalyticsService.Instance.RequestDataDeletion()`; consent must be denied before a deletion request on the newer API; the SDK persists deletion state in PlayerPrefs, so `PlayerPrefs.DeleteAll()` can interfere |
| PostHog (web) | Initialize opted out (`opt_out_capturing_by_default: true`), use `persistence: 'memory'` (or `cookieless_mode`) until consent, then `posthog.opt_in_capturing()`; `opt_out_capturing()` on withdrawal |
| Firebase / Google Analytics | `setConsent` (Consent Mode) with analytics storage denied by default for EEA users |
| GameAnalytics | Initialize only after consent; check the SDK docs for your engine for its event-submission toggle and data deletion process |
| Sentry | `sendDefaultPii: false`, scrub paths and user names in `beforeSend`, sample rates set deliberately |

Verify method names against the SDK version you install; these APIs change.

## 6. Paperwork that engineers should produce

- **Data inventory** (`design/analytics-plan.md` section): each event or data type, purpose, legal
  basis, processor, region, retention.
- **Processor list:** every vendor receiving data (analytics, crash, LLM used for feedback analysis)
  with its data-processing terms.
- **Deletion runbook:** how a deletion request is executed for each processor, and who does it.
- **Store forms:** App Store privacy labels, Play Data safety, console submissions, all consistent
  with the code.

## 7. Children

If children may play, default to the strictest posture across your markets:
- no advertising identifiers, no cross-app tracking, no behavioral profiling;
- aggregate, identifier-free counts only, unless you implement verifiable parental consent;
- no free-text chat collection; no social features that expose children's data;
- age gates that are neutral (do not hint the "right" answer) and do not retain the birth date
  beyond what is needed.
