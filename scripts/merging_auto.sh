myfolder=$1

# NGS filtering
plink --bfile $myfolder/input_files/image_auto --missing --out $myfolder/plink_files/image_auto --cow
plink --bfile $myfolder/input_files/image_auto --geno 0.4 --out $myfolder/plink_files/image_auto_cr --cow --make-bed

# 50K filtering
plink --tfile $myfolder/input_files/chip50 --chr 1-29 --geno 0.05 --out $myfolder/plink_files/chip50_auto --cow --make-bed
cut -f 2 $myfolder/plink_files/chip50_auto.bim > $myfolder/plink_files/chip50_auto.snp

# 800K filtering
plink --tfile $myfolder/input_files/chip800 --chr 1-29 --geno 0.05 --out $myfolder/plink_files/chip800_auto --cow --make-bed
cut -f 2 $myfolder/plink_files/chip800_auto.bim > $myfolder/plink_files/chip800_auto.snp

# merging 50K and 800K
plink --bfile $myfolder/plink_files/chip50_auto --bmerge $myfolder/plink_files/chip800_auto --out $myfolder/plink_files/chip_auto --cow
plink --bfile $myfolder/plink_files/chip50_auto --exclude $myfolder/plink_files/chip_auto.missnp --out $myfolder/plink_files/chip50_auto_temp --make-bed --cow 
plink --bfile $myfolder/plink_files/chip800_auto --exclude $myfolder/plink_files/chip_auto.missnp --out $myfolder/plink_files/chip800_auto_temp --make-bed --cow 
plink --bfile $myfolder/plink_files/chip50_auto_temp --bmerge $myfolder/plink_files/chip800_auto_temp --out $myfolder/plink_files/chip_auto --cow
# common positions
plink --bfile $myfolder/plink_files/chip_auto --cow --make-bed --out $myfolder/plink_files/chip_auto_temp --extract $myfolder/plink_files/chip50_auto.snp
plink --bfile $myfolder/plink_files/chip_auto_temp --cow --make-bed --out $myfolder/plink_files/chip_auto --extract $myfolder/plink_files/chip800_auto.snp
cut -f2 $myfolder/plink_files/chip_auto.bim > $myfolder/plink_files/chip_auto.snp

# merging chip and NGS
plink --bfile $myfolder/plink_files/image_auto_cr --extract $myfolder/plink_files/chip_auto.snp --out $myfolder/plink_files/image_auto_chip --cow --make-bed
plink --bfile $myfolder/plink_files/chip_auto --bmerge $myfolder/plink_files/image_auto_chip --out $myfolder/plink_files/common --cow
plink --bfile $myfolder/plink_files/chip_auto --flip $myfolder/plink_files/common.missnp --make-bed --out $myfolder/plink_files/chip_trial --cow
plink --bfile $myfolder/plink_files/image_auto_chip --bmerge $myfolder/plink_files/chip_trial --make-bed --out $myfolder/plink_files/common_trial --cow
plink --bfile $myfolder/plink_files/chip_trial --flip $myfolder/plink_files/common_trial-merge.missnp --make-bed --out $myfolder/plink_files/chip_corrected --cow
plink --bfile $myfolder/plink_files/chip_corrected --bmerge $myfolder/plink_files/image_auto_chip --out $myfolder/plink_files/common --cow
plink --bfile $myfolder/plink_files/chip_corrected --exclude $myfolder/plink_files/common.missnp --cow --make-bed --out $myfolder/plink_files/chip_corrected_temp
plink --bfile $myfolder/plink_files/image_auto_chip --exclude $myfolder/plink_files/common.missnp --cow --make-bed --out $myfolder/plink_files/image_chip_temp
plink --bfile $myfolder/plink_files/chip_corrected_temp --bmerge $myfolder/plink_files/image_chip_temp --out $myfolder/plink_files/common --cow
# common positions
cut -f2 $myfolder/plink_files/image_auto_chip.bim > $myfolder/plink_files/image_auto_chip.snp
plink --bfile $myfolder/plink_files/common --extract $myfolder/plink_files/image_auto_chip.snp --out $myfolder/plink_files/common_auto --cow --make-bed

# PCA check
plink --bfile $myfolder/plink_files/common_auto --ibs-matrix --out $myfolder/plink_files/common_auto --cow
R -f $myfolder/scripts/script_IBS.R --args common_auto $myfolder

# cleaning
rm $myfolder/plink_files/*.missnp
rm $myfolder/plink_files/*.log
rm $myfolder/plink_files/*temp*
rm $myfolder/plink_files/*trial*
rm $myfolder/plink_files/common.*
rm $myfolder/plink_files/*corrected*
