#!/usr/bin/env Rscript

# imports -----------------------------------------------------------------

suppressPackageStartupMessages({
  library(optparse)
  library(cyCombine)
  library(tidyverse)
  library(ggplot2)
})

source("cycombine/utils.R")

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

raw_dt <- load_fcs_txt(opt$raw)
norm_dt <- load_fcs_txt(opt$normalized)

print(raw_dt, nrows = 4)
print(norm_dt, nrows = 4)

# metrics

# plotting and visualization for comparison

