#!/usr/bin/env Rscript

# imports -----------------------------------------------------------------

suppressPackageStartupMessages({
  library(optparse)
  library(cyCombine)
  library(tidyverse)
  library(ggplot2)
  library(data.table)
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

# print(raw_dt, nrows = 4)

# metrics

markers <- intersect(
                     setdiff(colnames(raw_dt), c("filename", "batch")),
                     setdiff(colnames(norm_dt), c("filename", "batch"))
)

metrics <- rbindlist(lapply(markers, function(m) {
                                raw_mad <- mad(raw_dt[[m]])
                                norm_mad <- mad(norm_dt[[m]])
                                data.table(marker = m, raw_mad=raw_mad, norm_mad=norm_mad)
              }))
print(markers)
print(metrics$norm_mad)

fwrite(metrics, file.path(opt$output, "summary.tsv"), sep="\t")
