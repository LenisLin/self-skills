# Shared palettes, matrix color mapping, canvas styling and figure export.
stage <- c("CS12–13", "CS14–15", "CS17", "CS18", "CS19", "CS20", "CS23")
stage_col <- c("#EEF2FA", "#C2D8EA", "#9CC5DB", "#69A5CA", "#438ABA", "#2169A9", "#00428A")
gene_col <- c("#BC6F45", "#87BA54", "#D497A2", "#CCB9CC", "#8DC0CF", "#7695B4", "#73A39D")
heat_col <- grDevices::colorRampPalette(c("#6CBAD1", "#F8F6EA", "#BB3D27"))(256)

scaled_colors <- function(x, limits = c(-2, 2), palette = heat_col) {
  index <- pmax(1L, pmin(length(palette), as.integer((x - limits[1]) /
    diff(limits) * (length(palette) - 1)) + 1L))
  matrix(palette[index], nrow = nrow(x), ncol = ncol(x))
}

heat_raster <- function(z, xleft, ybottom, xright, ytop, limits = c(-2, 2), palette = heat_col) {
  graphics::rasterImage(as.raster(scaled_colors(z, limits, palette)), xleft, ybottom, xright, ytop,
                        interpolate = FALSE)
}

new_canvas <- function(xlim = c(0, 1), ylim = c(0, 1)) {
  par(mar = rep(0, 4), xaxs = "i", yaxs = "i", family = "sans")
  plot.new(); plot.window(xlim = xlim, ylim = ylim)
}

text_label <- function(x, y, labels, cex = .55, col = "black", font = 1, ...) {
  text(x, y, labels, cex = cex, col = col, font = font, ...)
}

render_example <- function(data, draw, stem, out, size) {
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  saveRDS(data, file.path(out, paste0(stem, "_simulated.rds")))
  for (format in c("pdf", "png")) {
    path <- file.path(out, paste0(stem, ".", format))
    if (format == "pdf") grDevices::cairo_pdf(path, width = size[1], height = size[2])
    else grDevices::png(path, width = size[1], height = size[2], units = "in", res = 200, type = "cairo")
    tryCatch(draw(data), finally = grDevices::dev.off())
  }
  cat("completed", stem, "\n")
}
