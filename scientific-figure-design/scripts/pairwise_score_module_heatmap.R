#!/usr/bin/env Rscript
# Display a symmetric feature-by-feature score matrix and module boundaries.
# Reference: Cattle Cell Landscape (2025), Extended Data Figure 1a.
# Input: output directory. Outputs: simulated data and PNG/PDF/SVG figures.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(112329)
sizes <- c(18, 21, 26, 48, 23, 20)
module <- rep(seq_along(sizes), sizes)
latent <- matrix(rnorm(800 * 6), 800, 6)
scores <- sapply(seq_along(module), function(i) {
  m <- module[i]
  group <- if (runif(1) < .30) sample(1:3, 1) else ceiling(m/2)
  pair <- c(2*group-1, 2*group)
  .3*latent[, m] + 1.8*rowMeans(latent[, pair]) +
    .4*latent[, sample(1:6, 1)] + rnorm(800, 0, .35)
})
correlation <- cor(scores)
score <- matrix(0, ncol(scores), ncol(scores))
for (i in seq_len(ncol(scores))) for (j in i:ncol(scores)) {
  other <- setdiff(seq_len(ncol(scores)), c(i, j))
  score[i, j] <- mean(correlation[i, other] < correlation[i, j] &
                      correlation[j, other] < correlation[i, j])
  score[j, i] <- score[i, j]
}
diag(score) <- 1
trees <- lapply(seq_along(sizes), function(m) {
  indices <- which(module == m)
  hclust(as.dist(1-correlation[indices, indices]), method = "average")
})
ordering <- unlist(lapply(seq_along(sizes), function(m) which(module == m)[trees[[m]]$order]))
score <- score[ordering, ordering]
saveRDS(list(feature_scores = scores[, ordering], pairwise_score = score,
             module = module[ordering], trees = trees),
        file.path(out, "pairwise_score_module_heatmap_simulated.rds"))

draw <- function() {
  par(mar = c(2, 2, 6, 6), family = "sans", xpd = NA)
  palette <- colorRampPalette(c("#FFFFFF", "#D2BDD9", "#A677BD", "#512884"))(101)
  colors <- c("#42A554", "#EE8978", "#D9AB77", "#91A75F", "#75A8C5", "#9273BB")
  image(seq_len(nrow(score)), seq_len(ncol(score)), t(score[nrow(score):1, ]),
        col = palette, zlim = c(.7, 1), axes = FALSE, xlab = "", ylab = "")
  mtext("Pairwise connection specificity", side = 3, line = 3.5, font = 2, cex = 1)
  bounds <- c(0, cumsum(sizes)) + .5
  for (i in seq_along(sizes)) {
    rect(bounds[i], nrow(score)-bounds[i+1]+1, bounds[i+1], nrow(score)-bounds[i]+1,
         border = colors[i], lwd = 1)
    rect(bounds[i], nrow(score)+1, bounds[i+1], nrow(score)+4, col = colors[i], border = NA)
    tree <- trees[[i]]; n <- sizes[i]
    xpos <- hpos <- numeric(n-1)
    for (k in seq_len(n-1)) {
      branches <- tree$merge[k, ]; xx <- yy <- numeric(2)
      for (j in 1:2) {
        if (branches[j] < 0) { xx[j] <- match(-branches[j], tree$order); yy[j] <- 0
        } else { xx[j] <- xpos[branches[j]]; yy[j] <- hpos[branches[j]] }
      }
      h <- 8*tree$height[k]/max(tree$height)
      x <- bounds[i] + xx - .5
      lines(c(x[1], x[1], x[2], x[2]), nrow(score)+4+c(yy[1], h, h, yy[2]), lwd = .4)
      y <- nrow(score)+1-x
      lines(.5-c(yy[1], h, h, yy[2]), c(y[1], y[1], y[2], y[2]), lwd = .4)
      xpos[k] <- mean(xx); hpos[k] <- h
    }
  }
  for (i in 1:100) rect(nrow(score)+8, (i-1)*nrow(score)/100, nrow(score)+11,
                        i*nrow(score)/100, col = palette[i], border = NA)
  text(nrow(score)+13, c(0, nrow(score)/2, nrow(score)), c("0.7", "0.85", "1"), adj = 0, cex = .7)
}
for (ext in c("png", "pdf", "svg")) {
  file <- file.path(out, paste0("pairwise_score_module_heatmap.", ext))
  if (ext == "png") png(file, width = 6, height = 6, units = "in", res = 200, type = "cairo")
  if (ext == "pdf") cairo_pdf(file, width = 6, height = 6)
  if (ext == "svg") svg(file, width = 6, height = 6)
  draw(); dev.off()
}
