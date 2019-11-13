#' Country selection for dashboard
#' Generates a selectinput box for countries
#' 
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}} 
#' @param data, dataset containing reporter and reporter_iso codes
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements - a select box for countries
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
    fluidRow(column(width = 8, tableOutput(outputId = ns("country_indicators"))))
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
  
  output$country_indicators <- renderTable({
    ind_table()
  })
}


#' Country flag images for dashboard
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}  
#'
#' @returna \code{shiny::\link[shiny]{tagList}} containing UI elements - an image link.
#' @export
#'
#' @examples
country_flag_mod_ui <- function(id){
  ns = NS(id)
  tagList(
    
      htmlOutput(outputId = ns("country_flag_url"))
             
  )
}


#' Country flag module server
#'
#' Solution for rendering url images from
#' https://github.com/khondula/image-viewer/blob/master/app.R
#'
#' @param input, output, session standard \code{shiny} boilerplate
#' @param dataset, dataset (non reactive) containing at least reporter_iso and
#'   urls to country flag images
#' @param country, list containing reactive country name (reporter_iso) to filter on 
#'
#' @return
#' @export
#'
#' @examples
country_flag_mod_server <- function(input, output, session, dataset, country){
  country_meta <- reactive({
    dt <- dataset %>% filter(reporter_iso == country$country()) %>% select(png) %>% as.character() 
    return(dt)
  })
  
  output$country_flag_url <- renderText({
    c('<img src="', country_meta(),'">')
  })
}