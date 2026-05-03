---
artifact_type: kickback
id: kickback-{NNN}
parent_id: {design-{NNN} | code-{NNN} | review-{NNN}}
increment_ref: inc-{NNN}
direction: architect-to-lead | coder-to-lead | reviewer-to-lead | lead-to-architect | lead-to-coder | lead-to-user
severity: blocking | clarification | proposal
status: open | resolved | abandoned
created: {YYYY-MM-DD}
resolved: {YYYY-MM-DD | null}
author: {architect | coder | reviewer | team-lead}
---

# Kickback — {Short title}

## What's Being Kicked Back

{One paragraph. Identify the artifact (parent_id) and what about it triggered
this kickback. Keep tightly scoped — one kickback per issue.}

## Why

{The reasoning. What did you observe, infer, or attempt that led to this
kickback? If a kickback's rationale fits in one sentence, it probably should
have been resolved without a kickback.}

## What's Needed

{What does the upstream party (Lead, Architect, user) need to do to resolve
this? Be specific. "Clarify the design" is not specific. "Decide whether the
session token is valid across regions or per-region only — affects the data
model in §5" is specific.}

- [ ] {Specific action needed}

## Severity Rationale

{Why is this `blocking` vs `clarification` vs `proposal`?

- **blocking:** the downstream party cannot proceed without resolution.
- **clarification:** can proceed with a specific assumption stated below, but
  resolution may invalidate work.
- **proposal:** suggesting an improvement; downstream is not blocked.}

## Working Assumption (clarification kickbacks only)

{If severity is `clarification`, state the assumption you're proceeding with
so the Lead knows what work is at risk if the assumption is wrong.}

## Resolution

{Filled in when status moves to resolved. What was decided, who decided it,
which artifacts were updated.}

- **Decision:** {what was decided}
- **Decided by:** {team-lead | user via team-lead}
- **Affected artifacts:** {discovery-{NNN}, design-{NNN}, ...}
- **Decision log entry:** {dec-{NNN} | none — a decision log entry is required
  for any architectural reversal or scope change}
