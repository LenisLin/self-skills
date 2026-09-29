# Training File Rules

## Responsibility
Training code orchestrates components and owns lifecycle control.

## Recommended files
```text
train.py
src/engine/trainer.py
src/engine/loops.py
src/engine/checkpoint.py
```

## Top-level flow
Keep construction and execution visible:

```python
def main(config: TrainConfig) -> None:
    """Build all training components and execute the configured run."""
    set_seed(config.seed)
    data = build_data(config.data)
    model = build_model(config.model)
    criterion = build_loss(config.loss)
    optimizer, scheduler = build_optimization(model, config.optimization)
    metrics = build_metrics(config.metrics)
    trainer = Trainer(...)
    trainer.fit()
```

## Naming
Use role names:
`config`, `model`, `criterion`, `optimizer`, `scheduler`, `train_loader`, `val_loader`, `batch`, `outputs`, `loss`, `metrics`.

## Trainer boundary
`Trainer` owns:
- epoch and step iteration
- forward/backward sequencing
- gradient accumulation
- optimizer and scheduler stepping
- mixed precision
- checkpoint timing
- logging timing
- validation timing

## Method naming
Use lifecycle verbs:
`fit`, `train_epoch`, `train_step`, `validate`, `validation_step`, `save_checkpoint`, `load_checkpoint`.

## Documentation
Every public function and non-trivial method has a docstring.
Docstrings describe lifecycle role, arguments, return values, device expectations, and state changes.

Add line-level comments around:
- autocast and scaler regions
- backward and gradient accumulation boundaries
- gradient clipping
- optimizer stepping
- scheduler stepping
- distributed synchronization
- checkpoint save/restore
- mode switches between `train()` and `eval()`

## Python features
Use `@dataclass` for trainer state or structured step results.
Use context managers for autocast, no-grad/inference scopes, profiling, and temporary state.
Use `@property` for derived trainer state such as global step or current learning rate when it improves readability.
