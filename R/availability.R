# Produce a dataframe containing availability of data in the ffd_trade data

library(tidyverse)

reporters <- readRDS(here::here("data", "reference", "reporters.rds"))
ffd_trade <- readRDS(here("data", "db", "ffd_trade.rds"))


data <- ffd_trade %>% 
                select(reporter_code, reporter, year) %>% 
                group_by(reporter_code, reporter, year) %>% 
                summarise(count = TRUE) %>% 
                pivot_wider(names_from = year, values_from = year) %>% 
                select(-count)

availability <- reporters %>% 
      left_join(data, by = c("id" = "reporter_code")) %>% 
      select(-reporter) %>% 
      rename(reporter = text,
             reporter_code = id)
