myfolder=$1
# these variables need to be replaced by the name of input file
myvcf=$myfolder/input_files/asturiana_WGS_SNP.vcf
my50=$myfolder/input_files/asturiana_50K
my800=$myfolder/input_files/asturiana_800K

# NGS data auto
plink --vcf $myvcf --vcf-min-gq 10 --chr-set 29 --biallelic-only strict --allow-extra-chr --make-bed --out $myfolder/input_files/image_auto  --chr 1-29
python $myfolder/scripts/add_snp_name.py $myfolder/input_files/image_auto.bim $myfolder/input_files/SNP50_top.tsv
mv $myfolder/input_files/image_auto.bim2 $myfolder/input_files/image_auto.bim
python $myfolder/scripts/modif_fam.py $myfolder/input_files/image_auto.fam image 1
mv $myfolder/input_files/image_auto.fam2 $myfolder/input_files/image_auto.fam

# NGS data X
plink --vcf $myvcf --vcf-min-gq 5 --chr-set 29 --biallelic-only strict --allow-extra-chr --make-bed --out $myfolder/input_files/image_X  --chr X --to-mb 137
python $myfolder/scripts/add_snp_name.py $myfolder/input_files/image_X.bim $myfolder/input_files/SNP50_top.tsv
mv $myfolder/input_files/image_X.bim2 $myfolder/input_files/image_X.bim
python $myfolder/scripts/modif_fam.py $myfolder/input_files/image_X.fam image 1
mv $myfolder/input_files/image_X.fam2 $myfolder/input_files/image_X.fam

# 50K data
plink --file $my50 --cow --chr 1-30 --recode transpose --out $myfolder/input_files/chip50
python $myfolder/scripts/rm_dup_snp.py $myfolder/input_files/chip50.tped
mv $myfolder/input_files/chip50.tped2 $myfolder/input_files/chip50.tped
python $myfolder/scripts/correc_tped.py $myfolder/input_files/chip50.tped $myfolder/input_files/SNP50_top.tsv
mv $myfolder/input_files/chip50.tped2 $myfolder/input_files/chip50.tped
python $myfolder/scripts/modif_fam.py $myfolder/input_files/chip50.tfam chip50 1
mv $myfolder/input_files/chip50.tfam2 $myfolder/input_files/chip50.tfam

# 800K data
plink --file $my800 --cow --chr 1-30 --recode transpose --filter-founders --out $myfolder/input_files/chip800
python $myfolder/scripts/rm_dup_snp.py $myfolder/input_files/chip800.tped
mv $myfolder/input_files/chip800.tped2 $myfolder/input_files/chip800.tped
python $myfolder/scripts/correc_tped.py $myfolder/input_files/chip800.tped $myfolder/input_files/SNP800_top.tsv
mv $myfolder/input_files/chip800.tped2 $myfolder/input_files/chip800.tped
python $myfolder/scripts/modif_fam.py $myfolder/input_files/chip800.tfam chip800 0
mv $myfolder/input_files/chip800.tfam2 $myfolder/input_files/chip800.tfam

# cleaning
rm $myfolder/input_files/*.nosex
rm $myfolder/input_files/*.log
rm $myfolder/input_files/*.hh

