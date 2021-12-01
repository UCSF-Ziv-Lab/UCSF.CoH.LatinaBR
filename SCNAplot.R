#### to make GISTIC peak plots using thresholded GISTIC data
library(ggplot2)

## Folder where to write plots
if (!dir.exists("plot")) dir.create("plot")

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

amp.peak <- peak$Descriptor[peak$SCNA == "gain"]
# loss.peak <- peak$Descriptor[peak$SCNA == "loss"]

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
for (i in seq_along(amp.peak)) {
  # i=24
  peak_name <- amp.peak[i]
  gene_name <- peak$candidate_gene[peak$Descriptor == peak_name & peak$SCNA == "gain"]
  TSS <- thres.gene$txStart[thres.gene$gene == gene_name]
  reg.start <- peak$region_start[peak$Descriptor == peak_name & peak$SCNA == "gain"]
  reg.end <- peak$region_end[peak$Descriptor == peak_name & peak$SCNA == "gain"]
  chr <- peak$chr[peak$Descriptor == peak_name & peak$SCNA == "gain"]
  chr_nam <- paste("Chr", chr)
  Region <- subset(thres.gene, Chrom == chr & txStart > reg.start - 5000000 & txEnd < reg.end + 5000000)
  Region <- Region[!duplicated(Region$Gene.Symbol), ]
  row.names(Region) <- Region$Gene.Symbol
  Region <- Region[order(Region$txStart), ]
  
  cols <- grep("^SC", colnames(Region))
  Region$sum2   <- sapply(1:nrow(Region), function(i) sum(Region[i, cols] == +2))
  Region$sum_m1 <- sapply(1:nrow(Region), function(i) sum(Region[i, cols] == -1))
  Region$sum_m2 <- sapply(1:nrow(Region), function(i) sum(Region[i, cols] == -2))

  region <- Region[, c("txStart", "txEnd", "sum2", "sum_m1", "sum_m2")] # generate input file with a few relevant variable for ggplot
  
  gene_plot <- ggplot(region) +
    geom_area(aes(x = `txStart`, y = (`sum2` / 1.46)), fill = "red", stat = "identity") +
    # geom_area(aes(x=`txStart`, y=-((`sum_m1`+`sum_m2`) / 1.46)), fill="blue", stat="identity") +  # not good to plot CN loss using this method
    geom_vline(xintercept = TSS) +
    ylim(0, max(region$sum2 / 1.46 + 2)) +
    xlab(chr_nam) +
    scale_x_continuous(breaks = seq(from = min(region$txStart), to = max(region$txEnd), by = 2500000)) +
    ylab("% CN Amplifications in 146 samples") +
    geom_text(mapping = aes(x = TSS, y = max(sum2 / 1.46 + 0.5), label = gene_name, hjust = -0.5, vjust = -0.5)) +
    mytheme

  imgfile <- paste0("SCNA2_5Mb_test", peak_name, gene_name, ".png")
  png(file.path("plot", imgfile), width = 10 * 200, height = 7 * 200, res = 300, pointsize = 8)
  plot(gene_plot)
  dev.off()
  
  csvfile <- paste0("SCNA2_gene_5Mb", peak_name, gene_name, ".csv")
  write.csv(region, file.path("plot", csvfile))
}
