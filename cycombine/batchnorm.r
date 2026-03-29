#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(cyCombine)
  library(tidyverse)
})

# -------------------------------------------------------------------------
# parse arguments
# -------------------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)

batch_dirs <- list()
method <- "scale"
cofactor <- NA
outdir <- "normalized_outputs"

i <- 1
while (i <= length(args)) {
  
  flag <- args[i]
  
  if (grepl("^--batch", flag)) {
    
    batch_dirs[[sub("^--", "", flag)]] <- args[i + 1]
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

if (length(batch_dirs) == 0) {
  stop("At least one batch must be specified: --batch1 <dir> ...")
}

cat("Detected batches:\n")
print(batch_dirs)
cat("Normalization method:", method, "\n")

if (!is.na(cofactor)) {
  cat("Arcsinh cofactor:", cofactor, "\n")
} else {
  cat("Arcsinh transform: skipped\n")
}

cat("Output directory:", outdir, "\n")

# -------------------------------------------------------------------------
# load files
# -------------------------------------------------------------------------

data_list <- list()

for (batch in names(batch_dirs)) {
  
  path <- batch_dirs[[batch]]
  
  files <- list.files(
    path,
    pattern = "\\.fcs\\.txt$",
    full.names = TRUE
  )
  
  cat("Batch:", batch, "Files:", length(files), "\n")
  
  for (f in files) {
    
    df <- read.table(f, sep = "\t", header = TRUE)
    df <- as_tibble(df)
    
    df$Filename <- basename(f)
    df$batch <- batch
    
    data_list[[length(data_list) + 1]] <- df
  }
}

uncorrected <- bind_rows(data_list)

cat("Total cells loaded:", nrow(uncorrected), "\n")

# -------------------------------------------------------------------------
# marker detection
# -------------------------------------------------------------------------

exclude_cols <- c("Filename", "batch", "Time")

markers <- setdiff(colnames(uncorrected), exclude_cols)

# remove NA values in marker columns
uncorrected <- uncorrected %>%
  filter(if_all(all_of(markers), ~ !is.na(.)))

cat("Markers detected:\n")
print(markers)
cat("Cells remaining after NA removal:", nrow(uncorrected), "\n")

# -------------------------------------------------------------------------
# optional arcsinh transform
# -------------------------------------------------------------------------

if (!is.na(cofactor)) {
  
  cat("Applying arcsinh transform...\n")
  
  uncorrected <- transform_asinh(
    uncorrected,
    markers = markers,
    cofactor = cofactor,
    .keep = TRUE
  )
  
}

# -------------------------------------------------------------------------
# cyCombine normalization
# -------------------------------------------------------------------------

normalized <- normalize(
  df = uncorrected,
  markers = markers,
  norm_method = method
)

# -------------------------------------------------------------------------
# save results
# -------------------------------------------------------------------------

dir.create(outdir, showWarnings = FALSE)

by_sample <- split(normalized, normalized$Filename)

for (nm in names(by_sample)) {
  
  out_path <- file.path(
    outdir,
    paste0(nm, "_normalized.txt")
  )
  
  write.table(
    by_sample[[nm]],
    sep = "\t",
    row.names = FALSE,
    quote = FALSE,
    file = out_path
  )
}

write.table(
  normalized,
  file = file.path(outdir, "combined_normalized.txt"),
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)

cat("Normalization complete.\n")
