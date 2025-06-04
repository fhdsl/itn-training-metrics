install.packages("jsonlite", repos = "https://cloud.r-project.org")

library(optparse) #make_option OptionParser parse_args
library(jsonlite) #fromJSON
library(here)
library(tidyverse)
library(magrittr)

# ----------- Get the output from GHA -----


# Look for the data_in argument
option_list <- list(
  optparse::make_option(
    c("--data_in_loq"),
    type = "character",
    default = NULL,
    help = "Sheet with Loqui data (json)"
  ),
  optparse::make_option(
    c("--data_in_loq_supp"),
    type = "character",
    default = NULL,
    help = "Sheet with supplemental Loqui data (json)"
  ),
  optparse::make_option(
    c("--data_in_courses"),
    type = "character",
    default = NULL,
    help = "Sheet with coursera and leanpub course numbers (json)"
  )
)

# Read the results provided as command line argument
opt_parser <- optparse::OptionParser(option_list = option_list)
opt <- optparse::parse_args(opt_parser)
jsonResults_loq <- opt$data_in_loq
jsonResults_loq_supp <- opt$data_in_loq_supp
jsonResults_courses <- opt$data_in_courses

# ---------- Interpret the JSON data ----- #should functionalize this....

#Pull the data itself from the API results
dfloq <- fromJSON(jsonResults_loq)
message("this good")
dfloq_supp <- fromJSON(jsonResults_loq_supp)
message("this also good")
dfcourses <- fromJSON(jsonResults_courses)

dfloq <- dfloq$results$result$formatted[[2]]
dfloq_supp <- dfloq_supp$results$result$formatted[[2]]
dfcourses <- dfcourses$results$results$formatted[[2]]
message("through here fine")

colnames(dfloq) <- dfloq[1, ] #colnames taken from first row of data
dfloq <- dfloq[-1, ] #remove the first row of data (original column names)
colnames(dfloq_supp) <- dfloq_supp[1, ]
dfloq_supp <- dfloq_supp[-1, ]
colnames(dfcourses) <- dfcourses[1, ]
dfcourses <- dfcourses[-1, ]

dfloq <- tibble::as_tibble(dfloq)
dfloq[dfloq==""]<- NA #make no responses NA

dfloq %<>% drop_na()
message(dim(dfloq))
message(colnames(dfloq))

dfloq_supp <- tibble::as_tibble(dfloq_supp)
dfloq_supp[dfloq_supp==""] <- NA

dfloq_supp %<>% drop_na()
message(dim(dfloq_supp))
message(colnames(dfloq_supp))

dfcourses <- tibble::as_tibble(dfcourses)
dfcourses[dfcourses==""]<- NA #make no responses NA
message(dim(dfcourses))
message(colnames(dfcourses))


sheet_results <- list(
  loqui_data = dfloq,
  loqui_data_supp = dfloq_supp,
  courses_data = dfcourses
)

rmarkdown::render_site(
  envir = new.env(parent = globalenv()) #enable the use of sheet_results inside the Rmd files being rendered
)
