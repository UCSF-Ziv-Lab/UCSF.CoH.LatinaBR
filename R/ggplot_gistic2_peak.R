#' @import ggplot2
#' @export
ggplot_gistic2_peak <- function(peak_name, padding = 5e6, type = c("gain", "loss"), peak, thres.gene, show_bug = FALSE) {
  ## To please R CMD check
  Chrom <- sum2 <- sum_m2 <- txEnd <- txStart <- NULL
  
  type <- match.arg(type)
  
  gene_name <- peak$candidate_gene[peak$Descriptor == peak_name & peak$SCNA == type]
  chr       <- peak$chr[peak$Descriptor == peak_name & peak$SCNA == type]
  reg.start <- peak$region_start[peak$Descriptor == peak_name & peak$SCNA == type]
  reg.end   <- peak$region_end[peak$Descriptor == peak_name & peak$SCNA == type]
  
  TSS <- thres.gene$txStart[thres.gene$gene == gene_name]

  chr_nam <- paste("Chr", chr)
  Region <- subset(thres.gene, Chrom == chr & txStart > reg.start - padding & txEnd < reg.end + padding)
  Region <- Region[!duplicated(Region$Gene.Symbol), ]
  row.names(Region) <- Region$Gene.Symbol
    
  ## Identify the samples among the column names
  cols <- grep("^SC", colnames(Region))
  Region$sum2   <-  rowSums(Region[, cols] == +2)
  Region$sum_m1 <- -rowSums(Region[, cols] == -1)
  Region$sum_m2 <- -rowSums(Region[, cols] == -2)
  nbr_of_samples <- length(cols)

  region <- Region[, c("txStart", "txEnd", "sum2", "sum_m1", "sum_m2")] # generate input file with a few relevant variable for ggplot
  region <- region[order(region$txStart), ]

  field <- switch(type, gain = "sum2", loss = "sum_m2")
  y <- region[[field]]
  col <- switch(type, gain = "red", loss = "blue")
  
  gg <- ggplot(region)
  
  if (show_bug) {
    gg <- gg + geom_area(aes(x = txStart, y = (sum2 - sum_m2) / 1.46), fill = "orange", stat = "identity")
  }
  
  gg <- gg +
  geom_area(aes(x = txStart, y = y / 1.46), fill = col, stat = "identity") +
    # geom_area(aes(x = txStart, y = -((sum_m1 + sum_m2) / 1.46)), fill = "blue", stat = "identity") +  # not good to plot CN loss using this method
    xlab(chr_nam) +
    ylab(sprintf("%% CN %s in %d samples", type, nbr_of_samples)) +
    scale_x_continuous(breaks = seq(from = min(region$txStart), to = max(region$txEnd), by = 2500000))

  if (type == "gain") {
    gg <- gg + ylim(0, max(y + 2))
  } else if (type == "loss") {
    gg <- gg + ylim(min(y - 2), 0)
  }
  ## FIXME: Works only for type = "gain"
  if (length(TSS) > 0) {
    gg <- gg + geom_vline(xintercept = TSS)
    gg <- gg + geom_text(mapping = aes(x = TSS, y = max(y / 1.46) + 0.5, label = gene_name, hjust = -0.5, vjust = -0.5))
  }

  title <- if (length(gene_name) > 0) {
    sprintf("%s (%s)", peak_name, gene_name)
  } else {
    peak_name
  }
  gg <- gg + ggtitle(title)

  ## Add custom theme
  gg <- gg + theme(
    strip.background = element_rect(fill = "white"),
    strip.text.x = element_text(size = 14, colour = "brown"),
    plot.title = element_text(face = "bold.italic", size = 14, color = "brown"),
    axis.title = element_text(face = "bold.italic", size = 16, color = "brown"),
    axis.text = element_text(face = "bold", size = 12, color = "darkblue"),
    panel.background = element_rect(fill = "white", color = "darkblue"),
    panel.grid.major.y = element_line(color = "grey", linetype = 1),
    panel.grid.minor.y = element_line(color = "grey", linetype = 2),
    panel.grid.minor.x = element_blank(), legend.position = "top",
    legend.title = element_text(size = 14, face = "bold"),
    legend.text = element_text(size = 14, face = "bold")
  )

  attr(gg, "params") <- list(
    peak_name    = peak_name,
    reg.start    = reg.start,
    reg.end      = reg.end,
    gene_name    = gene_name,
    TSS          = TSS,
    sample_names = colnames(Region)[cols]
  )
  
  gg
} ## plot_gistic2_peak()
