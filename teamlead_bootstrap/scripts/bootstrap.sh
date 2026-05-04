#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF' >&2
Usage: bootstrap.sh <parent_directory> <team_name>

Arguments:
  parent_directory  Absolute or relative path where the team workspace should be created.
  team_name         Directory name for the team workspace (alphanumeric, dash, underscore; 1-64 chars).
EOF
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

parent_dir_input="$1"
team_name="$2"

if [[ ! "$team_name" =~ ^[A-Za-z0-9_-]{1,64}$ ]]; then
  echo "error: team_name must match ^[A-Za-z0-9_-]{1,64}$" >&2
  exit 1
fi

if [[ ! -d "$parent_dir_input" ]]; then
  echo "error: parent directory '$parent_dir_input' does not exist or is not a directory" >&2
  exit 1
fi

if ! parent_dir=$(cd "$parent_dir_input" 2>/dev/null && pwd); then
  echo "error: unable to resolve absolute path for parent directory '$parent_dir_input'" >&2
  exit 1
fi

target_dir="${parent_dir}/${team_name}"
if [[ -e "$target_dir" ]]; then
  echo "error: target path '$target_dir' already exists" >&2
  exit 1
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
skill_root=$(cd "$script_dir/.." && pwd)

templates_dir="$skill_root/templates"
if [[ ! -d "$templates_dir" ]]; then
  echo "error: templates directory '$templates_dir' is missing" >&2
  exit 1
fi

mkdir -p "$target_dir/handoff_templates" "$target_dir/discovery" "$target_dir/increments" "$target_dir/decisions" "$target_dir/workspace"

cp -a "$templates_dir/." "$target_dir/handoff_templates/"

workspace_path=$(cd "$target_dir" && pwd)
timestamp=$(date '+%Y-%m-%d %H:%M')
date_only=$(date '+%Y-%m-%d')

cat <<EOF >"$target_dir/state.md"
---
artifact_type: team_state
team_name: $team_name
updated: $timestamp
updated_by: bootstrap
---

# Team State

> This file is the session-resumption anchor. The Team Lead reads it first at
> session start and overwrites it at every state transition. Keep it short.

## Current Increment

- **ID:** none
- **Title:** n/a
- **Phase:** not-started
- **Phase entered:** $timestamp

## Last Action

bootstrap created workspace at $workspace_path on $date_only.

## Next Action

begin discovery with the user.

## Open Kickbacks

none

## Open Questions for User

- What problem is this team being formed to solve?

## Increment History (this session)

| Time              | Phase         | Note                                |
|-------------------|---------------|-------------------------------------|
| $timestamp | not-started  | Workspace bootstrapped.              |
EOF

cat <<EOF >"$target_dir/README.md"
# $team_name Team Workspace

Bootstrap date: $date_only

Default description: Multi-agent software team workspace scaffold. Update this description once the team's charter is confirmed.

State tracking entry point: Read state.md before beginning each session.

## Layout

- handoff_templates/: Canonical input/output templates copied from the team kit.
- discovery/: Notes, research, and context gathered during discovery.
- increments/: Active and historical increment briefs and logs.
- decisions/: Approved decisions and rationale.
- workspace/: Scratch area for in-progress work.
EOF

if command -v git >/dev/null 2>&1; then
  (
    cd "$target_dir"
    if git init -b master >/dev/null 2>&1; then
      :
    else
      git init >/dev/null 2>&1
      git symbolic-ref HEAD refs/heads/master >/dev/null 2>&1 || true
    fi
    git add . >/dev/null 2>&1
    if ! git commit -m "Bootstrap team $team_name" >/dev/null 2>&1; then
      echo "warning: git commit failed (configure user.name and user.email). Files are staged." >&2
    fi
  ) || echo "warning: git operations encountered an issue." >&2
else
  echo "warning: git command not found; skipped repository initialization." >&2
fi

echo "Bootstrapped team workspace at $workspace_path"
