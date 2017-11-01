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
#' \item \code{fr}: French
#' \item \code{ar}: Arabic - only for the World Bank
#' \item \code{zh}: Mandarin - only for the World Bank
#' }
#' @param startdate Start date of the requested date range of the indicator data
#' @param enddate End date of the requsted date range of the indicator data
#' @param country List of countries. If \code{country} is unspecified,
#' 'all' is the default.
#' @param cache Cache of the metadata of the indicators, countries and topics
#' @return A data frame with the data of the indicator, countries and date range specified
#' @examples
#' # default is english. To specific another language use argument lang
#' ai(indicator = c("SOC_046","SL.UEM.TOTL.NE.ZS"),lang = "en")
#' ai(indicator = c("CONTFEHQ","SOC_046","SL.UEM.TOTL.NE.ZS"),country = c("CO"),startdate = 2000,enddate = 2015)
#' @export
ai <- function(country = "all", indicator, startdate=2010, enddate=2015,
               lang = c("en", "es", "fr", "ar", "zh"), meta=TRUE,cache)
{
  
  if (missing(cache)) cache <- agregadorindicadores::ai_cachelist
  
  ind<-cache$indicators
  
  df_ind<-as.data.frame(indicator)
  colnames(df_ind)<-"src_id_ind"
  indicators<-sqldf::sqldf("select src_id_ind,api from df_ind join ind using(src_id_ind)")
  
  nr_df=1
  df_list<-list()
  
  #WB
  wb_ind<-indicators[indicators$api=="World Bank",]$src_id_ind
  if(length(wb_ind)>0)
  {
    df_list[[nr_df]]<-load.WB.data(pIndicators = wb_ind, pCountry=country,pStart = startdate,pEnd=enddate)
    nr_df=nr_df+1
  }
  
  #N4D
  n4d_ind<-indicators[indicators$api=="Numbers for Development",]$src_id_ind
  if(length(n4d_ind)>0)
  {
    df_list[[nr_df]]<-load.N4D.data(pIndicators = n4d_ind, pCountry=country,pStart = startdate,pEnd=enddate)
    nr_df=nr_df+1
  }
  
  #NCD
  nc_ind<-indicators[indicators$api=="No Ceilings",]$src_id_ind
  if(length(nc_ind)>0)
  {
    df_list[[nr_df]]<-load.NC.data(pIndicators = nc_ind, pCountry=country,pStart = startdate,pEnd=enddate)
    nr_df=nr_df+1
  }
  
  df<-dplyr::bind_rows(df_list)
  
  if(meta)
  {
    df<-sqldf::sqldf("select * from df join ind using(src_id_ind)")
    
    #remove rows where indicator name=NA
    df <- df[!is.na(df$indicator),]
    
  }
  
  df
}

ai_normalize<-function(data)
{
  country_df<-agregadorindicadores::ai_cachelist$countries_wb
  
  df_ind_year<-sqldf::sqldf("SELECT src_id_ind, year, avg(value) as mean, stdev(value) as stddev, count(*) as total
                            from data JOIN country_df on iso2=iso2c
                            where income='Aggregates'
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