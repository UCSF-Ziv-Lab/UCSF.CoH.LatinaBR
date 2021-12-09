## Read GTF annotations
gtf <- read.csv("GTF_withEntrezID.csv")
## Map {chr1, chr2, ..., chrX, chrY, chrM} to 1:25
## Ignore '6_mann_hap4', 'Un_gl000223', etc.
chrs <- gsub(gtf$chrom, pattern = "chr", replacement = "")
chrs[chrs == "X"] <- "23"
chrs[chrs == "Y"] <- "24"
chrs[chrs == "M"] <- "25"
chrs <- suppressWarnings(as.integer(chrs))
gtf$Chrom <- chrs

## Read data
peak <- read.csv("gistic_peaks_s5m7q05v2.csv")
thresholded <- read.delim("s5m7q05borad.all_thresholded.by_genes.txt")
thres.gene <- merge(thresholded, gtf, by.x = "Locus.ID", by.y = "ENTREZID")

## Plot gains or losses?
type <- c("gain", "loss")[1]
peaks <- peak$Descriptor[peak$SCNA == type]
stopifnot(length(peaks) > 0L)


pageWithSidebar(
  headerPanel('Region'),
  sidebarPanel(
    selectInput('peak_name', 'Peak name', peaks, size = 20L, selectize = FALSE, multiple = FALSE),
  ),
  mainPanel(
    plotOutput('plot1'),
    checkboxInput('show_bug', "Show bug", value = FALSE)    
  )
)
