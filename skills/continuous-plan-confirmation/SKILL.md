---
name: continuous-plan-confirmation
description: Use in native Codex Plan Mode when the user wants high-efficiency human-in-the-loop pre-execution planning, continuous read-only work until real confirmation gates, request_user_input for material decisions, and no final-style closeout before explicit finalization. Trigger phrases include continuous plan, continuous plan confirmation, Consinuous plan confirmation, stay in plan mode, human-in-loop plan, confirm critical decisions, 不要执行, 不要收束, 不要总结, 继续讨论, 先讨论, 持续确认, 等我确认.
---

# Continuous Plan Confirmation

Use this skill when the user wants Codex to stay in native Plan Mode and collaborate on an execution-ready plan before any mutation.

The purpose is efficient human-in-the-loop planning before execution. Codex should keep doing useful read-only work until a real confirmation gate appears. It should not stop at ordinary intermediate observations, and it should not ask the user to decide routine details that can be resolved from repo evidence, prior decisions, or engineering judgment.

## Core Rules

- Treat the request as planning-only until the user explicitly asks to finalize, execute, modify files, or apply changes.
- Do not edit, move, delete, create, install, commit, push, or generate final patches without explicit permission.
- Read-only inspection is allowed when it improves the plan.
- Continue read-only diagnosis, comparison, and plan construction until a real gate is reached.
- Use `request_user_input` for material human decisions in native Codex Plan Mode.
- After `request_user_input` returns, continue working in the same assistant turn when more read-only planning can be done.
- Do not use a final-style closeout while the user is still discussing, refining, or confirming decisions.
- Do not output `<proposed_plan>` unless the user explicitly asks for the final plan, finalization, execution, or an equivalent.

## Native Plan Mode Work Loop

This skill is designed for native Codex Plan Mode.

Default loop:

1. Inspect and reason from local context.
2. Resolve discoverable facts without asking the user.
3. Make low-risk local decisions using repo conventions and prior user decisions.
4. Continue working while only read-only planning remains.
5. Pause only at a real confirmation, mutation, execution, or finalization gate.
6. If a material human decision is required, explain the gate and call `request_user_input`.
7. After the tool returns, incorporate the answer and continue the loop.

Do not convert ordinary intermediate reasoning into an assistant-turn boundary.

## Gates

A gate is a reason to pause continuous read-only work.

### Human Confirmation Gate

Use `request_user_input` when different user choices would change at least one of:

- goal, scope, success criteria, or authority status
- document structure, file boundaries, or artifact placement
- scientific claim strength, evidence standard, or uncertainty tolerance
- whether content is retained, moved, archived, deleted, or rewritten
- whether planning moves into mutation or execution
- tradeoffs between rigor, speed, readability, maintainability, and reversibility

Before calling `request_user_input`, explain:

- what has already been resolved without asking the user
- what decision remains
- why the decision is genuinely user-owned
- how the available choices would change the plan

Then present 2-4 meaningful options. Each option must state the practical consequence. Recommend a default only when evidence supports it.

### Mutation Or Execution Gate

Pause before any action that would change persistent state or execute the plan, including:

- editing, creating, deleting, moving, or renaming files
- installing dependencies
- running code generation, migrations, or formatters that rewrite files
- committing, pushing, merging, tagging, or publishing
- starting runtime work that the user has not authorized

### Finalization Gate

Only produce a final plan when the user explicitly asks for it, for example:

- `输出最终方案`
- `finalize the plan`
- `开始执行`
- `execute now`
- `确认修改`
- `apply the change`

Weak approval such as `按这个方向`, `继续`, `再确认一下`, or silence is not finalization permission.

## What Is Not A Gate

Do not ask the user to confirm:

- routine wording and formatting
- local section names when the document purpose already implies them
- file-reading or search steps
- low-risk reversible implementation details
- choices answerable from current repo state
- questions caused only by model uncertainty when read-only inspection can resolve them

For these cases, decide locally and keep working.

## Multiple Confirmations In One Turn

A single assistant turn may contain multiple `request_user_input` calls if each one corresponds to a new material gate discovered after continuing read-only work.

Do not batch unrelated decisions just to reduce tool calls. Do not split one decision into multiple confirmations. After each returned answer, incorporate the decision and continue until the next real gate or until the user explicitly requests finalization.

## Forbidden Behaviors In Open Planning

When this skill is active and the user has not explicitly requested finalization, do not:

- send a final-style closeout
- output `<proposed_plan>`
- end with only `Next confirmation point`
- ask a plain-text question when `request_user_input` can represent the gate
- provide a complete recommendation and attach a token confirmation sentence at the end
- stop only to report an intermediate observation when more read-only planning can continue
- ask the user to invent the option set for a material decision

Bad:

`My recommendation is X. Next confirmation point: should we do X?`

Better:

Explain what is already resolved, identify the remaining material gate, call `request_user_input`, then continue working after the answer returns.

## Decision State

Keep decision state short. Update it only when something material changes, such as:

- a path is confirmed or forbidden
- execution remains blocked or becomes authorized
- a major approach is selected or rejected
- a risk remains unresolved

Prefer current on-disk state and local evidence over long chat summaries.

## Self-Check

Before every response or confirmation tool call, check:

1. Am I still in planning mode?
2. Can I keep doing useful read-only work instead of responding now?
3. Is there a real gate, or am I about to stop at an intermediate observation?
4. Is the remaining decision genuinely user-owned?
5. Have I explained enough for the user to choose?
6. Should this be `request_user_input` instead of a plain-text question?
7. Am I about to mutate files or execute without permission?
8. Am I about to output `<proposed_plan>` without explicit finalization?
9. Would this response read as complete if the last confirmation sentence were removed?
10. After a user choice returns, can I continue same-turn planning before responding?
