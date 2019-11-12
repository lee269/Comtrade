#' Country selection for dashboard
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}} 
#' @param data, dataset containing reporter and reporter_iso codes
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements - a select box for counrtries
#' @export
#'
#' @examples
country_select_mod_ui <- function(id, data){
  ns <- NS(id)
  
  # https://rpodcast.shinyapps.io/modules_article1/
  countries <- data %>% 
    ungroup() %>% 
    select(reporter, reporter_iso) %>% 
    deframe()
  
  tagList(
    selectInput(inputId = ns("country"), label = "choose country", choices = countries)
  )
}


#' Country selection module server side
#'
#' @param input, output, session standard \code{shiny} boilerplate 
#'
#' @return list with following components
#' \describe{
#'   \item{country}{reactive character string indicating reporter_iso selection}
#' }
#' @export
#'
#' @examples
country_select_mod_server <- function(input, output, session) {
  return(list(country = reactive(input$country)))
}



country_indicators_mod_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(column(width = 8, tableOutput(outputId = ns("country_indicators"))))
  )
}





country_indicators_mod_server <- function(input, output, session, dataset, country){
  ind_table <- reactive({
    dt <- dataset %>% filter(reporter_iso == country$country())
    return(dt)
  })
  
  output$country_indicators <- renderTable({
    ind_table()
  })
}


