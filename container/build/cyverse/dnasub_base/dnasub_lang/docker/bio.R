options(download.file.method = "libcurl");
source("http://bioconductor.org/biocLite.R");
options(depedencies = TRUE);
options(repos = c(CRAN = "http://cran.rstudio.com/"));
biocLite();
biocLite(c("cummeRbund"));
