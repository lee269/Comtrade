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
#' @param height, text containing either percentage ("50%") or pixel size ("640")
#' @param width, text containing either percentage ("50%") or pixel size ("640")
#'
#' @return
#' @export
#'
#' @examples
country_flag_mod_server <- function(input, output, session, dataset, country, height = "100%", width = "100%"){
  country_meta <- reactive({
    dt <- dataset %>% filter(reporter_iso == country$country()) %>% select(png) %>% as.character() 
    return(dt)
  })
  
  output$country_flag_url <- renderText({
    c('<img src="', country_meta(),'", height = "', height, '", width = "', width, '">')
  })
}


#' Country map for dashboard
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}  
#'
#' @return\code{shiny::\link[shiny]{tagList}} containing UI elements - a map plot.
#' @export
#'
#' @examples
country_map_mod_ui <- function(id){
  ns <- NS(id)
  tagList(
    plotOutput(outputId = ns("country_map_plot"))
  )
}



#' Country map module server
#'
#' @param input, output session standard \code{shiny} boilerplate
#' @param dataset, a non reactive dataframe of ggplot map_data("world"), joined
#'   with a dataframe of country names and iso3 codes. We use the codes to
#'   filter the map data.
#' @param country, list containing reactive country name (reporter_iso) to filter on 
#'
#' @return
#' @export
#'
#' @examples
country_map_mod_server <- function(input, output, session, dataset, country){
  country_map <- reactive({
    dt <- dataset %>% filter(reporter_iso == country$country()) 
    return(dt)
  })
  
  output$country_map_plot <- renderPlot({
    ggplot() + geom_polygon(data = country_map(), aes(x = long, y = lat, group = group), fill = "gray50") + 
      coord_fixed(1.3) +
      theme_void()
  })
}
