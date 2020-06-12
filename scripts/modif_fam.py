import sys
infile_name=sys.argv[1] # fam file to be modified
outfile_name=infile_name+'2'
fam_name=sys.argv[2] # new family name
sex=sys.argv[3] # new sex code (0 if unchanged)

f=open(outfile_name,'w')

for line in open(infile_name):
    buf=line.split()
    if sex=='0':
    	f.write(fam_name+' '+buf[1]+' 0 0 '+buf[4]+' -9\n')
    else:
	f.write(fam_name+' '+buf[1]+' 0 0 '+sex+' -9\n')

