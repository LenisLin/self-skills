# 比较不同发育阶段的空间解剖结构。使用附带的模拟数据生成 PNG、PDF 和 RDS。
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else "."
entry <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
source(file.path(dirname(normalizePath(entry)), "_shared", "plot_style.R"))

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

set.seed(20261108)
data <- simulate_ext2a()
render_example(data, draw_ext2a, "spatial_anatomy_development", out, c(11, 10))
