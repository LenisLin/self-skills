# Deep Learning Project Architecture Skill

## Purpose
Use this skill to generate and extend maintainable deep learning projects.
It defines project boundaries, module names, file responsibilities, naming rules, comments, and Python implementation conventions.

## Core outcome
Model, dataset, loss, metrics, optimization, training, evaluation, and inference should remain independently understandable and replaceable.

## Default project shape
Use `src/` for Python source, `configs/` for experiment configuration, `tests/` for tests, and `scripts/` for execution helpers.

## Required reading order
1. Read `references/ARCHITECTURE.md` before creating or restructuring a project.
2. Read the component reference that matches the current task:
   - `TRAIN.md`
   - `MODEL.md`
   - `DATASET.md`
   - `LOSS.md`
   - `OPTIMIZATION.md`
   - `METRICS.md`
   - `INFERENCE.md`

## Generation workflow
1. Define the project tree.
2. Assign one responsibility to each module.
3. Define public interfaces before implementation details.
4. Keep experiment choices in configuration.
5. Keep orchestration in entrypoints and engine modules.
6. Keep reusable computation in domain modules.
7. Add function-level docstrings and targeted line-level comments.

## Python conventions
Use type hints on public interfaces.
Use `@dataclass` for structured configuration or result objects.
Use `@classmethod`, `@staticmethod`, and `@property` when they clarify ownership and API intent.
Use context managers for resources, precision scopes, inference scopes, and temporary state.
Prefer small explicit functions over hidden side effects.

## Naming
Use descriptive `snake_case` for modules, functions, and variables.
Use descriptive `PascalCase` for classes.
Use stable role names such as `model`, `dataset`, `criterion`, `optimizer`, `scheduler`, `batch`, `outputs`, `targets`, and `metrics`.

## Progressive disclosure
Load `ARCHITECTURE.md` as the shared contract.
Load only the component reference needed for the current implementation.
