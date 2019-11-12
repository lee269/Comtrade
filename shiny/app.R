library(shiny)
library(tidyverse)

source(here::here("shiny", "modules.R"))

ffd_indicators <- readRDS(here::here("data", "db", "ffd_indicators.rds"))

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(country_select_mod_ui(id = "country_selected", data = ffd_indicators)),
    mainPanel(country_indicators_mod_ui(id = "indicators"))
  )
)


server <- function(input, output, session){
  country_selected <- callModule(country_select_mod_server, "country_selected")
  res <- callModule(country_indicators_mod_server, "indicators", dataset = ffd_indicators, country = country_selected)
}

shinyApp(ui = ui, server = server)