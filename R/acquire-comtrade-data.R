library(iapdashboardadmin)
library(davidtools)
SCE_proxy()

auth <- readRDS(here::here("keys", "auth.rds"))
folder <- here::here("data", "downloads")
yrs <- c(2010:2018)
ctys <- c(4, 8, 12, 20, 24, 28, 51, 31, 44, 48, 52, 70, 72, 100)

get_countries_years(periods = yrs, reporters = ctys, token = auth, dest_folder = folder, unzip = FALSE)