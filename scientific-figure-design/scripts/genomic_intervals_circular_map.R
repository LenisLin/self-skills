#!/usr/bin/env Rscript
# Show ordered genomic intervals and their annotated features on a circular map.
# Reference: Mangiante et al. (2023), Nature Genetics, Figure 3c.
# Input: output directory. Outputs: simulated data and PNG/PDF/SVG figures.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
segments_data <- data.frame(chr = c("Chr10", "Chr17"), start_kb = c(52500, 60100),
  end_kb = c(53200, 63900), start_angle = c(92, 184), end_angle = c(177, 448),
  color = c("#A95230", "#5BBACC"))
features <- data.frame(name = c("Gene A", "Gene B", "Gene C"), chr = "Chr17",
                       position_kb = c(61813, 60676, 63483))
sector <- segments_data[match(features$chr, segments_data$chr), ]
features$angle <- with(sector, start_angle + (features$position_kb-start_kb) /
                         (end_kb-start_kb) * (end_angle-start_angle))
saveRDS(list(segments = segments_data, features = features),
        file.path(out, "genomic_intervals_circular_map_simulated.rds"))

xy <- function(angle, radius) cbind(.50 + radius*cos(angle*pi/180), .47 + radius*sin(angle*pi/180))
ring <- function(start, end, inner, outer, color) {
  polygon(rbind(xy(seq(start, end, length.out = 45), outer),
                xy(seq(end, start, length.out = 45), inner)), col = color, border = NA)
}
draw <- function() {
  par(mar = rep(0, 4), family = "sans", xpd = NA, cex = 1.2)
  plot.new(); plot.window(c(0, 1), c(0, 1), asp = 1, xaxs = "i", yaxs = "i")
  text(.5, .97, "Circular genomic intervals", cex = .95)
  for (i in seq_len(nrow(segments_data))) {
    s <- segments_data[i, ]; ring(s$start_angle, s$end_angle, .302, .318, s$color)
  }
  for (i in seq_len(nrow(features))) {
    angle <- features$angle[i]
    for (j in 0:3) ring(angle-3+j*1.2, angle-2.3+j*1.2, .295, .318, "#282828")
    ring(angle+2, angle+4.5, .296, .318, "#EC332A")
    label <- xy(angle, .242); rot <- (angle - 90 + 180) %% 360 - 180
    if (rot > 90) rot <- rot - 180
    if (rot < -90) rot <- rot + 180
    text(label[1], label[2], features$name[i], col = "#E72B21", font = 3, srt = rot, cex = .8)
  }
  text(.16, .74, "Chr10", col = "#A95230", cex = .82)
  text(.18, .17, "Chr17", col = "#5BBACC", cex = .82)
  text(.50, .085, "Genomic location (kb)", cex = .8)
  text(.13, .60, format(segments_data$end_kb[1], big.mark = ","), srt = -13, col = "#777777", cex = .67)
  text(.13, .35, format(segments_data$start_kb[2], big.mark = ","), srt = 13, col = "#777777", cex = .67)
  text(.32, .82, format(segments_data$start_kb[1], big.mark = ","), srt = -48, col = "#777777", cex = .67)
  text(.65, .81, format(segments_data$end_kb[2], big.mark = ","), srt = 64, col = "#777777", cex = .67)
  arrows(.07, .235, .107, .235, length = .04, col = "#E6322A", lwd = 1.4)
  segments(.107, .235, .195, .235, lwd = 1)
  rect(.135, .225, .165, .245, col = "#202020", border = NA)
  text(c(.07, .15, .20), .29, c("Start", "Exon", "End"), srt = 90, cex = .55)
}
for (ext in c("png", "pdf", "svg")) {
  file <- file.path(out, paste0("genomic_intervals_circular_map.", ext))
  if (ext == "png") png(file, width = 6, height = 6, units = "in", res = 200, type = "cairo")
  if (ext == "pdf") cairo_pdf(file, width = 6, height = 6)
  if (ext == "svg") svg(file, width = 6, height = 6)
  draw(); dev.off()
}
