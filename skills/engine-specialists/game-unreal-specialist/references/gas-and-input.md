# GAS and Enhanced Input (UE 5.8)

Read this before setting up the Gameplay Ability System or binding input in C++. Module setup
(`GameplayAbilities`, `GameplayTags`, `GameplayTasks`, `EnhancedInput` in Build.cs, plus the
GameplayAbilities plugin in the `.uproject`) is in `cpp-blueprint-patterns.md`. Replace `MYGAME_API`
with your module's API macro.

---

## 1. Gameplay Ability System (GAS)

**Use GAS** for games with many abilities, stacking buffs and debuffs, cooldowns and costs, or
networked abilities with prediction. **Skip it** for puzzle games, platformers with two or three
verbs, and narrative games: a component with a few functions is cheaper to build and debug. Budget
a learning spike before committing (rule of thumb: about a week for one programmer new to GAS).
Epic's Lyra sample game is the public reference for GAS, Enhanced Input and CommonUI together.

**Where the Ability System Component (ASC) lives:** on the `APlayerState` for player characters (it
survives respawn), on the `ACharacter` for AI. In multiplayer, use replication mode `Mixed` for
player ASCs and `Minimal` for AI. PlayerState replicates infrequently by default; GAS projects
usually raise its net update frequency.

```cpp
// MyPlayerState.h (excerpt)
UCLASS()
class MYGAME_API AMyPlayerState : public APlayerState, public IAbilitySystemInterface
{
    GENERATED_BODY()

public:
    AMyPlayerState();
    virtual UAbilitySystemComponent* GetAbilitySystemComponent() const override { return AbilitySystemComponent; }

protected:
    UPROPERTY(VisibleAnywhere, Category = "Abilities")
    TObjectPtr<UAbilitySystemComponent> AbilitySystemComponent;

    UPROPERTY()
    TObjectPtr<UMyAttributeSet> AttributeSet;
};

// MyPlayerState.cpp
AMyPlayerState::AMyPlayerState()
{
    AbilitySystemComponent = CreateDefaultSubobject<UAbilitySystemComponent>(TEXT("AbilitySystemComponent"));
    AbilitySystemComponent->SetIsReplicated(true);
    AbilitySystemComponent->SetReplicationMode(EGameplayEffectReplicationMode::Mixed);
    AttributeSet = CreateDefaultSubobject<UMyAttributeSet>(TEXT("AttributeSet"));
}

// MyCharacter.h also implements IAbilitySystemInterface (returning the PlayerState's ASC) and declares:
//   UPROPERTY(EditDefaultsOnly, Category = "Abilities") TArray<TSubclassOf<UGameplayAbility>> StartupAbilities;
//   bool bStartupAbilitiesGranted = false;
// MyCharacter.cpp: initialise on the server (PossessedBy) and on the owning client (OnRep_PlayerState)
void AMyCharacter::PossessedBy(AController* NewController)
{
    Super::PossessedBy(NewController);
    InitAbilitySystem();
}

void AMyCharacter::OnRep_PlayerState()
{
    Super::OnRep_PlayerState();
    InitAbilitySystem();
}

void AMyCharacter::InitAbilitySystem()
{
    AMyPlayerState* PS = GetPlayerState<AMyPlayerState>();
    if (!IsValid(PS)) { return; }

    UAbilitySystemComponent* ASC = PS->GetAbilitySystemComponent();
    ASC->InitAbilityActorInfo(PS, this);   // owner = PlayerState, avatar = this body

    if (HasAuthority() && !bStartupAbilitiesGranted)
    {
        for (const TSubclassOf<UGameplayAbility>& Ability : StartupAbilities)
        {
            ASC->GiveAbility(FGameplayAbilitySpec(Ability, 1));
        }
        bStartupAbilitiesGranted = true;
    }
}
```

**Attribute set** (the accessor macro is a project-local helper, the pattern used in Epic's GAS
docs and Lyra):

```cpp
// MyAttributeSet.h
#pragma once

#include "CoreMinimal.h"
#include "AttributeSet.h"
#include "AbilitySystemComponent.h"
#include "MyAttributeSet.generated.h"

#define ATTRIBUTE_ACCESSORS(ClassName, PropertyName) \
    GAMEPLAYATTRIBUTE_PROPERTY_GETTER(ClassName, PropertyName) \
    GAMEPLAYATTRIBUTE_VALUE_GETTER(PropertyName) \
    GAMEPLAYATTRIBUTE_VALUE_SETTER(PropertyName) \
    GAMEPLAYATTRIBUTE_VALUE_INITTER(PropertyName)

UCLASS()
class MYGAME_API UMyAttributeSet : public UAttributeSet
{
    GENERATED_BODY()

public:
    UPROPERTY(BlueprintReadOnly, ReplicatedUsing = OnRep_Health, Category = "Attributes")
    FGameplayAttributeData Health;
    ATTRIBUTE_ACCESSORS(UMyAttributeSet, Health)

    UPROPERTY(BlueprintReadOnly, ReplicatedUsing = OnRep_MaxHealth, Category = "Attributes")
    FGameplayAttributeData MaxHealth;
    ATTRIBUTE_ACCESSORS(UMyAttributeSet, MaxHealth)

    // Meta attribute: damage effects write it, PostGameplayEffectExecute consumes it. Not replicated.
    UPROPERTY(BlueprintReadOnly, Category = "Attributes")
    FGameplayAttributeData IncomingDamage;
    ATTRIBUTE_ACCESSORS(UMyAttributeSet, IncomingDamage)

    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override;
    virtual void PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue) override;
    virtual void PostGameplayEffectExecute(const FGameplayEffectModCallbackData& Data) override;

protected:
    UFUNCTION()
    void OnRep_Health(const FGameplayAttributeData& OldHealth);

    UFUNCTION()
    void OnRep_MaxHealth(const FGameplayAttributeData& OldMaxHealth);
};
```

```cpp
// MyAttributeSet.cpp
#include "MyAttributeSet.h"
#include "GameplayEffectExtension.h"
#include "Net/UnrealNetwork.h"

void UMyAttributeSet::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const
{
    Super::GetLifetimeReplicatedProps(OutLifetimeProps);
    DOREPLIFETIME_CONDITION_NOTIFY(UMyAttributeSet, Health, COND_None, REPNOTIFY_Always);
    DOREPLIFETIME_CONDITION_NOTIFY(UMyAttributeSet, MaxHealth, COND_None, REPNOTIFY_Always);
}

void UMyAttributeSet::PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue)
{
    Super::PreAttributeChange(Attribute, NewValue);
    if (Attribute == GetHealthAttribute())
    {
        NewValue = FMath::Clamp(NewValue, 0.f, GetMaxHealth());
    }
}

void UMyAttributeSet::PostGameplayEffectExecute(const FGameplayEffectModCallbackData& Data)
{
    Super::PostGameplayEffectExecute(Data);
    if (Data.EvaluatedData.Attribute == GetIncomingDamageAttribute())
    {
        const float Damage = GetIncomingDamage();
        SetIncomingDamage(0.f);
        SetHealth(FMath::Clamp(GetHealth() - Damage, 0.f, GetMaxHealth()));
    }
}

void UMyAttributeSet::OnRep_Health(const FGameplayAttributeData& OldHealth)
{
    GAMEPLAYATTRIBUTE_REPNOTIFY(UMyAttributeSet, Health, OldHealth);
}

void UMyAttributeSet::OnRep_MaxHealth(const FGameplayAttributeData& OldMaxHealth)
{
    GAMEPLAYATTRIBUTE_REPNOTIFY(UMyAttributeSet, MaxHealth, OldMaxHealth);
}
```

**A minimal ability.** Cost and cooldown are Gameplay Effects assigned in the ability's defaults
(`CostGameplayEffectClass`, `CooldownGameplayEffectClass`); `CommitAbility` applies both.

```cpp
// GA_Dash.cpp (header declares the ActivateAbility override and a DashStrength UPROPERTY)
UGA_Dash::UGA_Dash()
{
    InstancingPolicy = EGameplayAbilityInstancingPolicy::InstancedPerActor;
    NetExecutionPolicy = EGameplayAbilityNetExecutionPolicy::LocalPredicted;
}

void UGA_Dash::ActivateAbility(const FGameplayAbilitySpecHandle Handle,
    const FGameplayAbilityActorInfo* ActorInfo,
    const FGameplayAbilityActivationInfo ActivationInfo,
    const FGameplayEventData* TriggerEventData)
{
    if (!CommitAbility(Handle, ActorInfo, ActivationInfo))
    {
        EndAbility(Handle, ActorInfo, ActivationInfo, /*bReplicateEndAbility*/ true, /*bWasCancelled*/ true);
        return;
    }
    if (ACharacter* Character = Cast<ACharacter>(ActorInfo->AvatarActor.Get()))
    {
        Character->LaunchCharacter(Character->GetActorForwardVector() * DashStrength, true, false);
    }
    EndAbility(Handle, ActorInfo, ActivationInfo, true, false);
}
```

**Gameplay Effects.** Instant (damage, heal), Duration (buffs, DoTs), Infinite (equipment, auras).
Modifiers handle add/multiply/override; formulas with armor, resistances and crits belong in a
`UGameplayEffectExecutionCalculation`. Since UE 5.3, much of an effect's configuration (granted tags,
application requirements, immunity) lives in **Gameplay Effect Components**; the older flat
properties on `UGameplayEffect` are deprecated. Tutorials written before 5.3, and agents trained on
them, still set the old properties.

**Gameplay Tags.** Replace boolean soup (`bIsStunned && !bIsDead`) with tags. Declare the ones C++
needs as native tags so typos fail at compile time:

```cpp
// MyGameplayTags.h
#pragma once
#include "NativeGameplayTags.h"

UE_DECLARE_GAMEPLAY_TAG_EXTERN(TAG_Ability_Movement_Dash);
UE_DECLARE_GAMEPLAY_TAG_EXTERN(TAG_State_Stunned);

// MyGameplayTags.cpp
#include "MyGameplayTags.h"

UE_DEFINE_GAMEPLAY_TAG(TAG_Ability_Movement_Dash, "Ability.Movement.Dash");
UE_DEFINE_GAMEPLAY_TAG(TAG_State_Stunned, "State.Stunned");
```

Cosmetic feedback (hit sparks, buff glow, sounds) goes through **Gameplay Cues** so it stays out of
gameplay logic and replicates cheaply.

## 2. Enhanced Input

Input Actions (what the player wants), Input Mapping Contexts (which keys mean it, swapped per
context such as on-foot, vehicle, menu), Modifiers (dead zones, negate, swizzle) and Triggers
(pressed, hold, tap, chorded). Player-mappable configs back a rebinding screen, which is also an
accessibility requirement (`/gameforge:game-accessibility-specialist`). The legacy Action/Axis
Mappings and `BindAxis`/`BindAction(Name, IE_Pressed, ...)` were deprecated in UE 5.1; do not write
new code against them. UE 5.8 unifies Enhanced Input with Common Input/CommonUI (fewer duplicate data
assets, a new Input Debugger); check the 5.8 release notes before migrating CommonUI input setup.
Debug with `showdebug enhancedinput`.

```cpp
// MyCharacter.h (excerpt) -- forward declare: class UInputMappingContext; class UInputAction; struct FInputActionValue;
UPROPERTY(EditDefaultsOnly, Category = "Input")
TObjectPtr<UInputMappingContext> DefaultMappingContext;

UPROPERTY(EditDefaultsOnly, Category = "Input")
TObjectPtr<UInputAction> MoveAction;

UPROPERTY(EditDefaultsOnly, Category = "Input")
TObjectPtr<UInputAction> DashAction;
```

```cpp
// MyCharacter.cpp
#include "EnhancedInputComponent.h"
#include "EnhancedInputSubsystems.h"
#include "InputActionValue.h"
#include "AbilitySystemComponent.h"
#include "MyGameplayTags.h"

void AMyCharacter::NotifyControllerChanged()
{
    Super::NotifyControllerChanged();
    if (const APlayerController* PC = Cast<APlayerController>(Controller))
    {
        if (UEnhancedInputLocalPlayerSubsystem* Subsystem =
                ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(PC->GetLocalPlayer()))
        {
            Subsystem->AddMappingContext(DefaultMappingContext, /*Priority*/ 0);
        }
    }
}

void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);
    UEnhancedInputComponent* EIC = CastChecked<UEnhancedInputComponent>(PlayerInputComponent);
    EIC->BindAction(MoveAction, ETriggerEvent::Triggered, this, &AMyCharacter::Move);
    EIC->BindAction(DashAction, ETriggerEvent::Started, this, &AMyCharacter::Dash);
}

void AMyCharacter::Move(const FInputActionValue& Value)
{
    const FVector2D Axis = Value.Get<FVector2D>();
    AddMovementInput(GetActorForwardVector(), Axis.Y);
    AddMovementInput(GetActorRightVector(), Axis.X);
}

void AMyCharacter::Dash()
{
    if (UAbilitySystemComponent* ASC = GetAbilitySystemComponent())
    {
        ASC->TryActivateAbilitiesByTag(FGameplayTagContainer(TAG_Ability_Movement_Dash));
    }
}
```
