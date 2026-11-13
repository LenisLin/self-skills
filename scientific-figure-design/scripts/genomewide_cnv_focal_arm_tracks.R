#!/usr/bin/env Rscript
# Compare cohort copy-number frequencies, focal enrichment and arm-level events.
# Visual reference: Mangiante et al. (2023), Nature Genetics, Figure 3b.
# Run: Rscript genomewide_cnv_focal_arm_tracks.R OUTPUT_DIR
# Saves simulated sample-by-bin states and PNG, PDF and SVG figures.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(2026111303)

# Synthetic bins have chromosome-like relative sizes and 120 independent samples.
chromosomes <- c(as.character(1:22), "X", "Y")
bins_per_chr <- c(105, 100, 82, 78, 75, 70, 68, 62, 60, 58, 56, 55,
                  48, 47, 45, 40, 38, 35, 30, 27, 22, 21, 48, 18)
n <- 120
sample_ploidy <- sample(c(2L, 4L), n, replace = TRUE, prob = c(.75, .25))
chr <- rep(chromosomes, bins_per_chr)
within <- unlist(lapply(bins_per_chr, function(k) (seq_len(k)-.5)/k))
genome <- data.frame(chr = factor(chr, levels = chromosomes), position = within,
                     x = seq_along(chr) / length(chr))
states <- matrix(sample(c(0L, 1L, -1L), nrow(genome)*n, replace = TRUE,
                        prob = c(.972, .014, .014)), nrow = nrow(genome), ncol = n)
cnloh <- matrix(FALSE, nrow(genome), n)

# Broad and focal events share carriers across contiguous bins.
add_event <- function(chromosome, center, width, carriers, sign, magnitudes) {
  rows <- which(chr == chromosome & abs(within-center) <= width/2)
  people <- sample.int(n, carriers)
  magnitude <- sample(magnitudes, carriers, replace = TRUE)
  if (sign < 0) magnitude <- pmin(magnitude, sample_ploidy[people])
  states[rows, people] <<- matrix(rep(sign * magnitude, each = length(rows)), nrow = length(rows))
}
for (i in seq_len(55)) {
  add_event(sample(chromosomes[1:22], 1), runif(1, .2, .8), runif(1, .25, .65),
            sample(12:34, 1), sample(c(-1, 1), 1, prob = c(.68, .32)),
            if (runif(1) < .7) c(1L, 1L, 1L, 2L) else c(1L, 2L, 3L))
}
hotspots <- data.frame(chr = c("3", "9", "7", "15", "16", "5", "17", "22"),
                       pos = c(.31, .30, .76, .42, .28, .22, .37, .48),
                       width = c(.10, .12, .08, .09, .07, .10, .25, .24),
                       sign = c(-1, -1, -1, -1, -1, 1, -1, -1),
                       carriers = c(65, 74, 43, 38, 38, 48, 45, 54),
                       label = c("BAP1", "CDKN2A/B, MTAP", "EZH2", "B2M", "RBFOX1", "TERT", "TP53", "NF2"))
for (i in seq_len(nrow(hotspots))) {
  h <- hotspots[i, ]
  add_event(h$chr, h$pos, h$width, h$carriers, h$sign,
            if (h$sign < 0) c(1L, 1L, 1L, 2L, 2L, 3L, 4L) else c(1L, 1L, 2L, 3L, 4L, 5L, 6L))
}
for (i in seq_len(24)) {
  chromosome <- sample(chromosomes[1:22], 1)
  rows <- which(chr == chromosome & abs(within - runif(1, .2, .8)) < .18)
  cnloh[rows, sample.int(n, sample(5:19, 1))] <- TRUE
}

# Copy-neutral LOH occupies segments without a simulated total-copy change.
cnloh <- cnloh & states == 0

# The enrichment display uses BH-adjusted binomial probabilities from the simulated states.
gain_counts <- sapply(1:6, function(k) rowSums(if (k == 6) states >= k else states == k))
loss_counts <- sapply(1:4, function(k) rowSums(states == -k))
gain_total <- rowSums(gain_counts); loss_total <- rowSums(loss_counts)
q_gain <- p.adjust(pbinom(gain_total - 1, n, .15, lower.tail = FALSE), "BH")
q_loss <- p.adjust(pbinom(loss_total - 1, n, .15, lower.tail = FALSE), "BH")
tracks <- data.frame(genome, gain_counts, loss_counts,
                     cnloh_percent = rowMeans(cnloh) * 100, q_gain = q_gain, q_loss = q_loss)
colnames(tracks)[4:13] <- c(paste0("gain", 1:6), paste0("loss", 1:4))

arms <- do.call(rbind, lapply(chromosomes, function(chromosome) {
  do.call(rbind, lapply(0:1, function(arm) {
    rows <- which(chr == chromosome & if (arm == 0) within < .5 else within >= .5)
    positive <- colMeans(states[rows, , drop = FALSE] > 0) > .5
    negative <- colMeans(states[rows, , drop = FALSE] < 0) > .5
    data.frame(chr = chromosome, arm = c("p", "q")[arm+1], x0 = min(genome$x[rows]),
               x1 = max(genome$x[rows]), gain = sum(positive), loss = sum(negative))
  }))
}))
arms$q_gain <- p.adjust(pbinom(arms$gain - 1, n, .15, lower.tail = FALSE), "BH")
arms$q_loss <- p.adjust(pbinom(arms$loss - 1, n, .15, lower.tail = FALSE), "BH")
saveRDS(list(states = states, sample_ploidy = sample_ploidy, cnloh = cnloh,
             bin_tracks = tracks, arm_tracks = arms,
             hotspots = hotspots, null_event_fraction = .15),
        file.path(out, "genomewide_cnv_focal_arm_tracks_simulated.rds"))

# Consecutive polygons keep each copy-number category tied to its cohort fraction.
gain_colors <- c("#C67BCB", "#E85CB2", "#F43891", "#FB1760", "#F50035", "#D90000")
loss_colors <- c("#A4CBE0", "#70ADD4", "#2D78B7", "#133D78")
xmap <- function(x) .165 + .70*x
chromosome_rows <- lapply(chromosomes, function(chromosome) which(chr == chromosome))
names(chromosome_rows) <- chromosomes
xgene <- function(chromosome, position) {
  rows <- chromosome_rows[[chromosome]]
  xmap(genome$x[rows[which.min(abs(within[rows] - position))]])
}
stack_area <- function(x, lower, upper, col) {
  polygon(c(x, rev(x)), c(lower, rev(upper)), col = col, border = NA)
}

draw <- function() {
  par(mar = rep(0, 4), family = "sans", xpd = NA, cex = 1.27)
  plot.new(); plot.window(c(0, 1), c(0, 1), xaxs = "i", yaxs = "i")
  text(.015, .965, "b", font = 2, cex = 1.5, adj = c(0, 1))
  text(.515, .965, "Genomic location", cex = 1.0)
  top_zero <- .77; top_scale <- .00155
  focal_zero <- .515; focal_scale <- .0052
  arm_zero <- .205
  for (i in seq_along(chromosomes)) {
    rows <- chromosome_rows[[i]]; x <- xmap(genome$x[rows])
    text(mean(range(x)), .92, chromosomes[i], cex = if (i >= 19) .52 else .69)
    segments(min(x), top_zero, max(x), top_zero, col = "#DADADA", lwd = .7)
    lower <- rep(0, length(rows))
    for (k in 1:6) {
      upper <- lower + gain_counts[rows, k] / n * 100
      stack_area(x, top_zero + lower*top_scale, top_zero + upper*top_scale, gain_colors[k]); lower <- upper
    }
    lower <- rep(0, length(rows))
    for (k in 1:4) {
      upper <- lower + loss_counts[rows, k] / n * 100
      stack_area(x, top_zero - lower*top_scale, top_zero - upper*top_scale, loss_colors[k]); lower <- upper
    }
    lines(x, top_zero - tracks$cnloh_percent[rows]*top_scale, col = "#222222", lwd = .6)
    points(mean(range(x)), top_zero, pch = 16, cex = .25)
    lines(x, focal_zero + pmin(-log10(pmax(q_gain[rows], 1e-35)), 35)*focal_scale,
          col = "#F05463", lwd = .8)
    lines(x, focal_zero - pmin(-log10(pmax(q_loss[rows], 1e-35)), 35)*focal_scale,
          col = "#315EFF", lwd = .9)
    segments(min(x), arm_zero, max(x), arm_zero, col = "#DEDEDE", lwd = .7)
    points(mean(range(x)), arm_zero, pch = 16, cex = .30)
  }
  # Positive and negative arm bars use q values computed from the simulated samples.
  for (i in seq_len(nrow(arms))) {
    x0 <- xmap(arms$x0[i]); x1 <- xmap(arms$x1[i])
    if (arms$q_gain[i] < .05) rect(x0, arm_zero, x1, arm_zero+.045, col = "#FF8F8A", border = NA)
    if (arms$q_loss[i] < .05) rect(x0, arm_zero-.045, x1, arm_zero, col = "#85AAFF", border = NA)
  }
  for (v in c(-60, -30, 0, 15, 30)) {
    yy <- top_zero + v*top_scale
    text(.15, yy, abs(v), adj = 1, cex = .65)
    segments(.155, yy, .161, yy, col = "#555555", lwd = .6)
  }
  segments(.161, top_zero-.093, .161, top_zero+.047, col = "#555555", lwd = .6)
  text(.055, .79, "Percentage of\nsamples\nwith CNV", cex = .82)
  text(.11, .81, "+", col = "#F17D7B", cex = .9)
  text(.11, .73, "−", col = "#78A4FF", cex = .9)
  segments(.161, focal_zero-.185, .161, focal_zero+.03, col = "#555555", lwd = .6)
  for (v in c(0, 10, 20, 30)) {
    yy <- focal_zero-v*focal_scale
    text(.15, yy, if (v == 0) "1" else as.expression(bquote(10^-.(v))), adj = 1, cex = .65)
    segments(.155, yy, .161, yy, col = "#555555", lwd = .6)
  }
  text(.075, .485, "Focal (BH q)", srt = 90, cex = .84)
  text(.075, .205, "Chr. arm", srt = 90, cex = .84)
  text(.045, .35, "Enrichment", srt = 90, cex = .78)
  segments(.058, .16, .058, .60, lwd = 1.1)
  text(.11, .55, "+", col = "#F17D7B", cex = .9)
  text(.11, .47, "−", col = "#78A4FF", cex = .9)
  text(.11, .25, "+", col = "#F17D7B", cex = .9)
  text(.11, .17, "−", col = "#78A4FF", cex = .9)
  text(xgene("3", .31), .295, "BAP1", col = "#6D94FF", font = 3, cex = .72)
  text(xgene("9", .30), .285, "CDKN2A/B\nMTAP", col = "#6D94FF", font = 3, cex = .72)
  text(xgene("7", .76), .455, "EZH2", col = "#6D94FF", font = 3, cex = .72)
  text(xgene("15", .42), .455, "B2M", col = "#6D94FF", font = 3, cex = .72)
  text(xgene("16", .28), .405, "RBFOX1", col = "#6D94FF", font = 3, cex = .72)
  text(xgene("5", .22), .272, "TERT", col = "#F17D7B", font = 3, cex = .72)
  text(xgene("17", .37), .125, "TP53", col = "#6D94FF", font = 3, cex = .72)
  text(xgene("22", .48), .125, "NF2", col = "#6D94FF", font = 3, cex = .72)

  text(.91, .88, "Copy number", cex = .8, adj = 0)
  legend_cols <- c(rev(gain_colors), loss_colors)
  legend_labels <- c("≥6", "5", "4", "3", "2", "1", "−1", "−2", "−3", "−4")
  for (i in seq_along(legend_cols)) {
    yy <- .84 - (i-1)*.037
    rect(.91, yy-.011, .924, yy+.011, col = legend_cols[i], border = NA)
    text(.932, yy, legend_labels[i], adj = 0, cex = .72)
  }
  text(.958, .525, "WGD+\nonly", col = "#999999", adj = 0, cex = .52)
  segments(.91, .43, .93, .43, lwd = 1); text(.936, .43, "cnLOH", adj = 0, cex = .7)
  text(.885, .77, "Gain (+)", srt = 90, col = "#F17D7B", cex = .75)
  text(.885, .59, "Loss (−)", srt = 90, col = "#78A4FF", cex = .75)
}

png(file.path(out, "genomewide_cnv_focal_arm_tracks.png"), width = 2700, height = 1080, res = 200, type = "cairo"); draw(); dev.off()
cairo_pdf(file.path(out, "genomewide_cnv_focal_arm_tracks.pdf"), width = 13.5, height = 5.4); draw(); dev.off()
svg(file.path(out, "genomewide_cnv_focal_arm_tracks.svg"), width = 13.5, height = 5.4); draw(); dev.off()
