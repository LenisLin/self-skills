---
name: precise-project-modification-planning
description: Use when the user asks for a precise plan before editing documents, code, prompts, specs, README files, workflow docs, config docs, APIs, or other project text.
---

# Precise Project Modification Planning

## Purpose

Create concise, file-grounded modification plans before changing project text or code. Write every modification plan in English, even when the user's request is in another language.

A useful plan states the write location, the existing content, the target result, and the validation step for each edit. It favors modifying existing content over adding parallel instructions.

## Required Workflow

1. Read the target file and nearby context.
2. Identify existing headings, paragraphs, list items, table rows, symbols, imports, exports, config keys, tests, or conversation-confirmed freeze points that carry the requested meaning.
3. Anchor each planned edit to an exact file path and stable location.
4. For each edit, state the current content, action, target content or structure, reason, and validation.
5. When target content contains several hard constraints or confirmed freeze points, plan to rewrite that content as numbered steps, a checklist, confirmation points, or a reusable template.
6. Merge or remove overlapping content after preserving useful meaning in one canonical location.
7. Use short, concrete, positive language. Use exclusionary wording for real boundaries, invalid cases, compatibility risks, or necessary exceptions.
8. Ask only blocking questions that cannot be answered from local context.

When reviewing an existing plan, apply the same workflow and return only the revisions needed to make the plan executable.

## Plan Output Template

Use this English template unless the user requests a stricter structure.

```markdown
## Modification Plan

### Edit 1: <short name>
- File:
- Location:
- Current content:
- Action:
- Target content / structure:
- Reason:
- Validation:

### Consolidation Check
- Repeated or conflicting content:
- Canonical location:
- Content to merge, replace, or remove:

### Blocking Questions
- None / <question>
```

Add more `Edit N` blocks only when separate write locations or target outcomes are required.

## Code Change Addendum

Use this addendum only when the planned change touches code.

For code plans, add these fields inside each affected `Edit N` block:

- Comments / docstrings to add:
- Compatibility impact:

- Script headers should document purpose, expected inputs, produced outputs, main side effects, and required assumptions.
- Public functions and classes should document purpose, parameters, returns, raised errors when relevant, and domain assumptions when relevant.
- Key variables should have short comments when they encode units, shapes, axes, coordinate systems, metadata keys, thresholds, or non-obvious choices.
- API-affecting changes should include one compatibility classification: `Internal-only change`, `Stable API, implementation cleanup`, `Public API change with migration path`, or `Behavior change requiring justification`.

## Validation Before Final Plan

Before giving the final plan, confirm that it:

1. Is written in English.
2. Names every file to edit.
3. Anchors every edit to existing content or explains why new content is needed.
4. Gives a concrete target result for every edit.
5. Identifies duplicate or conflicting content and the canonical location.
6. Includes validation steps that check the changed file behavior or document contract.
