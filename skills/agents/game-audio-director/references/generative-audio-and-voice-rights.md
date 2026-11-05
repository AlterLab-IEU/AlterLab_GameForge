# Generative Audio and Voice: Rights, Consent, Disclosure (Audio Director reference)

Snapshot: November 2026. This is production guidance, not legal advice. Litigation and vendor
terms move; check the vendor's terms page and recent reporting before a cue ships, and record the
date in the provenance log. Items marked **UNVERIFIED** could not be confirmed.

---

## 1. Music generation

| Tool | Training data / legal position | Production guidance |
|---|---|---|
| **Suno** | Warner Music Group settled on 2025-11-25. **UMG and Sony are still suing** (court filings in Oct 2026 describe ongoing work toward a resolution). | Legally unsettled for shipped games. Use only as a private reference for direction; never in a build, trailer, or store page. |
| **Udio** | UMG settled in Oct 2025; Udio then disabled downloads. | No new production use. Audit older projects for Udio cues and replace them. |
| **Eleven Music** (ElevenLabs) | Trained on licensed data (Merlin and Kobalt deals); offered for commercial use. | Usable on a plan whose terms cover commercial games. Game-specific tier requirements are **UNVERIFIED**; read the current plan terms. |
| **Stable Audio 3** (Stability AI, 2026-05-20) | Trained on licensed data. Small SFX, Small and Medium are open weights under the Stability AI Community License; an Enterprise license is required above US$1M annual revenue. Large is API-only. | Usable within the license threshold. Local open-weight models keep the pipeline reproducible. |
| Other music generators | Varies | Same test: documented licensed training data, commercial output rights, no open litigation against the vendor. Otherwise ideation only. |

**What "ideation only" means in practice**: generated sketches may inform a brief to a human
composer ("this energy, this instrumentation") but are never handed over as stems to adapt, and are
never uploaded to a marketing channel.

---

## 2. SFX generation

| Tool | Notes |
|---|---|
| **ElevenLabs SFX v2** (Sept 2025) | 30 s clips, seamless loops, 48 kHz output. Good for ambience beds, textures, UI drafts. |
| **Stable Audio 3 Small SFX** | Open weights; local generation; Community License thresholds apply. |

Generated SFX follow the same gates as recorded SFX: audition in-engine at gameplay pace, check
against the material matrix, check loop points, and layer rather than use raw where precision
matters (combat hits, UI confirms). Common artifacts: smeared transients, over-smooth tails,
inconsistent room tone between variants, and phantom tonal content.

---

## 3. Voice: the 2025 SAG-AFTRA Interactive Media Agreement

Ratified 2025-07-09 with 95.04% approval, ending the 2024-2025 video game strike. As reported by
trade press and law-firm summaries:
- **Consent**: producers must obtain the performer's consent before creating or using a digital
  replica, with a "reasonably specific description" of each intended use.
- **Disclosure and usage reports**: performers who consent receive reports on how their replica was
  used, which also feed their compensation.
- **Strike suspension**: performers can suspend consent for generating new material during a strike.
- **Wages**: widely reported as a 15.17% increase on ratification plus further annual increases;
  one law-firm summary gives a different figure, so quote the union's own materials if pay matters.

**For non-signatory indies**: the agreement does not bind you, but the standard it sets is what
performers, players, and press now expect. Adopt it.

### Consent record (one per performer, stored with contracts, referenced from the log)

```
Performer: [name]                       Agent / union: [if any]
Recorded: [dates, studio]               Contract ref: [id]
Replica permitted: yes / no
Permitted uses (reasonably specific): e.g. "additional combat barks for the character Mara in
  [Game Title] and its DLC; no other characters, products, or marketing voice-over"
Prohibited: training models for other projects; use in other titles; sexual or political content
Disclosure: credits line + store page; usage report every [quarter]
Compensation: [session fee, per-line or per-use terms]
Revocation / strike suspension: [terms]
Signed: [performer, date]  [studio, date]
```

### Synthetic voice decision tree

1. **Placeholder TTS for timing and playtests** -> allowed; tag `PLACEHOLDER` in-build and in the log.
2. **Stock synthetic voice (no real person)** in the shipped game -> disclose on Steam (pre-generated
   sound) and in credits; expect player scrutiny. ARC Raiders used licensed TTS and then re-recorded
   many lines with actors after backlash (per PC Gamer and Kotaku coverage).
3. **Replica of a real performer** -> consent record above, usage reports, disclosure.
4. **Live-generated voice at runtime** (AI NPC speech) -> everything in 3, plus Steam's
   live-generated guardrails description, Microsoft Store policy 11.16 reporting if sold there,
   and EU AI Act Art. 50 duties (see section 4).
5. **Imitating a recognizable voice without consent** -> no.

---

## 4. Disclosure mapping

| Where | Audio-relevant rule |
|---|---|
| **Steam** (content survey rewritten 2026-01-16) | Pre-generated content players consume is disclosed: explicitly includes **sound**, plus marketing assets (trailer music counts). Live-generated content requires a description of guardrails. Code assistants are exempt. |
| **itch.io** | Generative-AI content must be disclosed; untagged AI content is a delisting risk. |
| **Microsoft Store / Xbox** (policy 11.16) | Live generative AI: disclose in metadata and Partner Center, keep output within policy, provide a way to report content and act on reports. Pre-generated assets are not covered. |
| **EU AI Act Art. 50** (applies from 2026-08-02) | 50(1): users must be told they are interacting with an AI system (AI NPC voices) unless obvious. 50(2): providers of generative systems mark output machine-readably (grace period to 2026-12-02 for systems already on the market). 50(4): deepfake disclosure for evidently fictional works must simply not hamper the work. |

---

## 5. Placeholder hygiene checklist (run before every milestone build)

- [ ] `grep` the log for `PLACEHOLDER` -- every entry has an owner and a replacement date
- [ ] No Suno or Udio file anywhere in the repository or the build (search by log entries and file
      metadata, not file names alone)
- [ ] Every generated cue has tool, version, plan, date checked, and human edits recorded
- [ ] Every synthetic voice line maps to a consent record or a stock-voice license
- [ ] Trailer and store-page audio checked with the same rules as in-game audio
- [ ] Disclosure text drafted from the log, reviewed by the producer
