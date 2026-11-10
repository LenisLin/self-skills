#!/usr/bin/env Rscript
# Figure 3h: zero-inflated count expression along bifurcating pseudotime.
args<-commandArgs(trailingOnly=TRUE);out<-if(length(args))args[1] else '.'
dir.create(out,recursive=TRUE,showWarnings=FALSE);set.seed(3402)
types<-c('MA0','MA1','MA2','MA3','MA4','MA5','MO0','MO1','MO2')
colors<-c('#8bcdbd','#f2aa96','#51ab60','#f2bd67','#51c5eb','#cfe797','#c39a70','#9755aa','#575757')
n<-c(500,170,160,120,55,65,150,120,160)
time<-c(rbeta(n[1],32,1.4)*100,rnorm(n[2],57,9),runif(n[3],28,100),runif(n[4],40,100),runif(n[5],15,95),runif(n[6],25,90),runif(n[7],0,30),c(runif(60,0,28),rnorm(60,84,3)),runif(n[9],0,20))
time<-pmin(100,pmax(0,time));subtype<-rep(types,n);branch<-ifelse(subtype=='MA0','State5','States2,3,4')
genes<-c('CALCR','CX3CR1','GPC5','P2RY12');data<-list()
for(g in seq_along(genes)) {
 mu<-switch(g, .2+35*plogis((time-96)/2)*(subtype=='MA0')+12*(subtype=='MA1'),
  2+12*(subtype=='MA1')+5*(subtype=='MA0')+4*(subtype=='MO2'),
  .3+12*plogis((time-94)/3)*(subtype=='MA0')+8*(subtype=='MA1'),
  .4+6*plogis((time-94)/3)*(subtype=='MA0')+8*(subtype=='MA1'))
 count<-rnbinom(length(mu),mu=mu,size=.6);count[runif(length(mu))<.55]<-0
 data[[g]]<-data.frame(gene=genes[g],pseudotime=time,subtype=subtype,branch=branch,count=count,expression=count+.5)
}
data<-do.call(rbind,data)
draw<-function(){
 par(mar=rep(0,4));plot.new();plot.window(c(0,1),c(0,1));text(.035,.976,'h',font=2,cex=1.7)
 text(.025,.54,'Expression',srt=90,cex=.85)
 for(g in 1:4){
  upper<-1-(g-1)*.22-.065;lower<-upper-.205
  par(fig=c(.04,.77,lower,upper),new=TRUE,mar=c(.4,2.4,1.4,.2),mgp=c(1.5,.4,0),tcl=-.2,family='sans')
  d<-data[data$gene==genes[g],]; ymax<-if(g==3)60 else 180
  plot(d$pseudotime,d$expression,log='y',pch=16,cex=.70,col=adjustcolor(colors[match(d$subtype,types)],.8),xlim=c(0,100),ylim=c(.45,ymax),axes=FALSE,xlab='',ylab='',xaxs='i')
  axis(2,at=if(g==3)c(1,3,10,30) else c(1,10,100),labels=if(g==3)c(1,3,10,30) else c(1,10,100),las=1,cex.axis=.63,lwd=.6)
  if(g==4){axis(1,at=seq(0,100,25),cex.axis=.63,lwd=.6)}
  box(bty='l',lwd=.6);title(main=genes[g],font.main=3,cex.main=.8,line=.1)
  # Kernel mean trajectories estimated from the simulated branch observations.
  for(b in c('States2,3,4','State5')) {
   z<-d[d$branch==b | d$pseudotime<35,]
   xx<-seq(0,100,length.out=150)
   yy<-vapply(xx,function(t){w<-exp(-.5*((z$pseudotime-t)/7)^2);sum(w*z$expression)/sum(w)},numeric(1))
   lines(xx,yy,lty=if(b=='State5')2 else 1,lwd=.9,col='black')
  }
 }
 par(fig=c(0,1,0,1),new=TRUE,mar=rep(0,4));plot.new();plot.window(c(0,1),c(0,1))
 text(.415,-.014,'Pseudotime',cex=.75,xpd=NA)
 text(.82,.67,'Branch',srt=90,cex=.7)
 for(i in 1:2){x<-.87+(i-1)*.075;segments(x,.65,x,.70,lty=i,lwd=1);text(x,.725,c('States2,3,4','State5')[i],srt=90,adj=c(0,.5),cex=.65)}
 text(.805,.48,'Cell subtypes',srt=90,cex=.72)
 yy<-seq(.60,.36,length.out=9);points(rep(.858,9),yy,pch=16,col=colors,cex=1.8);text(.858,yy,1:9,col='white',cex=.73);text(.892,yy,types,adj=0,cex=.77)
}
saveRDS(data,file.path(out,'microglia_marker_pseudotime_simulated.rds'))
png(file.path(out,'microglia_marker_pseudotime.png'),width=810,height=1370,res=160,type='cairo');draw();dev.off()
cairo_pdf(file.path(out,'microglia_marker_pseudotime.pdf'),width=5.06,height=8.56);draw();dev.off()
