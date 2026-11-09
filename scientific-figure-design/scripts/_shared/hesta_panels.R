#!/usr/bin/env Rscript
# Reusable, simulated-data illustrations inspired by HESTA figure panels.
# Input tables are simulated here, not author measurements or biological results.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("Usage: Rscript hesta_panels.R PANEL OUTPUT_DIR")
panel <- args[[1]]
out <- normalizePath(args[[2]], mustWork = FALSE)
dir.create(out, recursive = TRUE, showWarnings = FALSE)
set.seed(20261108)

stage <- c("CS12–13", "CS14–15", "CS17", "CS18", "CS19", "CS20", "CS23")
stage_col <- c("#EEF2FA", "#C2D8EA", "#9CC5DB", "#69A5CA", "#438ABA", "#2169A9", "#00428A")
gene_col <- c("#BC6F45", "#87BA54", "#D497A2", "#CCB9CC", "#8DC0CF", "#7695B4", "#73A39D")
heat_col <- grDevices::colorRampPalette(c("#6CBAD1", "#F8F6EA", "#BB3D27"))(256)

scaled_colors <- function(x, limits = c(-2, 2), palette = heat_col) {
  index <- pmax(1L, pmin(length(palette), as.integer((x - limits[1]) /
    diff(limits) * (length(palette) - 1)) + 1L))
  matrix(palette[index], nrow = nrow(x), ncol = ncol(x))
}

heat_raster <- function(z, xleft, ybottom, xright, ytop, limits = c(-2, 2), palette = heat_col) {
  graphics::rasterImage(as.raster(scaled_colors(z, limits, palette)), xleft, ybottom, xright, ytop,
                        interpolate = FALSE)
}

new_canvas <- function(xlim = c(0, 1), ylim = c(0, 1)) {
  par(mar = rep(0, 4), xaxs = "i", yaxs = "i", family = "sans")
  plot.new(); plot.window(xlim = xlim, ylim = ylim)
}

text_label <- function(x, y, labels, cex = .55, col = "black", font = 1, ...) {
  text(x, y, labels, cex = cex, col = col, font = font, ...)
}

simulate_2a <- function() {
  lists <- list(
    Liver = c("ID1", "LDHA", "HNF4A", "ATF2", "B2M", "SERPINF1", "APOC2", "APOC1", "APOB", "FASN", "MT1F", "MT1H", "APOC3", "TFRC"),
    `Skeletal muscle` = c("HMGA1", "HMGB2", "MEGF10", "MEOX1", "HMGB1", "ACTB", "PDGFRA", "PLS3", "BMP4", "MYOG", "WASF2", "PTPRS", "ACTA1", "MYH3")
  )
  lapply(lists, function(genes) {
    peak <- rep(1:7, length.out = 112)
    peak <- sort(peak)
    value <- outer(peak, 1:7, function(p, s) 2.3 * exp(-((p-s)/1.05)^2) - .8) + matrix(rnorm(112*7, 0, .35), 112)
    list(values = value, genes = genes, row = round(seq(3, 110, length.out = length(genes))))
  })
}

draw_2a <- function(data) {
  new_canvas(c(0, 1), c(0, 1))
  terms <- list(c("Stem cell population maintenance", "ATP metabolic process", "Hepatobiliary system development", "Hepatocyte apoptotic process", "Erythrocyte differentiation", "Response to steroid hormone", "Plasma lipoprotein particle", "Lipoprotein particle", "Alcohol metabolic process", "Fatty acid metabolic process", "Detoxification of inorganic compound", "Stress response to copper ion", "Sterol transport", "Iron ion homeostasis"),
                c("DNA conformation change", "Nucleus organization", "Myoblast migration", "Somitogenesis", "Positive regulation of DNA binding", "Cell-substrate junction", "Regulation of actin filament-based process", "Actin filament", "Cranial skeletal system development", "Muscle cell proliferation", "Postsynaptic actin cytoskeleton organization", "Regeneration", "Myosin binding", "Muscle contraction"))
  text_label(.355,.993,"Genes",adj=0,cex=.5); text_label(.53,.993,"GO terms",adj=0,cex=.5)
  segments(.355,.982,.49,.982,lwd=.45); segments(.53,.982,.93,.982,lwd=.45)
  for (k in seq_along(data)) {
    ytop <- if (k == 1) .95 else .47; ybot <- ytop - .36
    mat <- data[[k]]$values
    heat_raster(mat, .12, ybot, .32, ytop)
    rect(.105, ybot, .115, ytop, border = NA, col = c("#D77368", "#97B66C")[k])
    text_label(.09, (ytop+ybot)/2, names(data)[k], srt = 90, cex = .58)
    for (j in 1:7) rect(.12+(j-1)*.2/7, ytop+.005, .12+j*.2/7, ytop+.018, col = stage_col[j], border = NA)
    ys <- seq(ytop-.008, ybot+.008, length.out = length(data[[k]]$genes))
    actual <- ytop - (data[[k]]$row-.5)/nrow(mat)*(ytop-ybot)
    for (j in seq_along(ys)) {
      col <- gene_col[ceiling(j/2)]
      segments(.32, actual[j], .35, ys[j], col = "#999999", lwd = .4)
      text_label(.355, ys[j], data[[k]]$genes[j], adj = 0, font = 3, col = col, cex = .53)
    }
    for (j in 1:14) text_label(.53, ys[j], terms[[k]][j], adj = 0, col = gene_col[ceiling(j/2)], cex = .45)
  }
  text_label(.82,.47,"Scaled GE",adj=0,cex=.46)
  for (i in 1:100) rect(.82,.36+(i-1)*.0009,.83,.36+i*.0009,border=NA,col=heat_col[round(i*2.56)])
  text_label(.835,c(.36,.405,.45),c("-2","0","2"),adj=0,cex=.4)
  text_label(.82,.335,"CS stage",adj=0,cex=.46)
  for (j in 1:7) {rect(.82,.325-j*.016,.83,.338-j*.016,border=NA,col=stage_col[j]); text_label(.835,.331-j*.016,stage[j],adj=0,cex=.39)}
}

simulate_2g <- function() {
  genes <- list(c("LIN28A","PRTG","DLK1","MALAT1","FTH1","SFRP2","GJA1","SERPINF1","TRPM3","PMEL","TYR","SLC38A11","TYRP1","DCT","DAPL1"),
                c("IGF2R","BEST1","IL6ST","SMOC1","ATG10","RASGEF1B","MIR4300HG","SLC26A3","TSPAN9","GSTP1","KRT8","PITX1","FAM107A","KRT18","TNNT1","CLDN3","CLDN4","AGR2","CLDN10","MUC16","UGT2A1","AQP3","ANXA3","CD9","ATOH7","CRABP1","CCSER1","TUBB2B","RTN1","STMN2","CNTN2","OLFM1","PRPH","INA","SYT4","NSG1","TUBB2A","POU6F2","ELAVL4","MLLT11","TUBA1A","GAP43","SNCG","TMSB4X","TMSB10","MAP1B"))
  lapply(seq_along(genes), function(k) {
    n <- length(genes[[k]]); x <- seq(-2,2,length.out=120)
    peak <- rep(c(-1.4,0,1.4),length.out=n)
    if (k==2) peak <- rep(c(-1.5,-.1,1.5),times=c(14,14,n-28))
    value <- outer(peak,x,function(p,q) 2.8*exp(-((p-q)/1.3)^2)-1.4) + matrix(rnorm(n*120,0,.06),n)
    list(values = value, genes = genes[[k]], red = which(genes[[k]] %in% c("TYRP1","PMEL","ATOH7","SNCG","GAP43")))
  })
}

draw_2g <- function(data) {
  new_canvas(c(0, 1), c(0, 1))
  pal <- grDevices::colorRampPalette(c("#4C4197", "#398EAC", "#BFE0A0", "#F9EAA2", "#F18A47", "#A50026"))(256)
  for (k in 1:2) {
    ytop <- c(.96,.70)[k]; ybot <- c(.75,.13)[k]
    d <- data[[k]]; n <- length(d$genes)
    heat_raster(d$values, .29, ybot, .71, ytop, palette = pal)
    for (i in 1:n) {
      y <- ytop-(i-.5)/n*(ytop-ybot); left <- i %% 2 == 1
      text_label(if (left) .275 else .725, y, d$genes[i], adj = if (left) 1 else 0,
                 font = 3, cex = if (k == 1) .5 else .38,
                 col = if (i %in% d$red) "#D7483B" else "black")
    }
    subs <- if (k == 1) c("#E9A4AA", "#D44D49") else c("#AB8DBB", "#A47A62")
    for (j in 1:120) {
      rect(.29+(j-1)*.42/120,ybot-.014,.29+j*.42/120,ybot-.006,col=subs[1+(j>60)],border=NA)
      rect(.29+(j-1)*.42/120,ybot-.028,.29+j*.42/120,ybot-.020,col=stage_col[c(1,2,3,4,6,7)[ceiling(j/20)]],border=NA)
    }
    text_label(.725,ybot-.010,"Substructure",adj=0,cex=.42)
    text_label(.725,ybot-.024,"CS stage",adj=0,cex=.42)
  }
  text_label(.29,.065,"Scaled GE",adj=0,cex=.45)
  for(i in 1:100) rect(.29+(i-1)*.0014,.04,.29+i*.0014,.05,col=pal[round(i*2.56)],border=NA)
  text_label(c(.29,.36,.43),.028,c("-2","0","2"),cex=.4)
}

simulate_3b <- function() {
  cols <- c("#8DD3C7", "#FB8072", "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#BC80BD")
  lapply(seq_along(stage), function(i) {
    n <- 900; effect <- pmax(-3,pmin(3,rnorm(n,0,.72)))
    limit <- c(271,170,220,85,208,269,288)[i]
    score <- pmin(limit,abs(effect)^2*runif(n,15,limit/3))
    gene <- paste0("SyntheticGene", seq_len(n))
    chosen <- c(order(effect,decreasing=TRUE)[1:3],order(effect)[1:3])
    gene[chosen] <- c("MYH6","NPPA","PAM","MYH7","MYL2","BMP4")
    p_adj <- 10^(-score)
    data.frame(effect = effect, p_adj = p_adj, signed_score = sign(effect)*(-log10(p_adj)), gene=gene,
               significant = p_adj < .05 & abs(effect) > .25, color = cols[i],limit=limit)
  })
}

draw_3b <- function(data) {
  par(mfrow = c(1,7), mar = c(3.6,2.5,.4,.3), oma=c(1.2,0,0,0), mgp = c(1.4,.35,0), tcl = -.16,
      cex.axis = .5, cex.lab = .55, family = "sans")
  for (i in seq_along(data)) {
    d <- data[[i]]; lim <- d$limit[1]
    plot(d$signed_score,d$effect,pch=16,cex=.48,col=ifelse(d$significant,d$color,"#DEE1E6"),
         xlim=c(-lim,lim),ylim=c(-3.1,3.1),axes=FALSE,xlab=stage[i],ylab=if(i==1) "Atrium vs ventricle (average log2FC)" else "")
    abline(h=c(-.25,.25),lty=2,lwd=.45,col="#888888")
    axis(1,at=c(-lim,0,lim),labels=FALSE,lwd=.4,lwd.ticks=.4)
    text(c(-lim,0,lim),par("usr")[3]-.12,labels=c(-lim,0,lim),srt=45,adj=1,xpd=NA,cex=.46)
    if(i==1) axis(2,at=c(-3,0,3),las=1,lwd=.4,lwd.ticks=.4)
    box(bty="l",lwd=.4)
    top <- c(order(d$effect,decreasing=TRUE)[1:3],order(d$effect)[1:3])
    label_y <- c(2.8,2.45,2.1,-2.1,-2.45,-2.8)
    label_x <- ifelse(d$signed_score[top]>0, -.12*lim, .12*lim)
    segments(d$signed_score[top],d$effect[top],label_x,label_y,lwd=.35)
    for(j in seq_along(top)) text(label_x[j],label_y[j],d$gene[top[j]],cex=.6,font=3,adj=if(label_x[j]<0) 1 else 0)
  }
  mtext("Signed -log10(adjusted P), simulated", side=1, outer=TRUE, line=.2, cex=.65)
}

simulate_4i <- function() {
  x <- seq(0,20,length.out=201)
  data.frame(pseudotime=rep(x,4),gene=rep(c("HES5","HMGA2","FOXG1","NEUROG2"),each=length(x)),
    expression=c(.55+.85*exp(-((x-5.5)/6)^2), .47-.08*exp(-((x-3)/4)^2)+.95/(1+exp(-(x-12)/2.5)),
                 .02+1.08*exp(-((x-15)/7)^2), .29+.22*exp(-((x-4)/4)^2)+.52*(x/20)^7))
}

draw_4i <- function(data) {
  par(mar=c(3,3,2.8,.7),mgp=c(1.6,.45,0),tcl=-.18,cex.axis=.7,cex.lab=.8,family="sans")
  plot(NA,xlim=c(0,20),ylim=c(0,1.5),xlab="Pseudotime",ylab="Expression",axes=FALSE)
  axis(1,at=seq(0,20,5),lwd=.6); axis(2,at=0:1,las=1,lwd=.6); box(bty="l",lwd=.6)
  cols <- c(HES5="#F56300", HMGA2="#00D7CE", FOXG1="#28A2F9", NEUROG2="#7447D1")
  for (gene in names(cols)) {d <- data[data$gene==gene,]; lines(d$pseudotime,d$expression,col=cols[gene],lwd=1.25)}
  legend("top",legend=names(cols),col=cols,lwd=1.25,ncol=2,bty="n",text.font=3,cex=.65,inset=c(0,-.17),xpd=NA)
}

simulate_5e <- function() {
  organs <- c("Brain","SpC","Eye","IE","Heart","Som","Myo","SM","HD","Liver","LP","Lung","PG","Gut")
  n <- 1740; m <- length(organs)*7
  group <- cut(seq_len(n),breaks=9,labels=FALSE)
  x <- matrix(rnorm(n*m,mean=-.5,sd=.55),n)
  boundaries <- c(1,2,3,4,5,7,9,11,13,15)
  for (i in 1:9) {cols <- ((boundaries[i]-1)*7+1):((boundaries[i+1]-1)*7); rows <- which(group==i); x[rows,cols] <- x[rows,cols]+matrix(rexp(length(rows)*length(cols),rate=.42),length(rows))}
  labels <- c("FAM149B1","DCC","BCL11A","GAA","ETFB","PEX5","APC2","OTX2","ALDH1A3","RAX","BFSP2","TMEM94","COA5","MMADHC","PEX1","STAG2","NPC2","GATA4","GATA6","AGL","TBX20","TTN","LDB3","LMNA","GALE","SLC33A1","GFER","ARG1","FTL","MMACHC","PET100","CCBE1","ABCD4")
  annotation_rows <- round(seq(40,n-60,length.out=length(labels)))
  rownames(x) <- paste0("SyntheticGene",seq_len(n)); rownames(x)[annotation_rows] <- labels
  list(values=x,organs=organs,group=group,annotation_rows=annotation_rows)
}

draw_5e <- function(data) {
  new_canvas(c(0,1),c(0,1)); mat <- data$values; n <- nrow(mat); m <- ncol(mat)
  pal <- grDevices::colorRampPalette(c("#78C7DB","#F9F8EF","#BC3419"))(256)
  heat_raster(mat,.10,.06,.73,.85,limits=c(-5,10),palette=pal)
  organ_cols <- grDevices::hcl.colors(14,"Pastel 1")
  for(j in 1:m) {
    organ <- ceiling(j/7); x1 <- .1+(j-1)*.63/m; x2 <- .1+j*.63/m
    rect(x1,.855,x2,.866,col=stage_col[(j-1)%%7+1],border=NA)
    rect(x1,.868,x2,.879,col=organ_cols[organ],border=NA)
    rect(x1,.881,x2,.892,col=c("#C5D998","#DFD88D","#B4BD88")[(organ-1)%%3+1],border=NA)
  }
  for(i in 1:14) text_label(.1+(i-.5)*.63/14,.905,data$organs[i],srt=45,adj=0,cex=.42)
  text_label(.096,c(.886,.873,.86),c("Layer","Organ","Stage"),adj=1,cex=.4)
  for(i in 1:9) {
    boundaries <- c(1,2,3,4,5,7,9,11,13,15)
    rows <- which(data$group==i); xl <- .1+(boundaries[i]-1)*7*.63/m; xr <- .1+(boundaries[i+1]-1)*7*.63/m
    rect(xl,.85-max(rows)*.79/n,xr,.85-(min(rows)-1)*.79/n,border="#C63C32",lty=2,lwd=.7)
  }
  labels <- rownames(mat)[data$annotation_rows]
  pos <- .85-(data$annotation_rows-.5)*.79/n
  for(i in seq_along(pos)) {segments(.73,pos[i],.76,pos[i]+.002,lwd=.4,col="#777777"); text_label(.765,pos[i]+.002,labels[i],font=3,adj=0,cex=.36,col=gene_col[(i-1)%%7+1])}
  for(i in 1:100) rect(.94,.20+(i-1)*.003,.955,.20+i*.003,col=pal[round(i*2.56)],border=NA)
  text_label(.92,.52,"Scaled GE",cex=.42); text_label(.96,c(.20,.30,.40,.50),c("−5","0","5","10"),adj=0,cex=.4)
}

simulate_ext10f <- function() {
  n <- 600; group <- rep(1:8,each=75); x <- seq(-1,1,length.out=7)
  human <- mouse <- matrix(0,n,7)
  for(i in 1:8) {
    rows <- which(group==i)
    hdirection <- if(i<=4) 1 else -1
    mdirection <- if(i %in% c(1:2,5:6)) 1 else -1
    human[rows,] <- outer(runif(length(rows),.7,1.3),hdirection*x) + matrix(rnorm(length(rows)*7,0,.25),length(rows))
    mouse[rows,] <- outer(runif(length(rows),.7,1.3),mdirection*x) + matrix(rnorm(length(rows)*7,0,.25),length(rows))
  }
  genes <- c("BCL11A","FOXG1","SOX4","SYT1","SMARCC2","THRA","SUCLG1","NHP2","HNRNPK","CAMTA1","CENPF","DHFR","ERCC1","FBLN1","EZH2","HCFC1","MSI1","PSAT1")
  annotation_rows <- round(seq(8,n-12,length.out=length(genes)))
  rownames(human) <- rownames(mouse) <- paste0("SyntheticGene",seq_len(n))
  rownames(human)[annotation_rows] <- rownames(mouse)[annotation_rows] <- genes
  list(human=human,mouse=mouse,group=group,annotation_rows=annotation_rows,synthetic=TRUE)
}

draw_ext10f <- function(data) {
  new_canvas(); top <- .84; bot <- .06; n <- nrow(data$human)
  palette <- grDevices::colorRampPalette(c("#172554","#826CAC","#FCFAFD","#DB8E82","#AA2925"))(256)
  heat_raster(data$human,.16,bot,.29,top,limits=c(-2,2),palette=palette)
  heat_raster(data$mouse,.295,bot,.425,top,limits=c(-2,2),palette=palette)
  human_stage <- stage_col
  mouse_stage <- grDevices::colorRampPalette(c("#F6E0C6","#8D5E3B"))(7)
  for(i in 1:7) {
    rect(.16+(i-1)*.13/7,.845,.16+i*.13/7,.86,border=NA,col=human_stage[i])
    rect(.295+(i-1)*.13/7,.845,.295+i*.13/7,.86,border=NA,col=mouse_stage[i])
    text_label(.16+(i-.5)*.13/7,.87,stage[i],srt=90,adj=0,cex=.38)
    text_label(.295+(i-.5)*.13/7,.87,paste0("E",seq(10.5,16.5,1)[i]),srt=90,adj=0,cex=.38)
  }
  text_label(.29,.985,"Brain",cex=.65)
  for(i in 1:8) {
    rows <- which(data$group==i); yt <- top-(min(rows)-1)*(top-bot)/n; yb <- top-max(rows)*(top-bot)/n
    rect(.435,yb,.45,yt,col=if(i<=4) "#D84243" else "#1D5189",border=NA)
    rect(.452,yb,.467,yt,col=if(i %in% c(1:2,5:6)) "#398C3C" else "#8B589D",border=NA)
    rect(.469,yb,.484,yt,col=if(i%%2) "#F09892" else "#70B8AD",border=NA)
  }
  text_label(c(.442,.459,.476),.865,c("Human group","Mouse group","Cluster"),srt=90,adj=0,cex=.35)
  genes <- rownames(data$human)[data$annotation_rows]
  label_y <- top-(data$annotation_rows-.5)*(top-bot)/n
  for(i in seq_along(genes)) {segments(.145,label_y[i],.16,label_y[i],lwd=.4);text_label(.14,label_y[i],genes[i],font=3,adj=1,cex=.4)}
  terms <- list(c("axon development","axonogenesis","modulation of chemical synaptic transmission"),
    c("modulation of chemical transmission","regulation of trans-synaptic signalling","synapse organization"),
    c("negative regulation of fatty acid biosynthetic process","pyroptosis","androgen receptor signaling"),
    c("vasculogenesis","regulation of vasculogenesis","fatty acid transport"),
    c("chondrocyte differentiation","apoptotic signaling","neutrophil migration"),
    c("toll-like receptor 3 signaling pathway","protein ubiquitination","ammonium ion metabolic process"),
    c("nuclear division","organelle fission","mitotic nuclear division"),
    c("DNA replication","DNA-dependent DNA replication","ncRNA processing"))
  border <- rep(c("#9891C1","#777777","#B451A1","#E58198"),each=2)
  for(i in 1:8) {
    yt <- .945-(i-1)*.11; yb <- yt-.105; ym <- (yt+yb)/2
    segments(.484,top-(i-.5)*(top-bot)/8,.50,ym,col=border[i],lwd=.55)
    rect(.50,yb,.87,yt,border=border[i],lwd=.6)
    for(j in 1:3) text_label(.505,yt-.015-(j-1)*.03,terms[[i]][j],adj=0,cex=.43,col=if(i%%2) "#E99C99" else "#72BEB3")
  }
  text_label(.90,.80,"Scaled exp.",adj=0,cex=.4)
  for(i in 1:100) rect(.90,.62+(i-1)*.0016,.91,.62+i*.0016,col=palette[round(i*2.56)],border=NA)
  text_label(.915,c(.62,.70,.78),c("-2","0","2"),adj=0,cex=.36)
  for(j in 1:3) {
    labels <- list(c("UTG","DTG"),c("UTG","DTG"),c("1","2"))[[j]]
    colors <- list(c("#D84243","#1D5189"),c("#398C3C","#8B589D"),c("#F09892","#70B8AD"))[[j]]
    y <- .55-(j-1)*.12
    text_label(.90,y,c("Human group","Mouse group","Cluster")[j],adj=0,cex=.38)
    for(k in 1:2) {rect(.90,y-.02*k,.91,y-.02*k+.012,col=colors[k],border=NA);text_label(.915,y-.02*k+.006,labels[k],adj=0,cex=.37)}
  }
}

source(file.path(dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value=TRUE)[1]))), "extended_panels.R"))
simulators <- list(`2a`=simulate_2a, `2g`=simulate_2g, `3b`=simulate_3b, `4i`=simulate_4i, `5e`=simulate_5e,
                   ext2a=simulate_ext2a,ext7c=simulate_ext7c,ext7d=simulate_ext7d,ext10f=simulate_ext10f)
drawers <- list(`2a`=draw_2a, `2g`=draw_2g, `3b`=draw_3b, `4i`=draw_4i, `5e`=draw_5e,
                ext2a=draw_ext2a,ext7c=draw_ext7c,ext7d=draw_ext7d,ext10f=draw_ext10f)
sizes <- list(`2a`=c(6.6,7.0), `2g`=c(5.2,6.4), `3b`=c(8,8), `4i`=c(3.2,2.6), `5e`=c(7,8.5),
              ext2a=c(11,10),ext7c=c(6.8,6.8),ext7d=c(12,10),ext10f=c(14,7))
if (!panel %in% names(simulators)) stop("Unknown panel: ", panel)
data <- simulators[[panel]]()
saveRDS(data,file.path(out,paste0(panel,"_simulated.rds")))
size <- sizes[[panel]]
for (format in c("pdf","png")) {
  path <- file.path(out,paste0(panel,".",format))
  if (format=="pdf") grDevices::cairo_pdf(path,width=size[1],height=size[2])
  else grDevices::png(path,width=size[1],height=size[2],units="in",res=200,type="cairo")
  drawers[[panel]](data)
  dev.off()
}
cat("completed",panel,"\n")
