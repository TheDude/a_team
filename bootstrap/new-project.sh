#!/usr/bin/env bash
# new-project.sh — bootstrap a new team workspace.
#
# Usage:
#   ./new-project.sh <team_name> [parent_dir]
#
# Example:
#   ./new-project.sh widget-team ~/projects
#
# Behavior:
#   - Refuses if <parent_dir>/<team_name> already exists.
#   - Copies canonical handoff_templates/ from the skill into the new workspace.
#   - Initializes state.md, README.md, .gitignore.
#   - Runs `git init` and creates an initial commit.

set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 <team_name> [parent_dir]" >&2
  exit 2
fi

TEAM_NAME="$1"
PARENT_DIR="${2:-$PWD}"

# Validate team name.
if ! [[ "$TEAM_NAME" =~ ^[A-Za-z0-9_-]{1,64}$ ]]; then
  echo "Invalid team name: $TEAM_NAME" >&2
  echo "Allowed: alphanumeric, dash, underscore. 1-64 chars." >&2
  exit 2
fi

# Resolve skill root (the directory containing handoff_templates/).
# Walk up from this script's location until we find handoff_templates/.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SKILL_ROOT="$SCRIPT_DIR"
while [ "$SKILL_ROOT" != "/" ] && [ ! -d "$SKILL_ROOT/handoff_templates" ]; do
  SKILL_ROOT="$( dirname "$SKILL_ROOT" )"
done
if [ ! -d "$SKILL_ROOT/handoff_templates" ]; then
  echo "Could not locate handoff_templates/ above $SCRIPT_DIR" >&2
  exit 1
fi

TARGET="$PARENT_DIR/$TEAM_NAME"

if [ -e "$TARGET" ]; then
  echo "Refusing to overwrite existing path: $TARGET" >&2
  echo "Choose a different team name or remove the path explicitly." >&2
  exit 1
fi

NOW="$(date '+%Y-%m-%d %H:%M')"
TODAY="$(date '+%Y-%m-%d')"

echo "Bootstrapping team '$TEAM_NAME' at $TARGET"

# Create directory tree.
mkdir -p "$TARGET/handoff_templates"
mkdir -p "$TARGET/discovery"
mkdir -p "$TARGET/increments"
mkdir -p "$TARGET/decisions"
mkdir -p "$TARGET/workspace"

# Copy canonical templates.
cp "$SKILL_ROOT/handoff_templates/"*.md "$TARGET/handoff_templates/"

# state.md
cat > "$TARGET/state.md" <<EOF
---
artifact_type: team_state
team_name: $TEAM_NAME
updated: $NOW
updated_by: bootstrap
---

# Team State

## Current Increment

- **ID:** none
- **Title:** —
- **Phase:** not-started
- **Phase entered:** $NOW

## Last Action

Bootstrap script created the workspace at $TARGET on $TODAY.

## Next Action

Team Lead opens a session, reads this file and the (not-yet-created) discovery
document, then begins discovery with the user.

## Open Kickbacks

none

## Open Questions for User

- [ ] What problem is this team being formed to solve? (Discovery starts here.)

## Increment History (this session)

| Time | Phase | Note |
|------|-------|------|
| $NOW | bootstrap | workspace initialized |
EOF

# README.md
cat > "$TARGET/README.md" <<EOF
# $TEAM_NAME

Bootstrapped on $TODAY.

This is a Team workspace managed by an autonomous engineering team (Lead,
Architect, Coder, Reviewer). For session resumption, the Lead reads
\`state.md\` first.

## Layout

- \`state.md\` — current state. Read first.
- \`discovery/\` — discovery documents.
- \`increments/\` — one subdirectory per increment.
- \`decisions/\` — decision log.
- \`handoff_templates/\` — canonical templates (read-only reference).
- \`workspace/\` — source tree.

See \`workspace-spec.md\` in the skill repo for the full layout.
EOF

# .gitignore
cat > "$TARGET/.gitignore" <<'EOF'
# OS / editor noise
.DS_Store
Thumbs.db
*.swp
*~
.vscode/
.idea/

# Build artifacts under workspace/
workspace/build/
workspace/dist/
workspace/.cache/

# Language-specific
__pycache__/
*.pyc
*.pyo
.venv/
venv/
node_modules/
target/
EOF

# git init + initial commit (best effort; do not fail bootstrap if git is absent).
if command -v git >/dev/null 2>&1; then
  ( cd "$TARGET" && \
    git init -b main >/dev/null && \
    git add . && \
    git commit -m "Bootstrap team $TEAM_NAME" >/dev/null )
  echo "Initialized git repo with initial commit."
else
  echo "git not found; skipping git init."
fi

echo
echo "Done. Workspace ready at:"
echo "  $TARGET"
echo
echo "Next: open a Team Lead session in this workspace. The Lead will read"
echo "state.md and propose starting discovery."
