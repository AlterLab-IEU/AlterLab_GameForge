# Unreal Engine 5.x Configuration

This section configures Claude Code for an Unreal Engine 5.x project. Append to your project's CLAUDE.md or use standalone.

## Engine Details

- **Engine**: Unreal Engine 5.7+
- **Primary Languages**: C++ and Blueprints
- **Engine Specialist**: `/game-unreal-specialist`

When asking engine-specific questions, use `/game-unreal-specialist`. For architecture questions that are engine-agnostic, use `/game-technical-director`.

## Project Structure

```
[ProjectName].uproject
Source/
  [ProjectName]/
    [ProjectName].Build.cs       -- Module build file
    [ProjectName].h              -- Module header
    [ProjectName].cpp            -- Module implementation
    Characters/                  -- Player, enemy, NPC classes
    Components/                  -- ActorComponent subclasses
    GameModes/                   -- GameMode, GameState, PlayerState
    Abilities/                   -- GAS: GameplayAbilities, Effects, Cues
    UI/                          -- Slate/CommonUI widget classes
    Systems/                     -- Core game systems (inventory, save, etc.)
    Data/                        -- Data Assets, Data Tables, Gameplay Tags
    Interfaces/                  -- UInterface definitions
    Tests/                       -- Automation tests
  [ProjectName]Editor/           -- Editor-only module (tools, custom editors)
Content/
  Blueprints/                    -- Blueprint assets
  Maps/                          -- Level/map assets
  Materials/
  Textures/
  Meshes/
  Audio/
  UI/                            -- Widget Blueprints, CommonUI assets
  VFX/                           -- Niagara systems
  Data/                          -- Data Tables, Curves, Data Assets
Config/
  DefaultEngine.ini
  DefaultGame.ini
  DefaultInput.ini
  DefaultEditor.ini
Plugins/                         -- Project-local plugins
Binaries/                        -- Compiled output (gitignored)
Intermediate/                    -- Build intermediates (gitignored)
Saved/                           -- Local saves, logs, config (gitignored)
```

## C++ Coding Standards

### Naming Conventions (Epic Standard)

Unreal uses prefix conventions to communicate type information at a glance.

| Element | Convention | Example |
|---|---|---|
| Classes (UObject) | UPascalCase | `class UInventoryComponent : public UActorComponent` |
| Classes (AActor) | APascalCase | `class APlayerCharacter : public ACharacter` |
| Structs | FPascalCase | `struct FWeaponData` |
| Enums | EPascalCase | `enum class EPlayerState : uint8` |
| Interfaces | IPascalCase (impl: UPascalCase) | `class IDamageable` / `class UDamageableInterface` |
| Functions | PascalCase | `void TakeDamage(float Amount)` |
| Parameters | PascalCase | `float InDamageAmount` (In/Out prefix for clarity) |
| Local variables | PascalCase | `float CurrentHealth = MaxHealth;` |
| Member variables | PascalCase | `float MaxHealth;` |
| Booleans | bPascalCase | `bool bIsAlive;` |
| Delegates | FOnPascalCase | `DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnHealthChanged)` |
| Gameplay Tags | Category.SubCategory.Name | `Ability.Combat.DashAttack` |

### UPROPERTY and UFUNCTION Macros Are Mandatory

Every member that needs to be visible to Blueprints, GC, serialization, or replication must be tagged. Untagged UObject pointers will be garbage collected.

```cpp
UCLASS()
class MYGAME_API APlayerCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Combat")
    TObjectPtr<UWeaponData> DefaultWeaponData;

    UPROPERTY(BlueprintAssignable, Category = "Events")
    FOnHealthChanged OnHealthChanged;

    UFUNCTION(BlueprintCallable, Category = "Combat")
    void TakeDamage(float Amount, AActor* DamageCauser);

protected:
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
    TObjectPtr<UAbilitySystemComponent> AbilitySystemComponent;

private:
    UPROPERTY(Replicated)
    float CurrentHealth;
};
```

### TObjectPtr Over Raw Pointers

Use `TObjectPtr<T>` for all UPROPERTY member pointers (UE 5.0+). It enables access tracking, lazy loading, and better debugging.

```cpp
// Correct
UPROPERTY()
TObjectPtr<UStaticMeshComponent> MeshComponent;

// Wrong -- raw pointer, no access tracking
UPROPERTY()
UStaticMeshComponent* MeshComponent;
```

### Blueprint / C++ Boundary

This is the most critical architectural decision in any Unreal project.

- **C++ owns**: Performance-critical systems, AI tick logic, network replication, GAS abilities, core data types, interfaces.
- **Blueprints own**: Prototyping, visual scripting for designers, VFX triggers, audio events, UI binding, tuning values.
- **Rule**: If it runs every tick or handles networking, it must be C++. If a designer needs to iterate on it daily, expose it to Blueprint.

### Gameplay Ability System (GAS)

Use GAS for action/RPG games with abilities, buffs, and status effects. Do not use GAS for simple games where direct function calls suffice.

- Abilities derive from `UGameplayAbility`
- Effects derive from `UGameplayEffect`
- Use Gameplay Tags for ability identification and blocking
- Use Gameplay Cues for visual/audio feedback (decoupled from logic)

### Data-Driven Values

- Gameplay values live in Data Assets (`UDataAsset`) or Data Tables, never hardcoded in C++ or Blueprints.
- Use `FTableRowBase` structs for tabular data (enemy stats, weapon profiles, loot tables).
- Expose tuning values via `UPROPERTY(EditDefaultsOnly)` on Data Assets.

## UE-Specific Code Review Criteria

When reviewing Unreal code (`/game-code-review`), check for:

- [ ] All UObject member pointers use `UPROPERTY()` (prevents GC collection)
- [ ] `TObjectPtr<T>` used instead of raw pointers for UPROPERTY members
- [ ] `IsValid()` check before every UObject pointer dereference
- [ ] `HasAuthority()` check before modifying replicated state
- [ ] Correct RPC type used (Server, Client, Multicast) with `_Implementation` suffix
- [ ] UPROPERTY specifiers appropriate (EditDefaultsOnly vs EditAnywhere, BlueprintReadOnly vs ReadWrite)
- [ ] Forward declarations used in headers, includes only in .cpp files
- [ ] No Tick logic in Blueprints for performance-critical systems
- [ ] Gameplay Tags used instead of string comparisons or hardcoded enums for abilities
- [ ] Data Tables or Data Assets used for tunable values, not hardcoded constants
- [ ] `GENERATED_BODY()` present in every UCLASS/USTRUCT
- [ ] Module API macro (MYGAME_API) on classes that need cross-module visibility

## Build and Test Commands

```bash
# Build the project (Development configuration)
# Windows
Engine/Build/BatchFiles/RunUAT.bat BuildCookRun -project="[ProjectName].uproject" -platform=Win64 -configuration=Development -cook -stage -archive

# Linux
Engine/Build/BatchFiles/RunUAT.sh BuildCookRun -project="[ProjectName].uproject" -platform=Linux -configuration=Development -cook -stage -archive

# Build C++ only (faster iteration)
# Windows
Engine/Build/BatchFiles/Build.bat [ProjectName]Editor Win64 Development "[FullPath]/[ProjectName].uproject"

# Run automation tests
# Windows
Engine/Build/BatchFiles/RunUAT.bat RunTests -project="[ProjectName].uproject" -platform=Win64 -configuration=Development

# Run specific test
Engine/Binaries/Win64/UnrealEditor-Cmd.exe "[FullPath]/[ProjectName].uproject" -ExecCmds="Automation RunTests [TestName]" -unattended -nopause -NullRHI -log

# Generate project files (after adding new C++ files)
# Windows
Engine/Build/BatchFiles/GenerateProjectFiles.bat "[FullPath]/[ProjectName].uproject"

# Note: Replace Engine/ paths with your UE5 installation directory
# Typical: C:/Program Files/Epic Games/UE_5.7/
```

## Unreal Anti-Patterns to Flag

These patterns must be caught during code review or refactored on sight:

1. **Untagged UObject pointers**: Member pointers without `UPROPERTY()` will be garbage collected silently
2. **Raw pointers instead of TObjectPtr**: Missing access tracking and debugging support
3. **Missing IsValid checks**: Dereferencing without validity check causes crash-to-desktop
4. **Tick-heavy Blueprints**: Performance-critical logic in Blueprint Tick instead of C++
5. **Cast chains**: Long chains of `Cast<AMyActor>(GetOwner())->GetComponent<UMyComp>()->DoThing()` without validity checks
6. **Missing authority checks**: Modifying replicated state without `HasAuthority()` causes desyncs
7. **Include-heavy headers**: Including large headers (Engine.h) in frequently-used files instead of forward declaring
8. **Hardcoded gameplay values**: Magic numbers in C++ or Blueprint instead of Data Assets
9. **Monolithic Actors**: Single Actor class with hundreds of lines instead of composed ActorComponents
10. **String comparisons for abilities**: Using `FName` string matching instead of Gameplay Tags
