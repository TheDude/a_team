# new-project.ps1 — bootstrap a new team workspace (Windows / PowerShell).
#
# Usage:
#   .\new-project.ps1 -TeamName widget-team [-ParentDir C:\Users\me\projects]
#
# Behavior mirrors new-project.sh.

param(
    [Parameter(Mandatory=$true)]
    [string]$TeamName,

    [Parameter(Mandatory=$false)]
    [string]$ParentDir = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

# Validate team name.
if ($TeamName -notmatch '^[A-Za-z0-9_-]{1,64}$') {
    Write-Error "Invalid team name: $TeamName. Allowed: alphanumeric, dash, underscore. 1-64 chars."
    exit 2
}

# Resolve skill root (walk up from this script until we find handoff_templates/).
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillRoot = $ScriptDir
while ($SkillRoot -and -not (Test-Path (Join-Path $SkillRoot 'handoff_templates'))) {
    $Parent = Split-Path -Parent $SkillRoot
    if ($Parent -eq $SkillRoot) { break }
    $SkillRoot = $Parent
}
if (-not (Test-Path (Join-Path $SkillRoot 'handoff_templates'))) {
    Write-Error "Could not locate handoff_templates/ above $ScriptDir"
    exit 1
}

$Target = Join-Path $ParentDir $TeamName

if (Test-Path $Target) {
    Write-Error "Refusing to overwrite existing path: $Target. Choose a different team name or remove the path explicitly."
    exit 1
}

$Now = Get-Date -Format 'yyyy-MM-dd HH:mm'
$Today = Get-Date -Format 'yyyy-MM-dd'

Write-Host "Bootstrapping team '$TeamName' at $Target"

# Create directory tree.
New-Item -ItemType Directory -Path $Target | Out-Null
New-Item -ItemType Directory -Path (Join-Path $Target 'handoff_templates') | Out-Null
New-Item -ItemType Directory -Path (Join-Path $Target 'discovery') | Out-Null
New-Item -ItemType Directory -Path (Join-Path $Target 'increments') | Out-Null
New-Item -ItemType Directory -Path (Join-Path $Target 'decisions') | Out-Null
New-Item -ItemType Directory -Path (Join-Path $Target 'workspace') | Out-Null

# Copy canonical templates.
Copy-Item (Join-Path $SkillRoot 'handoff_templates\*.md') (Join-Path $Target 'handoff_templates') -Force

# state.md
$StateContent = @"
---
artifact_type: team_state
team_name: $TeamName
updated: $Now
updated_by: bootstrap
---

# Team State

## Current Increment

- **ID:** none
- **Title:** —
- **Phase:** not-started
- **Phase entered:** $Now

## Last Action

Bootstrap script created the workspace at $Target on $Today.

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
| $Now | bootstrap | workspace initialized |
"@
Set-Content -Path (Join-Path $Target 'state.md') -Value $StateContent -Encoding UTF8

# README.md
$ReadmeContent = @"
# $TeamName

Bootstrapped on $Today.

This is a Team workspace managed by an autonomous engineering team (Lead,
Architect, Coder, Reviewer). For session resumption, the Lead reads
``state.md`` first.

## Layout

- ``state.md`` — current state. Read first.
- ``discovery/`` — discovery documents.
- ``increments/`` — one subdirectory per increment.
- ``decisions/`` — decision log.
- ``handoff_templates/`` — canonical templates (read-only reference).
- ``workspace/`` — source tree.

See ``workspace-spec.md`` in the skill repo for the full layout.
"@
Set-Content -Path (Join-Path $Target 'README.md') -Value $ReadmeContent -Encoding UTF8

# .gitignore
$GitignoreContent = @"
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
"@
Set-Content -Path (Join-Path $Target '.gitignore') -Value $GitignoreContent -Encoding UTF8

# git init + initial commit.
if (Get-Command git -ErrorAction SilentlyContinue) {
    Push-Location $Target
    try {
        git init -b main | Out-Null
        git add . | Out-Null
        git commit -m "Bootstrap team $TeamName" | Out-Null
        Write-Host "Initialized git repo with initial commit."
    } finally {
        Pop-Location
    }
} else {
    Write-Host "git not found; skipping git init."
}

Write-Host ""
Write-Host "Done. Workspace ready at:"
Write-Host "  $Target"
Write-Host ""
Write-Host "Next: open a Team Lead session in this workspace. The Lead will read"
Write-Host "state.md and propose starting discovery."
