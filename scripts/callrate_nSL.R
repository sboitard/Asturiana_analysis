library(dplyr)
library(tidyr)
library(ggplot2)

args <- commandArgs(TRUE)
mydir=args[1]

# import plink .lmiss files
# chr 1
u=read.table(paste(mydir,'/results/nSL/image_cr2_1.lmiss',sep=''),head=T)
u = u %>% select(SNP,N_MISS) %>% separate(SNP,into=c('chr','pos'))
# other autosomes
for (i in 2:29){
	utemp=read.table(paste(mydir,'/results/nSL/image_cr2_',i,'.lmiss',sep=''),head=T)
	utemp = utemp %>% select(SNP,N_MISS) %>% separate(SNP,into=c('chr','pos'))
	u=rbind(u,utemp)
}

# import regions
#reg=read.table(paste(mydir,'/results/nSL/nSL_sig6_snp10.txt',sep=''),head=T)
reg=read.table(paste(mydir,'/results/nSL/nSL_tab2.txt',sep=''),head=T)
reg=reg%>%select(chr,beg,end) %>% mutate(miss=0)
for (i in 1:dim(reg)[1]){
	utemp=u%>%filter(chr==reg$chr[i] & pos>=reg$beg[i] & pos<=reg$end[i])
	reg$miss[i]=mean(utemp$N_MISS)
}
reg=rbind(reg,c(0,0,0,mean(u$N_MISS)))

# save
#write.table(reg,file=paste(mydir,'/results/nSL/nSL_sig6_snp10_miss.txt',sep=''),quote=F,col.names=T,row.names=F)
write.table(reg,file=paste(mydir,'/results/nSL/nSL_tab2_miss.txt',sep=''),quote=F,col.names=T,row.names=F)


