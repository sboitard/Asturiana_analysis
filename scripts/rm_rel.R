library(dplyr)
library(tidyr)
library(ggplot2)
library(gridExtra)

args <- commandArgs(TRUE)
filename=args[1]
mydir=args[2]

# load input data
grm=read.table(paste(mydir,'/plink_files/',filename,'.grm',sep=''))
colnames(grm)=c('id1','id2','nb_snp','rel')

grm.id=read.table(paste(mydir,'/plink_files/',filename,'.grm.id',sep=''))
colnames(grm.id)=c('generation','indiv')
grm.id = grm.id %>% mutate(id=1:dim(grm.id)[1])

# overall distribution of inbreeding and relatedness
grm.same=grm%>%filter(id1==id2)
p1=ggplot(grm.same,aes(x=rel))+geom_histogram()+theme_bw() +xlab('inbreeding')
grm.diff=grm%>%filter(id1!=id2)
p2=ggplot(grm.diff,aes(x=rel))+geom_histogram()+theme_bw() +xlab('relatedness')
p=grid.arrange(p1, p2, ncol = 2)
ggsave(paste(mydir,'/results/filtering/',filename,'_grm_all.pdf',sep=''), plot = p, width = 8, height = 4)

# remove inbred individuals
inbred.id=grm.same[grm.same$rel>=1.07,'id1'] 
grm.id[inbred.id,]
grm2=grm%>%filter(!id1 %in% inbred.id & !id2 %in% inbred.id)
grm2.same=grm2%>%filter(id1==id2)
p1=ggplot(grm2.same,aes(x=rel))+geom_histogram()+theme_bw() +xlab('inbreeding')
grm2.diff=grm2%>%filter(id1!=id2)
p2=ggplot(grm2.diff,aes(x=rel))+geom_histogram()+theme_bw() +xlab('relatedness')
p=grid.arrange(p1, p2, ncol = 2)
ggsave(paste(mydir,'/results/filtering/',filename,'_grm_noinbred.pdf',sep=''), plot = p, width = 8, height = 4)

# relatedness by generation
gene.id=grm.id[grm.id$generation==1,'id']
gene.grm=grm2%>%filter(id1 %in% gene.id & id2 %in% gene.id)%>%mutate(generation=1)
for (i in 2:max(grm.id[,1])){
	gene.id=grm.id[grm.id$generation==i,'id']
	gene.grm=rbind(gene.grm,grm2%>%filter(id1 %in% gene.id & id2 %in% gene.id)%>%mutate(generation=i))
}
gene.grm.diff=gene.grm%>%filter(id1!=id2)
p=ggplot(gene.grm.diff,aes(x=rel))+geom_histogram()+theme_bw() +xlab('relatedness')+facet_wrap(~generation)
ggsave(paste(mydir,'/results/filtering/',filename,'_grm_noinbred_bygen.pdf',sep=''), plot = p, width = 8, height = 8)

# remove related individuals
for (i in 1:max(grm.id[,1])){
	grm.temp=gene.grm.diff%>%filter(generation==i & rel>=0.1)
	pb=dim(grm.temp)[1]
	while (pb>0){		
		a=table(c(as.vector(grm.temp$id1),as.vector(grm.temp$id2)))
		idrem=as.integer(names(a)[which.max(a)])
		gene.grm.diff=gene.grm.diff%>%filter(id1!=idrem & id2!=idrem)
		grm.temp=gene.grm.diff%>%filter(generation==i & rel>=0.1)
		pb=dim(grm.temp)[1]
	}
}
p=ggplot(gene.grm.diff,aes(x=rel))+geom_histogram()+theme_bw() +xlab('relatedness')+facet_wrap(~generation)
ggsave(paste(mydir,'/results/filtering/',filename,'_grm_noinbred_norel.pdf',sep=''), plot = p, width = 8, height = 8)

# final sampling
idkeep=unique(c(as.vector(gene.grm.diff$id1),as.vector(gene.grm.diff$id2)))
grm.id.keep=grm.id %>% filter(id %in% idkeep)
table(grm.id.keep$generation)
table(grm.id$generation)
write.table(grm.id.keep[,1:2],col.names=F,row.names=F,quote=F,file=paste(mydir,'/plink_files/',filename,'_unrelated.indiv',sep=''))

