#!/usr/bin/env Rscript
# Show the composition of every sample, grouped and annotated by category.
# Reference: Karimi et al. (2023), Nature, Figure 1e, doi:10.1038/s41586-022-05680-3.
# Adapt the sample-by-category counts and sample group columns to your data.
# Run: Rscript sample_category_proportion_stacked.R OUTPUT_DIR
# Outputs: simulated counts/proportions and PNG, PDF and SVG figures.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(2026111901)

categories <- paste("Type", LETTERS[1:17])
category_colors <- c("#181623", "#0148A4", "#0B86EB", "#6D2CEB", "#CF2EEA",
                     "#11988C", "#02B958", "#9BC3E5", "#FC6C08", "#FFCE00",
                     "#B6DA51", "#CDD33A", "#E8CC98", "#BFC5C8", "#FABABC",
                     "#BB7C9B", "#86165C")
group_levels <- c("Group A", "Group B", "Group C", "Group D", "Group E", "Group F", "Group G")
group_colors <- c("#D50057", "#005B8C", "#3FB458", "#FFC950", "#ACE390", "#DBC6E1", "#AD82B0")
sample_groups <- rep(group_levels, c(192, 18, 19, 22, 19, 72, 47))
samples <- data.frame(sample = sprintf("Sample%03d", seq_along(sample_groups)),
                      group = sample_groups, stringsAsFactors = FALSE)
alpha <- c(.12, .18, .25, .12, .14, .12, .15, .08, .12, .14, .17, .15, 5.0, .2, .12, .25, 2.4)
counts <- t(vapply(seq_len(nrow(samples)), function(i) {
  group <- match(samples$group[i], group_levels)
  a <- alpha
  if (group %in% 2:5) a[c(13, 17)] <- c(4, 1.8)
  if (group %in% 6:7) a[c(13, 17)] <- c(1.5, 4.5)
  p <- rgamma(length(a), a); p <- p / sum(p)
  as.vector(rmultinom(1, sample(500:2500, 1), p))
}, integer(length(categories))))
colnames(counts) <- categories
fractions <- counts / rowSums(counts)
samples$sort_value <- fractions[, "Type Q"]
order_by_group <- order(match(samples$group, group_levels), -samples$sort_value)
samples <- samples[order_by_group, ]; counts <- counts[order_by_group, ]; fractions <- fractions[order_by_group, ]
rownames(counts) <- rownames(fractions) <- samples$sample
saveRDS(list(samples = samples, counts = counts, fractions = fractions,
             category_colors = setNames(category_colors, categories),
             group_colors = setNames(group_colors, group_levels)),
        file.path(out, "sample_category_proportion_stacked_simulated.rds"))

draw <- function() {
  par(mar = c(0, 0, 0, 0), family = "sans", xpd = NA)
  plot.new(); plot.window(c(0, 1), c(0, 1), xaxs = "i", yaxs = "i")
  x0 <- .10; x1 <- .75; h <- .34
  for (panel in 1:2) {
    idx <- if (panel == 1) which(samples$group == "Group A") else which(samples$group != "Group A")
    y0 <- if (panel == 1) .575 else .145
    w <- (x1-x0) / length(idx)
    for (j in seq_along(idx)) {
      lower <- 0
      for (k in seq_along(categories)) {
        upper <- lower + fractions[idx[j], k]
        rect(x0+(j-1)*w, y0+lower*h, x0+j*w+.0001, y0+upper*h,
             col = category_colors[k], border = NA)
        lower <- upper
      }
      rect(x0+(j-1)*w, y0-.026, x0+j*w+.0001, y0-.005,
           col = group_colors[match(samples$group[idx[j]], group_levels)], border = NA)
    }
    segments(x0, y0, x0, y0+h, lwd = .8)
    for (v in c(0, .5, 1)) {
      segments(x0-.005, y0+v*h, x0, y0+v*h, lwd = .7)
      text(x0-.008, y0+v*h, paste0(100*v, "%"), adj = 1, cex = .72)
    }
    text(x0-.008, y0-.016, "Group", adj = 1, cex = .66)
    text(x0, y0+h+.025, if (panel == 1) "Group A" else "Groups B-G", adj = 0, cex = .8)
  }
  text(.79, .95, "Category", adj = 0, font = 2, cex = .8)
  for (k in seq_along(categories)) {
    y <- .92 - (k-1)*.027
    rect(.79, y-.008, .801, y+.008, col = category_colors[k], border = NA)
    text(.808, y, categories[k], adj = 0, cex = .68)
  }
  text(.79, .425, "Sample group", adj = 0, font = 2, cex = .8)
  for (k in seq_along(group_levels)) {
    y <- .392-(k-1)*.033
    rect(.79, y-.01, .801, y+.01, col = group_colors[k], border = NA)
    text(.808, y, group_levels[k], adj = 0, cex = .7)
  }
}
for (ext in c("png", "pdf", "svg")) {
  file <- file.path(out, paste0("sample_category_proportion_stacked.", ext))
  if (ext == "png") png(file, width = 14, height = 6.5, units = "in", res = 200, type = "cairo")
  if (ext == "pdf") cairo_pdf(file, width = 14, height = 6.5)
  if (ext == "svg") svg(file, width = 14, height = 6.5)
  draw(); dev.off()
}
