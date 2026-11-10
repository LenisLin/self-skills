#!/usr/bin/env Rscript
# Fig. 2b: subtype-average z-scores, module counts, markers and GO annotations.
# Usage: Rscript mammary_subtype_marker_heatmap.R OUTPUT_DIR
args <- commandArgs(TRUE); out <- if(length(args)) args[1] else '.'
dir.create(out,recursive=TRUE,showWarnings=FALSE); set.seed(2329)
subtypes <- paste0('ME',0:7)
module_sizes <- c(20,11,6,15,18,13,17,20)
module_colors <- c('#8793b2','#eea083','#d5121c','#91c8bc','#344d7f','#e84f36','#49acc2','#109a85')
markers <- list(c('ELF5','LTF','CXCL3','HSPH1','HSPA1A','DNAJB1','JUN'),c('CSN1S1','AEP','CSN2','LALBA','FABP3'),c('CIDEA','ASB11'),c('PTGDS','SAA3'),c('EEF1A1','S100A2','FTH1','APOE','KRT15','LCN2','TMSB10'),c('AREG','ACTG1','ANXA1'),c('GHR','PGR','ESR1','PRLR','ERBB4','AFF3'),c('KRT5','ACTA2','MYH11','MYLK','KRT17'))
go <- list(c('Regulation of ATP-dependent activity','Response to heat','Regulation of DNA-templated transcription'),c('Response to progesterone','Response to estradiol','Response to corticosteroid'), 'Fatty acid biosynthetic process',c('Acute inflammatory response','Myeloid leukocyte-mediated immunity','Positive regulation of angiogenesis'),c('Cellular response to growth factor stimulus','Response to growth factor','Regulation of membrane depolarization'),c('Regulation of supramolecular fiber organization','Supramolecular fiber organization','Regulation of cellular component organization'),c('Hormone-mediated signaling pathway','Cellular response to hormone stimulus','Response to hormone'),c('Negative regulation of smooth muscle cell','Smooth muscle cell proliferation','Regulation of smooth muscle proliferation'))
# Every module has a dominant subtype; lactation modules also share ME1/ME3 activity.
profiles <- rbind(c(2,-.5,-.3,-.5,.3,.1,.1,-.4),c(.2,1.6,.3,1.9,-.6,-.5,-.5,-.6),c(.3,.7,-.5,2,-.6,-.5,-.5,-.6),c(.5,-.5,2,-.5,.5,-.5,-.5,-.5),c(-.5,-.5,-.3,-.5,2,.7,-.4,-.5),c(-.6,-.5,-.4,-.3,.5,2,.5,-.5),c(-.5,-.5,-.5,-.5,-.4,.2,2,-.5),c(-.5,-.5,-.5,-.5,-.5,-.5,-.4,2))
expr <- do.call(rbind,lapply(1:8,function(i){ z<-matrix(rnorm(module_sizes[i]*8,0,.37),ncol=8); z<-sweep(z,2,profiles[i,],'+'); if(i==1){z[1:3,5]<-1.8;z[10:14,7]<-2;z[15:17,8]<-2;z[18:20,7]<-3};t(scale(t(z))) }))
expr[] <- pmax(-2,pmin(2,expr)); colnames(expr)<-subtypes; rownames(expr)<-paste0('gene_',1:120)
counts <- c(650,580,400,210,200,155,110,140)
# GO term scores are simulated annotation inputs, shared identically by both devices.
go_logp <- lapply(1:8,function(i) if(i==2)c(18,17,15.5) else if(i==1)c(4.5,2.8,3.5) else if(i==5)c(3,2.5,2.5) else runif(length(go[[i]]),3,8))
saveRDS(list(go_log10_adjusted_p=go_logp,expression_z=expr,module=rep(1:8,module_sizes),cell_counts=setNames(counts,subtypes),markers=markers,go=go),file.path(out,'mammary_subtype_marker_heatmap_simulated.rds'))
pal <- colorRampPalette(c('#0864a6','#9daaca','#f5f4f4','#da8074','#9d171b'))(256)
draw <- function(){
 par(mar=rep(0,4),family='sans');plot.new();plot.window(c(0,1),c(0,1),xaxs='i',yaxs='i')
 text(.012,.98,'b',font=2,cex=1.8,adj=c(0,1));text(.05,.975,'Cell counts',adj=c(0,1),cex=.9)
 x0<-.17; x1<-.56; top<-.86; bot<-.065; dx<-(x1-x0)/8;dh<-(top-bot)/120
 rect(x0+(0:7)*dx+.012,.89,x0+(1:8)*dx-.012,.89+counts/650*.054,col=module_colors[c(1,2,4,3,5,6,8,7)],border='black',lwd=.5)
 segments(x0-.012,.89,x0-.012,.945);for(v in c(250,500)){y<-.89+v/650*.054;segments(x0-.019,y,x0-.012,y);text(x0-.025,y,v,adj=1,cex=.65)}
 text(.765,.96,'Gene expression (z-score)',cex=.95)
 for(k in 1:100)rect(.7+(k-1)*.12/100,.915,.7+k*.12/100,.939,col=pal[round(1+(k-1)*255/99)],border=NA)
 text(c(.7,.76,.82),.906,c('-2','0','2'),cex=.65)
 for(r in 1:120)for(c in 1:8)rect(x0+(c-1)*dx,top-r*dh,x0+c*dx,top-(r-1)*dh,col=pal[1+round((expr[r,c]+2)/4*255)],border=NA)
 start<-0
 for(i in 1:8){yt<-top-start*dh;yb<-top-(start+module_sizes[i])*dh;rect(x0,yb,x1,yt,border='black',lwd=.65);rect(x1+.003,yb,x1+.026,yt,col=module_colors[i],border=NA);text(x1+.014,(yt+yb)/2,paste0('n:',module_sizes[i]),srt=90,col='white',cex=.72)
 # Leader lines place the selected markers at distinct rows of their own module.
 pos<-seq(yt-.012,yb+.012,length.out=length(markers[[i]]));text(x0-.02,pos,markers[[i]],adj=1,font=3,col=module_colors[i],cex=.64);segments(x0-.015,pos,x0,pos,lwd=.4)
 gy<-seq(yt-.025,yb+.022,length.out=length(go[[i]]));if(length(go[[i]])==1)gy<-(yt+yb)/2
 score<-go_logp[[i]]
 for(j in seq_along(gy)){rect(.59,gy[j]-.011,.59+score[j]*.016,gy[j]+.011,col=adjustcolor(module_colors[i],alpha.f=.5),border=NA);text(.59,gy[j],go[[i]][j],adj=0,cex=.68)}
 start<-start+module_sizes[i] }
 text(x0+(seq_len(8)-.5)*dx,.046,subtypes,cex=.75);text(x0-.006,.046,'Subtypes',adj=1,cex=.72)
 segments(.59,bot,.88,bot);for(v in c(0,5,10)){segments(.59+v*.016,bot,.59+v*.016,bot-.01);text(.59+v*.016,bot-.025,v,cex=.7)};text(.90,.025,expression(-log[10](P[adj])),cex=.8)
}
png(file.path(out,'mammary_subtype_marker_heatmap.png'),width=2000,height=1700,res=220,type='cairo');draw();dev.off()
cairo_pdf(file.path(out,'mammary_subtype_marker_heatmap.pdf'),width=9.1,height=7.73);draw();dev.off()
