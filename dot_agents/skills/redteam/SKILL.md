---
name: redteam
description: "Red-team a piece of work: a subagent named @redteamer hunts for counterexamples that break it, proven against a golden harness or oracle where one exists, and the caller triages them, locks the valid ones in as deterministic tests and fixes them. Use for /redteam, 'red-team this', or 'try to break it'."
disable-model-invocation: true
---

# Red team

Two roles test one piece of work: a change, a PR, a function or a feature. **@redteamer** tries to break it. **The triager** (you, the caller, unless you hand it to someone else) decides which breaks count, turns each one into a deterministic test, and fixes it. They are kept apart on purpose: the agent that built the thing is the worst judge of where it breaks, and an attacker who also decides what counts will either find nothing or find everything.

`$ARGUMENTS`, if present, names the work under test and anything known about it.

## Frame the target

Before starting @redteamer, write down:
- **The work under test:** the diff, PR or files, and what it claims to do.
- **The oracle:** what decides right from wrong without anyone's opinion. Look for one before anything else: a golden harness, an existing oracle such as a reference calculator, sheet or spec table, a property that must hold (round-trip, idempotence, an invariant between two outputs), or a second implementation to compare with. Name where it lives and how to run it.
- **Out of bounds:** what @redteamer must not touch (production, shared environments, other people's branches) and how much it may spend.

## @redteamer

Start it as a background subagent with `name: "redteamer"` (a later round gets `redteamer-2`, `redteamer-3`, because a name two subagents have held no longer addresses either). Where the Agent tool offers no `name`, lead its description with "redteamer". Brief it with the frame above and these rules:

- **Find inputs that break the claim.** Read the change and what it touches, then hunt: boundaries, empty and extreme values, the cases the change's tests skip, interactions with code the change didn't touch, ordering and repeat calls, states a real user can reach.
- **Prove each break against the oracle, not its own judgement.** A counterexample is an input, the output the work gives, and the output the oracle gives, with the command that shows both. Where no oracle covers the case, it may still report the break, marked **judgement only**, with its reasoning. Those count for less.
- **Don't fix anything or edit the work under test.** It may write throwaway scripts and scratch tests in its scratchpad to find and prove breaks.
- **Report each counterexample** as: the input, expected (from the oracle) against actual, how to reproduce it, how a user would reach it, and whether it's oracle-proven or judgement only. Rank them by how likely a real user is to hit them. Report "no breaks found" plainly if that's the result, with what it tried.

## Triage

Read every counterexample yourself and reproduce it before believing it. Then judge each one:
- **Reachable:** can a real user, or real data, exercise this? An input no caller can produce isn't a defect in this work.
- **In scope:** is it caused by, or exposed by, the change under test? A real defect elsewhere is noted, not fixed here.
- **Solvable:** can the work be made right for it, or is the expected answer itself unsettled (the oracle disagrees with the spec, or the policy doesn't say)? An unsettled one goes to whoever owns the answer, as a question.
- **Oracle-proven or judgement only:** a judgement-only break needs your own reasoning to stand before it counts.

## Lock in and fix

For each counterexample that is reachable, in scope and solvable:
1. Add a deterministic test that fails on it, where it belongs: a case in the golden harness when it's an input-to-output check the harness covers, otherwise a unit or integration test beside the code. Run it and confirm it fails for the reason found.
2. Fix the defect, the root cause and not the symptom, and confirm the test passes along with the rest of the suite.
3. Commit the test before or with the fix, so the history shows it failing first where the repository's workflow allows.

In a repository with an implementation or revision skill (`/sl-ship`, `/sl-revise` in slate), the fixes go through that skill.

## Rounds

After the fixes land, a fresh @redteamer (`redteamer-2`) attacks the fixed work, briefed with what round 1 found and how each was fixed, so it doesn't repeat itself. Stop when a round finds nothing reachable, in scope and solvable, or after three rounds, and say which.

## Report

A table of every counterexample across the rounds: what it was, oracle-proven or judgement only, the verdict (fixed, out of scope, not reachable, unsettled) with the reason, and for each fixed one the test that now covers it. Then what remains: the unsettled questions and who owns them, and the out-of-scope defects. Don't file tickets for those; list them and ask.
