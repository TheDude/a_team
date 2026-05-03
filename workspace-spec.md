# Workspace Specification

This document defines the canonical layout of a team workspace. The Team Lead
treats this layout literally; specialists rely on it being stable. Improvising
file paths breaks session resumption.

## Directory tree

```
<team_name>/
├── README.md                    # Orientation document. Rare changes.
├── state.md                     # Session-resumption anchor. Frequent changes.
├── handoff_templates/           # Read-only canonical templates (copied at bootstrap).
│   ├── discovery-document.md
│   ├── increment.md
│   ├── design-package.md
│   ├── coder-report.md
│   ├── review-report.md
│   ├── decision-log-entry.md
│   ├── kickback.md
│   └── state.md
├── discovery/                   # Discovery documents.
│   ├── discovery-001.md
│   └── discovery-002.md         # Subsequent versions if discovery is reopened.
├── increments/                  # One subdirectory per increment.
│   ├── inc-001/
│   │   ├── increment.md
│   │   ├── design-001.md
│   │   ├── code-001.md
│   │   ├── review-001.md
│   │   └── kickbacks/
│   │       └── kickback-001.md
│   ├── inc-002/
│   └── ...
├── decisions/                   # Decision log entries, one file each.
│   ├── dec-001.md
│   └── dec-002.md
└── workspace/                   # Source tree. Coder works here.
    ├── src/
    ├── tests/
    ├── build/                   # Build artifacts. Gitignored.
    └── ...
```

## File roles

### `README.md`
Orientation document for the team workspace. Describes the project, the team,
the layout, and conventions. Rarely changes. Different from the skill's own
top-level README — this one lives inside the team workspace.

### `state.md`
The session-resumption anchor. The Team Lead reads this first at session start
and overwrites it at every phase transition. Short — current increment, current
phase, last action, next planned action, open kickbacks, open user questions.
Without this file, a new session has to reconstruct state by reading every
artifact in the workspace, which is slow and error-prone.

### `handoff_templates/`
Read-only canonical templates copied from the skill at bootstrap. The Lead and
specialists reference these but never modify them in place. If a template
needs to evolve, that's a change to the skill itself, propagated to teams via
re-bootstrap or by hand.

### `discovery/`
Discovery documents. There is usually one (`discovery-001.md`), but if
discovery is reopened and the document is materially rewritten, the new
version supersedes the old via the `supersedes` frontmatter field. Both are
kept on disk for audit; only the latest is `active`.

### `increments/`
One subdirectory per increment. The directory name is the increment ID
(`inc-001`, `inc-002`, ...). Inside each directory:

- `increment.md` — the increment artifact (one per directory).
- `design-{NNN}.md` — design package(s). Usually one, occasionally more if
  revised; `version` in frontmatter increments and `status: superseded` on
  prior versions.
- `code-{NNN}.md` — coder report(s).
- `review-{NNN}.md` — review report(s).
- `kickbacks/` — directory of kickback artifacts filed during this increment.

### `decisions/`
One file per decision log entry. Decision log entries are written for any
architectural reversal, scope change, or non-trivial decision that future
increments need to be aware of. Cross-referenced from `related_increments` in
frontmatter.

### `workspace/`
The actual source tree. The Coder works here. Build artifacts go in
`workspace/build/` or wherever the project's tooling places them, and
`workspace/.gitignore` excludes them. The Coder may create whatever
subdirectory structure makes sense for the project — this is the one part
of the workspace where the team has discretion.

## Conventions

### IDs

- Discovery documents: `discovery-{NNN}` (zero-padded to three digits).
- Increments: `inc-{NNN}`.
- Design packages: `design-{NNN}`. Numbering follows the increment number
  for the first design of an increment (`design-001` for `inc-001`); revised
  designs increment their `version` field rather than getting new IDs.
- Coder reports: `code-{NNN}`.
- Review reports: `review-{NNN}`.
- Decision log entries: `dec-{NNN}`. Globally numbered, not per-increment.
- Kickbacks: `kickback-{NNN}`. Globally numbered.

IDs are stable. Renaming an artifact is forbidden — supersede it instead via
frontmatter.

### Cross-references

Artifacts reference each other by **ID**, not path. The mapping from ID to
path is deterministic (this spec). That way, artifacts don't break when the
layout evolves; they only break if the spec changes, and the spec is the one
place we update.

Inside an artifact's body, write `inc-001`, not `increments/inc-001/increment.md`.
The Lead and specialists know the mapping.

### Build artifacts and gitignore

- `workspace/` is git-tracked.
- `workspace/build/`, `workspace/dist/`, `node_modules/`, `__pycache__/`,
  language-specific caches, and editor metadata are gitignored.
- Project-management artifacts (everything outside `workspace/`) are also
  git-tracked. The full project history — discovery, designs, reviews,
  decisions — is part of the deliverable.

### Naming conflicts

If a user attempts to bootstrap a team with a name that already exists, the
bootstrap script refuses. Silent overwriting of project state is the worst
outcome here. The user must be explicit: choose a different name, or
explicitly delete the prior workspace first.

### Sandboxing

The Lead is trusted to curate context for specialists; specialists are
trusted not to read outside their bundle. With Hermes' file-access tools, all
roles can technically read the entire workspace. The discipline is enforced
by prompt and by review of behavior, not by filesystem permissions.

If specialists are observed reading too broadly and it affects quality,
escalate to a sandboxed-view approach — the Lead constructs a temporary
directory or symlink farm for each delegation. Start with prompt discipline;
escalate only if you observe drift.
