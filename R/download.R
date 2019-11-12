Sys.setenv(http_proxy="http://10.85.4.54:8080", https_proxy="https://10.85.4.54:8080")
library(here)
library(httr)
library(tidyverse)

source(here::here("R", "get_country_year.R"))
source(here::here("R", "process_country.R"))

auth <- readRDS(here::here("keys", "auth.rds"))
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
# 156 - China
# 699 - India
# 710 - South Africa


# Download multiple countries
ids <- c("40","203","208","246","251","276","381","442","528","703","724","752")
ctrys <- c("austria","czechia","denmark","finland","france","germany","italy","luxembourg","netherlands","slovakia","spain","sweden")


period <- c(2010:2017)
reporter <- 703
folder <- here("data", "downloads")

# one country, multiple years
# pmap(list(period, reporter, authcode, folder), get_country_year)

# multiple countries, multiple years
mult <- function(ctrys){
  pmap(list(period, ctrys, authcode, folder), get_country_year)
}

ids <- c(579, 586, 616, 710)
map(ids, mult)
