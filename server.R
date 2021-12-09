library(UCSF.CoH.LatinaBR)
suppressPackageStartupMessages(library(ggplot2))

## Read GTF annotations
gtf <- read_gtf("GTF_withEntrezID.csv")

## Read GISTIC 2.0 data
peak <- read_gistic2("gistic_peaks_s5m7q05v2.csv")

## Read "thresholded" data
thresholded <- read_thresholded("s5m7q05borad.all_thresholded.by_genes.txt")

thres.gene <- merge(thresholded, gtf, by.x = "Locus.ID", by.y = "ENTREZID")

## Plot gains or losses?
type <- c("gain", "loss")[1]

cache <- list(bug = list(), nobug = list())

function(input, output, session) {
  output$plot1 <- renderPlot({
    peak_name <- input$peak_name
    show_bug <- input$show_bug
    cache_set <- if (show_bug) "bug" else "nobug"
    gene_plot <- cache[[cache_set]][[peak_name]]
    
    if (is.null(gene_plot)) {
      gene_plot <- ggplot_gistic2_peak(peak_name, type = type, peak = peak, thres.gene = thres.gene, show_bug = show_bug)
      cache[[cache_set]][[peak_name]] <<- gene_plot
    }
    
    print(gene_plot)
  })
}
