#' @importFrom utils file_test read.csv
#' @export
read_gistic2 <- function(file, path = ".", trim = TRUE) {
  file <- file.path(path, file)
  stopifnot(file_test("-f", file))
  
  res <- read.csv(file)

  ## Trim all fields
  if (trim) {
    for (field in colnames(res)) {
      value <- res[[field]]
      if (is.character(value)) {
        value <- gsub("(^[[:space:]]+|[[:space:]]+$)", "", value)
        res[[field]] <- value
      }
    }
  }
  
  res
}
