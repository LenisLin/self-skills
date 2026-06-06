---
name: continuous-plan-confirmation
description: Use in native Codex Plan Mode when the user requests continued planning discussion, human-in-the-loop confirmation, deferred final plan/proposed_plan, or uses phrases such as stay in plan mode, continue discussing, wait for my confirmation, keep planning, do not summarize yet.
---

# Continuous Plan Confirmation

Use this skill only in native Codex Plan Mode. When active, Codex stays in Open Planning and keeps the current turn in a working/planning state.

The core behavior is simple: keep planning, continue useful read-only work, and ask only when the next step genuinely requires human confirmation or a user-owned decision.

## Non-Terminal Turn Invariant

Once this skill has been invoked in a Plan Mode turn, that turn remains non-terminal.

When no human confirmation is required, Codex continues the next read-only planning step without asking.

In the same turn where this skill is active:

- Do not output `<final>`, `<proposed_plan>`, or any substitute final-plan response.
- Keep responses shaped as active planning updates, concrete next read-only work, or genuine user-owned decisions.
- Treat an explicit user exit request as a transition boundary to confirm for a later turn.
- Reserve questions for real decisions, human double-checks, mutation boundaries, or exit boundaries.
- If a human decision is required, ask an active planning question, preferably via `request_user_input` when available.
- If no human decision is required, continue read-only planning work.
- Keep the assistant state actively working/planning.

If the user asks for a final plan, `proposed_plan`, or execution while this skill is active, acknowledge the boundary and ask a confirmation question for a later-turn transition.

## Open Planning State

When this skill is active, default to Open Planning.

In Open Planning:

- Continue useful read-only inspection, diagnosis, comparison, and plan refinement.
- Keep all work read-only: inspect, compare, reason, refine, and document planning state.
- Do not output `<final>`, `<proposed_plan>`, or a user-visible final-plan/closeout response.
- Treat weak continuation or execution-like phrases as signals to keep planning.
- Keep moving through available read-only work until a genuine human decision, human double-check, mutation boundary, or explicit exit request is reached.

## Decision Check Before Asking

Before asking the user, check whether the decision is genuinely user-owned.

Ask only when the choice changes goal, scope, success criteria, file or artifact boundaries, irreversible state, risk tolerance, claim strength, or execution authority.

Resolve questions locally when repo evidence, prior user preferences, local conventions, engineering judgment, or more read-only inspection can answer them. Then continue the next read-only planning step.

When asking, use `request_user_input` with 2-4 meaningful options when available. Explain what is already known, what remains undecided, and how each option changes the plan. If `request_user_input` is unavailable, ask a concise plain-text question instead.

## Continue-vs-Ask Rule

Before asking anything, classify the next step:

- Continue if more read-only evidence gathering, analysis, comparison, or plan refinement can reduce uncertainty without changing user-owned goals or authority.
- Continue means perform or announce the next concrete read-only planning action.
- Ask if the choice changes goal, scope, success criteria, file or artifact boundaries, irreversible state, risk tolerance, claim strength, or execution authority.
- Ask if the user explicitly requests human double-check, confirmation, review before proceeding, or sign-off.
- Ask at mutation and exit boundaries because Plan Mode handles those as future-mode transitions while this skill remains active.

Questions must name the concrete decision being delegated to the user. Use generic keepalive questions such as "should I continue?", "does this look okay?", or "what next?" only when the user has explicitly asked for that kind of checkpoint.

If no useful read-only work remains, treat that as an exit boundary and ask whether the user wants a later turn to disable continuous planning and produce the final plan.

## Mutation Boundary

Open Planning permits read-only work only. At a file edit, dependency install, formatter or codegen rewrite, migration, commit, push, publish, or runtime action that carries out the plan, pause at the boundary and ask for the appropriate future-mode confirmation.

If the user asks to execute, treat it as an execution boundary requiring future-mode confirmation; produce `<proposed_plan>` only in a later turn where continuous planning has been explicitly disabled.

## Exit Requests

Keep Open Planning active throughout the same turn where this skill is active.

Treat explicit exit phrases as requests to confirm a future transition, not as permission to output `<final>` or `<proposed_plan>` immediately. Examples:

- `finalize the plan`
- `produce the final plan`
- `output the final plan`
- `end continuous planning`
- `generate proposed_plan`

For these phrases, ask a confirmation question such as whether the user wants to disable continuous planning and produce the final plan in a later turn. This is a genuine question because it changes the assistant's authority and terminal-output behavior.

Treat these as continuing-planning or boundary signals rather than exit permission: `continue`, `go in this direction`, `double-check this`, `start executing`, `execute now`, `confirm the change`, `apply the change`.

## Open Planning Response Rules

While still in Open Planning, write responses as active planning updates, boundary confirmations, or concrete read-only next steps.

If a response is needed and no user-owned decision is pending, make it an active planning update that states the next read-only planning work. If a user-owned decision is pending, ask a genuine `request_user_input` decision or concise question.

Use "no question is needed" as a reason to keep doing read-only planning work, not as a reason to produce `<final>`, `<proposed_plan>`, or a final-style answer.

## Decision State

Track only material decisions: confirmed paths, forbidden approaches, selected or rejected strategies, execution authority, and unresolved risks. Prefer current repo evidence over long chat summaries.

## Self-Check

Before responding or asking:

1. Am I still in Open Planning?
2. Can read-only work resolve this without the user?
3. Is this decision genuinely user-owned?
4. Am I at a mutation boundary?
5. Am I about to produce `<final>`, `<proposed_plan>`, or a final-style closeout in the same turn where this skill is active?
6. Is this question tied to a user decision, human double-check, mutation boundary, or exit boundary?
7. If no question is needed, what read-only planning work should I continue next?
8. Am I treating "no human confirmation needed" as a signal to continue planning rather than finish?
