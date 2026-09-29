# Dataset File Rules

## Responsibility
Data modules own reading, decoding, sample normalization, transforms, collation, and dataloader construction.

## Recommended layout
```text
src/data/
├── dataset.py
├── transforms.py
├── collate.py
└── factory.py
```

## Naming
Classes:
`ImageFolderDataset`, `SequenceDataset`, `PairDataset`.

Methods:
`__len__`, `__getitem__`, `load_sample`, `parse_record`, `build_transforms`, `collate_batch`.

Variables:
`sample`, `inputs`, `targets`, `metadata`, `batch`, `indices`, `transform`.

## Sample contract
Use a stable structure:
```python
{
    "inputs": inputs,
    "targets": targets,
    "sample_id": sample_id,
}
```

Document field meaning, dtype, shape, and coordinate or label conventions.

## Transform boundary
Separate deterministic parsing from stochastic augmentation.
Use `build_train_transforms` and `build_eval_transforms`.

## Documentation
Every dataset class and public builder has a docstring.
Non-trivial parsing and collation helpers also have docstrings.

Add line-level comments around:
- label mapping
- coordinate conversion
- padding and truncation
- stochastic sampling
- augmentation order
- shape conversion
- collation of variable-length samples

## Python features
Use `@dataclass` for structured metadata or parsed records.
Use `@classmethod` for dataset construction from manifests or index files.
Use `@staticmethod` for stateless parsing helpers.
Use context managers for file-backed resources.
