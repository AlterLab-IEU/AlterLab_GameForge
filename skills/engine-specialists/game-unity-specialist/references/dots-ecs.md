# DOTS / ECS in Unity 6 (6.3 LTS / 6.6)

Read this before recommending ECS, writing systems, or reviewing ECS code that an agent produced.
Netcode for Entities design belongs to `/gameforge:game-multiplayer`.

---

## 1. Should this project use ECS at all?

ECS helps when **profiling shows** the CPU cost comes from many similar things updated every frame.
It is a poor trade when the game's complexity sits in content, UI, narrative or one-off behaviours.

| Signal | Recommendation |
|---|---|
| Fewer than a few hundred active simulated objects | MonoBehaviour + pooling. Profile first. |
| Hot loops over arrays of plain data (projectiles, boids, crowds) | **Jobs + Burst** on `NativeArray`s first; no ECS needed |
| Thousands of homogeneous entities, plus a need for streaming/subscenes | ECS (Entities + Entities Graphics) |
| Deterministic simulation or prediction for netcode | ECS + Netcode for Entities. Design with `game-multiplayer` |
| Team new to data-oriented design, jam or prototype timeline | Do not adopt ECS now |

Hybrid is normal. Keep UI, audio, cameras and menus as GameObjects, and put the simulation in ECS.

---

## 2. Where ECS stands

- Per Unity's December 2025 ECS status post, Entities, Collections, Mathematics and Entities Graphics
  became **core packages in Unity 6.4**.
- Unity's "ECS Development Status for Unity 6.6" post:
  - "All of the ECS packages are now core packages", developed in line with Unity releases.
  - The 6.6 focus is aligning the `EntityId` type between GameObjects and Entities. The EntityId
    migration to 8 bytes is complete.
- **Deprecated APIs** (agents trained on older samples still emit these):

| Deprecated | Since | Use instead |
|---|---|---|
| Aspects (`IAspect`) | marked obsolete in Entities 1.3.x; 1.4 upgrade guide | Component access + `SystemAPI.Query` / `EntityQuery` |
| `Entities.ForEach`, `Job.WithCode` | obsolete in Entities 1.4 | `IJobEntity`, `SystemAPI.Query`, `IJob` |
| Managed components (class `IComponentData`, managed shared components) | deprecated in 6.6 | Unmanaged structs with `UnityObjectRef<T>` |
| Entities Hierarchy window | deprecated in 6.6 | Standard Hierarchy window |
| `SystemBase` for new code | not deprecated, but not Burst-compiled | `ISystem` with `[BurstCompile]` |

---

## 3. Minimal modern ECS slice

Authoring + baker: the GameObject side, converted at bake time.

```csharp
using Unity.Entities;
using UnityEngine;

namespace Game.Simulation
{
    public struct MoveSpeed : IComponentData
    {
        public float Value;
    }

    public sealed class MoveSpeedAuthoring : MonoBehaviour
    {
        [SerializeField, Min(0f)] private float _speed = 3f;

        private sealed class MoveSpeedBaker : Baker<MoveSpeedAuthoring>
        {
            public override void Bake(MoveSpeedAuthoring authoring)
            {
                Entity entity = GetEntity(TransformUsageFlags.Dynamic);
                AddComponent(entity, new MoveSpeed { Value = authoring._speed });
            }
        }
    }
}
```

The system plus job: Burst-compiled and scheduled in parallel.

```csharp
using Unity.Burst;
using Unity.Entities;
using Unity.Mathematics;
using Unity.Transforms;

namespace Game.Simulation
{
    [BurstCompile]
    public partial struct MoveJob : IJobEntity
    {
        public float DeltaTime;

        private void Execute(ref LocalTransform transform, in MoveSpeed speed)
        {
            transform.Position += new float3(0f, 0f, speed.Value * DeltaTime);
        }
    }

    [BurstCompile]
    public partial struct MoveSystem : ISystem
    {
        [BurstCompile]
        public void OnCreate(ref SystemState state) => state.RequireForUpdate<MoveSpeed>();

        [BurstCompile]
        public void OnUpdate(ref SystemState state)
        {
            new MoveJob { DeltaTime = SystemAPI.Time.DeltaTime }.ScheduleParallel();
        }
    }
}
```

Main-thread iteration for small or simple cases:

```csharp
foreach (var (transform, speed) in
         SystemAPI.Query<RefRW<LocalTransform>, RefRO<MoveSpeed>>())
{
    transform.ValueRW.Position.y += speed.ValueRO.Value * SystemAPI.Time.DeltaTime;
}
```

---

## 4. Structural changes and spawning

- Add/remove components or create/destroy entities through an `EntityCommandBuffer`. Take it from
  `SystemAPI.GetSingleton<EndSimulationEntityCommandBufferSystem.Singleton>()` and call
  `.CreateCommandBuffer(state.WorldUnmanaged)`. Do not make structural changes inside a job's
  iteration.
- Prefer **enableable components** (`IEnableableComponent`) to toggle state without structural
  changes.
- Spawn from baked prefab entities (`GetEntity(prefab, TransformUsageFlags.Dynamic)` in a baker). Do
  not instantiate GameObjects for simulation entities.
- Use **subscenes** for content. Baking happens in the Editor, and the runtime streams baked data.

---

## 5. Reviewing agent-written ECS code

- [ ] No `Entities.ForEach`, `IAspect`, or managed `class : IComponentData` in new code.
- [ ] Systems are `partial struct : ISystem` with `[BurstCompile]` on the struct and its methods.
- [ ] No managed types (strings, classes, `List<T>`) inside Burst code. Use `FixedString*`,
      `NativeList<T>` and blob assets.
- [ ] Every `Allocator.Persistent` / `TempJob` native container is disposed of.
- [ ] Job dependencies flow through `state.Dependency` (implicit with `ScheduleParallel()` in an
      `ISystem`) and are not completed early without reason.
- [ ] Reads are declared `in` / `RefRO`, writes `ref` / `RefRW`, so the safety system and the
      scheduler can parallelise.
- [ ] Profile with the Entities profiler modules and the Systems window (6.6 adds a scheduling
      column). Do not assume Burst made it fast.

---

## 6. Physics and netcode

- **Unity Physics** (stateless, deterministic-friendly) is the default for ECS physics.
- **Havok Physics for Unity** is a separately licensed alternative. Confirm current licensing on
  Unity's site before recommending it.
- **Netcode for Entities:**
  - Prediction, interpolation and ghost snapshots.
  - Per the 6.3 LTS release post, host migration through Unity Gaming Services.
  - Architecture, tick rates and authority models are designed in `/gameforge:game-multiplayer`.
