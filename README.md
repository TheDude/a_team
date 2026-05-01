# a_team

Starter kit for a Hermes-based multi-agent software development team.

This repository is now designed as a relocatable team-kit that can scaffold a project-local team working directory such as `agent-team/` inside any software repository.

Core idea:
- this repo contains the source-of-truth role skills and handoff templates
- a generated team working directory contains the live shared state for a specific project
- the generated team working directory is safe to commit to git alongside the target software project

## Recommended Team Working Directory Layout

Create a directory such as `agent-team/` in the target repository root with:
- `backlog.md`
- `decisions.md`
- `increments/`
- `test-plans/`
- `reviews/`
- `test-results/`
- `templates/`

This directory is the shared operational state for the agent team.

Important distinction:
- `skills/.../SKILL.md` in this kit define runtime role behavior
- `templates/*.md` define structured handoffs and reporting contracts
- files in the generated team working directory hold project-specific team state

In other words:
- skills shape behavior
- templates shape communication
- the team working directory stores durable project state

## Current Layout In This Repository

### Role skills
- `skills/teamlead-role/SKILL.md`
- `skills/architect-role/SKILL.md`
- `skills/coder-role/SKILL.md`
- `skills/reviewer-role/SKILL.md`
- `skills/tester-role/SKILL.md`

### Templates

#### Team Lead -> specialist handoffs
- `templates/teamlead-to-architect.md`
- `templates/teamlead-to-tester-test-design.md`
- `templates/teamlead-to-coder.md`
- `templates/teamlead-to-tester-execution.md`

#### Specialist -> Team Lead outputs
- `templates/architect-to-teamlead.md`
- `templates/coder-to-teamlead.md`
- `templates/reviewer-to-teamlead.md`
- `templates/tester-design-to-teamlead.md`
- `templates/tester-execution-to-teamlead.md`

#### Cross-role support
- `templates/coder-to-reviewer.md`
- `templates/blocker-report.md`
- `templates/teamlead-status-report.md`

### Installer
- `scripts/install-agent-team.sh`

The installer creates a working directory, copies the templates into it, and installs the role skills into a Hermes skills directory.

## Template Path Convention

The role skills in this repo now reference templates as:
- `./templates/...`

Interpretation:
- the active agent should be launched from inside the generated team working directory, or at minimum treat that directory as the current coordination root
- template lookups are relative to that active team working directory

This removes the old hardcoded dependency on `~/projects/a_team/templates/`.

## Installer Usage

Example:

```bash
~/projects/a_team/scripts/install-agent-team.sh ./agent-team --git-init
```

This will:
- create `./agent-team/`
- create `backlog.md`, `decisions.md`, `increments/`, `test-plans/`, `reviews/`, `test-results/`
- copy all handoff templates into `./agent-team/templates/`
- install role skills under `~/.hermes/skills/agent-team/` by default
- optionally initialize git in the team directory

Optional flags:
- `--skills-dir <path>` to choose a different Hermes skill installation directory
- `--force` to overwrite existing files
- `--git-init` to initialize a git repo in the generated team directory
- `--no-profiles` to skip automatic creation of `teamlead`, `architect`, `coder`, `reviewer`, and `tester` profiles

## Recommended Hermes Mapping

Recommended profile mapping:
- profile: `teamlead`  -> load skill: `teamlead-role`
- profile: `architect` -> load skill: `architect-role`
- profile: `coder`     -> load skill: `coder-role`
- profile: `reviewer`  -> load skill: `reviewer-role`
- profile: `tester`    -> load skill: `tester-role`

Suggested launch pattern:
- `cd agent-team && hermes -p teamlead -s teamlead-role`
- `cd agent-team && hermes -p architect -s architect-role`
- `cd agent-team && hermes -p coder -s coder-role`
- `cd agent-team && hermes -p reviewer -s reviewer-role`
- `cd agent-team && hermes -p tester -s tester-role`

## Recommended Operating Model

Default workflow:
1. User and Team Lead discuss goals and constraints.
2. Team Lead creates a scoped vertical slice.
3. Team Lead routes selectively:
   - Architect when design work is needed
   - Tester in test-design mode when acceptance or integration planning is needed
   - Coder for implementation
   - Reviewer before final test execution
   - Tester in execution mode for integration or regression validation
4. Team Lead triages results, re-plans if needed, and reports back to the user.

## Parallel Work Pattern

For the full team experience, run roles in separate `tmux` sessions and use worktree isolation where needed.

Example pattern:
- `tmux new-session -d -s teamlead 'cd agent-team && hermes -p teamlead -s teamlead-role'`
- `tmux new-session -d -s architect 'cd agent-team && hermes -p architect -s architect-role'`
- `tmux new-session -d -s coder 'cd agent-team && hermes -p coder -s coder-role -w'`
- `tmux new-session -d -s reviewer 'cd agent-team && hermes -p reviewer -s reviewer-role -w'`
- `tmux new-session -d -s tester 'cd agent-team && hermes -p tester -s tester-role -w'`

Use the Team Lead as the only role that talks directly to the human by default.

## Practical Rule

- If you want something followed automatically, put the critical version in a skill.
- If you want something documented, editable, and inspectable, put it in the team working directory.
- If you want consistent communication between roles, use templates.

## Thoughts On Your Proposal

Yes — this is a stronger design.

Why it is better:
- it makes each team instance self-contained and portable
- it turns the workflow artifacts into first-class repo state
- it avoids hardcoded local paths
- it makes installation repeatable
- it supports multiple teams across multiple repos with the same base kit
- it makes git a natural audit trail for backlog, decisions, reviews, and test results

The one subtle rule to preserve is this:
- the live role skills are installed into Hermes
- the live team state and live templates sit in the generated team directory
- the skills should always reference the generated team directory relatively, not the kit repo absolutely
