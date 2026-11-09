# 比较脑区和阶段间的转录相关性。使用附带的模拟数据生成 PNG、PDF 和 RDS。
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else "."
entry <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
source(file.path(dirname(normalizePath(entry)), "_shared", "plot_style.R"))

ext_brain_regions <- c("Pall", "Pall VZ", "SPall", "SPall VZ", "Hy", "Die",
                       "Mb", "Mb VZ", "Cere", "Hb", "Hb VZ", "SpC")
ext_region_col <- setNames(c("#D98C87", "#DD8730", "#89539D", "#4196A6",
                             "#845633", "#8592AB", "#8DB171", "#A24994",
                             "#BC316F", "#C97EAB", "#AEC846", "#F2CEAF"),
                           ext_brain_regions)
ext_stage_col <- c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F", "#E5C494")

simulate_ext7c <- function() {
  samples <- expand.grid(region = ext_brain_regions, stage_index = 1:7,
                         KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  samples$stage <- stage[samples$stage_index]
  samples$section_id <- sprintf("S%02d", samples$stage_index)
  samples$sample_id <- sprintf("SIM-C%02d", seq_len(nrow(samples)))
  samples$synthetic <- TRUE
  nfeature <- 600
  early <- rnorm(nfeature)
  late <- rnorm(nfeature)
  stage_signature <- matrix(rnorm(nfeature * 7), nfeature)
  region_signature <- matrix(rnorm(nfeature * 12), nfeature)
  temporal_weight <- c(1.8, 1.7, 1.4, .35, -.2, -.55, -.8)
  feature_matrix <- matrix(0, nfeature, nrow(samples))
  for (j in seq_len(nrow(samples))) {
    s <- samples$stage_index[j]
    r <- match(samples$region[j], ext_brain_regions)
    feature_matrix[, j] <- early * temporal_weight[s] +
      late * c(-.2, -.15, 0, .75, 1, .8, .6)[s] +
      stage_signature[, s] * c(.12, .15, .2, .8, .9, 1, .8)[s] +
      region_signature[, r] * c(.28, .3, .35, .65, .9, 1.15, 1.35)[s] +
      rnorm(nfeature, 0, .3 + .055 * s)
  }
  dimnames(feature_matrix) <- list(sprintf("SyntheticFeature%03d", 1:nfeature),
                                   samples$sample_id)
  correlation <- stats::cor(feature_matrix, method = "spearman")
  list(feature_matrix = feature_matrix, correlation = correlation,
       samples = samples, region_colors = ext_region_col,
       stage_colors = setNames(ext_stage_col, stage), synthetic = TRUE)
}

draw_ext7c <- function(data) {
  new_canvas()
  text_label(.20, .98, "Simulated illustration", adj = 0, cex = .65)
  # A normalized width is converted to a height with the same physical length.
  left <- .20; right <- .94; top <- .95
  bottom <- top - (right - left) * par("pin")[1] / par("pin")[2]
  pal <- grDevices::colorRampPalette(c("#438CB0", "#FFFFFF", "#CB5A97"))(256)
  heat_raster(data$correlation, left, bottom, right, top, limits = c(-1, 1), palette = pal)
  rect(left, bottom, right, top, border = "#D8D8D8", lwd = .35)
  n <- nrow(data$samples)
  for (j in seq_len(n)) {
    x1 <- left + (j - 1) * (right - left) / n
    x2 <- left + j * (right - left) / n
    rect(x1, bottom - .022, x2, bottom - .008,
         col = data$stage_colors[data$samples$stage[j]], border = NA)
    rect(x1, bottom - .043, x2, bottom - .029,
         col = data$region_colors[data$samples$region[j]], border = NA)
  }
  text_label(left - .01, bottom - c(.015, .036), c("CS stage", "Brain region"),
             adj = 1, cex = .45)
  heat_raster(matrix(seq(1, -1, length.out = 256), ncol = 1),
              .059, .40, .076, .60, limits = c(-1, 1), palette = pal)
  text_label(.067, .63, "Cor.", cex = .58)
  text_label(.085, c(.40, .50, .60), c("−1", "0", "1"), adj = 0, cex = .48)
  for (i in 1:7) {
    x <- .20 + ((i - 1) %% 4) * .19
    y <- bottom - .079 - ((i - 1) %/% 4) * .022
    rect(x, y - .005, x + .012, y + .005, col = data$stage_colors[i], border = NA)
    text_label(x + .017, y, names(data$stage_colors)[i], adj = 0, cex = .43)
  }
  for (i in 1:12) {
    x <- .20 + ((i - 1) %% 4) * .19
    y <- bottom - .132 - ((i - 1) %/% 4) * .021
    rect(x, y - .005, x + .012, y + .005, col = data$region_colors[i], border = NA)
    text_label(x + .017, y, names(data$region_colors)[i], adj = 0, cex = .43)
  }
}

set.seed(20261108)
data <- simulate_ext7c()
render_example(data, draw_ext7c, "brain_region_correlation_heatmap", out, c(6.8, 6.8))
