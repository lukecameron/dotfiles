---
name: evaluate-change
description: Preregister and assess an empirical change evaluation without moving the decision bar after seeing results. Use for A/B tests, benchmarks, model or prompt comparisons, performance experiments, ablations, or any adoption decision based on measured evidence.
---

# Evaluate Change

Define what would change the decision before collecting new data. Preserve rejected and inconclusive results as carefully as successful ones.

## Preregister

Create `EVAL_PLAN.md` before running any trial. Copy and complete [assets/EVAL_PLAN.md](assets/EVAL_PLAN.md), adapting field names to the project without weakening the required decisions.

The plan must state:

- The hypothesis and a result that would falsify it.
- Control, treatment, and any planned ablations.
- Primary metric, exact formula, direction, unit, and source fields.
- Adoption threshold and the decision it controls.
- Minimum sample size and stopping rule.
- Invalid-trial and exclusion rules.
- Environment assumptions and required controls.

Resolve ambiguous metrics or thresholds with the user before execution. Once data collection begins, do not edit the registered decision bar. If the plan must change, stop, record an amendment, and treat subsequent work as a new or explicitly exploratory evaluation.

## Execute

1. Verify the metric inputs and environment before the first trial.
2. Run the registered arms under comparable conditions.
3. Record every trial, including invalid, failed, and excluded trials with the registered reason. Never silently discard an inconvenient result.
4. Recompute the primary metric from raw data using the registered formula. Check for parsing collisions, unit mistakes, duplicated fields, and accidental double counting.
5. Report uncertainty appropriate to the data and distinguish observed results from interpretation.

## Decide and preserve the result

Compare the result to the registered threshold and return one outcome:

- `ADOPT`: the registered bar was met.
- `REJECT`: the registered bar was not met or the hypothesis was falsified.
- `INCONCLUSIVE`: the run cannot support either decision under the registered rules.

Write a durable result report containing the plan, raw-data locations, exclusions, calculations, uncertainty, outcome, and limitations. For `REJECT` or `INCONCLUSIVE`, preserve the evidence in `NEGATIVE_RESULT.md` unless the repository has an established evaluation-report location.

Do not weaken the bar after seeing data, hide negative results, or turn an inconclusive run into a positive claim. Do not publish or open a pull request unless the user explicitly asks and the registered decision permits it.

## Boundaries

This skill defines the evaluation method, not a universal autonomous harness. Build project-specific runners only when the user separately requests them and the repository provides concrete data and environment interfaces.
