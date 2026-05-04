---
artifact_type: increment
id: inc-{NNN}
title: {Short increment title}
status: not-started | discovery | designing | design-review | implementing | code-review | ci-cd | blocked | done
priority: P0 | P1 | P2
created: {YYYY-MM-DD}
updated: {YYYY-MM-DD}
author: team-lead
discovery_ref: discovery-{NNN}
depends_on: [inc-{NNN}, ...]
---

# Increment {inc-NNN} — {Title}

## Goal

{One or two sentences. What does this increment accomplish? State the user-visible
outcome, not the implementation.}

## Acceptance Criteria

{Specific, testable conditions. The Architect derives integration tests from
these. The Reviewer verifies each one is met.}

- [ ] {Criterion 1 — phrase as something an outside observer can verify}
- [ ] {Criterion 2}
- [ ] {Criterion 3}

## Traceability

{Map this increment back to the discovery document.}

- **User goals addressed:** {goal references from discovery §2}
- **Use cases covered:** {UC-1, UC-3, ...}
- **Non-goals respected:** {which non-goals from discovery §4 explicitly apply}

## Scope Estimate

- **Size:** XS | S | M | L | XL
- **Notes:** {if L or XL, justify why this can't be split further}

> **Splitting heuristic:** if the increment cannot be designed, built, reviewed,
> and integrated in a single pass without partial-state risk to the rest of the
> system, split it. XL is a smell.

## Dependencies

- **Prior increments:** {which increments must be done; what specifically this
  one inherits from them}
- **External:** {libraries, services, environments this increment requires}

## Out of Scope

{Things adjacent to this increment that are intentionally deferred. Prevents the
Architect or Coder from over-reaching.}

- {Out-of-scope item 1}

## Open Questions

- [ ] {Anything the Lead noted while drafting that needs to be resolved during
  design or before kickoff}
