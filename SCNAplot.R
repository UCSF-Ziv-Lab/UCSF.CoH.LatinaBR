#### to make GISTIC peak plots using thresholded GISTIC data
suppressPackageStartupMessages(library(ggplot2))

## Folder where to write plots
if (!dir.exists("plot")) dir.create("plot")

## Illustrate effect of Bug #1
## (https://github.com/UCSF-Ziv-Lab/UCSF_CoH-LatinaBR/issues/1)
show_bug <- TRUE

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

mytheme <- theme(
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

# amplification plots
for (i in seq_along(peaks)) {
  # i=24
  peak_name <- peaks[i]
  gene_name <- peak$candidate_gene[peak$Descriptor == peak_name & peak$SCNA == type]
  TSS <- thres.gene$txStart[thres.gene$gene == gene_name]
  reg.start <- peak$region_start[peak$Descriptor == peak_name & peak$SCNA == type]
  reg.end <- peak$region_end[peak$Descriptor == peak_name & peak$SCNA == type]
  chr <- peak$chr[peak$Descriptor == peak_name & peak$SCNA == type]
  chr_nam <- paste("Chr", chr)
  Region <- subset(thres.gene, Chrom == chr & txStart > reg.start - 5000000 & txEnd < reg.end + 5000000)
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
  
  gene_plot <- ggplot(region)
  
  if (show_bug) {
    gene_plot <- gene_plot + geom_area(aes(x = txStart, y = (sum2 - sum_m2) / 1.46), fill = "orange", stat = "identity")
  }
  
  gene_plot <- gene_plot +
  geom_area(aes(x = txStart, y = y / 1.46), fill = col, stat = "identity") +
    # geom_area(aes(x = txStart, y = -((sum_m1 + sum_m2) / 1.46)), fill = "blue", stat = "identity") +  # not good to plot CN loss using this method
    xlab(chr_nam) +
    ylab(sprintf("%% CN %s in %d samples", type, nbr_of_samples)) +
    scale_x_continuous(breaks = seq(from = min(region$txStart), to = max(region$txEnd), by = 2500000)) +
    mytheme

  if (type == "gain") {
    gene_plot <- gene_plot + ylim(0, max(y + 2))
  } else if (type == "loss") {
    gene_plot <- gene_plot + ylim(min(y - 2), 0)
  }
  
  ## FIXME: Works only for type = "gain"
  if (length(TSS) > 0) {
    gene_plot <- gene_plot + geom_vline(xintercept = TSS)
    gene_plot <- gene_plot + geom_text(mapping = aes(x = TSS, y = max(y / 1.46) + 0.5, label = gene_name, hjust = -0.5, vjust = -0.5))
  }

  imgfile <- paste0("SCNA2_5Mb_test", peak_name, gene_name, ".png")
  ggsave(file.path("plot", imgfile), plot = gene_plot, device = png, width = 10*200, height = 7*200, units = "px", dpi = 300, pointsize = 8)
  
  csvfile <- paste0("SCNA2_gene_5Mb", peak_name, gene_name, ".csv")
  write.csv(region, file.path("plot", csvfile))
}
