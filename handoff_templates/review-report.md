---
artifact_type: review_report
id: review-{NNN}
increment_ref: inc-{NNN}
design_ref: design-{NNN}
code_ref: code-{NNN}
status: draft | submitted
created: {YYYY-MM-DD}
updated: {YYYY-MM-DD}
author: reviewer
recommendation: sign-off | sign-off-with-followups | kickback
---

# Review Report — Increment {inc-NNN}

## 1. Recommendation

{One sentence summarizing the recommendation in `recommendation` frontmatter.
- `sign-off`: ready for CI/CD; no blocking or should-fix issues remain.
- `sign-off-with-followups`: blocking issues are clear; should-fix items can be
  filed as follow-up increments rather than blocking this one. Lead decides.
- `kickback`: blocking issues exist; the Coder must address before progressing.}

## 2. Summary

{Short paragraph. What was reviewed, against what, and the headline finding.}

- **Reviewed against:** design-{NNN}, inc-{NNN}, discovery-{NNN}
- **Diff size:** {N files, M lines added, K lines removed}
- **Coverage observed:** {from coder report}

## 3. Issues by Severity

> Severity is forced. Every issue must be one of: blocking, should-fix, nit.
> Blocking issues prevent sign-off. Should-fix is a Lead-judgment call.
> Nits are not grounds for kickback.

### Blocking

{Issues that prevent acceptance. Security vulnerabilities, correctness bugs,
acceptance criteria not met, undeclared deviations from design, tests that
don't actually verify what they claim to.}

- **B-1 — {title}**
  - **Where:** {file:line or component}
  - **Issue:** {what is wrong}
  - **Why blocking:** {tie to a category — security / correctness / AC unmet / design noncompliance / test invalidity}
  - **Suggested fix:** {if obvious; otherwise leave to Coder}

### Should-fix

{Issues that should be fixed but the Lead may choose to defer. Maintainability
problems, perf concerns under non-critical paths, missing edge-case handling
for non-acceptance scenarios.}

- **S-1 — {title}** — {one-line description and where}

### Nit

{Style, naming, minor refactors. Not actionable as kickback. Listed for the
record. Reviewers should be sparing here — every nit dilutes signal.}

- **N-1 — {title}** — {one-line description and where}

## 4. Acceptance Criteria Verification

| AC ref | Met? | Evidence (test ID / file) | Notes |
|--------|------|---------------------------|-------|
| AC-1   | yes  | IT-1 passes               |       |
| AC-2   | no   | IT-2 absent               | blocking issue B-2 |

## 5. Design Compliance

{Was the design package implemented as specified?}

- **Component boundaries respected:** {yes / no — if no, see B-{N}}
- **Public interfaces match:** {yes / no}
- **Data models / invariants honored:** {yes / no}
- **Constraints satisfied (perf, security, dependency):** {yes / no}
- **Declared deviations:** {accepted / disputed — if disputed, file as blocking}

## 6. Common-Pitfalls Checklist

{Reviewer's structured pass. Reference patterns from the project's failure-mode
taxonomy. Mark each: `ok` | `n/a` | `issue-{ref}`.}

- **Hallucinated APIs (calls to functions/libraries that don't exist):** ok
- **Tests that test the wrong thing (asserting on mock setup, not behavior):** ok
- **Tests written to pass rather than to verify:** ok
- **Silent error suppression:** ok
- **Off-by-one / boundary conditions:** ok
- **Resource leaks (files, connections, goroutines, timers):** ok
- **Concurrency hazards (shared state, race conditions, ordering):** ok
- **Input validation at trust boundaries:** ok
- **Secret / credential handling:** ok
- **Authn / authz checks where required:** ok
- **Performance traps (N+1, unbounded loops, accidental quadratics):** ok
- **Logging / observability appropriate:** ok
- **Failure modes documented:** ok

## 7. Notes / Suggestions

{Optional. Forward-looking notes the Lead may want to feed into discovery or
future increments. Not actionable on this increment.}
