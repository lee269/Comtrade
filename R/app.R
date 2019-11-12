library(shiny)
library(tidyverse)

ffd_indicators <- readRDS(here::here("data", "db", "ffd_indicators.rds"))
countries <- ffd_indicators %>% 
              ungroup() %>% 
              select(reporter, reporter_iso) %>% 
              deframe()

indicator_table_mod <- function(input, output, session, data, country) ({
  dt <- reactive({
    data <- data %>% filter(reporter_iso == country)
    })
  
  output$indicator_table <- renderTable({
    dt()
  })
})

indicator_table_ui <- function(id) ({
  ns <- NS(id)
  tableOutput(ns("indicator_table"))
})


ui <- fluidPage(
  
  sidebarLayout(
    sidebarPanel("sidebar",
                 selectInput("country", label = "choose country", choices = countries)),
    mainPanel(textOutput("selected_country"),
              tableOutput("data"),
              indicator_table_ui("test"))
  )
  
)

server <- function(input, output)({
  
  output$selected_country <- renderText(paste("selected: ", input$country))
  output$data <- renderTable({
    data <- ffd_indicators %>% filter(reporter_iso == input$country)
  })
  callModule(indicator_table_mod, "test", data = ffd_indicators, country = 
               input$country)
  
})

shinyApp(ui = ui, server = server)
