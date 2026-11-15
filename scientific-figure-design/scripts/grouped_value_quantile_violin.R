#!/usr/bin/env Rscript
# Compare bounded continuous values between two groups using violins and points.
# Reference: Mangiante et al. (2023), Nature Genetics, Figure 3c.
# Input: output directory. Outputs: simulated data and PNG/PDF/SVG figures.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(2026111304)
highlight <- c(.96, .41, .34)
values1 <- c(highlight, rbeta(37, 3.6, 1.7))
values2 <- c(rbeta(95, 1.1, 5), rbeta(45, 6, 1.1))
data <- data.frame(group = rep(c("Group A", "Group B"), c(length(values1), length(values2))),
                   value = c(values1, values2), jitter = runif(180, -.035, .035))
p_value <- wilcox.test(values1, values2, exact = FALSE)$p.value
saveRDS(list(observations = data, p_value = p_value),
        file.path(out, "grouped_value_quantile_violin_simulated.rds"))

draw <- function() {
  par(mar = rep(0, 4), family = "sans", xpd = NA, cex = 1.2)
  plot.new(); plot.window(c(0, 1.2), c(0, 1), xaxs = "i", yaxs = "i")
  text(.6, .97, "Grouped value distributions", cex = .95)
  ymap <- function(v) .16 + .61*v
  violin <- function(v, x) {
    d <- density(v, from = 0, to = 1, n = 256, bw = .11)
    width <- .135 * d$y/max(d$y)
    polygon(c(x-width, rev(x+width)), c(ymap(d$x), rev(ymap(d$x))),
            col = "#D7D7D7", border = "#BEBEBE", lwd = .6)
    segments(x-.085, ymap(median(v)), x+.085, ymap(median(v)), lwd = 1.1)
  }
  x1 <- .4; x2 <- .85
  violin(values1, x1); violin(values2, x2)
  points(ifelse(data$group == "Group A", x1, x2) + data$jitter, ymap(data$value),
         pch = 16, col = adjustcolor("#AFAFAF", .38), cex = .38)
  points(x1 + data$jitter[1:3], ymap(highlight), pch = 21, bg = "#E8342C", col = "black", cex = .52)
  for (i in seq_along(highlight)) {
    x <- x1-.165; y <- ymap(highlight[i]) - c(.045, -.035, .045)[i]
    rect(x, y-.027, x+.20, y+.027, col = "white", border = "#EB3D37", lwd = .65)
    text(x+.1, y, paste("Feature", LETTERS[i]), col = "#E6322A", font = 3, cex = .7)
  }
  segments(.20, ymap(0), 1.08, ymap(0), col = "#777777", lwd = .6)
  segments(.20, ymap(0), .20, ymap(1), col = "#777777", lwd = .6)
  for (v in seq(0, 1, .25)) {
    segments(.187, ymap(v), .20, ymap(v), col = "#777777", lwd = .6)
    text(.175, ymap(v), format(v, nsmall = if (v == 0) 0 else 2), adj = 1, cex = .69)
  }
  text(.055, .47, "Value (quantile)", srt = 90, cex = .76)
  text(c(x1, x2), .105, c("Group A", "Group B"), cex = .76)
  segments(x1, .81, x2, .81, lwd = 1)
  text((x1+x2)/2, .845, paste0("P value = ", format.pval(p_value, digits = 2, eps = 1e-16)), cex = .75)
}
for (ext in c("png", "pdf", "svg")) {
  file <- file.path(out, paste0("grouped_value_quantile_violin.", ext))
  if (ext == "png") png(file, width = 6.6, height = 5.5, units = "in", res = 200, type = "cairo")
  if (ext == "pdf") cairo_pdf(file, width = 6.6, height = 5.5)
  if (ext == "svg") svg(file, width = 6.6, height = 5.5)
  draw(); dev.off()
}
