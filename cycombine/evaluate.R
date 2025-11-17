#!/usr/bin/env Rscript

# imports -----------------------------------------------------------------

suppressPackageStartupMessages({
  library(optparse)
  library(cyCombine)
  library(tidyverse)
  library(ggplot2)
})

# arguments ---------------------------------------------------------------

option_list <- list(
  make_option(c("--raw"), type = "character", default = ".",
              help = "Directory of raw input data as provided to normalize function"),
  make_option(c("--normalized"), type = "character", default = "scale",
              help = "Directory of normalized dataset"),
  make_option(c("--output"), type = "character", default = "normalized_outputs",
              help = "Output directory for evaluation files")
)

opt <- parse_args(OptionParser(option_list = option_list))
dir_create(opt$output)

# data loading & processing

raw <- list.files(opt$raw, pattern = "\\.fcs\\.txt$", full.names = TRUE)
norm <- list.files(opt$normalized, pattern = "\\.fcs\\.txt$", full.names = TRUE)
if (length(raw) == 0) {
  stop("No .fcs.txt files found in ", opt$raw)
}
if (length(normalized) == 0) {
  stop("No .fcs.txt files found in ", opt$normalized)
}

raw_data <- lapply(raw, function(f) {
  df <- read.table(f, sep = "\t", header = TRUE)
  df <- as_tibble(df)
  df$Filename <- basename(f)
  df$batch <- "Batch1" # dummy batch
  df
})

norm_data <- lapply(norm, function(f) {
  df <- read.table(f, sep = "\t", header = TRUE)
  df <- as_tibble(df)
  df$Filename <- basename(f)
  df
})

# metrics

# plotting and visualization for comparison

