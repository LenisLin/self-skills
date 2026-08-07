---
name: precise-project-modification-planning
description: Use when the user asks for a precise plan before editing documents, code, prompts, specs, README files, workflow docs, config docs, APIs, or other project text.
---

# Precise Modification Planning

Create concise, source-grounded plans before changing project text or code. Write in the user's requested language; otherwise, use the language of the request.

## Core Requirements

1. Read each target file and its relevant local context before planning. Identify the current heading, paragraph, list item, symbol, function, configuration key, or test that carries the requested meaning.
2. Map every edit to an exact file and line range. Give `Current text` as `path:Lx-Ly` plus the full existing text or a continuous range excerpt from its first line or sentence through `...` to its last line or sentence. Give `Target text` as the final `path:Lx-Ly` plus the complete replacement text.
3. Identify each changed unit, its current role, detailed transformation, retained meaning, contract effect, and target structure. For code, state the control flow, data changes, error handling, interfaces, and required comments or docstrings.
4. Complete a scientific-rigor, redundancy, conflict, and engineering review of the plan. Record the review result and the revisions it produces.
5. Consolidate repeated or conflicting material into one canonical location. State the owner, the preserved meaning, and the updates that align related files with it.
6. Write short, precise, reader-oriented text. Express required behavior directly. Describe exceptions only where they define an active boundary, invalid case, or compatibility requirement.
7. Turn hard constraints and fixed procedures into numbered, confirmable steps or a reusable workflow template.

Ask a focused blocking question when the target state requires a user decision that the available project context cannot establish.

## Progressive References

Read only the reference needed for the task:

- Read [references/planning-workflow.md](references/planning-workflow.md) for plans with multiple files, consolidation, or a hard process requirement.
- Read [references/code-planning.md](references/code-planning.md) when the plan changes code, tests, scripts, APIs, or configuration behavior.
- Read [references/plan-template.md](references/plan-template.md) when the user has not supplied a required output format.
