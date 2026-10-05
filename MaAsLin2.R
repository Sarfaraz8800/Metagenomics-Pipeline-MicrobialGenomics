##### 0. Clear & Setup #####
rm(list = ls())
options(stringsAsFactors = FALSE)

#--- CRAN packages (install if missing)
cran_pkgs <- c(
  "Maaslin2","dplyr","data.table","corrplot","pheatmap",
  "RColorBrewer","ggplot2","reshape2","tidyverse",
  "igraph","caret","pROC","vegan"
)
for(pkg in cran_pkgs){
  if(!require(pkg, character.only = TRUE)){
    install.packages(pkg, repos = "https://cloud.r-project.org")
    library(pkg, character.only = TRUE)
  }
}

#--- Bioconductor packages
if(!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager", repos = "https://cloud.r-project.org")
for(pkg in c("phyloseq","DESeq2")){
  if(!require(pkg, character.only = TRUE))
    BiocManager::install(pkg, ask = FALSE)
  library(pkg, character.only = TRUE)
}

##### 1. Read & Parse Input #####
input_file <- "combined_taxa_merged.txt"
data_raw   <- read.table(
  input_file,
  sep             = "\t",
  header          = FALSE,
  stringsAsFactors= FALSE,
  fill            = TRUE,
  quote           = "",
  comment.char    = "",
  check.names     = FALSE
)

# Locate 'Subject_id' row to split metadata vs features
meta_end <- which(data_raw[,1] == "Subject_id")
if(length(meta_end) != 1) stop("Cannot find exactly one 'Subject_id' row.")

# Extract and transpose metadata
meta_rows <- data_raw[1:(meta_end-1), , drop = FALSE]
meta_keys <- as.character(meta_rows[,1])
meta_vals <- meta_rows[, -1, drop = FALSE]
metadata  <- as.data.frame(t(meta_vals), stringsAsFactors = FALSE)
colnames(metadata) <- meta_keys
sample_ids <- as.character(data_raw[meta_end, -1])
metadata$SampleID <- sample_ids
rownames(metadata) <- sample_ids

# Convert key metadata columns to factors
for(col in c("Classification","age","Gender","Geography")){
  if(col %in% names(metadata)){
    metadata[[col]] <- factor(metadata[[col]], levels = unique(metadata[[col]]))
  }
}

##### 2. Build Abundance Matrix #####
taxa_block <- data_raw[(meta_end+1):nrow(data_raw), , drop = FALSE]
taxa_block <- taxa_block[taxa_block[,1] != "", ]
taxa_names <- as.character(taxa_block[,1])
abund_mat  <- apply(taxa_block[,-1], 2, as.numeric)
rownames(abund_mat) <- taxa_names
colnames(abund_mat) <- sample_ids
abund_mat[is.na(abund_mat)] <- 0
abundance_df <- as.data.frame(t(abund_mat))  # samples × features

##### 3. Save Preprocessed Tables #####
write.table(abundance_df, "maaslin2_input_data.tsv",
            sep = "\t", quote = FALSE, row.names = TRUE)
write.table(metadata, "maaslin2_input_metadata.tsv",
            sep = "\t", quote = FALSE, row.names = FALSE)

##### 4. MaAsLin2 Analyses #####
# Model A: Classification only
Maaslin2(
  input_data     = abundance_df,
  input_metadata = metadata,
  output         = "maaslin2_classification_output",
  fixed_effects  = c("Classification"),
  reference      = c("Classification,Healthy"),
  min_abundance  = 1e-4,
  min_prevalence = 0.1,
  normalization  = "TSS",
  transform       = "LOG",
  analysis_method = "LM",
  max_significance= 0.25,
  correction      = "BH",
  standardize     = TRUE,
  plot_heatmap    = TRUE,
  plot_scatter    = TRUE,
  cores           = 1
)

# Model B: Full model with all covariates
Maaslin2(
  input_data     = abundance_df,
  input_metadata = metadata,
  output         = "maaslin2_full_model_output",
  fixed_effects  = c("Classification","age","Gender","Geography"),
  reference      = c("Classification,Healthy",
                     "age,young",
                     "Gender,Female",
                     "Geography,spain"),
  min_abundance  = 1e-4,
  min_prevalence = 0.1,
  normalization  = "TSS",
  transform       = "LOG",
  analysis_method = "LM",
  max_significance= 0.25,
  correction      = "BH",
  standardize     = TRUE,
  plot_heatmap    = TRUE,
  plot_scatter    = TRUE,
  cores           = 1
)

##### 5. Correlation Heatmaps (Top 50 Features) #####
ab_fil <- abundance_df[, apply(abundance_df, 2, var) > 0]
top50  <- names(sort(colMeans(ab_fil), decreasing = TRUE))[1:50]
corrm  <- cor(ab_fil[, top50], use = "pairwise.complete.obs")

pdf("correlation_heatmap_top50.pdf", width = 15, height = 12)
corrplot(corrm, method="circle", type="upper", order="hclust",
         tl.cex=0.6, tl.col="black", tl.srt=45,
         col=colorRampPalette(c("#B2182B","#FDE725","#2166AC"))(200))
dev.off()

pdf("pheatmap_correlation_top50.pdf", width = 16, height = 14)
pheatmap(corrm,
         clustering_distance_rows = "correlation",
         clustering_distance_cols = "correlation",
         color                    = colorRampPalette(c("#B2182B","#FDE725","#2166AC"))(100),
         labels_row               = parse(text = paste0("italic('", top50, "')")),
         labels_col               = parse(text = paste0("italic('", top50, "')")),
         fontsize_row             = 10,
         fontsize_col             = 10,
         border_color             = NA)
dev.off()

##### 6. Bidirectional Bar Plot (CRC vs Healthy) #####
sig_file <- "maaslin2_classification_output/significant_results.tsv"
if(file.exists(sig_file)){
  res <- read.table(sig_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
  if(nrow(res) > 0){
    res$Direction <- ifelse(res$coef > 0, "Enriched_in_CRC", "Enriched_in_Healthy")
    res$abs_coef  <- abs(res$coef)
    top50 <- res %>% arrange(desc(abs_coef)) %>% slice_head(n=50)
    top50$feature_short <- substr(top50$feature, 1, 40)
    p <- ggplot(top50, aes(x = reorder(feature_short, coef), y = coef, fill = Direction)) +
      geom_col(width = 0.7) + coord_flip() +
      scale_fill_manual(values = c(
        "Enriched_in_CRC"    = "#D73027",  # orange
        "Enriched_in_Healthy"= "#4575B4"   # green-blue
      )) +
      theme_minimal() +
      theme(axis.text.y = element_text(face = "italic", size = 10),
            legend.position = "bottom") +
      labs(x = "Feature", y = "Coefficient (LogFC)")
    ggsave("bidirectional_barplot_top50.pdf", p, width = 14, height = 10)
  }
}

##### 7. Escherchia coli Abundance by Country & Classification #####
# Subset data for Spain
metadata_spain <- metadata[metadata$Geography == "spain", ]
abundance_spain <- abundance_df[rownames(abundance_df) %in% metadata_spain$SampleID, ]

# Subset data for China
metadata_china <- metadata[metadata$Geography == "china", ]
abundance_china <- abundance_df[rownames(abundance_df) %in% metadata_china$SampleID, ]

# MaAsLin2 for Spain
Maaslin2(
  input_data     = abundance_spain,
  input_metadata = metadata_spain,
  output         = "maaslin2_spain_classification",
  fixed_effects  = c("Classification"),
  reference      = c("Classification,Healthy"),
  min_abundance  = 1e-4,
  min_prevalence = 0.1,
  normalization  = "TSS",
  transform       = "LOG",
  analysis_method = "LM",
  max_significance= 0.25,
  correction      = "BH",
  standardize     = TRUE,
  plot_heatmap    = FALSE,
  plot_scatter    = TRUE,
  cores           = 1
)

# MaAsLin2 for China
Maaslin2(
  input_data     = abundance_china,
  input_metadata = metadata_china,
  output         = "maaslin2_china_classification",
  fixed_effects  = c("Classification"),
  reference      = c("Classification,Healthy"),
  min_abundance  = 1e-4,
  min_prevalence = 0.1,
  normalization  = "TSS",
  transform       = "LOG",
  analysis_method = "LM",
  max_significance= 0.25,
  correction      = "BH",
  standardize     = TRUE,
  plot_heatmap    = FALSE,
  plot_scatter    = TRUE,
  cores           = 1
)

##### 7. ko00650 by Country #####

library(dplyr)
library(ggplot2)

# 7.1 Subset metadata & abundance by country
metadata_spain   <- filter(metadata, Geography == 'spain')
abundance_spain  <- abundance_df[rownames(abundance_df) %in% metadata_spain$SampleID, ]

metadata_china   <- filter(metadata, Geography == 'china')
abundance_china  <- abundance_df[rownames(abundance_df) %in% metadata_china$SampleID, ]

# 7.2 Read MaAsLin2 results and filter for F. prausnitzii CRC vs Healthy
sig_spain <- read.table(
  "maaslin2_spain_classification/significant_results.tsv",
  header = TRUE, sep = "\t", stringsAsFactors = FALSE
)
ecol_spain_res <- sig_spain %>%
  filter(feature == "ko00650",
         value   == "ClassificationCRC")

sig_china <- read.table(
  "maaslin2_china_classification/significant_results.tsv",
  header = TRUE, sep = "\t", stringsAsFactors = FALSE
)
ecol_china_res <- sig_china %>%
  filter(feature == "ko00650",
         value   == "ClassificationCRC")

# 7.3 Plotting function
plot_feature <- function(feature_name, abund_df, meta_df, stat_res, country) {
  df <- data.frame(
    SampleID  = rownames(abund_df),
    Abundance = abund_df[, feature_name],
    stringsAsFactors = FALSE
  ) %>%
    left_join(meta_df, by = "SampleID")
  
  coef <- if (nrow(stat_res) > 0) round(stat_res$coef, 3) else NA
  qval <- if (nrow(stat_res) > 0) round(stat_res$qval, 3) else NA
  
  gg <- ggplot(df, aes(x = Classification, y = Abundance)) +
    # light‐filled box with black border
    geom_boxplot(aes(fill = Classification),
                 color = "black", alpha = 0.3, outlier.shape = NA) +
    # colored dots: Healthy=steelblue4, CRC=tomato3
    geom_jitter(aes(color = Classification),
                width = 0.1, size = 2, alpha = 1) +
    theme_bw(base_size = 14) +
    theme(
      panel.grid    = element_blank(),
      plot.title    = element_text(hjust = 0.5, face = "bold"),
      plot.subtitle = element_text(hjust = 0.5),
      axis.text.x   = element_text(face = "italic")
    ) +
    labs(
      title    = feature_name,
      subtitle = paste0("FDR: ", qval, "   Coef: ", coef),
      x        = NULL,
      y        = "Relative abundance"
    ) +
    scale_fill_manual(values = c(Healthy = "#4575B4", CRC = "#D73027")) +
    scale_color_manual(values = c(Healthy = "steelblue4", CRC = "tomato3")) +
    guides(fill = "none", color = "none")
  
  ggsave(
    filename = paste0(gsub(" ", "_", feature_name), "_", country, ".png"),
    plot     = gg,
    width    = 6, height = 6, dpi = 300
  )
}

# 7.4 Generate plots for Spain & China
plot_feature(
  feature_name = "segatella copri",
  abund_df     = abundance_spain,
  meta_df      = metadata_spain,
  stat_res     = ecol_spain_res,
  country      = "Spain"
)

plot_feature(
  feature_name = "segatella copri",
  abund_df     = abundance_china,
  meta_df      = metadata_china,
  stat_res     = ecol_china_res,
  country      = "China"
)
