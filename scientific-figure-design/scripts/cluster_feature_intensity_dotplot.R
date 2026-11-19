#!/usr/bin/env Rscript
# Compare a feature-intensity matrix using dot area and group-specific colors.
# Reference: Karimi et al. (2023), Nature, Figure 3h, doi:10.1038/s41586-022-05680-3.
# Adapt the group-by-feature matrix and the named group colors to your data.
# Run: Rscript cluster_feature_intensity_dotplot.R OUTPUT_DIR
# Outputs: simulated intensity matrix and PNG, PDF and SVG figures.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(2026111904)

groups <- paste("Group", 1:15)
features <- paste("Marker", 1:9)
group_colors <- c("#00553B", "#75B7D6", "#ADC3DE", "#189052", "#00669C", "#36AA5B",
                  "#C9A7CB", "#D6D2E5", "#5B9FC4", "#C48CBD", "#E8E3F1", "#005182",
                  "#E41A91", "#E05DA9", "#A3DB7B")
intensity <- matrix(rbeta(15*9, .45, 5), nrow = 15, ncol = 9,
                    dimnames = list(groups, features))
hot <- rbind(c(1,7), c(2,4), c(2,6), c(4,2), c(5,5), c(9,2), c(10,2), c(11,1),
             c(11,8), c(11,9), c(12,2), c(12,3), c(12,4), c(13,2), c(15,3))
for (i in seq_len(nrow(hot))) intensity[hot[i,1], hot[i,2]] <- runif(1, .55, 1)
saveRDS(list(intensity = intensity, group_colors = setNames(group_colors, groups)),
        file.path(out, "cluster_feature_intensity_dotplot_simulated.rds"))

draw <- function() {
  par(mar = c(0, 0, 0, 0), family = "sans", xpd = NA)
  plot.new(); plot.window(c(0, 1), c(0, 1), xaxs = "i", yaxs = "i")
  x <- seq(.24, .90, length.out = length(features)); y <- seq(.90, .19, length.out = length(groups))
  for (i in seq_along(groups)) {
    points(rep(.14, 1), y[i], pch = 21, bg = group_colors[i], col = NA, cex = 2.2)
    text(.14, y[i], i, col = if (i %in% c(3, 7, 8, 10, 11, 15)) "#333333" else "white", cex = .72)
    points(x, rep(y[i], length(x)), pch = 21, bg = group_colors[i], col = "#444444",
           cex = 2.7*sqrt(intensity[i, ]), lwd = .45)
  }
  text(x, .16, features, srt = 90, adj = 1, cex = .73)
  text(.035, .045, "Intensity", adj = 0, cex = .75)
  for (i in seq_along(c(.25, .5, 1))) {
    value <- c(.25, .5, 1)[i]; x0 <- .16 + (i-1)*.14
    points(x0, .045, pch = 21, bg = "black", cex = 2.7*sqrt(value))
    text(x0+.045, .045, value, adj = 0, cex = .72)
  }
}
for (ext in c("png", "pdf", "svg")) {
  file <- file.path(out, paste0("cluster_feature_intensity_dotplot.", ext))
  if (ext == "png") png(file, width = 6, height = 9, units = "in", res = 200, type = "cairo")
  if (ext == "pdf") cairo_pdf(file, width = 6, height = 9)
  if (ext == "svg") svg(file, width = 6, height = 9)
  draw(); dev.off()
}
