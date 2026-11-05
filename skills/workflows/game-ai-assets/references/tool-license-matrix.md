# Tool and License Matrix for AI Game Assets

Snapshot: **2026-11-05**. Generators change models, plans and terms every few months, so treat
this file as a starting point and re-check the vendor's own terms on the day you generate
shippable assets. Record the terms URL and the date you read them in the tools register of the
provenance log (`${CLAUDE_PLUGIN_ROOT}/templates/ai-asset-log.md`).

**Evidence labels used below**
- **Verified 2026-11-05**: we fetched the vendor's own page or license text on that date.
- **Brief**: from the GameForge research brief `ai-tooling-and-engines.md` (sources accessed
  2026-11-05); the brief's source tag is given as `[S#]`.
- **UNVERIFIED**: single secondary source, conflicting sources, or vendor terms we could not
  retrieve. Do not repeat these as fact to the user. Tell them to read the terms.

Prices are deliberately left out. Plans and prices move faster than this file; look them up on
the vendor's pricing page at generation time and note the plan name in the log.

---

## 1. Ten questions to answer from any tool's terms

Answer these before a single shippable asset is generated. If the terms do not answer a question,
write "not stated" in the tools register. Do not assume the friendly answer.

1. **Commercial use:** is it allowed on the plan you are actually on, not just on the top plan?
2. **Ownership or license:** do you *own* the output, or get a license such as CC BY 4.0 that
   requires attribution?
3. **Public or private:** does the plan publish your generations or uploads to a public gallery?
4. **Territory:** does the license exclude any country you sell in or *display marketing* in?
5. **Thresholds:** revenue or monthly-active-user limits that trigger a separate license.
6. **Training restrictions:** can you train a LoRA or style model on the outputs? Some tools forbid it.
7. **Input rights:** what do they do with your uploaded references (retention, training, sharing)?
8. **Indemnity:** does any plan indemnify you against infringement claims?
9. **Marking:** does the vendor embed watermarks or provenance metadata in outputs? Keep those
   intact in anything you publish as-is.
10. **Change clause:** can they change terms retroactively? Snapshot the page (save a PDF next
    to the raw outputs) for any asset that ships.

---

## 2. 3D models

| Tool | Strengths (as reported) | License facts | Shipping verdict |
|---|---|---|---|
| **Meshy 6** (Jan 2026) | Low-poly mode, Remesh retopology, auto-rig. Brief [S48]. | **Verified 2026-11-05** (pricing page): Free plan outputs are **CC BY 4.0**, "commercial use with attribution". The FAQ asks free users to credit Meshy on sales pages. Paid plans are listed as **"Private & Customer owned"**. | Paid plan for anything that ships. If a Free-plan asset ships, log the attribution line and add it to credits. |
| **Tripo P1 "Smart Mesh"** (Mar 2026) | Topology-focused output. A reviewer found it **still needs cleanup for hero assets**. Brief [S49]. | The free Basic plan lists **public models under CC BY 4.0** (official pricing page, via search 2026-11-05; direct fetch returned 403). Tripo's own pages **conflict** on whether free output may be used commercially. Paid tiers are reported as private with commercial use (**UNVERIFIED**). | Treat free-tier output as **prototype-only**. Never upload unannounced designs on a public tier. |
| **Rodin Gen-2 / Gen-2.5** (Hyper3D) | Quad-dominant meshes (vendor claim). Brief [S50]. Also offered inside Scenario. | Official terms not retrieved. Third-party sources disagree on free-tier commercial rights (**UNVERIFIED**). | Read the current terms. When you use it through a platform such as Scenario, log both the platform's terms and the model's. |
| **Hunyuan3D 2.1** (Tencent, open weights) | Image-to-3D with textures. Hunyuan3D 3.x is reportedly API-only (**UNVERIFIED**). Brief [S51]. | **Verified 2026-11-05** (LICENSE): "Territory" is worldwide **excluding the EU, UK and South Korea**. §5(c) bars using, distributing or *displaying* **outputs** outside the Territory. Services with more than **1M monthly active users** must request a license (§4). §5(b) bars using outputs to improve other AI models. | **Do not use** for a game or marketing that can reach the EU, UK or South Korea, which covers any normal Steam or itch.io release. A store page shown there is a display. |
| **TRELLIS.2-4B** (Microsoft) | Mesh with PBR materials, GLB export. Paper published 2025-12-16. | **Verified 2026-11-05** (model card): **MIT license**. Needs an NVIDIA GPU with **at least 24 GB**. **Tested only on Linux**. | Cleanest license. Runs locally, so references never leave your machine. Needs the hardware. |
| **World models** (Genie 4 preview 2026-10-27, Marble, Muse) | Explorable scenes. Marble exports splats and GLB, with export on the paid Pro plan. Brief [S64][S66][S68]. | Varies by product. | Pitch, mood and graybox only. None is a production asset source. Brief [S64]. |

**Topology reality (Brief [S48][S49]):** auto-retopology and auto-rigging are acceptable for props
and background characters. Hero assets still need hand-placed edge loops. See
`post-processing.md`.

---

## 3. 2D, pixel art and sprites

| Tool | Strengths (as reported) | License facts | Notes |
|---|---|---|---|
| **PixelLab** | Rotations, skeleton animation, tilesets, Aseprite plugin, API (third-party reports). Brief [S53]. | **Verified 2026-11-05** (ToS, "Last Updated 2026-10-30"): "You retain ownership of any content you create." Commercial and non-commercial use permitted (§1.3). You may **not train your own models on PixelLab outputs** without written permission (§1.2, §3.3). | Do not build a LoRA from PixelLab sprites. For style models, train on hand-made art instead. |
| **Retro Diffusion** | RD Plus is FLUX-based and trained at 256 px or less. RD Animation makes spritesheets. Brief [S54]. | Official ToS not retrieved. Developer statements and third-party reviews say users own outputs and paid plans include a commercial license (**UNVERIFIED**). | Output is often close to the pixel grid but not exactly on it. Snap it to a true grid and remap to your palette (`post-processing.md` §2). |
| **Scenario** | Style training plus tileable PBR maps. Hosts third-party models such as Retro Diffusion and Rodin. Brief [S55][S54][S50]. | Terms not retrieved (**UNVERIFIED**). Hosted third-party models may carry their own terms. | Style training is only as clean as its training set: use art you own or have licensed for AI training. |
| **Layer.ai** | Multi-model studio workspace aimed at volume. Brief [S55]. | Terms not retrieved (**UNVERIFIED**). | Log the underlying model per asset, not just "Layer". |
| **Open-weight image checkpoints** | Local generation through ComfyUI and similar tools. | Each checkpoint, LoRA and ControlNet has its own license. Some cap revenue or forbid commercial use. | Log checkpoint name, hash or version, and every LoRA with its license. |

---

## 4. Textures and PBR materials

- **Scenario** generates tileable PBR maps. Brief [S55].
- **TRELLIS.2** outputs PBR materials on generated meshes. Model card, verified 2026-11-05.
- **No independent texture benchmark exists**, and "seamless" output does not always tile. Check
  the edges every time. Brief [S55]. A seam check command is in `post-processing.md` §2.
- **Buy or free alternative:** Poly Haven textures, HDRIs and models are **CC0**. "You can use our
  assets for any purpose", with no credit required (license page, verified 2026-11-05). Scanned
  CC0 materials are often a better background texture than a generated one, and they need no AI
  disclosure. Log them anyway as third-party CC0 (disclosure category `none`) so the log covers
  every external asset in the build.

---

## 5. Animation

| Tool | What it does | Notes |
|---|---|---|
| **Move AI Gen 2** | Single-camera `s2` video-to-motion model. Brief [S56]. | Film yourself or a consenting performer. Log the performer. |
| **Rokoko Vision 3.0** (2026-07-16) | Video-to-motion and text-to-motion. Brief [S57]. | Text-to-motion output is generated content. Video-to-motion of a real performance is capture, but log it either way. |
| **Cascadeur 2026.1 / 2026.2** | Generative motion between keys, UE Live Link, animation layers (2026.2, 2026-08-06), MCP server. Brief [S47]. | Good for cleaning capture and posing heroes by hand with physics assistance. |
| **Meshy auto-rig** | Auto-rigging for generated characters. Brief [S48]. | Check weights at the shoulders, hips and fingers before trusting it (`post-processing.md` §1.5). |
| **UE 5.8 webcam MetaHuman capture** | MetaHuman capture from a webcam. Brief [S25]. | Unreal only. |
| DeepMotion | | 2026 changes **UNVERIFIED**. |

If the performer in a capture is a union actor, the SAG-AFTRA Interactive Media Agreement covers
the performance and any digital replica made from it. See §7.

---

## 6. Sound effects and music

| Tool | Facts | Shipping verdict |
|---|---|---|
| **ElevenLabs SFX v2** (Sept 2025) | 30-second clips, seamless loops, 48 kHz output. Brief [S59]. **Verified 2026-11-05** (pricing page): a "Commercial License" is listed from the **Starter** plan upward. The Free plan's feature list has no commercial-use line. | Starter or higher for shipping. Treat Free-plan output as non-commercial. |
| **Stable Audio 3** (2026-05-20) | **Verified 2026-11-05** (Stability announcement): "trained on fully licensed data". **Small SFX, Small and Medium are open weights** on Hugging Face under the **Stability AI Community License**, and "you own your outputs". Organizations with **more than US$1M annual revenue** need the Enterprise license. Large is available through the API. Small runs up to two minutes and Medium up to 6:20. Small SFX targets on-device generation. | Good default for local SFX: no uploads, and licensed training data. Check the revenue threshold each year. |
| **Eleven Music** | Trained on licensed data (Merlin and Kobalt deals) and offered for commercial use. Brief [S60]. Pricing page lists "Music commercial use" from Starter (verified 2026-11-05). Game-specific tier requirements **UNVERIFIED**. | Acceptable for background music if the plan covers it. Log the plan. |
| **Suno / Udio** | UMG settled with Udio (Oct 2025), and Udio then **disabled downloads**. WMG settled with Suno (2025-11-25). **UMG and Sony are still suing Suno.** Brief [S61]. | **Legally unsettled for shipped games.** Temp tracks only: log them as `dev-only`, and replace them before any public build, trailer or stream. |

---

## 7. Voice

- **ElevenLabs** (TTS and voice cloning): commercial license from Starter upward (pricing page,
  verified 2026-11-05). Cloning anyone's voice, including a friend's or your own actor's, needs
  that person's **written, specific consent**. Store it with the raw files.
- **Inworld TTS-1.5:** about US$5–10 per million characters (Toolradar, read 2026-10-09). Brief
  [S70]. Use this for budgeting live TTS only; re-check before committing.
- **NVIDIA ACE on-device** (local ASR, Qwen 3.5 4B SLM and TTS, with function calling) is the
  most production-ready runtime option. Brief [S69]. Runtime voice is **live-generated** content:
  route the design to `game-narrative-director` and `game-technical-director`.
- **SAG-AFTRA 2025 Interactive Media Agreement:** ratified 2025-07-09 with 95.04% approval. It
  requires **consent and disclosure for digital replicas**, with a "reasonably specific
  description" of each intended use, and **usage reports** to performers. Performers can suspend
  consent during a strike. Brief [S63]. The agreement binds signatory companies. Non-signatory
  indies should still treat it as the bar players and press will hold them to.
- **Reputation case:** *ARC Raiders* used licensed TTS, then re-recorded many lines with actors
  after backlash. Brief [S73].

**Default:** use TTS for scratch and placeholder lines so you can time scenes and test pacing.
Cast humans for lead characters. Ship synthetic voices only with documented consent and disclosure.

---

## 8. Sources

- Meshy pricing and FAQ: https://www.meshy.ai/pricing (verified 2026-11-05)
- Tripo pricing: https://www.tripo3d.ai/pricing (search result 2026-11-05; direct fetch 403);
  Tripo licensing pages: https://www.tripo3d.ai/blog/commercial-use-ai-3d-models ,
  https://www.tripo3d.ai/game-development/3d-assets-license-game-development (these conflict)
- Hunyuan3D 2.1 license: https://raw.githubusercontent.com/Tencent-Hunyuan/Hunyuan3D-2.1/main/LICENSE (verified 2026-11-05)
- TRELLIS.2-4B model card: https://huggingface.co/microsoft/TRELLIS.2-4B (verified 2026-11-05)
- PixelLab Terms of Service: https://www.pixellab.ai/termsofservice (Last Updated 2026-10-30; verified 2026-11-05)
- Poly Haven license: https://polyhaven.com/license (verified 2026-11-05)
- ElevenLabs pricing: https://elevenlabs.io/pricing (verified 2026-11-05)
- Stability AI, Stable Audio 3: https://stability.ai/news-updates/meet-stable-audio-3-the-model-family-built-for-artistic-experimentation-with-open-weight-models (verified 2026-11-05)
- Research brief `ai-tooling-and-engines.md` §3 and sources [S25], [S47]–[S57], [S59]–[S64], [S68]–[S70], [S73]
