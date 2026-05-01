#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  install-agent-team.sh <team-dir> [--skills-dir <path>] [--force] [--git-init] [--no-profiles]

Creates a relocatable agent-team working directory, copies the handoff templates,
and installs the role skills into a Hermes skills directory.

Arguments:
  <team-dir>            Target working directory to create or update.

Options:
  --skills-dir <path>   Destination for installed Hermes skills.
                        Default: ~/.hermes/skills/agent-team
  --force               Overwrite existing files in the target team directory
                        and installed skill files.
  --git-init            Run 'git init' inside the target team directory if it is
                        not already a git repository.
  --no-profiles         Skip automatic 'hermes profile create' commands.
  -h, --help            Show this help text.
EOF
}

TEAM_DIR=""
SKILLS_DIR="${HOME}/.hermes/skills/agent-team"
FORCE=0
GIT_INIT=0
CREATE_PROFILES=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skills-dir)
      [[ $# -ge 2 ]] || { echo "error: --skills-dir requires a value" >&2; exit 1; }
      SKILLS_DIR="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --git-init)
      GIT_INIT=1
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
SKILLS_DIR="${SKILLS_DIR/#\~/$HOME}"
mkdir -p "$TEAM_DIR"
mkdir -p "$TEAM_DIR/templates" "$TEAM_DIR/increments" "$TEAM_DIR/test-plans" "$TEAM_DIR/reviews" "$TEAM_DIR/test-results"
mkdir -p "$SKILLS_DIR"

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

  if ! command -v hermes >/dev/null 2>&1; then
    echo "warn    hermes CLI not found; skipping profile setup"
    return 1
  fi

  if hermes profile show "$profile_name" >/dev/null 2>&1; then
    echo "skip    profile $profile_name (already exists)"
    return 0
  fi

  hermes profile create "$profile_name" --clone-from default --clone --no-alias >/dev/null
  echo "create  profile $profile_name"
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
  write_if_allowed "$TEAM_DIR/$dir/.gitkeep" ""
done

shopt -s nullglob
for template in "$TEMPLATE_SOURCE_DIR"/*.md; do
  copy_if_allowed "$template" "$TEAM_DIR/templates/$(basename "$template")"
done

for skill_dir in "$SKILL_SOURCE_DIR"/*; do
  [[ -d "$skill_dir" ]] || continue
  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"
  [[ -f "$skill_file" ]] || continue
  copy_if_allowed "$skill_file" "$SKILLS_DIR/$skill_name/SKILL.md"
done
shopt -u nullglob

if [[ "$GIT_INIT" -eq 1 && ! -d "$TEAM_DIR/.git" ]]; then
  git -C "$TEAM_DIR" init >/dev/null
  echo "git     initialized $TEAM_DIR"
fi

if [[ "$CREATE_PROFILES" -eq 1 ]]; then
  ensure_profile "teamlead" || true
  ensure_profile "architect" || true
  ensure_profile "coder" || true
  ensure_profile "reviewer" || true
  ensure_profile "tester" || true
fi

cat <<EOF

done

Team working directory: $TEAM_DIR
Installed skills dir:   $SKILLS_DIR

Suggested next steps:
1. Launch Hermes from inside the team working directory
2. Use tmux + worktree isolation for parallel specialists when needed
3. If needed, assign role-specific model/tool configs per profile
EOF
