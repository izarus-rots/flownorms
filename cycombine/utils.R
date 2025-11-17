#!/usr/bin/env Rscript

dir_create <- function(x) if (!dir.exists(x)) dir.create(x, recursive = TRUE)

load_fcs_txt <- function(path) {
    files <- list.files(path, pattern="\\.fcs\\.txt$", full.names = TRUE)
    rbindlist(lapply(files, function(f) {
                         dt <- fread(f, sep="\t")
                         dt[, filename := basename(f)]
                         dt
        }), fill=TRUE)
}
