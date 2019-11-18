library(shiny)
library(tidyverse)
Sys.setenv(http_proxy="http://10.85.4.54:8080", https_proxy="https://10.85.4.54:8080")


# Setup -------------------------------------------------------------------
source(here::here("shiny", "modules_ui.R"))
source(here::here("shiny", "modules_data.R"))
source(here::here("shiny", "modules_misc.R"))

ffd_indicators <- readRDS(here::here("data", "db", "ffd_indicators.rds")) %>% ungroup()
wb_indicators <- readRDS(here::here("data", "db", "wb_indicators.rds")) %>% ungroup()
world <- map_data("world")
world <- world %>% left_join(ffd_indicators, by = c("region" = "reporter"))

# Something about this csv - if I load it all up the flags stop working - if I
# just take the iso and flag png, it works. Need to fix this becuse there is
# more useful metadata in it.
country_meta <- read_csv(here::here("data", "reference", "countries.csv")) %>% select(reporter_iso, png)



# UI ----------------------------------------------------------------------
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(country_select_mod_ui(id = "country_selected", data = ffd_indicators),
                 country_flag_mod_ui(id = "flag"),
                 country_map_mod_ui(id = "map")
                 ),
    mainPanel(
              wb_indicators_mod_ui(id = "indicators"),
              country_indicators_mod_ui(id = "ffd_indicators")
              )
  )
)


# Server ------------------------------------------------------------------
server <- function(input, output, session){
  country_selected <- callModule(country_select_mod_server, id = "country_selected")
  country_indicators <- callModule(country_indicators_mod_server,id =  "ffd_indicators", dataset = ffd_indicators, country = country_selected)
  country_flag <- callModule(country_flag_mod_server, id = "flag", dataset = country_meta, country = country_selected, height = "25%", width = "25%")
  country_map <- callModule(country_map_mod_server, id = "map", dataset = world, country = country_selected)
  indicators <- callModule(wb_indicators_mod_server, id =  "indicators", dataset = wb_indicators, country = country_selected)
}


shinyApp(ui = ui, server = server)
