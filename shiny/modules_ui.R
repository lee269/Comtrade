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
mod_ui_country_select <- function(id, data, label = "Select country:"){
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
mod_server_country_select <- function(input, output, session) {
  return(list(country = reactive(input$country)))
}



