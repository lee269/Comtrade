# Extracts FFD level data at 4 digit from a comtrade bulk download zipfile
# file is the zipfile to process
extract_ffd <- function(file){
  require(tidyverse)
  source(here::here("R", "db_safe_names.R"))
  print(paste("Processing:", file))
  tmpdir <- tempdir()
  # get the csv filename from within the zipfile
  filename <- unzip(file, list = TRUE)[1,1]
  
  # unzip into temporary directory, read in the csv and clean up (because the unzipped csvs can be massive)
  unzip(file, exdir = tmpdir)
  all_trade <- read_csv(paste0(tmpdir,"/", filename))
  file.remove(paste0(tmpdir,"/", filename))
  
  
  hs4 <- c("0201", "0202", "0203", "0204", "0205", "0206", "0207", "0208", "0209", "0210", "0301", "0302", "0303", "0304", "0305", "0306", "0307", "0308", "0401",
           "0402", "0403", "0404", "0405", "0406", "0407", "0408", "0409", "0410", "0502", "0503", "0504", "0505", "0506", "0507", "0508", "0509", "0510", "0511",
           "0601", "0602", "0603", "0604", "0701", "0702", "0703", "0704", "0705", "0706", "0707", "0708", "0709", "0710", "0711", "0712", "0713", "0714", "0801",
           "0802", "0803", "0804", "0805", "0806", "0807", "0808", "0809", "0810", "0811", "0812", "0813", "0814", "0901", "0902", "0903", "0904", "0905", "0906",
           "0907", "0908", "0909", "0910", "1001", "1002", "1003", "1004", "1005", "1006", "1007", "1008", "1101", "1102", "1103", "1104", "1105", "1106", "1107",
           "1108", "1109", "1201", "1202", "1203", "1204", "1205", "1206", "1207", "1208", "1209", "1210", "1211", "1212", "1213", "1214", "1301", "1302", "1401",
           "1402", "1403", "1404", "1501", "1502", "1503", "1504", "1505", "1506", "1507", "1508", "1509", "1510", "1511", "1512", "1513", "1514", "1515", "1516",
           "1517", "1518", "1519", "1520", "1521", "1522", "1601", "1602", "1603", "1604", "1605", "1701", "1702", "1703", "1704", "1801", "1802", "1803", "1804",
           "1805", "1806", "1901", "1902", "1903", "1904", "1905", "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009", "2101", "2102", "2103",
           "2104", "2105", "2106", "2201", "2202", "2203", "2204", "2205", "2206", "2207", "2208", "2209", "2301", "2302", "2303", "2304", "2305", "2306", "2307",
           "2308", "2309")
  
  # filter for food and drink and aggregate up to 4 digit, tidy up column names 
  ffd_trade <- all_trade %>% 
                filter(`Trade Flow Code` == 1,
                       `Aggregate Level` == 4,
                       `Commodity Code` %in% hs4) %>% 
                group_by(Year, `Trade Flow`, `Reporter Code`, Reporter, `Reporter ISO`, `Partner Code`, Partner, `Partner ISO`, `Commodity Code`) %>% 
                summarise(net_weight_kg = sum(`Netweight (kg)`), trade_value_us = sum(`Trade Value (US$)`)) %>% 
                ungroup()
  
  colnames(ffd_trade) <- db_safe_names(colnames(ffd_trade))
  return(ffd_trade)
}