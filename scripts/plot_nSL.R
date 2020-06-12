library(dplyr)
library(tidyr)
library(ggplot2)
library(data.table)

args <- commandArgs(TRUE)
mydir=args[1]

u=fread(paste(mydir,'/results/nSL/nSL_all.txt',sep=''),head=T)
u$type=factor(u$type,levels=c('other','common'))

M=max(u$nsl_f)
# plot chr1 to chr12
utemp = u %>% filter(chr<=12)
p=ggplot(utemp,aes(x=pos,y=nsl_f,color=type,alpha=type))+geom_point()+theme_bw()+facet_wrap(~chr,scales='free')+ylim(0,M) + scale_alpha_manual(guide='none', values = list(other = 0.1, common = 1))
ggsave(paste(mydir,'/results/nSL/nSL_man1.jpg',sep=''),plot = p, width = 12, height = 6)

# plot chr13 to chr24
utemp = u %>% filter((chr>=13)&(chr<=24)) 
p=ggplot(utemp,aes(x=pos,y=nsl_f,color=type,alpha=type))+geom_point()+theme_bw()+facet_wrap(~chr,scales='free')+ylim(0,M) + scale_alpha_manual(guide='none', values = list(other = 0.1, common = 1))
ggsave(paste(mydir,'/results/nSL/nSL_man2.jpg',sep=''),plot = p, width = 12, height = 6)

# plot chr25 to chr29
utemp = u %>% filter(chr>=25)
p=ggplot(utemp,aes(x=pos,y=nsl_f,color=type,alpha=type))+geom_point()+theme_bw()+facet_wrap(~chr,scales='free')+ylim(0,M) + scale_alpha_manual(guide='none', values = list(other = 0.1, common = 1))
ggsave(paste(mydir,'/results/nSL/nSL_man3.jpg',sep=''),plot = p, width = 9, height = 3)

