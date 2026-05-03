# self-skills

Personal Codex skills that can be reused across projects.

## Included Skills

- `continuous-plan-confirmation`: keeps Codex in a planning confirmation loop until explicit execution or finalization.
- `scientific-objectivity-tone`: keeps scientific writing objective, evidence-bounded, and anti-hype.

## Repository Layout

```text
skills/
  continuous-plan-confirmation/
    SKILL.md
  scientific-objectivity-tone/
    SKILL.md
    references/
      authoritative-guidance.md
```

## Local Install

Install all skills:

```bash
mkdir -p ~/.codex/skills
cp -r skills/continuous-plan-confirmation ~/.codex/skills/
cp -r skills/scientific-objectivity-tone ~/.codex/skills/
```

Install one skill:

```bash
mkdir -p ~/.codex/skills
cp -r skills/<skill-name> ~/.codex/skills/
```
