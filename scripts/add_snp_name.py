import sys
infile_name=sys.argv[1] # bim file to be modified
outfile_name=infile_name+'2'
ref_file_name=sys.argv[2] # reference file with snp names

# choose reference file for snp names
dic={}
for line in open(ref_file_name):
    buf=line.split()
    if buf[4]=='X':
    	dic['30:'+buf[5]]=buf[1]
    else:
	dic[buf[4]+':'+buf[5]]=buf[1]

outfile=open(outfile_name,'w')
for line in open(infile_name):
    buf=line.split()
    snp=buf[0]+':'+buf[3]
    if dic.has_key(snp):
	outfile.write(buf[0]+' '+dic[snp]+' '+buf[2]+' '+buf[3]+' '+buf[4]+' '+buf[5]+'\n')
    else:
	outfile.write(buf[0]+' '+snp+' '+buf[2]+' '+buf[3]+' '+buf[4]+' '+buf[5]+'\n')
