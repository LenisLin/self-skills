#!/usr/bin/env Rscript
# Rank repeated random-forest feature importance beside response-group means.
# Reference: Wang et al. (2023), Nature, Figure 6e; DOI 10.1038/s41586-023-06498-3.
# Requires the randomForest R package. Run: Rscript feature_importance_response_heatmap.R OUTPUT_DIR
# Saves simulated patient predictors, 1,000 random-forest runs and PNG/PDF/SVG.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(2026111403)

# Generate patient predictors with different response associations.
labels <- c("AR+LAR (Dn)", "PDPN+ Stromal (Het)", "CD56+ NK (Hom)", "CD8+PD1+ T (Hom)",
            "M2 Mac (Dn)", "AR+LAR (Hom)", "CD15+ (Het)", "Apoptosis Ki67+",
            "CD15+ (Hom)", "CD15+ (Dn)", "CD8+GZMB+ T (Dn)", "CD8+GZMB+ T (Hom)")
feature_colors <- c("#195D68", "#E696AD", "#B29B25", "#235D34", "#E6CE13", "#195D68",
                    "#8C80BE", "#58BFE6", "#8C80BE", "#8C80BE", "#C0DCAD", "#C0DCAD")
compartment <- c("Epithelial", "TME", "TME", "TME", "TME", "Epithelial",
                 "Epithelial", "Epithelial", "Epithelial", "Epithelial", "TME", "TME")
n <- 76
response <- factor(c(rep("RD", 43), rep("pCR", 33)), levels = c("RD", "pCR"))
response <- sample(response)
effect <- c(-.8, -.9, .9, 1.4, -.95, -.95, -1.0, 1.0, -1.1, -1.15, 1.2, 1.3)
features <- sapply(effect, function(delta) rnorm(n, mean = as.numeric(response == "pCR") * delta, sd = 1))
colnames(features) <- sprintf("feature_%02d", seq_along(labels))
scaled_features <- scale(features)
patients <- data.frame(patient = sprintf("P%03d", seq_len(n)), response = response, features)

# Boruta-style selection with a fixed feature set: each forest compares real
# predictors against independently shuffled shadow predictors. The binomial
# test uses a 0.5 null hit probability and Bonferroni correction.
runs <- 1000
importance <- matrix(NA_real_, nrow = runs, ncol = ncol(features),
                     dimnames = list(NULL, colnames(features)))
hit <- matrix(FALSE, nrow = runs, ncol = ncol(features), dimnames = dimnames(importance))
for (i in seq_len(runs)) {
  shadow <- apply(features, 2, sample)
  colnames(shadow) <- paste0("shadow_", colnames(features))
  doubled <- data.frame(features, shadow, check.names = FALSE)
  fit <- randomForest::randomForest(x = doubled, y = response, ntree = 100,
                                    importance = TRUE, keep.forest = FALSE)
  score <- randomForest::importance(fit, type = 1, scale = TRUE)[, 1]
  importance[i, ] <- score[colnames(features)]
  hit[i, ] <- importance[i, ] > max(score[colnames(shadow)])
}
hit_count <- colSums(hit)
p_value <- pbinom(hit_count - 1, runs, prob = .5, lower.tail = FALSE)
p_adjusted <- p.adjust(p_value, method = "bonferroni")
response_means <- sapply(levels(response), function(group) colMeans(scaled_features[response == group, , drop = FALSE]))
feature_summary <- data.frame(feature = colnames(features), label = labels, color = feature_colors,
                              compartment = compartment, hits = hit_count,
                              p_binomial = p_value, p_adjusted = p_adjusted,
                              rd_mean = response_means[, "RD"], pcr_mean = response_means[, "pCR"],
                              median_importance = apply(importance, 2, median), row.names = NULL)
selected <- feature_summary[feature_summary$p_adjusted < .01, ]
selected <- selected[order(selected$median_importance), ]
saveRDS(list(patients = patients, importance = importance, hits = hit,
             feature_summary = feature_summary, selected = selected, n_runs = runs),
        file.path(out, "feature_importance_response_heatmap_simulated.rds"))

# Horizontal importance distributions and their aligned two-column heatmap.
draw <- function() {
  par(mar = rep(0, 4), family = "sans", xpd = NA, ps = 20)
  plot.new(); plot.window(c(0, 1), c(0, 1), xaxs = "i", yaxs = "i")
  text(.015, .96, "e", font = 2, adj = 0, cex = 1.3)
  text(.08, .965, "On-treatment", adj = 0, cex = .85)
  segments(.09, .93, .20, .93, col = "#999999", lwd = 2)
  points(c(.09, .145, .20), rep(.93, 3), pch = 21,
         bg = c("white", "#F5D892", "white"), col = "#999999", cex = c(.65, 1, .65), lwd = 1.2)
  observed <- importance[, selected$feature, drop = FALSE]
  lo <- min(0, floor(min(observed))); hi <- ceiling(max(observed))
  to_x <- function(v) .37 + (v-lo)/(hi-lo) * .32
  ypos <- seq(.85, .25, length.out = nrow(selected))
  text(.03, .55, "Predictor", srt = 90, cex = .7)
  heat_colors <- colorRampPalette(c("#000004", "#45106B", "#B32C70", "#F77D58", "#FCFDBF"))(256)
  heat_color <- function(v) heat_colors[pmax(1, pmin(256, round((v+1)/2*255) + 1))]
  for (i in seq_len(nrow(selected))) {
    row <- selected[i, ]; yy <- ypos[i]
    segments(.37, yy, .69, yy, col = "#DDDDDD", lwd = .6)
    text(.36, yy, row$label, adj = 1, cex = .67)
    stats <- boxplot.stats(importance[, row$feature])
    segments(to_x(stats$stats[1]), yy, to_x(stats$stats[5]), yy, lwd = .8)
    segments(to_x(stats$stats[1]), yy-.012, to_x(stats$stats[1]), yy+.012, lwd = .7)
    segments(to_x(stats$stats[5]), yy-.012, to_x(stats$stats[5]), yy+.012, lwd = .7)
    rect(to_x(stats$stats[2]), yy-.017, to_x(stats$stats[4]), yy+.017,
         col = row$color, border = "#111111", lwd = .7)
    segments(to_x(stats$stats[3]), yy-.017, to_x(stats$stats[3]), yy+.017, lwd = .8)
    if (length(stats$out)) points(to_x(stats$out), rep(yy, length(stats$out)), pch = 16, cex = .14)
    rect(.705, yy-.021, .721, yy+.021, col = heat_color(row$rd_mean), border = NA)
    rect(.722, yy-.021, .738, yy+.021, col = heat_color(row$pcr_mean), border = NA)
    rect(.739, yy-.021, .743, yy+.021, col = if (row$compartment == "TME") "#E9D897" else "#737CBE", border = NA)
    p_label <- if (row$p_adjusted < 2e-16) "<2e-16" else formatC(row$p_adjusted, format = "e", digits = 1)
    text(.748, yy, p_label, adj = 0, cex = .55, col = "#999999")
  }
  segments(.37, .225, .69, .225)
  ticks <- pretty(c(lo, hi), n = 4); ticks <- ticks[ticks >= lo & ticks <= hi]
  for (tick in ticks) {
    xx <- to_x(tick); segments(xx, .225, xx, .216); text(xx, .20, tick, cex = .65)
  }
  text(.53, .15, "Importance", cex = .75)
  text(.53, .118, "(scaled % misclassification rate)", cex = .65)
  text(.713, .19, "RD", srt = 90, cex = .60, adj = 1)
  text(.73, .19, "pCR", srt = 90, cex = .60, adj = 1)
  text(.75, .19, expression(P[binomial]), adj = 0, cex = .58, col = "#999999")
  text(.015, .088, "n (patients/pCR)", adj = 0, cex = .66)
  points(.245, .088, pch = 21, bg = "#D65B4A", cex = 1)
  text(.27, .088, sprintf("C&I (%d/%d)", n, sum(response == "pCR")), adj = 0, cex = .65)
  text(.87, .92, "Scaled\nmean", adj = c(0, 1), cex = .68)
  for (i in seq_len(100)) rect(.87, .54 + (i-1)*.0027, .886, .54+i*.0027,
                              col = heat_colors[round(1+(i-1)*255/99)], border = NA)
  text(.895, c(.54, .675, .81), c("-1", "0", "1"), adj = 0, cex = .58)
  rect(.87, .46, .88, .48, col = "#737CBE", border = NA)
  rect(.87, .425, .88, .445, col = "#E9D897", border = NA)
  text(.89, c(.47, .435), c("Epithelial", "TME"), adj = 0, cex = .55)
}
for (ext in c("png", "pdf", "svg")) {
  path <- file.path(out, paste0("feature_importance_response_heatmap.", ext))
  if (ext == "png") png(path, width = 11, height = 6.5, units = "in", res = 220, type = "cairo")
  if (ext == "pdf") cairo_pdf(path, width = 11, height = 6.5)
  if (ext == "svg") svg(path, width = 11, height = 6.5)
  draw(); dev.off()
}
