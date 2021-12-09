#' @importFrom shiny runApp
#' @importFrom utils file_test
#' @import ggplot2
#' @import shiny
#' @export
run_app <- function(type = c("gain", "loss"), path = ".") {
  type <- match.arg(type)
  stopifnot(file_test("-d", path))

  ## Read GISTIC 2.0 data
  peak <- read_gistic2("gistic_peaks_s5m7q05v2.csv", path = path)

  peaks <- peak$Descriptor[peak$SCNA == type]
  stopifnot(length(peaks) > 0L)

  ## Read GTF annotations
  gtf <- read_gtf("GTF_withEntrezID.csv", path = path)
  
  ## Read "thresholded" data
  thresholded <- read_thresholded("s5m7q05borad.all_thresholded.by_genes.txt", path = path)
  
  thres.gene <- merge(thresholded, gtf, by.x = "Locus.ID", by.y = "ENTREZID")

  cache <- list(bug = list(), nobug = list())

  app <- shinyApp(
    ui = pageWithSidebar(
      headerPanel('Region'),
      sidebarPanel(
        selectInput('peak_name', 'Peak name', peaks, size = 20L, selectize = FALSE, multiple = FALSE),
      ),
      mainPanel(
        plotOutput('plot1'),
        checkboxInput('show_bug', "Show bug", value = FALSE)    
      )
    ),

    server = function(input, output, session) {
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
  ) ## shinyApp()

  runApp(app)
}
