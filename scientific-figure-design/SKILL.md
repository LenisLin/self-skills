---
name: scientific-figure-design
description: Design and refine scientific and biomedical data figures from data structures, statistical results, and visual references; select plot types, adapt reference styles, and build reproducible examples.
---

# Scientific figure design

1. Identify the question, observational unit, data structure, result type, units, groups, sample size, distribution, and available uncertainty. Define the input columns or matrix axes.
2. Choose marks and encodings that fit the result; explain the variables carried by position, color, size, facets, and annotations. Adjust display density to the data and figure dimensions.
3. For group comparisons, show individual observations when useful and preserve pairing, bounds, zeros, skew, and the meaning of the reported test. Choose density plots when observations support density estimation.
4. For matrices, align row and column identifiers, distinguish missing values from zero, and select sequential or zero-centered diverging colors according to the quantity. For cellular-neighborhood composition, show the requested fraction with its denominator and a 0–1 scale.
5. For survival plots, use time, event, and group inputs; derive the curve, censor marks, confidence intervals, and risk table from the data. For forest plots, show each estimate and interval with its model or source, units, and appropriate reference line and scale.
6. For embeddings, spatial maps, networks, and genomic tracks, retain the meaning and units of coordinates, topology, ordering, and shared axes. Use faceting, aggregation, or rasterization to keep dense data readable.
7. When a visual reference is provided, inspect each relevant panel and compare composition, geometry, palette, density, typography, legends, and annotation placement. Adapt those visual features to the user's data and requested figure type; identify the source and any same-type substitute.
8. Reuse available author code and record whether it implements the figure, supplies similar geometry, or prepares upstream data. Build independent simulated examples where useful, compute displayed statistics from their inputs, and label simulation and assumptions.
9. Render at the intended size, inspect each output alongside its reference, and iterate on visible differences. Deliver reproducible code, input contracts, and readable vector and raster figures; report the selected method and practical limits.

When the current project provides `docs/visualization/README.md`, consult it for the method guide, source mappings, simulated inputs, and comparison gallery.
