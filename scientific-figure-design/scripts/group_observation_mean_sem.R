#!/usr/bin/env Rscript
# Compare observed values and mean +/- SEM across many grouped categories.
# Reference: Karimi et al. (2023), Nature, Figure 2b, doi:10.1038/s41586-022-05680-3.
# Adapt the observation, category, cohort and value columns to your data.
# Run: Rscript group_observation_mean_sem.R OUTPUT_DIR
# Outputs: simulated observations, group summaries and PNG, PDF and SVG figures.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "."
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(2026111903)

cohorts <- rep(c("All samples", "Cohort A", "Cohort B", "Cohort C"), c(5, 11, 9, 9))
categories <- paste("Group", sprintf("%02d", seq_along(cohorts)))
colors <- c("#DE391B", "#E49D00", "#36B324", "#0B9CC0", "#9160CB", "#DA3994")
observations <- do.call(rbind, lapply(seq_along(categories), function(i) {
  n <- sample(18:60, 1)
  mean_value <- 1.2 + i*.065 + if (i %% 7 == 0) 1.2 else 0
  upper_probability <- pgamma(15.8, shape = 1.6, scale = mean_value/1.6)
  value <- qgamma(runif(n, 0, upper_probability), shape = 1.6, scale = mean_value/1.6)
  if (i %in% c(2, 8, 13, 21, 30)) value[sample.int(n, 1)] <- runif(1, 34.5, 39.5)
  data.frame(cohort = cohorts[i], category = categories[i], observation = seq_len(n),
             value = value, jitter = runif(n, -.24, .24), color = colors[(i-1) %% length(colors)+1])
}))
summary <- do.call(rbind, lapply(seq_along(categories), function(i) {
  d <- observations[observations$category == categories[i], ]
  data.frame(category = categories[i], cohort = cohorts[i], n = nrow(d),
             mean = mean(d$value), sem = sd(d$value)/sqrt(nrow(d)))
}))
saveRDS(list(observations = observations, summary = summary, axis_break = c(16, 34)),
        file.path(out, "group_observation_mean_sem_simulated.rds"))

draw <- function() {
  par(mar = c(0, 0, 0, 0), family = "sans", xpd = NA)
  plot.new(); plot.window(c(0, 1), c(0, 1), xaxs = "i", yaxs = "i")
  left <- .085; right <- .98; bottom <- .40; top <- .82
  x <- seq(left+.013, right-.013, length.out = nrow(summary))
  ymap <- function(value) bottom + (ifelse(value <= 16, value, 18+(value-34)/3) / 20) * (top-bottom)
  for (i in seq_along(categories)) {
    d <- observations[observations$category == categories[i], ]
    points(x[i] + d$jitter*(right-left)/length(categories), ymap(d$value),
           pch = 16, cex = .28, col = d$color)
    mu <- summary$mean[i]; sem <- summary$sem[i]
    segments(x[i], ymap(mu-sem), x[i], ymap(mu+sem), lwd = .8)
    segments(x[i]-.006, ymap(mu-sem), x[i]+.006, ymap(mu-sem), lwd = .8)
    segments(x[i]-.006, ymap(mu+sem), x[i]+.006, ymap(mu+sem), lwd = .8)
    segments(x[i]-.008, ymap(mu), x[i]+.008, ymap(mu), lwd = 1.2)
    text(x[i], bottom-.025, sprintf("%s (n=%d)", categories[i], summary$n[i]),
         srt = 90, adj = 1, cex = .61)
  }
  breaks <- c(5, 16, 25)
  for (k in breaks) {
    boundary <- mean(x[k:(k+1)])
    segments(boundary, bottom, boundary, top, lty = 2, col = "#777777", lwd = .5)
  }
  sections <- list(1:5, 6:16, 17:25, 26:34)
  for (k in seq_along(sections)) text(mean(range(x[sections[[k]]])), top+.045,
                                      unique(cohorts[sections[[k]]]), cex = .76)
  segments(left-.012, bottom, right, bottom, lwd = .8)
  segments(left-.012, bottom, left-.012, top, lwd = .8)
  for (tick in c(0, 8, 16, 40)) {
    segments(left-.019, ymap(tick), left-.012, ymap(tick), lwd = .7)
    text(left-.024, ymap(tick), tick, adj = 1, cex = .7)
  }
  yy <- bottom + 17/20*(top-bottom)
  segments(left-.020, yy-.012, left-.006, yy+.004, lwd = 1.2, col = "white")
  segments(left-.020, yy-.006, left-.006, yy+.010, lwd = 1.2, col = "white")
  segments(left-.020, yy-.010, left-.006, yy+.006, lwd = .8)
  segments(left-.020, yy-.004, left-.006, yy+.012, lwd = .8)
  text(.018, .62, "Value (% of total)", srt = 90, cex = .85)
}
for (ext in c("png", "pdf", "svg")) {
  file <- file.path(out, paste0("group_observation_mean_sem.", ext))
  if (ext == "png") png(file, width = 15, height = 5.8, units = "in", res = 200, type = "cairo")
  if (ext == "pdf") cairo_pdf(file, width = 15, height = 5.8)
  if (ext == "svg") svg(file, width = 15, height = 5.8)
  draw(); dev.off()
}
