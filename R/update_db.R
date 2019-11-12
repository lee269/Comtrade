library(tidyverse)
source(here::here("R", "extract_ffd.R"))

# extract ffd data from all zipfiles in the download directory and create a dataframe
zips <- list.files(here::here("data", "downloads"), full.names = TRUE)
ffd_trade <- map_dfr(zips, extract_ffd)

# Get HS4 comodity code descriptions and add them to the ffd data
cncodes <- read_csv(here::here("data", "reference", "CN CODES MASTER TABLE.csv")) %>% 
            select(`HS4 code`, `HS4 Description`) %>% 
            transmute(commodity_code = `HS4 code`,
                      commodity = `HS4 Description`) %>% 
            group_by(commodity_code, commodity) %>% 
            summarise(count = n()) %>% 
            select(-count)
             

ffd_trade <- ffd_trade %>% 
              left_join(cncodes)

saveRDS(ffd_trade, here::here("data", "db", "ffd_trade.rds"))
