#' Country flag images for dashboard
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}  
#'
#' @returna \code{shiny::\link[shiny]{tagList}} containing UI elements - an image link.
#' @export
#'
#' @examples
mod_ui_country_flag <- function(id){
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
#'   urls to country flag images. Currently expect this dataset to have
#'   'reporter_iso' and 'png'. Should change this to specify using tidy
#'   evaluation in the future.
#' @param country, list containing reactive country name (reporter_iso) to
#'   filter on
#' @param height, text containing either percentage ("50%") or pixel size
#'   ("640")
#' @param width, text containing either percentage ("50%") or pixel size ("640")
#'
#' @return
#' @export
#'
#' @examples
mod_server_country_flag <- function(input, output, session, dataset, country, height = "100%", width = "100%"){
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
mod_ui_country_map <- function(id, height = "100%", width = "100%"){
  ns <- NS(id)
  tagList(
    plotOutput(outputId = ns("country_map_plot"), height = height, width = height)
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
mod_server_country_map <- function(input, output, session, dataset, country){
  country_map <- reactive({
    dt <- dataset %>% filter(reporter_iso == country$country()) 
    return(dt)
  })
  
  output$country_map_plot <- renderPlot({
    ggplot() + geom_polygon(data = country_map(), aes(x = long, y = lat, group = group), fill = "gray50") + 
      coord_fixed(1.3) +
      theme_void() + theme(plot.background = element_rect(fill = "#f5f5f5", colour = "#f5f5f5"))
  }, bg = "#f5f5f5")
}
