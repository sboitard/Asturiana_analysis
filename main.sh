myfolder=/work/sboitard/asturiana/final_analyzes # to be replaced by the path where this file is located

mkdir plink_files
mkdir results
mkdir results/filtering
mkdir results/time_series
mkdir results/nSL

# 0: data preparation 
# this step should be run from the raw data, not provided here
sh scripts/data_preparation.sh $myfolder

# 1a: filtering and merging the 3 datasets, autosomal SNPs
sh scripts/merging_auto.sh $myfolder

# 1b: filtering and merging the 3 datasets, X linked SNPs
sh scripts/merging_X.sh $myfolder

# 2a: time series analysis, autosomal SNPs
sh scripts/time_auto.sh $myfolder

# 2b: time series analysis, X linked SNPs
sh scripts/time_X.sh $myfolder

# 3: plotting and exploiting time series results
 R -f scripts/time_series.R --args $myfolder

# 4a: nSL analysis, autosomal SNPs - the script must be run for each chromosome, here 29 for instance
sh scripts/nSL_auto.sh 29 $myfolder

# 4b: nSL analysis, X linked SNPs
sh scripts/nSL_X.sh $myfolder

# 4c: merge and standardize nSL results + define candidate regions
R -f scripts/compute_nSL.R --args $myfolder
R -f scripts/signif_nSL.R --args $myfolder 5 10
R -f scripts/plot_nSL.R --args $myfolder

# 5: compare time series and nSL results
R -f scripts/time_vs_nSL.R --args $myfolder

