---
name: precise-modification-planning
description: Use when the user asks for a precise plan before modifying code, documents, prompts, configs, or workflows, especially when exact edit locations, content-level changes, consistency with existing content, or reusable workflows matter.
---

# Precise Modification Planning

Produce a concise, executable modification plan grounded in the relevant existing content.

## Workflow

1. Read the target sections and adjacent context needed to avoid duplication, redundancy, or conflicts.
2. For each planned change, state the file path, exact edit location, current relevant content, and intended replacement, addition, merge, move, or removal.
3. Preserve useful content, merge overlapping instructions, and resolve conflicts so the plan changes the existing text rather than adding parallel text.
4. For code, specify script headers, functions, key variables, and comments needed for non-obvious logic.
5. For fixed constraints, procedures, or repeated operations, express the result as a stepwise workflow, checklist, or reusable template with clear confirmation points.
6. Write in short, precise, human-readable language. State desired behavior directly; reserve exclusionary wording for boundary conditions that materially affect correctness. Inspect more files only when context is insufficient.
