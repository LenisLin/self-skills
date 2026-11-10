#!/usr/bin/env Rscript
# Extended Data Figure 3h: simulated spermatogenesis branch kinetics and GO bars.
args<-commandArgs(trailingOnly=TRUE);out<-if(length(args))args[1] else '.'
dir.create(out,recursive=TRUE,showWarnings=FALSE);set.seed(3404)
module_size<-c(48,112,115,115);cluster<-rep(c(4,1,3,2),module_size)
t<-seq(-1,1,length.out=160);distance<-abs(t);value<-matrix(0,length(cluster),length(t))
for(i in seq_len(nrow(value))){k<-match(cluster[i],c(4,1,3,2))
 signal<-switch(k,2.7*exp(-((t-.97)/.12)^2),2.6*exp(-((t+.96)/.14)^2)-1.4*exp(-(t/.12)^2),
 3*exp(-(t/.07)^2)-1.8*distance^6,2.8*exp(-((t+.97)/.12)^2)-4*t^7)
 signal<-signal+.6*sin(t*runif(1,3,13)+runif(1,0,6))+.3*exp(-((t-runif(1,-1,1))/.1)^2)+rnorm(160,0,.08)
 value[i,]<-as.numeric(scale(signal))
}
value[]<-pmax(-3,pmin(3,value))
terms<-list(c('regulation of plasma membrane\nbounded cell projection assembly','protein catabolic process','phospholipid biosynthetic process','glycerolipid biosynthetic process'),
c('microtubule-based process','actin cytoskeleton organization','actin filament-based process','microtubule cytoskeleton organization','reproductive process','regulation of organelle organization'),
c('RNA splicing','translation','protein folding','proton motive force-driven ATP synthesis','ATP metabolic process','cell cycle process','chromosome condensation'),
c('microtubule-based movement','cilium organization','axoneme assembly','spermatogenesis','regulation of cilium movement','mitochondrion organization'))
targets<-list(c(.8,.6,.65,.6),c(1.7,1.5,1.4,1.3,1.2,1.1),c(10.2,9,7.3,3.2,2.5,2.2,1.6),c(10.4,7.5,5.3,4.3,3.8,2.5))
# Select synthetic overlap counts around the visual target; calculate P and BH q.
enrichment<-lapply(1:4,function(k){
 n<-sum(cluster==c(4,1,3,2)[k]);overlaps<-0:min(100,n)
 p<-phyper(overlaps-1,600,19400,n,lower.tail=FALSE)
 ov<-vapply(targets[[k]],function(z)overlaps[which.min(abs(-log10(p)-z-1))],numeric(1))
 data.frame(term=terms[[k]],module_id=c(4,1,3,2)[k],set_size=600,background=20000,module_size=n,overlap=ov,p=phyper(ov-1,600,19400,n,lower.tail=FALSE))
})
qs<-p.adjust(unlist(lapply(enrichment,function(d)d$p)),'BH');offset<-0
for(k in 1:4){n<-nrow(enrichment[[k]]);enrichment[[k]]$q<-qs[offset+seq_len(n)];offset<-offset+n}
pal<-colorRampPalette(c('#153a9b','#279ad8','#5dbaaa','#b8d85f','#ffe845','#ed8c28','#cc001a'))(256)
cluster_col<-c('#aa97ba','#ef8a88','#c883bb','#7abb28');bar_col<-c('#82c6cf','#c9ca3e','#87c485','#e7a12b')
trees<-lapply(1:4,function(k)hclust(dist(value[cluster==c(4,1,3,2)[k],]),method='average'))
ord<-unlist(lapply(1:4,function(k)which(cluster==c(4,1,3,2)[k])[trees[[k]]$order]));value<-value[ord,]
draw<-function(){par(mar=rep(0,4),family='sans',xaxs='i',yaxs='i');plot.new();plot.window(c(0,1),c(0,1))
 text(.095,.975,'h',cex=1.6)
 hx<-.19;hw<-.33;top<-.94;bot<-.07;bound<-top-c(0,cumsum(module_size))/sum(module_size)*(top-bot)
 idx<-1+round((value+3)/6*255);rasterImage(as.raster(matrix(pal[idx],nrow(value))),hx,bot,hx+hw,top,interpolate=FALSE)
 segments(hx+hw/2,bot,hx+hw/2,top,col='white',lwd=1)
 for(j in 1:4)rect(hx+(j-1)*hw/4,.947,hx+j*hw/4,.965,col=c('#152145','#999999','#999999','#e85c46')[j],border='white',lwd=.4)
 for(k in 1:4){rect(.181,bound[k+1],.188,bound[k],col=cluster_col[c(4,1,3,2)[k]],border=NA)
 if(k>1)segments(hx,bound[k],hx+hw,bound[k],col='white',lwd=2)
 ys<-seq(bound[k],bound[k+1],length.out=module_size[k]+1);den<-as.dendrogram(trees[[k]]);cursor<-0
 walk<-function(node){if(is.leaf(node)){cursor<<-cursor+1;return(c(.179,mean(ys[c(cursor,cursor+1)])))};a<-walk(node[[1]]);b<-walk(node[[2]]);x<-.179-.022*attr(node,'height')/attr(den,'height');segments(x,a[2],x,b[2],lwd=.3);segments(x,a[2],a[1],a[2],lwd=.3);segments(x,b[2],b[1],b[2],lwd=.3);c(x,mean(c(a[2],b[2])))};walk(den)
 d<-enrichment[[k]];ysbar<-seq(bound[k]-.014,bound[k+1]+.023,length.out=nrow(d));if(k==1)ysbar<-c(.925,.89,.866,.842);dy<-min(.030,(bound[k]-bound[k+1])/(nrow(d)+.5))
 polygon(c(.522,.565,.565,.522),c(bound[k],ysbar[1]+dy/2,tail(ysbar,1)-dy/2,bound[k+1]),col=adjustcolor(bar_col[k],.11),border=NA)
 for(j in seq_len(nrow(d))){w<-min(11,-log10(d$q[j]))/11*.423;rect(.565,ysbar[j]-dy/2,.565+w,ysbar[j]+dy/2,col=bar_col[k],border=NA);if(k==1 && j==1){label<-strsplit(d$term[j],'\n')[[1]];text(.569,ysbar[j]+c(.010,-.010),label,adj=0,cex=.64)} else text(.569,ysbar[j],d$term[j],adj=0,cex=.68)}
 }
 # Explicit legends at left reproduce cell type, cluster and expression encodings.
 text(.015,.875,'Cell Type',adj=0,font=2,cex=.72)
 for(i in 1:3){y<-.845-(i-1)*.026;rect(.015,y-.008,.03,y+.008,col=c('#999999','#e85c46','#152145')[i],border=NA);text(.034,y,c('Pre-branch','SPT_1','SPT_2')[i],adj=0,cex=.7)}
 text(.015,.745,'Cluster',adj=0,font=2,cex=.72)
 for(i in 1:4){y<-.715-(i-1)*.023;rect(.015,y-.008,.03,y+.008,col=cluster_col[i],border=NA);text(.04,y,i,cex=.7)}
 rasterImage(as.raster(matrix(rev(pal),ncol=1)),.045,.235,.065,.59,interpolate=FALSE);text(.077,seq(.235,.59,length.out=7),-3:3,adj=0,cex=.7);text(.025,.414,'Relative Expression Level',srt=90,font=2,cex=.75)
 segments(.565,.045,.995,.045,lwd=1.2);for(v in seq(0,10,2.5)){x<-.565+v/11*.423;segments(x,.045,x,.055,lwd=1.2);text(x,.03,format(v,nsmall=1),cex=.67)};text(.78,.009,'-log10(p-adjust)',font=2,cex=.75)
}
saveRDS(list(expression=value,cluster=cluster,pseudotime=t,enrichment=enrichment),file.path(out,'spermatogenic_branch_gene_modules_simulated.rds'))
png(file.path(out,'spermatogenic_branch_gene_modules.png'),width=1120,height=980,res=160,type='cairo');draw();dev.off()
cairo_pdf(file.path(out,'spermatogenic_branch_gene_modules.pdf'),width=7,height=6.125);draw();dev.off()
