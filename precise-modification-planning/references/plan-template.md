# Modification Plan Template

Use this structure unless the user supplies another format. Include only sections that apply.

```markdown
## Modification Plan

### Edit 1: <short name>
- File: <path>
- Location: <heading, symbol, key, test, or stable local anchor>
- Changed unit: <the precise heading, paragraph, list item, table row, symbol, key, test, or generated artifact>
- Current text: `<path:Lx-Ly>` `<full existing text; or, for one continuous long range, first line or sentence ... last line or sentence>`
- Target text: `<path:Lx-Ly after the planned edits>` `<complete target text for the changed unit>`
- Current role: <meaning or behavior carried by the current text>
- Detailed changes:
  1. Preserve: <meaning or content that remains active>
  2. Revise: <current wording or behavior> -> <target wording or behavior>
  3. Add: <new content, behavior, or field>
  4. Relocate: <source> -> <destination>
  5. Retire: <content or behavior and its preserved successor, when applicable>
- Target structure: <target headings, paragraphs, tables, workflow steps, or code control flow and data path>
- Contract and impact: <owner, consumers, interface, compatibility, or generated output affected>
- Code units and locations: <script header, function/class, variable, test, or configuration key, when applicable>
- Comments / docstrings: <exact documentation to add or revise, when applicable>
- Interface classification: <when applicable>

### Consolidation Check
- Related repeated or conflicting content: <locations and the meaning each carries>
- Canonical location: <path and location>
- Preserved meaning: <content that remains active at the canonical location>
- Alignment changes: <specific merge, reference, relocation, or retirement for each related location>

### Plan Review
- Scientific rigor: <evidence, terms, units, assumptions, methods, and reproducibility check>
- Redundancy: <single-owner and repeated-content check>
- Conflicts: <cross-file contract, interface, terminology, and process check>
- Engineering: <code, workflow, template, error-path, maintainability, and test-coverage check>
- Revisions from review: <specific plan changes, or no change with reason>

### Blocking Questions
- None / <question that requires a user decision>
```

Use a separate `Edit N` section for each distinct write location or target outcome. Keep only the actions that apply from `Preserve`, `Revise`, `Add`, `Relocate`, and `Retire`; state each applicable action with concrete content. A continuous current-text excerpt starts at the first line or sentence, uses `...` for omitted middle text, and ends at the last line or sentence; its line range defines the complete scope. Target text always contains the full final content of the changed unit. Target line ranges refer to the complete file after earlier planned edits in that file. For new content, give the adjacent current line and the final target line. For retired content, give the successor target line and its exact text. For a new file, identify its parent directory, target structure, and the related owner that establishes its purpose.
