#!/usr/bin/env bash
# install.sh — install the four-role engineering team as Hermes profiles.
#
# Creates four Hermes profiles under $HERMES_HOME/profiles/:
#   - team-lead   (also bundles handoff_templates as a skill)
#   - architect
#   - coder
#   - reviewer
#
# For each profile, writes SOUL.md from prompts/<role>.md (YAML frontmatter
# stripped). Preserves any existing config.yaml, .env, memory, sessions, and
# state.db unless --force is passed; even with --force, only SOUL.md and the
# handoff-templates skill are overwritten — per-profile state is never touched.
#
# Run from the root of this skill repository (the directory containing
# prompts/ and handoff_templates/).

set -euo pipefail

# -----------------------------------------------------------------------------
# Defaults and option parsing
# -----------------------------------------------------------------------------

FORCE=0
HERMES_HOME_DIR="${HERMES_HOME:-$HOME/.hermes}"
PROFILE_PREFIX=""
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: install.sh [OPTIONS]

Installs the four-role engineering team as Hermes profiles.

Options:
  -f, --force            Overwrite existing SOUL.md and (for team-lead) the
                         handoff-templates skill. Per-profile state — memory,
                         sessions, .env, state.db — is preserved either way.
      --hermes-home DIR  Override the Hermes home root.
                         Default: $HERMES_HOME if set, else ~/.hermes
      --prefix STR       Prefix added to each profile name. e.g. with
                         --prefix ateam- the profiles become ateam-team-lead,
                         ateam-architect, etc. Useful when other Hermes
                         profiles already use these names.
  -n, --dry-run          Print actions without making changes.
  -h, --help             Show this help.

Profiles are written to: <hermes-home>/profiles/<prefix><role>/
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -f|--force) FORCE=1; shift ;;
    --hermes-home)
      [ $# -ge 2 ] || { echo "--hermes-home requires an argument" >&2; exit 2; }
      HERMES_HOME_DIR="$2"; shift 2 ;;
    --prefix)
      [ $# -ge 2 ] || { echo "--prefix requires an argument" >&2; exit 2; }
      PROFILE_PREFIX="$2"; shift 2 ;;
    -n|--dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    *) echo "Unexpected positional argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

# -----------------------------------------------------------------------------
# Locate skill root and validate
# -----------------------------------------------------------------------------

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROMPTS_DIR="$SCRIPT_DIR/prompts"
TEMPLATES_DIR="$SCRIPT_DIR/handoff_templates"

[ -d "$PROMPTS_DIR" ] || {
  echo "Error: $PROMPTS_DIR not found." >&2
  echo "Run install.sh from the root of the skill repository." >&2
  exit 1
}
[ -d "$TEMPLATES_DIR" ] || {
  echo "Error: $TEMPLATES_DIR not found." >&2
  echo "Run install.sh from the root of the skill repository." >&2
  exit 1
}

ROLES=(team-lead architect coder reviewer)
for role in "${ROLES[@]}"; do
  [ -f "$PROMPTS_DIR/$role.md" ] || {
    echo "Error: $PROMPTS_DIR/$role.md not found." >&2
    exit 1
  }
done

PROFILES_ROOT="$HERMES_HOME_DIR/profiles"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [dry-run] $*"
  else
    "$@"
  fi
}

# strip_frontmatter: read a markdown file and emit it with leading YAML
# frontmatter (--- ... ---) removed. If the file has no frontmatter, it's
# emitted unchanged. Hermes also strips frontmatter at runtime, but we strip
# at install time so SOUL.md is human-readable when inspected.
strip_frontmatter() {
  local file="$1"
  awk '
    BEGIN { in_fm = 0; passed_fm = 0 }
    NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; next }
    in_fm && /^---[[:space:]]*$/ { in_fm = 0; passed_fm = 1; next }
    in_fm { next }
    { print }
  ' "$file"
}

# write_file: write stdin to a file, respecting dry-run.
write_file() {
  local target="$1"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [dry-run] write $target"
    cat >/dev/null
  else
    mkdir -p "$(dirname "$target")"
    cat > "$target"
  fi
}

# -----------------------------------------------------------------------------
# Install one profile
# -----------------------------------------------------------------------------

install_profile() {
  local role="$1"
  local profile_name="${PROFILE_PREFIX}${role}"
  local profile_dir="$PROFILES_ROOT/$profile_name"
  local prompt_file="$PROMPTS_DIR/$role.md"
  local soul_file="$profile_dir/SOUL.md"

  echo "Profile: $profile_name"
  echo "  dir: $profile_dir"

  run mkdir -p "$profile_dir"

  # SOUL.md
  if [ -f "$soul_file" ] && [ "$FORCE" -eq 0 ]; then
    echo "  ! SOUL.md exists — skipping (re-run with --force to overwrite)"
  else
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "  [dry-run] write $soul_file (stripped frontmatter from $prompt_file)"
    else
      strip_frontmatter "$prompt_file" > "$soul_file"
      echo "  + SOUL.md written"
    fi
  fi

  # Team Lead also gets the handoff-templates skill.
  if [ "$role" = "team-lead" ]; then
    install_templates_skill "$profile_dir"
  fi
}

# -----------------------------------------------------------------------------
# Install the handoff-templates skill into the team-lead profile
# -----------------------------------------------------------------------------

install_templates_skill() {
  local profile_dir="$1"
  local skill_dir="$profile_dir/skills/handoff-templates"

  if [ -d "$skill_dir" ] && [ "$FORCE" -eq 0 ]; then
    echo "  ! handoff-templates skill exists — skipping (re-run with --force to overwrite)"
    return 0
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    [ -d "$skill_dir" ] && echo "  [dry-run] rm -rf $skill_dir"
    echo "  [dry-run] mkdir -p $skill_dir"
    echo "  [dry-run] copy templates from $TEMPLATES_DIR"
    echo "  [dry-run] write $skill_dir/SKILL.md"
    return 0
  fi

  # Wipe existing skill dir on --force so stale templates don't linger.
  if [ -d "$skill_dir" ]; then
    rm -rf "$skill_dir"
  fi
  mkdir -p "$skill_dir"

  cp "$TEMPLATES_DIR"/*.md "$skill_dir/"

  cat > "$skill_dir/SKILL.md" <<'EOF'
---
name: handoff-templates
description: Canonical handoff templates for the four-role engineering team — Discovery Document, Increment, Design Package, Coder Report, Review Report, Decision Log Entry, Kickback, and Team State. Used by the Team Lead during bootstrap and referenced by all roles via the team workspace.
---

# Handoff Templates

Markdown templates with YAML frontmatter, used by the four-role engineering
team. Each template defines the structure of a specific handoff artifact.

The Team Lead is responsible for these templates. At new-project bootstrap,
the Lead copies the contents of this skill into the new team workspace at
`<team_dir>/handoff_templates/`. From that point on, the team's own copy is
the active reference; this skill directory is the canonical source for new
teams.

Templates included:

- `discovery-document.md` — problem statement, use cases, roadmap.
- `increment.md` — a single unit of work.
- `design-package.md` — architectural design for an increment.
- `coder-report.md` — implementation report from the Coder.
- `review-report.md` — review report from the Reviewer.
- `decision-log-entry.md` — record of architectural / scope decisions.
- `kickback.md` — return an artifact upstream for revision.
- `state.md` — session-resumption anchor (one per team workspace).
EOF

  echo "  + handoff-templates skill installed at skills/handoff-templates/"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

echo "Installing four-role team into Hermes."
echo "  hermes-home: $HERMES_HOME_DIR"
echo "  prefix:      ${PROFILE_PREFIX:-(none)}"
echo "  force:       $([ "$FORCE" -eq 1 ] && echo yes || echo no)"
echo "  dry-run:     $([ "$DRY_RUN" -eq 1 ] && echo yes || echo no)"
echo

run mkdir -p "$PROFILES_ROOT"

for role in "${ROLES[@]}"; do
  install_profile "$role"
done

echo
echo "Done."
echo
echo "Verify with:"
echo "  ls $PROFILES_ROOT"
echo
echo "If the 'hermes' CLI is on PATH, each profile is launchable as:"
for role in "${ROLES[@]}"; do
  echo "  hermes --profile ${PROFILE_PREFIX}${role} chat"
done
