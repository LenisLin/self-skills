# Metrics File Rules

## Responsibility
Metrics modules define reusable measurement logic for training, validation, and evaluation.

## Recommended layout
```text
src/metrics/
├── classification.py
├── regression.py
├── collection.py
└── factory.py
```

## Naming
Use domain metric names:
`Accuracy`, `F1Score`, `MeanIoU`, `MeanAveragePrecision`, `Perplexity`.

Use lifecycle methods:
`update`, `compute`, `reset`, `merge_state`.

## State contract
Metric state is explicit.
Document whether state is per-batch, accumulated, distributed, or dataset-level.

## Documentation
Every public metric class and method has a docstring describing inputs, accumulated state, reduction behavior, and returned values.

Add line-level comments around:
- distributed reduction
- masking invalid samples
- thresholding
- confusion-matrix updates
- weighted aggregation
- numerically sensitive accumulation

## Python features
Use `@dataclass` for metric result bundles.
Use `@property` for derived metric state.
Use `@staticmethod` for pure conversion or threshold helpers.
Use context managers only when metric computation needs temporary device or precision state.
