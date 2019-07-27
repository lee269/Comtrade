Sys.setenv(http_proxy="http://10.85.4.54:8080", https_proxy="https://10.85.4.54:8080")
library(here)
library(httr)
library(tidyverse)

source(here("R", "get_country_year.R"))

auth <- readRDS(here("keys", "auth.rds"))
authcode <- as.character(auth[1,1])

# 40 - Austria
# 203 - Czechia
# 208 - Denmark
# 246 - Finland
# 251 - France
# 276 - Germany
# 381 - Italy
# 442 - Luxembourg
# 528 - Netherlands
# 703 - Slovakia
# 724 - Spain
# 752 - Sweden
# 826 - UK
# 842 - USA


process_countries <- function(country_id, country_name){
  
  yr <- 2000:2017
  map(yr, get_country_year, reporter = country_id, token = authcode, dest_folder = here("data", "downloads"))
  files <- list.files(here("data", "downloads"), full.names = TRUE)
  union <- map_df(files, read_csv)
  saveRDS(union, here("data", "final", paste0(country_name,"_all.rds")))
  map(files, file.remove)
  
}


process_countries("246", "finland")


ids <- c("40","203","208","246","251","276","381","442","528","703","724","752","826","842")
ctrys <- c("austria","czechia","denmark","finland","france","germany","italy","luxembourg","netherlands","slovakia","spain","sweden","uk","usa")

map2(ids, ctrys, process_countries)
