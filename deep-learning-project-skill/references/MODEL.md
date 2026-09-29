# Model File Rules

## Responsibility
Model files define neural network structure and forward computation.

## Recommended layout
```text
src/models/
├── resnet.py
├── transformer.py
├── heads.py
└── factory.py
```

Use one architecture family per module.
Place reusable blocks in dedicated modules.

## Naming
Classes use architecture or role names:
`ResNet`, `TransformerEncoder`, `ClassificationHead`.

Attributes use functional names:
`stem`, `encoder`, `decoder`, `backbone`, `projection`, `classifier`, `norm`, `dropout`.

Methods use role-based verbs:
`forward`, `encode`, `decode`, `extract_features`, `classify`, `reset_parameters`.

## Forward contract
Document accepted inputs, important tensor shapes, returned fields, and train/eval differences.

Prefer named outputs for multi-output models:
```python
return {
    "logits": logits,
    "features": features,
}
```

## Documentation
Every model class has a class docstring.
Every public method and non-trivial helper has a function-level docstring.

Add line-level comments around:
- tensor reshaping and permutation
- masking
- residual connections
- normalization order
- attention score construction
- feature pyramid merging
- mathematically meaningful scaling or stabilization

## Python features
Use `@dataclass` for structured model outputs when a dictionary becomes ambiguous.
Use `@classmethod` for alternate construction from pretrained metadata or configuration.
Use `@property` for derived read-only architecture values.
Use `@staticmethod` for pure shape or mask helpers owned by the model abstraction.
Keep decorators purposeful and visible in the public API.
