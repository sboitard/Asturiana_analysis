library(NB)

args <- commandArgs(TRUE)
mydir=args[1]
p=as.integer(args[2])

# run NB
infileNB=paste(mydir,'/results/time_series/chip_auto_gen4_unrelated_NBinput.txt', sep = '')
res=NB.estimator(infile=infileNB,alleles=rep(2,p),sample.interval=2:8,bound=c(10,10000))
res

# plot
#NB.plot.likelihood(infile=infileNB,alleles=rep(2,p),sample.interval=2:8,lb=10,ub=2000,step=100)





