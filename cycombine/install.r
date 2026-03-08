install.packages("BiocManager")
library(BiocManager)

install.packages("remotes")
install.packages("optparse")

# To ensure Rstudio looks up BioConductor packages run:
setRepositories(ind = 1:2)
# If you are correcting cytometry data, install the following Bioconductor packages:
BiocManager::install(c("flowCore", "Biobase", "sva"))
# Then install package with
remotes::install_github("biosurf/cyCombine")

# install.packages("tidyverse")
