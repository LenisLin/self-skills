---
name: continuous-plan-confirmation
description: Use in native Codex Plan Mode when the user requests continuous planning discussion, human-in-the-loop confirmation, no premature final plan, no premature proposed_plan, or uses phrases such as stay in plan mode, continue discussing, 等我确认, 不要收束, 不要总结.
---

# Continuous Plan Confirmation

Use this skill only in native Codex Plan Mode. When active, Codex stays in Open Planning until the user explicitly asks to end continuous discussion and produce a final plan.

The core behavior is simple: keep planning, avoid premature closeout, and ask the user only for decisions that are genuinely user-owned.

## Open Planning State

When this skill is active, default to Open Planning.

In Open Planning:

- Continue useful read-only inspection, diagnosis, comparison, and plan refinement.
- Do not edit, create, delete, move, install, commit, push, or otherwise mutate persistent state.
- Do not output `<final>`, `<proposed_plan>`, or a user-visible final-plan/closeout response.
- Treat weak continuation or execution-like phrases as insufficient to exit Open Planning.
- Pause only for a genuine human decision, mutation boundary, or explicit exit request.

## Decision Check Before Asking

Before asking the user, check whether the decision is genuinely user-owned.

Ask only when the choice changes goal, scope, success criteria, file or artifact boundaries, irreversible state, risk tolerance, claim strength, or execution authority.

Do not ask when the answer can be resolved from repo evidence, prior user preferences, local conventions, engineering judgment, or more read-only inspection. Decide these locally and keep planning.

When asking, use `request_user_input` with 2-4 meaningful options. Explain what is already known, what remains undecided, and how each option changes the plan.

## Mutation Boundary

Open Planning permits read-only work only. Stop before any file edit, dependency install, formatter or codegen rewrite, migration, commit, push, publish, or runtime action that carries out the plan.

If the user asks to execute, treat it as an execution boundary, not as permission to produce `<proposed_plan>` unless they also explicitly ask to end continuous planning.

## Allowed Exit Conditions

Exit Open Planning only when the user explicitly asks to end continuous discussion or produce the final plan, for example:

- `输出最终方案`
- `结束持续讨论`
- `生成 proposed_plan`
- `finalize the plan`
- `produce the final plan`

Do not treat these as exit permission by themselves: `继续`, `按这个方向`, `再确认一下`, `开始执行`, `execute now`, `确认修改`, `apply the change`.

## Open Planning Response Rules

While still in Open Planning, do not write a response that reads like completion. Avoid final summaries, handoff-style endings, or token confirmation lines such as `ready to proceed`.

If a response is needed, make it an active planning update, a genuine `request_user_input` decision, or a statement of the next read-only planning work.

## Decision State

Track only material decisions: confirmed paths, forbidden approaches, selected or rejected strategies, execution authority, and unresolved risks. Prefer current repo evidence over long chat summaries.

## Self-Check

Before responding or asking:

1. Am I still in Open Planning?
2. Can read-only work resolve this without the user?
3. Is this decision genuinely user-owned?
4. Am I about to mutate persistent state?
5. Am I about to produce `<final>`, `<proposed_plan>`, or a final-style closeout without an explicit exit request?
