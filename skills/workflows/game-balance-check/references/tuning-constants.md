# Exposing Tuning Constants

Goal: every balance number lives in one data source that the game, the simulation harness and a
debug panel all read. Designers (and agents) change data, not logic; every change is diffable and
logged. Do this before serious tuning, especially in agent-built games where numbers end up
hard-coded across many files.

## 1. What to expose

Expose: damage, health, cooldowns, speeds, spawn rates and weights, drop tables, prices, XP
curves, timers, difficulty multipliers, pity thresholds, economy rates.

Do not expose: physics solver settings, input dead zones that are really accessibility settings
(those go in the options menu), network tick rates, anything a player could change to cheat in a
competitive or online game (the server owns those).

Each constant gets:
- a **name** that says what and where (`enemy.grunt.hp`, not `HP2`)
- a **unit** (seconds, units per second, gold, percent as 0-1)
- a **range** the debug panel enforces
- a one-line **purpose**

## 2. Web (TypeScript, Vite)

```ts
// src/tuning/tuning.ts -- single source of truth for game, harness and debug panel
export const tuning = {
  player: {
    maxHp:         { value: 100,  min: 50,  max: 200, unit: 'hp',      why: 'survive ~6 grunt hits' },
    dashCooldown:  { value: 0.8,  min: 0.2, max: 2,   unit: 's',       why: 'core mobility rhythm' },
  },
  weapons: {
    spear: {
      damage:      { value: 22,   min: 5,   max: 60,  unit: 'hp',      why: 'mid TTK vs grunt (5 hits)' },
      critChance:  { value: 0.18, min: 0,   max: 0.5, unit: 'fraction', why: 'see tuning-changelog 2026-11-05' },
    },
  },
  economy: {
    goldPerKill:   { value: 12,   min: 1,   max: 50,  unit: 'gold',    why: 'shop item every ~2 rooms' },
  },
} as const;

export type Tuning = typeof tuning;
export const v = <T extends { value: number }>(c: T) => c.value;   // read helper
```

Debug panel in development only (lil-gui shown; Tweakpane and Leva for React Three Fiber work the
same way):

```ts
// src/tuning/panel.ts
import GUI from 'lil-gui';
import { tuning } from './tuning';

export function mountTuningPanel(): void {
  if (!import.meta.env.DEV) return;
  const gui = new GUI({ title: 'Tuning' });
  const walk = (node: Record<string, any>, folder: GUI) => {
    for (const [key, val] of Object.entries(node)) {
      if (val && typeof val === 'object' && 'value' in val) folder.add(val, 'value', val.min, val.max).name(key);
      else walk(val, folder.addFolder(key));
    }
  };
  walk(tuning, gui);
  gui.add({ dump: () => console.log(JSON.stringify(tuning, null, 2)) }, 'dump').name('Copy values to console');
}
```

Live edits are for exploring; commit the chosen values back to `tuning.ts` with a change-log entry.
If designers outside the code need to edit, keep the same shape in `tuning.json` and import it.

## 3. Godot 4.7

```gdscript
# res://tuning/combat_tuning.gd
class_name CombatTuning
extends Resource

@export_group("Player")
@export_range(50, 200, 1, "suffix:hp") var player_max_hp: int = 100
@export_range(0.2, 2.0, 0.05, "suffix:s") var dash_cooldown: float = 0.8

@export_group("Spear")
@export_range(5, 60, 1, "suffix:hp") var spear_damage: int = 22
@export_range(0.0, 0.5, 0.01) var spear_crit_chance: float = 0.18

@export_group("Economy")
@export_range(1, 50, 1, "suffix:gold") var gold_per_kill: int = 12
```

Save an instance as `res://tuning/combat.tres`, load it once in an autoload
(`var combat: CombatTuning = preload("res://tuning/combat.tres")`) and read from it everywhere.
The Inspector becomes the tuning panel; the `.tres` file is plain text, so diffs are readable and an
agent can edit it safely. The headless simulation (see `simulation-harnesses.md`) loads the same
`.tres`.

## 4. Unity 6.x

```csharp
using UnityEngine;

[CreateAssetMenu(menuName = "Tuning/Combat", fileName = "CombatTuning")]
public class CombatTuning : ScriptableObject
{
    [Header("Player")]
    [Range(50, 200)]   public int   playerMaxHp = 100;
    [Range(0.2f, 2f)]  public float dashCooldown = 0.8f;   // seconds

    [Header("Spear")]
    [Range(5, 60)]     public int   spearDamage = 22;
    [Range(0f, 0.5f)]  public float spearCritChance = 0.18f;

    [Header("Economy")]
    [Range(1, 50)]     public int   goldPerKill = 12;
}
```

Reference the asset from the systems that use it. Keep the rules that consume these values in
plain C# classes (no `MonoBehaviour` dependency) so Edit Mode tests and a batchmode simulation can
run them. Note that Unity 6.6 enables Fast Enter Play Mode by default and no longer resets static
fields; do not cache tuning in statics without an explicit reset.

## 5. Unreal Engine 5.8

- **Data Asset** (`UPrimaryDataAsset` subclass) for a handful of grouped values per system.
- **Data Table** (`FTableRowBase` struct) for many rows of the same shape (enemy roster, weapon
  list, drop tables); import and export as CSV or JSON so spreadsheets and agents can edit them.
- **Curve Tables** for XP and scaling curves.

```cpp
UCLASS(BlueprintType)
class UCombatTuning : public UPrimaryDataAsset
{
    GENERATED_BODY()
public:
    UPROPERTY(EditDefaultsOnly, Category="Spear", meta=(ClampMin="5", ClampMax="60"))
    int32 SpearDamage = 22;

    UPROPERTY(EditDefaultsOnly, Category="Spear", meta=(ClampMin="0.0", ClampMax="0.5"))
    float SpearCritChance = 0.18f;
};
```

`.uasset` files are binary; agents should edit the CSV/JSON export and re-import, or work through
the editor. Keep a text export in version control for review.

## 6. Change log format

`design/balance/tuning-changelog.md`, newest first:

```markdown
## 2026-11-05 -- spear.critChance 0.25 -> 0.18 (commit abc123)
Why: B1 in design/balance/2026-11-05-weapons.md (spear 68% pick, 61% win in sim and telemetry n=412)
Predicted: spear pick rate under 45%; overall win rate within 2 points
Check: next playtest round or 200 telemetry runs; revert if overall win rate drops more than 5 points
Result: [filled in at check time]
```

A change without a prediction cannot be evaluated. A change without a check date never gets one.
