#!/usr/bin/env Rscript
# Compare features across group pairs with significance-sized, direction-colored dots.
# Reference: Karimi et al. (2023), Nature, Figure 2a, doi:10.1038/s41586-022-05680-3.
# Adapt observation, feature, comparison, group and optional pair identifiers.
# Run: Rscript group_comparison_pvalue_bubble.R OUTPUT_DIR
# Outputs: simulated observations, t-test results and PNG, PDF and SVG figures.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(2026111902)

features <- paste("Feature", sprintf("%02d", 1:23))
comparisons <- data.frame(comparison = paste("Comparison", sprintf("%02d", 1:27)),
  section = rep(c("Cohort A", "Cohort B", "Cohort C"), c(10, 8, 9)),
  term_a = paste("A", 1:27), term_b = paste("B", 1:27),
  paired = seq_len(27) %in% c(10, 11, 12),
  color_a = rep(c("#0065A5", "#288D5B", "#56225E", "#6E8EAE", "#A1248E", "#A22215"), length.out = 27),
  color_b = rep(c("#A8DBB8", "#055B31", "#F3C6C4", "#95BADE", "#F88ABA", "#FFB886"), length.out = 27))

observations <- vector("list", nrow(comparisons) * length(features))
results <- vector("list", length(observations))
idx <- 0
for (i in seq_len(nrow(comparisons))) for (j in seq_along(features)) {
  idx <- idx + 1
  n <- sample(18:40, 1)
  baseline <- runif(1, .4, 4.5)
  effect <- if (runif(1) < .23) sample(c(-1, 1), 1) * runif(1, .5, 1.2) else rnorm(1, 0, .1)
  pair_effect <- if (comparisons$paired[i]) rnorm(n, 0, .45) else rep(0, n)
  a <- pmax(0, baseline + effect/2 + pair_effect + rnorm(n, 0, .8))
  b <- pmax(0, baseline - effect/2 + pair_effect + rnorm(n, 0, .8))
  test <- t.test(a, b, paired = comparisons$paired[i], var.equal = TRUE)
  observations[[idx]] <- data.frame(comparison = comparisons$comparison[i], feature = features[j],
    pair_id = rep(seq_len(n), 2), group = rep(c("A", "B"), each = n), value = c(a, b))
  results[[idx]] <- data.frame(comparison = comparisons$comparison[i], feature = features[j],
    mean_a = mean(a), mean_b = mean(b), p = test$p.value,
    higher = if (mean(a) >= mean(b)) "A" else "B")
}
observations <- do.call(rbind, observations)
results <- do.call(rbind, results)
saveRDS(list(observations = observations, comparisons = comparisons, results = results),
        file.path(out, "group_comparison_pvalue_bubble_simulated.rds"))

bubble_size <- function(p) ifelse(p > .05, .14, .25 + 1.65*sqrt(pmax(0, (pmin(-log10(p), 3)-1)/2)))
draw <- function() {
  par(mar = c(0, 0, 0, 0), family = "sans", xpd = NA)
  plot.new(); plot.window(c(0, 1), c(0, 1), xaxs = "i", yaxs = "i")
  left <- .105; right <- .67; top <- .90; bottom <- .22
  xx <- seq(left, right, length.out = length(features))
  yy <- seq(top, bottom, length.out = nrow(comparisons))
  for (i in seq_len(nrow(comparisons))) {
    row <- results[results$comparison == comparisons$comparison[i], ]
    row <- row[match(features, row$feature), ]
    col <- ifelse(row$higher == "A", comparisons$color_a[i], comparisons$color_b[i])
    points(xx, rep(yy[i], length(xx)), pch = 21, bg = col, col = "#222222",
           cex = bubble_size(pmax(row$p, 1e-300)), lwd = .35)
    for (term in 1:2) {
      x <- c(.71, .85)[term]; label <- if (term == 1) comparisons$term_a[i] else comparisons$term_b[i]
      color <- if (term == 1) comparisons$color_a[i] else comparisons$color_b[i]
      rect(x, yy[i]-.008, x+.013, yy[i]+.008, col = color, border = "#555555", lwd = .3)
      text(x+.018, yy[i], label, adj = 0, cex = .63)
    }
  }
  rect(left-.012, bottom-.016, right+.012, top+.016, border = "#333333", lwd = .7)
  for (k in c(10, 18)) {
    y <- mean(yy[k:(k+1)])
    segments(left-.012, y, .97, y, lwd = .65)
  }
  text(.085, mean(yy[1:10]), "Cohort A", srt = 90, cex = .68)
  text(.085, mean(yy[11:18]), "Cohort B", srt = 90, cex = .68)
  text(.085, mean(yy[19:27]), "Cohort C", srt = 90, cex = .68)
  text(xx, bottom-.028, features, srt = 90, adj = 1, cex = .64)
  text(c(.71, .85), .94, c("A term", "B term"), adj = 0, cex = .78)
  text(.828, .94, "vs", cex = .7)
  text(.71, .145, "P value", adj = 0, cex = .75)
  for (i in seq_along(c(.05, .01, .001))) {
    p <- c(.05, .01, .001)[i]; y <- .12 - (i-1)*.029
    points(.72, y, pch = 21, bg = "black", cex = bubble_size(p))
    text(.746, y, if (p == .001) "<= 0.001" else paste0("= ", p), adj = 0, cex = .68)
  }
}
for (ext in c("png", "pdf", "svg")) {
  file <- file.path(out, paste0("group_comparison_pvalue_bubble.", ext))
  if (ext == "png") png(file, width = 12, height = 10, units = "in", res = 200, type = "cairo")
  if (ext == "pdf") cairo_pdf(file, width = 12, height = 10)
  if (ext == "svg") svg(file, width = 12, height = 10)
  draw(); dev.off()
}
