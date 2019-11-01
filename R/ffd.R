library(here)
library(tidyverse)

source(here("R", "db_safe_names.R"))
cncodes <- read_csv("~/Documents/FFD/data/CN CODES MASTER TABLE.csv")
names(cncodes) <- db_safe_names(names(cncodes))

ctry <- readRDS(here("data", "final", "austria_all.rds"))

get_ffd <- function(file){

  ffd <- c("02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23")
  message(file)
  ctry <- readRDS(file)
  
  names(ctry) <- db_safe_names(names(ctry))
  
  ctry <- ctry %>% 
        filter(aggregate_level == 2, 
               trade_flow_code == 2, 
               partner_iso == "WLD",
               commodity_code %in% ffd)
}

 files <- list.files(here("data", "final"), full.names = TRUE)


x <- map_df(files, get_ffd) 
 
# saveRDS(x, here("data", "final", "ffd.rds"))

ffd <- x

x <- ffd %>% group_by(year, reporter) %>% summarise(exports = sum(trade_value_us_))


write.csv(x, here("data", "final", "ffd.csv"))
