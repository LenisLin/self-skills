# Synthetic illustrations of HESTA extended panels; all values and GO-like labels
# are illustrative, and simulated counts carry no biological inference.
# Required upstream: the caller sets seed 20261108 and supplies stage (7 labels),
# stage_col, new_canvas(), heat_raster() and text_label() from hesta_panels.R.
# Source this file as definitions only. simulate_ext*() return reusable lists;
# draw_ext*(data) draw on the caller's open device and save no files.
# Suggested sizes (inches): ext2a 15 x 6.5; ext7c 6.8 x 6.8; ext7d 12 x 10.
# Outputs: ext2a point/annotation/specimen tables; ext7c feature and exact Spearman
# matrices plus ordered samples; ext7d scores, row clusters, ordered samples,
# region/sample palettes and synthetic keyword data. Caller handles RDS/rendering.

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

# Curved sagittal silhouettes are a head bulb joined to a tapered C-shaped axis.
# Return textured synthetic region points, a 36-region palette and seven specimens.
simulate_ext2a <- function() {
  regions <- c("Forebrain", "Midbrain", "Hindbrain", "Ventricle", "Pallium", "Subpallium",
               "Diencephalon", "Hypothalamus", "Cerebellar field", "Spinal cord",
               "Neural tube", "Eye field", "Lens field", "Optic stalk", "Otic field",
               "Pharyngeal arch", "Facial field", "Heart field", "Atrial field",
               "Ventricular field", "Liver field", "Lung field", "Foregut", "Midgut",
               "Hindgut", "Mesentery", "Renal field", "Adrenal field", "Somite field",
               "Muscle field", "Cartilage field", "Limb field", "Vascular field",
               "Mesenchyme", "Surface field", "Tail field")
  palette <- setNames(grDevices::hcl.colors(length(regions), "Dynamic"), regions)
  centers <- data.frame(region = regions,
    x = c(.72,.52,.37,.61,.78,.69,.58,.61,.30,.17,.18,.81,.86,.75,.36,.52,.77,
          .48,.54,.48,.43,.35,.35,.41,.57,.37,.28,.29,.14,.17,.21,.36,.27,.24,.09,.67),
    y = c(.88,.88,.79,.82,.94,.75,.74,.69,.68,.49,.64,.79,.78,.77,.72,.64,.70,
          .53,.58,.49,.39,.50,.57,.26,.17,.32,.34,.40,.35,.26,.19,.18,.58,.44,.55,.19))
  specimens <- data.frame(sample_id = sprintf("SIM-EMB%02d", 1:7),
    stage = stage, stage_index = 1:7, height = c(.08,.10,.15,.19,.25,.30,.48),
    synthetic = TRUE)
  angle <- seq(65, 310, length.out = 100) * pi / 180
  axis_x <- .49 + .31 * cos(angle)
  axis_y <- .46 + .35 * sin(angle)
  radius <- .115 + .045 * sin(seq(0, pi, length.out = 100))
  radius[71:100] <- seq(radius[71], .028, length.out = 30)
  point_tables <- vector("list", 7)
  for (i in 1:7) {
    grid <- expand.grid(x = seq(.025, .98, length.out = 85 + 10 * i),
                        y = seq(-.04, 1.03, length.out = 110 + 12 * i))
    grid$x <- grid$x + runif(nrow(grid), -.002, .002)
    grid$y <- grid$y + runif(nrow(grid), -.002, .002)
    tube <- outer(grid$x, axis_x, "-")^2 + outer(grid$y, axis_y, "-")^2
    inside <- rowSums(sweep(tube, 2, radius^2, "<=")) > 0
    head <- ((grid$x - .63) / .235)^2 + ((grid$y - .83) / .185)^2 <= 1
    grid <- grid[inside | head, ]
    # Anisotropic nearest fields form contiguous patches with fine boundary texture.
    distance <- (outer(grid$x, centers$x, "-") / .10)^2 +
      (outer(grid$y, centers$y, "-") / .085)^2
    distance <- distance + matrix(runif(length(distance), 0, .18), nrow(distance))
    region <- regions[max.col(-distance, ties.method = "first")]
    point_tables[[i]] <- data.frame(sample_id = specimens$sample_id[i],
      stage = stage[i], stage_index = i, x = grid$x, y = grid$y,
      region = region, texture = runif(nrow(grid), .73, 1), synthetic = TRUE)
  }
  list(points = do.call(rbind, point_tables), annotation_palette = palette,
       region_centers = centers, specimens = specimens,
       stages = data.frame(stage = stage, color = stage_col),
       scale_bar = list(label = "schematic scale (uncalibrated)", calibrated = FALSE),
       description = "Synthetic anatomical fields; schematic spatial units")
}

draw_ext2a <- function(data) {
  old <- par(bg = "black")
  on.exit(par(old))
  new_canvas()
  rect(0, 0, 1, 1, col = "black", border = NA)
  text_label(.025, .974, "Synthetic regions | Simulated illustration", adj = 0,
             col = "white", cex = .8)
  palette <- data$annotation_palette
  headings <- paste("Synthetic region set", LETTERS[1:6])
  for (column in 0:5) text_label(.025+column*.162,.925,headings[column+1],adj=0,col="white",cex=.42)
  for (j in seq_along(palette)) {
    column <- (j - 1) %/% 6
    row <- (j - 1) %% 6
    x <- .025 + column * .162
    y <- .899 - row * .027
    rect(x, y - .006, x + .008, y + .006, col = palette[j], border = NA)
    text_label(x + .012, y, names(palette)[j], adj = 0, col = "white", cex = .48)
  }
  # Allocate increasing specimen widths with slender schematic sagittal proportions.
  aspect <- par("pin")[2] / par("pin")[1]
  widths <- data$specimens$height * aspect * .88 * .52
  centers <- .03 + cumsum(widths) - widths / 2 + (0:6) * .006
  for (i in 1:nrow(data$specimens)) {
    d <- data$points[data$points$sample_id == data$specimens$sample_id[i], ]
    h <- data$specimens$height[i]
    center <- centers[i]
    x <- center + (d$x - .45) * h * aspect * .52
    y <- .084 + (d$y - min(d$y)) / 1.07 * h
    rgb_col <- grDevices::col2rgb(palette[d$region]) / 255
    rgb_col <- sweep(rgb_col, 2, d$texture * .72, "*")
    colors <- grDevices::rgb(rgb_col[1, ], rgb_col[2, ], rgb_col[3, ])
    points(x, y, pch = 15, cex = .16 + .012 * i, col = colors)
    text_label(center, .053, data$specimens$stage[i], col = "white", cex = .40)
    text_label(center, .027, data$specimens$sample_id[i], col = "#AAAAAA", cex = .32)
  }
  segments(.87, .080, .92, .080, col = "white", lwd = 2)
  text_label(.895, .100, data$scale_bar$label, col = "white", cex = .38)
}

# A shared early factor creates a broad block; later factors and region signatures
# generate heterogeneous late-stage profiles. Correlations are computed from ranks.
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

# Region blocks each contain seven synthetic section measurements in stage order.
# Scores and sampled GO-like phrases describe a visual simulation, not enrichment.
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
