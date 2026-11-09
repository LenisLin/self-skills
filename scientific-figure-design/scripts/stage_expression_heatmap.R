# Show stage-specific gene modules across multiple organs. Simulate data and generate PNG, PDF, and RDS outputs.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else "."
entry <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
source(file.path(dirname(normalizePath(entry)), "_shared", "plot_style.R"))

simulate_2a <- function() {
  lists <- list(
    Liver = c("ID1", "LDHA", "HNF4A", "ATF2", "B2M", "SERPINF1", "APOC2", "APOC1", "APOB", "FASN", "MT1F", "MT1H", "APOC3", "TFRC"),
    `Skeletal muscle` = c("HMGA1", "HMGB2", "MEGF10", "MEOX1", "HMGB1", "ACTB", "PDGFRA", "PLS3", "BMP4", "MYOG", "WASF2", "PTPRS", "ACTA1", "MYH3")
  )
  lapply(lists, function(genes) {
    peak <- rep(1:7, length.out = 112)
    peak <- sort(peak)
    value <- outer(peak, 1:7, function(p, s) 2.3 * exp(-((p-s)/1.05)^2) - .8) + matrix(rnorm(112*7, 0, .35), 112)
    list(values = value, genes = genes, row = round(seq(3, 110, length.out = length(genes))))
  })
}

draw_2a <- function(data) {
  new_canvas(c(0, 1), c(0, 1))
  terms <- list(c("Stem cell population maintenance", "ATP metabolic process", "Hepatobiliary system development", "Hepatocyte apoptotic process", "Erythrocyte differentiation", "Response to steroid hormone", "Plasma lipoprotein particle", "Lipoprotein particle", "Alcohol metabolic process", "Fatty acid metabolic process", "Detoxification of inorganic compound", "Stress response to copper ion", "Sterol transport", "Iron ion homeostasis"),
                c("DNA conformation change", "Nucleus organization", "Myoblast migration", "Somitogenesis", "Positive regulation of DNA binding", "Cell-substrate junction", "Regulation of actin filament-based process", "Actin filament", "Cranial skeletal system development", "Muscle cell proliferation", "Postsynaptic actin cytoskeleton organization", "Regeneration", "Myosin binding", "Muscle contraction"))
  text_label(.355,.993,"Genes",adj=0,cex=.5); text_label(.53,.993,"GO terms",adj=0,cex=.5)
  segments(.355,.982,.49,.982,lwd=.45); segments(.53,.982,.93,.982,lwd=.45)
  for (k in seq_along(data)) {
    ytop <- if (k == 1) .95 else .47; ybot <- ytop - .36
    mat <- data[[k]]$values
    heat_raster(mat, .12, ybot, .32, ytop)
    rect(.105, ybot, .115, ytop, border = NA, col = c("#D77368", "#97B66C")[k])
    text_label(.09, (ytop+ybot)/2, names(data)[k], srt = 90, cex = .58)
    for (j in 1:7) rect(.12+(j-1)*.2/7, ytop+.005, .12+j*.2/7, ytop+.018, col = stage_col[j], border = NA)
    ys <- seq(ytop-.008, ybot+.008, length.out = length(data[[k]]$genes))
    actual <- ytop - (data[[k]]$row-.5)/nrow(mat)*(ytop-ybot)
    for (j in seq_along(ys)) {
      col <- gene_col[ceiling(j/2)]
      segments(.32, actual[j], .35, ys[j], col = "#999999", lwd = .4)
      text_label(.355, ys[j], data[[k]]$genes[j], adj = 0, font = 3, col = col, cex = .53)
    }
    for (j in 1:14) text_label(.53, ys[j], terms[[k]][j], adj = 0, col = gene_col[ceiling(j/2)], cex = .45)
  }
  text_label(.82,.47,"Scaled GE",adj=0,cex=.46)
  for (i in 1:100) rect(.82,.36+(i-1)*.0009,.83,.36+i*.0009,border=NA,col=heat_col[round(i*2.56)])
  text_label(.835,c(.36,.405,.45),c("-2","0","2"),adj=0,cex=.4)
  text_label(.82,.335,"CS stage",adj=0,cex=.46)
  for (j in 1:7) {rect(.82,.325-j*.016,.83,.338-j*.016,border=NA,col=stage_col[j]); text_label(.835,.331-j*.016,stage[j],adj=0,cex=.39)}
}

set.seed(20261108)
data <- simulate_2a()
render_example(data, draw_2a, "stage_expression_heatmap", out, c(6.6, 7.0))
