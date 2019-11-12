library(tidyverse)
library(broom)

ffd_trade <- readRDS(here::here("data", "db", "ffd_trade.rds"))

# Trying to make up some useful indicators
all_data <- ffd_trade %>% 
  group_by(reporter_code, reporter_iso, reporter) %>% 
  summarise(n = n()) %>% 
  select(-n)

# Total food imports
total_food_imports <- ffd_trade %>% 
                        filter(partner_iso == "WLD") %>% 
                        group_by(reporter, year) %>% 
                        summarise(total_food_imports = sum(trade_value_us)) %>% 
                        group_by(reporter) %>% 
                        mutate(max = max(year)) %>% 
                        filter(year == max) %>% 
                        select(-max)

# UK food imports
uk_food_imports <- ffd_trade %>% 
  filter(partner_iso == "GBR") %>% 
  group_by(reporter, year) %>% 
  summarise(uk_food_imports = sum(trade_value_us)) %>% 
  group_by(reporter) %>% 
  mutate(max = max(year)) %>%   
  filter(year == max) %>%
  select(-max)



indicators <- ffd_trade %>% 
  filter(partner_iso %in% c("WLD", "GBR")) %>% 
  select(year, reporter, partner_iso, commodity, commodity_code, trade_value_us) %>%
  group_by(year, reporter, partner_iso) %>% 
  summarise(trade_value_us = sum(trade_value_us)) %>% 
  pivot_wider(id_cols = c(year, reporter), names_from = partner_iso, values_from = trade_value_us) %>% 
  filter(GBR > 0) %>% 
  mutate(uk_market_share = (GBR/WLD)*100) %>% 
  arrange(reporter, year)


# https://community.rstudio.com/t/extract-slopes-by-group-broom-dplyr/2751
uk_mkt_share_growth <- indicators %>% 
  group_by(reporter) %>% 
  nest() %>% 
  mutate(model = map(data, ~lm(uk_market_share ~ year, data = .x) %>% tidy)) %>% 
  unnest(model) %>% 
  filter(term == "year") %>% 
  mutate(uk_mkt_share_growth = estimate * 100) %>% 
  select(reporter, uk_mkt_share_growth)

all_data <- all_data %>% 
            left_join(total_food_imports) %>% 
            left_join(uk_food_imports) %>% 
            left_join(uk_mkt_share_growth)
  
# saveRDS(all_data, here::here("data", "db", "ffd_indicators.rds"))

trade_model <- function(df) {
  lm(uk_market_share ~ year, data = df)
}

mods <- indicators %>% 
  group_by(reporter) %>% 
  nest() %>% 
  mutate(model = map(data, trade_model),
         details = coefficients(model),
         preds = map2(data, model, modelr::add_predictions)) 


preds <- unnest(mods, preds)

preds %>% 
  filter(reporter != "Ireland") %>% 
  ggplot(aes(x = year, colour = reporter)) +
  geom_line(aes(y = pred, group = reporter), alpha = 1 / 3) + 
  geom_line(aes(y = uk_market_share, group = reporter), alpha = 1 / 3) +
  geom_smooth(aes(y = pred), se = FALSE) +
  facet_grid(~ reporter) +
  theme(legend.position = "none")


cncodes <- read_csv(here::here("data", "reference", "CN CODES MASTER TABLE.csv")) %>% 
  select(`HS6 code`, `HS6 Description`, `FFD DESC`) %>% 
  group_by(`HS6 code`, `FFD DESC`) %>% 
  summarise(count = n()) %>% 
  filter(`FFD DESC` != "Not entered")

cncodes$`HS6 code`[duplicated(cncodes$`HS6 code`)]

