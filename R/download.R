# Download trade data from multiple countries for multiple years. Results are
# saved in the format reporterid-year.zip in the specified folder.

Sys.setenv(http_proxy="http://10.85.4.54:8080", https_proxy="https://10.85.4.54:8080")
library(here)
library(httr)
library(tidyverse)
source(here::here("R", "get_country_year.R"))
auth <- readRDS(here::here("keys", "auth.rds"))

periods <- c(2010:2018)
countrys <- c(348, 404)
authcode <- as.character(auth[1,1])
folder <- here::here("data", "downloads")

# because the paramaters can be lists of different lengths we need to convert to
# a list of equal length elements for pmap
params <- transpose(cross(list(periods, countrys, authcode, folder)))

# multiple countries, multiple years
pmap(params, get_country_year)

