#!/usr/bin/env Rscript
# Extended Data Figure 7f: branchpoint-1 expression modules and full KEGG table.
args<-commandArgs(trailingOnly=TRUE);out<-if(length(args))args[1] else '.'
dir.create(out,recursive=TRUE,showWarnings=FALSE);set.seed(3405)
module_size<-c(90,145,68);module<-rep(1:3,module_size);t<-seq(-1,1,length.out=160)
value<-matrix(0,length(module),160)
for(i in seq_len(nrow(value))){k<-module[i]
 signal<-switch(k,1.8*t, -1.8*t, 2.1*exp(-(t/.16)^2)-.6*t)
 signal<-signal+.7*sin(t*runif(1,3,12)+runif(1,0,6))+.4*exp(-((t-runif(1,-1,1))/.2)^2)+rnorm(160,0,.08)
 value[i,]<-as.numeric(scale(signal))
};value[]<-pmax(-3,pmin(3,value))
terms<-list(c('DNA replication','Nucleotide metabolism','Cell cycle'),
c('Neurotrophin signaling pathway','Protein processing in endoplasmic reticulum','Propanoate metabolism','Gastric acid secretion','Adipocytokine signaling pathway','beta-Alanine metabolism','Valine, leucine and isoleucine degradation','Biosynthesis of unsaturated fatty acids','Fructose and mannose metabolism'),
c('Proteasome','Endocytosis','Protein processing in endoplasmic reticulum','Bacterial invasion of epithelial cells'))
# KEGG P values come from synthetic gene-set overlaps, with source-like ordering.
enrichment<-lapply(1:3,function(k){size<-rep(600,length(terms[[k]]));overlap<-if(k==1)c(21,18,17) else if(k==2)c(18,18,16,16,15,14,14,13,13) else c(25,23,22,21)
 data.frame(term=terms[[k]],module_id=k,background=20000,set_size=size,module_size=sum(module==k),overlap=overlap,p=phyper(overlap-1,size,20000-size,sum(module==k),lower.tail=FALSE))})
all_q<-p.adjust(unlist(lapply(enrichment,function(d)d$p)),'BH');offset<-0
for(k in seq_along(enrichment)){n<-nrow(enrichment[[k]]);enrichment[[k]]$q<-all_q[offset+seq_len(n)];offset<-offset+n}
col_cluster<-c('#eb77ed','#ff8b80','#75aeec');pal<-colorRampPalette(c('#49748d','#bdd0da','#faf9f6','#d39999','#91363a'))(256)
trees<-lapply(1:3,function(k)hclust(dist(value[module==k,]),method='average'));ord<-unlist(lapply(1:3,function(k)which(module==k)[trees[[k]]$order]));value<-value[ord,]
draw<-function(){par(mar=rep(0,4),family='sans',xaxs='i',yaxs='i');plot.new();plot.window(c(0,1),c(0,1))
 text(.012,.97,'f',cex=1.7)
 hx<-.045;hw<-.39;top<-.92;bot<-.025;bound<-top-c(0,cumsum(module_size))/sum(module_size)*(top-bot)
 idx<-1+round((value+3)/6*255);rasterImage(as.raster(matrix(pal[idx],nrow(value))),hx,bot,hx+hw,top,interpolate=FALSE)
 segments(hx+hw/2,bot,hx+hw/2,top,col='white',lwd=1.4)
 text(c(.105,.252,.397),.965,c('State2,3,4','Pre-branch','State5'),cex=.73)
 for(j in 1:4)rect(hx+(j-1)*hw/4,.927,hx+j*hw/4,.938,col=c('#ef5a66','#999999','#999999','#8095c9')[j],border='white',lwd=.3)
 text(.72,.965,'Enriched KEGG (pvalue)',cex=.77);segments(.455,.937,.99,.937,lwd=.8)
 for(k in 1:3){
  rect(.036,bound[k+1],.043,bound[k],col=col_cluster[k],border=NA);if(k>1)segments(hx,bound[k],hx+hw,bound[k],col='white',lwd=2)
  den<-as.dendrogram(trees[[k]]);ys<-seq(bound[k],bound[k+1],length.out=module_size[k]+1);cursor<-0
  walk<-function(node){if(is.leaf(node)){cursor<<-cursor+1;return(c(.034,mean(ys[c(cursor,cursor+1)])))};a<-walk(node[[1]]);b<-walk(node[[2]]);x<-.034-.028*attr(node,'height')/attr(den,'height');segments(x,a[2],x,b[2],lwd=.3);segments(x,a[2],a[1],a[2],lwd=.3);segments(x,b[2],b[1],b[2],lwd=.3);c(x,mean(c(a[2],b[2])))};walk(den)
 }
 # Full three-cluster KEGG term table, independent of neighboring panel 7g.
 ypos<-c(.91,.715,.255);dy<-.041
 for(k in 1:3){d<-enrichment[[k]];y<-ypos[k];text(.473,y,paste0('Cluster',k),adj=0,col=col_cluster[k],cex=.74)
  rect(.455,y-.025-nrow(d)*dy,.465,y-.026,col=col_cluster[k],border=NA)
  for(j in seq_len(nrow(d)))text(.473,y-.025-j*dy+dy/2,paste0(d$term[j],' (',formatC(d$p[j],format='E',digits=2),')'),adj=0,cex=.69)
 }
}
saveRDS(list(expression=value,module=module,pseudotime=t,enrichment=enrichment),file.path(out,'forestomach_branchpoint_gene_modules_simulated.rds'))
png(file.path(out,'forestomach_branchpoint_gene_modules.png'),width=1175,height=750,res=150,type='cairo');draw();dev.off()
cairo_pdf(file.path(out,'forestomach_branchpoint_gene_modules.pdf'),width=7.83,height=5);draw();dev.off()
