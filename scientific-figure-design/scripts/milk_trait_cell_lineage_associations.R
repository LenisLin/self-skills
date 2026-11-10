# Reproduce CattleCA main Figure 7b with simulated cell-type/trait associations.
# Input: optional output directory. Outputs: PNG, vector PDF, simulated RDS.
# Run: Rscript milk_trait_cell_lineage_associations.R OUTPUT_DIR
# Uses base R; simulation and figure-specific drawing are fully inline.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else 'figures'
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(7329)
lineages <- c('Endothelial cells', 'Epithelial cells', 'Germline cells',
              'Immune cells', 'Muscle cells', 'Nervous cells', 'Stromal cells')
colors <- c('#007D44', '#E14892', '#37AA4D', '#F2AA5B', '#CC90B8', '#E7DF27', '#32B6CD')
n_types <- c(4, 50, 4, 30, 4, 20, 17)
types <- data.frame(cell_type = seq_len(129), lineage = rep(lineages, n_types))
traits <- c('FY','C10','C12','C15',paste0('Milk_trait_', 5:30))
d <- merge(types, data.frame(trait = traits), all = TRUE)
d$x <- d$cell_type + runif(nrow(d), -.38, .38)
# A large null component and a small lineage-dependent associated component.
rate <- c(2.2, 2.1, 2.0, 1.9, 1.4, 1.4, 1.6)[match(d$lineage,lineages)]
d$score <- rgamma(nrow(d), shape=.40, rate=rate)
active <- runif(nrow(d)) < c(.015,.07,.04,.06,.13,.13,.07)[match(d$lineage,lineages)]
d$score[active] <- rgamma(sum(active), 1.7, rate = .58)
d$score <- pmin(d$score, 8.6)
d$score[d$lineage=='Stromal cells'] <- pmin(d$score[d$lineage=='Stromal cells'],5.5)
d$score[d$lineage=='Endothelial cells'] <- pmin(d$score[d$lineage=='Endothelial cells'],1.6)
d$score[d$lineage=='Germline cells'] <- pmin(d$score[d$lineage=='Germline cells'],4.1)
# Embed coherent highlighted cell-type/trait pairs into the simulated matrix.
highlights <- data.frame(cell_type=c(90,106,89,91,35,95), trait=c('C10','FY','C12','C12','C15','FY'),
 score=c(16.6,15.0,15.9,12.7,3.6,7.6),
 label=c('C10_Excitatory neurons','FY_Excitatory neurons','C12_SMCs',
 'C12_Amacrine cells','C15_Luminal cells','FY_Neurons'),
 tx=c(90,115,77,90,34,102),ty=c(19.3,17.5,14.0,10.9,7.1,9.6))
# Correct subtype location to its lineage: nervous 93--112, muscle 89--92.
highlights$cell_type <- c(94,110,89,95,35,98)
for(i in seq_len(nrow(highlights))) {
 k <- which(d$cell_type==highlights$cell_type[i] & d$trait==highlights$trait[i])
 d$score[k] <- highlights$score[i]; d$x[k] <- highlights$cell_type[i]
}
d$FDR <- 10^(-d$score)
saveRDS(list(associations=d,highlights=highlights,lineages=types,seed=7329),
        file.path(out,'milk_trait_cell_lineage_associations_simulated.rds'))
# Draw at the reference crop's wide geometry, with inset legend and panel letter.
for (fmt in c('png','pdf')) {
 file <- file.path(out,paste0('milk_trait_cell_lineage_associations.',fmt))
 if(fmt=='png') png(file,width=1262,height=648,res=160,type='cairo') else
   cairo_pdf(file,width=1262/160,height=648/160)
 par(mar=c(2.8,5.5,6.5,10.2), mgp=c(1.6,.6,0),family='sans',cex=.83,xaxs='i',yaxs='i')
 plot(NA,xlim=c(-2,131),ylim=c(-.8,17.2),bty='l',xaxt='n',yaxt='n',
      xlab='Cell lineage',ylab=expression(-log[10](FDR)))
 axis(2,at=c(0,5,10,15),las=1,tck=-.014)
 axis(1,at=c(0,43,86,129),labels=FALSE,tck=-.025)
 abline(h=-log10(.05),lty=2,lwd=2.5)
 points(d$x,d$score,pch=16,cex=.82,col=colors[match(d$lineage,lineages)])
 for(i in seq_len(nrow(highlights))) {
  k <- which(d$cell_type==highlights$cell_type[i] & d$trait==highlights$trait[i])
  co <- colors[match(d$lineage[k],lineages)]
  dx <- highlights$tx[i]-d$x[k]; dy <- highlights$ty[i]-d$score[k]
  arrows(d$x[k]+dx*.15,d$score[k]+dy*.15,d$x[k]+dx*.65,d$score[k]+dy*.65,
         col=co,length=.07,lwd=1.8)
  text(highlights$tx[i], highlights$ty[i],highlights$label[i],col=co,cex=.79,xpd=NA)
 }
 mtext('Milk production',3,line=2.8,cex=1.05)
 legend(134,14.5,legend=lineages,col=colors,pch=16,bty='n',title='Cell lineages',
        xpd=NA,cex=.87,y.intersp=1.5,x.intersp=.8)
 mtext('b',3,line=5.4,at=-23,font=2,cex=1.6)
 dev.off()
}
