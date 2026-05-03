# Bootstrap — New Project

This document describes the procedure for bootstrapping a new team workspace.
There are two flavors:

- **New project bootstrap** — run once when the user starts a new project.
  Creates the directory tree, copies templates, initializes `state.md` and
  `README.md`, then yields control to the Team Lead to kick off discovery.
  This is a deterministic script (`new-project.sh` / `new-project.ps1`),
  not freeform agent behavior — there is no creativity required and getting
  the layout wrong silently breaks everything downstream.

- **Session resumption bootstrap** — run by the Team Lead at the start of
  every session that is not a brand-new project. This lives in the Lead's
  system prompt (see `prompts/team-lead.md` § "Session start"), not as a
  script. The Lead reads `state.md` first, then the relevant Discovery
  Document, then the current increment's directory, then announces state to
  the user.

This document covers new-project bootstrap. For session resumption, see the
Lead's prompt.

## Inputs

The bootstrap script needs:

- **Team name** — used as the root directory name. Constraints: filesystem-
  safe characters only (alphanumeric, dash, underscore), 1–64 chars, must
  not already exist as a directory in the parent path.
- **Parent directory** — where the team workspace will be created. Defaults
  to the current working directory.
- **Skill source path** — where the canonical handoff templates are copied
  from. Defaults to the directory the bootstrap script itself lives in,
  walking up to find `handoff_templates/`.
- **Initial git policy** — whether to `git init` the workspace. Default:
  yes. The Coder benefits from working in a git repo (clean diffs for the
  Reviewer, easy rollback on failed iterations) and project-management
  artifacts are also worth versioning.

## Steps

The script performs these steps in order. Any failure aborts and rolls back
created files.

1. **Validate inputs.** Reject if the team name is invalid or the target
   directory already exists. (No silent overwrites.)

2. **Create the directory tree** per `workspace-spec.md`:

   ```
   <team_name>/
   ├── handoff_templates/
   ├── discovery/
   ├── increments/
   ├── decisions/
   └── workspace/
   ```

3. **Copy canonical handoff templates** from the skill source into
   `<team_name>/handoff_templates/`. These are reference material; the
   bootstrap script is the only thing that writes to that directory. The
   Lead and specialists never modify the templates in place.

4. **Initialize `state.md`** with empty / pending values:

   ```yaml
   ---
   artifact_type: team_state
   team_name: <team_name>
   updated: <timestamp>
   updated_by: bootstrap
   ---
   ```

   Body indicates that no increment is active; the next action is "kick off
   discovery with the user."

5. **Initialize `README.md`** with the team name, the date, a one-line
   description (defaulted; user can edit), and a pointer to `state.md` as
   the session entry point.

6. **`.gitignore`** at the team workspace root — excludes editor noise,
   common build directories under `workspace/`, and language caches.

7. **`git init`** if the policy is on. Creates an initial commit with the
   bootstrapped layout so subsequent work has a clean diff baseline.

8. **Print a summary** with the absolute path to the workspace and the
   suggested first action: "Open a new Lead session in this workspace; the
   Lead will read `state.md` and propose starting discovery."

## What the bootstrap script does NOT do

- It does not invoke the Lead. The Lead is launched separately, in whatever
  harness the team is running (Hermes, Claude Agent SDK, etc.). The script
  just prepares the workspace.
- It does not write any discovery content. Discovery is the Lead's first
  job, not the bootstrap's.
- It does not auto-suffix on name conflicts. Silent overwrites are bad.
  Conflicts require explicit user action.

## Implementation notes

Two scripts are provided:

- `new-project.sh` — POSIX shell. Use on macOS / Linux / WSL.
- `new-project.ps1` — PowerShell. Use on Windows.

Both are intentionally simple. They depend only on the shell and `git` (if
the git policy is on). They do not read the skill itself; they just copy
the `handoff_templates/` directory from a known location.

The scripts must be kept in sync. When the workspace spec changes, update
both, plus the spec doc itself.

## Manual fallback

If you can't run the script, the manual procedure is:

1. `mkdir <team_name> && cd <team_name>`
2. `mkdir handoff_templates discovery increments decisions workspace`
3. Copy the contents of the skill's `handoff_templates/` into
   `handoff_templates/`.
4. Create `state.md` (see template at `handoff_templates/state.md`),
   filling in the team name and timestamp.
5. Create `README.md` (free-form, mostly a pointer to `state.md`).
6. Create `.gitignore` (see `bootstrap/gitignore-template`).
7. `git init && git add . && git commit -m "Bootstrap"`.
