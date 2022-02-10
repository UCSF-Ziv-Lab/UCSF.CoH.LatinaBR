<div id="badges"><!-- pkgdown markup -->
<a href="https://github.com/UCSF-Ziv-Lab/UCSF_CoH-LatinaBR/actions?query=workflow%3AR-CMD-check"><img border="0" src="https://github.com/UCSF-Ziv-Lab/UCSF_CoH-LatinaBR/actions/workflows/R-CMD-check.yaml/badge.svg" alt="R CMD check status"/></a>
</div>

# UCSF-CoH Latina Breast Cancer Study

## Shiny app to browser GISTIC peaks

Assuming you have followed the below 'Setup' instructions, then launch R in the same directory where the data files are and run:

```r
> UCSF.CoH.LatinaBR::run_app()
```

This will open the below Shiny app in your web browser:

![](man/figures/shiny_app_screenshot.png)


## Setup instructions

### Data files

Place the following files in the current working directory:

```r
$ ls -l -- *.csv *.txt
-rw-rw-r-- 1 hb hb   19312 Dec  1 13:21 gistic_peaks_s5m7q05v2.csv
-rw-rw-r-- 1 hb hb 7779894 Dec  1 13:21 GTF_withEntrezID.csv
-rw-rw-r-- 1 hb hb 8203335 Dec  1 13:57 s5m7q05borad.all_thresholded.by_genes.txt
```

### Install this R package

To install this package and all of its dependencies, do:

```r
if (!require("remotes")) install.packages("remotes")
remotes::install_github("UCSF-Ziv-Lab/UCSF.CoH.LatinaBR")
```

