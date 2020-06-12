import sys
infile_name=sys.argv[1] # tped file to be corrected
outfile_name=infile_name+'2'
ref_file_name=sys.argv[2] # reference file with snp names

dic={}
for line in open(ref_file_name):
    buf=line.split()
    if buf[1]!='NULL' and buf[4]!='99':
    	if buf[3]=='A/C' or buf[3]=='A/G': # remove transversions
	    fw=buf[2].split('/')
    	    top=buf[3].split('/')
    	    dic[buf[6]]=[buf[1],buf[4],buf[5],fw,top]  # name,chr,pos,fw,top
#print str(len(dic))

outfile=open(outfile_name,'w')
notfound=0
for line in open(infile_name):
    buf=line.split()
    snp=buf[1]
    if dic.has_key(snp):
    	n=len(buf)-4
    	# genos
	genos=''
	all_dic={}
	all_dic[dic[snp][4][0]]=dic[snp][3][0] #key=top,value=fw
	all_dic[dic[snp][4][1]]=dic[snp][3][1]
	all_dic['0']='0'
	try:
            for i in range(n):
	    	genos=genos+' '+all_dic[buf[i+4]]
	    outfile.write(dic[snp][1]+' '+dic[snp][0]+' 0 '+dic[snp][2]+genos+'\n')
	except KeyError:
	    print all_dic
	    print buf[:50]
	    pass
    else:
	notfound+=1
print str(notfound)
	    
    
