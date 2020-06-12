myfolder=$1

# histogram of birth dates
R -f $myfolder/scripts/histo_birth.R --args $myfolder

# cluster into generations - common markers
R -f $myfolder/scripts/pop2time.R --args common_auto $myfolder 4
cp $myfolder/plink_files/common_auto.bed $myfolder/plink_files/common_auto_gen4.bed
cp $myfolder/plink_files/common_auto.bim $myfolder/plink_files/common_auto_gen4.bim

# filter out related individual - common markers
plink --bfile $myfolder/plink_files/common_auto_gen4 --ibs-matrix --out $myfolder/plink_files/common_auto_gen4 --cow
gcta64 --bfile $myfolder/plink_files/common_auto_gen4 --make-grm-gz --autosome-num 29 --maf 0.1 --out $myfolder/plink_files/common_auto_gen4
gunzip $myfolder/plink_files/common_auto_gen4.grm.gz
R -f $myfolder/scripts/rm_rel.R --args common_auto_gen4 $myfolder
plink --bfile $myfolder/plink_files/common_auto_gen4 --keep $myfolder/plink_files/common_auto_gen4_unrelated.indiv --cow --make-bed --out $myfolder/plink_files/common_auto_gen4_unrelated

# time series analysis - common markers
plink --bfile $myfolder/plink_files/common_auto_gen4_unrelated --freq --family --out $myfolder/plink_files/common_auto_gen4_unrelated --cow
python $myfolder/scripts/shift_generation.py $myfolder/plink_files/common_auto_gen4_unrelated.frq.strat 2
mv $myfolder/plink_files/common_auto_gen4_unrelated.frq.strat2 $myfolder/plink_files/common_auto_gen4_unrelated.frq.strat
python3 $myfolder/compareHMM/src/run_rd_analyzer.py -N 800 --infile $myfolder/plink_files/common_auto_gen4_unrelated.frq.strat --outfile $myfolder/results/time_series/common_auto_gen4.csv --times 0 1 2 3 4 5 6 7 # can be run in parallel after decomposing the data in different snp sets

# cluster into generations - all chip markers
R -f $myfolder/scripts/pop2time.R --args chip_auto $myfolder 4
cp $myfolder/plink_files/chip_auto.bed $myfolder/plink_files/chip_auto_gen4.bed
cp $myfolder/plink_files/chip_auto.bim $myfolder/plink_files/chip_auto_gen4.bim

# filter out related individual - all chip markers
plink --bfile $myfolder/plink_files/chip_auto_gen4 --ibs-matrix --out $myfolder/plink_files/chip_auto_gen4 --cow
gcta64 --bfile $myfolder/plink_files/chip_auto_gen4 --make-grm-gz --autosome-num 29 --maf 0.1 --out $myfolder/plink_files/chip_auto_gen4
gunzip $myfolder/plink_files/chip_auto_gen4.grm.gz
R -f $myfolder/scripts/rm_rel.R --args chip_auto_gen4 $myfolder
plink --bfile $myfolder/plink_files/chip_auto_gen4 --keep $myfolder/plink_files/chip_auto_gen4_unrelated.indiv --cow --make-bed --out $myfolder/plink_files/chip_auto_gen4_unrelated

# time series analysis - chip specific markers
cut -f 2 $myfolder/plink_files/common_auto_gen4.bim > $myfolder/plink_files/common_auto_gen4.snp
plink --bfile $myfolder/plink_files/chip_auto_gen4_unrelated --exclude $myfolder/plink_files/common_auto_gen4.snp --make-bed --cow --out $myfolder/plink_files/chip_only_auto_gen4_unrelated
plink --bfile $myfolder/plink_files/chip_only_auto_gen4_unrelated --freq --family --out $myfolder/plink_files/chip_only_auto_gen4_unrelated --cow
python $myfolder/scripts/shift_generation.py $myfolder/plink_files/chip_only_auto_gen4_unrelated.frq.strat 2
mv $myfolder/plink_files/chip_only_auto_gen4_unrelated.frq.strat2 $myfolder/plink_files/chip_only_auto_gen4_unrelated.frq.strat
python3 $myfolder/compareHMM/src/run_rd_analyzer.py -N 800 --infile $myfolder/plink_files/chip_only_auto_gen4_unrelated.frq.strat --outfile $myfolder/results/time_series/chip_only_auto_gen4.csv --times 0 1 2 3 4 5 6 # can be run in parallel after decomposing the data in different snp sets

# cleaning
rm $myfolder/plink_files/*.log
rm $myfolder/plink_files/*grm*


