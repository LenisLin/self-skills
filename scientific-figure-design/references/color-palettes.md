# Scientific figure color palettes

Following Wong's guidance on color-vision differences and the dittoSeq palette documentation, prioritize category distinction, text contrast, and consistency across figures. User-specified palettes or panel references take precedence; prefer dittoSeq for routine categorical plots, with ggsci as an option for journal styles. References: [Wong, Nature Methods (2011)](https://www.nature.com/articles/nmeth.1618), [Wong correction](https://www.nature.com/articles/s41592-023-01974-0), [dittoSeq vignette](https://bioconductor.org/packages/release/bioc/vignettes/dittoSeq/inst/doc/dittoSeq.html), [ggsci documentation](https://nanx.me/ggsci/).

| Context | Palette choice | Numeric and visual encoding |
| --- | --- | --- |
| UMAP annotations, group comparisons, cell types | dittoSeq categorical colors, preferably the first 7; [swatches](../assets/figures/color_palette_preview.png) | Assign one fixed color to each category; with many groups, also use shapes, facets, or direct labels |
| Gene expression, proportions, and nonnegative intensities | Sequential color scale with increasing lightness | Encode expression or proportions; use the same numeric range for comparison plots |
| Signed values such as log2FC and correlation coefficients | Diverging color scale centered on 0 or a scientific reference value | Hue indicates direction and lightness indicates magnitude; use a range of −1 to 1 for correlation coefficients |
| Journal color styles | Choose ggsci palettes, such as NPG, according to the plot's needs | Preserve category mappings; check readability using shapes, labels, and grayscale |

The swatches show the first 7 dittoSeq colors and the 10 ggsci NPG colors for inspecting categorical and journal palettes, respectively; the [R script](../scripts/color_palette_preview.R) generates the swatches. Also use recognizable shapes, line types, or labels for important categories in a figure, and check pale-yellow contrast on white backgrounds, colors after transparency overlays, grayscale output, and common color-vision differences. dittoSeq's `Simulate()` can check how its plotting functions appear under different color-vision conditions.

Wong's correction adds the original source of the Okabe and Ito palette.

## R: Stable mappings for categorical variables

```r
library(ggplot2)

group_levels <- c("T cell", "B cell", "Myeloid")
palette <- dittoSeq::dittoColors(reps = 1)
stopifnot(length(group_levels) <= length(unique(palette)))
group_colors <- setNames(palette[seq_along(group_levels)], group_levels)

# p is an existing ggplot; use the same named mapping across subsets and panels.
p + scale_colour_manual(values = group_colors) +
  scale_fill_manual(values = group_colors)
```

## R: Choose color scales according to numeric meaning

```r
# Proportions from 0–1; comparison panels share limits.
p + scale_colour_viridis_c(limits = c(0, 1))

# Signed effects with 0 as the reference.
p + scale_fill_gradient2(low = "#0072B2", mid = "white",
                         high = "#D55E00", midpoint = 0)

# NPG-style categorical colors; use ggsci::scale_fill_npg() for fill mappings.
p + ggsci::scale_color_npg()
```

For actual figures, use limits, transformations, and units appropriate to the data. Existing reference-reproduction scripts retain the panel colors; choose colors for new figures according to the analysis question and the user's requested style.
