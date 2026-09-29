# Scientific Analysis Script Style Guide

## 1. Scope

This guide targets biomedical research analysis code whose primary job is to expose and reproduce a scientific workflow: bioinformatics, omics, statistics, imaging, benchmarking, and figure generation.

The governing objective is not application architecture. It is a scientifically correct analysis that is easy to read, modify, rerun, and relate to the study design.

## 2. Design objective

A reader should be able to determine, with minimal navigation:

1. the scientific task;
2. the required data or upstream result;
3. the analysis sequence and analysis-defining choices;
4. the generated outputs;
5. which operations are reusable versus study-specific.

A typical script therefore reads naturally as:

```text
script header
→ imports / paths / analysis parameters
→ load inputs
→ transform / summarize
→ statistical or computational analysis
→ visualization when needed
→ export
```

The visible top-level execution order is part of the documentation. Use line-by-line analysis code rather than a `main()` wrapper.

## 3. Script header

Keep the header operational and compact. Useful fields are:

```text
Script
Purpose
Inputs
Outputs
Prerequisite
Steps (optional)
```

Explain an analysis choice only when it materially affects interpretation. For example, identify the biological replicate, the representation being summarized, or the purpose of an analysis-defining threshold.

Long methodological discussion belongs in project documentation rather than at the top of every script.

## 4. Execution-step comments

Key execution steps should be preceded by short comments that state their scientific role:

```python
# Load paired pre/post-treatment samples used in the patient-level comparison.
...

# Compute one response estimate per patient before cohort-level testing.
...

# Export the patient-level response table used by the next analysis step.
...
```

These comments should reveal why the block exists in the analysis. Do not comment every syntax line.

For longer scripts, group related steps with semantic section comments such as:

```python
# 3. Compute paired patient-level treatment responses
```

Short scripts do not need artificial section numbering when a few execution-step comments already make the workflow clear.

## 5. Function extraction

A function is useful when it captures a meaningful analytical operation, repeated logic, reusable implementation, or a block whose details would otherwise obscure the workflow.

Good abstraction:

```python
def summarize_patient_expression(cells, genes):
    """Return patient-level detection and expression summaries."""
```

Keep one-use operations such as a single file read, rename, filter, or export directly in the workflow unless abstraction adds real meaning.

For non-trivial functions, document enough to establish the scientific purpose, expected inputs, returned object, and assumptions that affect interpretation. Documentation should support use of the function rather than restate its syntax.

## 6. Scientific minimalism

Research scripts should implement the scientific design, not simulate production infrastructure.

Use the data contract already established by the project. Do not automatically add schema audits, duplicated-identifier scans, empty-result guards, generic `try/except`, fallback algorithms, retry logic, verbose logging, or defensive type/shape checks simply because they are possible.

A check or special branch belongs in the script when a concrete, known failure mode is relevant to the current dataset or method and could silently change the scientific result. Handle that condition locally and minimally.

```text
scientific requirement → implement
known method/data failure affecting result → minimal targeted handling
hypothetical misuse or unrelated edge case → omit
```

Produce the tables, models, figures, and intermediate artifacts needed by the workflow or its declared downstream steps; avoid extra audit tables and diagnostic files without a scientific use.

## 7. Comments and rationale

High-value comments explain the selected analysis logic or non-obvious method behavior:

```python
# Patient is the replicate unit for the cohort-level comparison.
```

Avoid comments that merely translate the next line into English. Also avoid long defensive passages listing methods not used, groups excluded, alternative implementations rejected, or every possible limitation. Mention such information only when necessary to understand the chosen analysis or its interpretation.

## 8. Constants, filters, and thresholds

Expose scientifically meaningful parameters with clear names when they are part of the analysis design.

```python
FDR_THRESHOLD = 0.05
```

Do not create new cutoffs solely to make code paths cleaner. When the scientific design calls for retaining a continuous quantity, record the quantity instead of inventing a threshold.

## 9. Repository organization

A practical structure is:

```text
project/
├── README.md
├── analysis/
│   ├── 01_prepare_data.py
│   ├── 02_patient_level_analysis.py
│   ├── 03_validation.py
│   └── 04_make_figures.py
├── src/
│   ├── statistics.py
│   └── plotting.py
├── configs/
├── data/
├── results/
├── figures/
└── docs/
    └── workflow.md
```

`analysis/` contains study-specific executable narratives. `src/` contains implementation that is genuinely reused. A workflow document can describe dependencies that are not obvious from numbered filenames alone.

## 10. Workflow discoverability

When a dominant order exists, numbered filenames make execution visible:

```text
01_prepare_data.py
      ↓
02_primary_analysis.py
      ├──→ 03_external_validation.py
      └──→ 04_secondary_analysis.py
                ↓
          05_make_figures.py
```

Document actual branches rather than forcing every file into a false linear chain.

## 11. Inputs, outputs, and reproducibility

Use stable project-relative paths or an existing project configuration. A reader should be able to identify the important inputs and outputs without tracing the entire implementation.

Expose reproducibility settings when they are required by the method, such as a random seed for stochastic analysis or an environment lock file for the project. Avoid adding reproducibility machinery that does not affect the actual workflow.

## 12. Practical decision rule

Before adding code, ask:

**Does this line directly implement, clarify, or reproduce the scientific analysis?**

If not, it usually does not belong in the analysis script.
