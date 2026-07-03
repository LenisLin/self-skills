---
name: precise-document-modification-planning
description: Use when the user asks for a precise plan before modifying documents, prompts, specs, design docs, README files, workflow docs, config docs, or other text-based project materials.
---

# Precise Document Modification Planning

Produce a concise, executable modification plan for document changes. The plan must be grounded in the existing document content, specify exact edits, reduce redundancy, and convert stable constraints or repeated procedures into clear workflows or templates.

## Core Requirements

1. Anchor every planned edit in the existing document.
   - Read the target section and nearby context before planning edits.
   - Use the current heading, paragraph, list item, table row, or anchor text to identify where the edit applies.
   - Modify existing content first when it already covers the same purpose.
   - Add new content only when the existing document has no suitable place for the intended meaning.

2. State the exact modification.
   For each planned edit, specify:
   - File path.
   - Exact location.
   - Current relevant content.
   - Planned action: replace, merge, move, split, remove, or add.
   - Target content or target structure.
   - Reason for the change.

3. Reduce redundancy and parallel instructions.
   - Merge overlapping paragraphs, repeated rules, duplicated examples, and near-equivalent workflows.
   - Keep one canonical statement for each rule, definition, or process.
   - Move supporting details under the canonical statement instead of repeating them elsewhere.
   - Preserve useful distinctions when similar text serves different purposes.

4. Prefer positive, direct constraints.
   - Describe the desired behavior directly.
   - Use exclusionary wording only when it marks a real boundary, exception, risk, or invalid case.
   - Replace broad negative instructions with affirmative requirements where possible.
   - Keep boundary conditions short and specific.

5. Use human-readable language.
   - Use short, precise sentences.
   - Prefer concrete nouns and verbs.
   - Keep each instruction focused on one action or rule.
   - Avoid dense meta-language, stacked qualifiers, and vague evaluation words.
   - Use examples only when they clarify execution.

6. Convert hard constraints and repeated procedures into workflows or templates.
   - Turn stable procedures into numbered steps, checklists, or reusable templates.
   - Include confirmation points when correctness depends on existing content, user intent, or project conventions.
   - Keep workflows compact enough to be followed during editing.
   - Separate required steps from optional cleanup.

7. Keep the plan proportional.
   - Focus on edits needed for the requested document change.
   - Mention conflicts, outdated text, or duplicates only when they affect the planned edit.
   - Avoid broad document audits unless the user explicitly asks for one.
   - Inspect additional files only when needed to resolve location, meaning, duplication, or consistency.

8. Preserve document intent and structure.
   - Keep terminology consistent with the existing document unless the plan explicitly renames it.
   - Maintain the document’s audience, level of detail, and ordering logic.
   - When replacing text, preserve useful information from the original content.
   - When removing text, explain where its useful meaning is retained or why it is obsolete.

## Workflow

1. Identify scope.
   - List the document files and sections to inspect.
   - State why each file or section is relevant.
   - Mark any context that remains unresolved.

2. Read and compare.
   - Review the target section and adjacent context.
   - Identify overlapping rules, repeated language, conflicting instructions, stale text, or unclear structure.
   - Keep only findings that affect the modification plan.

3. Build the edit plan.
   For each edit, provide:
   - `File:`
   - `Location:`
   - `Current content:`
   - `Action:`
   - `Target content / structure:`
   - `Reason:`

4. Consolidate repeated content.
   - Select the canonical location for each repeated rule or workflow.
   - State which content will be merged, moved, replaced, or removed.
   - Confirm that the resulting document has one clear source for each rule.

5. Normalize language.
   - Convert negative wording into direct positive requirements where suitable.
   - Keep necessary boundaries explicit.
   - Shorten sentences that combine multiple rules.
   - Replace vague phrasing with operational wording.

6. Solidify workflows and templates.
   - Convert repeated procedures, hard constraints, or review gates into stepwise workflows.
   - Add checklist items or template fields where they improve repeatability.
   - Place the workflow near the section where it will be used.

7. Define validation.
   - Check that every planned edit has a file path, location, action, and target result.
   - Check that repeated content has a canonical location.
   - Check that language is concise, positive where suitable, and human-readable.
   - Check that the plan changes existing content instead of adding parallel instructions.

## Output Format

Use this format unless the user requests another structure.

### Scope

- File:
- Sections to inspect:
- Reason:

### Modification Plan

1. `path/to/file`
   - Location:
   - Current content:
   - Action:
   - Target content / structure:
   - Reason:

### Consolidation Plan

- Repeated or overlapping content:
- Canonical location:
- Merge / move / replace / remove:
- Resulting single source of truth:

### Language Normalization

- Negative or exclusionary wording to revise:
- Positive target wording:
- Necessary boundary conditions:

### Workflow / Template Updates

- Constraint or repeated process:
- Target workflow or template:
- Confirmation points:

### Validation

- Required checks:
- Expected result:

### Blocking Questions

List only questions that prevent a correct edit plan.