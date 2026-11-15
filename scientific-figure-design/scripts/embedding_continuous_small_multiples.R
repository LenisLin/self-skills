#!/usr/bin/env Rscript
# Compare continuous scores on a shared two-dimensional embedding.
# Reference: Cattle Cell Landscape (2025), Extended Data Figure 1a.
# Input: output directory. Outputs: simulated data and PNG/PDF/SVG figures.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(112329)
centers <- rbind(c(-1, 2), c(0, 2), c(1, 1.5), c(-1.2, 1), c(0, 1), c(1.2, .5),
                 c(-1, 0), c(0, 0), c(1, -.4), c(-1, -1), c(0, -1), c(.7, -2))
cluster <- sample(seq_len(nrow(centers)), 4800, replace = TRUE)
xy <- centers[cluster, ] + cbind(rnorm(4800, 0, .23), rnorm(4800, 0, .15))
activity <- sapply(seq_len(6), function(i)
  pmin(1, pmax(0, .1 + .6 * (cluster %% 6 == i %% 6) + rnorm(4800, 0, .07))))
colnames(activity) <- paste0("Score ", seq_len(6))
saveRDS(list(coordinates = xy, scores = activity),
        file.path(out, "embedding_continuous_small_multiples_simulated.rds"))

draw <- function() {
  par(mfrow = c(6, 1), mar = c(0, 0, 1, 0), family = "sans")
  colors <- c("#42A554", "#EE8978", "#D9AB77", "#91A75F", "#75A8C5", "#9273BB")
  for (i in seq_len(ncol(activity))) {
    palette <- colorRampPalette(c("#F4F4F4", colors[i]))(101)
    ord <- order(activity[, i])
    plot(xy[ord, ], pch = 16, cex = .35, col = palette[1 + round(100*activity[ord, i])],
         axes = FALSE, xlab = "", ylab = "", asp = 1, main = colnames(activity)[i])
  }
}
for (ext in c("png", "pdf", "svg")) {
  file <- file.path(out, paste0("embedding_continuous_small_multiples.", ext))
  if (ext == "png") png(file, width = 3.2, height = 10, units = "in", res = 200, type = "cairo")
  if (ext == "pdf") cairo_pdf(file, width = 3.2, height = 10)
  if (ext == "svg") svg(file, width = 3.2, height = 10)
  draw(); dev.off()
}
