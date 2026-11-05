# Unreal Engine 5 Multiplayer

Facts dated 2026-11-05. Sources: Epic's UE 5.8 documentation pages for the Iris replication system,
the Mover plugin, dedicated server setup and network emulation; UE release context (5.8 on
2026-06-17 as the last planned major UE5 release; UE6 early access targeted for late 2027) from
the AI-tooling research. Long-standing replication APIs (properties, RPCs, roles) are described as
documented across UE5; confirm details against your engine version.

## 1. Stack at a glance

| Layer | Option | Status (UE 5.8) |
|---|---|---|
| Replication | Generic replication system: actor and property replication, RPCs | Production standard |
| Replication | **Iris** replication system | **Experimental** ("use caution when shipping"); opt-in, coexists with the generic system; built from Fortnite experience for larger worlds, more players, lower server cost |
| Movement | `CharacterMovementComponent` | Built-in client prediction and server correction for characters |
| Movement | **Mover** plugin | **Experimental**; modular movement with rollback networking via the Network Prediction plugin or Chaos Networked Physics |
| Abilities | Gameplay Ability System | Prediction keys for predicted abilities and effects |
| Online | Online Subsystem / Online Services plugins with EOS or Steam | Sessions, lobbies, identity, presence |
| Servers | Dedicated server targets | **Require a source build of the engine** |

Planning note: UE 5.8 is the last planned major UE5 release; UE6 (Verse and Scene Graph) early
access is targeted for late 2027. A game starting now ships on UE5 replication; do not build on
Iris or Mover unless you accept experimental-feature risk.

## 2. Replication fundamentals

- **Authority**: the server owns the truth. `HasAuthority()` is true on the server copy. Roles:
  `ROLE_Authority` (server), `ROLE_AutonomousProxy` (the owning client's pawn),
  `ROLE_SimulatedProxy` (everyone else's).
- **Net modes**: Standalone, Listen Server (a player hosts), Dedicated Server, Client.
- **Framework placement**: `GameMode` exists only on the server; `GameState` and `PlayerState` are
  replicated to all; each client has its own `PlayerController`, which is the natural owner for
  client-to-server RPCs.
- **Relevancy**: actors replicate only to connections where they are relevant (distance culling,
  owner-only, always-relevant flags). This is your interest management.
- **Update frequency and priority** per actor control bandwidth; set them deliberately instead of
  leaving every actor at defaults.

```cpp
// MyCharacter.h
#pragma once
#include "GameFramework/Character.h"
#include "MyCharacter.generated.h"

UCLASS()
class AMyCharacter : public ACharacter
{
    GENERATED_BODY()
public:
    AMyCharacter();
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override;

    // Client asks; server decides. Quantized types cut bandwidth.
    UFUNCTION(Server, Reliable, WithValidation)
    void ServerFire(FVector_NetQuantize Origin, FVector_NetQuantizeNormal Direction, float ClientViewTime);

protected:
    UPROPERTY(ReplicatedUsing = OnRep_Health)
    float Health = 100.f;

    UFUNCTION()
    void OnRep_Health();          // clients update UI/FX here

    double LastFireTime = -1.0;
    static constexpr double MinFireInterval = 0.12;
};
```

```cpp
// MyCharacter.cpp
#include "MyCharacter.h"
#include "Net/UnrealNetwork.h"

AMyCharacter::AMyCharacter()
{
    bReplicates = true;
}

void AMyCharacter::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const
{
    Super::GetLifetimeReplicatedProps(OutLifetimeProps);
    DOREPLIFETIME(AMyCharacter, Health);
}

bool AMyCharacter::ServerFire_Validate(FVector_NetQuantize Origin, FVector_NetQuantizeNormal Direction,
                                       float ClientViewTime)
{
    // Returning false disconnects the client: keep this to "impossible" inputs only.
    return Direction.IsNormalized();
}

void AMyCharacter::ServerFire_Implementation(FVector_NetQuantize Origin, FVector_NetQuantizeNormal Direction,
                                             float ClientViewTime)
{
    const double Now = GetWorld()->GetTimeSeconds();
    if (Now - LastFireTime < MinFireInterval) return;                         // rate limit
    if (FVector::DistSquared(Origin, GetActorLocation()) > FMath::Square(200.f)) return; // origin sanity
    LastFireTime = Now;
    // Rewind other players' hitboxes to a bounded ClientViewTime, trace on the server,
    // apply damage through the server-side damage pipeline. Never accept a client hit result.
}
```

Rules:
- Use `WithValidation` for cheap impossibility checks; do gameplay validation (cooldowns, ammo,
  range, line of sight) in `_Implementation` and silently reject.
- Prefer `Unreliable` RPCs for high-frequency cosmetic events; `Reliable` only for state-changing
  events. A flood of reliable RPCs can saturate and drop the connection.
- `NetMulticast` RPCs are for cosmetic one-offs (impact effects). State belongs in replicated
  properties so late joiners get it.
- Blueprint equivalents: the actor's Replicates flag, RepNotify variables, custom events set to
  Run on Server / Run on owning Client / Multicast, and the Switch Has Authority node.

## 3. Movement and prediction

- `CharacterMovementComponent` already predicts the local player's movement and corrects from the
  server. Extend it with custom movement modes through its saved-move mechanism rather than
  writing movement in Tick, or corrections will fight you.
- Mover (Experimental in 5.8) is Epic's modular, rollback-capable successor path; use it for new
  experimental projects only.
- Physics-heavy multiplayer: Chaos Networked Physics underpins Mover's physics backend; treat
  networked physics as a research task with a prototype before committing.

## 4. Iris

- Iris is opt-in and experimental in 5.8. The engine docs pitch it at larger, more interactive
  worlds, higher player counts and lower server costs.
- Follow the 5.8 Iris documentation for enabling it (build and config changes) instead of copying
  flags from older blog posts; settings have changed across versions.
- For a typical indie co-op or small competitive game, the generic replication system is the
  safer choice today.

## 5. Dedicated servers

- "You must use a source build of Unreal Engine" to build a dedicated server (UE 5.8 docs).
- Add `<PROJECT_NAME>Server.Target.cs` in `Source/` (Lyra's `LyraServer.Target.cs` is Epic's
  example), build the Server configuration, package server and client separately.
- Run the server headless in a container or VM; expose the game port (UDP by default for the
  standard net driver).
- Budget build time and disk: a source build plus server and client cooks is a CI concern
  (`game-ci-pipeline`).

## 6. Online services, lobbies and relays

- **EOS** (Epic Online Services): lobbies, sessions, P2P with relay, voice, Easy Anti-Cheat;
  cross-platform. Integrated through the EOS Online Subsystem / Online Services plugins.
- **Steam**: Steam online subsystem plus the Steam sockets plugin for Steam Datagram Relay (hides
  IP addresses, no port forwarding). Steam lobbies and invites through the overlay.
- Plugin names and which generation (Online Subsystem vs Online Services) to use change across
  versions; check the 5.8 docs for your platform mix.
- Listen-server co-op over EOS or Steam relays needs no servers you pay for.

## 7. Testing in Unreal

- **Play In Editor**: set Number of Players and Net Mode (Play As Listen Server / Play As Client)
  to run several clients; test with "Run Under One Process" both on and off, since single-process
  testing hides real serialization bugs.
- **Network emulation (UE 5.8 docs)**:
  - Editor: Edit > Editor Preferences > Level Editor > Play > Multiplayer Options > **Enable Network
    Emulation**, with profiles Custom, Average and Bad filling incoming and outgoing latency and loss.
  - Console at runtime: `NetEmulation.PktLag <ms>`, `NetEmulation.PktLoss <percent>`, and other
    `NetEmulation.<Setting>` values.
  - Command line: `<SETTING_NAME>=<VALUE>` arguments; config: a `[PacketSimulationSettings]`
    section in `DefaultEngine.ini`; `PktEmulationProfile` selects a named profile.
  - `PktLag` cannot be combined with `PktOrder`; `PktLagVariance` needs `PktLag`.
- **Networking Insights** (Unreal Insights) shows bandwidth per actor and property; use it to find
  what is eating your budget.
- Automation tests can spin up multi-client sessions; the experimental Unreal MCP in 5.8 can run
  automation tests from an agent (editor-only, loopback, no auth).

## 8. Unreal checklist

```markdown
- [ ] Authority map matches code: GameMode server-only logic; state in replicated properties
- [ ] Server RPCs validate rate, range, resources; WithValidation used only for impossibilities
- [ ] Reliable RPCs limited to state changes; cosmetics unreliable or multicast
- [ ] Relevancy and update frequency set per actor class; Networking Insights reviewed
- [ ] Movement through CharacterMovementComponent (or Mover, accepted as experimental)
- [ ] Dedicated server target builds from source in CI (if dedicated)
- [ ] Network emulation profile "Bad" used in regular playtests; multi-process PIE tested
- [ ] EOS/Steam relay path tested between two real networks, not just LAN
```
