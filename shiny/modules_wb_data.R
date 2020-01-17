
#' World Bank indicators for dashboard
#' 
#' 
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}} 
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements - a table of indicators.
#' @export
#'
#' @examples
mod_ui_wb_indicators <- function(id){
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
mod_server_wb_indicators <- function(input, output, session, dataset, country){
  ind_table <- reactive({
    dt <- dataset %>% filter(reporter_iso == country$country())
    return(dt)
  })
  
  output$wb_indicators <- DT::renderDataTable({
    ind_table()
  })
}


#' Title
#'
#' @param id 
#'
#' @return
#' @export
#'
#' @examples
mod_ui_wb_meta <- function(id){
  ns <- NS(id)
  tagList(
    tags$strong(textOutput(outputId = ns("country_meta")))
  )
}


#' Title
#'
#' @param input 
#' @param output 
#' @param session 
#' @param dataset 
#' @param country 
#'
#' @return
#' @export
#'
#' @examples
mod_server_wb_meta <- function(input, output, session, dataset, country, indicator){
  wb_table <- reactive({
    dt <- dataset %>% filter(reporter_iso == country$country(), indicatorID == indicator())
    # dt <- subset(dataset, reporter_iso == country$country())
    # dt <- subset(dt, indicatorID == indicator)
    return(dt)
  })
  
  output$country_meta <- renderText({
    paste(wb_table()$indicator_short_text[1], ":", wb_table()$value[1])
  })
  
}
