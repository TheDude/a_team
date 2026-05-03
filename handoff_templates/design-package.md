---
artifact_type: design_package
id: design-{NNN}
increment_ref: inc-{NNN}
discovery_ref: discovery-{NNN}
version: {N}
status: draft | accepted | superseded
created: {YYYY-MM-DD}
updated: {YYYY-MM-DD}
author: architect
---

# Design Package — Increment {inc-NNN}

## 1. Summary

{One paragraph. What is being built and why. The Coder reads this first to
orient; do not assume they have the full discovery document loaded.}

## 2. Stack Decisions

{First-touch increments fix the stack; subsequent increments inherit unless
explicitly escalated.}

- **Language / runtime:** {e.g., Python 3.12, Node 20, Go 1.22}
- **Framework(s):** {e.g., FastAPI, Express}
- **Persistence:** {if applicable}
- **Build / test tooling:** {pytest, jest, etc.}
- **Inherited from:** {design-{NNN} | none — this is a first-touch increment}
- **Justification:** {only required for first-touch or for escalations}

## 3. Component Boundaries

{What modules / components / services are being added or modified. Each gets a
name and a one-line responsibility statement. The Coder is not allowed to
introduce new components without a kickback.}

| Component        | Responsibility                                                  | New / Modified |
|------------------|-----------------------------------------------------------------|----------------|
| {name}           | {one-line statement}                                            | new            |
| {name}           | {one-line statement}                                            | modified       |

## 4. Public Interfaces

{For each new or modified public surface (function, class, endpoint, message
schema), specify the contract. The Coder is bound to these signatures.}

### {Component}.{Surface}

- **Signature:** {`fn(args) -> return_type` or `POST /path -> 200 application/json {schema}`}
- **Preconditions:** {what must be true before invocation}
- **Postconditions:** {what is guaranteed after success}
- **Error cases:** {what kinds of failure can occur and how they're surfaced —
  exceptions, error codes, return values}

## 5. Data Models

{Schemas, entities, key value-objects. Include invariants — properties that
must always hold — separately from structure.}

### {ModelName}

```
{type definition / schema}
```

- **Invariants:** {bullet list of properties that must always hold}
- **Lifecycle:** {how instances are created, mutated, destroyed}

## 6. Integration Points

{How this increment connects to existing code. Be specific about which existing
modules are touched and what the contact surface is.}

- **Consumes:** {what this increment depends on from the existing codebase}
- **Produces:** {what existing code will start consuming from this increment}
- **Migration / compatibility notes:** {if applicable}

## 7. Acceptance Criteria (from increment)

{Restate the acceptance criteria from the increment. The Reviewer verifies
each is met.}

- [ ] {AC-1, copied from increment}

## 8. Integration Test Scenarios

{High-level scenarios derived from the use cases, written so the Coder can
implement them. Each scenario references the use case it exercises.}

### IT-1 — {Scenario name} (covers UC-{N})
- **Setup:** {state required before the scenario}
- **Steps:** {what the test does}
- **Assertions:** {what must be true after}

### IT-2 — ...

## 9. Constraints (architectural)

{Performance, security, dependency, or compatibility constraints that affect
implementation choices. The Coder must comply; the Reviewer verifies.}

- **Performance:** {budgets specific to this increment}
- **Security:** {auth, validation, secret handling, threat-model items}
- **Dependencies:** {libraries the Coder must / must-not use}
- **Concurrency / consistency model:** {if applicable}

## 10. Non-Goals (architectural)

{Things adjacent to this design that are intentionally not addressed. Often
narrower than the increment-level non-goals — those are about user value,
these are about architectural scope.}

- {Item}

## 11. Traceability Matrix

| Requirement / UC ref | Component / interface that satisfies it | Acceptance criterion |
|----------------------|------------------------------------------|----------------------|
| UC-1                 | {component.surface}                      | AC-1                 |

## 12. Open Questions

{Items the Architect could not resolve from the discovery document or prior
artifacts. Each open question must be resolved before this design package
moves to `accepted`. Resolve via Lead, who may amend discovery or escalate
to the user.}

- [ ] {Question 1 — what's needed, who can answer}

## 13. Revision History

| Version | Date         | Change                                      |
|---------|--------------|---------------------------------------------|
| 1       | {YYYY-MM-DD} | Initial draft                               |
