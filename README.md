# Detection of selection signatures in the cattle breed Asturiana de los Valles
Scripts used in Boitard et al (2021, Front. Genet. doi: 10.3389/fgene.2021.575405) to detect selection signatures in the cattle breed Asturiana de los Valles

All commands used for the population genetics analyzes performed in this study can be found in main.sh.

These commands call private python or R scripts, which can be found in directory 'scripts'.

Directory 'compareHMM' should contain the code allowing to detect selection from genomic time series (Paris et al, 2019), downloaded from https://github.com/CyrielParis/compareHMM.

Other public software (plink1.9, GCTA, shapeit, selscan) are needed for some commands and should be installed before running main.sh.

The NGS, 50K and 800K raw datasets used in these analyzes are public but not provided here (url are provided in the manuscript).
