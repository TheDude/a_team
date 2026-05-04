---
name: teamlead_bootstrap
description: Bootstrap a software development team working directory structure
---

# Teamlead Bootstrap

How to create the directory structure for a software development team when acting as a teamlead.

## When to Use
Use this skill when creating a new software development team and creating a new workspace structure. This is a deterministic procedure, not a creative one — follow it literally. 

### Inputs you need
- **Team name** — the root directory name. Constraints: alphanumeric, dash, or underscore only; 1–64 chars; must not match any existing directory at the parent path.
- **Parent directory** — where the team workspace will be created. If not provided, ask. Do not assume the current working directory.

If either of these is missing, ask the user before doing anything else. Do not guess.

### Validation

Refuse to proceed if:

- The team name is invalid (regex: `^[A-Za-z0-9_-]{1,64}$`).
- `<parent_directory>/<team_name>` already exists. Silent overwriting of
  project state is the worst outcome here. The user must choose a different
  name or remove the existing path explicitly.
- The skill root does not contain a `templates/` directory with the
  expected template files.

### Procedure

- execute <skill-root>/bootstrap.sh. This will create the directory tree.
- verify the workspace has been created:
   ```
   <team_name>/
   ├── handoff_templates/
   ├── discovery/
   ├── increments/
   ├── decisions/
   └── workspace/
   ```
- If there are any errors, stop and report.
