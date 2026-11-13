#!/usr/bin/env Rscript
# Compare phenotype composition over time across treatment and response groups.
# Reference: Wang et al. (2023), Nature, Figure 5c; DOI 10.1038/s41586-023-06498-3.
# Run: Rscript cell_composition_timecourse_small_multiples.R OUTPUT_DIR
# Simulates patient-level compartment proportions and saves data plus PNG/PDF/SVG.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(2026111402)

tme <- c("CD8+ T", "CD8+GZMB+ T", "CD8+TCF1+ T", "CD8+PD1+ TEx", "CD4+TCF1+ T",
         "CD4+PD1+ T", "Treg", "CD20+ B", "CD79a+ Plasma", "CD56+ NK", "M2 Mac",
         "DCs", "Neutrophils", "PD-L1+ APCs", "PD-L1+IDO+ APCs", "Endothelial",
         "Fibroblasts", "Myofibroblasts", "PDPN+ Stromal", "CA9+")
epithelial <- c("CKhi GATA3+", "CK8/18med", "CKlo GATA3+", "AR+ LAR", "panCKmed",
                "Basal", "Vimentin+ EMT", "CD15+", "CD56+ NE", "CA9+ Hypoxia",
                "pH2AX+ DSB", "Apoptosis", "MHCI&IIhi", "PD-L1+IDO+", "PD-L1+GZMB+",
                "Helios+", "TCF1+")
tme_colors <- c("#0AA44E", "#BCDBAB", "#83A451", "#245F30", "#6EC086", "#51977F",
                "#80B74B", "#B9D52A", "#57622A", "#B59B28", "#E7C90B", "#F39422",
                "#F7DEA4", "#D13B8C", "#DDA7CB", "#F34032", "#C9A1B0", "#C71848",
                "#EC93A8", "#8F101D")
epi_colors <- c("#7257B0", "#93C0E4", "#3E2465", "#16616E", "#5A88BD", "#2AB9AC",
                "#6D51A0", "#8F82BF", "#262626", "#4655A7", "#5985CA", "#5AC5EB",
                "#4D5EB4", "#C6ADD4", "#8B6CA8", "#BFAFC9", "#3998C8")
timepoints <- c("B", "OT", "PT")

# Patients contribute proportions within each compartment; each row sums to one.
groups <- expand.grid(timepoint = timepoints, response = c("RD", "pCR"),
                      arm = c("C", "C&I"), stringsAsFactors = FALSE)
groups$n_tme <- c(48, 42, 43, 45, 39, 42, 49, 42, 41, 46, 40, 44)
groups$n_epi <- c(46, 37, 25, 43, 35, 0, 47, 38, 27, 44, 34, 0)
make_parameters <- function(features) {
  n <- length(features)
  data.frame(phenotype = features, baseline = rnorm(n, 0, .45),
             on = rnorm(n, 0, .40), post = rnorm(n, 0, .40),
             response = rnorm(n, 0, .20), treatment = rnorm(n, 0, .18),
             interaction = rnorm(n, 0, .20))
}
tme_par <- make_parameters(tme); epi_par <- make_parameters(epithelial)
tme_par$interaction[match(c("CD8+GZMB+ T", "CD8+PD1+ TEx"), tme)] <- c(1.0, .9)
epi_par$interaction[match("CD15+", epithelial)] <- -.8
simulate_compartment <- function(params, compartment, group, n) {
  shift <- params$baseline + params$on * (group$timepoint == "OT") +
    params$post * (group$timepoint == "PT") + params$response * (group$response == "pCR") +
    params$treatment * (group$arm == "C&I") + params$interaction *
    (group$arm == "C&I") * (group$response == "pCR") * (group$timepoint == "OT")
  mean_fraction <- exp(shift) / sum(exp(shift))
  values <- matrix(rgamma(n * nrow(params), shape = rep(mean_fraction * 160, each = n)), nrow = n)
  values <- values / rowSums(values)
  data.frame(patient = rep(sprintf("%s_%s_%s_%03d", group$arm, group$response,
                                   group$timepoint, seq_len(n)), times = nrow(params)),
             compartment = compartment, arm = group$arm, response = group$response,
             timepoint = group$timepoint, phenotype = rep(params$phenotype, each = n),
             proportion = as.vector(values))
}
patient_data <- do.call(rbind, unlist(lapply(seq_len(nrow(groups)), function(i) {
  group <- groups[i, ]
  result <- list(simulate_compartment(tme_par, "TME", group, group$n_tme))
  if (group$n_epi > 0) result[[2]] <- simulate_compartment(epi_par, "Epithelial", group, group$n_epi)
  result
}), recursive = FALSE))

# Z-score group means within each phenotype; scale the group variance by the
# same between-group standard deviation used for its mean.
keys <- c("compartment", "phenotype", "arm", "response", "timepoint")
means <- aggregate(patient_data$proportion, patient_data[keys], mean)
variances <- aggregate(patient_data$proportion, patient_data[keys], var)
names(means)[6] <- "mean_proportion"; names(variances)[6] <- "variance"
summary <- merge(means, variances, by = keys)
summary$z_mean <- NA_real_; summary$scaled_variance <- NA_real_
for (comp in c("TME", "Epithelial")) for (feature in unique(summary$phenotype[summary$compartment == comp])) {
  i <- which(summary$compartment == comp & summary$phenotype == feature)
  spread <- sd(summary$mean_proportion[i])
  summary$z_mean[i] <- (summary$mean_proportion[i] - mean(summary$mean_proportion[i])) / spread
  summary$scaled_variance[i] <- summary$variance[i] / spread^2
}
summary$point_cex <- .30 + .45 / (1 + summary$scaled_variance / median(summary$scaled_variance))
saveRDS(list(patient_proportions = patient_data, group_summary = summary, group_sizes = groups),
        file.path(out, "cell_composition_timecourse_small_multiples_simulated.rds"))

# Four columns of phenotype sparklines; within each row, arm and response are
# shown by line placement and marker fill. Circle size decreases with scaled variance.
draw <- function() {
  par(mar = rep(0, 4), family = "sans", xpd = NA, ps = 18)
  plot.new(); plot.window(c(0, 44), c(2.6, 18), xaxs = "i", yaxs = "i")
  text(.18, 17.8, "c", font = 2, adj = 0, cex = 1.3)
  segments(1, 17.20, 21.6, 17.20, col = "#E9D897", lwd = 4)
  segments(22.1, 17.20, 43.5, 17.20, col = "#737CBE", lwd = 4)
  text(11.3, 17.5, "TME", cex = .8); text(32.7, 17.5, "Epithelial", cex = .8)
  cols <- list(tme[1:10], tme[11:20], epithelial[1:9], epithelial[10:17])
  colors <- list(tme_colors[1:10], tme_colors[11:20], epi_colors[1:9], epi_colors[10:17])
  bases <- c(.9, 11.6, 22.3, 33.0)
  for (col in seq_along(cols)) {
    x0 <- bases[col]
    points(c(x0+.5, x0+2.8), rep(16.7, 2), pch = 21, bg = c("#505050", "#D65B4A"), cex = .75)
    text(c(x0+.8, x0+3.1), rep(16.7, 2), c("C", "C&I"), adj = 0, cex = .67)
    for (j in seq_along(cols[[col]])) {
      feature <- cols[[col]][j]
      comp <- if (col < 3) "TME" else "Epithelial"
      center <- 15.9 - (j-1) * .96
      highlight <- feature %in% c("CD8+GZMB+ T", "CD8+PD1+ TEx", "CD15+")
      if (highlight) rect(x0+.12, center-.39, x0+5.0, center+.39, col = "#E8E6E6", border = NA)
      segments(x0+.15, center-.37, x0+.15, center+.37, lwd = .6)
      segments(x0+.15, center, x0+4.65, center, col = "#E83B38", lty = 3, lwd = .8)
      rect(x0+4.82, center-.36, x0+4.96, center+.36, col = colors[[col]][j], border = NA)
      text(x0+5.12, center, feature, adj = 0, cex = .70)
      for (a in seq_along(c("C", "C&I"))) for (r in c("RD", "pCR")) {
        z <- summary[summary$compartment == comp & summary$phenotype == feature &
                       summary$arm == c("C", "C&I")[a] & summary$response == r, ]
        z <- z[match(timepoints, z$timepoint, nomatch = 0), ]
        xx <- x0 + if (a == 1) .42 else 2.75
        xx <- xx + (match(z$timepoint, timepoints)-1) * .65
        yy <- center + .12*z$z_mean
        lines(xx, yy, col = if (r == "pCR") "#111111" else "#888888", lwd = .65)
        points(xx, yy, pch = 21, bg = if (r == "pCR") "#111111" else "#D5D5D5",
               col = if (r == "pCR") "#111111" else "#777777", cex = z$point_cex, lwd = .55)
      }
    }
    # The colored dots describe the three timepoints in the two treatment arms.
    under <- 15.9 - length(cols[[col]]) * .96 + .13
    for (start in c(.42, 2.75)) {
      xx <- x0 + start + (0:2)*.65
      segments(xx[1], under, xx[3], under, col = "#BBBBBB", lwd = 1)
      points(xx, rep(under, 3), pch = 21, bg = c("#B6DDAE", "#F2D899", "#E1ACCF"),
             col = "#AAAAAA", cex = .45)
    }
  }
  text(.25, 11.2, "Scaled mean", srt = 90, cex = .72)
  text(1.0, 4.7, "Legend", font = 2, adj = 0, cex = .8)
  points(c(1.3, 4.0), c(4.25, 4.25), pch = 21, bg = c("#111111", "#D5D5D5"), cex = .8)
  text(c(1.65, 4.35), c(4.25, 4.25), c("pCR", "RD"), adj = 0, cex = .66)
  text(1, 3.75, "Circle size decreases with scaled variance", adj = 0, cex = .60)
  text(1, 3.35, "Red dotted line: zero; B / OT / PT: timepoints", adj = 0, cex = .60)
  # A miniature y-axis decodes the common z-score scale in every sparkline.
  segments(12.2, 3.66, 12.2, 4.14, lwd = .65)
  for (z in c(-2, 0, 2)) {
    yy <- 3.9 + .12*z
    segments(12.1, yy, 12.2, yy, lwd = .65)
    text(12.0, yy, z, adj = 1, cex = .55)
  }
  segments(12.2, 3.9, 16.1, 3.9, col = "#E83B38", lty = 3)
  lines(c(12.5, 13.15, 13.8), c(4.02, 4.10, 4.04), lwd = .65)
  points(c(12.5, 13.15, 13.8), c(4.02, 4.10, 4.04), pch = 16, cex = .35)
  lines(c(12.5, 13.15, 13.8), c(3.78, 3.72, 3.76), col = "#888888", lwd = .65)
  points(c(12.5, 13.15, 13.8), c(3.78, 3.72, 3.76), pch = 21, bg = "#D5D5D5", cex = .4)
  text(c(12.5, 13.15, 13.8), rep(3.43, 3), timepoints, cex = .5)
  legend_counts <- function(comp, x, y) {
    text(x, y, paste(comp, "patients per timepoint (B / OT / PT)"), adj = 0, font = 2, cex = .64)
    for (i in seq_along(c("C", "C&I"))) for (j in seq_along(c("RD", "pCR"))) {
      rows <- groups[groups$arm == c("C", "C&I")[i] & groups$response == c("RD", "pCR")[j], ]
      ns <- if (comp == "TME") rows$n_tme else rows$n_epi
      lab <- ifelse(ns == 0, "–", as.character(ns))
      text(x, y - .37 * ((i-1)*2+j),
           paste0(c("C", "C&I")[i], " ", c("RD", "pCR")[j], ":  ", paste(lab, collapse = " / ")),
           adj = 0, cex = .60)
    }
  }
  legend_counts("TME", 21.9, 4.7)
  legend_counts("Epithelial", 33.2, 4.7)
}
for (ext in c("png", "pdf", "svg")) {
  path <- file.path(out, paste0("cell_composition_timecourse_small_multiples.", ext))
  if (ext == "png") png(path, width = 15, height = 11.5, units = "in", res = 200, type = "cairo")
  if (ext == "pdf") cairo_pdf(path, width = 15, height = 11.5)
  if (ext == "svg") svg(path, width = 15, height = 11.5)
  draw(); dev.off()
}
