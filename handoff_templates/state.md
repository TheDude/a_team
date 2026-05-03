---
artifact_type: team_state
team_name: {team_name}
updated: {YYYY-MM-DD HH:MM}
updated_by: team-lead
---

# Team State

> This file is the session-resumption anchor. The Team Lead reads it first at
> session start and overwrites it at every state transition. Keep it short.

## Current Increment

- **ID:** {inc-{NNN} | none}
- **Title:** {title}
- **Phase:** discovery | designing | design-review | implementing | code-review | ci-cd | blocked | done
- **Phase entered:** {YYYY-MM-DD HH:MM}

## Last Action

{One or two sentences. What was just done? Who did it? What artifact was
produced?}

## Next Action

{One or two sentences. What is the Lead about to do? Which specialist will
be invoked, with what context?}

## Open Kickbacks

{Any unresolved kickbacks blocking progress. List by ID with one-line summary.
If none, write "none".}

- {kickback-{NNN}} — {summary}

## Open Questions for User

{Anything the Lead is waiting on the user for. If none, write "none".}

- {question}

## Increment History (this session)

{Brief log of phase transitions for the active increment, most recent last.
Truncate to current increment only — older history lives in the per-increment
directory and the decision log.}

| Time              | Phase            | Note                              |
|-------------------|------------------|-----------------------------------|
| YYYY-MM-DD HH:MM  | discovery        | started                           |
