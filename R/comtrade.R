library(here)
library(rjson)


auth <- readRDS(here("keys", "auth.rds"))
authcode <- as.character(auth[1,1])

# make names db safe: no '.' or other illegal characters,
# all lower case and unique
dbSafeNames = function(names) {
  names = gsub('[^a-z0-9]+','_',tolower(names))
  names = make.names(names, unique=TRUE, allow_=TRUE)
  names = gsub('.','_',names, fixed=TRUE)
  names
}




getComtrade <- function(url="http://comtrade.un.org/api/get?"
                        ,maxrec=50000
                        ,type = "C"
                        ,freq = "A"
                        ,px = "HS"
                        ,ps = "now"
                        ,r
                        ,p
                        ,rg = "all"
                        ,cc = "TOTAL"
                        ,fmt = "json"
                        ,token = ""
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
                 ,"fmt=",fmt, "&"        #Format
                 ,"token=", token
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



string <- "http://comtrade.un.org/data/cache/reporterAreas.json"
reporters <- fromJSON(file=string)
reporters <- as.data.frame(t(sapply(reporters$results,rbind)))
names(reporters) <- c("id", "name")
reporters$id <- as.character(reporters$id)
reporters$name <- as.character(reporters$name)


year <- "2016"
flowtype <- "1"
logfile <- here("Logs", paste( year, "_", flowtype, ".csv", sep = ""))
cat(paste("year","id","country", "rows", "flowid", sep = ","), file = logfile, append = FALSE, sep = "\n")

for (i in reporters$id[2:nrow(reporters)]) {
  
  #Sys.sleep(36) # 36 seconds to comply with max 100 requests/hr
  trade <- getComtrade(maxrec = 250000, r=i, px = "HS", cc = "AG4", p = "all", ps = year, rg = flowtype, fmt = "csv", token = authcode)
  trade <- trade$data
  colnames(trade) <- dbSafeNames(colnames(trade))
  
  if (nrow(trade) == 250000) {
    
    print(paste(year, i, reporters[reporters$id == i,2], "-1", flowtype,sep = "|"))
    cat(paste(year, i, reporters[reporters$id == i,2], "-1", flowtype, sep = ","), file = logfile, append = TRUE, sep = "\n")      
    
  } else {
    if (nrow(trade) > 1 ) {
      
      write.csv(trade, file = here("Downloads", paste(year,"_", flowtype, "_", i,".csv", sep = "")), row.names = FALSE)
      # dbWriteTable(comtrade, 'trade', trade, row.names = FALSE, append = TRUE)
      print(paste(year, i, reporters[reporters$id == i,2], nrow(trade), flowtype, sep="|"))
      cat(paste(year, i, reporters[reporters$id == i,2], nrow(trade), flowtype, sep = ","), file = logfile, append = TRUE, sep = "\n")      
      
    } else {
      
      print(paste(year, i, reporters[reporters$id == i,2], "0", flowtype, sep = "|"))
      cat(paste(year, i, reporters[reporters$id == i,2], "0", flowtype, sep = ","), file = logfile, append = TRUE, sep = "\n")      
      
    }
  }
}


