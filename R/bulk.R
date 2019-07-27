library(here)
library(data.table)
library(sqldf)
library(tidyverse)

ct <- fread(here("Downloads", "ct2015.csv"), stringsAsFactors = FALSE, verbose = TRUE)
# ct <- read.csv.sql(here("Downloads", "ct2012.csv"), sql = "select * from file where 'Trade Flow' = 'Import'")
saveRDS(ct, here("Downloads", "ct2015.rds"))

ct <- readRDS(here("Downloads", "ct2012.rds"))

colnames(ct) <- dbSafeNames(colnames(ct))

ct <- ct %>% 
      filter(trade_flow_code == 1)

saveRDS(ct, here("Downloads", "ct2015i.rds"))


cncodes <- read_csv(here("Downloads", "CN CODES MASTER TABLE.csv"),  col_types = "cccccccccccccccccccccccccccc")
colnames(cncodes) <- dbSafeNames(colnames(cncodes))



food <- cncodes$hs6_code

ctfood <- ct %>% 
          filter(commodity_code %in% food)


x <- ctfood %>% 
      select(aggregate_level, commodity_code) %>% 
      group_by(aggregate_level, commodity_code) %>%
      summarise(count = n())