# Project Architecture

## Goal
Structure the project so training orchestration, reusable domain logic, experiment configuration, evaluation, and inference have explicit boundaries.

## Canonical tree
```text
project/
├── configs/
│   ├── data/
│   ├── model/
│   ├── loss/
│   ├── optimization/
│   ├── metrics/
│   └── experiment/
├── src/
│   ├── data/
│   ├── models/
│   ├── losses/
│   ├── optimization/
│   ├── metrics/
│   ├── engine/
│   ├── evaluation/
│   ├── inference/
│   └── utils/
├── train.py
├── evaluate.py
├── infer.py
├── tests/
└── scripts/
```

## Component contracts

### `configs/`
Declares experiment choices and hyperparameters.
`optimization/` contains optimizer and scheduler configuration together.
Experiment files compose model, data, loss, optimization, metrics, runtime, and seed settings.

### `src/data/`
Owns dataset definitions, transforms, sample parsing, collation, and dataloader construction.

### `src/models/`
Owns model architecture and forward computation.

### `src/losses/`
Owns differentiable training objectives and loss composition.

### `src/optimization/`
Owns optimizer construction, scheduler construction, parameter groups, warmup policy, and optimization-specific utilities.

### `src/metrics/`
Owns reusable metric definitions, metric state, reduction, and aggregation.

### `src/engine/`
Owns reusable training, validation, and evaluation loops plus checkpoint lifecycle.

### `src/evaluation/`
Owns evaluator composition, prediction post-processing, dataset-level aggregation, and report construction.

### `src/inference/`
Owns prediction pipelines, preprocessing orchestration, batching, device execution, post-processing, and serializable outputs.

### `src/utils/`
Owns small reusable infrastructure such as logging, seeding, distributed helpers, device helpers, and generic I/O.

### Entry points
`train.py`, `evaluate.py`, and `infer.py` are composition roots.
They load configuration, construct components, wire dependencies, and start the requested lifecycle.

## Dependency direction
```text
train.py / evaluate.py / infer.py
              ↓
       engine / inference
      ↙    ↓      ↓     ↘
   data  models  losses  optimization
      ↘    ↓      ↓     ↙
     metrics / evaluation

configs describe construction
utils support all layers
```

## Interface rule
Each major module exposes a small typed public interface.
Implementation helpers stay local to the module.

## Extension rule
A new component should primarily change its own module area plus matching configuration.

## Comment rule
Every public function and non-trivial method has a concise docstring describing purpose, inputs, outputs, shapes, state changes, and raised errors when relevant.
Core tensor operations, optimizer state changes, masking, reshaping, checkpoint transitions, and non-obvious control flow receive line-level comments.

## Python feature rule
Use Python language features when they make contracts clearer:
- `@dataclass` for structured immutable or semi-structured data
- `@classmethod` for alternate constructors
- `@staticmethod` for logic owned by a class without instance state
- `@property` for derived read-only state
- context managers for scoped state
- type aliases, enums, and protocols for stable interfaces where useful
