library(dplyr)
library(tidyr)
library(ggplot2)

args <- commandArgs(TRUE)
mydir=args[1]

# load data
u1=read.table(paste(mydir,'/results/time_series/chip_only_auto_gen4.csv',sep=''),head=T,stringsAsFactors=F,sep=',')
u2=read.table(paste(mydir,'/results/time_series/common_auto_gen4.csv',sep=''),head=T,stringsAsFactors=F,sep=',')
u3=read.table(paste(mydir,'/results/time_series/chip_only_X_gen4.csv',sep=''),head=T,stringsAsFactors=F,sep=',')
u4=read.table(paste(mydir,'/results/time_series/common_X_gen4.csv',sep=''),head=T,stringsAsFactors=F,sep=',')
u=rbind(u1,u2,u3,u4)

# compute chi-square test
u = u %>% mutate(LR=2*(LMLE-L0)) %>% mutate(pval_time=pchisq(LR,lower.tail=F,df=1)) %>% mutate(log10_pval_time=-log10(pval_time))

# add position
pos=read.table(paste(mydir,'/plink_files/chip_only_auto_gen4_unrelated.bim',sep=''),head=F)
colnames(pos)=c('CHR','ID','d','pos','A1','A2')
pos2=read.table(paste(mydir,'/plink_files/common_auto_gen4_unrelated.bim',sep=''),head=F)
colnames(pos2)=c('CHR','ID','d','pos','A1','A2')
posX=read.table(paste(mydir,'/plink_files/chip_only_X_gen4_unrelated.bim',sep=''),head=F)
colnames(posX)=c('CHR','ID','d','pos','A1','A2')
posX2=read.table(paste(mydir,'/plink_files/common_X_gen4_unrelated.bim',sep=''),head=F)
colnames(posX2)=c('CHR','ID','d','pos','A1','A2')
pos=rbind(pos,pos2,posX,posX2)
u = left_join(u,pos,key=ID)

# filters on maf - autosomes
f=read.table(paste(mydir,'/plink_files/chip_only_auto_gen4_unrelated.frq.strat',sep=''),head=T)
f.all=f %>% select(SNP,CLST,MAC) %>% group_by(SNP) %>% summarize(MAC.all=sum(MAC))
f_im=read.table(paste(mydir,'/plink_files/common_auto_gen4_unrelated.frq.strat',sep=''),head=T)
f_im.all=f_im %>% select(SNP,CLST,MAC) %>% group_by(SNP) %>% summarize(MAC.all=sum(MAC))
f.all=rbind(f.all,f_im.all) %>% mutate(MAC=MAC.all)
f.all.filtered = f.all %>% select(SNP,MAC) %>% filter(MAC>10) %>% rename(ID=SNP)

# filters on maf - X
f=read.table(paste(mydir,'/plink_files/chip_only_X_gen4_unrelated.frq.strat',sep=''),head=T)
f.all.X=f %>% select(SNP,CLST,MAC) %>% group_by(SNP) %>% summarize(MAC.all=sum(MAC))
f=read.table(paste(mydir,'/plink_files/common_X_gen4_unrelated.frq.strat',sep=''),head=T)
f_im.all.X=f %>% select(SNP,CLST,MAC) %>% group_by(SNP) %>% summarize(MAC.all=sum(MAC))
f.all.X=rbind(f.all.X,f_im.all.X) %>% rename(MAC=MAC.all)
f.all.X.filtered = f.all.X %>% select(SNP,MAC) %>% filter(MAC>5) %>% rename(ID=SNP)

u = inner_join(u,rbind(f.all.filtered,f.all.X.filtered),key=ID)

# filters out 4 outlier SNPs
u = u %>% arrange(pval_time)
u=u[-(1:4),]

# pvalue distribution
p=ggplot(u,aes(x=pval_time))+geom_histogram()+theme_bw() +xlab('p-value')+ylab('number of SNPs') 
ggsave(paste(mydir,'/results/time_series/time_pval_hist.png',sep=''),plot = p, width = 4, height = 4)

# manhattan plots
M=max(u$log10_pval_time)
# chr1 to chr12
utemp = u %>% filter(CHR<=12)
p=ggplot(utemp,aes(x=pos,y=log10_pval_time))+geom_point(alpha=0.5)+theme_bw()+facet_wrap(~CHR,scales='free')+ylim(0,M)
ggsave(paste(mydir,'/results/time_series/time_man1.png',sep=''),plot = p, width = 12, height = 6)
# chr13 to chr24
utemp = u %>% filter((CHR<=24)&(CHR>=13))
p=ggplot(utemp,aes(x=pos,y=log10_pval_time))+geom_point(alpha=0.5)+theme_bw()+facet_wrap(~CHR,scales='free')+ylim(0,M)
ggsave(paste(mydir,'/results/time_series/time_man2.png',sep=''),plot = p, width = 12, height = 6)
# chr25 to chr29
utemp = u %>% filter(CHR>=25)
p=ggplot(utemp,aes(x=pos,y=log10_pval_time))+geom_point(alpha=0.5)+theme_bw()+facet_wrap(~CHR,scales='free')+ylim(0,M)
ggsave(paste(mydir,'/results/time_series/time_man3.png',sep=''),plot = p, width = 9, height = 3)

# save results
u = u %>% select(CHR,pos,ID,sMLE,LR,pval_time,log10_pval_time) %>% arrange(CHR,pos) 
write.table(u,file=paste(mydir,'/results/time_series/time_all.txt',sep=''),quote=F,col.names=T,row.names=F)

## local score

# import source code from Fariello et al (2017) and convert data into relevant format
library(data.table)
source(paste(mydir,'/scripts/scorelocalfunctions_vf.R',sep=''))
mydata=u %>% select(CHR,pos,pval_time) %>% rename(chr=CHR,pvalue=pval_time) %>% arrange(chr,pos)
mydata=data.table(mydata)
setkey(mydata,chr)
Nchr=length(mydata[,unique(chr)])
# add cumulated positions
chrInf=mydata[,.(L=.N,cor=autocor(pvalue)),chr]
setkey(chrInf,chr)
tmp=data.table(chr=mydata[,unique(chr),], S=cumsum(c(0,chrInf$L[-Nchr])))
setkey(tmp,chr)
mydata[tmp,posT:=pos+S]
# compute scores from p-values
xi=1
mydata[,score:= -log10(pvalue)-xi]
mean(mydata$score)
mydata[,lindley:=lindley(score),chr]
# compute significnce thresholds for each chromosome
chrInf[,th:=thresUnif(L, cor, 1,0.1),]
mydata=mydata[chrInf]
sigZones=mydata[chrInf,sig_sl(lindley, pos, unique(th)),chr]
sigZones = sigZones %>% filter(beg>0) %>% select(chr,beg,end) %>% mutate(L=end-beg) %>% mutate(nb_snp=0)
for (i in 1:(dim(sigZones)[1])){
	reg=mydata %>% filter((chr==sigZones$chr[i])&(pos>=sigZones$beg[i])&(pos<=sigZones$end[i]))	
	print(reg)
	sigZones$nb_snp[i]=dim(reg)[1]
}
write.table(sigZones,file=paste(mydir,'/results/time_series/time_SL_signif10.txt',sep=''),quote=F,col.names=T,row.names=F)
# plot lindley process
M=max(max(chrInf$th),max(mydata$lindley))
# chr1 to chr12
mydata.temp = mydata %>% filter(chr<=12) 
p=ggplot(mydata.temp,aes(x=pos,y=lindley))+geom_line()+theme_bw()+facet_wrap(~chr,scales='free',nrow=4,ncol=3)+ylim(0,M)+xlab('genomic position')+ylab('Lindley process')
p=p+geom_hline(aes(yintercept=th),color='red')
ggsave(paste(mydir,'/results/time_series/time_SL_signif10_man1.png',sep=''),plot = p, width = 12, height = 6)
# chr13 to chr24
mydata.temp = mydata %>% filter((chr<=24)&(chr>=13)) 
p=ggplot(mydata.temp,aes(x=pos,y=lindley))+geom_line()+theme_bw()+facet_wrap(~chr,scales='free',nrow=4,ncol=3)+ylim(0,M)+xlab('genomic position')+ylab('Lindley process')
p=p+geom_hline(aes(yintercept=th),color='red')
ggsave(paste(mydir,'/results/time_series/time_SL_signif10_man2.png',sep=''),plot = p, width = 12, height = 6)
# chr25 to chr29
mydata.temp = mydata %>% filter(chr>=25) 
p=ggplot(mydata.temp,aes(x=pos,y=lindley))+geom_line()+theme_bw()+facet_wrap(~chr,scales='free',nrow=4,ncol=3)+ylim(0,M)+xlab('genomic position')+ylab('Lindley process')
p=p+geom_hline(aes(yintercept=th),color='red')
ggsave(paste(mydir,'/results/time_series/time_SL_signif10_man3.png',sep=''),plot = p, width = 9, height = 3)









