# 比较多个阶段的差异基因及方向。使用附带的模拟数据生成 PNG、PDF 和 RDS。
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else "."
entry <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
source(file.path(dirname(normalizePath(entry)), "_shared", "plot_style.R"))

simulate_3b <- function() {
  cols <- c("#8DD3C7", "#FB8072", "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#BC80BD")
  lapply(seq_along(stage), function(i) {
    n <- 900; effect <- pmax(-3,pmin(3,rnorm(n,0,.72)))
    limit <- c(271,170,220,85,208,269,288)[i]
    score <- pmin(limit,abs(effect)^2*runif(n,15,limit/3))
    gene <- paste0("SyntheticGene", seq_len(n))
    chosen <- c(order(effect,decreasing=TRUE)[1:3],order(effect)[1:3])
    gene[chosen] <- c("MYH6","NPPA","PAM","MYH7","MYL2","BMP4")
    p_adj <- 10^(-score)
    data.frame(effect = effect, p_adj = p_adj, signed_score = sign(effect)*(-log10(p_adj)), gene=gene,
               significant = p_adj < .05 & abs(effect) > .25, color = cols[i],limit=limit)
  })
}

draw_3b <- function(data) {
  par(mfrow = c(1,7), mar = c(3.6,2.5,.4,.3), oma=c(1.2,0,0,0), mgp = c(1.4,.35,0), tcl = -.16,
      cex.axis = .5, cex.lab = .55, family = "sans")
  for (i in seq_along(data)) {
    d <- data[[i]]; lim <- d$limit[1]
    plot(d$signed_score,d$effect,pch=16,cex=.48,col=ifelse(d$significant,d$color,"#DEE1E6"),
         xlim=c(-lim,lim),ylim=c(-3.1,3.1),axes=FALSE,xlab=stage[i],ylab=if(i==1) "Atrium vs ventricle (average log2FC)" else "")
    abline(h=c(-.25,.25),lty=2,lwd=.45,col="#888888")
    axis(1,at=c(-lim,0,lim),labels=FALSE,lwd=.4,lwd.ticks=.4)
    text(c(-lim,0,lim),par("usr")[3]-.12,labels=c(-lim,0,lim),srt=45,adj=1,xpd=NA,cex=.46)
    if(i==1) axis(2,at=c(-3,0,3),las=1,lwd=.4,lwd.ticks=.4)
    box(bty="l",lwd=.4)
    top <- c(order(d$effect,decreasing=TRUE)[1:3],order(d$effect)[1:3])
    label_y <- c(2.8,2.45,2.1,-2.1,-2.45,-2.8)
    label_x <- ifelse(d$signed_score[top]>0, -.12*lim, .12*lim)
    segments(d$signed_score[top],d$effect[top],label_x,label_y,lwd=.35)
    for(j in seq_along(top)) text(label_x[j],label_y[j],d$gene[top[j]],cex=.6,font=3,adj=if(label_x[j]<0) 1 else 0)
  }
  mtext("Signed -log10(adjusted P), simulated", side=1, outer=TRUE, line=.2, cex=.65)
}

set.seed(20261108)
data <- simulate_3b()
render_example(data, draw_3b, "stage_differential_volcano", out, c(8, 8))
