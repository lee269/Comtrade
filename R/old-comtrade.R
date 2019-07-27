# install.packages("rjson")
# install.packages("RPostgreSQL")

  library(rjson)
  library('RPostgreSQL')

# Function definitions

# make names db safe: no '.' or other illegal characters,
# all lower case and unique
  dbSafeNames = function(names) {
    names = gsub('[^a-z0-9]+','_',tolower(names))
    names = make.names(names, unique=TRUE, allow_=TRUE)
    names = gsub('.','_',names, fixed=TRUE)
    names
  }

  get.Comtrade <- function(url="http://comtrade.un.org/api/get?"
                           ,maxrec=50000
                           ,type="C"
                           ,freq="A"
                           ,px="HS"
                           ,ps="now"
                           ,r
                           ,p
                           ,rg="all"
                           ,cc="TOTAL"
                           ,fmt="json"
  )
  {
    string<- paste(url
                   ,"max=",maxrec,"&" #maximum no. of records returned
                   ,"type=",type,"&" #type of trade (c=commodities)
                   ,"freq=",freq,"&" #frequency
                   ,"px=",px,"&" #classification
                   ,"ps=",ps,"&" #time period
                   ,"r=",r,"&" #reporting area
                   ,"p=",p,"&" #partner country
                   ,"rg=",rg,"&" #trade flow
                   ,"cc=",cc,"&" #classification code
                   ,"fmt=",fmt        #Format
                   ,sep = ""
    )
    
    if(fmt == "csv") {
      raw.data<- read.csv(string,header=TRUE)
      return(list(validation=NULL, data=raw.data))
    } else {
      if(fmt == "json" ) {
        raw.data<- fromJSON(file=string)
        data<- raw.data$dataset
        validation<- unlist(raw.data$validation, recursive=TRUE)
        ndata<- NULL
        if(length(data)> 0) {
          var.names<- names(data[[1]])
          data<- as.data.frame(t( sapply(data,rbind)))
          ndata<- NULL
          for(i in 1:ncol(data)){
            data[sapply(data[,i],is.null),i]<- NA
            ndata<- cbind(ndata, unlist(data[,i]))
          }
          ndata<- as.data.frame(ndata)
          colnames(ndata)<- var.names
        }
        return(list(validation=validation,data =ndata))
      }
    }
  }

  
  
  
  
# database driver
  pg = dbDriver("PostgreSQL")

# Local Postgres.app database; no password by default
# Of course, you fill in your own database information here.
  comtrade = dbConnect(pg, user="datascience7", password="",
                        host="localhost", port=5432, dbname="comtradev2")

# Read in FFD codes table - comcodes
  
  # comcodes <- read.csv("/Users/datascience7/Dropbox/Work/CN CODES MASTER TABLE.txt")
  # colnames(comcodes) <- dbSafeNames(colnames(comcodes))
  # 
  # if(dbExistsTable(comtrade, "comcodes")) {
  #   dbRemoveTable(comtrade, "comcodes")
  #   dbWriteTable(comtrade,'comcodes', comcodes, row.names = FALSE)
  # } else {
  #   dbWriteTable(comtrade,'comcodes', comcodes, row.names = FALSE)
  # }
  
  

# Read in reference tables from Comtrade
# Reporter countries table - reporters
  
  string <- "http://comtrade.un.org/data/cache/reporterAreas.json"
  reporters <- fromJSON(file=string)
  reporters <- as.data.frame(t(sapply(reporters$results,rbind)))
  names(reporters) <- c("id", "name")
  reporters$id <- as.character(reporters$id)
  reporters$name <- as.character(reporters$name)
  
  if(dbExistsTable(comtrade, "reporters")) {
    dbRemoveTable(comtrade, "reporters")
    dbWriteTable(comtrade,'reporters', reporters, row.names = FALSE)
  } else {
    dbWriteTable(comtrade,'reporters', reporters, row.names = FALSE)
  }

# Partner countries table - partners  
    
  string <- "http://comtrade.un.org/data/cache/partnerAreas.json"
  partners <- fromJSON(file=string)
  partners <- as.data.frame(t(sapply(partners$results,rbind)))
  names(partners) <- c("id", "name")
  partners$id <- as.character(partners$id)
  partners$name <- as.character(partners$name)
  
  if(dbExistsTable(comtrade, "partners")) {
    dbRemoveTable(comtrade, "partners")
    dbWriteTable(comtrade,'partners', partners, row.names = FALSE)
  } else {
    dbWriteTable(comtrade,'partners', partners, row.names = FALSE)
  }

  
# Comcodes table - hscodes
  
  string <- "http://comtrade.un.org/data/cache/classificationHS.json"
  hscodes <- fromJSON(file = string)
  hscodes <- as.data.frame(t(sapply(hscodes$results, rbind)))
  names(hscodes) <- c("id", "text", "parent")
  hscodes$id <- as.character(hscodes$id)
  hscodes$text <- as.character(hscodes$text)
  hscodes$parent <- as.character((hscodes$parent))


  if(dbExistsTable(comtrade, "hscodes")){
    dbRemoveTable(comtrade, "hscodes")
    dbWriteTable(comtrade, 'hscodes', hscodes, row.names = FALSE)
  } else {
    dbWriteTable(comtrade, 'hscodes', hscodes, row.names = FALSE)
  }
  
  
  
  
  
# Comcodes table - hs2012

  # string <- "http://comtrade.un.org/data/cache/classificationH4.json"
  # hs2012 <- fromJSON(file = string)
  # hs2012 <- as.data.frame(t(sapply(hs2012$results, rbind)))
  # names(hs2012) <- c("id", "text", "parent")
  # hs2012$id <- as.character(hs2012$id)
  # hs2012$text <- as.character(hs2012$text)
  # hs2012$parent <- as.character((hs2012$parent))
  # 
  # 
  # if(dbExistsTable(comtrade, "hs2012")){
  #   dbRemoveTable(comtrade, "hs2012")
  #   dbWriteTable(comtrade, 'hs2012', hs2012, row.names = FALSE)
  # } else {
  #   dbWriteTable(comtrade, 'hs2012', hs2012, row.names = FALSE)
  # }

# Trade flow table - flow

  string <- "http://comtrade.un.org/data/cache/tradeRegimes.json"
  flow <- fromJSON(file = string)
  flow <- as.data.frame(t(sapply(flow$results, rbind)))
  names(flow) <- c("id", "type")
  flow$id <- as.character(flow$id)
  flow$type <- as.character(flow$type)


  if(dbExistsTable(comtrade, "flow")) {
    dbRemoveTable(comtrade, "flow")
    dbWriteTable(comtrade, 'flow', flow, row.names = FALSE)
  } else {
    dbWriteTable(comtrade, 'flow', flow, row.names = FALSE)
  }



# Read in one years annual flow from Comtrade

  # for (i in reporters$id[2:nrow(reporters)]) {
  #   Sys.sleep(36) # 36 seconds to comply with max 100 requests/hr
  #   trade <- get.Comtrade(r=i, px = "HS", cc = "AG4", p = "all", ps = "2011", rg = "2", fmt = "csv")
  #   trade <- as.data.frame(sapply(trade$data, rbind))
  #   if (nrow(trade) == 50000) {
  #     print(paste("2011", i, reporters[reporters$id == i,2], "-1", "2",sep = "|"))
  #   } else {
  #     if (ncol(trade) > 1) {
  #       colnames(trade) <- dbSafeNames(colnames(trade))
  #       dbWriteTable(comtrade, 'trade', trade, row.names = FALSE, append = TRUE)
  #       print(paste("2011", i, reporters[reporters$id == i,2], nrow(trade), "2", sep="|"))
  #     } else {
  #       print(paste("2011", i, reporters[reporters$id == i,2], "0", "2", sep = "|"))
  #     }
  #   }
  # }

  
  # cat(paste("year","id","country", "rows", "flowid", sep = ","), file = logfile, append = TRUE, sep = "\n")
  #   
  # close(logfile)
  # 
  # trade <- get.Comtrade(r="826", px = "HS", cc = "AG4", p = "all", ps = "2011", rg = "2", fmt = "csv")
  # trade <- trade$data
  # colnames(trade) <- dbSafeNames(colnames(trade))
  # write.csv(trade, file = paste("/Users/datascience7/Dropbox/Work/Comtrade_v2/Downloads/","2011","_","2","_","826",".csv", sep = ""), row.names = FALSE)
  # dbWriteTable(comtrade, 'trade', trade, row.names = FALSE, append = TRUE)

  
  # Read in one years annual flow from Comtrade
# nrow(reporters)
  year <- "2015"
  flowtype <- "1"
  logfile <- paste("/Users/datascience7/Dropbox/Work/Comtrade_v2/Logfiles/", year, "_", flowtype, ".csv", sep = "")
  cat(paste("year","id","country", "rows", "flowid", sep = ","), file = logfile, append = FALSE, sep = "\n")
    
  for (i in reporters$id[2:nrow(reporters)]) {
    
    Sys.sleep(36) # 36 seconds to comply with max 100 requests/hr
    trade <- get.Comtrade(r=i, px = "HS", cc = "AG4", p = "all", ps = year, rg = flowtype, fmt = "csv")
    trade <- trade$data
    colnames(trade) <- dbSafeNames(colnames(trade))
    
    if (nrow(trade) == 50000) {
      
      print(paste(year, i, reporters[reporters$id == i,2], "-1", flowtype,sep = "|"))
      cat(paste(year, i, reporters[reporters$id == i,2], "-1", flowtype, sep = ","), file = logfile, append = TRUE, sep = "\n")      

    } else {
      if (nrow(trade) > 1 ) {
        
        write.csv(trade, file = paste("/Users/datascience7/Dropbox/Work/Comtrade_v2/Downloads/", year,"_", flowtype, "_", i,".csv", sep = ""), row.names = FALSE)
        dbWriteTable(comtrade, 'trade', trade, row.names = FALSE, append = TRUE)
        print(paste(year, i, reporters[reporters$id == i,2], nrow(trade), flowtype, sep="|"))
        cat(paste(year, i, reporters[reporters$id == i,2], nrow(trade), flowtype, sep = ","), file = logfile, append = TRUE, sep = "\n")      
        
      } else {
        
        print(paste(year, i, reporters[reporters$id == i,2], "0", flowtype, sep = "|"))
        cat(paste(year, i, reporters[reporters$id == i,2], "0", flowtype, sep = ","), file = logfile, append = TRUE, sep = "\n")      
        
      }
    }
  }
  

# Filter the yearly logs for the missing countries
  
  for (i in 2011:2015){
    yearlog <- read.csv(paste("/Users/datascience7/Dropbox/Work/Comtrade_v2/Logfiles/", i, "_1.csv", sep = ""), header = TRUE, quote = "")
    yearmiss <- yearlog[yearlog$rows == -1, ]
    write.csv(yearmiss, paste("/Users/datascience7/Dropbox/Work/Comtrade_v2/Logfiles/", i, "_1_missing.csv", sep = ""), row.names = FALSE)
  }  
  
  
    
  
# TEST fill in missing countries
  
  comtrademissing <- read.csv("/Users/datascience7/Dropbox/Work/Comtrade_v2/Logfiles/2015_1_missing.csv", header = TRUE)
  codes <- c("0101,0102,0103,0104,0105,0106,0201,0202,0203,0204,0205,0206,0207,0208,0209,0210,0301,0302,0303","0304,0305,0306,0307,0308,0401,0402,0403,0404,0405,0406,0407,0408,0409,0410,0501,0502,0503,0504,0505","0506,0507,0508,0509,0510,0511,0601,0602,0603,0604,0701,0702,0703,0704,0705,0706,0707,0708,0709,0710","0711,0712,0713,0714,0801,0802,0803,0804,0805,0806,0807,0808,0809,0810,0811,0812,0813,0814,0901,0902","0903,0904,0905,0906,0907,0908,0909,910,1001,1002,1003,1004,1005,1006,1007,1008,1101,1102,1103,1104","1105,1106,1107,1108,1109,1201,1202,1203,1204,1205,1206,1207,1208,1209,1210,1211,1212,1213,1214,1301","1302,1401,1402,1403,1404,1501,1502,1503,1504,1505,1506,1507,1508,1509,1510,1511,1512,1513,1514,1515","1516,1517,1518,1519,1520,1521,1522,1601,1602,1603,1604,1605,1701,1702,1703,1704,1801,1802,1803,1804","1805,1806,1901,1902,1903,1904,1905,2001,2002,2003,2004,2005,2006,2007,2008,2009,2101,2102,2103,2104","2105,2106,2201,2202,2203,2204,2205,2206,2207,2208,2209,2301,2302,2303,2304,2305,2306,2307,2308,2309")
  ccs <- as.data.frame(codes)


  for(i in 1:nrow(comtrademissing)){
    for(j in 1:nrow(ccs)){
      
#      print(paste(comtrademissing$id[i], comtrademissing$year[i], comtrademissing$flowid[i], ccs[j,1], sep = " x "))
      Sys.sleep(36) # 36 seconds to comply with max 100 requests/hr
      missingcountries <- get.Comtrade(r=comtrademissing$id[i], px = "HS", cc = ccs[j,1], p = "all", ps = comtrademissing$year[i], rg = comtrademissing$flowid[i], fmt = "csv")
      missingcountries <- missingcountries$data
      colnames(missingcountries) <- dbSafeNames(colnames(missingcountries))
      
      if (nrow(missingcountries) == 50000) {
        
        print(paste(i, comtrademissing$id[i], comtrademissing$country[i], "reached maxrows", sep = "|"))
      
      } else {
      
          if (nrow(missingcountries) > 1) {
      
            write.csv(missingcountries, file = paste("/Users/datascience7/Dropbox/Work/Comtrade_v2/Downloads/", comtrademissing$year[i], "_", comtrademissing$flowid[i], "_", comtrademissing$id[i], "_", j, ".csv", sep = ""), row.names = FALSE)

            dbWriteTable(comtrade, 'missingcountries', missingcountries, row.names = FALSE, append = TRUE)
            print(paste(i, comtrademissing$id[i], comtrademissing$country[i], nrow(missingcountries), "rows", sep = "|"))

            } else {
    
            print(paste(i, comtrademissing$id[i], comtrademissing$country[i], "no data", sep = "|"))
        }
      }
    }
  }

  
  