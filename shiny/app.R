library(shiny)
library(tidyverse)

source(here::here("shiny", "modules.R"))

ffd_indicators <- readRDS(here::here("data", "db", "ffd_indicators.rds"))

# Something about this csv - if I load it all up the flags stop working - if I
# just take the iso and flag png, it works. Need to fix this becuse there is
# more useful metadata in it.
country_meta <- read_csv(here::here("data", "reference", "countries.csv")) %>% select(reporter_iso, png)



ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(country_select_mod_ui(id = "country_selected", data = ffd_indicators)),
    mainPanel(country_indicators_mod_ui(id = "indicators"),
              country_flag_mod_ui(id = "flag"))
  )
)


server <- function(input, output, session){
  country_selected <- callModule(country_select_mod_server, id = "country_selected")
  country_indicators <- callModule(country_indicators_mod_server,id =  "indicators", dataset = ffd_indicators, country = country_selected)
  country_flag <- callModule(country_flag_mod_server, id = "flag", dataset = country_meta, country = country_selected)
}

shinyApp(ui = ui, server = server)