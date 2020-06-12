myfolder=$1

# NGS filtering
plink --bfile $myfolder/input_files/image_X --set-hh-missing --out $myfolder/plink_files/image_X_hom --cow --make-bed
plink --bfile $myfolder/plink_files/image_X_hom --missing --out $myfolder/plink_files/image_X_hom --cow
plink --bfile $myfolder/plink_files/image_X_hom --geno 0.4 --out $myfolder/plink_files/image_X_cr --cow --make-bed

# 50K filtering
plink --tfile $myfolder/input_files/chip50 --chr 30 --to-mb 137 --set-hh-missing --out $myfolder/plink_files/chip50_X_hom --cow --make-bed
plink --bfile $myfolder/plink_files/chip50_X_hom --geno 0.05 --out $myfolder/plink_files/chip50_X --cow --make-bed
cut -f 2 $myfolder/plink_files/chip50_X.bim > $myfolder/plink_files/chip50_X.snp

# 800K filtering
plink --tfile $myfolder/input_files/chip800 --chr 30 --to-mb 137 --set-hh-missing --out $myfolder/plink_files/chip800_X_hom --cow --make-bed
plink --bfile $myfolder/plink_files/chip800_X_hom --geno 0.05 --out $myfolder/plink_files/chip800_X --cow --make-bed
cut -f 2 $myfolder/plink_files/chip800_X.bim > $myfolder/plink_files/chip800_X.snp

# merging 50K and 800K
plink --bfile $myfolder/plink_files/chip50_X --bmerge $myfolder/plink_files/chip800_X --out $myfolder/plink_files/chip_X --cow
# common positions
plink --bfile $myfolder/plink_files/chip_X --cow --make-bed --out $myfolder/plink_files/chip_X_temp --extract $myfolder/plink_files/chip50_X.snp
plink --bfile $myfolder/plink_files/chip_X_temp --cow --make-bed --out $myfolder/plink_files/chip_X --extract $myfolder/plink_files/chip800_X.snp
cut -f2 $myfolder/plink_files/chip_X.bim > $myfolder/plink_files/chip_X.snp

# merging chip and NGS
plink --bfile $myfolder/plink_files/image_X_cr --extract $myfolder/plink_files/chip_X.snp --out $myfolder/plink_files/image_X_chip --cow --make-bed
plink --bfile $myfolder/plink_files/chip_X --bmerge $myfolder/plink_files/image_X_chip --out $myfolder/plink_files/common --cow
plink --bfile $myfolder/plink_files/chip_X --flip $myfolder/plink_files/common.missnp --make-bed --out $myfolder/plink_files/chip_trial --cow
plink --bfile $myfolder/plink_files/image_X_chip --bmerge $myfolder/plink_files/chip_trial --make-bed --out $myfolder/plink_files/common_trial --cow
# common positions
cut -f2 $myfolder/plink_files/image_X_chip.bim > $myfolder/plink_files/image_X_chip.snp
plink --bfile $myfolder/plink_files/common_trial --extract $myfolder/plink_files/image_X_chip.snp --out $myfolder/plink_files/common_X --cow --make-bed

# PCA check
plink --bfile $myfolder/plink_files/common_X --ibs-matrix --out $myfolder/plink_files/common_X_test --chr-set 30
R -f $myfolder/scripts/script_IBS.R --args common_X_test $myfolder
plink --bfile $myfolder/plink_files/common_X --ibs-matrix --out $myfolder/plink_files/common_X_test_males --filter-males --chr-set 30 
R -f $myfolder/scripts/script_IBS.R --args common_X_test_males $myfolder

# cleaning
rm $myfolder/plink_files/*.missnp
rm $myfolder/plink_files/*.log
rm $myfolder/plink_files/*temp*
rm $myfolder/plink_files/*trial*
rm $myfolder/plink_files/common.*
rm $myfolder/plink_files/*hom*
rm $myfolder/plink_files/*test*

