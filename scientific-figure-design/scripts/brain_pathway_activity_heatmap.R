# 比较脑区与阶段的通路活性模块。使用附带的模拟数据生成 PNG、PDF 和 RDS。
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
ext_sample_col <- setNames(c("#626C87", "#E59D67", "#87BDB3", "#A78DC1",
                             "#CBBF66", "#D47C90", "#729EB7"),
                           sprintf("S%02d", 1:7))
ext_cluster_col <- c("#EFB5B7", "#28C982", "#6D7272", "#B9BCB8", "#949C9D", "#CB805F")
ext_stage_col <- c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F", "#E5C494")

simulate_ext7d <- function() {
  samples <- expand.grid(stage_index = 1:7, region = ext_brain_regions,
                         KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  samples$stage <- stage[samples$stage_index]
  samples$section_id <- sprintf("S%02d", samples$stage_index)
  samples$sample_id <- sprintf("SIM-D%02d", seq_len(nrow(samples)))
  samples$synthetic <- TRUE
  row_cluster <- rep(1:6, each = 60)
  scores <- matrix(0, length(row_cluster), nrow(samples))
  region_index <- match(samples$region, ext_brain_regions)
  for (k in 1:6) {
    rows <- which(row_cluster == k)
    region_effect <- .11 * cos((region_index - 2 * k) * pi / 6)
    temporal <- .06 * sin(samples$stage_index * .8 + k)
    scores[rows, ] <- outer(rnorm(60, c(.74, .66, .35, .66, .70, .38)[k], .055),
                            rep(1, nrow(samples))) +
      matrix(rep(region_effect + temporal, each = 60), 60) +
      matrix(rnorm(60 * nrow(samples), 0, .055), 60)
    # Sparse low-score horizontal bands and coherent region-specific troughs.
    stripe <- rows[seq(8, 60, by = 13)]
    scores[stripe, ] <- scores[stripe, ] - .40
    trough <- region_index %in% c(1 + (2 * k) %% 12, 1 + (2 * k + 1) %% 12)
    scores[rows[20:43], trough] <- scores[rows[20:43], trough] - .30
  }
  scores <- pmin(pmax(scores, 0), 1)
  dimnames(scores) <- list(sprintf("SyntheticPathway%03d", seq_len(nrow(scores))),
                           samples$sample_id)
  phrases <- c("regulation leukocyte immune", "response signaling", "process metabolic",
    "maturation development", "transport", "organization", "response signaling apoptotic",
    "assembly ribosomal biogenesis", "proliferation cell", "differentiation cell",
    "localization nucleus import", "cycle transition", "chemotaxis migration",
    "defense response", "DNA replication", "synaptic signaling",
    "homeostasis depolarization", "nervous system", "chromosome organization",
    "ion transport", "cell maturation", "protein localization", "RNA processing",
    "membrane organization", "axon development", "cell migration",
    "ribosome assembly", "signal transduction", "metabolic process", "cell cycle")
  chosen <- sample(phrases, 30, replace = FALSE)
  terms <- data.frame(term_id = sprintf("ILLUSTRATIVE%02d", 1:30),
                       cluster = rep(1:6, each = 5), phrase = chosen, synthetic = TRUE)
  terms$keywords <- strsplit(terms$phrase, " ", fixed = TRUE)
  keyword_col <- c("#D85D79", "#333333", "#C5A600", "#29AEB5", "#AE51A5", "#7DA957")
  terms$keyword_colors <- lapply(terms$keywords, function(w)
    sample(keyword_col, length(w), replace = FALSE))
  terms$keyword_cex <- lapply(terms$keywords, function(w)
    c(.72, rep(.56, length(w) - 1)))
  list(scores = scores, row_cluster = row_cluster, samples = samples,
       region_colors = ext_region_col, sample_colors = ext_sample_col,
       stage_colors = setNames(ext_stage_col, stage), cluster_colors = ext_cluster_col,
       go_terms = terms, synthetic = TRUE)
}

draw_ext7d <- function(data) {
  new_canvas()
  text_label(.04, .976, "Simulated illustration", adj = 0, cex = .85)
  text_label(.51, .94, "Illustrative GO-like keywords", adj = 0, cex = .65)
  left <- .04; right <- .46; bottom <- .08; top <- .88
  gap <- .006
  block_height <- (top - bottom - 5 * gap) / 6
  block_width <- (right - left - 11 * .003) / 12
  pal <- grDevices::colorRampPalette(c("#66ACD0", "#FFFFFF", "#E94358"))(256)
  cluster_mid <- numeric(6)
  for (k in 1:6) {
    ytop <- top - (k - 1) * (block_height + gap)
    ybot <- ytop - block_height
    cluster_mid[k] <- (ytop + ybot) / 2
    for (r in 1:12) {
      columns <- which(data$samples$region == names(data$region_colors)[r])
      x1 <- left + (r - 1) * (block_width + .003)
      heat_raster(data$scores[data$row_cluster == k, columns], x1, ybot,
                  x1 + block_width, ytop, limits = c(0, 1), palette = pal)
    }
    rect(.465, ybot, .472, ytop, col = data$cluster_colors[k], border = NA)
  }
  # Three annotation bands follow exactly the same region gaps as the matrix.
  for (r in 1:12) {
    columns <- which(data$samples$region == names(data$region_colors)[r])
    x1 <- left + (r - 1) * (block_width + .003)
    rect(x1, .922, x1 + block_width, .933, col = data$region_colors[r], border = NA)
    text_label(x1 + block_width / 2, .943, names(data$region_colors)[r], cex = .37)
    for (j in seq_along(columns)) {
      d <- data$samples[columns[j], ]
      a <- x1 + (j - 1) * block_width / 7
      b <- x1 + j * block_width / 7
      rect(a, .907, b, .918, col = data$sample_colors[d$section_id], border = NA)
      rect(a, .892, b, .903, col = data$stage_colors[d$stage], border = NA)
    }
  }
  text_label(.036, c(.928, .913, .898), c("Region", "Sample", "CS stage"),
             adj = 1, cex = .32)
  # Leader lines connect cluster centers to five compact keyword boxes per cluster.
  term_y <- seq(.866, .094, length.out = nrow(data$go_terms))
  for (i in seq_len(nrow(data$go_terms))) {
    d <- data$go_terms[i, ]
    y <- term_y[i]
    lines(c(.474, .492, .508), c(cluster_mid[d$cluster], y, y),
          col = "#B9B9B9", lwd = .5)
    rect(.51, y - .011, .788, y + .011, col = "white", border = "#B9B9B9", lwd = .5)
    words <- d$keywords[[1]]
    sizes <- d$keyword_cex[[1]]
    widths <- strwidth(paste0(words, " "), cex = sizes)
    fit <- min(1, .264 / sum(widths))
    sizes <- sizes * fit
    widths <- strwidth(paste0(words, " "), cex = sizes)
    x <- .516 + c(0, head(cumsum(widths), -1))
    for (j in seq_along(words)) text_label(x[j], y, words[j], adj = 0,
      cex = sizes[j], col = d$keyword_colors[[1]][j])
  }
  # Fixed legend slots keep scores, clusters, stages, regions and sample key apart.
  text_label(.825, .933, "Pathway score", adj = 0, cex = .6)
  heat_raster(matrix(seq(1, 0, length.out = 256), ncol = 1),
              .827, .813, .840, .915, limits = c(0, 1), palette = pal)
  text_label(.847, c(.813, .864, .915), c("0", "0.5", "1"), adj = 0, cex = .48)
  text_label(.825, .787, "Cluster", adj = 0, cex = .6)
  for (k in 1:6) {
    y <- .767 - (k - 1) * .018
    rect(.827, y - .006, .839, y + .006, col = data$cluster_colors[k], border = NA)
    text_label(.847, y, k, adj = 0, cex = .47)
  }
  text_label(.825, .649, "CS stage", adj = 0, cex = .6)
  for (k in 1:7) {
    y <- .629 - (k - 1) * .018
    rect(.827, y - .006, .839, y + .006, col = data$stage_colors[k], border = NA)
    text_label(.847, y, names(data$stage_colors)[k], adj = 0, cex = .47)
  }
  text_label(.825, .494, "Brain region", adj = 0, cex = .6)
  for (k in 1:12) {
    y <- .474 - (k - 1) * .018
    rect(.827, y - .006, .839, y + .006, col = data$region_colors[k], border = NA)
    text_label(.847, y, names(data$region_colors)[k], adj = 0, cex = .47)
  }
  text_label(.825, .249, "Synthetic sample key", adj = 0, cex = .53)
  for (k in 1:7) {
    y <- .229 - (k - 1) * .018
    rect(.827, y - .006, .839, y + .006, col = data$sample_colors[k], border = NA)
    text_label(.847, y, paste(names(data$sample_colors)[k], names(data$stage_colors)[k]),
               adj = 0, cex = .43)
  }
  text_label(.04, .043, "360 synthetic pathways × 84 region samples | six illustrative clusters",
             adj = 0, cex = .58)
  text_label(.51, .043, "Synthetic scores and terms", adj = 0, cex = .52, col = "#666666")
}

set.seed(20261108)
data <- simulate_ext7d()
render_example(data, draw_ext7d, "brain_pathway_activity_heatmap", out, c(12, 10))
