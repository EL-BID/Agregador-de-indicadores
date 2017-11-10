#' Download data from indicators of the from World Bank API, Numbers for Development API and No Celings 
#'
#' @param lang Language in which to return the metadata of the indicators. If \code{lang} is unspecified,
#' english is the default.
#' @note Not all data returns have support for langauges other than english. Indicators from No Celings are only available in english. If the specific return
#' does not support your requested language by default it will return \code{NA}. For an enumeration of
#' supported languages by data source.
#' The options for \code{lang} are:
#' \itemize{
#' \item \code{en}: English
#' \item \code{es}: Spanish
#' }
#' @param startdate Start date of the requested date range of the indicator data
#' @param enddate End date of the requsted date range of the indicator data
#' @param country List of countries. If \code{country} is unspecified,
#' 'all' is the default.
#' @param cache Cache of the metadata of the indicators, countries and topics
#' @return A data frame with the data of the indicator, countries and date range specified
#' @examples
#' # Get the data for two indicators and all countries
#' ai(indicator = c("SOC_046","SL.UEM.TOTL.NE.ZS"))
#'
#' #Get the data for two indicators and one country from 2000 until 2015
#' ai(indicator = c("CONTFEHQ","SOC_046","SL.UEM.TOTL.NE.ZS"),country = c("CO"),startdate = 2000,enddate = 2015)
#' @export
ai <- function(country = "all", indicator, startdate=2010, enddate=2015,
               lang = c("en", "es", "fr", "ar", "zh"), meta=TRUE,cache)
{
  
  if (missing(cache)) cache <- agregadorindicadores::ai_cachelist
  
  #validate date range
  if(!(startdate <= enddate)){
    stop('La fecha inicial debe ser menor o igual a la fecha final. startdate <= enddate')
  }
  
  
  #Validate Countries
  if(!('all' %in% country)){
   
    countries_wb<-cache$countries_wb
    
    df_ct<-as.data.frame(country)
    colnames(df_ct)<-"iso2c"
    indicators<-sqldf::sqldf("select iso2c, iso3c from df_ct join countries_wb using(iso2c)")
    if(nrow(indicators)==0)
    {
      stop("Los países requeridos no son válidos.")    
    }
   
  }else{
    country = 'all'
  }
  
  
  
  
  if(length(indicator)>150) message("Por el número de indicadores, el procesamiento puede tardar unos minutos...") 
  
  ind<-cache$indicators
  
  df_ind<-as.data.frame(indicator)
  colnames(df_ind)<-"src_id_ind"
  indicators<-sqldf::sqldf("select src_id_ind,api from df_ind join ind using(src_id_ind)")
  
  nr_df=0
  df_list<-list()
  
  #World Bank
  wb_ind<-indicators[indicators$api=="World Bank",]$src_id_ind
  if(length(wb_ind)>0)
  {
   df_temp<-load.WB.data(pIndicators = wb_ind, pCountry=country,pStart = startdate,pEnd=enddate)
  
   if(length(df_temp)>1)
   {
     nr_df=nr_df+1
     df_list[[nr_df]]<-df_temp  
   }
  }
  
  #Numbers for Development 
  n4d_ind<-indicators[indicators$api=="Numbers for Development",]$src_id_ind
  if(length(n4d_ind)>0)
  {
    tryCatch(
      {
      df_temp<-load.N4D.data(pIndicators = n4d_ind, pCountry=country,pStart = startdate,pEnd=enddate, cache=cache)
      if(length(df_temp)>1)
      {
        nr_df=nr_df+1
        df_list[[nr_df]]<-df_temp 
      }
    }, warning = function(w) { 
      #do nothing
    }, error = function(e) {
      #do nothing
    }, finally = {
      #do nothing
    })
    
    
    
  }
  
  #No Ceilings 
  nc_ind<-indicators[indicators$api=="No Ceilings",]$src_id_ind
  if(length(nc_ind)>0)
  {
    df_temp<-load.NC.data(pIndicators = nc_ind, pCountry=country,pStart = startdate,pEnd=enddate, cache=cache)
    
    if(length(df_temp)>1)
    {
      nr_df=nr_df+1
      df_list[[nr_df]]<-df_temp  
    }
  }
  
  #Govdata360
  g360_ind<-indicators[indicators$api=="Govdata360",]$src_id_ind
  if(length(g360_ind)>0)
  {
    df_temp<-load.360.data(pIndicators = g360_ind, pCountry=country,pStart = startdate,pEnd=enddate, cache=cache)
    if(length(df_temp)>1)
    {
      nr_df=nr_df+1
      df_list[[nr_df]]<-df_temp  
    }
  }
  
  if(nr_df>0)
  {
    df<-dplyr::bind_rows(df_list)
    
    if(meta)
    {
      df<-sqldf::sqldf("select * from df join ind using(src_id_ind)")
      
      #remove rows where indicator name=NA
      df <- df[!is.na(df$indicator),]
      
    }
    
    return(df)
  }
  else
    {
      message("No se encontraron datos para la búsqueda solicitada")
      return("No data")
    }
}

#' Normalize the data per year and indicator
#'
#' Normalization process:
#' 
#' 1. Compute the mean (M) and the standar deviation (S) of the indicator value per year and indicator
#' 2. Compute the indicator value normalize with the following formula
#'    ind.value_norm=(value-M)/S * Multiplier
#'    
#'    where the Multiplier is 1 if the indicator is positive and -1 if the indicator is negativa. 
#'    A positive indicator means that higher values of the indicator are prefered (GDP per capita) 
#'    and negative indicator (unemployment rate) means that lower values are prefered.
#'    The multiplier is computed based on keywords found in the indicator. The keywords can be found in \code(agregadorindicadores::keywords)
#'
#' @note the metadata of the indicators should be in english 
#' @param data A dataframe generated by \code(ai())
#' @return A data frame with the data and the new column value_norm
#' @examples
#'
#' #Normalize all indicators of Numbers for Development for year 2014
#' ind<- ind_search(pattern = "Numbers for Development", c("api"))
#' df<-ai(indicator = ind$src_id_ind, startdate=2014, enddate=2014)
#' ai_normalize()
#' @export
ai_normalize<-function(data)
{
  country_df<-agregadorindicadores::ai_cachelist$countries_wb
  
  # Compute the mean
  df_ind_year<-sqldf::sqldf("SELECT src_id_ind, year, avg(value) as mean, stdev(value) as stddev, count(*) as total
                            from data JOIN country_df on iso2=iso2c
                            where income not like 'Aggregates'
                            group by YEAR, src_id_ind;")
  
  
  index <- df_ind_year$stddev == 0
  df_ind_year$stddev[index] <- 1 
  
  sqldf::sqldf("select 
               ind.*,
               (ind.VALUE-indY.mean)/indY.stddev*multiplier as value_norm,
               indY.total as nr_countries
               from 
               data ind LEFT outer JOIN df_ind_year indY
               ON  ind.src_id_ind= indY.src_id_ind
               AND ind.year= indY.year;")
  
}