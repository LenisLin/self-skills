#!/usr/bin/env Rscript
# Compare total counts and category composition for each group.
# Reference: Karimi et al. (2023), Nature, Figure 3h, doi:10.1038/s41586-022-05680-3.
# Adapt the group-by-category count matrix and named colors to your data.
# Run: Rscript group_category_count_stacked_bars.R OUTPUT_DIR
# Outputs: simulated count matrix and PNG, PDF and SVG figures.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(2026111905)

groups <- paste("Group", 1:15)
categories <- paste("Type", LETTERS[1:7])
totals <- c(1500, 3800, 5700, 10500, 3400, 9500, 5000, 4200, 7600, 3800, 5200, 8300, 3100, 3600, 8700)
colors <- c("#D00058", "#BED8F6", "#0000B8", "#95E675", "#168F08", "#D55A00", "#F0B579")
group_colors <- c("#00553B", "#75B7D6", "#ADC3DE", "#189052", "#00669C", "#36AA5B",
                  "#C9A7CB", "#D6D2E5", "#5B9FC4", "#C48CBD", "#E8E3F1", "#005182",
                  "#E41A91", "#E05DA9", "#A3DB7B")
alpha <- rbind(c(6,1,.2,.2,.05,.05,.05), c(4,2,.2,.2,.1,.05,.05),
               c(3,3,.2,.2,.1,.05,.05), c(6,1,.3,.2,.1,.05,.05),
               c(5,1,.2,.2,.1,.05,.05), c(4,1.2,.3,.4,.1,.1,.1),
               c(3,1,.8,.5,.1,.1,.1), c(1,1,2,1,.1,.1,.1),
               c(2,1,.7,.5,.4,.3,.3), c(1,1,.3,.5,.3,.2,.1),
               c(1,1.5,.2,.2,.2,.1,.1), c(1,4,.5,1,.4,.3,.2),
               c(2,1,.2,.2,.1,.1,.1), c(1,1,.2,.2,.1,.1,.1),
               c(2,3,.4,.4,.1,.1,.1))
counts <- t(vapply(seq_along(groups), function(i) {
  p <- rgamma(length(categories), alpha[i, ]); p <- p/sum(p)
  as.vector(rmultinom(1, totals[i], p))
}, integer(length(categories))))
dimnames(counts) <- list(groups, categories)
saveRDS(list(counts = counts, category_colors = setNames(colors, categories),
             group_colors = setNames(group_colors, groups)),
        file.path(out, "group_category_count_stacked_bars_simulated.rds"))

draw <- function() {
  par(mar = c(0, 0, 0, 0), family = "sans", xpd = NA)
  plot.new(); plot.window(c(0, 1), c(0, 1), xaxs = "i", yaxs = "i")
  left <- .24; right <- .94; top <- .87; bottom <- .22
  y <- seq(top, bottom, length.out = length(groups)); xmax <- 12000
  xmap <- function(value) left + value/xmax*(right-left)
  for (i in seq_along(groups)) {
    points(.15, y[i], pch = 21, bg = group_colors[i], col = NA, cex = 2.0)
    text(.15, y[i], i, col = if (i %in% c(3, 7, 8, 10, 11, 15)) "#333333" else "white", cex = .68)
    lower <- 0
    for (j in seq_along(categories)) {
      upper <- lower + counts[i, j]
      rect(xmap(lower), y[i]-.012, xmap(upper), y[i]+.012, col = colors[j], border = NA)
      lower <- upper
    }
  }
  segments(left, top+.035, right, top+.035, lwd = .8)
  for (tick in c(0, 5000, 10000)) {
    segments(xmap(tick), top+.035, xmap(tick), top+.045, lwd = .7)
    text(xmap(tick), top+.065, format(tick, big.mark = ","), cex = .7)
  }
  text((left+right)/2, .975, "Total count", cex = .8)
  text(.12, .155, "Category", adj = 0, cex = .75, font = 2)
  for (j in seq_along(categories)) {
    col <- (j-1) %% 4; row <- (j-1) %/% 4
    x <- .12 + .22*col; yy <- .12 - .04*row
    rect(x, yy-.01, x+.014, yy+.01, col = colors[j], border = NA)
    text(x+.021, yy, categories[j], adj = 0, cex = .7)
  }
}
for (ext in c("png", "pdf", "svg")) {
  file <- file.path(out, paste0("group_category_count_stacked_bars.", ext))
  if (ext == "png") png(file, width = 7, height = 9, units = "in", res = 200, type = "cairo")
  if (ext == "pdf") cairo_pdf(file, width = 7, height = 9)
  if (ext == "svg") svg(file, width = 7, height = 9)
  draw(); dev.off()
}
