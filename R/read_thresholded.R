#' @importFrom utils file_test read.delim
#' @export
read_thresholded <- function(file, path = ".") {
  file <- file.path(path, file)
  stopifnot(file_test("-f", file))

  res <- read.delim(file)
  
  res
}
