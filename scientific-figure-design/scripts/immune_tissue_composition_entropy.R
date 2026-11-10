#!/usr/bin/env Rscript
# Fig. 3a: immune lineage counts per tissue and Shannon effective diversity.
args<-commandArgs(TRUE);out<-if(length(args))args[1]else'.';dir.create(out,recursive=TRUE,showWarnings=FALSE);set.seed(3301)
tissues<-c('Mammary gland','Liver','PBMC','Cecum','Spleen','Jejunum','Duodenum','Colon','Lung','Ileum','Mammary cistern','Mammary duct','Mammary parenchyma','Pituitary gland','Rectum','Rumen','Blood','Thymus','Reticulum','Omasum','Intima of uterine horn','Rumen papilla','Heart','Cervical lymph node','Thyroid','Adrenal gland','Bone marrow','Medulla oblongata','Abomasum','Blood vessel','Ovary','Epididymis','Cerebral cortex','Salivary gland','Hypothalamus','Intima of corpus uteri','Testis','Pancreas','Rumen muscle','Oviduct','Skin','Kidney','Sublingual gland','Bulbar conjunctiva','Frontal lobe','Tongue','Esophagus','Palpebral conjunctiva','Fungal papilla','Parietal lobe','Bile duct','Occipital lobe','Circumvallate papilla','Cerebellum','Vagina','Trachea','Placenta','Intervertebral disc')
totals<-c(96865,55369,46078,45137,42102,37709,35693,34240,30478,29533,27689,26258,25937,22624,17178,17105,15660,14249,10757,10728,10248,9866,8410,8158,8045,7626,7427,6295,5872,5183,4779,4424,4004,3972,3834,3700,3288,3111,2693,2578,2489,2479,2397,2308,1594,1514,1461,965,930,894,797,687,608,489,431,383,277,264)
celltypes<-c('Double-negative T cells','T cells','CD4+ T cells','CD8+ T cells','Cytotoxic CD8+ T cells','WC1- gamma-delta T cells','WC1+ gamma-delta T cells','Proliferative CD4+ T cells','Proliferative T cells','NK T cells','NK cells','Classical monocytes','Intermediate monocytes','Nonclassical monocytes','Macrophages','Microglia','Kupffer cells','DCs','Conventional DCs type 1','Conventional DCs type 2','Migratory DCs','Plasmacytoid DCs','Proliferative DCs','B cells','Plasma cells','Neutrophils','Mast cells','Erythroid cells','Other immune cells')
colors<-c('#d5c9ca','#e9c7d0','#efb7c9','#cc79a5','#b74e89','#aa4d62','#8f4566','#685194','#7088bb','#88d0dd','#75c6c1','#62b5a8','#439fae','#3e91aa','#7ab8a2','#83c58d','#66b67b','#609744','#68630b','#a6a959','#ffffad','#eff5a5','#e5ec92','#f3e28b','#f5d179','#d7ad56','#e5a12e','#f5b300','#ffcc00')
# Dirichlet-multinomial tissue profiles, with lymphoid, neural, hepatic and blood enrichment.
counts<-matrix(0,58,29,dimnames=list(tissues,celltypes))
for(i in 1:58){alpha<-c(rep(.9,7),.16,.12,.8,.4,.7,.15,.18,.5,.05,.05,.14,.14,.12,.08,.08,.08,.7,.3,.4,.2,.2,.2)
 if(i%in%c(2,33,35,45,50,52,54))alpha[if(i==2)17 else 16]<-12
 if(i%in%c(3,17,27))alpha[c(12:14,26)]<-c(4,2,2,6)
 if(i==18)alpha[1:4]<-c(3,4,7,8)
 if(i%in%c(1,11:13))alpha[c(3,5,10)]<-c(12,4,3)
 p<-rgamma(29,alpha);p<-p/sum(p)
 target<-c(9.8,5.0,8.2,7.5,8.1,7.9,6.2,6.0,5.7,7.9,4.2,3.5,4.7,3.4,4.8,3.0,5.5,3.9,3.3,3.5,5.4,2.5,4.1,2.8,2.5,2.6,3.2,1.3,1.7,1.4,1.1,1.3,1.1,1.0,1.1,1.2,1.0,1.1,1.0,1.0,1.1,1.0,1.0,1.0,1.0,1.2,1.1,1.0,1.0,1.0,1.1,1.1,1.0,1.0,1.0,1.0,1.0,1.0)[i]
 # Tune concentration to match tissue-specific effective diversity while preserving lineages.
 p<-.7*p+.3/29;dominant<-which.max(p);lo<-0;hi<-1
 for(iter in 1:50){w<-(lo+hi)/2;q<-(1-w)*p;q[dominant]<-q[dominant]+w;ed<-exp(-sum(q[q>0]*log(q[q>0])));if(ed>target)lo<-w else hi<-w}
 q<-(1-hi)*p;q[dominant]<-q[dominant]+hi;counts[i,]<-as.vector(rmultinom(1,totals[i],q))}
p<-counts/rowSums(counts);entropy<- -rowSums(ifelse(p>0,p*log(p),0));effective_diversity<-exp(entropy)
saveRDS(list(counts=counts,proportions=p,shannon_nats=entropy,display_diversity=effective_diversity),file.path(out,'immune_tissue_composition_entropy_simulated.rds'))
draw<-function(){par(mar=rep(0,4),family='sans');plot.new();plot.window(c(0,1),c(0,1),xaxs='i',yaxs='i');text(.015,.995,'a',font=2,cex=1.8,adj=c(0,1));left<-.10;right<-.66;top<-.93;bottom<-.055;hh<-(top-bottom)/58
 for(i in 1:58){xx<-right-totals[i]/100000*(right-left);for(j in 1:29){nx<-xx+counts[i,j]/100000*(right-left);rect(xx,top-i*hh+.001,nx,top-(i-1)*hh-.001,col=colors[j],border=NA);xx<-nx};text(right+.018,top-(i-.5)*hh,tissues[i],adj=0,cex=.59);text(right-totals[i]/100000*(right-left)-.006,top-(i-.5)*hh,format(totals[i],big.mark=','),adj=1,cex=.59)}
 # Reference labels span 0-10, which exceeds log(29); effective number retains that display range.
 ex<-right-pmin(effective_diversity,10)/10*(right-left);ey<-top-((1:58)-.5)*hh;lines(ex,ey,col='#c6c8cb',lwd=1.5);points(ex,ey,pch=16,cex=.3)
 segments(left,bottom-.002,right,bottom-.002);segments(right,bottom,right,top)
 for(v in c(0,25000,50000,75000,100000)){x<-right-v/100000*(right-left);segments(x,bottom-.002,x,bottom-.008);text(x,bottom-.025,format(v,big.mark=',',scientific=FALSE),cex=.6)}
 text((left+right)/2,.008,'Cell number',cex=.78);text(right+.03,.958,'Tissues',adj=0,cex=.7)
 segments(left,top+.005,right,top+.005);for(v in seq(0,10,2.5)){x<-right-v/10*(right-left);segments(x,top+.005,x,top+.011);text(x,top+.024,v,cex=.61)};text((left+right)/2,.983,'Effective diversity, exp(Shannon)',cex=.65)
 text(.047,.695,'Cell types',adj=0,cex=.78)
 for(j in 1:29){y<-.674-(j-1)*.0204;rect(.045,y-.007,.077,y+.007,col=colors[j],border=NA);text(.084,y,celltypes[j],adj=0,cex=.64)}
}
png(file.path(out,'immune_tissue_composition_entropy.png'),width=1250,height=2050,res=220,type='cairo');draw();dev.off()
cairo_pdf(file.path(out,'immune_tissue_composition_entropy.pdf'),width=5.68,height=9.32);draw();dev.off()
