# C++ and Blueprint Patterns (UE 5.8)

Read this before writing gameplay C++, deciding what lives in Blueprint, or setting up Data Assets
and Subsystems. GAS and Enhanced Input live in `gas-and-input.md` next to this file. Samples are
written against the public UE 5.8 API; build them before trusting them, and replace `MYGAME_API` and
`MyGame` with your module name.

---

## 1. Module setup

```csharp
// Source/MyGame/MyGame.Build.cs
using UnrealBuildTool;

public class MyGame : ModuleRules
{
    public MyGame(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

        PublicDependencyModuleNames.AddRange(new[] {
            "Core", "CoreUObject", "Engine", "InputCore", "EnhancedInput" });

        // Only if the project uses GAS. Also enable the GameplayAbilities plugin in the .uproject.
        PrivateDependencyModuleNames.AddRange(new[] {
            "GameplayAbilities", "GameplayTags", "GameplayTasks" });
    }
}
```

- Plugins (GameplayAbilities, StateTree, MassEntity, CommonUI, PythonScriptPlugin) are enabled in the
  `.uproject` `Plugins` array or the Plugins window. A missing plugin is the most common cause of
  "unresolved external" link errors after an agent adds a module dependency.
- Split code into modules when compile times hurt: a `MyGame` runtime module, a `MyGameEditor`
  editor-only module (`Type = "Editor"` in the `.uproject`), and Game Feature plugins for optional content.

## 2. Reflection essentials

| Rule | Why |
|---|---|
| `GENERATED_BODY()` in every `UCLASS`/`USTRUCT`; `.generated.h` is the last include in the header | UnrealHeaderTool generates reflection code there. `GENERATED_UCLASS_BODY()` is the UE4-era form. |
| Every `UObject*` member is a `UPROPERTY()` holding `TObjectPtr<T>` | The garbage collector only tracks reflected references; an untagged pointer can dangle. |
| `IsValid(Ptr)` before dereferencing UObjects you do not own | Catches null and objects already marked for destruction. |
| `TWeakObjectPtr<T>` for non-owning references that may die (targets, observers) | No GC root, safe to test. |
| `TSoftObjectPtr<T>` / `TSoftClassPtr<T>` for assets you load on demand | Hard references pull assets into memory with their owner. |
| Forward-declare in headers, include in `.cpp` | Keeps rebuilds small. Never include `Engine.h` in a header. |
| `FVector` is double precision in UE5 (Large World Coordinates) | Use `FVector3f` only for float data such as GPU buffers. |

**Property specifiers that matter:**

| Specifier | Use |
|---|---|
| `EditDefaultsOnly` | Tuned on the class default (Blueprint subclass, Data Asset). Most gameplay values. |
| `EditAnywhere` | Also editable per placed instance. Use sparingly; per-instance overrides hide bugs. |
| `VisibleAnywhere` | Components created in C++; Blueprint can see but not replace them. |
| `BlueprintReadOnly` / `BlueprintReadWrite` | Graph access. Default to ReadOnly; write through a function that validates. |
| `meta = (ClampMin = "0", AllowPrivateAccess = "true")` | Editor clamps; expose private members to Blueprint without making them public. |
| `Replicated` / `ReplicatedUsing = OnRep_X` | Needs `GetLifetimeReplicatedProps` and `#include "Net/UnrealNetwork.h"`. Networking design lives in `/gameforge:game-multiplayer`. |

**Function specifiers:** `BlueprintCallable` (graph can call), `BlueprintPure` (no exec pin, no side
effects), `BlueprintImplementableEvent` (Blueprint implements, C++ calls), `BlueprintNativeEvent`
(C++ default in `X_Implementation`, Blueprint may override).

## 3. The Blueprint / C++ boundary

The working rule: **C++ owns systems, state and anything that runs every frame or crosses the
network; Blueprint owns content, configuration and one-off reactions.**

| C++ | Blueprint |
|---|---|
| Base classes, interfaces, components | Subclasses that pick meshes, sounds, VFX, Data Assets |
| Per-frame logic (movement, AI evaluation, queries) | Event responses (on hit, on pickup, on open) |
| Replicated state, RPCs, authority checks | Level scripting, encounters, cinematics triggers |
| GAS base abilities, attribute sets, executions | Ability subclasses that set tags, costs, cues |
| Save data, subsystems, tools | UI layout and animation (UMG), timelines |

**Thin Blueprint pattern.** C++ base class exposes knobs and events; the Blueprint subclass only
fills in assets and cosmetic reactions:

```cpp
// Weapon.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Weapon.generated.h"

class USkeletalMeshComponent;

UCLASS(Abstract, Blueprintable)
class MYGAME_API AWeapon : public AActor
{
    GENERATED_BODY()

public:
    AWeapon();

    UFUNCTION(BlueprintCallable, Category = "Weapon")
    void Fire();

protected:
    // C++ default does the gameplay; Blueprint override adds cosmetics and calls the parent node.
    UFUNCTION(BlueprintNativeEvent, Category = "Weapon")
    void OnFired(const FHitResult& Hit);

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
    TObjectPtr<USkeletalMeshComponent> Mesh;

    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Weapon", meta = (ClampMin = "0"))
    float Range = 5000.f;
};
```

```cpp
// Weapon.cpp
#include "Weapon.h"
#include "Components/SkeletalMeshComponent.h"

AWeapon::AWeapon()
{
    PrimaryActorTick.bCanEverTick = false;   // event-driven; no Tick cost
    Mesh = CreateDefaultSubobject<USkeletalMeshComponent>(TEXT("Mesh"));
    SetRootComponent(Mesh);
}

void AWeapon::Fire()
{
    FHitResult Hit;
    const FVector Start = Mesh->GetComponentLocation();
    const FVector End = Start + GetActorForwardVector() * Range;
    if (GetWorld()->LineTraceSingleByChannel(Hit, Start, End, ECC_Visibility))
    {
        OnFired(Hit);
    }
}

void AWeapon::OnFired_Implementation(const FHitResult& Hit)
{
    // Gameplay response here; Blueprint subclasses add muzzle flash and sound.
}
```

**Tick discipline:** `PrimaryActorTick.bCanEverTick = false` by default; use `FTimerManager` timers,
delegates, or `PrimaryActorTick.TickInterval` when something genuinely needs periodic work. Blueprint
Nativization was removed in UE5, so hot Blueprint logic has to be moved to C++ by hand; profile first.

**Blueprint-only projects** are viable for small scope (jam games, narrative games, simple
single-player). Add a C++ module the moment you need GAS attribute sets, custom movement, heavy
per-frame logic, or anything an AI agent should write and test as text.

## 4. Gameplay Framework placement

| Class | Exists on | Put here |
|---|---|---|
| `AGameModeBase` / `AGameMode` | Server only | Rules, spawning, match flow. Clients never see it. |
| `AGameStateBase` | Server + all clients | Replicated match state (score, phase, timer). |
| `APlayerController` | Server + owning client | Input routing, UI ownership, client-only requests. |
| `APlayerState` | Server + all clients | Per-player persistent state (name, team, GAS for players). |
| `APawn` / `ACharacter` | Server + relevant clients | Body: movement, collision, animation. Dies and respawns. |
| `UGameInstanceSubsystem` | Each process, whole session | Save system, settings, session services. |
| `AHUD` / UMG / CommonUI | Owning client | Presentation only; reads state, never owns it. |

Putting logic in the wrong class (score on the Pawn, rules in the PlayerController) is the root of
most "it works in single-player" bugs.

## 5. Data Assets, Data Tables and the Asset Manager

```cpp
UCLASS(BlueprintType)
class MYGAME_API UEnemyDefinition : public UPrimaryDataAsset
{
    GENERATED_BODY()

public:
    UPROPERTY(EditDefaultsOnly, Category = "Identity")
    FText DisplayName;

    UPROPERTY(EditDefaultsOnly, Category = "Stats", meta = (ClampMin = "1"))
    float BaseHealth = 100.f;

    UPROPERTY(EditDefaultsOnly, Category = "Visual")
    TSoftObjectPtr<USkeletalMesh> Mesh;   // soft: loaded when the enemy spawns, not at startup

    UPROPERTY(EditDefaultsOnly, Category = "Abilities")
    TArray<TSubclassOf<UGameplayAbility>> StartupAbilities;
};
```

- **Data Assets** for individual definitions (enemies, items, weapons). Register primary asset types
  in Project Settings > Asset Manager so they can be discovered, cooked and loaded asynchronously.
- **Data Tables** (`FTableRowBase` rows) for spreadsheet-shaped data imported from CSV/JSON; designers
  own the spreadsheet, the import is reproducible, and diffs are readable.
- **Curve Tables / Curve Floats** for progression (XP per level, difficulty over time).
- Load soft references with the Asset Manager or `FStreamableManager` during loading screens, never
  synchronously in gameplay.

## 6. Subsystems

```cpp
UCLASS()
class MYGAME_API USaveGameSubsystem : public UGameInstanceSubsystem
{
    GENERATED_BODY()

public:
    virtual void Initialize(FSubsystemCollectionBase& Collection) override;
    virtual void Deinitialize() override;

    UFUNCTION(BlueprintCallable, Category = "Save")
    bool SaveSlot(const FString& SlotName);
};
```

| Subsystem | Lifetime | Typical use |
|---|---|---|
| `UGameInstanceSubsystem` | Whole session | Save/load, settings, analytics, achievements |
| `UWorldSubsystem` | One world | Spawners, world rules, environment state |
| `ULocalPlayerSubsystem` | One local player | Input preferences, UI stack, per-player options |
| `UEditorSubsystem` | Editor only | Tools; reachable from Python via `unreal.get_editor_subsystem()` |

Subsystems replace hand-rolled singletons: the engine creates and destroys them, and Blueprint and
Python can reach them without static state.

## 7. Animation quick rules

- Animation Blueprints: keep the Event Graph thin; compute values in the thread-safe update so the
  anim graph can run off the game thread.
- Montages for one-shots (attacks, reactions); Anim Notifies to sync gameplay with frames (spawn the
  projectile on the notify, not on a timer).
- Control Rig for procedural IK and foot placement. UE 5.8 adds Control Rig Physics (Beta).
- Mover is UE5's newer movement framework; in 5.8 it is still working toward leaving Experimental,
  so ship with `UCharacterMovementComponent` unless you have a reason and time to absorb changes.
