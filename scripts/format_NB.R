library(dplyr)
library(data.table)

args <- commandArgs(TRUE)
mydir=args[1]

# load frequency file
namefile <- paste(mydir,'/plink_files/chip_auto_gen4_unrelated.frq.strat',sep='')
df <- fread(namefile, header = T)

## optionnal filters on SNP set

# no filter
#dfsnp=df %>% sample_n(10000)
#df = df %>% filter(SNP %in% dfsnp$SNP)
#$N 407.8783, $CI 367.0122 458.1865


# high MAF in G2
#dfsnp=df %>% filter(CLST==2 & MAF>=0.2 & MAF<=0.8) %>% sample_n(1000)
#df = df %>% filter(SNP %in% dfsnp$SNP)

# all poly in G2
#dfsnp=df %>% filter(CLST==2 & MAF>0 & MAF<1)
#df = df %>% filter(SNP %in% dfsnp$SNP)

# gen 4 to 7, maf 5%
#df= df %>% filter(CLST>=4 & CLST<=7)
#dfsnp=df %>% filter(CLST==4 & MAF>=0.05 & MAF<=0.95) %>% sample_n(1000)
#df = df %>% filter(SNP %in% dfsnp$SNP)

# gen 4 to 7, no filter
#df= df %>% filter(CLST>=4 & CLST<=7)
#dfsnp=df %>% sample_n(1000)
#df = df %>% filter(SNP %in% dfsnp$SNP)

# gen 4 and more, all snps
#df= df %>% filter(CLST>=4)
#dfsnp=df %>% filter(CLST==4 & MAF>0 & MAF<1)
#df = df %>% filter(SNP %in% dfsnp$SNP)

#for (i in 4:8){
#	dftemp= df %>% filter(CLST==i)
#	dftemp = dftemp %>% filter(NCHROBS==max(dftemp$NCHROBS))	
# 	df = df %>% filter(SNP %in% dftemp$SNP)
#}

# gen 4 and more, maf 20%
#df= df %>% filter(CLST>=4)
#dfsnp=df %>% filter(CLST==4 & MAF>=0.2 & MAF<=0.8) %>% sample_n(1000)
#df = df %>% filter(SNP %in% dfsnp$SNP)

# gen 4 and more, overall maf 5%
#df= df %>% filter(CLST>=4 & CLST<=7)
#dfsnp = df %>% group_by(SNP) %>% summarise(mean = mean(MAF)) %>% filter(mean > 0.05 & mean < 0.95) %>% sample_n(1000)
#df = df %>% filter(SNP %in% dfsnp$SNP)


# overall maf 20%
#dfsnp = df %>% group_by(SNP) %>% summarise(mean = mean(MAF)) %>% filter(mean > 0.20 & mean < 0.80) %>% sample_n(1000)
#df = df %>% filter(SNP %in% dfsnp$SNP)

# overall maf 5%
#dfsnp = df %>% group_by(SNP) %>% summarise(mean = mean(MAF)) %>% filter(mean > 0.05 & mean < 0.95) %>% sample_n(1000)
#df = df %>% filter(SNP %in% dfsnp$SNP)

# overall maf >0
#dfsnp = df %>% group_by(SNP) %>% summarise(mean = mean(MAF)) %>% filter(mean > 0 & mean < 1)
#df = df %>% filter(SNP %in% dfsnp$SNP)

# put at NB format and export
df$CAM <- df$NCHROBS - df$MAC
df = df %>% arrange(CLST,SNP)
#for (i in c(2,8)){
for (i in 2:8){
	infileNB=paste(mydir,'/results/time_series/chip_auto_gen4_unrelated_NBinput_G',i,'.txt', sep = '')
	dftemp= df %>% filter(CLST==i)
	print(head(dftemp))
	print(tail(dftemp))	
 	dftemp = dftemp %>% select(MAC,CAM)
	write.table(dftemp,infileNB,col.names = FALSE,row.names = FALSE)
}






