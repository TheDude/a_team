# a_team — Hermes Engineering Team Skill

A four-role autonomous software engineering team designed to run on
[Hermes](https://nousresearch.com/) (Nous Research). The team consists of a
Team Lead, an Architect, a Coder, and a Reviewer; the Lead orchestrates,
specialists are invoked with curated context, and every handoff is a
structured artifact.

This repository is the **skill** — the prompts, templates, and layout spec.
It is not a team workspace itself. To create a team workspace, open a Team
Lead session and point it at this skill (see "Quick start" below). The Lead
handles bootstrap; there is no separate script.

## Repository layout

```
a_team/
├── README.md                # This file.
├── spec.md                  # Canonical spec — read this first.
├── workspace-spec.md        # Team workspace layout reference.
├── prompts/                 # System prompts for the four roles.
│   ├── team-lead.md         # Includes the bootstrap + session-resumption procedure.
│   ├── architect.md
│   ├── coder.md
│   └── reviewer.md
└── handoff_templates/       # Markdown + YAML-frontmatter templates.
    ├── discovery-document.md
    ├── increment.md
    ├── design-package.md
    ├── coder-report.md
    ├── review-report.md
    ├── decision-log-entry.md
    ├── kickback.md
    └── state.md
```

## Quick start

To create a new team workspace:

1. Open a Team Lead session in your harness (Hermes, Claude Agent SDK,
   LangGraph, etc.) using `prompts/team-lead.md` as the system prompt.
2. Tell the Lead the team name, the parent directory where the workspace
   should live, and the path to this skill (so the Lead knows where to
   copy `handoff_templates/` from).
3. The Lead validates inputs, creates the directory tree, copies the
   templates, initializes `state.md` / `README.md` / `.gitignore`, runs
   `git init`, and announces completion before transitioning into discovery.

To resume an existing team, point the Lead at the workspace directory.
The Lead will read `state.md` first and announce the current state before
taking any action.

## Conceptual flow

1. The Lead conducts discovery with the user, producing a Discovery Document
   and a roadmap of increments.
2. The Lead picks the next increment, drafts the Increment artifact.
3. The Lead invokes the Architect with the Discovery Document and the
   Increment; the Architect returns a Design Package.
4. The Lead verifies the Design Package against the Discovery Document.
5. The Lead invokes the Coder with the Design Package; the Coder writes
   tests, then code, then submits a Coder Report.
6. The Lead invokes the Reviewer with the Design, Report, and diff; the
   Reviewer returns a Review Report. **Review is unconditional.**
7. The Lead resolves any blocking issues (via kickback to the Coder),
   then kicks off CI/CD.
8. On green CI/CD, the increment is marked `done`.

See `spec.md` for the full design rationale, including what the team is and
isn't trying to do, the phase machine, kickback protocol, and the open
questions that this version doesn't pin down (eval harness, sandboxed views,
parallel increments).

## Status

Working draft, version 1. Expect to iterate on the role prompts and
templates as you observe real failure modes. Treat this skill the way you
treat any other component: write evals, replay handoffs, fold lessons back
into the prompts.
