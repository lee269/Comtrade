Sys.setenv(http_proxy="http://10.85.4.54:8080", https_proxy="https://10.85.4.54:8080")
library(here)
library(httr)
library(tidyverse)

source(here("R", "get_country_year.R"))
source(here("R", "process_country.R"))

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
# 156 - China





process_country(country_id = "442",country_name =  "luxembourg", year_start = 2010, year_end = 2017, token = authcode)


ids <- c("40","203","208","246","251","276","381","442","528","703","724","752","826","842", "156")
ctrys <- c("austria","czechia","denmark","finland","france","germany","italy","luxembourg","netherlands","slovakia","spain","sweden","uk","usa", "china")


pmap(list(ids, ctrys, 2000, 2017), process_country)
