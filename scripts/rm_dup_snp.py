import sys
infile_name=sys.argv[1] # tped file to be modified
outfile_name=infile_name+'2'

chro=''
pos=''

outfile=open(outfile_name,'w')
for line in open(infile_name):
    buf=line.split()
    if buf[0]==chro and buf[3]==pos:
	print chro+':'+str(pos)
    else:
	outfile.write(line)
	chro=buf[0]
	pos=buf[3]
