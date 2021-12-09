#' @importFrom utils file_test read.csv
#' @export
read_gtf <- function(file, path = ".") {
  file <- file.path(path, file)
  stopifnot(file_test("-f", file))

  res <- read.csv(file)
  
  ## Map {chr1, chr2, ..., chrX, chrY, chrM} to 1:25
  ## Ignore '6_mann_hap4', 'Un_gl000223', etc.
  chrs <- gsub(res$chrom, pattern = "chr", replacement = "")
  chrs[chrs == "X"] <- "23"
  chrs[chrs == "Y"] <- "24"
  chrs[chrs == "M"] <- "25"
  chrs <- suppressWarnings(as.integer(chrs))
  res$Chrom <- chrs
  
  res
}
