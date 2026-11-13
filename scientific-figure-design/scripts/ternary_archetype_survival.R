#!/usr/bin/env Rscript
# Compare three archetype proportions, sample classes and a continuous outcome.
# Visual reference: Mangiante et al. (2023), Nature Genetics, Figure 2b.
# The author notebook shows archetype-coordinate projection and ternary geometry:
# https://github.com/IARCbioinfo/MESOMICS_data/tree/main/phenotypic_map/MESOMICS
# Run: Rscript ternary_archetype_survival.R OUTPUT_DIR
# Saves simulated sample data and a ternary plot in PNG, PDF and SVG formats.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(2026111302)

# Draw class-associated compositions from Dirichlet distributions.
n <- 120
types <- c("MME", "MMB", "MMS")
type_colors <- c(MME = "#79C9B0", MMB = "#FFBF86", MMS = "#B83D70")
sample_type <- sample(types, n, replace = TRUE, prob = c(.63, .20, .17))
shape <- rbind(MME = c(1.1, 2.0, 4.2), MMB = c(2.3, 1.7, 2.3), MMS = c(4.7, 1.4, 1.0))
immune_dominant <- sample.int(n, 10)
proportions <- t(vapply(seq_len(n), function(i) {
  alpha <- if (i %in% immune_dominant) c(.8, 6.0, .8) else shape[sample_type[i], ]
  z <- rgamma(3, shape = alpha)
  z / sum(z)
}, numeric(3)))
colnames(proportions) <- c("cell_division", "immune_interaction", "acinar")
survival <- pmax(2, pmin(42, 3 + 25 * proportions[, 2] +
                            40 * proportions[, 3] + rnorm(n, 0, 3.8)))
samples <- data.frame(sample = sprintf("S%03d", seq_len(n)), type = sample_type,
                      proportions, survival_months = survival)

# Plot coordinates are barycentric combinations of the three vertices.
left <- c(.43, .17); top <- c(.73, .17 + .6 * sqrt(3) / 2); right <- c(1.03, .17)
coordinates <- function(p) {
  outer(p[, 1], left) + outer(p[, 2], top) + outer(p[, 3], right)
}
xy <- coordinates(proportions)
samples$x <- xy[, 1]; samples$y <- xy[, 2]
means <- aggregate(proportions, list(type = factor(sample_type, levels = types)), mean)

# A kernel-weighted mean uses the same simulated samples as the points.
N <- 30
triangles <- list()
k <- 0
vertex <- function(i, j) c((N - i - j) / N, j / N, i / N)
for (i in 0:(N - 1)) for (j in 0:(N - i - 1)) {
  k <- k + 1
  triangles[[k]] <- rbind(vertex(i, j), vertex(i + 1, j), vertex(i, j + 1))
  if (i + j < N - 1) {
    k <- k + 1
    triangles[[k]] <- rbind(vertex(i + 1, j), vertex(i, j + 1), vertex(i + 1, j + 1))
  }
}
centers <- t(vapply(triangles, colMeans, numeric(3)))
center_xy <- coordinates(centers)
distance2 <- outer(center_xy[, 1], xy[, 1], "-")^2 + outer(center_xy[, 2], xy[, 2], "-")^2
weights <- exp(-distance2 / (2 * .08^2))
surface <- as.vector(weights %*% survival / rowSums(weights))
saveRDS(list(samples = samples, group_mean_proportions = means,
             surface_centers = centers, surface_months = surface, bandwidth = .08),
        file.path(out, "ternary_archetype_survival_simulated.rds"))

sector <- function(cx, cy, angle0, angle1, radius, fill) {
  theta <- seq(angle0, angle1, length.out = 30) * pi / 180
  polygon(c(cx, cx + radius * cos(theta)), c(cy, cy + radius * sin(theta)),
          col = fill, border = "white", lwd = .7)
}

draw <- function() {
  par(mar = rep(0, 4), family = "sans", xpd = NA, cex = 1.4)
  plot.new(); plot.window(c(0, 1.50), c(0, .88), asp = 1, xaxs = "i", yaxs = "i")
  text(.025, .855, "b", font = 2, cex = 1.7, adj = c(0, 1))
  text(top[1], .84, "Tumor–immune interaction", col = "#87ABC4", cex = 1.05)
  fill_colors <- colorRampPalette(c("#F9F9FC", "#DDD9EE", "#A69ACF", "#6F5AAC", "#362277"))(256)
  for (i in seq_along(triangles)) {
    p <- coordinates(triangles[[i]])
    idx <- max(1, min(256, 1 + floor(surface[i] / 42 * 255)))
    polygon(p[, 1], p[, 2], col = fill_colors[idx], border = NA)
  }
  polygon(rbind(left, top, right), border = "#999999", lwd = .7)
  for (v in seq(.2, .8, .2)) {
    points3 <- rbind(c(v, 1-v, 0), c(v, 0, 1-v),
                     c(0, v, 1-v), c(1-v, v, 0), c(0, 1-v, v), c(1-v, 0, v))
    z <- coordinates(points3)
    segments(z[c(1,3,5), 1], z[c(1,3,5), 2], z[c(2,4,6), 1], z[c(2,4,6), 2],
             col = adjustcolor("white", .20), lwd = .45)
  }
  center <- colMeans(rbind(left, top, right))
  segments(center[1], center[2], c(left[1], top[1], right[1]), c(left[2], top[2], right[2]),
           col = "#A5A5A5", lwd = .7)
  points(xy[, 1], xy[, 2], pch = 21, bg = adjustcolor(type_colors[sample_type], .88),
         col = "white", lwd = .9, cex = 1.85)
  points(c(left[1]-.055, top[1], right[1]+.055), c(left[2]-.045, top[2]+.052, right[2]-.045),
         pch = 21, bg = c("#D35470", "#83A9C0", "#91C47A"), col = "#AAAAAA", cex = 2.1)
  text(c(left[1]-.055, top[1], right[1]+.055), c(left[2]-.045, top[2]+.052, right[2]-.045),
       c("1", "2", "3"), cex = .85)
  text(left[1]-.055, .055, "Cell division", col = "#E45A6D", cex = 1.02)
  text(right[1]+.06, .055, "Acinar", col = "#91C47A", cex = 1.02)
  text(.73, .09, "Cold tumors", cex = .9)
  text(.49, .48, "Invasion and tissue remodeling", srt = 60, cex = .84)
  text(.98, .51, "Good prognosis", srt = -60, cex = .84)

  text(1.145, .75, "Type", adj = 0, cex = 1.05)
  for (i in seq_along(types)) {
    points(1.158, .715 - (i-1)*.033, pch = 21, bg = type_colors[i], col = "white", cex = 1.45)
    text(1.185, .715 - (i-1)*.033, types[i], adj = 0, cex = .88)
  }
  text(1.145, .587, "Survival (months)", adj = 0, cex = .98)
  for (i in seq_len(100)) {
    rect(1.15, .38 + (i-1)*.0016, 1.18, .38 + i*.0016,
         col = fill_colors[round(1+(i-1)*255/99)], border = NA)
  }
  for (v in c(10, 20, 30, 40)) {
    yy <- .38 + .16*v/42; segments(1.18, yy, 1.19, yy, col = "#777777")
    text(1.20, yy, v, adj = 0, cex = .75)
  }

  # Each polar bar uses the mean of its corresponding archetype within type.
  for (i in seq_along(types)) {
    radius <- .14 * means[i, "cell_division"]
    sector(.27, .17, 118 + (i-1)*25, 141 + (i-1)*25, radius, type_colors[i])
    radius <- .14 * means[i, "acinar"]
    sector(1.20, .17, 68 - (i-1)*25, 91 - (i-1)*25, radius, type_colors[i])
  }
  text(.115, .16, "MMS", srt = -22, cex = .67)
  text(.15, .245, "MMB", srt = -45, cex = .67)
  text(.22, .30, "MME", srt = -65, cex = .67)
  text(1.215, .325, "MME", srt = 65, cex = .67)
  text(1.29, .285, "MMB", srt = 45, cex = .67)
  text(1.34, .22, "MMS", srt = 22, cex = .67)
  text(.345, .19, "Mean proportion", srt = 90, cex = .72)
  text(1.115, .19, "Mean proportion", srt = 90, cex = .72)
  segments(c(.32, 1.16), .17, c(.32, 1.16), .31, col = "#888888", lwd = .6)
  for (v in c(0, .5, 1)) {
    segments(c(.32, 1.16), .17 + .14*v, c(.325, 1.165), .17 + .14*v, col = "#888888", lwd = .6)
    text(.31, .17 + .14*v, v, adj = 1, cex = .65, col = "#666666")
    text(1.15, .17 + .14*v, v, adj = 1, cex = .65, col = "#666666")
  }
}

png(file.path(out, "ternary_archetype_survival.png"), width = 2400, height = 1408, res = 200, type = "cairo"); draw(); dev.off()
cairo_pdf(file.path(out, "ternary_archetype_survival.pdf"), width = 12, height = 7.04); draw(); dev.off()
svg(file.path(out, "ternary_archetype_survival.svg"), width = 12, height = 7.04); draw(); dev.off()
