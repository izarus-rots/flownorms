#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(data.table)
})

dir_create <- function(x) if (!dir.exists(x)) dir.create(x, recursive = TRUE)

load_fcs_txt <- function(path) {
    files <- list.files(path, pattern="\\.txt$", full.names = TRUE)
    rbindlist(lapply(files, function(f) {
                         dt <- fread(f, sep="\t")
                         dt[, filename := basename(f)]
                         dt$batch <- "Batch1" # dummy batch
                         dt
        }), fill=TRUE)
}
