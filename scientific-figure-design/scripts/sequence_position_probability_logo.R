#!/usr/bin/env Rscript
# Display nucleotide position probability matrices as information-content logos.
# Reference: Cattle Cell Landscape (2025), Extended Data Figure 1a.
# Input: output directory. Outputs: simulated data and PNG/PDF/SVG figures.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(112329)
library(grid)
consensus <- c("NNATGCAAATNNN", "NATGACGTCATNN", "NNCTTATCTNN", "TCAGCACATGGACAGACCC", "NAAAGAGGAAGTGNN", "NATTCCCCN")
bases <- c("A", "C", "G", "T")
colors <- c(A = "#159646", C = "#24669F", G = "#F2A717", T = "#CF2334")
pwms <- lapply(consensus, function(sequence) {
  letters <- strsplit(sequence, "")[[1]]
  result <- matrix(0, 4, length(letters), dimnames = list(bases, NULL))
  for (i in seq_along(letters)) {
    if (letters[i] == "N") result[, i] <- c(.27, .25, .23, .25) else {
      major <- runif(1, .8, .98)
      result[, i] <- (1-major)/3
      result[letters[i], i] <- major
    }
  }
  result
})
saveRDS(list(position_probabilities = pwms),
        file.path(out, "sequence_position_probability_logo_simulated.rds"))

# Glyphs are stretched to the information contribution of each nucleotide.
glyph <- function(base, x, y, w, h) {
  poly <- function(px, py, fill = colors[base])
    grid.polygon(unit(x+px*w, "native"), unit(y+py*h, "native"), gp = gpar(fill = fill, col = NA))
  if (base == "A") {
    poly(c(0,.4,.6,1,.75,.62,.38,.25), c(0,1,1,0,0,.35,.35,0))
    poly(c(.43,.5,.57), c(.48,.76,.48), "white")
  }
  if (base == "T") poly(c(0,1,1,.61,.61,.39,.39,0), c(1,1,.82,.82,0,0,.82,.82))
  if (base %in% c("C", "G")) {
    theta <- seq(pi*.22, pi*1.78, length.out = 50)
    poly(c(.5+.5*cos(theta), rev(.5+.27*cos(theta))),
         c(.5+.5*sin(theta), rev(.5+.34*sin(theta))))
    if (base == "G") poly(c(.5,1,1,.8,.8,.5), c(.52,.52,.18,.18,.34,.34))
  }
}
draw <- function() {
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(6, 1)))
  for (m in seq_along(pwms)) {
    pushViewport(viewport(layout.pos.row = m, layout.pos.col = 1,
                          xscale = c(-2, ncol(pwms[[m]])+1), yscale = c(-.3, 2.5)))
    grid.text(paste("Motif", m), x = .05, y = .95, just = c("left", "top"),
              gp = gpar(fontfamily = "sans", fontsize = 11, fontface = 2))
    grid.lines(unit(c(.5, ncol(pwms[[m]])+.5), "native"), unit(c(0, 0), "native"), gp = gpar(col = "#AAAAAA"))
    grid.lines(unit(c(.45, .45), "native"), unit(c(0, 2), "native"), gp = gpar(col = "#888888"))
    for (tick in 0:2) {
      grid.text(tick, x = unit(.2, "native"), y = unit(tick, "native"), just = "right", gp = gpar(fontsize = 7))
    }
    grid.text("bits", x = unit(-1, "native"), y = unit(1, "native"), rot = 90, gp = gpar(fontsize = 8))
    for (i in seq_len(ncol(pwms[[m]]))) {
      p <- pwms[[m]][, i]; bits <- 2 + sum(p*log2(p)); heights <- p*bits; y <- 0
      for (j in order(heights)) {
        glyph(bases[j], i-.4, y, .8, heights[j]); y <- y + heights[j]
      }
    }
    popViewport()
  }
  popViewport()
}
for (ext in c("png", "pdf", "svg")) {
  file <- file.path(out, paste0("sequence_position_probability_logo.", ext))
  if (ext == "png") png(file, width = 5, height = 10, units = "in", res = 200, type = "cairo")
  if (ext == "pdf") cairo_pdf(file, width = 5, height = 10)
  if (ext == "svg") svg(file, width = 5, height = 10)
  draw(); dev.off()
}
