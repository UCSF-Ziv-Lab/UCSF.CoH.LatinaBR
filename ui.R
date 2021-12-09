library(UCSF.CoH.LatinaBR)

## Read GTF annotations
gtf <- read_gtf("GTF_withEntrezID.csv")

## Read GISTIC 2.0 data
peak <- read_gistic2("gistic_peaks_s5m7q05v2.csv")

## Read "thresholded" data
thresholded <- read_thresholded("s5m7q05borad.all_thresholded.by_genes.txt")

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
