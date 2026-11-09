# 比较两个物种的共同基因随阶段变化。使用附带的模拟数据生成 PNG、PDF 和 RDS。
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else "."
entry <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
source(file.path(dirname(normalizePath(entry)), "_shared", "plot_style.R"))

simulate_ext10f <- function() {
  n <- 600; group <- rep(1:8,each=75); x <- seq(-1,1,length.out=7)
  human <- mouse <- matrix(0,n,7)
  for(i in 1:8) {
    rows <- which(group==i)
    hdirection <- if(i<=4) 1 else -1
    mdirection <- if(i %in% c(1:2,5:6)) 1 else -1
    human[rows,] <- outer(runif(length(rows),.7,1.3),hdirection*x) + matrix(rnorm(length(rows)*7,0,.25),length(rows))
    mouse[rows,] <- outer(runif(length(rows),.7,1.3),mdirection*x) + matrix(rnorm(length(rows)*7,0,.25),length(rows))
  }
  genes <- c("BCL11A","FOXG1","SOX4","SYT1","SMARCC2","THRA","SUCLG1","NHP2","HNRNPK","CAMTA1","CENPF","DHFR","ERCC1","FBLN1","EZH2","HCFC1","MSI1","PSAT1")
  annotation_rows <- round(seq(8,n-12,length.out=length(genes)))
  rownames(human) <- rownames(mouse) <- paste0("SyntheticGene",seq_len(n))
  rownames(human)[annotation_rows] <- rownames(mouse)[annotation_rows] <- genes
  list(human=human,mouse=mouse,group=group,annotation_rows=annotation_rows,synthetic=TRUE)
}

draw_ext10f <- function(data) {
  new_canvas(); top <- .84; bot <- .06; n <- nrow(data$human)
  palette <- grDevices::colorRampPalette(c("#172554","#826CAC","#FCFAFD","#DB8E82","#AA2925"))(256)
  heat_raster(data$human,.16,bot,.29,top,limits=c(-2,2),palette=palette)
  heat_raster(data$mouse,.295,bot,.425,top,limits=c(-2,2),palette=palette)
  human_stage <- stage_col
  mouse_stage <- grDevices::colorRampPalette(c("#F6E0C6","#8D5E3B"))(7)
  for(i in 1:7) {
    rect(.16+(i-1)*.13/7,.845,.16+i*.13/7,.86,border=NA,col=human_stage[i])
    rect(.295+(i-1)*.13/7,.845,.295+i*.13/7,.86,border=NA,col=mouse_stage[i])
    text_label(.16+(i-.5)*.13/7,.87,stage[i],srt=90,adj=0,cex=.38)
    text_label(.295+(i-.5)*.13/7,.87,paste0("E",seq(10.5,16.5,1)[i]),srt=90,adj=0,cex=.38)
  }
  text_label(.29,.985,"Brain",cex=.65)
  for(i in 1:8) {
    rows <- which(data$group==i); yt <- top-(min(rows)-1)*(top-bot)/n; yb <- top-max(rows)*(top-bot)/n
    rect(.435,yb,.45,yt,col=if(i<=4) "#D84243" else "#1D5189",border=NA)
    rect(.452,yb,.467,yt,col=if(i %in% c(1:2,5:6)) "#398C3C" else "#8B589D",border=NA)
    rect(.469,yb,.484,yt,col=if(i%%2) "#F09892" else "#70B8AD",border=NA)
  }
  text_label(c(.442,.459,.476),.865,c("Human group","Mouse group","Cluster"),srt=90,adj=0,cex=.35)
  genes <- rownames(data$human)[data$annotation_rows]
  label_y <- top-(data$annotation_rows-.5)*(top-bot)/n
  for(i in seq_along(genes)) {segments(.145,label_y[i],.16,label_y[i],lwd=.4);text_label(.14,label_y[i],genes[i],font=3,adj=1,cex=.4)}
  terms <- list(c("axon development","axonogenesis","modulation of chemical synaptic transmission"),
    c("modulation of chemical transmission","regulation of trans-synaptic signalling","synapse organization"),
    c("negative regulation of fatty acid biosynthetic process","pyroptosis","androgen receptor signaling"),
    c("vasculogenesis","regulation of vasculogenesis","fatty acid transport"),
    c("chondrocyte differentiation","apoptotic signaling","neutrophil migration"),
    c("toll-like receptor 3 signaling pathway","protein ubiquitination","ammonium ion metabolic process"),
    c("nuclear division","organelle fission","mitotic nuclear division"),
    c("DNA replication","DNA-dependent DNA replication","ncRNA processing"))
  border <- rep(c("#9891C1","#777777","#B451A1","#E58198"),each=2)
  for(i in 1:8) {
    yt <- .945-(i-1)*.11; yb <- yt-.105; ym <- (yt+yb)/2
    segments(.484,top-(i-.5)*(top-bot)/8,.50,ym,col=border[i],lwd=.55)
    rect(.50,yb,.87,yt,border=border[i],lwd=.6)
    for(j in 1:3) text_label(.505,yt-.015-(j-1)*.03,terms[[i]][j],adj=0,cex=.43,col=if(i%%2) "#E99C99" else "#72BEB3")
  }
  text_label(.90,.80,"Scaled exp.",adj=0,cex=.4)
  for(i in 1:100) rect(.90,.62+(i-1)*.0016,.91,.62+i*.0016,col=palette[round(i*2.56)],border=NA)
  text_label(.915,c(.62,.70,.78),c("-2","0","2"),adj=0,cex=.36)
  for(j in 1:3) {
    labels <- list(c("UTG","DTG"),c("UTG","DTG"),c("1","2"))[[j]]
    colors <- list(c("#D84243","#1D5189"),c("#398C3C","#8B589D"),c("#F09892","#70B8AD"))[[j]]
    y <- .55-(j-1)*.12
    text_label(.90,y,c("Human group","Mouse group","Cluster")[j],adj=0,cex=.38)
    for(k in 1:2) {rect(.90,y-.02*k,.91,y-.02*k+.012,col=colors[k],border=NA);text_label(.915,y-.02*k+.006,labels[k],adj=0,cex=.37)}
  }
}

set.seed(20261108)
data <- simulate_ext10f()
render_example(data, draw_ext10f, "cross_species_expression_heatmap", out, c(14, 7))
