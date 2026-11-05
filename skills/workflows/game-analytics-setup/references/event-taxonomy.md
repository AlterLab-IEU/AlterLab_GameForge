# Event Taxonomy, KPI Mapping and a Consent-Gated Telemetry Wrapper

Read this before writing instrumentation. The taxonomy file in the project
(`design/analytics-events.md`) is the source of truth; code follows it, never the reverse.

## 1. Conventions

- **Names:** `domain.object.action`, lowercase, dot-separated. Domains: `game`, `run`, `progress`,
  `ui`, `economy`, `social`, `system`, `consent`, `tutorial`, `upgrade`.
- **Verbs:** `start`, `complete`, `fail`, `end`, `open`, `close`, `change`, `select`, `earn`,
  `spend`, `unlock`, `error`. Never mix `begin` and `start`.
- **Standard properties (every event):** `event_version` (int), `build` (str), `platform` (enum),
  `session_id` (uuid, new per launch), `t` (ms since session start), `locale` (BCP 47). Add
  `player_id` (random uuid stored locally) **only after analytics consent**.
- **Types:** numbers as numbers, booleans as booleans, enums as fixed string sets documented in the
  taxonomy file. No free text, no player names, no chat, no file paths (they often contain the OS
  user name).
- **Versioning:** bump `event_version` when meaning or properties change; never silently reuse a
  name with different semantics.

## 2. Starter taxonomy: short web game (10-15 events)

| Event | Properties | Feeds KPI |
|---|---|---|
| `game.boot.start` | `renderer` (webgl2/webgpu), `device_class` (low/mid/high), `referrer_host` | Load-to-play, tech failure |
| `game.boot.ready` | `load_ms` | Time to first play |
| `game.play.start` | `input` (kb/touch/pad) | Load-to-play |
| `run.start` | `run_index`, `seed` | Runs per session |
| `run.end` | `run_index`, `result` (win/fail/quit), `time_s`, `score` | First-round length, retry rate |
| `run.fail` | `cause` (enum), `room_index` | Hot spots |
| `ui.share.click` | `target` (copy_link/native) | Sharing |
| `ui.settings.change` | `setting` (enum), `value` (enum or number) | Option usage |
| `system.render.init_fail` | `api` (webgpu/webgl2), `reason` (enum) | Tech failure |
| `system.webgl.context_lost` | `scene` | Tech failure |
| `system.error` | `kind` (enum), `fingerprint` (hash, no stack text) | Error rate |
| `consent.change` | `analytics` (bool), `version` (int) | Compliance |

## 3. Starter taxonomy: premium game (20-40 events)

| Event | Properties | Feeds KPI |
|---|---|---|
| `game.session.start` / `end` | `duration_s`, `end_reason` (quit/crash/suspend) | Session length, crash-free |
| `tutorial.start` / `complete` / `skip` | `step_reached` | Tutorial completion |
| `progress.chapter.start` / `complete` | `chapter_id`, `playtime_min` | Chapter funnel |
| `progress.level.start` / `complete` / `fail` | `level_id`, `attempt`, `time_s`, `cause` | Hot spots |
| `progress.level.quit_after_fail` | `level_id`, `seconds_since_fail` | Rage-quit hot spots |
| `progress.credits.reach` | `playtime_min`, `difficulty` | Completion rate |
| `upgrade.select` / `item.equip` | `id`, `run_index` | Build diversity |
| `economy.currency.earn` / `spend` | `currency`, `amount`, `source`/`sink` | Economy balance |
| `ui.settings.change` | `setting`, `value` | Option usage (accessibility) |
| `ui.difficulty.change` | `from`, `to`, `level_id` | Difficulty fit |
| `system.performance.sample` | `fps_p50`, `fps_p5`, `gpu_tier`, `scene` (sampled, e.g. once per 5 min) | Performance by device |
| `system.crash` (from crash reporter) | `fingerprint`, `build` | Crash-free sessions |
| `consent.change` | `analytics`, `crash`, `version` | Compliance |

## 4. Mapping to SDK event models

| SDK | How it models events | Mapping |
|---|---|---|
| GameAnalytics | Typed events: progression (start/complete/fail with up to three progression levels), resource (source/sink with currency and item), business, design (custom, colon-delimited hierarchy), error | `progress.level.*` -> progression; `economy.*` -> resource; everything else -> design events such as `run:fail:room04` |
| Unity Analytics (UGS) | Custom events with parameters defined in the dashboard schema | Register each event and parameter in the dashboard first; undeclared parameters are rejected |
| PostHog | Free-form event name + properties | Use names as-is; turn off autocapture for games |
| Firebase / Google Analytics | Event name (snake_case, length limits) + parameters | Replace dots with underscores: `run_room_complete` |
| Own collector | JSON lines to your endpoint | As-is |

Check the current SDK docs for name length and property-count limits before finalizing names.

## 5. Consent-gated telemetry wrapper

One wrapper, called from gameplay code; no direct SDK calls anywhere else. It drops events until
consent, batches, never blocks the frame, and never throws into gameplay.

### TypeScript (web)

```ts
type Props = Record<string, string | number | boolean>;
const ENDPOINT = '/collect';            // your collector or a vendor SDK adapter
const queue: object[] = [];
let consent = false;
const sessionId = crypto.randomUUID();
const t0 = performance.now();

export const Telemetry = {
  setConsent(granted: boolean) {
    consent = granted;
    try { localStorage.setItem('consent.analytics', granted ? '1' : '0'); } catch {}
    if (!granted) queue.length = 0;     // withdraw: drop anything pending
    this.track('consent.change', { analytics: granted, version: 1 }, true);
  },
  track(name: string, props: Props = {}, essential = false) {
    if (!consent && !essential) return;
    queue.push({ name, ...props, event_version: 1, session_id: sessionId,
      t: Math.round(performance.now() - t0), build: __APP_VERSION__ });
    if (queue.length >= 20) this.flush();
  },
  flush() {
    if (!queue.length) return;
    const body = JSON.stringify(queue.splice(0));
    if (!navigator.sendBeacon?.(ENDPOINT, body)) {
      fetch(ENDPOINT, { method: 'POST', body, keepalive: true }).catch(() => {});
    }
  },
};
addEventListener('visibilitychange', () => { if (document.visibilityState === 'hidden') Telemetry.flush(); });
```

`__APP_VERSION__` comes from Vite `define`. The `consent.change` record is marked essential so the
decision itself is logged without identifiers; confirm with counsel whether your regime allows it,
otherwise keep it local only. On portals that forbid external requests (Poki), compile the wrapper
to a no-op.

### GDScript (Godot 4.x autoload)

```gdscript
extends Node
## Autoload "Telemetry". Gameplay calls Telemetry.track("run.end", {...}) only.
const ENDPOINT := "https://collect.example.com/v1/events"
var _consent := false
var _queue: Array[Dictionary] = []
var _session_id := ""
@onready var _http := HTTPRequest.new()

func _ready() -> void:
    add_child(_http)
    _session_id = "%x%x" % [randi(), Time.get_ticks_usec()]
    var t := Timer.new(); t.wait_time = 30.0; t.autostart = true
    t.timeout.connect(flush); add_child(t)

func set_consent(granted: bool) -> void:
    _consent = granted
    if not granted: _queue.clear()

func track(event_name: String, props: Dictionary = {}) -> void:
    if not _consent: return
    props.merge({"name": event_name, "event_version": 1, "session_id": _session_id,
        "t": Time.get_ticks_msec(), "build": ProjectSettings.get_setting("application/config/version")})
    _queue.append(props)
    if _queue.size() >= 20: flush()

func flush() -> void:
    if _queue.is_empty() or _http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED: return
    var body := JSON.stringify(_queue); _queue.clear()
    _http.request(ENDPOINT, ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST: flush()
```

For a vendor SDK (GameAnalytics GDExtension, PostHog's experimental Godot addon), keep this
autoload as the facade and call the SDK inside `track`, initializing the SDK only in
`set_consent(true)`.

### C# (Unity)

```csharp
public static class Telemetry
{
    static bool _consent;
    public static void SetConsent(bool granted)
    {
        _consent = granted;
        // Vendor hook goes here, e.g. initialize the SDK on grant; on withdraw stop collection and
        // request deletion using the API your SDK version documents (see privacy-compliance.md).
    }
    public static void Track(string name, System.Collections.Generic.Dictionary<string, object> props = null)
    {
        if (!_consent) return;
        // Adapter: Unity Analytics custom event, GameAnalytics design event, or your collector.
    }
}
```

Keep allocations out of per-frame paths: track discrete events (room complete), not per-frame
state; sample performance on a timer.

## 6. Pre-launch validation checklist

- [ ] Each event in the taxonomy fires once at the documented moment (debug view or collector log)
- [ ] Types match the taxonomy (no numbers as strings)
- [ ] Nothing leaves the client before consent; decline and withdraw send nothing further
- [ ] Offline: events queue within a cap or drop; no unbounded growth; no gameplay hitch
- [ ] Release builds have SDK debug logging off
- [ ] Web: a Playwright test intercepts the collector with `page.route()` and asserts zero requests
      before consent and the expected events after a scripted run
