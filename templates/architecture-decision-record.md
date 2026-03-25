# Architecture Decision Record

> **ADR Number:** [Sequential number, e.g., ADR-007]
> **Title:** [Short descriptive title, e.g., "Use ECS for NPC Crowd Simulation"]
> **Date:** [Date of decision]
> **Author:** [Name / role]
> **Status:** [Proposed / Accepted / Deprecated / Superseded by ADR-XXX]

---

## Context

[Describe the situation that led to this decision. What problem are we solving? What constraints exist? What forces are in tension?]

[Include relevant technical context: engine version, target platforms, team expertise, performance requirements, timeline constraints.]

[Reference any related ADRs, GDD sections, or external resources that informed this decision.]

---

## Decision

[State the decision clearly and concisely.]

> We will [decision]. Specifically:

1. [Specific implementation detail]
2. [Specific implementation detail]
3. [Specific implementation detail]

### Scope

- **Applies to:** [Which systems, modules, or features this decision covers]
- **Does NOT apply to:** [Explicitly state what is excluded]

---

## Consequences

### Positive

- [Benefit 1 — e.g., "Reduces draw calls by 40% in crowd scenes"]
- [Benefit 2 — e.g., "Enables deterministic replay for networking"]
- [Benefit 3 — e.g., "Aligns with engine vendor's recommended architecture"]

### Negative

- [Drawback 1 — e.g., "Increases learning curve for team members unfamiliar with ECS"]
- [Drawback 2 — e.g., "Makes debugging more difficult due to data-oriented layout"]
- [Drawback 3 — e.g., "Locks us into a specific engine version range"]

### Neutral / Trade-offs

- [Trade-off 1 — e.g., "More boilerplate code but clearer data flow"]
- [Trade-off 2 — e.g., "Slower iteration speed but better runtime performance"]

---

## Alternatives Considered

### Alternative 1: [Name]

- **Description:** [What this alternative would look like]
- **Pros:** [Benefits]
- **Cons:** [Drawbacks]
- **Why rejected:** [Specific reason for rejection]

### Alternative 2: [Name]

- **Description:** [What this alternative would look like]
- **Pros:** [Benefits]
- **Cons:** [Drawbacks]
- **Why rejected:** [Specific reason for rejection]

### Alternative 3: [Name]

- **Description:** [What this alternative would look like]
- **Pros:** [Benefits]
- **Cons:** [Drawbacks]
- **Why rejected:** [Specific reason for rejection]

---

## Pillar Alignment

[How does this decision align with the project's design pillars?]

| Pillar | Alignment | Notes |
|--------|-----------|-------|
| [Pillar 1 from game concept] | [Supports / Neutral / Conflicts] | [Explanation] |
| [Pillar 2 from game concept] | [Supports / Neutral / Conflicts] | [Explanation] |
| [Pillar 3 from game concept] | [Supports / Neutral / Conflicts] | [Explanation] |

---

## Implementation Notes

[Any practical guidance for implementing this decision.]

- **Migration path:** [If replacing an existing approach, how to transition]
- **Key files/modules affected:** [List of files or systems that will change]
- **Estimated effort:** [Hours/days/sprints]
- **Validation:** [How to verify the decision is working as expected]

---

## Review

| Reviewer | Role | Approval | Date |
|----------|------|----------|------|
| [Name] | [Role] | [ ] Approved / [ ] Concerns | [Date] |
| [Name] | [Role] | [ ] Approved / [ ] Concerns | [Date] |

### Concerns Raised
- [Concern 1 and resolution]
- [Concern 2 and resolution]

---

## References

- [Link to related ADR, e.g., "ADR-003: Rendering Pipeline Selection"]
- [Link to GDD section]
- [Link to external documentation or benchmark data]
- [Link to prototype or proof-of-concept branch]
