---
artifact_type: coder_report
id: code-{NNN}
increment_ref: inc-{NNN}
design_ref: design-{NNN}
status: draft | submitted | revised
created: {YYYY-MM-DD}
updated: {YYYY-MM-DD}
author: coder
outcome: success | partial | blocked
---

# Coder Report — Increment {inc-NNN}

## 1. Outcome

{One sentence: did the implementation reach a green test suite, partially
complete, or hit a blocker. Match the `outcome` field in frontmatter.}

## 2. Test Plan (as executed)

{The plan you wrote before coding, plus the execution result. Tests were
written first; deviations from the plan are noted in §4.}

### Unit tests
| ID    | Description                          | Result    | Notes |
|-------|--------------------------------------|-----------|-------|
| UT-01 | {what's being tested}                | pass/fail | {if relevant} |

### Integration tests (from design package)
| ID    | Description                          | Result    | Notes |
|-------|--------------------------------------|-----------|-------|
| IT-1  | {scenario from design §8}            | pass/fail | {if relevant} |

### Coverage / overall
- **Unit:** {N passed / M total, K skipped}
- **Integration:** {N passed / M total, K skipped}
- **Other (lint, type, build):** {summary}

## 3. Implementation Plan (as executed)

{The task breakdown you used. Order of operations. Helps the Reviewer trace
the change history. Brief — bullet points.}

1. {step}
2. {step}

## 4. Deviations from Design Package

{Critical. Anything the implementation does differently from the design package
must be listed here with a justification. The Reviewer treats undeclared
deviations as defects.}

| Deviation                            | Justification                              | Risk |
|--------------------------------------|--------------------------------------------|------|
| {what differs from the design}       | {why — was it forced, was it preferable}   | low/med/high |

> If this section is non-empty and any item is `med` or `high` risk, the Lead
> may want a Reviewer pass on the deviation specifically before sign-off.

## 5. Known Limitations

{Things the implementation does NOT do that a reader might reasonably expect
it to do. Includes deferred work, partial behaviors, and known edge cases not
yet handled. Each should map to either an acceptance criterion (which means
the increment is partial), a follow-up increment, or an explicit out-of-scope
item.}

- {Limitation 1 — disposition}

## 6. Design Issues Encountered

{If TDD or implementation surfaced a design problem (awkward tests, contracts
that don't compose, data model wrong, integration point underspecified),
describe it here. If the issue is severe enough to require a kickback to the
Architect, file a kickback artifact and reference it.}

- {Issue 1} — kickback: {kickback-{NNN} | none, reason}

## 7. Files Changed

{Summary of what was added / modified / deleted. Reviewer reads the diff
itself; this section is for navigation, not full enumeration.}

- **Added:** {files}
- **Modified:** {files}
- **Removed:** {files}

## 8. How to Run

{Short. Commands the Reviewer (or the Lead, or a future maintainer) needs to
exercise the code.}

```
{install / setup}
{run tests}
{run the thing, if applicable}
```

## 9. Notes for Reviewer

{Optional. Anything you want the Reviewer to look at first or be aware of.
Keep it short — long notes here often signal the Coder is asking the Reviewer
to forgive something they should have fixed.}
