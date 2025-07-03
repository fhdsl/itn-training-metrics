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

# ---------- Interpret the JSON data -----
json_to_df <- function(jsonResults){

  #Pull the data itself from the API results
  df <- fromJSON(jsonResults)
  df <- df$results$result$formatted[[2]]

  colnames(df) <- df[1, ] #colnames taken from first row of data
  df <- df[-1, ] #remove the first row of data (original column names)

  df <- tibble::as_tibble(df)
  df[df==""] <- NA #make no responses NA

  return(df)
}

# loqui data
dfloq <- json_to_df(jsonResults_loq)

dfloq %<>% drop_na()
message(dim(dfloq))
message(colnames(dfloq))

# supplemental loqui data
dfloq_supp <- json_to_df(jsonResults_loq_supp)

dfloq_supp %<>% drop_na()
message(dim(dfloq_supp))
message(colnames(dfloq_supp))

# leanpub and coursera course data
dfcourses <- json_to_df(jsonResults_courses)

message(dim(dfcourses))
message(colnames(dfcourses))

# google analytics for courses
auth_from_secret("google",
  refresh_token = Sys.getenv("METRICMINER_GOOGLE_REFRESH"),
  access_token = Sys.getenv("METRICMINER_GOOGLE_ACCESS"),
  cache = TRUE
)

sheet_results <- list(
  loqui_data = dfloq,
  loqui_data_supp = dfloq_supp,
  courses_data = dfcourses
)

rmarkdown::render_site(
  envir = new.env(parent = globalenv()) #enable the use of sheet_results inside the Rmd files being rendered
)
