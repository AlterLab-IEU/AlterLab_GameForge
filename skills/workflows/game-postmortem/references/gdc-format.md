# Long-Form (GDC-Style) Post-Mortem and Publishing Checklist

Read when the audience is a team blog, a public post-mortem or a talk, or when the user wants the
classic "What Went Right / What Went Wrong" document. Write it honestly enough that it would be
worth publishing, then decide what to redact.

## Format

```markdown
# [Game] Post-Mortem
**Developer:** [studio or person] | **Platforms:** [...] | **Released:** [date] or canceled [date]
**Team:** [size and roles] | **Development time:** [months] | **Engine / stack:** [...]
**Budget (optional):** [...] | **Tools:** [engine, key tools, coding agents and asset tools used]

## The game as designed vs as shipped
**Pitch as designed:** [from the first GDD]
**Pitch as shipped:** [what it actually became]
[If these differ, that delta is the story of this post-mortem. Explain it.]

## Timeline
| Phase | Planned | Actual | Delta | Key event |
|---|---|---|---|---|
| Concept | | | | |
| Pre-production | | | | |
| Production | | | | |
| Alpha | | | | |
| Beta | | | | |
| Launch | | | | |

## What went right
### 1. [Title]
[A full paragraph: what went right, why, what conditions enabled it, and what another team could
copy. Specific enough to replicate.]
### 2. ... ### 5.

## What went wrong
### 1. [Title]
[A full paragraph: what went wrong, the root cause in a system or decision, the impact, when the
team recognized it, and what should have been done differently.]
### 2. ... ### 5.

## How we used AI
[Factual and specific. Which agents and asset tools, for which kinds of work, in which phases.
What they did well and poorly, with numbers from the AI ledger: agent share of tasks, verify
cost, defects traced to agent code, what reached players. What was hand-made and why.
Must match the store's AI disclosure and the credits.]

## The cut list
[Every significant feature cut, when, why, and whether it was the right call in hindsight.]

## The one thing
[One sentence, then two or three sentences on why it is the lesson and how it changes the next
project.]

## Key learnings
| Lesson | Evidence from this project | Applies to |
|---|---|---|

## Numbers (optional)
[Sales, wishlists, review score, playtime, refunds -- only what the team is comfortable sharing
and allowed to share.]
```

Rules for the long form:
- Five right and five wrong is the tradition; fewer, well-evidenced items beat padding.
- Each "wrong" item traces to a decision or system, never to a named person.
- Every number has a source in the project records.
- "How we used AI" is a section of fact, not of persuasion. Neither apologize for nor sell it.

## Publishing checklist

Before anything leaves the team:

- [ ] Every person named or clearly identifiable has read and approved their mention.
- [ ] Publisher, platform holder or client agreements (NDAs, embargoed data, sales figures) checked.
- [ ] No security-sensitive detail: server architecture weaknesses, unpatched exploits,
      credentials, anti-cheat internals.
- [ ] Statements about AI use match the Steam content survey answers (rules of 2026-01-16: shipped
      AI content including localization and marketing; code assistants exempt), the itch.io
      generative-AI disclosure, and the in-game credits.
- [ ] Claims about tools and vendors are factual and dated ("as of [date], [tool] could not...").
- [ ] Numbers cross-checked against the internal version; rounding stated.
- [ ] Blame language removed; criticism aimed at decisions and systems.
- [ ] Screenshots and footage are of the team's own game and assets.
- [ ] A redaction list is kept with the internal version, so future readers know what the public
      version omits.

## Publish assessment block

Add to the internal version:

```
PUBLISH ASSESSMENT
Audience:        internal only / team blog / public post-mortem / conference talk
Redactions:      [what is removed from the public version and why]
Approvals:       [who signed off]
Value to others: [what another team would learn from reading this]
AI statement consistent with store disclosure and credits: yes / no -- [details]
```
