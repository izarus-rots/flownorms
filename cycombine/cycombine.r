#!/usr/bin/env Rscript

# imports -----------------------------------------------------------------

suppressPackageStartupMessages({
  library(optparse)
  library(cyCombine)
  library(tidyverse)
})

# arguments ---------------------------------------------------------------

option_list <- list(
  make_option(c("--input"), type = "character", default = ".",
              help = "Input directory with preprocessed fcs files"),
  make_option(c("--method"), type = "character", default = "scale",
              help = "Normalization method (e.g., scale, quantile, etc.)"),
  make_option(c("--cofactor"), type = "numeric", default = 5,
              help = "Cofactor for asinh transformation"),
  make_option(c("--output"), type = "character", default = "normalized_outputs",
              help = "Output directory for normalized files")
)

opt <- parse_args(OptionParser(option_list = option_list))

# data loading & processing -----------------------------------------------

files <- list.files(opt$input, pattern = "\\.fcs\\.txt$", full.names = TRUE)
if (length(files) == 0) {
  stop("No .fcs.txt files found in ", opt$input)
}

data_list <- lapply(files, function(f) {
  df <- read.table(f, sep = "\t", header = TRUE)
  df <- as_tibble(df)
  df$Filename <- basename(f)
  df$batch <- "Batch1" # dummy batch
  df
})

uncorrected <- bind_rows(data_list)
cat(length(files), "files loaded with", nrow(uncorrected), "cells \n")

# cycombine ---------------------------------------------------------------

exclude_cols <- c("Filename", "batch")
markers <- setdiff(colnames(uncorrected), exclude_cols)
cat("Markers detected:", paste(markers, collapse = ", "), "\n")

uncorrected <- transform_asinh(
  uncorrected,
  markers = markers,
  cofactor = opt$cofactor,
  .keep = TRUE
)

normalized <- normalize(
  df = uncorrected,
  markers = markers,
  norm_method = opt$method
)

# saving ------------------------------------------------------------------

dir.create(opt$output, showWarnings = FALSE, recursive = TRUE)

by_sample <- split(normalized, normalized$Filename)
for (nm in names(by_sample)) {
  out_path <- file.path(opt$output, paste0(nm, "_normalized.txt"))
  write.table(by_sample[[nm]], sep = "\t", row.names = FALSE, quote = FALSE, file = out_path)
}

cat("Normalization complete. Output written to:", opt$output, "\n")