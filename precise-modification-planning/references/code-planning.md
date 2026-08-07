# Code Planning Requirements

Apply these requirements to every planned code edit.

## Documentation Coverage

- For each edited script, name the header location and list the purpose, expected inputs, produced outputs, main side effects, and required assumptions to document.
- For each edited public function or class, name the symbol and list the purpose, parameter meanings, return values, relevant errors, domain assumptions, and changed control flow.
- For each key variable, name the variable, its scope, its stored concept, and the short comment that explains units, shapes, axes, coordinate systems, metadata keys, thresholds, or another non-obvious choice.
- Describe the data path for every edited code unit: input source, transformations, output destination, persisted state, and applicable error path.
- Cite the current code unit by line range and full text or continuous range excerpt. Give the complete final code for every modified target unit.
- Engineering review checks the changed behavior, output contract, failure handling, compatibility path, documentation coverage, and test coverage.

## Interface Classification

State one interface classification for each API-affecting edit:

- `Internal-only change`
- `Stable API, implementation cleanup`
- `Public API change with migration path`
- `Behavior change with documented rationale`

## Code-Edit Confirmation

For each affected file, include these plan fields when relevant:

- Code units and locations
- Detailed behavior changes
- Data and error paths
- Comments / docstrings to add or revise
- Interface classification
- Engineering review findings and plan revisions
