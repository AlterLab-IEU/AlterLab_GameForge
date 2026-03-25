# MCP Integrations for Game Development

## Overview

Model Context Protocol (MCP) servers extend Claude Code with direct tool access to external services -- game engines, 3D modeling software, audio generation platforms, project management tools, and more. Instead of describing what you want and then manually switching to another application, MCP servers let Claude Code operate those tools directly within your development session.

For game developers, this means Claude can launch your Godot project, create a 3D model in Blender, generate sound effects through ElevenLabs, file a GitHub issue, update your Notion GDD, and push a build -- all without leaving the conversation. MCP turns Claude Code from an advisor into a hands-on collaborator.

This document maps the MCP ecosystem to GameForge skills, recommends server configurations for different team sizes and engines, and provides ready-to-use setup instructions.

---

## Already Connected

These 15 MCP servers are available through your Claude Code environment. No additional installation is needed.

| MCP Server | Game Dev Use Case | Mapped GameForge Skills | Priority |
|---|---|---|---|
| **GitHub** | Version control, issue tracking, PR reviews, project boards | `game-code-review`, `game-sprint-plan`, `game-launch`, `game-producer` | Critical |
| **Filesystem** | Read/write game project files, manage asset directories, edit configs | All engine specialists, `game-prototype`, `game-start` | Critical |
| **Memory** | Persist knowledge graph across sessions -- design decisions, character bibles, world lore | `game-designer`, `game-narrative-director`, `game-creative-director` | Critical |
| **Context7** | Fetch up-to-date docs for Godot, Unity, Phaser, Pixi.js, or any library | All engine specialists, `game-technical-director` | High |
| **Notion** | Game design documents, sprint boards, wikis, content tracking | `game-designer`, `game-producer`, `game-sprint-plan`, `game-design-review` | High |
| **Figma** | UI/UX mockups, HUD design, menu flows, icon sheets | `game-ux-designer`, `game-art-director` | High |
| **Playwright** | Automate browser testing for web-based games, scrape asset stores, test web builds | `game-qa-lead`, `game-playtest` | High |
| **HuggingFace** | Search/use ML models for procedural generation, image classification, NPC behavior | `game-technical-director`, `game-art-director` | Medium |
| **Excalidraw** | Quick whiteboarding -- level layouts, system diagrams, flow charts | `game-designer`, `game-brainstorm`, `game-design-review` | Medium |
| **Canva** | Marketing assets, store page graphics, social media for game launches | `game-launch`, `game-producer` | Medium |
| **Slack** | Team communication, build notifications, playtest coordination | `game-team-orchestrator`, `game-retrospective` | Medium |
| **Google Calendar** | Sprint planning, milestone deadlines, playtest scheduling | `game-sprint-plan`, `game-producer` | Low |
| **Gmail** | Publisher communications, press outreach, beta invites | `game-launch` | Low |
| **Vercel** | Deploy web game builds, marketing sites, companion apps | `game-launch`, `game-prototype` | Low |
| **Cloudflare** | CDN for game assets, R2 storage for builds, D1 for leaderboards | `game-launch`, `game-analytics-setup` | Low |

---

## Engine-Specific MCPs

### Godot MCP Servers

Godot has the richest indie-friendly MCP ecosystem, with multiple mature options for AI-assisted game development.

| Rank | Server | Stars | What It Does | Install |
|---|---|---|---|---|
| 1 | [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) | 2,616 | Launch editor, run projects, capture debug output. The most popular Godot MCP. | See repo README |
| 2 | [HaD0Yun/Gopeak-godot-mcp](https://github.com/HaD0Yun/Gopeak-godot-mcp) | 90 | 95+ tools: scene management, GDScript LSP, DAP debugger, screenshots, ClassDB, CC0 assets. Widest tool coverage. | `npx gopeak` |
| 3 | [ee0pdt/Godot-MCP](https://github.com/ee0pdt/Godot-MCP) | 509 | Create and edit games in Godot with AI tools. Clean integration for assisted development. | See repo README |

**Recommendation:** Start with **Coding-Solo/godot-mcp** for general use. If you need deep LSP integration, debugger access, or asset library browsing, add **Gopeak** alongside it.

Other notable Godot MCPs:
- [DaxianLee/godot-mcp](https://github.com/DaxianLee/godot-mcp) (250 stars) -- One-click config, common operations
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) (142 stars) -- MCP Server + Godot Plugin combo
- [tugcantopaloglu/godot-mcp](https://github.com/tugcantopaloglu/godot-mcp) (60 stars) -- 149 tools for Godot 4.x
- [Nihilantropy/godot-mcp-docs](https://github.com/Nihilantropy/godot-mcp-docs) (53 stars) -- Documentation search server

### Unity MCP Servers

Unity has the most-starred single MCP server in the game engine category, with strong support for AI-controlled editor operations.

| Rank | Server | Stars | What It Does | Install |
|---|---|---|---|---|
| 1 | [CoplayDev/unity-mcp](https://github.com/CoplayDev/unity-mcp) | 7,540 | Bridge for AI to manage assets, control scenes, edit scripts, automate tasks. The dominant Unity MCP. | See repo README |
| 2 | [IvanMurzak/Unity-MCP](https://github.com/IvanMurzak/Unity-MCP) | 1,659 | AI Skills, MCP Tools, CLI for Unity. Full AI dev/test loop. Expose any C# method as a tool. | See repo README |
| 3 | [jackwrichards/UnityMCP](https://github.com/jackwrichards/UnityMCP) | 515 | Clean Unity MCP integration for AI-assisted workflows. | See repo README |

**Recommendation:** **CoplayDev/unity-mcp** is the primary pick for most Unity projects. If you need the ability to expose arbitrary C# methods as MCP tools, **IvanMurzak/Unity-MCP** is the more flexible (and more advanced) option.

Other notable Unity MCPs:
- [quazaai/UnityMCPIntegration](https://github.com/quazaai/UnityMCPIntegration) (148 stars) -- Enable AI agents to control Unity
- [isuzu-shiranui/UnityMCP](https://github.com/isuzu-shiranui/UnityMCP) (127 stars) -- TypeScript server + C# plugin, TCP/IP, extensible
- [AnkleBreaker-Studio/unity-mcp-server](https://github.com/AnkleBreaker-Studio/unity-mcp-server) (74 stars) -- Full Unity Hub + Editor AI control

### Unreal MCP Servers

Unreal's MCP ecosystem is maturing. Setup is more complex than Godot or Unity due to the C++ compilation pipeline, but the available servers provide meaningful AI control over the editor.

| Rank | Server | Stars | What It Does | Install |
|---|---|---|---|---|
| 1 | [chongdashu/unreal-mcp](https://github.com/chongdashu/unreal-mcp) | 1,637 | Control Unreal Engine through natural language via MCP. The leading Unreal MCP. | See repo README |
| 2 | [kvick-games/UnrealMCP](https://github.com/kvick-games/UnrealMCP) | 549 | AI agents control Unreal with a broad set of editor operations. | See repo README |
| 3 | [ChiR24/Unreal_mcp](https://github.com/ChiR24/Unreal_mcp) | 412 | C++ Automation Bridge plugin + TypeScript MCP server. Dual-layer architecture. | See repo README |

**Recommendation:** **chongdashu/unreal-mcp** is the primary pick. Note that all Unreal MCPs require installing a companion plugin inside the engine -- plan for setup time.

Other notable Unreal MCPs:
- [runreal/unreal-mcp](https://github.com/runreal/unreal-mcp) (88 stars) -- Uses Unreal Python Remote Execution
- [GenOrca/unreal-mcp](https://github.com/GenOrca/unreal-mcp) (68 stars) -- UE5 control with Python and C++ support

### Blender MCP

Blender MCP enables AI-driven 3D modeling -- the single most impactful creative MCP for game developers without a dedicated 3D artist.

| Server | Stars | What It Does | Install |
|---|---|---|---|
| [ahujasid/blender-mcp](https://github.com/ahujasid/blender-mcp) | 18,022 | The dominant Blender MCP. AI-driven 3D modeling, scene creation, material setup. Requires Blender addon installation. | `uvx blender-mcp` |

At 18,022 stars, this is the most-starred game-dev-adjacent MCP server. It enables Claude to create and manipulate 3D assets directly in Blender -- from scene composition to material assignment to basic modeling operations.

Other Blender MCPs:
- [VxASI/blender-mcp-vxai](https://github.com/VxASI/blender-mcp-vxai) (291 stars) -- Blender MCP variant
- [CommonSenseMachines/blender-mcp](https://github.com/CommonSenseMachines/blender-mcp) (126 stars) -- Text to 4D Worlds in Blender
- [poly-mcp/Blender-MCP-Server](https://github.com/poly-mcp/Blender-MCP-Server) (28 stars) -- 51 tools covering modeling, materials, lighting, rendering, animation

---

## Creative Asset MCPs

### Image Generation

| Server | Stars | What It Does | Best For |
|---|---|---|---|
| [AIDC-AI/Pixelle-MCP](https://github.com/AIDC-AI/Pixelle-MCP) | 938 | Open-source multimodal AIGC via ComfyUI + MCP + LLM | Full AI art pipeline with local ComfyUI |
| [joenorton/comfyui-mcp-server](https://github.com/joenorton/comfyui-mcp-server) | 237 | Lightweight Python MCP server for local ComfyUI | Simple local image generation |
| [raveenb/fal-mcp-server](https://github.com/raveenb/fal-mcp-server) | 40 | Fal.ai MCP -- generate images, videos, music, audio via cloud API | Cloud-based generation without local GPU |

For concept art exploration, texture generation, and style prototyping, connect a ComfyUI MCP if you have a local GPU, or the fal.ai MCP for cloud-based generation. The already-connected **HuggingFace** MCP can also access image generation models.

Mapped GameForge skill: `game-art-director`

### Audio Generation

| Server | Stars | What It Does | Best For |
|---|---|---|---|
| [elevenlabs/elevenlabs-mcp](https://github.com/elevenlabs/elevenlabs-mcp) | 1,272 | Official ElevenLabs MCP -- TTS, voice cloning, SFX generation, 48kHz output, 32 languages | Voice acting prototypes, SFX, TTS for dialogue |
| [raveenb/fal-mcp-server](https://github.com/raveenb/fal-mcp-server) | 40 | Fal.ai -- includes audio and music generation models | Music generation, ambient audio |

Audio MCP tooling is still thin compared to visual tools. ElevenLabs is the clear leader for voice and sound effects. For music generation, no dedicated Suno or Udio MCP servers exist yet -- fal.ai provides some audio model access.

Mapped GameForge skill: `game-audio-director`

---

## Project Management MCPs

| Server | Stars | Status | What It Does |
|---|---|---|---|
| [github/github-mcp-server](https://github.com/github/github-mcp-server) | 28,245 | Already connected | Official GitHub MCP -- repos, issues, PRs, Actions |
| [suekou/mcp-notion-server](https://github.com/suekou/mcp-notion-server) | 872 | Already connected | Notion pages, databases, comments |
| [jerhadf/linear-mcp-server](https://github.com/jerhadf/linear-mcp-server) | 347 | Optional install | Linear project management -- issues, projects, cycles |

GitHub and Notion are already available. If your team uses Linear for issue tracking, the Linear MCP server integrates cleanly.

Mapped GameForge skills: `game-producer`, `game-sprint-plan`, `game-code-review`

---

## Setup Guide

Add engine-specific and creative MCP servers to your `~/.claude.json` configuration. The servers below complement the 15 already-connected servers.

### Example mcpServers Configuration

```jsonc
{
  "mcpServers": {
    // --- ALREADY CONNECTED (via claude.ai) ---
    // filesystem, memory, github, context7, notion, figma, playwright,
    // excalidraw, huggingface, slack, canva, google calendar, gmail,
    // vercel, cloudflare

    // --- ENGINE: GODOT ---
    "godot-mcp": {
      "command": "npx",
      "args": ["-y", "godot-mcp"]
      // https://github.com/Coding-Solo/godot-mcp (2,616 stars)
    },

    // --- ENGINE: UNITY (uncomment if using Unity) ---
    // "unity-mcp": {
    //   "command": "npx",
    //   "args": ["-y", "unity-mcp"]
    //   // https://github.com/CoplayDev/unity-mcp (7,540 stars)
    // },

    // --- ENGINE: UNREAL (uncomment if using Unreal) ---
    // "unreal-mcp": {
    //   // https://github.com/chongdashu/unreal-mcp (1,637 stars)
    //   // Requires Unreal plugin installation -- see repo README
    // },

    // --- 3D MODELING ---
    "blender-mcp": {
      "command": "uvx",
      "args": ["blender-mcp"]
      // https://github.com/ahujasid/blender-mcp (18,022 stars)
      // Requires Blender addon installation -- see repo README
    },

    // --- AUDIO ---
    "elevenlabs": {
      "command": "npx",
      "args": ["-y", "@anthropic/elevenlabs-mcp"],
      "env": {
        "ELEVENLABS_API_KEY": "${ELEVENLABS_API_KEY}"
      }
      // https://github.com/elevenlabs/elevenlabs-mcp (1,272 stars)
    },

    // --- IMAGE GENERATION (pick one) ---
    "comfyui-mcp": {
      "command": "uvx",
      "args": ["comfyui-mcp-server"]
      // https://github.com/joenorton/comfyui-mcp-server (237 stars)
      // Requires local ComfyUI instance running
    }
    // OR for cloud-based image/audio generation:
    // "fal-mcp": {
    //   "command": "npx",
    //   "args": ["-y", "fal-mcp-server"],
    //   "env": {
    //     "FAL_KEY": "${FAL_KEY}"
    //   }
    //   // https://github.com/raveenb/fal-mcp-server (40 stars)
    // }
  }
}
```

> **Important:** Check each repo's README for exact install commands -- the above `command`/`args` are representative but may differ per repo version. Many engine MCPs require a companion plugin installed in the engine itself.

---

## Recommended Configurations

### Solo Indie Dev (Godot)

The most common GameForge user profile. Optimized for one person wearing every hat.

**Already connected (no setup needed):**
- GitHub -- version control, issues for solo task tracking
- Filesystem -- project file access
- Memory -- persist design decisions between sessions
- Context7 -- Godot documentation lookup
- Notion -- GDD management
- Excalidraw -- level layout whiteboarding

**Add these:**
| Server | Why | Config Key |
|---|---|---|
| [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) | Direct Godot editor control | `godot-mcp` |
| [ahujasid/blender-mcp](https://github.com/ahujasid/blender-mcp) | 3D asset creation without a dedicated artist | `blender-mcp` |
| [elevenlabs/elevenlabs-mcp](https://github.com/elevenlabs/elevenlabs-mcp) | Prototype voice lines and generate SFX | `elevenlabs` |

**Total cost:** Free (Godot, Blender) + ElevenLabs API fees for audio generation.

### Small Team (Unity)

A 2-5 person team using Unity. Collaboration tools become more important.

**Already connected (no setup needed):**
- GitHub -- PRs, code review, project boards
- Notion -- shared GDD, sprint boards
- Figma -- UI/HUD design handoffs
- Slack -- team communication
- Google Calendar -- sprint milestones
- Playwright -- web build testing

**Add these:**
| Server | Why | Config Key |
|---|---|---|
| [CoplayDev/unity-mcp](https://github.com/CoplayDev/unity-mcp) | AI-assisted Unity editor operations | `unity-mcp` |
| [ahujasid/blender-mcp](https://github.com/ahujasid/blender-mcp) | 3D asset pipeline acceleration | `blender-mcp` |
| [elevenlabs/elevenlabs-mcp](https://github.com/elevenlabs/elevenlabs-mcp) | Placeholder voice for playtesting | `elevenlabs` |
| [AIDC-AI/Pixelle-MCP](https://github.com/AIDC-AI/Pixelle-MCP) | AI art pipeline for concept/texture generation | `pixelle-mcp` |

### AAA Prototype (Unreal)

A larger team or funded studio prototyping in Unreal Engine. Full pipeline coverage.

**Already connected (no setup needed):**
- GitHub -- enterprise workflow with branch protection
- Notion -- design documentation wiki
- Figma -- UI specification and prototyping
- Slack -- multi-channel team coordination
- Google Calendar -- milestone planning
- Canva -- marketing asset creation

**Add these:**
| Server | Why | Config Key |
|---|---|---|
| [chongdashu/unreal-mcp](https://github.com/chongdashu/unreal-mcp) | AI control of Unreal Editor | `unreal-mcp` |
| [ahujasid/blender-mcp](https://github.com/ahujasid/blender-mcp) | 3D asset prototyping before full art pipeline | `blender-mcp` |
| [elevenlabs/elevenlabs-mcp](https://github.com/elevenlabs/elevenlabs-mcp) | Voice prototype for narrative playtests | `elevenlabs` |
| [AIDC-AI/Pixelle-MCP](https://github.com/AIDC-AI/Pixelle-MCP) | Concept art generation pipeline | `pixelle-mcp` |
| [jerhadf/linear-mcp-server](https://github.com/jerhadf/linear-mcp-server) | Sprint tracking for larger teams | `linear-mcp` |

---

## Gaps and Opportunities

Areas where MCP tooling does not yet exist or is too early for production use:

| Gap | Current State | Workaround |
|---|---|---|
| Pixel art pipeline | Only 1 Aseprite MCP with 1 star ([mine3911/MCP-Aseprite](https://github.com/mine3911/MCP-Aseprite)) | Use ComfyUI MCPs with pixel art models |
| Music generation | No Suno or Udio MCP servers | Use fal.ai MCP for some audio model access |
| Sound effects library | No Freesound API MCP | Use ElevenLabs SFX generation |
| Game analytics | No GameAnalytics or Unity Analytics MCP | Use generic database MCPs |
| Store publishing | No itch.io or Steam MCP servers | Manual submission with checklist from `game-launch` |
| Sprite sheet management | Nothing found | Manual workflow |
| Tiled map editor | Nothing found | Manual workflow |
| FMOD/Wwise middleware | Nothing found | Manual middleware configuration |

---

## Key References

| Resource | URL | Stars | What It Is |
|---|---|---|---|
| Official MCP Servers | https://github.com/modelcontextprotocol/servers | 82,025 | Reference server implementations |
| MCP Registry | https://github.com/modelcontextprotocol/registry | 6,590 | Community-driven server registry |
| MCP Inspector | https://github.com/modelcontextprotocol/inspector | 9,194 | Visual testing tool for MCP servers |
| TypeScript SDK | https://github.com/modelcontextprotocol/typescript-sdk | 11,955 | Build custom MCP servers in TypeScript |
| Python SDK | https://github.com/modelcontextprotocol/python-sdk | 22,305 | Build custom MCP servers in Python |
| Awesome MCP Servers | https://github.com/punkpeye/awesome-mcp-servers | 84,047 | Largest curated MCP server list |
