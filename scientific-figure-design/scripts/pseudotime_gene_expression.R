# Compare expression trends of key genes along pseudotime. Simulate data and generate PNG, PDF, and RDS outputs.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else "."
entry <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
source(file.path(dirname(normalizePath(entry)), "_shared", "plot_style.R"))

simulate_4i <- function() {
  x <- seq(0,20,length.out=201)
  data.frame(pseudotime=rep(x,4),gene=rep(c("HES5","HMGA2","FOXG1","NEUROG2"),each=length(x)),
    expression=c(.55+.85*exp(-((x-5.5)/6)^2), .47-.08*exp(-((x-3)/4)^2)+.95/(1+exp(-(x-12)/2.5)),
                 .02+1.08*exp(-((x-15)/7)^2), .29+.22*exp(-((x-4)/4)^2)+.52*(x/20)^7))
}

draw_4i <- function(data) {
  par(mar=c(3,3,2.8,.7),mgp=c(1.6,.45,0),tcl=-.18,cex.axis=.7,cex.lab=.8,family="sans")
  plot(NA,xlim=c(0,20),ylim=c(0,1.5),xlab="Pseudotime",ylab="Expression",axes=FALSE)
  axis(1,at=seq(0,20,5),lwd=.6); axis(2,at=0:1,las=1,lwd=.6); box(bty="l",lwd=.6)
  cols <- c(HES5="#F56300", HMGA2="#00D7CE", FOXG1="#28A2F9", NEUROG2="#7447D1")
  for (gene in names(cols)) {d <- data[data$gene==gene,]; lines(d$pseudotime,d$expression,col=cols[gene],lwd=1.25)}
  legend("top",legend=names(cols),col=cols,lwd=1.25,ncol=2,bty="n",text.font=3,cex=.65,inset=c(0,-.17),xpd=NA)
}

set.seed(20261108)
data <- simulate_4i()
render_example(data, draw_4i, "pseudotime_gene_expression", out, c(3.2, 2.6))
