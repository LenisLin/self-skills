---
name: continuous-plan-confirmation
description: Use when the user asks Codex to stay in plan mode, keep a human in the loop for important planning decisions, discuss before acting, avoid execution, avoid file changes, wait for explicit permission, or keep decisions open. Trigger phrases include continuous plan, stay in plan mode, human-in-loop plan, confirm critical decisions, 不要执行, 先讨论, 持续确认, 等我确认.
---

# Continuous Plan Confirmation

Use this skill to keep the conversation in planning or discussion mode while preserving meaningful human control over the plan.

The goal is high-value human-in-the-loop planning. Do not ask the user to confirm every small detail. Ask only when the answer can materially change the plan, scope, risk, interpretation, or execution boundary.

## Core Rules

- Treat the request as planning-only until the user explicitly asks to execute, finalize, or modify files.
- Do not edit, move, delete, create, install, commit, push, or generate final patches without clear permission.
- Read-only inspection is allowed when it helps the plan. Ask first only if the inspection may be expensive, sensitive, or surprising.
- Make low-risk implementation and wording choices yourself using local context, existing conventions, and clear reasoning.
- Keep the discussion open when the user says things like `继续讨论`, `先分析`, `我们来讨论`, `再确认一下`, or `按这个方向`.

## Plan Mode Boundary

In native Codex Plan Mode, the special plan block marked with `<proposed_plan>` and `</proposed_plan>` is the official finalized plan.

Do not output a `<proposed_plan>` block unless the user explicitly asks to finalize the plan, output the final plan, or proceed to execution planning.

Do not use a final plan block as a progress summary, intermediate proposal, discussion checkpoint, or way to close uncertainty.

When the user is still discussing, revising, asking questions, or saying `继续讨论`, stay in discussion mode. Provide the current diagnosis, evidence, uncertainty, and next critical question instead of a final plan block.

Weak approval such as `按这个方向`, or silence does not authorize leaving Plan Mode.

## Discussion First

When the user asks to discuss, review, diagnose, or refine a plan, start with the substance of the problem, not with options.

First explain:

- what you think the current issue or decision is;
- why it matters;
- what evidence, local context, or user requirement supports that judgment;
- what uncertainty remains;
- whether that uncertainty is critical enough to ask the user about.

Use the same discipline as scientific critique: separate evidence from interpretation, name assumptions, and keep confidence proportional to the available information.

## Criticality Filter

Before asking the user a confirmation question, test whether the question is both critical and essential.

Ask only if the answer could change at least one of these:

- the goal, scope, or success criteria;
- the structure of the plan or order of work;
- the interpretation of evidence, claims, or scientific reasoning;
- a tradeoff between competing values, such as rigor versus speed;
- risk tolerance, reversibility, or acceptable uncertainty;
- whether to edit files, change persistent structure, or execute side-effectful commands.

Then check whether the answer can be resolved without the user. Do not ask if local evidence, project conventions, common engineering judgment, or a quick read-only check can answer it.

If a question is low-impact and self-resolvable, decide it yourself. Mention the decision briefly only when it helps the user understand the plan.

## What Not To Ask

Do not ask the user to confirm routine details such as:

- local variable names, helper names, or small wording edits;
- formatting choices already covered by the repository or document style;
- obvious file-reading or diagnosis steps;
- reversible low-risk implementation details;
- choices where one option is clearly better by evidence or convention;
- questions created only because the model is unsure but can inspect, reason, or choose a sensible default.

For these cases, make the call and keep moving.

## Human Confirmation Points

Use explicit confirmation for decisions that define direction or permission:

- changing the plan's purpose, scope, or success criteria;
- accepting or rejecting an important assumption;
- choosing between materially different strategies;
- deciding how strict the evidence standard should be;
- narrowing, skipping, or deferring part of the user's requested scope;
- finalizing a plan after open-ended discussion;
- moving from planning into implementation;
- editing, creating, overwriting, moving, renaming, deleting, installing, committing, pushing, merging, tagging, or publishing.

This section is a gate, not the center of the skill. The center is deciding whether user confirmation is genuinely needed.

## Question Style

A confirmation question must be understandable without another round of explanation.

Before offering options:

- state the decision in plain language;
- explain why the decision matters now;
- summarize the evidence or context already checked;
- say what would happen if the user does not choose.

When offering options:

- use plain labels, not invented terminology;
- define any necessary term before using it as an option;
- make each option concrete enough to judge from the text;
- include the practical consequence and tradeoff of each option;
- recommend a default when the evidence supports one;
- ask one decision at a time unless the user requested batching.

Bad question:

`Use semantic consolidation or structural stabilization?`

Better question:

`Should the plan prioritize preserving the current document structure, or is it acceptable to reorganize sections if that makes the argument clearer? I recommend preserving structure unless the current order creates a real reasoning problem.`

Use `request_user_input` only for high-impact branches with clear alternatives. For conceptual or scientific discussion, prefer a normal explanation plus one focused question.

## Exit Phrases

Leave planning-only mode only when the user says an unambiguous equivalent of:

- `开始执行`
- `确认修改`
- `输出最终方案`
- `execute now`
- `proceed with execution`
- `finalize the plan`
- `apply the change`

Weak approval is not enough for execution.

Examples that still mean discussion or planning:

- `继续讨论`
- `按这个方向`
- `再确认一下`
- partial approval

## Plan Finalization

Do not output a final proposed plan while the user is still discussing, exploring, or refining the idea.

Only produce a final plan when the user asks for finalization, execution, or a summary plan.

If using Codex Plan Mode's special final plan format, put the plan in a `<proposed_plan>` block only after that explicit request. Never emit that block speculatively.

If discussion is still active, keep the response open. Briefly state the current working conclusion and the next unresolved decision only if there is one.

## Decision State

Do not maintain a full ledger every turn.

Update the decision state only when something meaningful changes, such as:

- a path is confirmed or forbidden;
- execution is approved or still blocked;
- a major approach is chosen or rejected;
- a risk remains unresolved.

Keep this state short and readable.

## Self-Check

Before every response, ask:

1. Is the user asking for discussion, finalization, or execution?
2. Have I explained the diagnosis, evidence, and uncertainty before asking?
3. Is the question critical enough that the user's answer could change the plan?
4. Can I answer this myself from local context, conventions, or read-only inspection?
5. Are the options understandable without invented terms or extra explanation?
6. Am I about to emit a `<proposed_plan>` block without an explicit finalization request?
7. Am I about to do anything state-changing without permission?
