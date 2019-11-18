library(tidyverse)
library(broom)
library(wbstats)

ffd_trade <- readRDS(here::here("data", "db", "ffd_trade.rds"))

# Get the countries we have in the db
all_data <- ffd_trade %>% 
  group_by(reporter_code, reporter_iso, reporter) %>% 
  summarise(n = n()) %>% 
  select(-n)

# World Bank reference data
# IC.BUS.EASE.XQ
ind_ids <- c("SP.POP.TOTL", "NY.GDP.PCAP.PP.KD", "NE.IMP.GNFS.ZS", "IC.BUS.EASE.XQ")
ind_text <- c("Population", "GDP per capita PPP", "Imports of goods and services (% GDP)", "Ease of doing business")
indicators <- data.frame(
  indicatorID = ind_ids,
  indicator_short_text = ind_text,
  stringsAsFactors = FALSE
)

# get data for selected indicators and countries 
countries <- as.vector(all_data$reporter_iso)
wbinds <- wb(indicator = ind_ids, mrv = 10, freq = "Y", country = countries) %>% 
          mutate(date = as.numeric(date))


# Rank the countries - assumes higher numbers are better (may not be true). Also
# only ranks the countries in the ffd_trade data. Could get WB data for all
# countries but wouyld then have to strip out a large number of country groups
# such as 'Arab world' etc
wbranks <- wbinds %>%
  group_by(date, indicatorID) %>% 
  mutate(indicator_rank = min_rank(-value)) %>%
  ungroup() %>% 
  group_by(iso3c, indicatorID) %>% 
  filter(date == max(date)) 



# Get growth rates for the indicators
wbgrowth <- wbinds %>% 
      group_by(iso3c, indicatorID) %>% 
      nest() %>% 
      mutate(model = map(data, ~lm(value ~ date, data = .x) %>% tidy)) %>% 
      unnest(model) %>% 
      filter(term == "date") %>% 
      mutate(indicator_growth = estimate * 100) %>% 
      select(iso3c, indicatorID, indicator_growth)

# Join tem all up and name consistently
wb_indicators <- wbranks %>% 
    left_join(wbgrowth) %>% 
    left_join(indicators) %>% 
    rename(reporter_iso = iso3c,
           year = date,
           reporter = country)


saveRDS(wb_indicators, here::here("data", "db", "wb_indicators.rds"))



  # mutate(quartile = ntile(avggrowth, 3)) %>% 