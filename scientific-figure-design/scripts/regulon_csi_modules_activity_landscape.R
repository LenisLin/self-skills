# Extended Data Figure 1a: simulated 156-regulon CSI and six-module landscape.
# Input: optional output directory. Outputs: PNG, vector PDF and complete simulated RDS.
# Run: Rscript regulon_csi_modules_activity_landscape.R OUTPUT_DIR
# All cell simulation, CSI calculation, embedding, word clouds and motif logic is inline.
args <- commandArgs(trailingOnly=TRUE)
out <- if(length(args)) args[1] else 'figures'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
set.seed(112329)
library(grid)
module_sizes <- c(18,21,26,48,23,20)
module <- rep(1:6,module_sizes)
module_colors <- c('#42A554','#EE8978','#D9AB77','#91A75F','#75A8C5','#9273BB')
lineages <- c('Endothelial cells','Epithelial cells','Germline cells','Immune cells',
              'Muscle cells','Nerve cells','Others','Stromal cells')
lineage_colors <- c('#7BAE37','#28AA91','#90CB50','#258D9B','#3385A0','#D8C823','#34568A','#433175')
# Source tissue sets define mild simulated tissue effects; clouds rank all tissues.
reference_tissue_names <- list(
 c('Esophage','Trachea','Abomasum','Bulbar conjunctiva','Palpebral conjunctiva','Omasum','Vagina','Skin','Rumen','Blood'),
 c('Reticulum','Circumvallate papilla','Skin','Thyroid','Palpebral conjunctiva','Bone Marrow','Cervical lymph node','Esophage','Oviduct','Intima of corpus uteri'),
 c('Intima of corpus uteri','Bone Marrow','Bile duct','Thyroid','Fungal papilla','Tongue','Cervical lymph node','Circumvallate papilla','Oviduct','Rumen muscle'),
 c('Retina','Occipital lobe','Frontal lobe','Hypothalamus','Parietal lobe','Kidney','Bile duct','Medulla oblongata','Cerebral cortex','Cerebellum'),
 c('Lung','Mammary gland','Colon','Mammary cistern','Mammary parenchyma','Spleen','Thymus','Cecum','PBMC','Blood'),
 c('Circumvallate papilla','Mammary cistern','Adrenal gland','Bile duct','Heart','Thyroid','Thymus','Mammary duct','Mammary parenchyma','Mammary gland'))
tf_lists <- list(c('POU2F3','E2F8','ARID3A','MYBL2'),c('JUN','JUNB','JUND','FOS','FOSB'),
 c('GATA4','TEAD4','SMAD1','CREB3L2'),c('MYRF','SOX10','HESX1','DLX1','POU3F2'),
 c('SPI1','EOMES','IRF4','XBP1','CEBPE','TBX21'),c('RELB','ETS1','SPIB','CEBPB'))
representative <- vapply(tf_lists,`[`,character(1),1)
# Cell-level lineages and tissue programs jointly determine module activity.
# Six preference vectors retain the main regulatory themes visible in the source clouds.
preference <- rbind(c(.55,1,.30,.45,.35,.23,.63,.68),c(.9,.78,.2,.68,.75,.18,.67,.84),
 c(.94,.46,.12,.20,.55,.3,.27,1),c(.26,.56,.37,.22,.47,1,.48,.35),
 c(.28,.35,.18,1,.33,.2,.72,.32),c(.83,.58,.2,.96,.52,.57,.76,.65))
all_tissues <- unique(unlist(reference_tissue_names))
# Correlated Gaussian islands and bridges form a common atlas-like display embedding.
centers <- rbind(c(-.7,2.4),c(-1.05,1.9),c(.1,2.2),c(.7,1.8),c(1.0,1.2),
 c(-.5,1.1),c(-1.2,.65),c(-1.5,.1),c(-.8,.05),c(0,.1),c(.7,.5),c(1.4,.6),
 c(1.55,-.15),c(.8,-.55),c(1.35,-.9),c(.4,-1.1),c(-.3,-1.1),c(.3,-1.6),
 c(.65,-2.0),c(1.0,-2.4),c(-.8,-1.8),c(-1.25,-1.5),c(-.3,1.8),c(.4,.95))
n_cells <- 4800
cluster <- sample(seq_len(nrow(centers)),n_cells,replace=TRUE)
cells <- data.frame(cell=paste0('Cell',seq_len(n_cells)),cluster=cluster,
 lineage=lineages[(cluster-1)%%8+1],tissue=sample(all_tissues,n_cells,TRUE))
angle <- runif(nrow(centers),0,pi)
u<-rnorm(n_cells,0,.19); v<-rnorm(n_cells,0,.095)
cells$x<-centers[cluster,1]+u*cos(angle[cluster])-v*sin(angle[cluster])
cells$y<-centers[cluster,2]+u*sin(angle[cluster])+v*cos(angle[cluster])
activity <- matrix(0,n_cells,6,dimnames=list(cells$cell,paste0('Module',1:6)))
for(m in 1:6) {
 tissue_bonus <- ifelse(cells$tissue%in%reference_tissue_names[[m]],.18,0)
 z <- preference[m,match(cells$lineage,lineages)]+tissue_bonus+rnorm(n_cells,0,.09)
 activity[,m]<-pmin(.55,pmax(.005,z*.33))
}
# Regulons inherit module programs, plus submodule loadings and independent noise.
regulon_names <- unlist(lapply(1:6,function(m) c(tf_lists[[m]],paste0('TF_M',m,'_',seq_len(module_sizes[m]-length(tf_lists[[m]]))))))
regulon_scores <- matrix(0,n_cells,156,dimnames=list(cells$cell,regulon_names))
# Shared lineage/cluster factors permit cross-module co-regulation and local blocks.
latent <- sapply(1:12,function(k) {
 centers_k <- sample(1:24,8)
 .12 + .20*(cluster%in%centers_k) + .13*(match(cells$lineage,lineages)==(k-1)%%8+1)
})
for(j in 1:156) {
 m<-module[j]
 # Three broad co-regulation programs cross the six labeled modules. A subset
 # of bridge regulons inherits another program, creating off-diagonal CSI blocks.
 group<-ceiling(m/2)
 if(runif(1)<.30) group<-sample(1:3,1)
 pair<-c(2*group-1,2*group)
 regulon_scores[,j]<-pmax(0,activity[,m]*runif(1,.12,.30)+
   rowMeans(activity[,pair])*runif(1,1.8,2.4)+
   latent[,sample(1:6,1)]*runif(1,.25,.55)+rnorm(n_cells,0,.018))
}
# Scale simulated regulon activity to [0,1], then average the same scores by module.
regulon_scores <- regulon_scores/1.7
activity <- sapply(1:6,function(m) rowMeans(regulon_scores[,module==m]))
colnames(activity)<-paste0('Module',1:6)
rownames(activity)<-cells$cell
correlation <- cor(regulon_scores)
# CSI(i,j) = fraction of other regulons less correlated to BOTH i and j than r(i,j).
# This rank-based calculation couples CSI to the simulated regulatory programs.
CSI <- matrix(0,156,156,dimnames=list(regulon_names,regulon_names))
for(i in 1:156) for(j in i:156) {
 others <- setdiff(1:156,c(i,j))
 CSI[i,j] <- mean(correlation[i,others]<correlation[i,j] & correlation[j,others]<correlation[i,j])
 CSI[j,i] <- CSI[i,j]
}
diag(CSI)<-1
# Cluster within the six defined modules; retain module order to match the source.
trees<-lapply(1:6,function(m) hclust(as.dist(1-correlation[module==m,module==m]),method='average'))
order <- unlist(lapply(1:6,function(m) which(module==m)[trees[[m]]$order]))
CSI <- CSI[order,order];regulon_scores<-regulon_scores[,order]
lineage_means <- sapply(1:6,function(m) tapply(activity[,m],factor(cells$lineage,levels=lineages),mean))
# Rank all 42 tissue averages, then display exactly the ten highest for each module.
all_tissue_means <- lapply(1:6,function(m) sort(tapply(activity[,m],cells$tissue,mean),decreasing=TRUE))
tissue_means <- lapply(all_tissue_means,head,10)
tissue_names <- lapply(tissue_means,names)
# Binding logos use synthetic PWMs based on the representative TF family consensus.
# They retain nucleotide sequence, position variation and information-content encoding.
consensus <- c('NNATGCAAATNNN','NATGACGTCATNN','NNCTTATCTNN','TCAGCACATGGACAGACCC','NAAAGAGGAAGTGNN','NAT TCCCCN')
consensus[6] <- 'NATTCCCCN'
base_colors <- c(A='#159646',C='#24669F',G='#F2A717',T='#CF2334')
PWM <- lapply(seq_along(consensus),function(m) {
 bases<-strsplit(consensus[m],'')[[1]]
 p<-matrix(0,4,length(bases),dimnames=list(c('A','C','G','T'),NULL))
 for(k in seq_along(bases)) {
  if(bases[k]=='N') p[,k]<-c(.27,.25,.23,.25)+runif(4,-.025,.025) else {
   p[,k]<-(1-runif(1,.80,.98))/3;p[bases[k],k]<-1-sum(p[-match(bases[k],rownames(p)),k])
  }
  p[,k]<-p[,k]/sum(p[,k])
 }
 p
})
names(PWM)<-representative
saveRDS(list(cells=cells,module_activity=activity,regulon_scores=regulon_scores,CSI=CSI,
 module_sizes=module_sizes,module=module[order],within_module_trees=trees,regulon_order=order,lineage_means=lineage_means,
 tissue_means=tissue_means,tissue_names=tissue_names,all_tissue_means=all_tissue_means,
 reference_tissue_names=reference_tissue_names,TFs=tf_lists,PWM=PWM,seed=112329),
 file.path(out,'regulon_csi_modules_activity_landscape_simulated.rds'))
# Drawing is specified in output-pixel coordinates to keep the complex panel aligned.
W<-1959;H<-938
for(fmt in c('png','pdf')) {
 file<-file.path(out,paste0('regulon_csi_modules_activity_landscape.',fmt))
 if(fmt=='png') png(file,width=W,height=H,res=144,type='cairo') else cairo_pdf(file,width=W/144,height=H/144)
 grid.newpage();pushViewport(viewport(xscale=c(0,W),yscale=c(H,0)))
 txt<-function(label,x,y,size=16,col='black',bold=FALSE,...) grid.text(label,unit(x,'native'),unit(y,'native'),gp=gpar(fontfamily='sans',fontsize=size/2,col=col,fontface=if(bold) 2 else 1),...)
 lines<-function(x,y,col='black',lwd=.5,lty=1) grid.lines(unit(x,'native'),unit(y,'native'),gp=gpar(col=col,lwd=lwd,lty=lty))
 rect<-function(x,y,w,h,fill,col=NA,lwd=.4) grid.rect(unit(x,'native'),unit(y,'native'),unit(w/W,'npc'),unit(h/H,'npc'),just=c('left','top'),gp=gpar(fill=fill,col=col,lwd=lwd))
 txt('a',48,48,30)
 txt('Connection Specificity Index',424,20,23,bold=TRUE)
 pal<-colorRampPalette(c('#FFFFFF','#D2BDD9','#A677BD','#512884'))(101)
 for(k in 1:100) rect(300+(k-1)*2.72,36,2.8,18,pal[k])
 for(v in seq(.7,1,.05)) txt(format(v,trim=TRUE),300+(v-.7)/.3*272,66,18)
 headers<-c('Average regulatory activity','Rank of cell lineage','Rank of tissues','TFs','Binding motif')
 for(k in 1:5) txt(headers[k],c(898,1150,1420,1601,1813)[k],68,17,bold=TRUE)
 # Heatmap 156 by 156; column/row order and dendrogram follow the same clustering.
 x0<-28;y0<-106;mw<-756;mh<-817;cw<-mw/156;rh<-mh/156
 heat<-matrix(pal[pmax(1,pmin(101,1+round((CSI-.7)/.3*100)))],156,156)
 grid.raster(as.raster(heat),unit(x0+mw/2,'native'),unit(y0+mh/2,'native'),unit(mw/W,'npc'),unit(mh/H,'npc'),interpolate=FALSE)
 bounds<-c(0,cumsum(module_sizes))
 for(m in 1:6) {
  start<-bounds[m];n<-module_sizes[m]
  rect(x0+start*cw-3,y0+start*rh-3,n*cw+6,n*rh+6,NA,module_colors[m],.8)
  rect(x0+start*cw,87,n*cw,17,adjustcolor(module_colors[m],alpha.f=.32))
  rect(9,y0+start*rh,17,n*rh,adjustcolor(module_colors[m],alpha.f=.32))
  tr<-trees[[m]]; xpos<-numeric(n-1); hpos<-numeric(n-1)
  ordloc<-match(1:n,tr$order)
  maxh<-max(tr$height)
  for(k in 1:(n-1)) {
   branches<-tr$merge[k,];xx<-yy<-numeric(2)
   for(j in 1:2) if(branches[j]<0) {xx[j]<-ordloc[-branches[j]]-.5;yy[j]<-0} else {xx[j]<-xpos[branches[j]];yy[j]<-hpos[branches[j]]}
   ht<-tr$height[k]/maxh*18
   lines(x0+(start+c(xx[1],xx[1],xx[2],xx[2]))*cw,106-c(yy[1],ht,ht,yy[2]),lwd=.35)
   lines(28-c(yy[1],ht,ht,yy[2]),y0+(start+c(xx[1],xx[1],xx[2],xx[2]))*rh,lwd=.35)
   xpos[k]<-mean(xx);hpos[k]<-ht
  }
 }
 # Keep panel a's two red zoom connectors terminating at its lower boundary.
 lines(c(571,230),c(807,938),'#C82342',.8);lines(c(677,905),c(807,938),'#C82342',.8)
 for(x in c(1015,1291,1556)) lines(c(x,x),c(95,925),'#666666',.7,2)
 row_centers<-c(155,295,435,575,715,855)
 for(m in 1:6) {
  yc<-row_centers[m]
  # Common embedding, module-specific activity encoded white-to-module color.
  txt(paste0('Module',m),818,yc,18,col=module_colors[m],bold=TRUE,rot=90)
  xx<-860+(cells$x-min(cells$x))/diff(range(cells$x))*120
  yy<-yc+62-(cells$y-min(cells$y))/diff(range(cells$y))*124
  cp<-colorRampPalette(c('#FFFFFF',module_colors[m]))(101)
  scaled<-pmax(0,pmin(1,(activity[,m]-.08)/.38))
  grid.points(unit(xx,'native'),unit(yy,'native'),pch=16,size=unit(.48,'mm'),gp=gpar(col=adjustcolor(cp[1+round(scaled*100)],alpha.f=.60)))
  # Horizontal word clouds: sizes computed from mean cell-level module activity.
  weights<-lineage_means[,m];ranked<-order(weights,decreasing=TRUE)
  # Rows give clear non-overlapping terms, with small secondary words at edges.
  ypos<-c(0,-20,20,-39,40,-55,54,-53)
  xpos<-c(1153,1150,1155,1148,1158,1095,1158,1213)
  for(k in 1:8) {
   i<-ranked[k];s<-11+9*(weights[i]-min(weights))/diff(range(weights))
   shade<-colorRampPalette(c('#C7DDC7',lineage_colors[i]))(100)[25+round(75*(weights[i]-min(weights))/diff(range(weights)))]
   txt(lineages[i],xpos[k],yc+ypos[k],s,col=shade)
  }
  # Tissue words run from highest mean activity at the top to tenth at the bottom.
  ts<-tissue_means[[m]]; tscaled<-(ts-min(ts))/max(diff(range(ts)),.001)
  ty<-seq(-54,54,length.out=10)
  tx<-c(1425,1420,1425,1415,1420,1425,1420,1415,1425,1420)
  for(k in 1:10) txt(tissue_names[[m]][k],tx[k],yc+ty[k],11+4*tscaled[k],
    col=colorRampPalette(c('#AFCAB4',c('#349BA5','#443177','#56BC70','#A8C74A','#4C76A0','#27AA8B','#C5CC26')[1+(k-1)%%7]))(100)[25+round(75*tscaled[k])])
  # Complete source TF lists; representative family is bold and heads its logo.
  for(k in seq_along(tf_lists[[m]])) txt(tf_lists[[m]][k],1580,yc-34+(k-1)*20,16,bold=k==1,just='left')
  txt(representative[m],1685,yc-49,16,bold=TRUE,just='left')
  # Vector nucleotide letters use geometric glyphs stretched to PWM information heights.
  glyph<-function(base,x,y,w,h) {
   poly<-function(px,py,fill=base_colors[base]) grid.polygon(unit(x+px*w,'native'),unit(y-py*h,'native'),gp=gpar(fill=fill,col=NA))
   if(base=='A') {
    poly(c(0,.4,.6,1,.75,.62,.38,.25),c(0,1,1,0,0,.35,.35,0))
    poly(c(.43,.5,.57),c(.48,.76,.48),'white')
   }
   if(base=='T') poly(c(0,1,1,.61,.61,.39,.39,0),c(1,1,.82,.82,0,0,.82,.82))
   if(base%in%c('C','G')) {
    theta<-seq(pi*.22,pi*1.78,length.out=50)
    px<-c(.5+.5*cos(theta),rev(.5+.27*cos(theta)))
    py<-c(.5+.5*sin(theta),rev(.5+.34*sin(theta)))
    poly(px,py)
    if(base=='G') poly(c(.5,1,1,.8,.8,.5),c(.52,.52,.18,.18,.34,.34))
   }
  }
  pwm<-PWM[[m]]; nc<-ncol(pwm);logo_x<-1690;logo_w<-240
  for(k in 1:nc) {
   p<-pwm[,k];bits<-2+sum(p*log2(p)); heights<-p*bits/2*103
   ybase<-yc+54
   for(i in order(heights)) {
    glyph(names(base_colors)[i],logo_x+(k-1)*logo_w/nc,ybase,logo_w/nc*.90,heights[i])
    ybase<-ybase-heights[i]
   }
  }
  lines(c(1687,1938),c(yc+56,yc+56),'#BBBBBB',.4)
 }
 popViewport();dev.off()
}
