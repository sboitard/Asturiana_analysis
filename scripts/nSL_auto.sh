# this file describes the analyzes for a single chromosome. All chromosomes can (should) be analyzed in parallel.
chro=$1
myfolder=$2

# filters ngs data on callrate - 5 missing individuals allowed
plink --bfile $myfolder/input_files/image_auto --geno 0.34 --chr $chro --out $myfolder/results/nSL/image_cr2_$chro --cow --make-bed

# stores call rate at remaining sites
plink --bfile $myfolder/results/nSL/image_cr2_$chro --out $myfolder/results/nSL/image_cr2_$chro --cow --missing

# phase genotypes and inpute missing data - SHAPEIT2.v790 was used in our study
shapeit --input-bed $myfolder/results/nSL/image_cr2_$chro --effective-size 1000 --rho 0.00004 --output-max $myfolder/results/nSL/image_cr2_$chro -W 5 --force

# converts output to vcf
shapeit -convert --input-haps $myfolder/results/nSL/image_cr2_${chro} --output-vcf $myfolder/results/nSL/image_cr2_${chro}.vcf
cut -f 1-3 $myfolder/results/nSL/image_cr2_${chro}.vcf > $myfolder/results/nSL/image_cr2_${chro}.pos

# run selscan
selscan --nsl --vcf $myfolder/results/nSL/image_cr2_${chro}.vcf --out $myfolder/results/nSL/image_cr2_${chro} --max-extend-nsl 10000

# cleaning
# rm $myfolder/shapeit*
rm $myfolder/results/nSL/*_${chro}.log
rm $myfolder/results/nSL/*_${chro}.bed
rm $myfolder/results/nSL/*_${chro}.bim
rm $myfolder/results/nSL/*_${chro}.fam
rm $myfolder/results/nSL/*_${chro}.vcf
rm $myfolder/results/nSL/*_${chro}.hh

