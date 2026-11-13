#!/usr/bin/env Rscript
# Compare phenotype associations with response across two treatment arms.
# Reference: Wang et al. (2023), Nature, Figure 2b; DOI 10.1038/s41586-023-06498-3.
# Run: Rscript treatment_interaction_forest.R OUTPUT_DIR
# Simulates patient densities and response; saves inputs, model results and PNG/PDF/SVG.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(2026111401)

# Simulate per-patient cell densities, treatment and binary response.
phenotypes <- c("Fibroblasts", "Myofibroblasts", "Endothelial", "PDPN+ Stromal",
                "M2 Mac", "DCs", "CD4+TCF1+ T", "Neutrophils", "CA9+",
                "CD8+PD1+ TEx", "CD79a+ Plasma", "CD8+ T", "CD8+TCF1+ T",
                "CD20+ B", "Treg", "CD4+PD1+ T", "PD-L1+ APCs", "CD8+GZMB+ T",
                "CD56+ NK", "PD-L1+IDO+ APCs")
phenotype_colors <- c("#C79DAE", "#BD1744", "#F24135", "#EB92A8", "#F1CF12",
                      "#F29A1F", "#6ABF7C", "#F9DDA6", "#921419", "#175B27",
                      "#536026", "#0CA34A", "#79A64D", "#B8D72C", "#80B84D",
                      "#4B9A7C", "#D03B8A", "#B3D9A3", "#AF9827", "#DEA2C9")
n <- 224
arm <- rep(c("C", "C&I"), c(111, 113))
x <- matrix(rgamma(n * length(phenotypes), shape = 4, scale = 5), nrow = n,
            dimnames = list(NULL, phenotypes))
xc <- scale(x, center = TRUE, scale = FALSE)
baseline <- rep(0, length(phenotypes)); baseline[c(12, 17)] <- c(.020, .027)
interaction <- rep(0, length(phenotypes))
interaction[c(11, 14, 16, 18, 19, 20)] <- c(.030, .040, .045, .075, .060, .120)
eta <- -.05 + .1 * (arm == "C&I") + as.vector(xc %*% baseline) +
  as.vector(xc %*% interaction) * (arm == "C&I")
response <- rbinom(n, 1, plogis(eta))
patients <- data.frame(patient = sprintf("P%03d", seq_len(n)), arm = arm,
                       response = response, x, check.names = FALSE)

# Arm-specific logistic odds ratios use density units; the interaction p value
# comes from the combined density-by-treatment model for the same phenotype.
fit_results <- lapply(seq_along(phenotypes), function(j) {
  d <- data.frame(y = response, arm = factor(arm, levels = c("C", "C&I")), density = x[, j])
  arm_fits <- lapply(levels(d$arm), function(a) {
    fit <- glm(y ~ density, data = d[d$arm == a, ], family = binomial())
    z <- coef(summary(fit))["density", ]
    data.frame(arm = a, odds_ratio = exp(z[1]), lower = exp(z[1] - 1.96*z[2]),
               upper = exp(z[1] + 1.96*z[2]), p = z[4])
  })
  fit_interaction <- glm(y ~ density * arm, data = d, family = binomial())
  result <- do.call(rbind, arm_fits)
  result$phenotype <- phenotypes[j]
  result$color <- phenotype_colors[j]
  result$p_interaction <- coef(summary(fit_interaction))["density:armC&I", "Pr(>|z|)"]
  result
})
results <- do.call(rbind, fit_results)
results$q_association <- ave(results$p, results$arm, FUN = function(p) p.adjust(p, method = "BH"))
ranked <- results$phenotype[results$arm == "C&I"][order(results$odds_ratio[results$arm == "C&I"]) ]
results$phenotype <- factor(results$phenotype, levels = ranked)
counts <- aggregate(response ~ arm, data = patients, function(z) c(n = length(z), pCR = sum(z)))
saveRDS(list(patients = patients, results = results, arm_counts = counts),
        file.path(out, "treatment_interaction_forest_simulated.rds"))

# Reproduce the two-arm forest, phenotype color strip and interaction-p column.
draw <- function() {
  par(mar = rep(0, 4), family = "sans", xpd = NA, ps = 18)
  plot.new(); plot.window(c(0, 1), c(0, 1), xaxs = "i", yaxs = "i")
  text(.015, .97, "b", font = 2, cex = 1.4, adj = 0)
  text(.11, .96, "Baseline", cex = .85, adj = 0)
  segments(.12, .93, .22, .93, col = "#999999", lwd = 2)
  points(c(.12, .17, .22), rep(.93, 3), pch = 21,
         bg = c("#B3DDB0", "white", "white"), col = "#999999", cex = c(1.1, .75, .75), lwd = 1.4)
  lo <- floor(min(results$lower, 1) * 10) / 10
  hi <- ceiling(max(results$upper, 1) * 10) / 10
  to_x <- function(z) .38 + (z-lo) / (hi-lo) * .38
  ypos <- seq(.85, .205, length.out = length(ranked))
  text(.035, .52, "Cell density", srt = 90, cex = .8)
  segments(to_x(1), .19, to_x(1), .865, lty = 2, col = "#777777", lwd = .7)
  arrows(.39, .89, .77, .89, length = .065, code = 3, col = "#555555", lwd = 1.2)
  text(.43, .91, "RD", cex = .8); text(.70, .91, "pCR", cex = .8)
  for (i in seq_along(ranked)) {
    row <- results[results$phenotype == ranked[i], ]
    y <- ypos[i]
    text(.348, y, ranked[i], adj = 1, cex = .70)
    rect(.357, y-.014, .365, y+.014, col = row$color[1], border = NA)
    for (k in seq_len(nrow(row))) {
      yy <- y + if (row$arm[k] == "C") .005 else -.005
      line_col <- if (row$p[k] < .05) "#111111" else "#C0C0C0"
      segments(to_x(row$lower[k]), yy, to_x(row$upper[k]), yy, col = line_col, lwd = .8)
      points(to_x(row$odds_ratio[k]), yy, pch = 21, cex = 1.15,
             bg = if (row$arm[k] == "C") "#4F4F4F" else "#D75A48", col = line_col, lwd = .9)
      if (row$q_association[k] < .1) text(to_x(row$odds_ratio[k]), yy, "*", col = "white", cex = .55, font = 2)
    }
    p <- row$p_interaction[1]
    label <- if (p < .001) "<0.001" else formatC(p, format = "f", digits = 2)
    text(.79, y, label, adj = 0, cex = .68, col = if (p < .05) "#111111" else "#999999")
  }
  segments(.38, .19, .76, .19, lwd = 1)
  ticks <- pretty(c(lo, hi), n = 5); ticks <- ticks[ticks >= lo & ticks <= hi]
  for (tick in ticks) {
    xx <- to_x(tick); segments(xx, .19, xx, .181)
    text(xx, .165, format(tick, trim = TRUE), cex = .7)
  }
  text(.57, .133, "Odds ratio per density unit", cex = .75)
  text(.79, .165, expression(P[interaction]), adj = 0, cex = .72)
  text(.025, .105, "P > 0.05", adj = 0, cex = .68, col = "#777777")
  segments(.015, .106, .022, .106, col = "#BBBBBB"); points(.019, .106, pch = 21, bg = "white", col = "#BBBBBB", cex = .6)
  text(.19, .105, "P < 0.05", adj = 0, cex = .68)
  segments(.18, .106, .187, .106); points(.184, .106, pch = 21, bg = "white", cex = .6)
  text(.35, .105, "* BH FDR < 0.1", adj = 0, cex = .68)
  text(.02, .055, "Arm (patients/pCR)", adj = 0, cex = .72)
  arm_colors <- c("#4F4F4F", "#D75A48")
  for (i in seq_len(nrow(counts))) {
    xx <- .40 + (i-1)*.25
    points(xx, .055, pch = 21, bg = arm_colors[i], cex = 1.1)
    text(xx+.023, .055, sprintf("%s (%d/%d)", counts$arm[i], counts$response[i,"n"],
                                 counts$response[i,"pCR"]), adj = 0, cex = .70)
  }
}
for (ext in c("png", "pdf", "svg")) {
  path <- file.path(out, paste0("treatment_interaction_forest.", ext))
  if (ext == "png") png(path, width = 8, height = 8, units = "in", res = 220, type = "cairo")
  if (ext == "pdf") cairo_pdf(path, width = 8, height = 8)
  if (ext == "svg") svg(path, width = 8, height = 8)
  draw(); dev.off()
}
