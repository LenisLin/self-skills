# 展示轨迹中基因模块与阶段转换。使用附带的模拟数据生成 PNG、PDF 和 RDS。
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else "."
entry <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
source(file.path(dirname(normalizePath(entry)), "_shared", "plot_style.R"))

simulate_2g <- function() {
  genes <- list(c("LIN28A","PRTG","DLK1","MALAT1","FTH1","SFRP2","GJA1","SERPINF1","TRPM3","PMEL","TYR","SLC38A11","TYRP1","DCT","DAPL1"),
                c("IGF2R","BEST1","IL6ST","SMOC1","ATG10","RASGEF1B","MIR4300HG","SLC26A3","TSPAN9","GSTP1","KRT8","PITX1","FAM107A","KRT18","TNNT1","CLDN3","CLDN4","AGR2","CLDN10","MUC16","UGT2A1","AQP3","ANXA3","CD9","ATOH7","CRABP1","CCSER1","TUBB2B","RTN1","STMN2","CNTN2","OLFM1","PRPH","INA","SYT4","NSG1","TUBB2A","POU6F2","ELAVL4","MLLT11","TUBA1A","GAP43","SNCG","TMSB4X","TMSB10","MAP1B"))
  lapply(seq_along(genes), function(k) {
    n <- length(genes[[k]]); x <- seq(-2,2,length.out=120)
    peak <- rep(c(-1.4,0,1.4),length.out=n)
    if (k==2) peak <- rep(c(-1.5,-.1,1.5),times=c(14,14,n-28))
    value <- outer(peak,x,function(p,q) 2.8*exp(-((p-q)/1.3)^2)-1.4) + matrix(rnorm(n*120,0,.06),n)
    list(values = value, genes = genes[[k]], red = which(genes[[k]] %in% c("TYRP1","PMEL","ATOH7","SNCG","GAP43")))
  })
}

draw_2g <- function(data) {
  new_canvas(c(0, 1), c(0, 1))
  pal <- grDevices::colorRampPalette(c("#4C4197", "#398EAC", "#BFE0A0", "#F9EAA2", "#F18A47", "#A50026"))(256)
  for (k in 1:2) {
    ytop <- c(.96,.70)[k]; ybot <- c(.75,.13)[k]
    d <- data[[k]]; n <- length(d$genes)
    heat_raster(d$values, .29, ybot, .71, ytop, palette = pal)
    for (i in 1:n) {
      y <- ytop-(i-.5)/n*(ytop-ybot); left <- i %% 2 == 1
      text_label(if (left) .275 else .725, y, d$genes[i], adj = if (left) 1 else 0,
                 font = 3, cex = if (k == 1) .5 else .38,
                 col = if (i %in% d$red) "#D7483B" else "black")
    }
    subs <- if (k == 1) c("#E9A4AA", "#D44D49") else c("#AB8DBB", "#A47A62")
    for (j in 1:120) {
      rect(.29+(j-1)*.42/120,ybot-.014,.29+j*.42/120,ybot-.006,col=subs[1+(j>60)],border=NA)
      rect(.29+(j-1)*.42/120,ybot-.028,.29+j*.42/120,ybot-.020,col=stage_col[c(1,2,3,4,6,7)[ceiling(j/20)]],border=NA)
    }
    text_label(.725,ybot-.010,"Substructure",adj=0,cex=.42)
    text_label(.725,ybot-.024,"CS stage",adj=0,cex=.42)
  }
  text_label(.29,.065,"Scaled GE",adj=0,cex=.45)
  for(i in 1:100) rect(.29+(i-1)*.0014,.04,.29+i*.0014,.05,col=pal[round(i*2.56)],border=NA)
  text_label(c(.29,.36,.43),.028,c("-2","0","2"),cex=.4)
}

set.seed(20261108)
data <- simulate_2g()
render_example(data, draw_2g, "trajectory_gene_modules_heatmap", out, c(5.2, 6.4))
