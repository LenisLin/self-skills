#!/usr/bin/env Rscript
# Fig. 3b: coherent pseudobulk-expression correlations across immune populations.
args<-commandArgs(TRUE);out<-if(length(args))args[1]else'.';dir.create(out,recursive=TRUE,showWarnings=FALSE);set.seed(3302)
# Samples share pan-immune, lineage and subtype transcription programs.
lineages<-c('T cells','B cells','T cells','B cells','T cells','Myeloid cells','Mast cells','Erythroid cells','Plasma cells','Immune cells','Neutrophils','Immune cells')
sizes<-c(40,8,48,9,20,65,4,24,21,16,20,5);group<-rep(seq_along(sizes),sizes);n<-length(group);ngenes<-1000
programs<-matrix(rnorm(ngenes*8),ngenes,8);pan<-rnorm(ngenes)
lineage_levels<-c('B cells','T cells','Myeloid cells','Erythroid cells','Immune cells','Mast cells','Neutrophils','Plasma cells')
li<-match(lineages[group],lineage_levels)
expression<-sapply(seq_len(n),function(i){j<-li[i]; common<-if(j%in%c(1,2)) .95 else if(j==3).65 else .05;pan*common+programs[,j]*runif(1,.4,1.0)+rnorm(ngenes,sd=runif(1,.22,1.0))})
correlation<-cor(expression);hc<-hclust(as.dist(1-correlation),method='average')
# Apply the actual hierarchical leaf order to the matrix and both metadata strips.
hc<-as.hclust(reorder(as.dendrogram(hc),wts=c(1.2,1,2,4,6,3,7,5)[li],agglo.FUN=min))
ord<-hc$order
correlation<-correlation[ord,ord];li<-li[ord];system<-sample(1:11,n,replace=TRUE,prob=c(.3,.12,.1,.12,.08,.08,.04,.06,.04,.03,.03));system[li==5]<-8
system_names<-c('Digestive system','Endocrine system','Cardiovascular system','Lymphatic system','Female reproductive system','Respiratory system','Male reproductive system','Nervous system','Urinary system','Skeletal system','Integumentary system')
sc<-c('#f36067','#f3a058','#b6b471','#7ac5a7','#aabbd3','#a8bc8c','#89d56d','#64d7df','#5082ba','#574584','#9c6260');lc<-c('#f95a60','#75cbd7','#c7cf64','#bccb51','#a7d392','#e7d9a7','#e59a29','#7a92b0');pal<-colorRampPalette(c('#ffffef','#ffffc2','#fee18a','#f9b475','#ec7048','#d62a20'))(256)
saveRDS(list(expression=expression[,ord],correlation=correlation,cell_lineage=lineage_levels[li],tissue_system=system_names[system],order=ord,dendrogram=hc),file.path(out,'immune_expression_correlation_triangle_simulated.rds'))
draw<-function(){par(mar=rep(0,4),family='sans');plot.new();plot.window(c(0,1),c(0,1),xaxs='i',yaxs='i');text(.012,.99,'b',cex=1.8,font=2,adj=c(0,1));x0<-.16;x1<-.97;y0<-.035;yt<-.865;dx<-(x1-x0)/n;dy<-(yt-y0)/n
 for(i in seq_len(n))for(j in i:n){v<-max(0,min(1,correlation[i,j]));rect(x0+(j-1)*dx,yt-i*dy,x0+j*dx,yt-(i-1)*dy,col=pal[1+round(v*255)],border=NA)}
 segments(x0,yt,x1,y0,lwd=.75)
 for(j in seq_len(n)){rect(x0+(j-1)*dx,.87,x0+j*dx,.884,col=lc[li[j]],border=NA);rect(x0+(j-1)*dx,.887,x0+j*dx,.9,col=sc[system[j]],border=NA)}
 text(x0-.006,.894,'Tissue_systems',adj=1,cex=.47);text(x0-.006,.877,'Cell_types',adj=1,cex=.47)
 # Draw the actual hierarchical tree using leaf positions fixed to the displayed order.
 leafx<-numeric(n);leafx[ord]<-x0+(seq_len(n)-.5)*dx;node_x<-node_y<-numeric(n-1)
 for(k in 1:(n-1)){a<-hc$merge[k,1];b<-hc$merge[k,2];xa<-if(a<0)leafx[-a]else node_x[a];xb<-if(b<0)leafx[-b]else node_x[b];ya<-if(a<0).905 else node_y[a];yb<-if(b<0).905 else node_y[b];y<-.905+hc$height[k]/max(hc$height)*.065;segments(c(xa,xb),c(ya,yb),c(xa,xb),y,lwd=.35);segments(xa,y,xb,y,lwd=.35);node_x[k]<-mean(c(xa,xb));node_y[k]<-y}
 text(.018,.846,'Tissue_systems',adj=0,cex=.62);for(k in 1:11){y<-.824-(k-1)*.022;rect(.018,y-.009,.038,y+.009,col=sc[k],border=NA);text(.043,y,system_names[k],adj=0,cex=.58)}
 text(.018,.555,'Cell_types',adj=0,cex=.62);for(k in 1:8){y<-.533-(k-1)*.022;rect(.018,y-.009,.038,y+.009,col=lc[k],border=NA);text(.043,y,lineage_levels[k],adj=0,cex=.58)}
 for(k in 1:100)rect(.26,.41+(k-1)*.15/100,.275,.41+k*.15/100,col=pal[round(1+(k-1)*255/99)],border=NA)
 for(v in seq(0,1,.2))text(.28,.41+v*.15,format(v,nsmall=1),adj=0,cex=.6);text(.245,.485,'Pearson correlation',srt=90,cex=.6)
 # Diagonal block boundaries and arrows derive from the reordered class runs.
 runs<-rle(li);ends<-cumsum(runs$lengths);starts<-c(0,head(ends,-1))
 for(k in seq_along(ends)){ss<-starts[k];ee<-ends[k];segments(x0+ss*dx,yt-ss*dy,x0+ee*dx,yt-ss*dy,lwd=.65);segments(x0+ee*dx,yt-ss*dy,x0+ee*dx,yt-ee*dy,lwd=.65)}
 # Label the longest contiguous run of each lineage so arrows match the displayed matrix.
 for(cls in unique(li)){
  candidates<-which(runs$values==cls);k<-candidates[which.max(runs$lengths[candidates])]
  mid<-(starts[k]+ends[k])/2;tx<-x0+mid*dx;ty<-yt-mid*dy
  label<-lineage_levels[cls];if(label=='T cells')label<-'T cells/NK cells';if(label=='Immune cells')label<-'Microglia_brain'
  if(cls%in%c(2,3)){
   text(min(.91,tx+.045),ty+.04,label,cex=.65)
  }else{
   lx<-max(.23,min(.88,tx+.06));ly<-max(.08,min(.82,ty+.05))
   if(cls==1){lx<-tx+.10;ly<-ty+.06}
   text(lx,ly,label,cex=.62,col=if(cls%in%c(1,5))'#393390'else'black')
   arrows(lx,ly+.012,tx,ty,length=.07,col='#4c5b6b',lwd=1.2)
  }
 }

}
png(file.path(out,'immune_expression_correlation_triangle.png'),width=1900,height=1850,res=220,type='cairo');draw();dev.off()
cairo_pdf(file.path(out,'immune_expression_correlation_triangle.pdf'),width=8.64,height=8.41);draw();dev.off()
