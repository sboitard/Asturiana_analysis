import sys
mydir=sys.argv[1]

outfile=open(mydir+'/results/time_series/chip_auto_gen4_unrelated_NBinput.txt','w')
for i in range(2,9):
#for i in [2,8]:
    for line in open(mydir+'/results/time_series/chip_auto_gen4_unrelated_NBinput_G'+str(i)+'.txt'):
	outfile.write(line)
    outfile.write('\n')
