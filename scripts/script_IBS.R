library(dplyr)
library(tidyr)
library(ggplot2)
library(gridExtra)

args <- commandArgs(TRUE)
filename=args[1]
mydir=args[2]

matrice_IBS=1-read.table(paste(mydir,'/plink_files/',filename,'.mibs',sep=""),stringsAsFactors=F)
ped=read.table(paste(mydir,'/plink_files/',filename,'.mibs.id',sep=""),stringsAsFactors=F)

# MDS analysis
mds=cmdscale(matrice_IBS,k=4)
res=cbind(ped,mds)
colnames(res)=c('technology','indiv',paste('C',1:4,sep=''))
ind=which(res$technology=='chip50')
res$technology[ind]='50K'
ind=which(res$technology=='chip800')
res$technology[ind]='800K'
ind=which(res$technology=='image')
res$technology[ind]='NGS'

p=ggplot(res,aes(x=C1,y=C2,colour=technology))+geom_point(alpha=0.5)+theme_bw()
ggsave(paste(mydir,'/results/filtering/',filename,'.png',sep=''), plot = p, width = 5, height = 4)


