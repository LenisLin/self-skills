---
name: continuous-plan-confirmation
description: Use when the user asks Codex to stay in plan mode, keep confirming decisions, avoid execution, avoid file changes, or wait for explicit permission. Trigger phrases include continuous plan, stay in plan mode, confirm everything, do not execute, wait for confirmation, ctrl+p plan mode, 持续 plan, 持续确认, 不要执行, 直到我要求输出.
---

# Continuous Plan Confirmation

Keep Codex in a confirmation loop. This skill does not authorize edits, moves, deletes, installs, commits, codegen, final patches, or other state-changing work.

## Core Rules

- Treat the user's request as planning-only until an explicit exit phrase appears.
- In Codex, `final` ends the turn. Do not use `final` for intermediate plans, progress summaries, or confirmation questions.
- In native Codex Plan mode, ask material confirmations with `request_user_input`.
- If `request_user_input` is unavailable, ask in the non-final conversation channel and state that the plan remains open.
- Read-only inspection is allowed only when it improves the plan; ask first if it may be expensive, sensitive, or surprising.

## Exit Phrases

Leave the loop only for an unambiguous equivalent of:

- `开始执行`
- `按你的建议执行`
- `输出最终方案`
- `不再确认，直接完成`
- `execute now`
- `proceed with execution`
- `finalize the plan`

`ok`, `looks good`, `继续讨论`, `再确认一下`, `按这个方向`, silence, or partial approval means continue planning, not execution and not `final`.

## Mandatory Pauses

Pause before any step involving:

- file creation, overwrite, move, rename, deletion, install, commit, push, or patch generation
- uncertain source or destination paths
- multiple viable implementation routes
- missing files, unexpected repo state, failed commands, unclear dependencies, or conflicting requirements
- skipping, deferring, or narrowing any part of the user's request
- transition from analysis/planning into implementation

## Confirmation Shape

Each confirmation must include:

- 2-4 realistic options
- a recommended default
- the tradeoff or risk for each option
- a custom-option path
- one decision per prompt unless the user asked for batching

Maintain a short ledger every turn:

- confirmed paths and forbidden paths
- allowed read-only checks
- chosen approach and rejected alternatives
- open risks and questions

## Self-Check

Before every response, ask:

1. Did the user explicitly request execution or finalization?
2. Would `final` close the loop prematurely?
3. Should this confirmation use `request_user_input`?
4. Did I preserve the decision ledger?

If 1 is no and 2 is yes, do not send `final`; continue confirming.
