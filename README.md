# self-skills

Personal Codex skills that can be reused across projects.

## Included Skills

- `analysis-script-style`: keeps biomedical data-analysis scripts concise, readable, and sequential.
- `continuous-plan-confirmation`: keeps Codex in a planning confirmation loop until explicit execution or finalization.
- `deep-learning-project-skill`: defines maintainable deep-learning project boundaries, interfaces, and conventions.
- `precise-modification-planning`: produces concise, file-grounded plans before code, document, prompt, config, or workflow changes.
- `scholar-bibtex-citation-audit`: refreshes BibTeX entries from Google Scholar, preserves LaTeX citation keys, and audits citation consistency.
- `scientific-objectivity-tone`: keeps scientific writing objective, evidence-bounded, and anti-hype.
- `reviewer-response`: plans and drafts source-grounded reviewer responses with revision matching, formatting rules, and worked examples.

## Repository Layout

```text
analysis-script-style/
  SKILL.md
  agents/
    openai.yaml
  assets/
    icon.svg
  examples/
    python_analysis.py
    r_analysis.R
  references/
    review-checklist.md
    style-guide.md
continuous-plan-confirmation/
  SKILL.md
deep-learning-project-skill/
  SKILL.md
  references/
    ARCHITECTURE.md
    DATASET.md
    INFERENCE.md
    LOSS.md
    METRICS.md
    MODEL.md
    OPTIMIZATION.md
    TRAIN.md
precise-modification-planning/
  SKILL.md
  references/
    planning-workflow.md
    code-planning.md
    plan-template.md
scholar-bibtex-citation-audit/
  SKILL.md
  agents/
    openai.yaml
scientific-objectivity-tone/
  SKILL.md
  references/
    authoritative-guidance.md
reviewer-response/
  SKILL.md
  references/
    01_response_planning_and_drafting.md
    02_evidence_scope_and_claims.md
    03_manuscript_changes_and_matrices.md
    04_document_editing_and_validation.md
  examples/
    response_schemes.md
```

## Local Install

Run the following commands from the repository root. Copying a skill that is
already installed overwrites matching files in its destination directory.

Install all skills:

```bash
mkdir -p ~/.codex/skills
cp -r analysis-script-style ~/.codex/skills/
cp -r continuous-plan-confirmation ~/.codex/skills/
cp -r deep-learning-project-skill ~/.codex/skills/
cp -r precise-modification-planning ~/.codex/skills/
cp -r scholar-bibtex-citation-audit ~/.codex/skills/
cp -r scientific-objectivity-tone ~/.codex/skills/
cp -r reviewer-response ~/.codex/skills/
```

Install one skill:

```bash
mkdir -p ~/.codex/skills
cp -r <skill-name> ~/.codex/skills/
```
