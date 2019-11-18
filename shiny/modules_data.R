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


#' Country trade indicators module server
#'
#' @param input, output, session standard \code{shiny} boilerplate  
#' @param dataset, dataset (non-reactive) containing indicators and reporter_iso variable 
#' @param country, list containing reactive country name (reporter_iso) to filter on 
#'
#' @return
#' @export
#'
#' @examples
country_indicators_mod_server <- function(input, output, session, dataset, country){
  ind_table <- reactive({
    dt <- dataset %>% filter(reporter_iso == country$country())
    return(dt)
  })
  
  output$country_indicators <- DT::renderDataTable({
    ind_table()
  })
}



#' World Bank indicators for dashboard
#' 
#' 
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}} 
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements - a table of indicators.
#' @export
#'
#' @examples
wb_indicators_mod_ui <- function(id){
  ns <- NS(id)
  tagList(
    DT::dataTableOutput(outputId = ns("wb_indicators"))
  )
}


#' World Bank indicators module server
#'
#' @param input, output, session standard \code{shiny} boilerplate  
#' @param dataset, dataset (non-reactive) containing indicators and reporter_iso variable 
#' @param country, list containing reactive country name (reporter_iso) to filter on 
#'
#' @return a DT data table of indicators
#' @export
#'
#' @examples
wb_indicators_mod_server <- function(input, output, session, dataset, country){
  ind_table <- reactive({
    dt <- dataset %>% filter(reporter_iso == country$country())
    return(dt)
  })
  
  output$wb_indicators <- DT::renderDataTable({
    ind_table()
  })
}
