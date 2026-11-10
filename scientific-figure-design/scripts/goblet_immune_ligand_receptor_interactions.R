# CattleCA main Figure 4d: paired expression dot matrices and interaction network.
# Simulates 48 tissue/cell-type combinations, 13 ligand genes and 19 receptor genes.
# Run: Rscript goblet_immune_ligand_receptor_interactions.R OUTPUT_DIR
# Outputs: PNG, PDF and simulated RDS containing every displayed measurement.
args <- commandArgs(trailingOnly=TRUE)
out <- if(length(args)) args[1] else 'figures'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
set.seed(4429)
library(grid)
ligands <- c('GZMA','CD6','C5','MIF','C3','ALCAM','SEMA4A','LGALS9','SEMA4D','GUCA2A','F11R','CDH1','APP')
receptors <- c('PARD3','F2R','ALCAM','C5AR1','C3AR1','HAVCR2','CXCR4(CD74_)','CR2',
 'ITGB7','ITGAE','ITGB2','ITGAL','CD6','CD44','PLXNB2','GUCY2C','F11R','CDH1','CD74')
# The reference has 19 receptor rows; the two matrices retain their different heights.
cell_types <- c('B cells','CD4+ T cells','cDC1 cells','Cytotoxic CD8+ T cells','GCs','Macrophages','Mast cells','Plasma cells')
tissues <- c('Cecum','Colon','Duodenum','Ileum','Jejunum','Rectum')
cell_colors <- c('#8ED5DF','#F7CFD6','#D8D373','#E7A523','#99D498','#E7C580','#C94260','#8278BC')
tissue_colors <- cell_colors[c(1,2,3,4,5,6)]
columns <- expand.grid(tissue=tissues,cell_type=cell_types,stringsAsFactors=FALSE)
# Cell-type-restricted expression over six intestinal segments, with shared interactions.
make_expression <- function(genes) {
 z<-matrix(rnorm(length(genes)*48,-.82,.18),length(genes),48,dimnames=list(genes,NULL))
 pct<-matrix(runif(length(genes)*48,4,14),length(genes),48)
 list(z=z,pct=pct,ring=matrix(FALSE,length(genes),48))
}
a<-make_expression(ligands); b<-make_expression(receptors)
# Activate gene-by-lineage modules; rings denote plausible shared ligand/receptor use.
activate <- function(obj,gene,group,mean=1.55,ring=TRUE,pct=70) {
 r<-match(gene,rownames(obj$z)); c<-which(columns$cell_type%in%group)
 obj$z[r,c]<-rnorm(length(c),mean,.38)
 obj$pct[r,c]<-pmin(100,pmax(15,rnorm(length(c),pct,12)))
 obj$ring[r,c]<-ring
 obj
}
a<-activate(a,'GZMA',cell_types[4]);a<-activate(a,'CD6',cell_types[c(2,4)])
for(g in c('C5','C3','GUCA2A','F11R','CDH1','APP')) a<-activate(a,g,'GCs')
a<-activate(a,'MIF',cell_types[c(3,6)],1.2,FALSE,78)
a<-activate(a,'MIF','GCs',-.8,TRUE,83)
a<-activate(a,'ALCAM',cell_types[c(1,3,6)],.4,FALSE,45)
a<-activate(a,'ALCAM','GCs',-.5,TRUE,65)
a<-activate(a,'SEMA4A',cell_types[c(3,6,7)],.8,TRUE,56)
a<-activate(a,'LGALS9',cell_types[c(3,5,6)],.3,TRUE,65)
a<-activate(a,'SEMA4D',cell_types[c(2,4)],.8,TRUE,71)
for(g in c('PARD3','PLXNB2','GUCY2C','F11R','CDH1')) b<-activate(b,g,'GCs',1.2,TRUE,76)
b<-activate(b,'F2R','CD4+ T cells',.7,FALSE,40)
b<-activate(b,'ALCAM',cell_types[c(1,3,6)],.5,FALSE,55)
b<-activate(b,'ALCAM','GCs',-.8,TRUE,68)
for(g in c('C5AR1','C3AR1')) b<-activate(b,g,'Macrophages',1.8,TRUE,69)
b<-activate(b,'HAVCR2','cDC1 cells',.8,TRUE,65)
for(g in c('CXCR4(CD74_)','CR2')) b<-activate(b,g,'B cells',1.4,TRUE,80)
for(g in c('ITGB7','ITGAE','ITGB2','ITGAL','CD6','CD44')) b<-activate(b,g,cell_types[c(2,3,4)],.5,TRUE,64)
b<-activate(b,'CD74',cell_types[c(1,3,5,6,8)],-.4,TRUE,94)
b<-activate(b,'CD74','Macrophages',1.4,TRUE,94)
a$z<-pmin(pmax(a$z,-1.3),2.3); b$z<-pmin(pmax(b$z,-1.3),2.3)
# Distinct ligand-to-receptor relationships drive the curved network.
edges <- data.frame(ligand=c('GZMA','CD6','C5','MIF','MIF','C3','ALCAM','SEMA4A',
 'SEMA4D','LGALS9','LGALS9','LGALS9','GUCA2A','F11R','F11R','CDH1','CDH1','APP'),
 receptor=c('F2R','ALCAM','C5AR1','CXCR4(CD74_)','CD74','C3AR1','CD6','PLXNB2',
 'CD44','HAVCR2','CD44','CD74','GUCY2C','F11R','ITGAL','CDH1','ITGB7','CD74'))
saveRDS(list(ligand=a,receptor=b,columns=columns,edges=edges,seed=4429),file.path(out,'goblet_immune_ligand_receptor_interactions_simulated.rds'))
palette <- colorRampPalette(c('#A7BFE9','#FFFDFD','#B50025'))(201)
for(fmt in c('png','pdf')) {
 file<-file.path(out,paste0('goblet_immune_ligand_receptor_interactions.',fmt))
 if(fmt=='png') png(file,width=1378,height=1020,res=144,type='cairo') else cairo_pdf(file,width=1378/144,height=1020/144)
 grid.newpage();pushViewport(viewport(xscale=c(0,1378),yscale=c(1020,0)))
 text_at <- function(label,x,y,size=8,...) grid.text(label,unit(x,'native'),unit(y,'native'),gp=gpar(fontsize=size,fontfamily='sans'),...)
 line_at <- function(x,y,col='black',lwd=.5) grid.lines(unit(x,'native'),unit(y,'native'),gp=gpar(col=col,lwd=lwd))
 circle_at <- function(x,y,r,fill,col=NA,lwd=.5) grid.circle(unit(x,'native'),unit(y,'native'),r=unit(r,'native'),gp=gpar(fill=fill,col=col,lwd=lwd))
 rect_at <- function(x,y,w,h,fill,col=NA) grid.rect(unit(x,'native'),unit(y,'native'),unit(w,'native'),unit(h/1020,'npc'),just=c('left','top'),gp=gpar(fill=fill,col=col,lwd=.45))
 text_at('d',18,22,20)
 # Two independently scaled row grids, preserving the original common column spacing.
 draw_matrix <- function(obj,y0,height) {
  nr<-nrow(obj$z); row_h<-height/nr; x0<-50; cw<-18.4
  for(j in 0:48) line_at(rep(x0+j*cw,2),c(y0,y0+height),'#CBD1DB',.3)
  for(i in 0:nr) line_at(c(x0,x0+48*cw),rep(y0+i*row_h,2),'#CBD1DB',.3)
  for(i in 1:nr) for(j in 1:48) {
   co<-palette[1+round((obj$z[i,j]+1.3)/3.6*200)]
   circle_at(x0+(j-.5)*cw,y0+(i-.5)*row_h,1.6+sqrt(obj$pct[i,j]/100)*7.4,co,
             if(obj$ring[i,j]) 'black' else NA,if(obj$ring[i,j]) 1 else .5)
  }
  rect_at(x0,y0,48*cw,height,NA,'black')
  for(i in 1:nr) text_at(rownames(obj$z)[i],x0+48*cw+10,y0+(i-.5)*row_h,8.8,just='left')
  for(j in 1:48) rect_at(x0+(j-1)*cw,y0+height+8,cw,18,tissue_colors[(j-1)%%6+1],'black')
  for(k in 1:8) rect_at(x0+(k-1)*6*cw,y0+height+30,6*cw,18,cell_colors[k],'black')
  text_at('Tissues',944,y0+height+17,9,just='left')
  text_at('Cell_types',944,y0+height+39,9,just='left')
 }
 draw_matrix(a,20,328); draw_matrix(b,408,332)
 # Source and target nodes at the exact heights of their corresponding matrix rows.
 src_y<-20+(seq_along(ligands)-.5)*328/length(ligands)
 tgt_y<-408+(seq_along(receptors)-.5)*332/length(receptors)
 for(k in seq_len(nrow(edges))) {
  y1<-src_y[match(edges$ligand[k],ligands)]
  y2<-tgt_y[match(edges$receptor[k],receptors)]
  grid.bezier(unit(c(1095,1225,1225,1105),'native'),unit(c(y1,y1,y2,y2),'native'),
              gp=gpar(col='black',lwd=.85),arrow=arrow(length=unit(.045,'inches'),type='closed'))
 }
 for(y in src_y) circle_at(1093,y,7.7,'#F5CCD4','black',.5)
 for(y in tgt_y) circle_at(1093,y,7.7,'#8AD3DE','black',.5)
 text_at('Source',1216,104,10)
 grid.lines(unit(c(1216,1216),'native'),unit(c(133,646),'native'),gp=gpar(col='#F8998E',lwd=.7),arrow=arrow(length=unit(.08,'inches'),type='closed'))
 text_at('Target',1216,688,10)
 # Legends occupy the lower right region beneath the matrix and network.
 text_at('Tissues',666,815,10,just='left');text_at('Cell_types',797,815,10,just='left')
 for(i in seq_along(tissues)) {rect_at(667,832+(i-1)*22,18,18,tissue_colors[i],'black');text_at(tissues[i],691,841+(i-1)*22,9,just='left')}
 for(i in seq_along(cell_types)) {rect_at(800,832+(i-1)*22,35,18,cell_colors[i],'black');text_at(cell_types[i],846,841+(i-1)*22,8.5,just='left')}
 # Continuous expression legend, scaled -1 to 2 with signed ticks.
 for(i in 1:100) rect_at(1117,779+(100-i)*1.15,22,1.3,palette[round(1+(i-1)*200/99)])
 for(v in -1:2) text_at(v,1148,779+(2.3-v)/3.6*115,10,just='left')
 grid.text('Average\nexpression',unit(1088,'native'),unit(837,'native'),rot=90,gp=gpar(fontsize=9))
 text_at('Type',1215,810,10)
 circle_at(1203,833,4.5,'#999999');circle_at(1228,833,5,'#999999','black',1)
 grid.text('None',unit(1203,'native'),unit(865,'native'),rot=90,gp=gpar(fontsize=9))
 grid.text('ligand-receptor',unit(1228,'native'),unit(912,'native'),rot=90,gp=gpar(fontsize=9))
 for(i in 0:4) {y<-925+i*20;circle_at(1128,y,1.6+sqrt(i/4)*7.4,'white','black',.5);text_at(i*25,1146,y,9,just='left')}
 grid.text('Percentage\nexpression',unit(1086,'native'),unit(962,'native'),rot=90,gp=gpar(fontsize=9))
 popViewport();dev.off()
}
