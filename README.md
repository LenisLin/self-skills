# self-skills

Personal Codex skills that can be reused across projects.

## Included Skills

- `continuous-plan-confirmation`: keeps Codex in a planning confirmation loop until explicit execution or finalization.
- `precise-modification-planning`: produces concise, file-grounded plans before code, document, prompt, config, or workflow changes.
- `scholar-bibtex-citation-audit`: refreshes BibTeX entries from Google Scholar, preserves LaTeX citation keys, and audits citation consistency.
- `scientific-objectivity-tone`: keeps scientific writing objective, evidence-bounded, and anti-hype.
- `reviewer-response`: plans and drafts source-grounded reviewer responses with revision matching, formatting rules, and worked examples.

## Repository Layout

```text
continuous-plan-confirmation/
  SKILL.md
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
cp -r continuous-plan-confirmation ~/.codex/skills/
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
