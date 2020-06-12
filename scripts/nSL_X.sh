myfolder=$1

# filters ngs data on callrate - 5 missing individuals allowed
plink --bfile $myfolder/input_files/image_X --set-hh-missing --out $myfolder/plink_files/image_X_hom --cow --make-bed
plink --bfile $myfolder/plink_files/image_X_hom --geno 0.34 --out $myfolder/results/nSL/image_cr2_X --cow --make-bed

# phase genotypes and inpute missing data
shapeit --input-bed $myfolder/results/nSL/image_cr2_X --effective-size 1000 --rho 0.00004 --output-max $myfolder/results/nSL/image_cr2_X -W 5 --force --chrX

# converts output to vcf
head -n 9 $myfolder/results/nSL/image_cr2_X.sample > $myfolder/results/nSL/image_cr2_X_modif.sample
cut -d" " -f 1-6,8,10,12,14,16,18,20,22,24,26,28,30,32 $myfolder/results/nSL/image_cr2_X.haps > $myfolder/results/nSL/image_cr2_X_modif.haps
shapeit -convert --input-haps $myfolder/results/nSL/image_cr2_X_modif --output-vcf $myfolder/results/nSL/image_cr2_X_modif.vcf
cut -f 1-3 $myfolder/results/nSL/image_cr2_X_modif.vcf > $myfolder/results/nSL/image_cr2_X.pos

# run selscan
selscan --nsl --vcf $myfolder/results/nSL/image_cr2_X_modif.vcf --out $myfolder/results/nSL/image_cr2_X --max-extend-nsl 10000

# cleaning
rm $myfolder/shapeit*
rm $myfolder/results/nSL/*X.log
rm $myfolder/results/nSL/*X.bed
rm $myfolder/results/nSL/*X.bim
rm $myfolder/results/nSL/*X.fam
rm $myfolder/results/nSL/*X.vcf
rm $myfolder/results/nSL/*X.hh
