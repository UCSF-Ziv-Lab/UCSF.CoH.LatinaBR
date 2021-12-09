#' @importFrom utils file_test read.csv
#' @export
read_gistic2 <- function(file, path = ".") {
  file <- file.path(path, file)
  stopifnot(file_test("-f", file))
  
  res <- read.csv(file)
  
  res
}
