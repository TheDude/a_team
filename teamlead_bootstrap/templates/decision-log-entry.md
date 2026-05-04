---
artifact_type: decision_log_entry
id: dec-{NNN}
title: {Short decision title}
status: proposed | accepted | superseded | reversed
created: {YYYY-MM-DD}
decided: {YYYY-MM-DD}
author: {team-lead | architect | coder | reviewer}
related_increments: [inc-{NNN}, ...]
supersedes: {dec-{NNN} | null}
---

# Decision — {Title}

## Context

{Two or three sentences. What's going on that requires a decision? What
constraints, assumptions, or recent events are relevant?}

## Decision

{The decision itself, stated declaratively. Not "we considered using X" — say
"we are using X."}

## Alternatives Considered

{Each alternative gets a name and a one-line "why not." If you can't articulate
why an alternative was rejected, you don't yet have a decision — you have a
preference. Go back and think harder.}

- **{Alternative 1}** — {why not}
- **{Alternative 2}** — {why not}

## Consequences

{What does this lock in? What becomes harder later? What downstream choices
does this constrain?}

- **Positive:** {what this unlocks or simplifies}
- **Negative / trade-offs:** {what this costs}
- **Reversibility:** {one-way door / easily reversed / reversible with cost}

## Triggers for Reversal

{Conditions under which this decision should be revisited. If you can't think
of any, that's fine — but if you can, write them down so a future Lead doesn't
have to re-derive them.}

- {Trigger 1}
