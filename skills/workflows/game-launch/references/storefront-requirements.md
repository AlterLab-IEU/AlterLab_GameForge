# Storefront Requirements (verified November 2026)

Platform rules change several times a year. Every figure below was checked against the platform's
own documentation or named coverage in November 2026. Before quoting a deadline or size to the
user, re-open the source with WebFetch. Browser releases (itch.io HTML5, Poki, CrazyGames, Discord
Activities, YouTube Playables, PWA) live in `/gameforge:game-web-publish`.

## 1. Steam

### Account, fee and payout
- **Steam Direct fee:** US$100 per app, not refundable, recouped once the app reaches US$1,000 in
  adjusted gross revenue from Steam store and in-app purchases (Steamworks "Steam Direct Fee").
- Bank, tax and identity verification must be complete before you can release. Start it when you
  create the Steamworks account; it is a frequent surprise blocker for first-time developers.

### Store page timing
- The page must be public as **Coming Soon for at least two weeks** before release (Steamworks
  release docs). Valve recommends putting it up "as soon as you're ready and able".
- Submit the store page for review **at least 7 business days** before you want it live; review
  typically takes 3-5 business days. After approval, press "Post as Coming Soon".
- Once the page is live and the release date is **within 14 days**, you cannot change the date
  without contacting Valve.
- Release becomes possible once the store page is approved, has been Coming Soon for two weeks, and
  the build is approved; the button is "Release App".

### Store graphical assets (Steamworks "Store Graphical Assets")

| Asset | Size (px) | Rules |
|---|---|---|
| Header capsule | 920 x 430 | Key art plus logo; no text beyond the title; legible logotype |
| Small capsule | 462 x 174 | Logo nearly fills it; must read at tiny sizes |
| Main capsule | 1232 x 706 | Same text rules as header |
| Vertical capsule | 748 x 896 | Same text rules as header |
| Screenshots | At least 5, 1920 x 1080 minimum, 16:9 | Gameplay only: no concept art, pre-rendered stills, awards or marketing copy; menus only if they are a distinctive part of play; mark at least four as suitable for all ages |
| Page background | 1438 x 810 (optional) | Ambient; must not compete with page content |
| Bundle header | 707 x 232 (bundles only) | Branding, legible logo |

Library assets (Steamworks "Library Assets"): library capsule 600 x 900 (title-only text), library
header 920 x 430 (falls back to the header capsule), library hero 3840 x 1240 (no text at all;
keep key content inside the centered 860 x 380 safe area), library logo transparent PNG 1280 px
wide and/or 720 px tall, logotype only. Use Artwork Overrides for event or update messaging instead
of editing the standard capsules.

### Review: what Valve checks
Store page:
- Only features and content available at launch
- Capsules show a readable product title or logo
- Screenshots contain gameplay only
- Detailed, coherent description with no links to other websites

Build:
- Starts properly on every operating system listed on the store page
- Every feature the store page lists is implemented
- In-game transactions use the Steam Wallet

Review is one-time: later updates do not need re-review. Store page and build each take
typically 3-5 business days; plan for at least 7. In November 2026 Valve said new-title reviews
were taking up to 12 business days against a 3-5 day goal, and added pre-review checks
(Engadget, 2026-11-04):
- Run the game through Steam for at least five minutes before submitting
- Confirm common redistributables (DirectX, Visual C++)
- Confirm achievements are ready
- Confirm Steam Cloud save paths
- Categorize screenshots (gameplay, menus, concept art, cinematics)

AI content is checked at this pre-release review against what the Content Survey declared. See
`compliance-checklist.md` row C1.

### Steam Next Fest (Steamworks "Steam Next Fest")
- Three editions a year: February, June, October. Upcoming editions listed in November 2026:
  February 2027 and June 2027 (dates on Valve's Upcoming Events page).
- Eligibility: Steamworks account in good standing; base-game store page published and public;
  a publicly playable demo by the time the fest begins; game not released before that edition ends;
  not a prologue or short-form version of a game already on Steam.
- **A title may participate in only one Next Fest.** Choose the edition you can arrive at with your
  best demo, ideally a few months before launch so wishlists convert at release.
- Demo build review: submit at least 3 weeks before the fest, or 5 weeks for Press Preview.
- Registration closes weeks before each edition (the October 2026 edition closed registration at the
  end of August); check the edition page. Livestreaming during the fest is optional.
- Scale context: roughly 7,300 demos in October 2026 versus roughly 4,400 in June 2026 (press and
  analyst counts, no official Valve total). Filtering by genre and theme improved in October 2026,
  but a demo still has to earn attention in its first minutes.

### Wishlists (Steamworks "Wishlists")
- Wishlisters receive an email and/or mobile push at release, at the Early Access to full release
  transition, and for discounts of **20% or more** that last over 8 hours and cover at least the
  lowest-priced package.
- There is no minimum wishlist count before Steam shows a game, and Valve says there is no formula
  that predicts sales from wishlists. Track your own wishlist-to-purchase conversion after each
  event or discount and plan from that, not from community rules of thumb.

### Steam Deck, Early Access, web tech
- **Steam Deck:** Valve rates compatibility (Verified, Playable, Unsupported, Unknown). Do not claim
  Deck support on the page unless you test on a Deck: controller-only navigation, readable text at
  1280 x 800, no launcher that needs a mouse.
- **Early Access:** same two-week Coming Soon rule before the game becomes playable. Write the Early
  Access questions on the store page honestly (current state, planned length, price changes).
- **Web technology on Steam:** browser games usually ship to Steam inside Electron with a Steamworks
  binding. `steamworks.js` has had no npm release since 0.4.0 (2024-08-06); `steamworks-ffi-node`
  exists but its maturity is unverified. Tauri uses the OS webview (WebView2, WKWebView,
  WebKitGTK), so test Linux and Steam Deck carefully. Packaging details: `/gameforge:game-web-publish`
  and `/gameforge:game-ci-pipeline`.

## 2. Epic Games Store and GOG

- **Epic Games Store:** self-publishing through the Epic Developer Portal; age ratings through IARC.
  Since June 2025 Epic takes a 0% store fee on the first US$1M of revenue per app per year, then
  the standard 88/12 split (Epic announcement, 2025-05-01). Unreal Engine titles pay a 3.5% royalty
  instead of 5% under the Launch Everywhere program when they ship on EGS at the same time or
  first, and revenue from EGS sales is royalty-free (Unreal licence terms).
- **GOG:** curated; submit through GOG's developer submission process well before your target date.
  DRM-free builds and an offline installer are expected.
- Keep feature parity claims honest per store: achievements, cloud saves and overlays are
  per-platform integrations, each needing its own test pass.

## 3. Consoles

- Access comes through the platform programs (ID@Xbox, PlayStation Partners, the Nintendo Developer
  Portal). Requirement checklists (Sony TRC, Xbox Requirements, Nintendo Lotcheck guidelines) and
  certification timelines are under NDA; take them from the partner portal or your account manager,
  never from blog posts.
- Run an internal pre-certification pass against the current checklist before the first submission
  and budget at least one resubmission cycle.
- Digital storefront ratings come from IARC on PlayStation Store, Nintendo eShop and the Microsoft
  Store (Xbox); physical releases and Japan (CERO) need the boards directly.
- Microsoft Store policy 11.11 requires an accurate IARC questionnaire at submission and prompt
  updates when content changes; policy 11.16 covers live generative AI (see compliance row C2).
  Microsoft defines "Store" to include Xbox-branded stores.
- Xbox shows the ESA Accessible Games Initiative tags on store pages and audits them; tags can be
  revoked if the shipped game does not match.
- Patches go through certification again; know each platform's expedited path for critical fixes
  before launch week.

## 4. Mobile

### Apple App Store
- **Build floor:** since 2026-04-28 uploads must be built with Xcode 26 or later using the iOS 26
  SDK (or the matching 26 SDK for other Apple platforms). The deployment target can be lower.
- **Age ratings:** Apple's own questionnaire. Since July 2025 the tiers are 4+, 9+, 13+, 16+ and 18+;
  developers had to answer the new questions by 2026-01-31 to keep submitting updates.
- **Privacy:** privacy details ("nutrition labels") must match what the app and its SDKs collect;
  a privacy policy URL is mandatory. Disclose and get permission before sharing personal data with
  third-party AI services.
- **Guideline 2.5.2:** apps that download and execute code are at risk; Apple blocked updates to
  vibe-coding app builders in March 2026. An in-game level or game *maker* that runs user code
  needs careful review.
- Metadata limits (name and subtitle 30 characters each, keywords 100) and screenshot sizes are in
  App Store Connect; check the current device list when you capture.

### Google Play
- **Target API:** since 2026-08-31, new apps and updates must target Android 16 (API 36); existing
  apps must target at least API 35 to stay available to new users on newer Android versions (Wear
  OS, TV, Automotive and XR have lower floors). This moves every year; check the Play Console page.
- Content rating via the IARC questionnaire in Play Console; Data safety form must match SDK
  behavior; privacy policy URL mandatory.
- **AI-Generated Content policy:** apps with generative AI features must prevent offensive or
  deceptive output and let users report it; no labelling mandate was found as of November 2026.

## 5. itch.io (downloadable builds)

- Generative-AI content must be disclosed on the project; the disclosure feeds the "no AI" filter,
  which extended to search on 2026-11-03 after itch.io removed terabytes of AI-generated spam
  uploads. Mass-produced AI pages are treated as spam.
- Upload per-platform builds with correct platform tags; use butler, itch.io's command-line
  uploader, so patches ship as small diffs. HTML5 builds: `/gameforge:game-web-publish`.

## 6. Cross-store store-page checklist

- One-sentence hook in the first line of the description; the feature list after it
- Tags and genre set to what the game is, not to what is trending
- Screenshots show the first hour, not only the late game; mismatch is a refund driver
- System requirements tested on matching hardware
- Every language on the page is actually shipped and tested (`/gameforge:game-localization-manager`)
- Accessibility features listed honestly; store tags only for features the build meets
- AI disclosure on every store that asks for one, consistent across stores
