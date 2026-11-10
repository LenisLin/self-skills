#!/usr/bin/env Rscript
# Figure 3g: four gene-expression modules on mirrored pseudotime branches.
# All values are simulated; GO terms reproduce the reference vocabulary.
args <- commandArgs(trailingOnly=TRUE)
out <- if(length(args)) args[1] else '.'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
set.seed(3401)
n_gene <- c(65,165,90,95); n_position <- 180
pseudotime <- abs(seq(-1,1,length.out=n_position))
branch <- rep(c('States2,3,4','State5'),each=90)
module <- rep(c('Cluster1','Cluster2','Cluster4','Cluster3'),n_gene)
expression <- matrix(0,sum(n_gene),n_position)
for(i in seq_len(nrow(expression))) {
  k <- match(module[i],c('Cluster1','Cluster2','Cluster4','Cluster3'))
  t <- pseudotime
  signal <- switch(k, 2.1*t*(branch=='State5')-.8*t*(branch!='State5'),
                   2.4*t^1.5*(branch=='State5')-.7*t*(branch!='State5'),
                   2.1*exp(-((t-runif(1,.15,.75))/.3)^2)*(branch!='State5')-.6*t,
                   2.3*t*(branch!='State5')-.8*t*(branch=='State5'))
  # Smooth gene-specific kinetics keep the matrix biologically structured.
  signal <- signal + .5*sin(t*runif(1,4,12)+runif(1,0,6)) + rnorm(n_position,0,.09)
  expression[i,] <- as.numeric(scale(signal))
}
expression[] <- pmax(-3,pmin(3,expression))
rownames(expression) <- sprintf('simulated_gene_%03d',seq_len(nrow(expression)))
# Apply the same leaf order to the heatmap and its module dendrograms.
trees <- lapply(c('Cluster1','Cluster2','Cluster4','Cluster3'),function(m) hclust(dist(expression[module==m,]),method='average'))
ordered_rows <- unlist(lapply(1:4,function(k) which(module==c('Cluster1','Cluster2','Cluster4','Cluster3')[k])[trees[[k]]$order]))
expression <- expression[ordered_rows,]

terms <- list(c('Nervous system development','Cellular component morphogenesis',
'Modulation of chemical synaptic transmission','Chloride transmembrane transport','Regulation of neurotransmitter secretion'),
c('Protein modification by small protein\nconjugation or removal','Double-strand break repair'),
c('Peptide metabolic process','Cellular macromolecule biosynthetic process','Proton transmembrane transport'),
c('Regulation of protein modification process','Nitrogen compound transport','Intracellular signal transduction','Positive regulation of autophagy'))
# Hypergeometric enrichment from a synthetic 20,000-gene background.
enrichment <- lapply(seq_along(terms),function(k) {
 N <- 20000; set_size <- seq(230,650,length.out=length(terms[[k]])); overlap <- seq(14,21,length.out=length(set_size))
 data.frame(term=terms[[k]],module_id=c('Cluster1','Cluster2','Cluster4','Cluster3')[k],background=N,set_size=round(set_size),module_size=n_gene[k],overlap=round(overlap),
 p=phyper(round(overlap)-1,round(set_size),N-round(set_size),n_gene[k],lower.tail=FALSE))
})
all_q <- p.adjust(unlist(lapply(enrichment,function(d)d$p)),'BH'); offset <- 0
for(k in seq_along(enrichment)){n <- nrow(enrichment[[k]]); enrichment[[k]]$q <- all_q[offset+seq_len(n)]; offset <- offset+n}
pal <- colorRampPalette(c('#3d6c90','#c0d4de','#f6f5f2','#d39799','#92282f'))(256)
module_colors <- c('#b8a0ff','#ff9e97','#8ddd24','#ee8df4')
draw <- function() {
 par(mar=rep(0,4),family='sans',xaxs='i',yaxs='i');plot.new();plot.window(c(0,1),c(0,1))
 text(.535,.975,'g',font=2,cex=1.8)
 text(c(.64,.78,.955),.96,c('States2,3,4','State1','State5'),cex=.73)
 arrows(.60,.931,.98,.931,code=3,length=.07,lwd=1.3,col='#455369');segments(.79,.918,.79,.944,lwd=2,col='#455369')
 hx <- .58; hw <- .415; top <- .89; bottom <- .10
 idx <- 1+pmin(255,round((expression+3)/6*255));rasterImage(as.raster(matrix(pal[idx],nrow(expression))),hx,bottom,hx+hw,top,interpolate=FALSE)
 segments(hx+hw/2,bottom,hx+hw/2,top,col='white',lwd=2)
 rect(hx,.898,hx+.072,.91,col='#f15b6c',border=NA);rect(hx+.072,.898,.925,.91,col='#a2a3a5',border=NA);rect(.925,.898,.995,.91,col='#8099cf',border=NA)
 bounds <- top-c(0,cumsum(n_gene))/sum(n_gene)*(top-bottom)
 # A clustered dendrogram for each gene module; leaves retain heatmap row order.
 for(k in 1:4) {
  ys <- seq(bounds[k],bounds[k+1],length.out=n_gene[k]+1)
  rect(.57,bounds[k+1],.578,bounds[k],col=module_colors[k],border=NA)
  if(k>1) segments(hx,bounds[k],.995,bounds[k],col='white',lwd=2)
  dend <- as.dendrogram(trees[[k]])
  cursor <- 0
  walk <- function(node) {
   if(is.leaf(node)){cursor <<- cursor+1;return(c(.568,mean(ys[c(cursor,cursor+1)])))}
   a <- walk(node[[1]]); b <- walk(node[[2]]); xx <- .568-.024*attr(node,'height')/attr(dend,'height')
   segments(xx,a[2],xx,b[2],lwd=.35);segments(xx,a[2],a[1],a[2],lwd=.35);segments(xx,b[2],b[1],b[2],lwd=.35)
   c(xx,mean(c(a[2],b[2])))
  };walk(dend)
 }
 # Table and translucent module-to-table ribbons match the reference composition.
 y <- .685;segments(.01,y,.49,y);text(.18,y-.019,'GO terms',cex=.75);text(.44,y-.019,'P',font=3,cex=.75);y<-y-.039
 for(k in 1:4) {
  ystart<-y;segments(.01,y,.49,y);text(.02,y-.021,c('Cluster1','Cluster2','Cluster4','Cluster3')[k],adj=0,col=module_colors[k],cex=.73); y<-y-.042;segments(.01,y,.49,y)
  d<-enrichment[[k]]
  for(j in seq_len(nrow(d))) {
   dy<-if(grepl('\n',d$term[j])) .047 else .03
   text(.02,y-dy/2,d$term[j],adj=0,cex=.63)
   text(.484,y-dy/2,formatC(d$p[j],format='e',digits=2),adj=1,cex=.62);y<-y-dy
  }
  segments(.01,y,.49,y)
  polygon(c(.49,.565,.565,.49),c(ystart,bounds[k],bounds[k+1],y),col=adjustcolor(module_colors[k],.14),border=NA)
 }
 rasterImage(as.raster(matrix(pal,nrow=1)),.715,.051,.94,.068,interpolate=FALSE)
 text(seq(.715,.94,length.out=7),.033,-3:3,cex=.65)
 text(.667,.058,'Relative\nexpression\nlevel',cex=.7)
}
saveRDS(list(expression=expression,module=module,pseudotime=pseudotime,branch=branch,enrichment=enrichment),file.path(out,'branched_pseudotime_gene_modules_simulated.rds'))
png(file.path(out,'branched_pseudotime_gene_modules.png'),width=1660,height=1350,res=180,type='cairo');draw();dev.off()
cairo_pdf(file.path(out,'branched_pseudotime_gene_modules.pdf'),width=9.22,height=7.5);draw();dev.off()
