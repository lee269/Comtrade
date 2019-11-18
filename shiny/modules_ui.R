#' Country selection for dashboard
#' Generates a selectinput box for countries
#' 
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}} 
#' @param data, dataset containing reporter and reporter_iso codes
#' @param label, text label for the input box
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements - a select box for countries
#' @export
#'
#' @examples
country_select_mod_ui <- function(id, data, label = "Select country:"){
  ns <- NS(id)
  
  # https://rpodcast.shinyapps.io/modules_article1/
  countries <- data %>% 
    ungroup() %>% 
    select(reporter, reporter_iso) %>% 
    deframe()
  
  tagList(
    selectInput(inputId = ns("country"), label = label, choices = countries)
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



#' Country trade indicators for dashboard
#' 
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}} 
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements - a table of indicators.
#' @export
#'
#' @examples
country_indicators_mod_ui <- function(id){
  ns <- NS(id)
  tagList(
    DT::dataTableOutput(outputId = ns("country_indicators"))
  )
}
