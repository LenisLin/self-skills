#!/usr/bin/env Rscript
# Extended Data Fig. 2a: integrated communication among seven cattle cell lineages.
# Usage: Rscript cell_lineage_interaction_chord.R OUTPUT_DIR
args<-commandArgs(TRUE);out<-if(length(args))args[1]else'.';dir.create(out,recursive=TRUE,showWarnings=FALSE);set.seed(232)
lineages<-c('Stromal cells','Nervous cells','Muscle cells','Immune cells','Germline cells','Epithelial cells','Endothelial cells')
cols<-c('#9dd8e1','#eeee8f','#c26aa1','#f1d98e','#8a70ad','#d981b2','#62ba84')
# Interaction counts follow shared tissue access and lineage-specific signaling capacity.
base<-matrix(c(0,5,5,22,1,18,11, 5,0,2,3,.4,2,2, 5,2,0,9,.5,5,4, 22,3,9,0,1.5,19,14, 1,.4,.5,1.5,0,.9,.5, 18,2,5,19,.9,0,18, 11,2,4,14,.5,18,0),7,7,byrow=TRUE)
# Direction-specific counts preserve paired endpoints; diagonal terms encode self-signaling.
diag(base)<-c(11,1.7,3,14,.4,13,6)
counts<-matrix(0,7,7,dimnames=list(lineages,lineages))
for(i in 1:7)for(j in 1:7){direction_factor<-if(i==j)1 else exp(.18*(i-j)/6);counts[i,j]<-rpois(1,base[i,j]*250*direction_factor)}
# A lineage sector measures total endpoint mass: outgoing plus incoming counts.
# A self interaction occupies two endpoints in the same sector.
outgoing<-rowSums(counts);incoming<-colSums(counts);totals<-outgoing+incoming
gap<-3;span<-totals/sum(totals)*(360-7*gap);starts<-90-c(0,head(cumsum(span+gap),-1));ends<-starts-span
source_endpoint<-target_endpoint<-array(NA,c(7,7,2))
for(i in 1:7){cursor<-starts[i]
 for(j in c(i,setdiff(1:7,i))){w<-span[i]*counts[i,j]/totals[i];source_endpoint[i,j,]<-c(cursor,cursor-w);cursor<-cursor-w}
 for(j in c(setdiff(1:7,i),i)){w<-span[i]*counts[j,i]/totals[i];target_endpoint[j,i,]<-c(cursor,cursor-w);cursor<-cursor-w}
 stopifnot(abs(cursor-ends[i])<1e-8)
}
# Metadata tracks carry simulated donor-sex and count-derived sender/receiver fractions.
sex_fraction<-runif(7,.4,.65);sender_fraction<-outgoing/totals
saveRDS(list(lineage_colors=setNames(cols,lineages),interaction_counts=counts,lineage_total=totals,outgoing=outgoing,incoming=incoming,sex_fraction=sex_fraction,sender_fraction=sender_fraction,sector_start=starts,sector_end=ends,source_endpoint=source_endpoint,target_endpoint=target_endpoint),file.path(out,'cell_lineage_interaction_chord_simulated.rds'))
xy<-function(angle,r=1)cbind(r*cos(angle*pi/180),r*sin(angle*pi/180))
arc<-function(a,b,r,n=50)xy(seq(a,b,length.out=n),r)
ring<-function(a,b,r0,r1,col,border=NA){z<-rbind(arc(a,b,r1),arc(b,a,r0));polygon(z,col=col,border=border,lwd=.3)}
bezier<-function(p0,p1,p2,p3,n=70){t<-seq(0,1,length.out=n);s<-1-t;cbind(s^3*p0[1]+3*s^2*t*p1[1]+3*s*t^2*p2[1]+t^3*p3[1],s^3*p0[2]+3*s^2*t*p1[2]+3*s*t^2*p2[2]+t^3*p3[2])}
# Tangential labels are flipped on the lower semicircle for reading orientation.
tangent_text<-function(a,r,label,cex=.6,col='black'){p<-xy(a,r);rot<-(a-90+180)%%360-180;if(rot< -90)rot<-rot+180;if(rot>90)rot<-rot-180;text(p[1],p[2],label,srt=rot,cex=cex,col=col)}
draw<-function(){par(mar=rep(0,4),family='sans');plot.new();plot.window(c(-1.54,1.54),c(-1.52,1.48),asp=1,xaxs='i',yaxs='i');text(-1.5,1.43,'a',cex=1.8,adj=c(0,1))
 # Draw weaker interactions first and let major pathways remain legible.
 pairs<-which(counts>0,arr.ind=TRUE);pairs<-pairs[order(counts[pairs]),,drop=FALSE]
 # Put self-interaction ribbons last so their local petal loops remain visible.
 pairs<-rbind(pairs[pairs[,1]!=pairs[,2],,drop=FALSE],pairs[pairs[,1]==pairs[,2],,drop=FALSE])
 for(k in seq_len(nrow(pairs))){i<-pairs[k,1];j<-pairs[k,2];a<-source_endpoint[i,j,];b<-target_endpoint[i,j,];p0<-xy(a[2],.965)[1,];p3<-xy(b[1],.965)[1,];q0<-xy(b[2],.965)[1,];q3<-xy(a[1],.965)[1,]
  if(i==j){
   # Self ribbons turn inward locally, forming a visible loop inside their own sector.
   mid<-(starts[i]+ends[i])/2;center<-xy(mid,.48)[1,]
   z<-rbind(arc(a[1],a[2],.965,20),bezier(p0,p0*.45,p3*.45,p3),arc(b[1],b[2],.965,20),bezier(q0,center,center,q3))
  }else{z<-rbind(arc(a[1],a[2],.965,20),bezier(p0,p0*.30,p3*.30,p3),arc(b[1],b[2],.965,20),bezier(q0,q0*.30,q3*.30,q3))}
  polygon(z,col=adjustcolor(cols[i],alpha.f=.73),border='#656565',lwd=.3)}
 for(i in 1:7){a<-starts[i];b<-ends[i];ring(a,b,.965,1.005,cols[i],border='#4c4c4c');
  # Each integer tick is derived from the actual interaction-count scale.
  step<-if(span[i]<12)ceiling(totals[i]/2/500)*500 else if(totals[i]>20000)1000 else 500;v<-seq(0,totals[i],by=step)
  for(value in v){ang<-a-span[i]*value/totals[i];p<-xy(ang,1.008);q<-xy(ang,1.025);segments(p[1],p[2],q[1],q[2],lwd=.3);p<-xy(ang,1.09);rot<-ang;if(rot< -90||rot>90)rot<-rot+180;text(p[1],p[2],format(value,scientific=FALSE,trim=TRUE),srt=rot,cex=.31)}
  # Metadata rings, split within each lineage by their own denominators.
  cut<-a-span[i]*sex_fraction[i];ring(a,cut,1.175,1.196,'#79bdc8',border='#424242');ring(cut,b,1.175,1.196,'#d97ab1',border='#424242')
  cut<-a-span[i]*sender_fraction[i];ring(a,cut,1.202,1.218,'#f2db8d',border='#424242');ring(cut,b,1.202,1.218,'#7fc69a',border='#424242')
  for(f in if(span[i]<12)c(0,1)else seq(0,1,.1)){ang<-a-span[i]*f;p<-xy(ang,1.22);q<-xy(ang,1.242);segments(p[1],p[2],q[1],q[2],lwd=.3);p<-xy(ang,1.268);rot<-ang;if(rot< -90||rot>90)rot<-rot+180;text(p[1],p[2],paste0(round(f*100),'%'),srt=rot,cex=.31)}
  tangent_text((a+b)/2,1.4,lineages[i],cex=1.28)
 }
}
png(file.path(out,'cell_lineage_interaction_chord.png'),width=1800,height=1800,res=220,type='cairo');draw();dev.off()
cairo_pdf(file.path(out,'cell_lineage_interaction_chord.pdf'),width=8.18,height=8.18);draw();dev.off()
