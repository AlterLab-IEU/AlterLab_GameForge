# Platform Embeds: Discord Activities, Reddit (Devvit Web), Telegram Mini Apps

Facts dated 2026-11-05. Sources: Discord Developer Docs (Activities overview, "How Activities
Work", "Building an Activity", networking guide, "Implementing IAP for Activities"); Telegram
"Mini Apps" and "Payments in Stars" pages; Reddit coverage from the Reddit x Phaser hackathon
announcement (Phaser News, June 2026). Reddit's developer docs could not be fetched for this
skill, so most Reddit specifics are UNVERIFIED.

All three run your web build inside someone else's app. Common rules:
- You need a small backend (token exchange, signature validation, purchase verification).
- The host controls networking. Design for WebSockets over the host's proxy, not WebRTC.
- Identity is handed to you; treat it as personal data and say so in a privacy notice.
- Purchases are verified server-side, never trusted from the client.

## 1. Discord Activities

Activities are "web apps hosted in an iframe that use the Embedded App SDK to communicate with
Discord clients". They run on desktop, mobile and web Discord clients and are launched by people
in a voice or text channel, so they are social by default.

### Setup (from "Building an Activity")
1. Enable Developer Mode in Discord (User Settings > Advanced).
2. Developer Portal: create an application and pick a development team. A non-distributed
   Activity can only be launched by you and team members.
3. **Installation**: enable both User Install and Guild Install contexts.
4. **OAuth2 > Redirects**: add the placeholder `https://127.0.0.1`. Keep the Client ID in the
   client env (`VITE_CLIENT_ID`) and the **Client Secret only on the server**
   (`DISCORD_CLIENT_SECRET`).
5. `npm install @discord/embedded-app-sdk`.
6. Local dev: expose Vite with `cloudflared tunnel --url http://localhost:5173`.
7. **Activities > URL Mappings**: map prefix `/` to the tunnel (later, your production host).
8. **Activities > Settings**: Enable Activities (creates the default "Launch" entry point command).
9. Launch from the App Launcher in a test server.

Discord's sample projects: the Discord Activity Starter (TypeScript), the Embedded App SDK
Playground, and a Nested Framework App example for engine builds.

### Client flow

```ts
import { DiscordSDK } from '@discord/embedded-app-sdk';

const discordSdk = new DiscordSDK(import.meta.env.VITE_CLIENT_ID);

export async function connectDiscord() {
  await discordSdk.ready();                               // READY payload from the client
  const { code } = await discordSdk.commands.authorize({
    client_id: import.meta.env.VITE_CLIENT_ID,
    response_type: 'code',
    state: '',
    prompt: 'none',
    scope: ['identify', 'guilds', 'applications.commands'],
  });
  // Relative URL: goes through Discord's proxy to your mapped backend.
  const res = await fetch('/api/token', {               // sample code uses '/.proxy/api/token'
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ code }),
  });
  const { access_token } = await res.json();
  const auth = await discordSdk.commands.authenticate({ access_token });
  return auth; // contains the user; key multiplayer rooms by the Activity instance
}
```

The server's `/api/token` route exchanges the `code` for an access token with Discord's OAuth2
token endpoint, using the client secret. Discord's sample uses an Express server on port 3001.
Requesting new scopes later can re-prompt the user.

### Networking inside Discord
- Your Activity is served from `https://<clientId>.discordsays.com/...` through Discord's proxy.
- A Content Security Policy limits requests to your own proxied app; requests to un-mapped external
  URLs fail with `blocked:csp`. Add URL Mappings for each external host you need.
- `patchUrlMappings([{ prefix: '/foo', target: 'foo.com' }])` from the SDK rewrites global
  `fetch`, `WebSocket` and `XMLHttpRequest.prototype.open` for third-party libraries that hardcode
  URLs. It is global; use it only when forking or patching the library is impractical.
- Transport: **WebSockets only**. WebTransport is not yet supported; WebRTC is not supported.
  Traffic passes through Cloudflare Workers, which brings unspecified restrictions.
- Cookies must be set for `<clientId>.discordsays.com` with `SameSite=None; Partitioned`.
- Multiplayer: everyone in the same Activity session should land in the same server room. Key the
  room on the Activity instance identifier the SDK exposes (commonly `discordSdk.instanceId`;
  confirm the property in the SDK reference). Route the server design to `game-multiplayer`.

### In-app purchases
- Enable monetization for the app, then create **SKUs** (premium products). A purchase creates an
  **entitlement**; consumables start unconsumed and should be consumed promptly.
- Client: `getSkus()` for the storefront (map perks by SKU `id`, not name; format prices with
  `PriceUtils.formatPrice`), `startPurchase()` with a SKU id to open the purchase modal, listen for
  `ENTITLEMENT_CREATE`, then refetch entitlements **from your server**.
- "SKUs can never be deleted", so every SKU you publish must map to something forever.
- Discord's rule: client SDK data can be spoofed, so use it optimistically and verify entitlements
  through the Discord HTTP API from your backend ("trust, but verify").
- Revenue share, payout and eligibility requirements: not stated on the IAP page (UNVERIFIED).

### Discord checklist block
```markdown
- [ ] Client secret only on the server; token exchange route works through the proxy
- [ ] URL Mappings cover the game host, API host and any CDN; no `blocked:csp` in console
- [ ] WebSocket multiplayer works via the proxy; no WebRTC/WebTransport dependency
- [ ] Rooms keyed by Activity instance; late joiners sync state
- [ ] Tested on desktop, mobile and browser Discord clients
- [ ] Entitlements verified server-side via the Discord HTTP API before granting perks
- [ ] Privacy notice covers Discord user data you store
```

## 2. Reddit (Devvit Web)

What is reasonably established (secondary sources, 2026):
- Reddit's developer platform, **Devvit**, supports web games through **Devvit Web**: your web
  build runs inside a Reddit post, with Devvit server code for persistence and Reddit APIs.
- Reddit and Phaser ran the "Games with a Hook" hackathon (Jun-Jul 2026) with a Phaser template,
  and explicitly rejected "obvious AI slop".
- Reddit's **Developer Funds** paid developers on engagement milestones; terms after July 2026 are
  UNVERIFIED.

UNVERIFIED in this pass (read developers.reddit.com before building): the scaffolding command,
available templates, size limits, runtime limits, storage APIs, payment options and review process.

Design guidance that holds regardless:
- Build for the feed: one-tap start, readable at small sizes, fast first frame.
- Daily or per-post content (a new puzzle per post, community leaderboards) uses Reddit's
  strength: posts are the distribution and comments are the community.
- Keep the game logic and scores on the Devvit server side; treat the client as untrusted.

## 3. Telegram Mini Apps

Mini Apps are web apps opened inside Telegram from a bot.

### Launching
- Add the script first in `<head>`: `<script src="https://telegram.org/js/telegram-web-app.js"></script>`
  (the docs append a version query string; copy the current tag).
- In @BotFather, set the bot's **Main Mini App**; it opens at `https://t.me/<bot>?startapp`.
- Direct links: `https://t.me/<bot>/<appname>`, with `?startapp=<param>` to pass a start parameter
  (good for referral or level links).
- Other entry points: keyboard and inline buttons, the menu button, inline mode, attachment menu.

### Client API for games

```ts
const tg = (window as any).Telegram.WebApp;
tg.ready();                 // call as soon as essential UI is loaded
tg.expand();                // maximum available height
tg.requestFullscreen?.();   // fullscreen; exitFullscreen() to leave
tg.lockOrientation?.();     // lock to current orientation; unlockOrientation() to release
```

- Home screen: `addToHomeScreen()` and `checkHomeScreenStatus(cb)`.
- Storage: **DeviceStorage** up to 5 MB per user per bot; **SecureStorage** up to 10 items (iOS
  Keychain / Android Keystore); **CloudStorage** up to 1,024 keys with values up to 4,096 chars.
- Motion: `Accelerometer`, `DeviceOrientation`, `Gyroscope` with `start({ refresh_rate })`.

### Validate `initData` on your server (never trust it client-side)
Telegram's procedure: the secret key is HMAC-SHA-256 of the bot token keyed with the constant
`WebAppData`; then HMAC-SHA-256 of the data-check-string with that secret must equal `hash`. The
data-check-string is every received field except `hash`, as `key=value`, sorted alphabetically,
joined with `\n`. Reject stale `auth_date`.

```ts
import { createHmac, timingSafeEqual } from 'node:crypto';

export function validateInitData(initData: string, botToken: string, maxAgeSec = 3600) {
  const params = new URLSearchParams(initData);
  const hash = params.get('hash') ?? '';
  params.delete('hash');
  const dataCheckString = [...params.entries()]
    .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0))
    .map(([k, v]) => `${k}=${v}`)
    .join('\n');
  const secret = createHmac('sha256', 'WebAppData').update(botToken).digest();
  const computed = createHmac('sha256', secret).update(dataCheckString).digest('hex');
  const ok = computed.length === hash.length &&
    timingSafeEqual(Buffer.from(computed), Buffer.from(hash));
  const fresh = Date.now() / 1000 - Number(params.get('auth_date')) < maxAgeSec;
  return ok && fresh ? JSON.parse(params.get('user') ?? 'null') : null;
}
```

Third parties can instead verify the `signature` field with Telegram's Ed25519 public key, without
the bot token. Follow the current docs exactly; field handling has changed over time.

### Payments
- Telegram's rule: "Payments for digital goods and services must be carried out exclusively in
  Telegram Stars." Using other currencies or providers for digital goods means Telegram "cannot
  display your bot or mini-app to mobile users" (app-store rules).
- Use currency `XTR`. `sendInvoice` with an empty `provider_token` works for digital goods; Mini
  Apps typically create an invoice link with the Bot API (`createInvoiceLink`) and open it with
  `Telegram.WebApp.openInvoice(url, callback)`.
- Grant items only after your bot receives the successful-payment update on the server. Store
  `telegram_payment_charge_id`; refunds use `refundStarPayment`.
- Stars can be converted to a reward (Telegram's 2024 announcement describes conversion to TON);
  fees, rates and hold periods sit in the Developer Terms and an image table (UNVERIFIED here).

### Telegram checklist block
```markdown
- [ ] `ready()` called after essential UI loads; layout handles expand/fullscreen and safe areas
- [ ] `initData` validated server-side (HMAC or Ed25519) with an `auth_date` freshness check
- [ ] Digital goods sold only in Stars (`XTR`); items granted on server-confirmed payment
- [ ] Refund path implemented (`refundStarPayment`); charge ids stored
- [ ] Storage within DeviceStorage/CloudStorage limits; no secrets in client storage
- [ ] Tested in Telegram iOS, Android and Desktop clients
```
