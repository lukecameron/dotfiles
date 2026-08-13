---
name: review-change
description: Review code changes with evidence-backed findings, scope checks, and remediation verification. Use when asked to review a branch, commit, pull-request diff, uncommitted changes, or a fix for earlier review findings; use the optional adversarial mode for large or high-risk changes.
---

# Review Change

Review the resulting code, not the authoring narrative. Report only actionable findings supported by current source evidence.

## Establish the review target

1. Resolve the requested change and base. Prefer an explicit base, pull-request metadata, or the repository's configured default branch; do not silently assume `main`.
2. Read the applicable `AGENTS.md` files and repository documentation for build, test, and review rules.
3. Inspect the worktree before reviewing. Preserve unrelated user changes and distinguish them from the target diff.
4. Read the complete diff, then open every changed file with enough surrounding context to understand the behavior. Inspect affected callers, tests, schemas, and dependency contracts where relevant.

## Review

Check, in order:

- Correctness, edge cases, error paths, concurrency, and security.
- Blast radius: behavior or files outside the stated task, especially shared configuration and public contracts.
- Tests: whether each behavior change has a test that would fail without it, and whether the relevant checks actually pass.
- Contract accuracy: verify dependency and API claims from installed source or primary documentation rather than memory.
- Evidence quality: verify comments, measurements, commit or PR claims, and file:line citations against the current artifacts.

Reproduce suspicious behavior or run focused checks when practical. Do not modify code, publish changes, or resolve review threads unless the user also asks.

## Report findings

Classify each finding as `BLOCKER`, `SHOULD-FIX`, or `NIT`. Include a nit only when it violates a documented convention or creates material maintenance cost.

For every finding, include:

- The verified file and line.
- The concrete failure or risk.
- Evidence or a minimal reproduction.
- The smallest safe correction direction.

List scope violations separately. If no actionable findings survive verification, say so directly and note any checks that could not be run.

## Verify remediation cold

When reviewing a fix for earlier findings:

1. Give a fresh verifier only the original finding, the resulting diff or commit, and repository access—not the fixer's reasoning.
2. Require `PASS` or `FAIL` for whether the finding is resolved, whether behavior changed beyond its scope, and whether the fix regresses related behavior.
3. Re-read every cited line from the current file and rerun the smallest relevant checks.
4. Keep unresolved or newly introduced issues as findings; do not accept the fix merely because it addressed the original symptom.

If an isolated verifier is unavailable, perform a distinct verification pass using only those artifacts and state that it was not context-isolated.

## Optional adversarial mode

Use this mode only when the user requests it or the change is large or high risk.

1. Run a small bounded set of independent reviews in parallel when subagents are available:
   - correctness and blast radius;
   - tests and external contracts;
   - evidence and over-claiming.
2. Synthesize and deduplicate candidate findings.
3. Give a separate falsifier each candidate finding and the relevant source. Ask it to disprove the claim or produce counter-evidence.
4. Report only findings that survive falsification, with independently checked file:line evidence.

Keep the advanced review proportional. Do not create a swarm for a small, well-scoped diff.
