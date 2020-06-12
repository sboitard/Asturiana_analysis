library(dplyr)
library(tidyr)
library(ggplot2)

args <- commandArgs(TRUE)
mydir=args[1]

# load and merge data
u=read.table(paste(mydir,'/input_files/birth_dates.txt',sep=''),header=T)
fam=read.table(paste(mydir,'/plink_files/common_auto.fam',sep=''))
colnames(fam)=c('pop','indiv','father','mother','sex','pheno')
res=left_join(fam,u)

p=ggplot(res,aes(x=year,fill=pop))+geom_histogram(alpha=0.5)+theme_bw()
ggsave(paste(mydir,'/results/time_series/histo_birth.png',sep=''), plot = p, width = 5, height = 4)


