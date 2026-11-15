#!/usr/bin/env Rscript
# Display genomic sectors, copy-number signals and paired breakpoint links.
# Reference: Mangiante et al. (2023), Nature Genetics, Figure 3c.
# Input: output directory. Outputs: simulated data and PNG/PDF/SVG figures.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(2026111304)

sectors <- data.frame(chr = c("Chr6", "Chr7", "Chr17", "Chr10"),
  start = c(92, 145, 255, 310), end = c(143, 253, 308, 449),
  length_mb = c(170, 159, 83, 133),
  color = c("#A0A0A0", "#A0A0A0", "#61BBD0", "#AA5030"))
links <- data.frame(start = c(runif(17, 160, 250), runif(11, 95, 135), runif(9, 260, 300)),
  end = c(runif(17, 335, 418), runif(11, 330, 405), runif(9, 175, 245)),
  bend = runif(37, -.09, .09))
regions <- data.frame(start = c(107, 170, 274, 340, 385), end = c(115, 180, 285, 352, 397))
track <- do.call(rbind, lapply(seq_len(nrow(sectors)), function(i) {
  angle <- seq(sectors$start[i], sectors$end[i], length.out = 50)
  data.frame(chr = sectors$chr[i], angle = angle,
             value = sin(angle * pi / 38 + i) * .28 + rnorm(50, 0, .13))
}))
position_mb <- function(chr, angle) {
  s <- sectors[match(chr, sectors$chr), ]
  (angle - s$start) / (s$end - s$start) * s$length_mb
}
links$from_chr <- rep(c("Chr7", "Chr6", "Chr17"), c(17, 11, 9))
links$to_chr <- rep(c("Chr10", "Chr10", "Chr7"), c(17, 11, 9))
links$from_mb <- position_mb(links$from_chr, links$start)
links$to_mb <- position_mb(links$to_chr, links$end)
regions$chr <- c("Chr6", "Chr7", "Chr17", "Chr10", "Chr10")
regions$start_mb <- position_mb(regions$chr, regions$start)
regions$end_mb <- position_mb(regions$chr, regions$end)
track$position_mb <- position_mb(track$chr, track$angle)
saveRDS(list(sectors = sectors, links = links, regions = regions, track = track),
        file.path(out, "genomic_breakpoint_links_circos_simulated.rds"))

xy <- function(angle, radius) cbind(.47 + radius*cos(angle*pi/180), .47 + radius*sin(angle*pi/180))
ring <- function(start, end, inner, outer, color, border = NA) {
  outer_xy <- xy(seq(start, end, length.out = 45), outer)
  inner_xy <- xy(seq(end, start, length.out = 45), inner)
  polygon(rbind(outer_xy, inner_xy), col = color, border = border, lwd = .4)
}
draw <- function() {
  par(mar = rep(0, 4), family = "sans", xpd = NA, cex = 1.2)
  plot.new(); plot.window(c(0, .94), c(0, 1), asp = 1, xaxs = "i", yaxs = "i")
  text(.47, .97, "Genomic breakpoint links", cex = .95)
  for (i in seq_len(nrow(links))) {
    p0 <- xy(links$start[i], .235)[1, ]; p1 <- xy(links$end[i], .235)[1, ]
    control <- c(.47 + links$bend[i], .47 - links$bend[i]/2)
    t <- seq(0, 1, length.out = 50)
    lines((1-t)^2*p0[1] + 2*(1-t)*t*control[1] + t^2*p1[1],
          (1-t)^2*p0[2] + 2*(1-t)*t*control[2] + t^2*p1[2], lwd = 1)
  }
  for (i in seq_len(nrow(sectors))) {
    s <- sectors[i, ]; ring(s$start, s$end, .317, .33, s$color)
    edges <- seq(s$start, s$end, length.out = 17)
    for (j in seq_len(16)) {
      color <- if (j %% 4 == 0) "#3A3A3A" else if (j %% 2) "#C9C9C9" else "#EFEFEF"
      ring(edges[j]+.3, edges[j+1]-.3, .302, .315, color, "white")
      ring(edges[j]+.3, edges[j+1]-.3, .288, .298, if (j %% 3 == 0) "#BABABA" else "#EEEEEE", "white")
    }
    d <- track[track$chr == s$chr, ]; pos <- xy(d$angle, .264 + .025*abs(d$value))
    for (j in seq_len(nrow(d)-1)) lines(pos[j:(j+1), ], col = if (d$value[j] >= 0) "#EF382F" else "#4E8DE6", lwd = .9)
    label <- xy((s$start+s$end)/2, .375)
    text(label[1], label[2], s$chr, col = s$color, cex = .76)
  }
  for (i in seq_len(nrow(regions))) ring(regions$start[i], regions$end[i], .316, .332, "#EE5621")
  rect(.435, .476, .505, .516, col = "white", border = NA)
  text(.47, .496, "Links", cex = .9)
  text(.465, .68, "Gain", col = "#E9322A", cex = .8)
  text(.42, .628, "Loss", col = "#5589D8", cex = .75)
  text(.50, .07, "Highlighted region", col = "#EE5621", cex = .8)
  segments(.60, .11, .55, .15, col = "#EE5621", lwd = .7)
}
for (ext in c("png", "pdf", "svg")) {
  file <- file.path(out, paste0("genomic_breakpoint_links_circos.", ext))
  if (ext == "png") png(file, width = 6, height = 6, units = "in", res = 200, type = "cairo")
  if (ext == "pdf") cairo_pdf(file, width = 6, height = 6)
  if (ext == "svg") svg(file, width = 6, height = 6)
  draw(); dev.off()
}
