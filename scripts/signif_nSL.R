library(dplyr)
library(tidyr)
library(ggplot2)
library(data.table)

args <- commandArgs(TRUE)
mydir=args[1]
thres=as.integer(args[2]) # nSL threshold
snp_thres=as.integer(args[3]) # nb of significant SNPs threshold

u=fread(paste(mydir,'/results/nSL/nSL_all.txt',sep=''),head=T)

# significant SNPs
utemp = u %>% filter(nsl_f >=thres) %>% arrange(chr,pos)
write.table(utemp,file=paste(mydir,'/results/nSL/nSL_sig',thres,'.txt',sep=''),quote=F,row.names=F,col.names=T)

# significant regions
utemp=utemp %>% mutate(region=1)
reg_temp=1
for (i in 2:dim(utemp)[1]){
	if ((utemp$chr[i]!=utemp$chr[i-1])|(utemp$pos[i]>(utemp$pos[i-1]+1000000))){
		reg_temp=reg_temp+1
	} 
	utemp$region[i]=reg_temp
}

# all regions with more than 10 SNPs
reg=utemp %>% group_by(region) %>% summarize(chr=mean(chr),beg=min(pos),end=max(pos),nb_snp=length(pos))
reg = reg %>% filter(nb_snp>=snp_thres) %>% mutate(L=end-beg) %>% select(chr,beg,end,L,nb_snp)
write.table(reg,file=paste(mydir,'/results/nSL/nSL_sig',thres,'_snp',snp_thres,'.txt',sep=''),quote=F,row.names=F,col.names=T)


