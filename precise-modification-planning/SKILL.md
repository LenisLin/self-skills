---
name: precise-project-modification-planning
description: Use when the user asks for a precise plan or review before modifying documents, code, prompts, specs, README files, workflow docs, config docs, package APIs, migration plans, cleanup plans, or other text-based project materials.
---

# Precise Project Modification Planning

Produce a concise, executable modification plan for document or code changes. The plan must be grounded in the existing files, identify exact write locations, state what will change, define the target result, reduce redundancy, and preserve project semantics.

Use this skill when the user asks for a plan, review, migration check, cleanup plan, or precise edit proposal before making changes.

## Core Requirements

1. Ground every edit in existing content.

   - Inspect the target file and nearby context before planning edits.
   - Identify each edit by exact file path and stable location.
   - For documents, use headings, paragraphs, list items, table rows, or anchor text.
   - For code, use modules, classes, functions, methods, imports, exports, tests, config keys, or symbol names.
   - Modify existing content first when it already covers the same purpose.
   - Add new content only when no existing location can carry the intended meaning cleanly.

2. Make every edit patch-grade specific.

   For each planned edit, provide:

   - `File:`
   - `Location:`
   - `Current content:`
   - `Action:` replace, merge, move, split, remove, add, rename, refactor, document, test, or deprecate.
   - `Target content / structure:`
   - `Reason:`
   - `Validation:`

   The target result must be specific enough that another editor can apply it without guessing.

3. Reduce redundancy and conflict.

   - Keep one canonical place for each rule, workflow, function, definition, API behavior, or project convention.
   - Merge overlapping content into the canonical location.
   - Remove or replace parallel statements after their useful meaning is retained.
   - Preserve separate content only when it has a distinct purpose, audience, behavior, or domain meaning.
   - State where removed content is retained or why it is obsolete.

4. Use short, precise, human-readable language.

   - Use concrete nouns and verbs.
   - Keep each sentence focused on one action or rule.
   - Prefer direct positive requirements.
   - Use exclusionary wording only for real boundaries, invalid cases, compatibility risks, or necessary exceptions.
   - Replace vague wording with operational wording.
   - Use examples only when they clarify execution.

5. Convert hard constraints into workflows or templates.

   Turn stable or repeated procedures into:

   - Numbered steps.
   - Checklists.
   - Review gates.
   - Tables.
   - Reusable templates.

   Each workflow should include required steps, confirmation points, expected output, and validation checks. Separate required work from optional cleanup.

6. Handle code changes explicitly.

   For code edits, identify affected:

   - Modules.
   - Classes, functions, methods, or scripts.
   - Current and target signatures.
   - Imports and exports.
   - Public APIs.
   - Tests.
   - Documentation.
   - Examples.
   - Compatibility impact.

   Classify compatibility as one of:

   - `Internal-only change`
   - `Stable API, implementation cleanup`
   - `Public API rename with migration path`
   - `Deprecated wrapper retained`
   - `Duplicate removed`
   - `Behavior change requiring explicit justification`

7. Add sufficient code comments and docstrings.

   For code plans, specify comments or docstrings to add or update.

   Script headers should state:

   - Purpose.
   - Expected inputs.
   - Produced outputs.
   - Main side effects.
   - Required assumptions.

   Public functions and classes should document:

   - Purpose.
   - Parameters.
   - Returns.
   - Raised errors when relevant.
   - Domain meaning when relevant.
   - Shape, unit, coordinate, layer, key, or metadata assumptions when relevant.

   Key variables should have short comments when they encode domain assumptions, units, shapes, axes, coordinate systems, metadata keys, thresholds, or non-obvious algorithm choices.

   Comments should explain intent, meaning, and assumptions. Obvious operations should remain uncluttered.

8. Preserve semantics and flexibility.

   For domain, scientific, analysis, or package API changes, confirm:

   - Input object type and required fields.
   - Output object type and produced fields.
   - Units, shapes, axes, coordinates, indexes, metadata keys, and data layers.
   - Defaults and override points.
   - User-facing API meaning.
   - Statistical, mathematical, scientific, or project-specific assumptions.

   Keep tools flexible:

   - Separate validation, transformation, modeling, plotting, export, and I/O when they represent different user decisions.
   - Use explicit parameters for thresholds, keys, methods, modes, and output destinations.
   - Keep defaults documented and overrideable.
   - Return stable, predictable objects.
   - Use thin convenience wrappers around reusable core functions when needed.

   Merge functions only when they have the same purpose, input assumptions, output contract, and domain meaning.

## Workflow

1. Identify scope.

   - List files, sections, symbols, tests, docs, configs, and examples to inspect.
   - State why each item matters.
   - Mark unresolved context that affects correctness.

2. Read and anchor existing content.

   - Inspect the target location and adjacent context.
   - Identify existing content that already carries the requested meaning.
   - Identify duplicates, conflicts, stale content, or unclear structure.
   - Record stable anchors for planned edits.

3. Compare behavior when migrating, merging, removing, or refactoring.

   Confirm source and target behavior, input assumptions, output contract, domain meaning, defaults, override points, API effect, and test coverage.

4. Build the modification plan.

   For each edit, specify file, location, current content, action, target result, reason, and validation.

5. Consolidate repeated content.

   Select the canonical location, merge useful details, and remove parallel content.

6. Normalize language.

   Use short, direct, positive wording. Keep necessary boundaries explicit.

7. Define validation.

   Check that every edit has a file path, exact location, target result, and validation step. Confirm that the plan modifies existing content before adding parallel instructions.

## Output Format

Use this format unless the user requests another structure.

### Scope

- Files / sections / symbols to inspect:
- Reason:
- Unresolved context:

### Existing Content Anchors

- File:
- Location:
- Current content:
- Existing meaning:
- Why this anchor matters:

### Plan Review

Use this section when the user provides an existing migration, cleanup, or modification plan.

- Proposed change:
- Current source behavior:
- Current target behavior:
- Semantic correctness:
- Flexibility impact:
- Duplication impact:
- Readability impact:
- API / compatibility impact:
- Tests / docs impact:
- Decision:
- Required revision:

### Modification Plan

1. `path/to/file`
   - Location:
   - Current content:
   - Action:
   - Target content / structure:
   - Reason:
   - Validation:

For code edits, include when relevant:

   - Current signature:
   - Target signature:
   - Imports / exports affected:
   - Tests affected:
   - Docs affected:
   - Comments / docstrings to add:
   - Compatibility impact:

### Consolidation Plan

- Repeated or overlapping content:
- Canonical location:
- Merge / move / replace / remove:
- Resulting single source of truth:

### Workflow / Template Updates

- Constraint or repeated process:
- Target workflow or template:
- Required confirmation points:
- Optional cleanup:

### Semantic and Flexibility Review

Use this section for code, analysis, API, scientific, or domain-specific changes.

- Meaning to preserve:
- Input assumptions:
- Output contract:
- Units / axes / shapes / keys:
- Defaults and override points:
- Functions to merge:
- Functions to keep separate:
- Flexibility risks:
- Required tests or checks:

### Validation

- Required checks:
- Expected result:

### Blocking Questions

List only questions that prevent a correct edit plan. If there are none, write `None`.