import sys
infile_name=sys.argv[1]
n=int(sys.argv[2])
outfile_name=infile_name+'2'

outfile=open(outfile_name,'w')
for line in open(infile_name):
    buf=line.split()
    try:
    	outfile.write(buf[0]+' '+buf[1]+' '+str(int(buf[2])-n)+' '+buf[3]+' '+buf[4]+' '+buf[5]+' '+buf[6]+' '+buf[7]+' '+'\n')
    except ValueError:
	outfile.write(line)
    
