library(tidyverse)


# Create reporter reference table
reporters <- jsonlite::fromJSON("https://comtrade.un.org/Data/cache/reporterAreas.json", flatten = TRUE)
reporters <- reporters$results %>% 
              filter(id != "all") %>% 
              mutate(id = as.numeric(id))

saveRDS(reporters, here::here("data", "reference", "reporters.rds"))
