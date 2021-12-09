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

Because this R package is in a _private_ GitHub repository, it's a bit trickier to install it.  The easiest is to set up a [personal access token](https://github.com/settings/tokens) on GitHub;

1. Go to <https://github.com/settings/tokens/new>
2. Note: Enter 'remotes::install_github()' or something informative for you
3. Expiration: Select 'No expiration'
4. Select scopes: Check **repo** (leave everything else unchecked)
5. Click 'Generate token'
6. Write down the randomly generated hexadecimal token displayed (you won't see it later). It'll look something like `ghp_BaWRiMXYuF8CUT2n6SNrXTrqbLFVKpR95eR0`.

Now, you can use that GitHub token whenever you want to install an R package from a _private_ GitHub repository.

```r
> if (!require("remotes")) install.packages("remotes")
> remotes::install_github("UCSF-Ziv-Lab/UCSF.CoH.LatinaBR", auth_token = "ghp_BaWRiMXYuF8CUT2n6SNrXTrqbLFVKpR95eR0")
```

This will also install all other R packages required.  BTW, if the R package was in a _public_ GitHub repository, we would not have to use a token.
