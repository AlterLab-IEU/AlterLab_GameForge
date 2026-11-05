# Web Multiplayer (Browser Games)

Facts dated 2026-11-05. Sources: Colyseus docs and the "Colyseus 0.18 is here" post (2026-08-20);
npm registry metadata queried 2026-11-05 (versions below); Cloudflare's PartyKit/partyserver README
and Durable Objects WebSocket guide; Supabase Realtime limits page; MDN browser-compat-data 8.1.8
and WebKit's Safari 26.4 notes for WebTransport; Discord's Activities networking guide.

## 1. Options

| Stack | Version (npm, 2026-11) | Model | Good for |
|---|---|---|---|
| Colyseus | `@colyseus/core` 0.18.26; client `@colyseus/sdk` 0.18.9 | Authoritative Node rooms, Schema state sync, built-in prediction and lag compensation (0.18) | Most realtime web games; self-host free or Colyseus Cloud |
| Cloudflare `partyserver` + `partysocket` | 0.5.10 / 1.3.0 | A Durable Object per room, WebSockets, your server code at the edge | Party games, lobbies, Discord Activities, turn-based |
| Geckos.io | 3.1.0 | WebRTC DataChannels from a Node server (UDP-like delivery) | Fast action where WebSocket head-of-line blocking hurts |
| Playroom Kit | `playroomkit` 0.0.97 | Hosted lobby and rooms (`insertCoin()`), host-driven state; MAU-based pricing (secondary) | Jams, casual co-op, quick prototypes |
| SpacetimeDB | `spacetimedb` 2.14.1 (2.0 on 2026-02-20) | Database with server modules (TypeScript supported) and a browser SDK with React hooks | Persistent worlds, MMO-lite experiments |
| Nakama | Apache-2.0 | Game backend: matchmaker, authoritative matches, leaderboards; JS client | Full backend, any engine |
| Supabase Realtime | see limits below | Broadcast/Presence relay over WebSockets | Light co-op, presence, turn-based with database validation |

Do not use `colyseus.js`: it is frozen at 0.16.22. Use `@colyseus/sdk`.

## 2. Transports in the browser

| Transport | Delivery | Support | Notes |
|---|---|---|---|
| WebSocket | Reliable, ordered (TCP) | Everywhere; the only transport Discord Activities allow | Head-of-line blocking under loss; fine for 10-20 Hz party games |
| WebRTC DataChannel | Configurable unreliable/unordered | All major browsers | Needs signaling and STUN/TURN; TURN relays cost bandwidth; not allowed in Discord Activities |
| WebTransport | Streams and unreliable datagrams over HTTP/3 | Chrome 97+, Firefox 114+, **Safari 26.4+ (2026-03-24)** | Needs an HTTP/3 server; not yet supported through Discord's proxy; keep a WebSocket fallback |

Default: WebSocket. Move to WebTransport datagrams or WebRTC only when measured loss causes visible
stalls in a fast action game.

## 3. Colyseus 0.18

Scaffold a server with `npm create colyseus-app@latest`, then adapt. The sketch below follows the
0.18 docs and release post; check signatures against the generated template.

```ts
// server/src/rooms/ArenaRoom.ts
import { Room, Client } from 'colyseus';
import { schema, t } from '@colyseus/schema';

export const Player = schema({ x: t.number().default(0), y: t.number().default(0) }, 'Player');
export const ArenaState = schema({ players: t.map(Player) }, 'ArenaState');

const MAX_SPEED = 200;          // units per second
const MAX_MSGS_PER_SEC = 60;

export class ArenaRoom extends Room {
  maxClients = 8;
  state = new ArenaState();
  private inputs = new Map<string, { dx: number; dy: number; seq: number; budget: number }>();

  onCreate() {
    this.onMessage('input', (client: Client, msg: { dx: number; dy: number; seq: number }) => {
      const s = this.inputs.get(client.sessionId);          // 0.18: client.sessionId, not client.id
      if (!s || s.budget < 1 || ![msg?.dx, msg?.dy, msg?.seq].every(Number.isFinite) || msg.seq <= s.seq) return;
      s.budget -= 1;
      const len = Math.hypot(msg.dx, msg.dy) || 1;
      s.dx = msg.dx / Math.max(1, len);                      // clamp magnitude
      s.dy = msg.dy / Math.max(1, len);
      s.seq = msg.seq;
    });
    // 0.18 renamed this to setTimestep(); the old name still works.
    this.setSimulationInterval((dtMs) => this.step(dtMs / 1000), 1000 / 30);
  }

  onJoin(client: Client) {
    this.state.players.set(client.sessionId, new Player());
    this.inputs.set(client.sessionId, { dx: 0, dy: 0, seq: -1, budget: MAX_MSGS_PER_SEC });
  }

  onLeave(client: Client, code: number) {
    this.state.players.delete(client.sessionId);
    this.inputs.delete(client.sessionId);
  }

  private step(dt: number) {
    this.state.players.forEach((p, id) => {
      const s = this.inputs.get(id)!;
      s.budget = Math.min(MAX_MSGS_PER_SEC, s.budget + MAX_MSGS_PER_SEC * dt);
      p.x += s.dx * MAX_SPEED * dt;                         // add collision/bounds here
      p.y += s.dy * MAX_SPEED * dt;
    });
  }
}
```

```ts
// client/src/net.ts
import { Client, Callbacks } from '@colyseus/sdk';

const client = new Client(import.meta.env.VITE_SERVER_URL);   // wss:// in production
export const room = await client.joinOrCreate('arena', { token: sessionToken });
export const mySessionId = room.sessionId;

const callbacks = Callbacks.get(room);
callbacks.onAdd('players', (player, sessionId) => spawnAvatar(sessionId, player));
// See the SDK docs for the matching remove/change callbacks.

let seq = 0;
export function sendInput(dx: number, dy: number) {
  room.send('input', { dx, dy, seq: seq++ });
}
```

0.18 additions worth knowing (from the release post):
- **Prediction and lag compensation built in**. Client: `Predict.get(room, { mode: 'lerp', delay: 100 })`
  and `predict.reconciler(self, { input, step, smoothMs: 65 })`. Server: `this.defineInput(...)`
  with a buffer size and a `sanitize` block, `this.allowRewindState({ maxRewindMs: 500 })`,
  `this.setFixedTimestep(...)`, and `rewind.lastSeenBy(sessionId)` for hit checks. Read the
  prediction docs for full signatures before relying on the shapes shown here.
- **Request/response**: `await room.request('get-profile', { userId: 42 })` on the client; the
  server handler returns a value or calls `ctx.reject('reason')` (JS/TS SDK only so far).
- **Schema 5**: `schema({...}, 'Name')` with `t.number()`, `t.map()`, plus `t.quantized()`,
  `t.angle()`, `.patchOnly()`, `.fullStateOnly()`, `view.subscribe()` (per-client views), and an
  experimental `t.stream()`. Decorators still work. Max 63 fields per Schema.
- **Debug**: `import '@colyseus/sdk/debug'` adds a telemetry panel and a latency simulator.
- **Breaking**: `client.id` removed (use `client.sessionId`); `setMetadata()` replaces instead of
  merging; fossil-delta serializer removed; `@colyseus/auth` password hashes need a reset.
- A `WebRTCPlugin` provides peer-to-peer signaling; the browser SDK is about 58 KB gzipped.

## 4. Cloudflare partyserver and Durable Objects

```ts
// worker/src/index.ts
import { routePartykitRequest, Server, type Connection } from 'partyserver';

export class GameRoom extends Server {
  onConnect(conn: Connection) {
    conn.send(JSON.stringify({ type: 'welcome', id: conn.id }));
  }
  onMessage(conn: Connection, message: string) {
    const msg = safeParse(message);               // validate shape and size; drop otherwise
    if (!msg || !rateOk(conn.id)) return;
    applyIntent(this.name, conn.id, msg);         // room-authoritative logic
    this.broadcast(JSON.stringify(stateDelta()), [conn.id]);
  }
}

export default {
  async fetch(request: Request, env: Env) {
    return (await routePartykitRequest(request, env)) || new Response('Not Found', { status: 404 });
  },
};
```

```ts
// client
import PartySocket from 'partysocket';
const socket = new PartySocket({ host: 'game.example.com', party: 'game-room', room: roomCode });
socket.addEventListener('message', (e) => onServerMessage(JSON.parse(e.data)));
```

- `wrangler.jsonc` declares the Durable Object binding (`name` and `class_name`) and a migration
  with `new_sqlite_classes`. `party` is the kebab-cased binding name.
- **Hibernation**: with the WebSocket Hibernation API, an idle Durable Object leaves memory while
  sockets stay open, and duration (GB-s) charges stop accruing. Alarms, incoming requests and
  `setTimeout`/`setInterval` prevent hibernation. A 20 Hz tick loop keeps the room awake and
  billable for the whole match; turn-based and lobby rooms benefit most.
- Per-connection attachments are capped at 16,384 bytes. Batch small messages into fewer frames.
- PartyKit (acquired by Cloudflare, 2024-04-05) lives on as these libraries; the old `partykit`
  CLI has been at 0.0.115 since 2025-05-21 and legacy partykit.io hosting status is UNVERIFIED.
- Public example: the Vibe Jam 2026 gold winner, *A Game About Capybaras Delivering Food*, built
  with Claude Code, used a single Cloudflare WebSocket lobby; its developer called multiplayer
  "simpler than expected for a jam" (Wccftech interview, Jul 2026).

## 5. Supabase Realtime limits (read 2026-11-05)

| Limit | Free | Pro | Team |
|---|---|---|---|
| Concurrent connections | 200 | 500 | 10,000 |
| Messages per second | 100 | 500 | 2,500 |
| Channel joins per second | 100 | 500 | 2,500 |
| Presence messages per second | 20 | 50 | 1,000 |
| Broadcast payload | 256 KB | 3,000 KB | 3,000 KB |

- Put per-tick state on **Broadcast**; Presence is for who is online, and its limits are low.
- 100 messages per second on Free is the whole project's budget: four players sending 20 Hz input
  already use 80. Do the math before choosing it for realtime play.
- Realtime is a relay, not an authority. Pair it with database functions and row-level security
  for anything that matters (scores, inventory), and never ship a service-role key to the client.

## 6. Web security checklist

```markdown
- [ ] Server validates every message: schema (e.g. zod), size cap, types, ranges, sequence numbers
- [ ] Per-connection rate limits; per-IP room and connection caps
- [ ] Join requires a token issued by your backend (or the platform's verified identity)
- [ ] Origin checked on WebSocket upgrade; wss:// only
- [ ] Player names and chat sanitized before rendering into the DOM (XSS)
- [ ] No API keys, service-role keys or admin routes in the client bundle
- [ ] Game state is not exposed as mutable `window` globals; even if it is, the server ignores it
- [ ] Scores and unlocks computed or verified server-side
- [ ] Single-player still works when the server is down (jam builds outlive their backends)
```
