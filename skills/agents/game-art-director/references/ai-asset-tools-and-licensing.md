# AI Asset Tools, Licences, and Provenance (Art Director reference)

Snapshot: November 2026. Tool capabilities and licence terms change monthly. Treat every row as a
starting point: open the vendor's current terms page, read the licence file itself (not a summary),
and record the date you checked in the AI Asset Policy and in each provenance entry.

Claims marked *(vendor claim)* come only from the vendor. Claims marked **UNVERIFIED** could not be
confirmed and must not be repeated to the user as fact.

---

## 1. Tool and licence matrix

### 3D generation

| Tool | Status (late 2026) | Licence / terms | Strengths | Watch out for |
|---|---|---|---|---|
| **TRELLIS.2-4B** (Microsoft) | Open weights; paper 2025-12-16 | **MIT** | Full PBR output; you own the pipeline | Needs a 24 GB+ GPU; tested on Linux only |
| **Hunyuan3D 2.1** (Tencent) | Open weights | Tencent licence **does not apply in the EU, UK, or South Korea, including outputs**; services above 1M monthly active users need a separate licence | Strong shape quality | Unusable for any game sold in those territories. Hunyuan3D 3.x reportedly API-only (**UNVERIFIED**) |
| **Meshy 6** | Service (Jan 2026) | Commercial service terms; check the plan's output rights | Low-poly mode, Remesh retopology, auto-rig | Auto-retopo is fine for props, not hero deformation |
| **Tripo P1 "Smart Mesh"** | Service (Mar 2026) | Service terms | Topology-focused output | An independent review still found hero assets needed cleanup |
| **Rodin Gen-2 / Gen-2.5** (Hyper3D) | Service, also via aggregators | Service terms of whichever platform you call it through | Quad-dominant meshes *(vendor claim)* | Terms differ between direct and aggregator access |
| **World Labs Marble** | Service | Paid Pro plan required for export | Exports Gaussian splats and GLB meshes | Mood and greybox only; not production geometry |

### 2D, pixel art, textures

| Tool | What it does | Notes |
|---|---|---|
| **PixelLab** | Pixel-art rotations, skeleton animation, tilesets; Aseprite plugin and API | Feature list from third-party reports; check the commercial tier |
| **Retro Diffusion** | RD Plus (FLUX-based, trained at 256 px or smaller); RD Animation for sprite sheets | Good palette discipline; still review frame-to-frame consistency |
| **Scenario** | Style training on your own art; tileable PBR maps | Train only on art the team owns or has licensed for training |
| **Layer.ai** | Multi-model studio workspace aimed at volume | Volume is the risk: more variants, more drift |

No independent texture benchmark exists. "Seamless" output does not always tile: offset the texture by
half its width and height and inspect the seams before approving it.

### Animation

| Tool | What it does |
|---|---|
| **Move AI Gen 2** | Single-camera motion capture (`s2` model) |
| **Rokoko Vision 3.0** (2026-07-16) | Video-to-motion and text-to-motion |
| **Cascadeur 2026.1 / 2026.2** | Generative in-betweens, animation layers, Unreal Live Link; 2026.2 ships a simple MCP server |
| **UE 5.8 MetaHuman Animator** | Face and body capture from a single webcam |

MetaHuman licensing allows use in Unity and Godot and selling on Fab; using MetaHumans to train AI is
prohibited. DeepMotion's 2026 changes are **UNVERIFIED**.

### Image generation and local pipelines

General image models (cloud or local ComfyUI graphs) are fine for mood boards and concept
exploration. For production use, the policy must name the exact model and version, its licence, and
where its training data is documented. If a model's licence or training-data position is unclear,
it stays in ideation only.

---

## 2. Licence check procedure (run before a tool enters the policy)

1. **Territory**: list every country the game will be sold or streamed in. Reject any tool whose
   licence excludes one of them, including exclusions that cover outputs (Hunyuan3D 2.1).
2. **Scale clauses**: MAU or revenue thresholds that trigger a different licence (Hunyuan3D 2.1 at
   1M MAU; Stability AI Community License above US$1M revenue for its models).
3. **Output ownership**: does the plan you pay for grant commercial rights to outputs? Free tiers
   often do not.
4. **Training-data position**: is it documented? Is the vendor party to active litigation?
   (Late 2026: Getty v. Stability in the UK was largely won by Stability on 2025-11-04;
   Disney/Universal/WBD v. Midjourney is in discovery; Andersen v. Stability has a summary-judgment
   hearing set for Feb 2027.)
5. **Input rights**: you may only feed the tool images you own or are licensed to transform.
6. **Record**: tool, version, licence name, URL, date checked, territories cleared, reviewer.

---

## 3. Provenance log

Every non-hand-made asset gets an entry in the project's `ai-asset-log.md` (created by
`/gameforge:game-ai-assets` from the plugin's log template; if it does not exist yet, create it in
`design/`). Log at integration time, not at launch.

| Field | Example |
|---|---|
| ID | 47 |
| Asset path | `public/assets/models/env_ruins_pillar_broken.glb` |
| Tool and version | TRELLIS.2-4B, local, commit abc123 |
| Licence, date checked | MIT, 2026-11-05 |
| Input | Concept paintover CP-112 (team-owned) |
| Prompt or settings | Seed 1842, PBR on, decimation 0.4 |
| Human edits | Manual retopology, UV layout, albedo repaint, roughness pass |
| Author of edits | J. Park |
| Status | placeholder / in-review / final / removed |
| Disclosure category | Steam pre-generated: artwork; itch.io AI tag |

Why the "human edits" column matters: under the US Copyright Office's Part 2 report (2025-01-29),
prompts alone do not make an output protectable, while human selection, arrangement, and modification
can be. The Supreme Court denied cert in *Thaler* on 2026-03-02, so human authorship remains the US
requirement. The log is your evidence of human contribution.

---

## 4. Disclosure mapping

| Where | What triggers disclosure | What the log must support |
|---|---|---|
| Steam content survey (rewritten 2026-01-16) | Pre-generated content players consume: artwork, sound, narrative, localization, and marketing assets. Code assistants are exempt. | List of shipped generated assets by category; marketing assets included |
| Steam live-generated content | Runtime generation in the shipped game | Description of guardrails |
| itch.io | Generative-AI content in the project | AI disclosure; the "no AI" filter now also applies to search (Nov 2026) |
| EU AI Act Art. 50 | Runtime generative systems need machine-readable marking (50(2)); AI characters must be disclosed unless obvious (50(1)) | Pre-generated art usually falls outside 50(2); runtime image generation does not |
| Credits | Studio policy | Tool names under "AI-assisted production" |

Platform holders without a public AI-specific store rule (PlayStation, Nintendo, per late-2026
reporting) still expect accurate marketing. Never describe generated work as hand-made.

---

## 5. Reputation context (attributed, public record)

- **Indie Game Awards, Dec 2025**: rescinded *Clair Obscur*'s awards over generated placeholder
  textures that had been patched out after launch. Placeholder art that ships, even briefly, counts.
- **GDC 2026 State of the Industry**: 52% of respondents say generative AI is harming the industry
  (up from 30% in 2025); 36% use it at work. Your players and peers include many of the 52%.
- **itch.io, Nov 2026**: deleted "a couple terabytes" of AI uploads and extended its AI filter to
  search. Store flooding makes visible craft a differentiator.

---

## 6. "Gameslop" avoidance protocol

1. **Brief before batch.** Every generation session starts from a written brief that cites the style
   reference sheet and lists known failure modes as negatives.
2. **Automated pre-checks.** Resolution, triangle count, texture size, palette distance from the
   approved hex ranges, and tiling seams. Reject before human review.
3. **Art director review.** Shape language, material accuracy, lighting direction, and the classic
   artifacts: fused fingers, melted geometry, asymmetry where symmetry is expected, unreadable text,
   inconsistent shadow direction, over-smooth surfaces.
4. **In-context test.** In-engine at gameplay distance beside hand-made assets. Looks fine alone but
   clashes in context = fail.
5. **Playtest signal.** Flag comments like "that looks off" or "this doesn't fit" and pull the asset.

Project-level cap: the policy may set a maximum share of generated content per asset class (for
example, "background props only"). Set it by asset class, not as a single percentage of everything,
so the core visual identity stays human-authored.

---

## 7. Hero-asset retopology checklist

- [ ] Edge loops follow deformation: shoulders, elbows, wrists, knees, hips, neck
- [ ] Face loops around eyes and mouth for expression or blend shapes
- [ ] Quads in deforming areas; triangles only on flat, static surfaces
- [ ] Triangle count inside the class budget at LOD0; LODs generated afterwards
- [ ] UVs re-laid by hand: seams hidden, consistent texel density, no stretched islands
- [ ] Textures re-baked from the generated high-poly onto the new topology
- [ ] Skin weights painted and tested through the full animation set
- [ ] Silhouette re-checked after decimation for each LOD
- [ ] Provenance entry updated: "human retopology, UV, bake, weights"
