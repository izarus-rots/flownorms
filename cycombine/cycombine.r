# imports -----------------------------------------------------------------
library(cyCombine)
library(tidyverse)
path <- "../datasets/CLL_288/CLL_24/" # expect 24 files, `ls -lah | awk 'substr($9, length($9) - 2) == "txt"' | wc -l`
files <- list.files(path, pattern = "\\.fcs\\.txt$", full.names = TRUE)

data_list <- lapply(files, function(f) {
  df <- read.table(f, sep = "\t", header = TRUE)
  df <- as_tibble(df) # cyCombine vignette implies necessity of this format
  df$Filename <- basename(f)
  df$batch <- "Batch1" # dummy batch — lacking batch information
  df
})

uncorrected <- bind_rows(data_list)
cat("Loaded", length(files), "files with", nrow(uncorrected), "total cells \n")

# cycombine ---------------------------------------------------------------
exclude_cols <- c("Filename", "batch")
markers <- setdiff(colnames(uncorrected), exclude_cols)
cat("Markers detected:", paste(markers, collapse = ", "), "\n")
uncorrected <- transform_asinh(uncorrected, markers = markers, cofactor = 5, .keep = TRUE)

normalized <- normalize(
  df = uncorrected,
  markers = markers,
  norm_method = "scale"
)

# saving ------------------------------------------------------------------

dir.create(file.path("normalized_outputs"), showWarnings = FALSE)

by_sample <- split(normalized, normalized$Filename)
for (nm in names(by_sample)) {
  out_path <- file.path("normalized_outputs", paste0(nm, "_normalized.txt"))
  write.table(by_sample[[nm]], sep = "\t", row.names = FALSE, quote = FALSE, file = out_path)
}