#!/usr/bin/env Rscript
# Encode ranked category scores by label size and compare across groups.
# Reference: Cattle Cell Landscape (2025), Extended Data Figure 1a.
# Input: output directory. Outputs: simulated data and PNG/PDF/SVG figures.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(112329)
categories <- c("Category A", "Category B", "Category C", "Category D",
                "Category E", "Category F", "Category G", "Category H")
scores <- matrix(runif(48, .08, .48), nrow = 8, ncol = 6,
                 dimnames = list(categories, paste0("Group ", 1:6)))
saveRDS(list(scores = scores), file.path(out, "category_score_ranked_words_simulated.rds"))

draw <- function() {
  par(mfrow = c(6, 1), mar = c(0, 0, 1, 0), family = "sans")
  colors <- c("#3E9D54", "#2A8D9B", "#34568A", "#A59C28", "#537EB2", "#9273BB", "#BF736A", "#65884F")
  for (i in seq_len(ncol(scores))) {
    plot.new(); plot.window(c(0, 1), c(0, 1))
    title(colnames(scores)[i], cex.main = .9)
    ord <- order(scores[, i], decreasing = TRUE)
    positions <- rbind(c(.5,.84), c(.29,.67), c(.71,.67), c(.5,.50),
                       c(.25,.33), c(.75,.33), c(.32,.16), c(.7,.16))
    for (k in seq_along(ord)) {
      j <- ord[k]
      text(positions[k, 1], positions[k, 2], categories[j],
           cex = 1.1 + .7*(scores[j, i] - min(scores[, i]))/diff(range(scores[, i])),
           col = colors[j])
    }
  }
}
for (ext in c("png", "pdf", "svg")) {
  file <- file.path(out, paste0("category_score_ranked_words.", ext))
  if (ext == "png") png(file, width = 4, height = 10, units = "in", res = 200, type = "cairo")
  if (ext == "pdf") cairo_pdf(file, width = 4, height = 10)
  if (ext == "svg") svg(file, width = 4, height = 10)
  draw(); dev.off()
}
