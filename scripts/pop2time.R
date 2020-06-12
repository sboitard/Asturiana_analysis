library(dplyr)
library(tidyr)
library(ggplot2)

args <- commandArgs(TRUE)
filename=args[1]
mydir=args[2]
G=as.integer(args[3]) # generation time

# load and merge data
u=read.table(paste(mydir,'/input_files/birth_dates.txt',sep=''),header=T)
fam=read.table(paste(mydir,'/plink_files/',filename,'.fam',sep=''))
colnames(fam)=c('pop','indiv','father','mother','sex','pheno')
res=left_join(fam,u)

# define generations
res=res %>% mutate(generation=0)
m=min(res$year)
M=max(res$year)

deb=m
i=1
while (deb<=M){
	ind=which((res$year >= deb) & (res$year < deb+G))
	res[ind,'generation']=i
	i=i+1
	deb=deb+G
}

# check distribution by generation
table(res$generation)

# save results
write.table(cbind(res[,8],res[,2:6]),file=paste(mydir,'/plink_files/',filename,'_gen',G,'.fam',sep=''),quote=F,col.names=F,row.names=F)
