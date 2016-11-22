options(download.file.method = "libcurl");
source("http://bioconductor.org/biocLite.R");
options(depedencies = TRUE);
options(repos = c(CRAN = "http://cran.rstudio.com/"));
biocLite();
# Add biocLite("modules") here to add new ones
