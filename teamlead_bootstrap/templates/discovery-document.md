---
artifact_type: discovery_document
id: discovery-{NNN}
version: {N}
status: draft | active | superseded
created: {YYYY-MM-DD}
updated: {YYYY-MM-DD}
author: team-lead
supersedes: {discovery-{NNN} | null}
---

# Discovery Document — {Project / Initiative Name}

## 1. Problem Statement

{One to three paragraphs. What problem is this work solving and for whom? What
is the current pain or gap? Avoid solutioning here — describe the problem.}

## 2. User Goals

{Bulleted list of what the user wants to achieve, ordered roughly by priority.
Each item should be a goal in user terms, not a feature.}

- {Goal 1}
- {Goal 2}

## 3. Use Cases

{Concrete usage scenarios. Each use case has a priority (P0 = must, P1 = should,
P2 = nice). The Architect derives integration test scenarios from these, so be
specific enough that an outside party could write a test against the description.}

### UC-1 — {Short name} (P0 | P1 | P2)
- **Actor:** {who is doing this}
- **Trigger:** {what kicks off this scenario}
- **Flow:** {step-by-step in plain language}
- **Outcome:** {what success looks like}
- **Edge cases / failure modes:** {what can go wrong; what should happen}

### UC-2 — ...

## 4. Non-Goals

{Explicit list of things this work will NOT do. Non-goals are at least as
important as goals — they prevent scope creep and protect later increments
from being judged against expectations they were never meant to meet.}

- {Non-goal 1}
- {Non-goal 2}

## 5. Constraints

{Anything outside the team's discretion. Examples: target platforms, performance
budgets, security/compliance requirements, languages or frameworks the user
mandates or forbids, integration points with existing systems, deadlines.}

- **Stack constraints:** {if any — language, runtime, framework forbidden or required}
- **Performance:** {budgets, SLOs}
- **Security / compliance:** {requirements, regulations}
- **Operational:** {deployment target, environment, dependencies}
- **Other:** {anything else}

## 6. Success Criteria

{How we know the project is done. Measurable, observable outcomes — not
"the code is written" but "the user can do X in under Y seconds with Z reliability".}

- {Criterion 1}
- {Criterion 2}

## 7. Open Questions

{Anything the Lead is uncertain about and needs the user to resolve. The Lead
reopens discovery against this section when an increment surfaces a question
that can't be answered from existing artifacts.}

- [ ] {Question 1}
- [ ] {Question 2}

## 8. Roadmap

{Ordered list of increments. Each increment is a unit of work that produces
testable, verifiable code. Splitting is correct when each increment can be
designed, built, reviewed, and integrated independently.}

| ID       | Title            | Priority | Depends on   | Status      |
|----------|------------------|----------|--------------|-------------|
| inc-001  | {Title}          | P0       | —            | not-started |
| inc-002  | {Title}          | P0       | inc-001      | not-started |
| inc-003  | {Title}          | P1       | inc-001      | not-started |

## 9. Revision History

| Version | Date         | Change                                      |
|---------|--------------|---------------------------------------------|
| 1       | {YYYY-MM-DD} | Initial draft                               |
