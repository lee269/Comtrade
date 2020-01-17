library(shiny)
library(tidyverse)
# Sys.setenv(http_proxy="http://10.85.4.54:8080", https_proxy="https://10.85.4.54:8080")


# Setup -------------------------------------------------------------------
source(here::here("shiny", "modules_ui.R"))
source(here::here("shiny", "modules_wb_data.R"))
source(here::here("shiny", "modules_trade_data.R"))
source(here::here("shiny", "modules_misc.R"))

ffd_indicators <- readRDS(here::here("data", "db", "ffd_indicators.rds")) %>% ungroup()
wb_indicators <- readRDS(here::here("data", "db", "wb_indicators.rds")) %>% ungroup()
world <- map_data("world")
world <- world %>% left_join(ffd_indicators, by = c("region" = "reporter"))

# Something about this csv - if I load it all up the flags stop working - if I
# just take the iso and flag png, it works. Need to fix this becuse there is
# more useful metadata in it.
# country_meta <- read_csv(here::here("data", "reference", "countries.csv")) %>% select(reporter_iso, png)
country_meta <- readRDS(here::here("data", "reference", "countries.rds")) %>% select(reporter_iso, png)


# UI Elements -------------------------------------------------------------

# we
country_selector <- wellPanel(mod_ui_country_select(id = "country_selected", data = ffd_indicators)) 

flag_section <- wellPanel(
                  splitLayout(mod_ui_country_flag(id = "flag"),
                              mod_ui_country_map(id = "map", height = 100, width = 100),
                              cellWidths = c("40%", "60%"))
                         )

country_details <- wellPanel(mod_ui_wb_meta(id = "country_desc")
                             )

body_section <- mainPanel(tags$h3("Some stuff"),
                          mod_ui_wb_indicators(id = "indicators"),
                          tags$h3("And some more stuff"),
                          mod_ui_trade_indicators(id = "ffd_indicators")
                          )

# UI ----------------------------------------------------------------------
ui <- fluidPage(
        # titlePanel("Dashboard"),
        column(width = 3,
               fluidRow(country_selector),
               fluidRow(flag_section),
               fluidRow(country_details)
               ),
        column(width = 9,
               fluidRow(body_section)
               )
            )


# Server ------------------------------------------------------------------
server <- function(input, output, session){
  country_selected <- callModule(mod_server_country_select, id = "country_selected")
  country_flag <- callModule(mod_server_country_flag, id = "flag", dataset = country_meta, country = country_selected, height = "66", width = "100")
  country_map <- callModule(mod_server_country_map, id = "map", dataset = world, country = country_selected)
  trade_indicators <- callModule(mod_server_trade_indicators,id =  "ffd_indicators", dataset = ffd_indicators, country = country_selected)
  indicators <- callModule(mod_server_wb_indicators, id =  "indicators", dataset = wb_indicators, country = country_selected)
  wb_text <- callModule(mod_server_wb_meta, id = "country_desc", dataset = wb_indicators, country = country_selected, indicator = reactive("NY.GDP.PCAP.PP.KD"))

}


shinyApp(ui = ui, server = server)
