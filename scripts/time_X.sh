myfolder=$1

# cluster into generations - common markers
cp $myfolder/plink_files/common_auto_gen4.fam $myfolder/plink_files/common_X_gen4.fam
cp $myfolder/plink_files/common_X.bed $myfolder/plink_files/common_X_gen4.bed
cp $myfolder/plink_files/common_X.bim $myfolder/plink_files/common_X_gen4.bim

# filter out related individual - common markers
plink --bfile $myfolder/plink_files/common_X_gen4 --keep $myfolder/plink_files/common_auto_gen4_unrelated.indiv --cow --make-bed --out $myfolder/plink_files/common_X_gen4_unrelated

# time series analysis - common markers
plink --bfile $myfolder/plink_files/common_X_gen4_unrelated --freq --family --out $myfolder/plink_files/common_X_gen4_unrelated --cow
python $myfolder/scripts/shift_generation.py $myfolder/plink_files/common_X_gen4_unrelated.frq.strat 2
mv $myfolder/plink_files/common_X_gen4_unrelated.frq.strat2 $myfolder/plink_files/common_X_gen4_unrelated.frq.strat
python3 $myfolder/compareHMM/src/run_rd_analyzer.py -N 600 --infile $myfolder/plink_files/common_X_gen4_unrelated.frq.strat --outfile $myfolder/results/time_series/common_X_gen4.csv --times 0 1 2 3 4 5 6 7 # can be run in parallel after decomposing the data in different snp sets

# cluster into generations - all chip markers
cp $myfolder/plink_files/chip_auto_gen4.fam $myfolder/plink_files/chip_X_gen4.fam
cp $myfolder/plink_files/chip_X.bed $myfolder/plink_files/chip_X_gen4.bed
cp $myfolder/plink_files/chip_X.bim $myfolder/plink_files/chip_X_gen4.bim

# filter out related individual - all chip markers
plink --bfile $myfolder/plink_files/chip_X_gen4 --keep $myfolder/plink_files/chip_auto_gen4_unrelated.indiv --cow --make-bed --out $myfolder/plink_files/chip_X_gen4_unrelated

# time series analysis - chip specific markers
cut -f 2 $myfolder/plink_files/common_X_gen4.bim > $myfolder/plink_files/common_X_gen4.snp
plink --bfile $myfolder/plink_files/chip_X_gen4_unrelated --exclude $myfolder/plink_files/common_X_gen4.snp --make-bed --cow --out $myfolder/plink_files/chip_only_X_gen4_unrelated
plink --bfile $myfolder/plink_files/chip_only_X_gen4_unrelated --freq --family --out $myfolder/plink_files/chip_only_X_gen4_unrelated --cow
python $myfolder/scripts/shift_generation.py $myfolder/plink_files/chip_only_X_gen4_unrelated.frq.strat 2
mv $myfolder/plink_files/chip_only_X_gen4_unrelated.frq.strat2 $myfolder/plink_files/chip_only_X_gen4_unrelated.frq.strat
python3 $myfolder/compareHMM/src/run_rd_analyzer.py -N 600 --infile $myfolder/plink_files/chip_only_X_gen4_unrelated.frq.strat --outfile $myfolder/results/time_series/chip_only_X_gen4.csv --times 0 1 2 3 4 5 6 # can be run in parallel after decomposing the data in different snp sets

# cleaning
rm $myfolder/plink_files/*.log
rm $myfolder/plink_files/*grm*

