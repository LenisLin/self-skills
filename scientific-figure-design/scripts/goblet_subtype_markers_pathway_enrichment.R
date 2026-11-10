# CattleCA main Figure 4f: subtype marker heatmap and aligned pathway NES bars.
# Input: optional output directory. Output: PNG, vector PDF and simulated RDS.
# Run: Rscript goblet_subtype_markers_pathway_enrichment.R OUTPUT_DIR
args <- commandArgs(trailingOnly=TRUE)
out <- if(length(args)) args[1] else 'figures'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
set.seed(4329)
subtypes <- paste0('GC',0:6)
subtype_colors <- c('#50AC69','#2897B8','#DBCA48','#E73865','#5144B4','#E39A34','#9C5B4A')
block_colors <- c('#A2CEAC','#8BC5D5','#D9C67D','#A79AC8','#EFCA96','#D5A196')
# Twenty conditionally upregulated genes per subtype, sharing realistic background.
expression <- matrix(rnorm(140*7,-.28,.28),140,7,dimnames=list(paste0('Gene',1:140),subtypes))
for(i in 1:7) expression[((i-1)*20+1):(i*20),i] <- rnorm(20,1.05,.23)
expression[41:80,2] <- expression[41:80,2] + .35
expression[70:90,3] <- expression[70:90,3] + .30
expression[70:105,4] <- expression[70:105,4] - .8
expression[,7] <- expression[,7]+rnorm(140,0,.18)
expression <- pmax(pmin(expression,1.7),-1.7)
marker_rows <- c(3,7,11,20,24,27,31,45,48,52,57,61,65,69,74,78,82,86,90,94,98,102,106,110,114,118,123,127,131,135,139)
markers <- c('WFDC2','DEFB7','DEFB13','OXR1','LAMC2','STXBP6','ITGA2','AHNAK','HSPA6','KLF4','TRPM4','MPTX1','PLA2G2A','PLA2G2A.1','ENSBTAG00000013039','REG3G','CD74','BOLA-DRA','BLA-DQB','C1QA','SLC8A1','C1QC','CD83','RGS1','APOE','CST3','SDF2L1','GADD45G','RARRES2','TFF3','AGR2')
rownames(expression)[marker_rows] <- markers
terms <- c('KEGG:ribosome','GO:cytoplasmic translation','GO:peptide biosynthetic process',
'GO:cellular macromolecule biosynthetic process','KEGG:oxidative phosphorylation',
'KEGG:tight junction','GO:lymphocyte migration','GO:response to osmotic stress',
'GO:cell-cell junction organization','KEGG:endocytosis',
'GO:response to purine-containing compound','GO:response to mechanical stimulus',
'GO:response to abiotic stimulus','GO:response to temperature stimulus',
'KEGG:B cell receptor signaling pathway','KEGG:complement and coagulation cascades',
'GO:innate immune response','GO:complement activation','GO:humoral immune response',
'GO:defense response to other organism','GO:cell activation','GO:immune response',
'GO:regulation of cell-cell adhesion','KEGG:antigen processing and presentation',
'KEGG:intestinal immune network for IgA production','GO:defense response to bacterium',
'GO:digestive system development')
# Six functional blocks correspond to the contiguous heatmap regions in reference.
NES <- c(3.35,3.15,2.55,2.75,2.28,2.17,2.15,2.08,2.02,1.86,2.05,1.91,1.88,1.76,1.65,1.83,1.62,1.71,1.69,1.55,2.15,1.96,1.84,1.77,1.82,1.62,1.47)+rnorm(27,0,.035)
pathways <- data.frame(term=terms,NES=NES,block=rep(1:6,c(5,5,5,5,5,2)))
saveRDS(list(expression=expression,marker_rows=marker_rows,pathways=pathways,seed=4329),file.path(out,'goblet_subtype_markers_pathway_enrichment_simulated.rds'))
library(grid)
# Coordinates in pixels make heatmap rows and enrichment bars align precisely.
for(fmt in c('png','pdf')) {
 file <- file.path(out,paste0('goblet_subtype_markers_pathway_enrichment.',fmt))
 if(fmt=='png') png(file,width=780,height=576,res=140,type='cairo') else cairo_pdf(file,width=780/140,height=576/140)
 grid.newpage(); pushViewport(viewport(xscale=c(0,780),yscale=c(576,0)))
 txt <- function(label,x,y,size=8,...) grid.text(label,x=unit(x,'native'),y=unit(y,'native'),gp=gpar(fontsize=size,fontfamily='sans'),...)
 line <- function(x,y) grid.lines(unit(x,'native'),unit(y,'native'),gp=gpar(lwd=.5))
 txt('f',18,25,19)
 hm <- colorRampPalette(c('#A9C5D1','#F5F6F3','#F09682'))(101)
 for(j in 1:7) {
  x<-176+(j-1)*31.7
  grid.rect(unit(x,'native'),unit(69,'native'),unit(30,'native'),unit(10/576,'npc'),just='left',gp=gpar(fill=subtype_colors[j],col=NA))
  txt(subtypes[j],x+15,38,9,rot=90)
  for(i in 1:140) grid.rect(unit(x,'native'),unit(77+(i-1)*3.11,'native'),unit(31.7,'native'),unit(3.2,'native'),just=c('left','top'),gp=gpar(fill=hm[1+round((expression[i,j]+1.7)/3.4*100)],col=NA))
 }
 # Distribute marker labels with leader lines where adjacent marker rows are dense.
 ly <- c(84,96,108,138,150,162,174,218,230,244,257,270,283,296,307,321,335,348,360,373,386,399,412,424,437,450,463,476,489,501,514)
 for(k in seq_along(markers)) {
  yy <-77+(marker_rows[k]-.5)*3.11
  txt(markers[k],156,ly[k],6.5,just='right');line(c(162,168,172),c(ly[k],ly[k],yy))
 }
 line(c(408,408),c(73,513))
 for(i in 1:27) {
  yy<-81+(i-1)*16.15
  grid.rect(unit(412,'native'),unit(yy,'native'),unit(NES[i]*82,'native'),unit(14.8,'native'),just='left',gp=gpar(fill=block_colors[pathways$block[i]],col=NA))
  txt(terms[i],413,yy,8.1,just='left')
 }
 line(c(412,708),c(513,513))
 for(t in 0:3) {line(c(412+82*t,412+82*t),c(513,520));txt(t,412+82*t,532,9)}
 txt('Normalized enrichment score',558,557,11)
 popViewport();dev.off()
}
