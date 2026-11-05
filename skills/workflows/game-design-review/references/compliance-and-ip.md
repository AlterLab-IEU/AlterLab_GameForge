# Compliance and IP Reference for Design Reviews

Read before scoring dimensions 11 (originality and IP) and 12 (AI content and disclosure). Facts are
as of 2026-11-05; quote the dates in findings and tell the team to re-check before submission.
Findings based on this file are flags for the team, not legal advice.

## Design feature -> obligations

| Design feature | Steam (rules of 2026-01-16) | itch.io | Microsoft Store 11.16 | EU AI Act Art. 50 (since 2026-08-02) | Other |
|---|---|---|---|---|---|
| Code written with coding agents | Exempt (efficiency tools) | No disclosure found for code | Not covered | Source code excluded from 50(2) | Review security-sensitive code (see `docs/coding-standards.md`) |
| Pre-generated art, audio, text in the build | Disclose as pre-generated | Disclose; feeds the "no AI" filter (search since 2026-11-03) | Not covered (11.16 is live AI only) | Marking duties fall on the generator's provider; deepfakes 50(4) | Document human contribution for copyright |
| AI-assisted localization | Disclosable content | Disclose | Not covered | -- | Human review for humour and culture |
| AI store page or marketing assets | Disclosable content | Disclose | -- | -- | Do not market AI content as hand-made |
| Runtime generation (LLM NPCs, generated quests or images) | Live-generated: describe guardrails; no live-generated adult sexual content | Disclose | Disclose in metadata, keep output within policy, provide in-game reporting | 50(1): disclose AI interaction unless obvious; 50(2) machine-readable marking for generative output (grace to 2026-12-02 only for systems already on the market) | Cost per player-hour; prompt-injection hardening (shipped AI chat NPCs have been exploited by players) |
| Synthetic or cloned voice | Disclose | Disclose | Live only | 50(4) if it imitates a real person | SAG-AFTRA 2025 Interactive Media Agreement: informed consent and disclosure for digital replicas |
| In-game purchases | -- | -- | -- | -- | European Accessibility Act: e-commerce, including in-game purchase flows, is in scope (since 2025-06-28) |
| Player chat or voice comms | -- | -- | -- | -- | EAA electronic-communications scope is the basis for arguments that in-game chat is covered |
| Console release | -- | -- | -- | -- | EAA covers consoles as products; games themselves are not named |
| In-app game maker or player-shared playable content on iOS | -- | -- | -- | -- | Apple blocked updates to vibe-coding apps under guideline 2.5.2 (executing downloaded code) in March 2026 |
| Generative features on Android | -- | -- | -- | -- | Google Play AI-Generated Content policy: no offensive or deceptive output; no labelling mandate found |

Other storefronts: no public AI-specific store rule was found for PlayStation, Nintendo or the Epic
Games Store as of November 2026. Absence of a rule is not permission; follow general content policy.

EAA exemption: microenterprises (fewer than 10 staff and at most EUR 2M turnover) are exempt for
services. Many indies qualify; say so in the finding rather than assuming.

EU AI Act fines reach EUR 15M or 3% of worldwide turnover. Article 50 is not retroactive for media
generated before 2026-08-02.

## Copyright and ownership

- US Copyright Office report Part 2 (2025-01-29): prompts alone do not make a work protectable;
  human selection, arrangement and modification can be.
- US Supreme Court denied certiorari in *Thaler* (2026-03-02): human authorship remains required.
- Review implication: a design whose key art, characters or music are purely generated may not be
  protectable, which matters for trademarks, merch, sequels and clone disputes. Flag it as Major
  when the IP is central to the business plan.

## Asset-tool license flags

| Tool or situation | Flag |
|---|---|
| Hunyuan3D 2.1 | License does not apply in the EU, UK or South Korea, including outputs. Critical for a worldwide release. |
| TRELLIS.2 | MIT license. No license flag; hero meshes still need manual retopology. |
| Suno, Udio | UMG and Sony litigation against Suno unresolved; Udio disabled downloads after settling with UMG. Treat output as unsettled for shipped games: Major. |
| Licensed-data audio models (e.g. Stable Audio 3, Eleven Music) | Check the tier and revenue thresholds of the license; record it. |
| Unknown or missing license | Major until recorded. |

## Originality and IP red flags

| Red flag in the design | Severity | Why |
|---|---|---|
| Pitch only works as "[existing game] but [small change]" | Critical | Clone risk; Claude Code (since late Oct 2026) declines recreations of specific existing games "even if renamed" |
| Names, characters, logos, level layouts or UI trade dress from an existing game | Critical | Direct infringement risk |
| Assets exported, ripped or decompiled from other games | Critical | In October 2026 Activision issued DMCA takedowns against AI-built browser ports that used assets exported from the original games |
| "Spiritual successor" with close mechanical and visual mimicry | Major | Trade-dress and clone disputes; store reviewers and players react badly |
| Fan game of a living IP without permission | Critical for commercial release | Takedown risk regardless of price |
| Genre conventions (roguelike runs, deckbuilding, metroidvania gating) | None | Mechanics in a genre are shared vocabulary |

Recommended reframe for clone-shaped designs: name the mechanic or feeling the designer loves,
keep it as a genre convention, and find the design's own pillar and twist. Route to
`/gameforge:game-brainstorm` or `/gameforge:game-gdd-author` Step 1.

## Market and reputation context (use sparingly, cite)

- GDC 2026 State of the Game Industry: 52% of respondents say generative AI is harming the
  industry; 36% use it at work.
- Aftermath reported on 2026-11-01 that new itch.io pages per day had doubled in two months,
  almost all AI-made, without growth in downloads or purchases; itch.io then deleted "a couple
  terabytes" of AI uploads and extended its "no AI" filter to search (2026-11-03).
- In December 2025 the Indie Game Awards rescinded awards to *Clair Obscur: Expedition 33* over
  generative-AI placeholder textures that had already been patched out.

Use these to explain why undisclosed or untracked AI content is a business risk, not to moralize
about the team's choices.
