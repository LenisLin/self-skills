#!/usr/bin/env Rscript
# Figure 4a: epithelial gene modules, pathways, TFs, tissues and cell composition.
# A self-contained simulation and base-R vector drawing; no downloaded data needed.
args<-commandArgs(trailingOnly=TRUE);out<-if(length(args))args[1] else '.'
dir.create(out,recursive=TRUE,showWarnings=FALSE);set.seed(3403)
# 24 cell classes sampled in 15 gastrointestinal tissue labels, arranged by module.
cell_types<-c('Basal cells','Epithelial stem cells','Keratinocytes','Proliferative basal cells','Spinous cells',
 'Enterocytes','GCs','Intestinal stem cells','Progenitor cells','Acinar cells','Duct cells','Basal duct cells',
 'Pit cells','Other epithelial cells','Isthmus cells','Mucous neck cells','Parietal cells','Chief cells',
 'alpha cells','beta cells','Hepatocytes','Cholangiocytes','Hepatoblasts','Luminal cells')
cell_colors<-c('#efbe8d','#8b8174','#bb4670','#dfa54d','#c77cae','#4c81b9','#75b32c','#f5c89a','#f39d9c',
 '#dce343','#9cc039','#a3c79b','#6fb69f','#4fb2c2','#315a9b','#4e9abf','#80c4d7','#d69ec4',
 '#4aab3a','#74c4bc','#e25c77','#cf79ba','#d26b38','#dd5963')
tissues<-c('Rumen','Reticulum','Omasum','Esophagus','Pancreas','Salivary gland','Duodenum','Ileum','Jejunum','Colon','Cecum','Rectum','Liver','Bile duct','Abomasum')
# 45 tissue-by-cell-class columns; shared programs produce off-diagonal structure.
module_width<-c(12,4,13,3,4,4,3,2);module_rows<-c(82,24,105,62,25,64,16,26)
column_module<-rep(1:8,module_width);gene_module<-rep(1:8,module_rows)
nr<-length(gene_module);nc<-length(column_module)
expression<-matrix(rnorm(nr*nc,-.45,.31),nr,nc)
for(i in seq_len(nr)){
 k<-gene_module[i];expression[i,column_module==k]<-rnorm(sum(column_module==k),1.0,.62) + .65*exp(-((seq_len(sum(column_module==k))-runif(1,1,sum(column_module==k)))/max(1,sum(column_module==k)/4))^2)
 # Related digestive programs share modest low-expression patterns.
 if(k%in%c(2,3,5,8)) expression[i,column_module%in%c(2,3,5,8)]<-expression[i,column_module%in%c(2,3,5,8)]+.15
}
# Forestomach subprograms distinguish the epithelial strata within module 1.
for(i in which(gene_module==1)){
 active<-if(i<=8)1 else if(i<=45)2:6 else 7:12
 expression[i,column_module==1]<-rnorm(sum(column_module==1),-.35,.25)
 expression[i,active]<-rnorm(length(active),1.35,.55)
}
expression[]<-pmax(-2,pmin(2,expression))
column_tissue<-c(c(rep(1,3),rep(2,3),rep(3,3),4,4,4),rep(6,4),rep(7:12,length.out=13),rep(13,3),rep(15,4),rep(14,4),rep(5,3),rep(15,2))
column_cell<-c(rep(1:5,length.out=12),c(10,11,12,14),rep(6:9,length.out=13),21:23,c(13,15,16,18),c(22,24,22,24),c(10,19,20),rep(17,2))
pathways<-list(c('Pyruvate metabolism','Fatty acid metabolism','Amino acid degradation','Fatty acid degradation'),
 c('Salivary secretion','Lysosome'),c('Intestinal immune network for IgA','Fructose and mannose metabolism','Mineral absorption','Fat digestion and absorption'),
 c('Bile secretion','PI3K/Akt signaling pathway'),c('Pyruvate metabolism','Glycolysis/gluconeogenesis','Cholesterol metabolism'),
 'Pancreatic secretion',c('Collecting duct acid secretion','Gastric acid secretion'))
pathway_modules<-c(1,2,3,4,6,7,8)
pathway_colors<-c('#c56d6f','#e7bd73','#98d697','#f4b432','#dbd86b','#fac4d3','#95d9e5')
# Simulated pathway overlap counts give the displayed hypergeometric P values.
enrichment<-lapply(seq_along(pathways),function(k){
 sz<-sample(600:1200,length(pathways[[k]]));n<-sum(gene_module==pathway_modules[k])
 ov<-pmin(n,round(n*runif(length(sz),.16,.28)))
 data.frame(term=pathways[[k]],module_id=pathway_modules[k],background=20000,
 set_size=sz,module_size=n,overlap=ov,p=phyper(ov-1,sz,20000-sz,n,lower.tail=FALSE))})
TFs<-c('CEBPD, NFIA, NOBOX,\nOVOL2, PITX1, TEAD1,\nYBX1, ZBTB7A','E2F3, EBF4, ESRRA,\nPBX4, SOX10',
'ARID5B, BACH1, CDX1,\nCDX2, CUX2, FOSL1,\nFOXA1, FOXD2, HNF4G,\nNFIA, NR1H4, NR1I2,\nNR1I3, ZBTB7A, ZNF248',
'ATF5, ELF2, HNF4A,\nHNF4G, NFIA, NR3C1,\nONECUT2, PPARA, TCF7L1',
'ELF1, ELF2, MEIS1,\nZNF704','EGR1, ELF2, ELF3,\nGRHL2, NFIA, NR1H4,\nNR3C1, ONECUT2, PPARA',
'FOSB, FOXO1, HNF1B,\nNEUROD1, NR3C1, RFX3','ESRRB, MEIS1')
all_q<-p.adjust(unlist(lapply(enrichment,function(d)d$p)),'BH');offset<-0
for(k in seq_along(enrichment)){n<-nrow(enrichment[[k]]);enrichment[[k]]$q<-all_q[offset+seq_len(n)];offset<-offset+n}
# Generate the irregular cell positions once; both graphics devices use this table.
schematic_cells<-list()
for(kind in c('acinar','hepatic')){
 n<-if(kind=='acinar')38 else 42
 cells<-data.frame(dx=numeric(n),dy=numeric(n),color=character(n))
 for(j in seq_len(n)){
  angle<-runif(1,0,2*pi);radius<-sqrt(runif(1))
  cells$dx[j]<-if(kind=='acinar').021*radius*cos(angle) else .022*radius*cos(angle)
  cells$dy[j]<-if(kind=='acinar').044*radius*sin(angle) else .048*radius*sin(angle)
  cells$color[j]<-if(kind=='acinar')sample(cell_colors[c(10,11,19,20)],1) else cell_colors[21]
 }
 schematic_cells[[kind]]<-cells
}
# Small vector anatomy illustrations use organ outlines plus epithelial cell units.
ellipse<-function(x,y,rx,ry,col,border='#777777',lwd=.65){a<-seq(0,2*pi,length.out=100);polygon(x+rx*cos(a),y+ry*sin(a),col=col,border=border,lwd=lwd)}
cell<-function(x,y,color,rx=.0036,ry=.007){ellipse(x,y,rx,ry,color,border=NA);ellipse(x+rx*.25,y,rx*.28,ry*.32,adjustcolor('#55405b',.7),border=NA)}
organ<-function(x,y,kind){
 if(kind=='stomach'){a<-seq(0,2*pi,length.out=100);polygon(x+.032*cos(a)*(1+.19*sin(2*a)),y+.054*sin(a),col='#7f644b',border='#6b5945');ellipse(x+.022,y-.026,.012,.022,'#e1e9e4');ellipse(x+.015,y-.018,.008,.018,'#bd9468')}
 if(kind=='intestine'){ellipse(x,y,.027,.048,'#dba56c');for(i in 1:7){a<-seq(0,2*pi,length.out=130);lines(x+(.004+i*.0026)*cos(a),y+(.004+i*.0045)*sin(a),col='#a77345',lwd=.8)};segments(x+.015,y+.04,x+.043,y+.045,col='#b78044',lwd=8)}
 if(kind=='salivary'){for(j in 1:6)ellipse(x+.009*cos(j),y+.023*sin(j),.009,.013,'#bc7b83','#6e5555');ellipse(x+.007,y-.006,.008,.012,'#ddbcc0')}
 if(kind=='pancreas'){polygon(x+c(-.024,-.018,-.012,-.004,.001,.009,.014,.012,.025,.02,.007,-.005,-.02),y+c(0,.025,.02,.038,.021,.042,.02,-.005,-.028,-.04,-.028,-.045,-.032),col='#9a8c5e',border='#625b47')}
 if(kind=='liver'){polygon(x+c(-.031,-.022,-.005,.013,.024,.028,.016,-.01,-.025),y+c(-.05,-.005,.063,.072,.05,-.004,-.034,-.062,-.062),col='#aa3928',border='#63291f');ellipse(x+.043,y+.047,.009,.025,'#237348','#215537');segments(x+.041,y+.025,x+.044,y-.03,col='#276844',lwd=2)}
}
zoom<-function(x,y,kind){
 ellipse(x,y,.028,.067,'white','#999999')
 if(kind=='stratified'){for(j in 1:7)for(i in 1:4)cell(x+(i-2.5)*.006,y+(j-4)*.014,cell_colors[c(1,4,5,5,5,3,3)[j]],rx=.0031,ry=.006)}
 if(kind=='villus'){a<-seq(0,pi,length.out=18);for(s in c(-1,1)){xx<-x+s*.010;yy<-y+seq(-.037,.045,length.out=18);for(j in 1:18)cell(xx+sin(j/4)*.003,yy[j],cell_colors[6+(j%%4)],rx=.003,ry=.004)};for(j in 1:8)cell(x+(j-4)*.003,y-.04,cell_colors[6+(j%%4)],rx=.003,ry=.005)}
 if(kind=='duct'){for(j in 1:16){a<-2*pi*j/16;cell(x+.016*cos(a),y-.022+.025*sin(a),'#dce343',rx=.004,ry=.007)};for(j in 1:10)cell(x+(-1)^j*.005,y+.005+j*.004,'#a4c23a',rx=.003,ry=.005)}
 if(kind=='gastric'){for(j in 1:18)for(s in c(-1,1))cell(x+s*(.006+.004*sin(j/4)),y-.05+j*.0055,cell_colors[c(13,14,15,16,17,18)[1+(j%%6)]],rx=.0028,ry=.004)}
 if(kind %in% names(schematic_cells)){d<-schematic_cells[[kind]];for(j in seq_len(nrow(d)))cell(x+d$dx[j],y+d$dy[j],d$color[j],rx=.0033,ry=.006)}
 if(kind=='bile'){for(j in 1:17)for(s in c(-1,1))cell(x+s*(.005+.009*exp(-((j-13)/3)^2)),y-.05+j*.0055,cell_colors[if(j<10)24 else 22],rx=.0028,ry=.004)}
}
pal<-colorRampPalette(c('#2c9fc5','#b4d7e7','#f8f7f5','#efa0a9','#c3002e'))(256)
draw<-function(){
 par(mar=rep(0,4),family='sans',xaxs='i',yaxs='i');plot.new();plot.window(c(0,1),c(0,1));text(.013,.975,'a',font=2,cex=1.7)
 hx<-.16;hw<-.30;top<-.89;bot<-.10
 idx<-1+round((expression+2)/4*255);rasterImage(as.raster(matrix(pal[idx],nr)),hx,bot,hx+hw,top,interpolate=FALSE)
 for(j in 1:nc){x<-hx+(j-1)*hw/nc;rect(x,.917,x+hw/nc,.932,col=c('#83664b','#b18d64','#79766c','#b89470','#e0ad91','#d7b2a4','#d39f83','#e4b893','#f0bc92','#a88d69','#d9d3c6','#c6bdb4','#984535','#607d43','#897850')[column_tissue[j]],border='grey85',lwd=.2);rect(x,.898,x+hw/nc,.912,col=cell_colors[column_cell[j]],border='grey85',lwd=.2)}
 text(.462,.926,'Tissues',adj=0,cex=.65);text(.462,.905,'Cell types',adj=0,cex=.65)
 rb<-top-c(0,cumsum(module_rows))/nr*(top-bot);cb<-hx+c(0,cumsum(module_width))/nc*hw
 for(k in 1:8)rect(cb[k],rb[k+1],cb[k+1],rb[k],border='#353535',lwd=.8)
 annotations<-c('1 Rumen, reticulum,\n   omasum','2 Salivary gland','3 Intestine','4 Liver, bile duct\n   (hepatocytes)','5 Abomasum','6 Liver, bile duct\n   (cholangiocytes)','7 Pancreas','8 Abomasum (parietal cells)')
 ax<-c(.245,.276,.365,.256,.304,.30,.37,.29);ay<-(rb[1:8]+rb[2:9])/2
 text(ax,ay,annotations,adj=0,cex=.67)
 # Pathway bar strips at the left; module 5 lacks a separate KEGG strip in source.
 centers<-c(.83,.675,.535,.395,.285,.205,.125)
 for(k in seq_along(pathways)){
  y<-centers[k];d<-enrichment[[k]];dy<-.033
  for(j in seq_len(nrow(d))){yy<-y+(nrow(d)+1-2*j)*dy/2;w<-min(9,-log10(d$p[j]))/9*.112;rect(.139-w,yy-.014,.139,yy+.014,col=pathway_colors[k],border=NA);text(.137,yy,d$term[j],adj=1,cex=.64)}
  h<-max(.034,nrow(d)*dy);rect(.146,y-h/2,.156,y+h/2,col=pathway_colors[k],border='#333333',lwd=.5);text(.151,y,pathway_modules[k],cex=.8)
 }
 text(c(.025,.081,.139),.08,c('9','4','0'),cex=.65);text(.083,.047,'KEGG pathways (-log10(P))',cex=.72)
 # TF annotations occupy a separate aligned column, linked to the heatmap modules.
 ty<-c(.80,.68,.555,.415,.31,.235,.16,.105)
 text(.551,.866,'TFs',cex=.72)
 for(k in 1:8){yy<-ty[k];segments(.475,if(k==1).839 else mean(ty[c(k-1,k)]),.6,if(k==1).839 else mean(ty[c(k-1,k)]),col='#777777',lwd=.6);text(.477,yy,as.character(k),cex=.8);text(.489,yy,TFs[k],adj=c(0,.5),cex=.61)}
 segments(.46,.89,.475,.839,col='#777777',lwd=.7);segments(.46,rb[2],.475,.719,col='#777777',lwd=.7)
 # Tissue outlines and enlarged cell structures in the same six anatomical rows.
 text(.688,.965,'Tissues',cex=.75);text(.83,.965,'Cell types',cex=.75)
 organ(.655,.85,'stomach');zoom(.715,.84,'stratified')
 organ(.722,.70,'intestine');zoom(.655,.70,'villus')
 organ(.656,.55,'salivary');zoom(.715,.55,'duct')
 organ(.722,.40,'stomach');zoom(.655,.40,'gastric')
 organ(.656,.25,'pancreas');zoom(.715,.25,'acinar')
 organ(.688,.095,'liver');zoom(.641,.087,'hepatic');zoom(.744,.087,'bile')
 for(yy in c(.85,.70,.55,.40,.25)){segments(.67,yy+.015,.698,yy+.04,col='#999999',lwd=.65);segments(.67,yy-.025,.698,yy-.05,col='#999999',lwd=.65)}
 groups<-list(1:5,6:9,10:12,c(13:18),c(11,10,14,19,20),21:24)
 yy<-c(.928,.765,.635,.51,.305,.145)
 for(k in 1:6)for(j in seq_along(groups[[k]])){
  z<-groups[[k]][j];y<-yy[k]-(j-1)*.029;cell(.798,y,cell_colors[z],rx=.0053,ry=.006);text(.811,y,cell_types[z],adj=0,cex=.69)
 }
 rasterImage(as.raster(matrix(pal,nrow=1)),.28,.055,.345,.073,interpolate=FALSE);text(.265,.064,'z-score',adj=1,cex=.67);text(seq(.28,.345,length.out=5),.039,-2:2,cex=.6)
}
saveRDS(list(expression=expression,gene_module=gene_module,column_module=column_module,column_tissue=tissues[column_tissue],column_cell=cell_types[column_cell],enrichment=enrichment,TFs=TFs,schematic_cells=schematic_cells),file.path(out,'gastrointestinal_epithelial_modules_simulated.rds'))
png(file.path(out,'gastrointestinal_epithelial_modules.png'),width=2780,height=1135,res=180,type='cairo');draw();dev.off()
cairo_pdf(file.path(out,'gastrointestinal_epithelial_modules.pdf'),width=15.44,height=6.31);draw();dev.off()
