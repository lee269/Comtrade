# Download complete trade for one country for one year.
# period: year to request
# reporter: country id
# token: bulk dowload api access token
# dest_folder: folder to save file in format id-year.csv
get_country_year <- function(period = "2016",
                             reporter = "152",
                             token = "",
                             dest_folder,
                             unzip = FALSE)
  {

    url <- "http://comtrade.un.org/api/get/bulk/"
    type <- "C"
    freq <- "A"
    classification <- "HS"
    token <- token
    
    string <- paste0(url,type, "/", freq, "/", period, "/", reporter, "/", classification,"?token=", token)

    tmp <- tempfile()
    download.file(string, destfile = tmp)
    
    if (unzip == FALSE) { 
      
      file.copy(from = tmp, to = paste0(dest_folder, "/", reporter, "-", period, ".zip"))
      
    } else {
      
      filename <- unzip(tmp, list = TRUE) 
      unzip(tmp, exdir = dest_folder)
      file.rename(from = paste0(dest_folder, "/", filename[1,1]),
                  to = paste0(dest_folder, "/", reporter, "-", period, ".csv"))
    }
}


