---
name: analysis-script-style
description: Write and review biomedical data-analysis scripts as concise, readable, sequential scientific workflows.
---

# Analysis Script Style

Use this skill for biomedical and scientific data-analysis code, including
bioinformatics, omics, imaging, statistics, benchmarking, and figure generation.

## Core principle

Analysis scripts should read as executable scientific narratives.
Implement the shortest clear workflow that correctly answers the scientific question.
Use line-by-line top-level analysis code; no `main()` wrapper is needed.

## Required structure

1. Start with a compact header stating:
   - purpose / scientific question
   - required inputs
   - main outputs
   - upstream dependency when relevant
   - major steps only when they are not obvious from the code
2. Keep scientific workflow steps at top level and in execution order.
3. Add concise comments before key execution steps so the scientific progression is clear.
4. For non-trivial or multi-stage scripts, group related steps with semantic section comments.
5. Extract functions when they represent reusable, repeated, or conceptually distinct
   analytical operations, or when extraction materially improves readability.
6. Give non-trivial functions enough documentation to understand their scientific
   purpose, inputs, returned object, and analysis-defining assumptions.
7. Prefer numbered filenames (`01_`, `02_`, `03_`) when scripts form a workflow.
8. Make cross-script order and dependencies discoverable in README/workflow docs.

## Scientific minimalism

- Prefer direct library/dataframe operations over extra wrappers or infrastructure.
- Use the project's declared data contract directly; do not add speculative validation,
  audit passes, generic edge-case handling, or defensive fallback branches.
- Handle a failure condition only when it is known, relevant to the current data or
  method, and capable of changing the scientific result.
- Keep comments focused on the chosen scientific logic and non-obvious method behavior.
- Avoid narrating rejected alternatives, exclusions, or obvious syntax unless needed
  to interpret the analysis.
- Do not introduce thresholds, filters, checks, logging, abstractions, or outputs that
  are not needed for the stated scientific objective.

## Preferred repository split

- `analysis/` or `scripts/`: executable scientific workflows
- `src/`, `lib/`, or `utils/`: genuinely reusable implementation code
- `docs/` or `references/`: workflow rationale and deeper methodological notes

## Progressive references

Read `references/style-guide.md` for detailed guidance and repository organization.
Read `references/review-checklist.md` when reviewing existing analysis code.
Use `examples/python_analysis.py` and `examples/r_analysis.R` as minimal templates.
