# Planning Workflow

Use this workflow for multi-file changes, content consolidation, and fixed procedures.

1. Read the target files and the directly related files that define, repeat, test, generate, or consume the same content.
2. Record the current owner, exact location, and meaning of each relevant item.
3. Group items that express the same rule, data contract, workflow, or interface.
4. Select one canonical location for each group. Preserve the complete active meaning there and align related files through concise references or compatible summaries.
5. Build a change inventory for every edited unit: current file line range and full text or continuous range excerpt, final file line range and complete target text, current role, retained meaning, detailed transformation, target structure, and contract effect.
6. Review the complete plan for scientific rigor, redundancy, conflicts, and engineering quality. Record each finding and the corresponding plan revision.
7. Express each fixed requirement as an ordered action with an observable confirmation point.
8. Confirm that the plan covers the requested scope and gives each active rule one owner with one clear instruction.

## Fixed-Procedure Template

Use this structure when the target document defines a required process:

```markdown
### <Procedure name>

1. <Action>
   - Confirm: <observable state or artifact>
2. <Action>
   - Confirm: <observable state or artifact>
3. <Action>
   - Confirm: <observable state or artifact>
```

Each confirmation point should identify a concrete file state, command result, review outcome, or generated artifact.
