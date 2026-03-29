#!/usr/bin/env Rscript

# imports -----------------------------------------------------------------

suppressPackageStartupMessages({
  library(cyCombine)
  library(tidyverse)
})

# arguments ---------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)

input_dir <- ""
method <- "scale"
cofactor <- NA
outdir <- "normalized_outputs"

i <- 1
while (i <= length(args)) {
	flag <- args[i]

	if (flag == "--input") {
		input_dir <- args[i + 1]
		i <- i + 2
		next
	}

	if (flag == "--method") {
		method <- args[i + 1]
		i <- i + 2
		next
	}

	if (flag == "--cofactor") {
		cofactor <- as.numeric(args[i + 1])
		i <- i + 2
		next
	}

	if (flag == "--outdir") {
		outdir <- args[i + 1]
		i <- i + 2
		next
	}

	stop(paste("Unknown argument:", flag))
}

cat("Running cycombine on:", input_dir, "\n")
cat("Normalization method:", method, "\n")
if (!is.na(cofactor)) {
	cat("Arcsinh cofactor:", cofactor, "\n")
} else {
	cat("Arcsinh transform: skipped\n")
}

cat("Output directory:", outdir, "\n")


# data loading & processing -----------------------------------------------

files <- list.files(input_dir, pattern = "\\.fcs\\.txt$", full.names = TRUE)
if (length(files) == 0) {
  stop("No .fcs.txt files found in ", input_dir)
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

# remove NA values in marker columns
uncorrected <- uncorrected %>%
  filter(if_all(all_of(markers), ~ !is.na(.)))

cat("Markers detected:", paste(markers, collapse = ", "), "\n")

# arcsinh transform should be optional? w/o multibatch support the
# normalization process is nonlinear and therefore this will likely make no
# change ...

if (!is.na(cofactor)) {
    cat("Applying arcsinh transform...\n")

    uncorrected <- transform_asinh(
      uncorrected,
      markers = markers,
      cofactor = cofactor,
      .keep = TRUE
    )
}

normalized <- normalize(
  df = uncorrected,
  markers = markers,
  norm_method = method
)

# saving ------------------------------------------------------------------

dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

by_sample <- split(normalized, normalized$Filename)
for (nm in names(by_sample)) {
  out_path <- file.path(outdir, paste0(nm, "_normalized.txt"))
  write.table(by_sample[[nm]], sep = "\t", row.names = FALSE, quote = FALSE, file = out_path)
}

cat("Normalization complete. Output written to:", outdir, "\n")
