#------------------------------------------#
#   Banco Inter-americano de Desarrollo    #
#       Agregador Indicadores              #
#                                          #
# Autores:                                 #
#        Alejandro Rodriguez               #
#------------------------------------------#

#------------------------------------------#
#            No Ceilings Data              #
#                                          #
#   Downloaded from www.noceilings.org     #
#------------------------------------------#

#No ceiling data is an innitiative developed by the Clinton Foundation.
#This was a one time effort that gathered data from multiple sources.
#Information regarding renovating this effort is not yet defined.


#' Download Data from the No Ceilings www.noceilings.org
#'
#' @param country Character vector of country or region codes. Default value is special code of \code{all}.
#'  Other permissible values are codes in the following fields from the \code{\link{ai_cachelist}} \code{countries_idb}
#'  data frame.  \code{iso2c}
#' @param indicator Character vector of indicator codes. These codes correspond to the \code{src_id_ind} column
#'  from the \code{indicator} data frame of \code{\link{ai_cache}} or \code{\link{ai_cachelist}}, or
#'  the result of \code{\link{ai_search}}
#' @param startdate Numeric. Year (four digit) of the start of the requested date range.
#' @param enddate Numeric. Year (four digit) of the end of the requested date range.
#' @param cache List of data frames returned from \code{\link{ai_cache}}. If omitted,
#'  \code{\link{ai)_cachelist}} is used
#' @param lang Language in which to return the results. If \code{lang} is unspecified,
#'  english is the default.
#' @return Data frame with all available requested data.
#'
#' @note Not all data returns have support for langauges other than english. If the specific return
#'  does not support your requested language by default it will return \code{NA}.
#'  The options for \code{lang} are:
#'  \itemize{
#'  \item \code{en}: English
#'  \item \code{es}: Spanish
#'  \item \code{fr}: French
#'  \item \code{ar}: Arabic
#'  \item \code{zh}: Mandarin
#'  }
#'  If there is no data available that matches the request parameters, an empty data frame is returned along with a
#'  \code{warning}.
#'
#'  @examples
#' load.NC.data(pIndicators=c("CONTFEHQ"))
#' pIndicators=c("CONTFEHQ",pStart=2013,pEnd=2015, pCountry='all')
#' @export
load.NC.data <- function(pIndicators=c("CONTFEHQ"),pStart=2010,pEnd=2015, pCountry='all', cache){

  if (missing(cache)) cache <- agregadorindicadores::ai_cachelist
  
  dfList<-list()

  #merge all indicators
  df<-cache$no_ceilings
  
  #load countries
  df_wb_ct<-cache$countries_wb
  
  indicators<-as.data.frame(pIndicators)
  colnames(indicators)<-c("src_id_ind")
  
  #Format Country and filter time
  sql <- sprintf("select df_wb_ct.iso2c as iso2, 
                 df_wb_ct.country, 
                 df.year as year, 
                 df.src_id_ind, 
                 df.value 
                 from df join df_wb_ct on df.iso=df_wb_ct.iso3c
                 where df.src_id_ind in (select src_id_ind from indicators) 
                and df.year>= %s and df.year<= %s", pStart, pEnd)
  
  df_ncd<-sqldf::sqldf(sql)
  
  #Filter Countries
  if(!('all' %in% pCountry))
  {
    df_ct<-as.data.frame(pCountry)
    colnames(df_ct)<-"iso2"
    
    df_ncd<-sqldf::sqldf("select * from df_ncd where iso2 in (select iso2 from df_ct)")
  }
  
  df_ncd$iso2<-as.character(df_ncd$iso2)
  
  return(df_ncd)
  
}

#' Download updated indicator metadata from Numbers for Development (N4D) API
#'
#' @return A data frame of available indicators with related metadata
#' @note The only language supported for this source of information is english
#' 
#' @examples 
#' load.NC.metadata()
#' @export
load.NC.metadata<-function()
{
  
  #suppressWarnings(suppressMessages(library(dplyr)))
  
  #Download Metadata
  url_meta="https://raw.githubusercontent.com/fathominfo/noceilings-data/master/indicators.csv"
  df_nc_meta<-read.csv(url(url_meta))
  
  #Filter World Bank
  df_nc_meta<-df_nc_meta %>% filter(!grepl("World Bank", source))
  
  df_nc_meta<-schemaMatch(df_nc_meta,api="No Ceilings",id_api="ncd")
  
  #detach("package:dplyr", unload=TRUE) 
  
  return(df_nc_meta)
  
}

#' @export
cache.NC.data <- function(){
  
  #suppressWarnings(suppressMessages(library(dplyr)))
  #suppressWarnings(suppressMessages(library(tidyr)))

  # Download and unzip data
  downloader::download("https://github.com/fathominfo/noceilings-data/archive/master.zip", dest="dataset.zip", mode="wb")
  
  unzip ("dataset.zip", overwrite=T)
  
  ############################################
  #                                          #
  #        Importing untransformed data      #
  #                                          #
  ############################################
  
  # Get file names
  files <- list.files('./noceilings-data-master/csv')
  
  wd <- getwd()
  
  setwd('./noceilings-data-master/csv')
  
  outputNCD<-paste0(wd,"/data/NCD.csv")
  
  write.table(c("iso,src_id_ind,year,value"),outputNCD, row.names=F,na="NA",append=FALSE, quote= FALSE, sep=",", col.names=F)
  
  # LOOP to create dataframes from all csv files
  #indicator_list <- list()
  for(i in 1:length(files)){
    
    f = readLines(files[i])                           # used for counts
    temp = read.csv(files[i], nrows = length(f) - 7)  # removes the last 7 lines of csv
    fname = stringr::str_sub(files[i],1,-5) # remove .csv from the file name
    temp$series = rep(fname, nrow(temp)) # creates a variable with the indicator name
    
    #put in the appropriate structure (from wide to long form)
    temp <- gather(temp, year, value, 2:(length(names(temp))-1)) %>%  filter(value != "")
    
    #remove rows that have NAs in value variable
    temp <- temp[!is.na(temp$value),]
    
    #convert text "yes/no" rows into numeric 1/0 values  
    temp <- temp %>%
      mutate(value = ifelse(value=="yes","1",ifelse(value=="no","0",value)))
    
    #ensure that all data have numeric value
    temp$value <- as.numeric(temp$value)
   
    temp$year<-gsub("X","",temp$year) 
    write.table(temp,outputNCD, row.names=F,na="NA",append=T, quote= FALSE, sep=",", col.names=F)
  }
  
  setwd(wd)
  
  df<-read.csv("./data/NCD.csv")
  
  #Delete files
  unlink("./data/NCD.csv", recursive = TRUE, force = TRUE)
  unlink("dataset.zip", recursive = TRUE, force = TRUE)
  unlink("noceilings-data-master", recursive = TRUE, force = TRUE)
  
  #detach("package:dplyr", unload=TRUE) 
  #detach("package:tidyr", unload=TRUE) 

  return(df)
  
}
  
