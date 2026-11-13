#!/usr/bin/env Rscript
# Relate simulated chromothripsis breakpoints, ecDNA segments and expression ranks.
# Visual reference: Mangiante et al. (2023), Nature Genetics, Figure 3c.
# Run: Rscript chromothripsis_ecdna_expression.R OUTPUT_DIR
# Saves structural variants, circular segments, expression data and PNG/PDF/SVG figures.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(2026111304)

# Four chromosome sectors contain copy-number tracks, cytobands and SV endpoints.
sectors <- data.frame(chr = c("Chr6", "Chr7", "Chr17", "Chr10"),
                      start = c(92, 145, 255, 310), end = c(143, 253, 308, 449),
                      color = c("#A0A0A0", "#A0A0A0", "#61BBD0", "#AA5030"))
links <- data.frame(start = c(runif(17, 160, 250), runif(11, 95, 135), runif(9, 260, 300)),
                    end = c(runif(17, 335, 418), runif(11, 330, 405), runif(9, 175, 245)),
                    bend = runif(37, -.09, .09))
shattered <- data.frame(start = c(107, 170, 274, 340, 385), end = c(115, 180, 285, 352, 397))
copy_track <- do.call(rbind, lapply(seq_len(nrow(sectors)), function(i) {
  angles <- seq(sectors$start[i], sectors$end[i], length.out = 50)
  data.frame(chr = sectors$chr[i], angle = angles,
             copy_effect = sin(angles*pi/38 + i)*.28 + rnorm(50, 0, .13))
}))
ecdna_segments <- data.frame(chr = c("Chr10", "Chr17"), start = c(92, 184),
                             end = c(177, 448), color = c("#A95230", "#5BBACC"),
                             source_start = c(335, 275), source_end = c(382, 298))
# Two saved SV junctions connect the same source segments in the circular amplicon.
links$reconstructed_ecdna <- FALSE
links[1, c("start", "end")] <- list(ecdna_segments$source_end[1], ecdna_segments$source_start[2])
links[2, c("start", "end")] <- list(ecdna_segments$source_end[2], ecdna_segments$source_start[1])
links$reconstructed_ecdna[1:2] <- TRUE
genes <- data.frame(gene = c("BRIP1", "PPM1D", "CD79B"), angle = c(303, 224, 59),
                    quantile = c(.96, .41, .34))

# The violin and P value are computed from the same saved simulated quantiles.
quantile_ecdna <- c(genes$quantile, rbeta(37, 3.6, 1.7))
quantile_other <- c(rbeta(95, 1.1, 5), rbeta(45, 6, 1.1))
expression <- data.frame(group = rep(c("Genes in ecDNA", "Other genes"),
                                     c(length(quantile_ecdna), length(quantile_other))),
                         gene = c(genes$gene, paste0("ecDNA_gene_", seq_len(37)),
                                  paste0("other_gene_", seq_len(140))),
                         quantile = c(quantile_ecdna, quantile_other),
                         jitter = runif(length(quantile_ecdna) + length(quantile_other), -.035, .035))
p_value <- wilcox.test(quantile_ecdna, quantile_other, exact = FALSE)$p.value
saveRDS(list(sectors = sectors, copy_track = copy_track, structural_variants = links,
             shattered_regions = shattered, ecdna_segments = ecdna_segments,
             genes = genes, expression_quantiles = expression, wilcoxon_p = p_value),
        file.path(out, "chromothripsis_ecdna_expression_simulated.rds"))

xy <- function(cx, cy, angle, radius) {
  cbind(cx + radius*cos(angle*pi/180), cy + radius*sin(angle*pi/180))
}
arc <- function(cx, cy, start, end, radius, n = 45) {
  xy(cx, cy, seq(start, end, length.out = n), radius)
}
ring <- function(cx, cy, start, end, inner, outer, color, border = NA) {
  points <- rbind(arc(cx, cy, start, end, outer), arc(cx, cy, end, start, inner))
  polygon(points, col = color, border = border, lwd = .4)
}
curve <- function(p0, control, p1, steps = 50) {
  t <- seq(0, 1, length.out = steps)
  cbind((1-t)^2*p0[1] + 2*(1-t)*t*control[1] + t^2*p1[1],
        (1-t)^2*p0[2] + 2*(1-t)*t*control[2] + t^2*p1[2])
}
violin <- function(values, x, ymap) {
  d <- density(values, from = 0, to = 1, n = 256, bw = .11)
  width <- .135 * d$y/max(d$y)
  polygon(c(x-width, rev(x+width)), c(ymap(d$x), rev(ymap(d$x))),
          col = "#D7D7D7", border = "#BEBEBE", lwd = .6)
  segments(x-.085, ymap(median(values)), x+.085, ymap(median(values)), lwd = 1.1)
}

draw <- function() {
  par(mar = rep(0, 4), family = "sans", xpd = NA, cex = 1.25)
  plot.new(); plot.window(c(0, 3.0), c(0, 1.08), asp = 1, xaxs = "i", yaxs = "i")
  text(.025, 1.055, "c", font = 2, cex = 1.5, adj = c(0, 1))
  text(.47, 1.0, "Chromothripsis", cex = .96)
  text(1.42, 1.0, "Amplicon 1 (ecDNA)", cex = .96)
  text(2.45, 1.0, "Oncogene overexpression", cex = .96)
  arrows(.72, 1.0, 1.10, 1.0, length = .08, lwd = 1.1)
  arrows(1.75, 1.0, 2.08, 1.0, length = .08, lwd = 1.1)

  # Structural-variant links use the same endpoints saved in the data object.
  cx <- .47; cy <- .47
  for (i in seq_len(nrow(links))) {
    p0 <- xy(cx, cy, links$start[i], .235)[1, ]
    p1 <- xy(cx, cy, links$end[i], .235)[1, ]
    control <- c(cx + links$bend[i], cy - links$bend[i]/2)
    path <- curve(p0, control, p1)
    lines(path, col = "#101010", lwd = 1.0)
  }
  for (i in seq_len(nrow(sectors))) {
    s <- sectors[i, ]
    ring(cx, cy, s$start, s$end, .317, .33, s$color)
    edges <- seq(s$start, s$end, length.out = 17)
    for (j in seq_len(16)) {
      color <- if (j %% 4 == 0) "#3A3A3A" else if (j %% 2) "#C9C9C9" else "#EFEFEF"
      ring(cx, cy, edges[j]+.3, edges[j+1]-.3, .302, .315, color, "white")
      ring(cx, cy, edges[j]+.3, edges[j+1]-.3, .288, .298,
           if (j %% 3 == 0) "#BABABA" else "#EEEEEE", "white")
    }
    sub <- copy_track[copy_track$chr == s$chr, ]
    points <- xy(cx, cy, sub$angle, .264 + .025*abs(sub$copy_effect))
    for (j in seq_len(nrow(sub)-1)) {
      lines(points[j:(j+1), ], col = if (sub$copy_effect[j] >= 0) "#EF382F" else "#4E8DE6", lwd = .9)
    }
    mid <- (s$start+s$end)/2
    pos <- xy(cx, cy, mid, .375)
    text(pos[1], pos[2], s$chr, col = s$color, cex = .76)
  }
  for (i in seq_len(nrow(shattered))) {
    ring(cx, cy, shattered$start[i], shattered$end[i], .316, .332, "#EE5621")
  }
  rect(cx-.035, cy+.006, cx+.035, cy+.046, col = "white", border = NA)
  text(cx, cy+.026, "SVs", cex = .92)
  text(cx-.005, cy+.21, "CN gain", col = "#E9322A", cex = .82)
  text(cx-.05, cy+.158, "CN loss", col = "#5589D8", cex = .76)
  text(cx+.03, .07, "Shattered region", col = "#EE5621", cex = .86)
  segments(cx+.13, .11, cx+.08, .15, col = "#EE5621", lwd = .7)

  # Colored ecDNA arcs and gene marks correspond to the saved segments and genes.
  cx <- 1.42; cy <- .47
  for (i in seq_len(nrow(ecdna_segments))) {
    s <- ecdna_segments[i, ]
    ring(cx, cy, s$start, s$end, .302, .318, s$color)
  }
  for (i in seq_len(nrow(genes))) {
    angle <- genes$angle[i]
    for (j in 0:3) ring(cx, cy, angle-3+j*1.2, angle-2.3+j*1.2, .295, .318, "#282828")
    ring(cx, cy, angle+2, angle+4.5, .296, .318, "#EC332A")
    label <- xy(cx, cy, angle, .242)
    rot <- (angle - 90 + 180) %% 360 - 180
    if (rot > 90) rot <- rot - 180
    if (rot < -90) rot <- rot + 180
    text(label[1], label[2], genes$gene[i], col = "#E72B21", font = 3, srt = rot, cex = .80)
  }
  text(.955, .30, "Start", srt = 90, cex = .52)
  text(1.010, .30, "Exon", srt = 90, cex = .52)
  text(1.060, .30, "End", srt = 90, cex = .52)
  arrows(.945, .235, .982, .235, length = .04, col = "#E6322A", lwd = 1.4)
  segments(.982, .235, 1.07, .235, lwd = 1)
  rect(1.01, .225, 1.04, .245, col = "#202020", border = NA)
  text(1.08, .74, "Chr10", col = "#A95230", cex = .82)
  text(1.10, .17, "Chr17", col = "#5BBACC", cex = .82)
  text(1.42, .085, "Genomic location (kb)", cex = .80)
  text(1.13, .60, "53,200", srt = -13, col = "#777777", cex = .67)
  text(1.24, .82, "52,500", srt = -48, col = "#777777", cex = .67)
  text(1.57, .81, "63,900", srt = 64, col = "#777777", cex = .67)

  # Kernel density displays, medians and the two-sided rank-sum P value.
  ymap <- function(value) .155 + .61*value
  x1 <- 2.20; x2 <- 2.65
  violin(quantile_ecdna, x1, ymap); violin(quantile_other, x2, ymap)
  group_x <- ifelse(expression$group == "Genes in ecDNA", x1, x2)
  points(group_x + expression$jitter, ymap(expression$quantile), pch = 16,
         col = adjustcolor("#AFAFAF", .38), cex = .38)
  points(x1 + expression$jitter[1:3], ymap(genes$quantile), pch = 21,
         bg = "#E8342C", col = "black", cex = .52)
  for (i in seq_len(nrow(genes))) {
    x <- x1 - .165; yy <- ymap(genes$quantile[i]) - c(.045, -.035, .045)[i]
    rect(x, yy-.027, x+.20, yy+.027, col = "white", border = "#EB3D37", lwd = .65)
    text(x+.10, yy, genes$gene[i], col = "#E6322A", font = 3, cex = .70)
  }
  segments(2.00, ymap(0), 2.88, ymap(0), col = "#777777", lwd = .6)
  segments(2.00, ymap(0), 2.00, ymap(1), col = "#777777", lwd = .6)
  for (v in seq(0, 1, .25)) {
    segments(1.987, ymap(v), 2.00, ymap(v), col = "#777777", lwd = .6)
    text(1.975, ymap(v), format(v, nsmall = if (v == 0) 0 else 2), adj = 1, cex = .69)
  }
  text(1.86, .47, "Gene expression in case\n(quantile of cohort)", srt = 90, cex = .76)
  text(x1, .105, "Genes in ecDNA", cex = .76)
  text(x2, .105, "Other genes", cex = .76)
  segments(x1, .81, x2, .81, lwd = 1)
  text((x1+x2)/2, .845, paste0("P value = ", format.pval(p_value, digits = 2, eps = 1e-16)), cex = .75)
  arrows(2.93, .48, 2.93, .76, length = .07, lwd = .8)
  arrows(2.93, .43, 2.93, .15, length = .07, lwd = .8)
  text(2.975, .64, "More expressed", srt = 90, cex = .62)
  text(2.975, .28, "Less expressed", srt = 90, cex = .62)
}

png(file.path(out, "chromothripsis_ecdna_expression.png"), width = 3000, height = 1080, res = 200, type = "cairo"); draw(); dev.off()
cairo_pdf(file.path(out, "chromothripsis_ecdna_expression.pdf"), width = 15, height = 5.4); draw(); dev.off()
svg(file.path(out, "chromothripsis_ecdna_expression.svg"), width = 15, height = 5.4); draw(); dev.off()
