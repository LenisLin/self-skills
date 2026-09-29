# Analysis Script Review Checklist

Use this checklist to review biomedical analysis code for scientific clarity and minimalism.

## Scientific objective

- [ ] The script has one identifiable scientific purpose.
- [ ] Inputs, outputs, and upstream dependency are easy to identify.
- [ ] The implemented analysis matches the stated scientific question.
- [ ] Analysis-defining parameters or assumptions are visible and interpretable.

## Execution logic

- [ ] Top-level code reveals the scientific sequence directly.
- [ ] Key execution blocks have concise comments describing their scientific role.
- [ ] Multi-stage scripts use semantic sections only where they improve navigation.
- [ ] Cross-script order and real workflow branches are discoverable.
- [ ] The script does not depend on hidden interactive state.

## Functions

- [ ] Functions represent meaningful analytical or reusable operations.
- [ ] Non-trivial functions have enough documentation to use and interpret them.
- [ ] Trivial one-use wrappers do not fragment the workflow.

## Scientific minimalism

- [ ] Every filter, threshold, branch, and transformation serves the analysis design.
- [ ] No speculative validation or generic edge-case machinery has been added.
- [ ] Known method/data failure modes are handled only where scientifically relevant.
- [ ] Comments explain selected logic rather than obvious syntax or rejected alternatives.
- [ ] Logging, diagnostics, intermediate files, and plots have a declared scientific use.
- [ ] The implementation is no more complex than required to obtain the intended result.

## Repository structure

- [ ] Numbered scripts are used when a real execution order exists.
- [ ] Reusable implementation is separated only when reuse or clarity justifies it.
- [ ] README/workflow documentation is sufficient to run the analysis in the intended order.
- [ ] Results and figures are written to predictable project locations.
