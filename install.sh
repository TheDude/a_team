#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./install.sh [-b base_profile] [--force] [--remove]

Options:
  -b, --base   PROFILE   Use PROFILE as the source for config/auth/.env (default: default)
  -f, --force            Overwrite existing profiles (delete before creating)
  -r, --remove           Remove installed profiles (no installation)
  -h, --help             Show this help message
USAGE
}

BASE_PROFILE="default"
FORCE=0
REMOVE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--base)
      [[ $# -lt 2 ]] && { echo "Error: --base requires an argument" >&2; exit 1; }
      BASE_PROFILE="$2"
      shift 2
      ;;
    -f|--force)
      FORCE=1
      shift
      ;;
    -r|--remove)
      REMOVE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ $FORCE -eq 1 && $REMOVE -eq 1 ]]; then
  echo "Error: --force and --remove cannot be used together." >&2
  exit 1
fi

if ! command -v hermes >/dev/null 2>&1; then
  echo "Error: hermes CLI not found in PATH" >&2
  exit 1
fi

run_hermes() {
  hermes "$@"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
PROFILES_DIR="$HERMES_HOME/profiles"

ROLES=(teamlead architect coder reviewer)
PROMPT_FILES=("team-lead.md" "architect.md" "coder.md" "reviewer.md")

BASE_PROFILE_DIR="$PROFILES_DIR/$BASE_PROFILE"
if [[ ! -d "$BASE_PROFILE_DIR" ]]; then
  BASE_PROFILE_DIR=$HERMES_HOME
fi

BASE_CONFIG=""
if [[ -f "$BASE_PROFILE_DIR/config.yaml" ]]; then
  BASE_CONFIG="$BASE_PROFILE_DIR/config.yaml"
elif [[ -f "$BASE_PROFILE_DIR/config.yml" ]]; then
  BASE_CONFIG="$BASE_PROFILE_DIR/config.yml"
fi

BASE_AUTH=""
if [[ -f "$BASE_PROFILE_DIR/auth.json" ]]; then
  BASE_AUTH="$BASE_PROFILE_DIR/auth.json"
fi

BASE_ENV=""
if [[ -f "$BASE_PROFILE_DIR/.env" ]]; then
  BASE_ENV="$BASE_PROFILE_DIR/.env"
fi

if [[ $REMOVE -eq 1 ]]; then
  for role in "${ROLES[@]}"; do
    profile_dir="$PROFILES_DIR/$role"
    if [[ -d "$profile_dir" ]]; then
      echo "Removing profile '$role'."
      if ! run_hermes profile delete -y "$role" >/dev/null 2>&1; then
        echo "Warning: 'hermes profile delete $role' failed; removing directory directly." >&2
        rm -rf "$profile_dir"
      fi
    else
      echo "Profile '$role' not found; skipping."
    fi
  done
  echo "Profile removal complete."
  exit 0
fi

for idx in "${!ROLES[@]}"; do
  role="${ROLES[$idx]}"
  prompt_file="$PROMPTS_DIR/${PROMPT_FILES[$idx]}"

  if [[ ! -f "$prompt_file" ]]; then
    echo "Error: missing prompt file $prompt_file" >&2
    exit 1
  fi

  profile_dir="$PROFILES_DIR/$role"

  if [[ -d "$profile_dir" ]]; then
    if [[ $FORCE -eq 0 ]]; then
      echo "Profile '$role' already exists; skipping. Use --force to overwrite."
      continue
    fi
    echo "Removing existing profile '$role'."
    if ! run_hermes profile delete -y "$role" >/dev/null 2>&1; then
      echo "Warning: 'hermes profile delete $role' failed; removing directory directly." >&2
      rm -rf "$profile_dir"
    fi
  fi

  echo "Creating profile '$role'."
  if ! run_hermes profile create "$role" >/dev/null 2>&1; then
    echo "Error: failed to create profile '$role'." >&2
    exit 1
  fi

  mkdir -p "$profile_dir"

  rm -f "$profile_dir/config.yaml" "$profile_dir/config.yml"
  if [[ -n "$BASE_CONFIG" ]]; then
    cp "$BASE_CONFIG" "$profile_dir/$(basename "$BASE_CONFIG")"
  fi

  rm -f "$profile_dir/auth.json"
  if [[ -n "$BASE_AUTH" ]]; then
    cp "$BASE_AUTH" "$profile_dir/auth.json"
  fi

  rm -f "$profile_dir/.env"
  if [[ -n "$BASE_ENV" ]]; then
    cp "$BASE_ENV" "$profile_dir/.env"
  fi

  cp "$prompt_file" "$profile_dir/SOUL.md"
  echo "Installed prompt for profile '$role' at $profile_dir/SOUL.md"

done

echo "All requested profiles processed."
