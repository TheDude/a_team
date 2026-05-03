# Hermes Engineering Team — Spec

This document is the canonical specification for an autonomous, four-role
software engineering team designed to run on Hermes (Nous Research). It
bundles the design rationale, the role definitions, the artifact templates,
the workspace layout, and the bootstrap procedure into one place.

For working files referenced by this spec:

- Role prompts: `prompts/`
- Handoff templates: `handoff_templates/`
- Workspace layout: `workspace-spec.md`
- Bootstrap procedure: `bootstrap/new-project.md`
- Bootstrap scripts: `bootstrap/new-project.sh`, `bootstrap/new-project.ps1`

---

## 1. Goals

The team automates the design / build / test loop for software development
the way an experienced engineer would actually run it: discovery before
design, design before code, tests before implementation, review before merge,
regression before done. The goal is to produce working, maintainable code
with the quality you would expect from a small, disciplined team — not just
plausibly-shaped code that passes a smoke test.

Specific design goals, in priority order:

1. **Quality through context isolation.** Each role sees only what it
   needs. The Coder doesn't carry discovery rationale; the Architect
   doesn't carry implementation noise.
2. **Auditable handoffs.** Every transition between roles produces a
   structured artifact. No verbal-equivalent passes.
3. **Honest reporting.** Every artifact has fields for what was done, what
   was deferred, and what deviated from the prior layer. Undeclared
   deviations are treated as defects.
4. **Session resumption.** The team can be paused and resumed across
   sessions without losing state. This is a workspace-layout concern more
   than a model-state concern.
5. **Fully autonomous, with the user at the seams.** The user appears at
   discovery, at lead-to-user kickbacks, and at final increment sign-off.
   Everything in between is the team's job.

Non-goals for the current version:

- Parallel increments. The flow handles one active increment at a time.
  Cross-increment dependency tracking, merge-conflict orchestration, and
  parallel branch CI are explicitly deferred.
- Multi-project orchestration. One team, one project.
- Self-modification. The team does not edit its own prompts or templates.

## 2. Roles

Four roles. The Team Lead orchestrates; the others are invoked by the Lead
and never speak directly to the user or to each other.

### Team Lead

Owns the project lifecycle. Responsibilities:

- Conducts discovery with the user and produces the Discovery Document.
- Maintains the roadmap of increments.
- Picks the next increment, drafts the Increment artifact, kicks off the
  design / build / review cycle.
- Curates the context bundle for each specialist invocation.
- Verifies handoff artifacts against templates and against prior layers.
- Adjudicates kickbacks; decides between resolve-in-place, escalate to
  discovery, escalate to user, or defer.
- Maintains `state.md` and the decision log.
- Kicks off CI/CD after review sign-off.

The Lead does not write production code, run tests directly, or perform
reviews. The Lead decides, routes, and verifies.

System prompt: `prompts/team-lead.md`.

### Architect

Takes a Discovery Document and an Increment, produces a Design Package.
Owns:

- Component boundaries
- Public interfaces and their contracts (preconditions, postconditions,
  error cases)
- Data models and their invariants
- Dependency choices
- Integration points
- Architectural constraints (perf, security, concurrency)
- High-level integration test scenarios derived from use cases
- Stack selection on first-touch increments

Does not own internal class hierarchies, method-level decomposition,
algorithm pseudocode (unless an algorithmic property is itself
architectural), or anything contained within a single component.

System prompt: `prompts/architect.md`.

### Coder

Takes a Design Package, produces a test plan, a task breakdown, and then
working tested code. Owns:

- Test plan (derived from contracts and acceptance criteria)
- Task breakdown (order of operations)
- Internal decomposition: classes, helpers, method-level structure
- Variable names, file organization within a module
- Algorithm choice (subject to any algorithmic constraints in the design)
- Test organization

Tests are written first. The Coder declares deviations from the design
package explicitly. If TDD surfaces a design problem, the Coder files a
kickback rather than working around silently.

System prompt: `prompts/coder.md`.

### Reviewer

Takes the Increment, the Design Package, the Coder Report, and the diff;
produces a Review Report. Reviews against:

- Acceptance criteria coverage and verification
- Design compliance (boundaries, interfaces, invariants, constraints)
- Common pitfalls (security, perf, resource leaks, test validity, etc.)
- Maintainability and quality

Severity is forced: every issue is `blocking`, `should-fix`, or `nit`.
Recommendation is one of `sign-off`, `sign-off-with-followups`, or
`kickback`. Review is unconditional — every increment passes through the
Reviewer regardless of whether the Coder reported issues.

System prompt: `prompts/reviewer.md`.

## 3. Lifecycle

Each increment progresses through a phase machine. The Lead is responsible
for transitions; phase transitions write to `state.md`.

```
not-started
  → designing         (Lead invokes Architect)
  → design-review    (Lead reviewing the design package)
  → implementing      (Lead invokes Coder)
  → code-review      (Lead invokes Reviewer)
  → ci-cd            (regression suite running)
  → done             (review signed off + CI green)

Any phase → blocked   (kickback opened, awaiting resolution)
blocked → previous phase (on resolution)
```

Project-level discovery happens before the first increment and may be
reopened at any time. Reopening produces a new Discovery Document version
that supersedes the previous; prior is preserved on disk.

## 4. Handoffs

Every handoff is an artifact written from a template. Free-form passes are
forbidden; they accumulate ambiguity at every boundary.

| From → To             | Artifact                          | Template                              |
|-----------------------|-----------------------------------|---------------------------------------|
| Lead → user           | Discovery Document                | `handoff_templates/discovery-document.md` |
| Lead → Architect      | Increment + curated context       | `handoff_templates/increment.md`       |
| Architect → Lead      | Design Package                    | `handoff_templates/design-package.md`  |
| Lead → Coder          | Design Package + curated context  | (forwarded)                           |
| Coder → Lead          | Coder Report (+ diff in repo)     | `handoff_templates/coder-report.md`    |
| Lead → Reviewer       | Design + Report + diff            | (forwarded)                           |
| Reviewer → Lead       | Review Report                     | `handoff_templates/review-report.md`   |
| Any → Lead, Lead → up | Kickback                          | `handoff_templates/kickback.md`        |
| Lead (any time)       | Decision log entry                | `handoff_templates/decision-log-entry.md` |
| Lead (each transition)| `state.md` overwrite              | `handoff_templates/state.md`           |

Each artifact is markdown with YAML frontmatter. The frontmatter carries
type, ID, status, refs, and timestamps; the body uses the structured sections
defined in the template.

Cross-references between artifacts use IDs (e.g., `inc-001`, `design-001`),
not paths. The mapping from ID to path is fixed in `workspace-spec.md`.

## 5. Workspace

A team workspace has a fixed layout. The Lead and specialists treat it
literally. See `workspace-spec.md` for the full structure and conventions.

Top-level shape:

```
<team_name>/
├── README.md
├── state.md
├── handoff_templates/   # canonical, read-only after bootstrap
├── discovery/
├── increments/          # one directory per increment
├── decisions/
└── workspace/           # source tree
```

The increment-as-directory pattern is the important one. Co-locating all
artifacts for a single unit of work makes context curation tractable: the
Lead can hand the Coder `increments/inc-003/` and trust that everything
relevant is there.

`state.md` is the session-resumption anchor — short, overwritten at every
transition, read first by every new Lead session.

## 6. Bootstrap

Two flavors:

**New project bootstrap.** A deterministic script (`bootstrap/new-project.sh`
or `.ps1`) creates the directory tree, copies the canonical templates,
initializes `state.md` and `README.md`, runs `git init`, and prints a
summary. The script does not invoke the Lead — that's a separate step in
whatever harness the team is running.

**Session resumption bootstrap.** Built into the Lead's system prompt
(`prompts/team-lead.md` § "Session start"). The Lead reads `state.md`
first, then the relevant Discovery Document, then the current increment's
directory, then announces state to the user before taking any action.
Autonomy mode does not exempt the Lead from the announce-and-confirm step
— a user resuming after days away may have changed their mind since the
last session.

See `bootstrap/new-project.md` for the procedure document.

## 7. Lead's verification responsibilities

In addition to whatever the specialists report, the Lead performs these
checks at each handoff:

**On receiving a Design Package.** Every acceptance criterion in the
increment maps to at least one entry in the design's traceability matrix.
Every public interface has explicit pre/postconditions and error cases.
Stack decisions are present (or explicitly inherited). Open questions in
the package's §12 are empty before it can be marked accepted.

**On receiving a Coder Report.** All acceptance criteria have a corresponding
test. If §4 deviations is empty but the diff appears to deviate from the
design, the Lead files a kickback. Test results are green or `outcome` is
`partial` or `blocked`.

**On receiving a Review Report.** Every blocking issue is addressed before
sign-off. For `sign-off-with-followups`, the Lead decides whether each
should-fix item is deferrable; deferrals become follow-up increments in
the roadmap, not vague notes.

## 8. Kickbacks and escalation

Specialists may file kickbacks to the Lead. The Lead may file kickbacks to
specialists or to the user. Every kickback is an artifact (template:
`handoff_templates/kickback.md`), filed in the relevant increment's
`kickbacks/` directory, with a `parent_id` pointing at the artifact that
triggered it.

Severity:
- **blocking** — downstream cannot proceed.
- **clarification** — can proceed under a stated working assumption; that
  assumption is at risk if resolved differently.
- **proposal** — improvement suggestion; downstream not blocked.

Lead's decision tree on receiving a kickback:
- Resolve in place — answer or amend the artifact at the same level.
- Escalate to discovery — kickback reveals a discovery-level gap; reopen
  discovery with the user.
- Escalate to user — only the user can answer.
- Defer — only if the working assumption is acceptable. Mark
  `clarification`-resolved with a note of what was deferred and to which
  increment.

Decision log entries are required for any architectural reversal or
non-trivial scope change resulting from a kickback.

## 9. CI/CD

After review sign-off, the Lead kicks off the regression test suite. The
specifics depend on the project's stack and tooling; the design package's
stack decisions identify the relevant tools.

CI/CD is treated as part of the deliverable, not the team's harness. The
team produces a project that includes its CI/CD configuration; the Lead
runs that configuration as part of finishing an increment.

If CI/CD fails after a green review, the Lead opens a kickback to the
Coder with the failure details. This is rare in well-scoped increments —
when it happens, it usually surfaces a gap in the design's integration
test scenarios. The Lead may amend the design package and require a
re-review.

## 10. Open design questions

Things this spec does not yet pin down. These are areas where you'll
likely iterate as you build out the implementation:

- **Eval harness.** A four-role system has a combinatorial space of failure
  modes. The eval harness needs fixtures (sample discovery requests,
  sample increments at various complexity levels), rubrics for grading
  each artifact type against its template, and replay infrastructure for
  re-running handoffs against changed prompts. Build the harness before
  tuning prompts, not after.

- **Tools-vs-agents tradeoff.** The Reviewer in particular may be better
  modeled as a tool (`review(code, design) -> report`) than as an agent
  with conversation state. Worth measuring once basic flow works.

- **Sandboxed views.** Currently the prompt asks specialists not to read
  outside their bundle, but the filesystem doesn't enforce it. If
  specialists drift, escalate to per-invocation sandboxed views (a
  temporary directory or symlink farm with only the curated artifacts).

- **Parallel increments.** Out of scope for this version. When you take it
  on, you'll need explicit dependency tracking between increments,
  merge-conflict handling, and integration test orchestration across
  branches. Don't pretend the current design is one small step away.

- **Failure-mode taxonomy.** The Reviewer's common-pitfalls checklist is a
  starting point. As you observe real failure modes from this team, fold
  them into the checklist and into the Coder's anti-pattern list.

## 11. What "done" looks like for an increment

An increment is `done` when all of the following are true:

- The Coder Report's `outcome` is `success`.
- The Review Report's `recommendation` is `sign-off` or
  `sign-off-with-followups` (with deferrals filed as follow-up increments).
- All `blocking` issues from review are resolved.
- All open kickbacks for the increment are `resolved` or `abandoned`.
- CI/CD passes.
- `state.md` reflects the transition to `done`.
- The roadmap in the Discovery Document is updated.

The Lead does the final transition. The user is notified.
