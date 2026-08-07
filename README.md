# self-skills

Personal Codex skills that can be reused across projects.

## Included Skills

- `continuous-plan-confirmation`: keeps Codex in a planning confirmation loop until explicit execution or finalization.
- `precise-modification-planning`: produces concise, file-grounded plans before code, document, prompt, config, or workflow changes.
- `scientific-objectivity-tone`: keeps scientific writing objective, evidence-bounded, and anti-hype.

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
scientific-objectivity-tone/
  SKILL.md
  references/
    authoritative-guidance.md
```

## Local Install

Install all skills:

```bash
mkdir -p ~/.codex/skills
cp -r continuous-plan-confirmation ~/.codex/skills/
cp -r precise-modification-planning ~/.codex/skills/
cp -r scientific-objectivity-tone ~/.codex/skills/
```

Install one skill:

```bash
mkdir -p ~/.codex/skills
cp -r <skill-name> ~/.codex/skills/
```
