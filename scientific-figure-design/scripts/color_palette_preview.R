# Compare the first seven dittoSeq colours and the ten ggsci NPG colours.
# The fixed swatches follow the packages' published palettes.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
ditto <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
npg <- c("#E64B35", "#4DBBD5", "#00A087", "#3C5488", "#F39B7F", "#8491B4", "#91D1C2", "#DC0000", "#7E6148", "#B09C85")
path <- file.path(out, "color_palette_preview.png")
png(path, width = 1800, height = 500, res = 150, type = "cairo")
par(mar = c(0, 0, 0, 0), family = "sans", xaxs = "i", yaxs = "i")
plot.new()
plot.window(xlim = c(0, 12), ylim = c(0, 3.5))
text(.2, 3.25, "Scientific figure color palettes", adj = 0, cex = 1.2, font = 2)
for (i in seq_along(ditto)) {
  x <- .2 + (i - 1) * 1.15
  rect(x, 2.05, x + .95, 2.75, col = ditto[i], border = NA)
  text(x + .475, 1.87, ditto[i], cex = .68)
}
text(.2, 2.94, "dittoSeq - first 7", adj = 0, cex = .8)
for (i in seq_along(npg)) {
  x <- .2 + (i - 1) * 1.15
  rect(x, .55, x + .95, 1.25, col = npg[i], border = NA)
  text(x + .475, .37, npg[i], cex = .68)
}
text(.2, 1.44, "ggsci - NPG (10 colors)", adj = 0, cex = .8)
dev.off()
cat("Saved", path, "\n")
