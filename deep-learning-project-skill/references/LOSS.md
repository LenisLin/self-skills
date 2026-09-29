# Loss File Rules

## Responsibility
Loss modules define differentiable objectives and loss composition.

## Recommended layout
```text
src/losses/
├── classification.py
├── regression.py
├── composite.py
└── factory.py
```

## Naming
Use objective names:
`CrossEntropyLoss`, `FocalLoss`, `DiceLoss`, `ContrastiveLoss`.

Composite objectives use role names:
`DetectionLoss`, `MultiTaskLoss`, `TotalLoss`.

Helpers describe the term:
`classification_loss`, `localization_loss`, `regularization_loss`.

## Inputs and outputs
Accept documented model outputs and targets.

Single objective:
```python
return loss
```

Composite objective:
```python
return {
    "loss": total_loss,
    "classification_loss": cls_loss,
    "localization_loss": loc_loss,
}
```

Use `loss` as the optimized total scalar.

## Documentation
Every public loss class, function, and non-trivial helper has a docstring describing the mathematical objective, expected inputs, target encoding, reduction, weighting, and return values.

Add line-level comments around:
- masking
- normalization
- numerical stabilization
- log/exp transforms
- reduction dimensions
- weighting and balancing
- detached values used only for reporting

## Python features
Use `@dataclass` for structured loss outputs when named fields improve type safety.
Use `@staticmethod` for pure helper formulas owned by a loss class.
Use typed aliases for output dictionaries or structured targets when useful.
