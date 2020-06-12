library(dplyr)
library(tidyr)
library(ggplot2)

args <- commandArgs(TRUE)
mydir=args[1]

# load data
u=read.table(paste(mydir,'/results/time_series/time_all.txt',sep=''),head=T)
w=read.table(paste(mydir,'/results/nSL/nSL_common.txt',sep=''),head=T)

# comparison of p-values
w = w %>% select(snp,nsl_f) %>% rename(ID=snp)
w=left_join(w,u,key=ID)
p=ggplot(w,aes(x=LR,y=nsl_f))+geom_point(alpha=0.5)+theme_bw()+xlab('HMM Likelihood Ratio Test')+ylab('standardized nSL')
ggsave(paste(mydir,'/results/nSL_vs_time.png',sep=''),plot = p, width = 6, height = 6)

## allele freq trajectories
## Remark : the SNPs represented in this function may slightly differ from those in the paper, 
## as a result of parameter values used while optimizing the HMM likelihood.
f=read.table(paste(mydir,'/plink_files/chip_only_auto_gen4_unrelated.frq.strat',sep=''),head=T) %>% mutate(CLST=CLST+2)
f_im=read.table(paste(mydir,'/plink_files/common_auto_gen4_unrelated.frq.strat',sep=''),head=T) %>% mutate(CLST=CLST+2)
utemp=u %>% arrange(pval_time)
utemp=utemp[1:5,]
wtemp=w %>% arrange(-nsl_f)
wtemp=wtemp[1:5,]
ftemp1=f_im %>% filter(SNP %in% utemp$ID) %>% mutate(test='time series')
ftemp2=f %>% filter(SNP %in% utemp$ID) %>% mutate(test='time series')
ftemp3=f_im %>% filter(SNP %in% wtemp$ID) %>% mutate(test='nSL')
ftemp=rbind(ftemp1,ftemp2,ftemp3)
p=ggplot(ftemp,aes(x=CLST,y=MAF,color=SNP))+geom_line(lwd=1)+theme_bw()+facet_wrap(~test)+xlab('generation')+ylim(0,1)
ggsave(paste(mydir,'/results/allele_traj.png',sep=''),plot = p, width = 10, height = 5)





