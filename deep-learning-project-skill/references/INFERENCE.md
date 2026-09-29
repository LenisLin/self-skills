# Inference File Rules

## Responsibility
Inference code owns prediction-time orchestration from input preparation to serializable outputs.

## Recommended layout
```text
infer.py
src/inference/
├── predictor.py
├── pipeline.py
├── postprocess.py
└── serialization.py
```

## Public interface
Prefer a small predictor API:
```python
class Predictor:
    def predict(self, inputs: InputBatch) -> PredictionBatch:
        """Run preprocessing, model execution, and post-processing."""
```

## Lifecycle
Inference should make these stages visible:
1. load configuration and checkpoint
2. construct model and preprocessing
3. prepare batch
4. enter inference precision/device scope
5. execute model
6. post-process outputs
7. serialize or return predictions

## Documentation
Every public predictor, pipeline function, and post-processing function has a docstring.

Add line-level comments around:
- device transfer
- batching
- `torch.inference_mode()`
- autocast
- shape restoration
- thresholding or decoding
- coordinate restoration
- serialization of model outputs

## Python features
Use `@dataclass` for prediction records and batch outputs.
Use `@classmethod` for constructors such as `from_checkpoint`.
Use `@property` for stable predictor metadata.
Use context managers for inference mode, autocast, and temporary runtime state.
