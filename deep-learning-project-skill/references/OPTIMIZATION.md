# Optimization File Rules

## Responsibility
Optimization modules own optimizer construction, scheduler construction, parameter grouping, warmup, and learning-rate policy.

## Recommended layout
```text
src/optimization/
├── factory.py
├── param_groups.py
└── schedulers.py
```

Keep optimizer and scheduler configuration together under:
```text
configs/optimization/
```

## Public interface
Prefer one construction function:
```python
def build_optimization(
    model: nn.Module,
    config: OptimizationConfig,
) -> tuple[Optimizer, LRScheduler | None]:
    """Build optimizer and scheduler from one optimization configuration."""
```

## Naming
Use:
`optimizer`, `scheduler`, `param_groups`, `base_lr`, `weight_decay`, `warmup_steps`, `total_steps`.

## Parameter groups
Make grouping rules explicit and testable.
Document rules for:
- backbone vs head learning rates
- decay vs no-decay parameters
- frozen parameters
- layer-wise learning-rate decay

## Documentation
Every public builder and non-trivial grouping function has a docstring.

Add line-level comments around:
- parameter selection
- learning-rate scaling
- weight-decay exclusions
- warmup transitions
- scheduler step timing
- resume-state restoration

## Python features
Use `@dataclass` for optimization configuration or structured group specifications.
Use `@staticmethod` for pure parameter classification helpers.
Use enums for scheduler modes when string literals become ambiguous.
