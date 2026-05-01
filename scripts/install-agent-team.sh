#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  install-agent-team.sh <team-dir> [--force] [--no-profiles]

Creates a relocatable agent-team working directory, copies the handoff templates,
and installs the role skills into each profile's skills directory.

Arguments:
  <team-dir>            Target working directory to create or update.

Options:
  --force               Overwrite existing files in the target team directory.
  --no-profiles         Skip automatic 'hermes profile create' commands.
  -h, --help            Show this help text.
EOF
}

TEAM_DIR=""
FORCE=0
CREATE_PROFILES=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    --no-profiles)
      CREATE_PROFILES=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -* )
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [[ -n "$TEAM_DIR" ]]; then
        echo "error: unexpected extra argument: $1" >&2
        usage >&2
        exit 1
      fi
      TEAM_DIR="$1"
      shift
      ;;
  esac
done

if [[ -z "$TEAM_DIR" ]]; then
  echo "error: <team-dir> is required" >&2
  usage >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMPLATE_SOURCE_DIR="${KIT_ROOT}/templates"
SKILL_SOURCE_DIR="${KIT_ROOT}/skills"

if [[ ! -d "$TEMPLATE_SOURCE_DIR" ]]; then
  echo "error: template source directory not found: $TEMPLATE_SOURCE_DIR" >&2
  exit 1
fi

if [[ ! -d "$SKILL_SOURCE_DIR" ]]; then
  echo "error: skill source directory not found: $SKILL_SOURCE_DIR" >&2
  exit 1
fi

TEAM_DIR="${TEAM_DIR/#\~/$HOME}"
mkdir -p "$TEAM_DIR"
mkdir -p "$TEAM_DIR/templates" "$TEAM_DIR/increments" "$TEAM_DIR/test-plans" "$TEAM_DIR/reviews" "$TEAM_DIR/test-results"

write_if_allowed() {
  local target="$1"
  local content="$2"

  if [[ -e "$target" && "$FORCE" -ne 1 ]]; then
    echo "skip    $target"
    return
  fi

  mkdir -p "$(dirname "$target")"
  printf '%s' "$content" > "$target"
  echo "write   $target"
}

copy_if_allowed() {
  local src="$1"
  local dest="$2"

  if [[ -e "$dest" && "$FORCE" -ne 1 ]]; then
    echo "skip    $dest"
    return
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "copy    $dest"
}

ensure_profile() {
  local profile_name="$1"
  local skill_name="$2"

  if ! command -v hermes >/dev/null 2>&1; then
    echo "warn    hermes CLI not found; skipping profile setup"
    return 1
  fi

  local profile_exists=0
  if hermes profile show "$profile_name" >/dev/null 2>&1; then
    profile_exists=1
    echo "skip    profile $profile_name (already exists)"
  else
    hermes profile create "$profile_name" --clone-from default --clone --no-alias >/dev/null
    echo "create  profile $profile_name"
  fi

  # Copy the role skill to the profile's skills directory
  local profile_dir="${HOME}/.hermes/profiles/${profile_name}"
  local skill_source_dir="${SKILL_SOURCE_DIR}/${skill_name}"
  local skill_dest_dir="${profile_dir}/skills/${skill_name}"

  if [[ -d "$skill_source_dir" ]]; then
    mkdir -p "$skill_dest_dir"
    for src_file in "$skill_source_dir"/*; do
      [[ -e "$src_file" ]] || continue
      dest_file="${skill_dest_dir}/$(basename "$src_file")"
      if [[ -e "$dest_file" && "$FORCE" -ne 1 ]]; then
        echo "skip    $dest_file"
      else
        cp -r "$src_file" "$skill_dest_dir/"
        echo "copy    $dest_file"
      fi
    done
  fi

  return 0
}

TEAM_NAME="$(basename "$TEAM_DIR")"

write_if_allowed "$TEAM_DIR/backlog.md" "# ${TEAM_NAME} backlog

## Active slices

## Next up

## Blocked
"

write_if_allowed "$TEAM_DIR/decisions.md" "# ${TEAM_NAME} decisions

| Date | Decision | Status | Notes |
| --- | --- | --- | --- |
"

write_if_allowed "$TEAM_DIR/README.md" "# ${TEAM_NAME}

Agent-team working directory.

Layout:
- backlog.md
- decisions.md
- increments/
- test-plans/
- reviews/
- test-results/
- templates/

Notes:
- Agents should treat this directory as the active team working directory.
- Role skills reference handoff templates in ./templates/ relative to this directory.
- Keep durable team state here instead of relying on chat history alone.
"

for dir in increments test-plans reviews test-results; do
  mkdir -p "$TEAM_DIR/$dir"
done

shopt -s nullglob
for template in "$TEMPLATE_SOURCE_DIR"/*.md; do
  copy_if_allowed "$template" "$TEAM_DIR/templates/$(basename "$template")"
done
shopt -u nullglob

if [[ "$CREATE_PROFILES" -eq 1 ]]; then
  ensure_profile "teamlead" "teamlead-role" || true
  ensure_profile "architect" "architect-role" || true
  ensure_profile "coder" "coder-role" || true
  ensure_profile "reviewer" "reviewer-role" || true
  ensure_profile "tester" "tester-role" || true
fi

cat <<EOF

done

Team working directory: $TEAM_DIR
Role skills installed to each profile's skills directory:
  - teamlead  -> ~/.hermes/profiles/teamlead/skills/teamlead-role/
  - architect -> ~/.hermes/profiles/architect/skills/architect-role/
  - coder     -> ~/.hermes/profiles/coder/skills/coder-role/
  - reviewer  -> ~/.hermes/profiles/reviewer/skills/reviewer-role/
  - tester    -> ~/.hermes/profiles/tester/skills/tester-role/

Suggested next steps:
1. Launch Hermes from inside the team working directory
2. Use tmux + worktree isolation for parallel specialists when needed
3. If needed, assign role-specific model/tool configs per profile
EOF
