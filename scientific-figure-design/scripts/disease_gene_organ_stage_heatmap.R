# Show expression of disease-associated genes across organs and stages. Simulate data and generate PNG, PDF, and RDS outputs.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else "."
entry <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
source(file.path(dirname(normalizePath(entry)), "_shared", "plot_style.R"))

simulate_5e <- function() {
  organs <- c("Brain","SpC","Eye","IE","Heart","Som","Myo","SM","HD","Liver","LP","Lung","PG","Gut")
  n <- 1740; m <- length(organs)*7
  group <- cut(seq_len(n),breaks=9,labels=FALSE)
  x <- matrix(rnorm(n*m,mean=-.5,sd=.55),n)
  boundaries <- c(1,2,3,4,5,7,9,11,13,15)
  for (i in 1:9) {cols <- ((boundaries[i]-1)*7+1):((boundaries[i+1]-1)*7); rows <- which(group==i); x[rows,cols] <- x[rows,cols]+matrix(rexp(length(rows)*length(cols),rate=.42),length(rows))}
  labels <- c("FAM149B1","DCC","BCL11A","GAA","ETFB","PEX5","APC2","OTX2","ALDH1A3","RAX","BFSP2","TMEM94","COA5","MMADHC","PEX1","STAG2","NPC2","GATA4","GATA6","AGL","TBX20","TTN","LDB3","LMNA","GALE","SLC33A1","GFER","ARG1","FTL","MMACHC","PET100","CCBE1","ABCD4")
  annotation_rows <- round(seq(40,n-60,length.out=length(labels)))
  rownames(x) <- paste0("SyntheticGene",seq_len(n)); rownames(x)[annotation_rows] <- labels
  list(values=x,organs=organs,group=group,annotation_rows=annotation_rows)
}

draw_5e <- function(data) {
  new_canvas(c(0,1),c(0,1)); mat <- data$values; n <- nrow(mat); m <- ncol(mat)
  pal <- grDevices::colorRampPalette(c("#78C7DB","#F9F8EF","#BC3419"))(256)
  heat_raster(mat,.10,.06,.73,.85,limits=c(-5,10),palette=pal)
  organ_cols <- grDevices::hcl.colors(14,"Pastel 1")
  for(j in 1:m) {
    organ <- ceiling(j/7); x1 <- .1+(j-1)*.63/m; x2 <- .1+j*.63/m
    rect(x1,.855,x2,.866,col=stage_col[(j-1)%%7+1],border=NA)
    rect(x1,.868,x2,.879,col=organ_cols[organ],border=NA)
    rect(x1,.881,x2,.892,col=c("#C5D998","#DFD88D","#B4BD88")[(organ-1)%%3+1],border=NA)
  }
  for(i in 1:14) text_label(.1+(i-.5)*.63/14,.905,data$organs[i],srt=45,adj=0,cex=.42)
  text_label(.096,c(.886,.873,.86),c("Layer","Organ","Stage"),adj=1,cex=.4)
  for(i in 1:9) {
    boundaries <- c(1,2,3,4,5,7,9,11,13,15)
    rows <- which(data$group==i); xl <- .1+(boundaries[i]-1)*7*.63/m; xr <- .1+(boundaries[i+1]-1)*7*.63/m
    rect(xl,.85-max(rows)*.79/n,xr,.85-(min(rows)-1)*.79/n,border="#C63C32",lty=2,lwd=.7)
  }
  labels <- rownames(mat)[data$annotation_rows]
  pos <- .85-(data$annotation_rows-.5)*.79/n
  for(i in seq_along(pos)) {segments(.73,pos[i],.76,pos[i]+.002,lwd=.4,col="#777777"); text_label(.765,pos[i]+.002,labels[i],font=3,adj=0,cex=.36,col=gene_col[(i-1)%%7+1])}
  for(i in 1:100) rect(.94,.20+(i-1)*.003,.955,.20+i*.003,col=pal[round(i*2.56)],border=NA)
  text_label(.92,.52,"Scaled GE",cex=.42); text_label(.96,c(.20,.30,.40,.50),c("−5","0","5","10"),adj=0,cex=.4)
}

set.seed(20261108)
data <- simulate_5e()
render_example(data, draw_5e, "disease_gene_organ_stage_heatmap", out, c(7, 8.5))
