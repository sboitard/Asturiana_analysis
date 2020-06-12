library(dplyr)
library(tidyr)
library(ggplot2)

args <- commandArgs(TRUE)
mydir=args[1]

# import selscan files and add positions
# chr X
u=read.table(paste(mydir,'/results/nSL/image_cr2_X.nsl.out',sep=''),head=F)
colnames(u)=c('snp','pos','freq','sl1','sl2','u_nsl')
u = u %>% select(snp,pos,freq,u_nsl)
v=read.table(paste(mydir,'/results/nSL/image_cr2_X.pos',sep=''),head=F)
colnames(v)=c('chr','pos','snp')
u = left_join(u,v,key=snp)
# autosomes
for (i in 1:29){
	utemp=read.table(paste(mydir,'/results/nSL/image_cr2_',i,'.nsl.out',sep=''),head=F)
	colnames(utemp)=c('snp','pos','freq','sl1','sl2','u_nsl')
	utemp = utemp %>% select(snp,pos,freq,u_nsl)
	vtemp=read.table(paste(mydir,'/results/nSL/image_cr2_',i,'.pos',sep=''),head=F)
	colnames(vtemp)=c('chr','pos','snp')
	utemp = left_join(utemp,vtemp,key=snp)
	u=rbind(u,utemp)
}

# folded nsl
u=u %>% mutate(u_nsl_f=u_nsl) %>% mutate(freq_f=freq)
ind=which(u$u_nsl_f<0)
u$u_nsl_f[ind]=-u$u_nsl_f[ind]
u$freq_f[ind]=1-u$freq_f[ind]

# standardized nSL autosomes
u1=u %>% filter(chr<=29) %>% mutate(bin=trunc(20*(freq_f-0.00001))+1)
u1.m=u1 %>% group_by(bin) %>% summarize(av=mean(u_nsl_f),std=sd(u_nsl_f))
u1=left_join(u1,u1.m,key=bin)
u1 = u1 %>% mutate(nsl_f=(u_nsl_f-av)/std)
# standardized nSL X
u2=u %>% filter(chr>29) %>% mutate(bin=trunc(10*(freq_f-0.00001))+1)
u2.m=u2 %>% group_by(bin) %>% summarize(av=mean(u_nsl_f),std=sd(u_nsl_f))
u2=left_join(u2,u2.m,key=bin)
u2 = u2 %>% mutate(nsl_f=(u_nsl_f-av)/std)
# merge agin
u=rbind(u1,u2)

# check distribution
p=ggplot(u,aes(x=nsl_f))+geom_histogram()+theme_bw()
ggsave(paste(mydir,'/results/nSL/nSL_hist.png',sep=''),plot = p, width = 4, height = 4)
p=ggplot(u,aes(x=nsl_f))+geom_histogram()+theme_bw()+facet_wrap(~bin)
ggsave(paste(mydir,'/results/nSL/nSL_hist_bybin.png',sep=''),plot = p, width = 4, height = 4)

# positions common with chip
v=read.table(paste(mydir,'/plink_files/common_auto_gen4.snp',sep=''),head=F)
colnames(v)=c('snp')
vtemp=read.table(paste(mydir,'/plink_files/common_X_gen4.snp',sep=''),head=F)
colnames(vtemp)=c('snp')
v=rbind(v,vtemp)
u1 = u %>% filter(snp %in% v$snp) %>% mutate(type='common')
u2 = u %>% filter(!snp %in% v$snp) %>% mutate(type='other')
u=rbind(u1,u2)

# save
u = u %>% select(chr,pos,snp,nsl_f,type)
write.table(u,file=paste(mydir,'/results/nSL/nSL_all.txt',sep=''),quote=F,col.names=T,row.names=F)

u = u %>% filter(type=='common') %>% select(chr,pos,snp,nsl_f)
write.table(u,file=paste(mydir,'/results/nSL/nSL_common.txt',sep=''),quote=F,col.names=T,row.names=F)

