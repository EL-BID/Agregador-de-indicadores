#------------------------------------------#
#   Banco Inter-americano de Desarrollo    #
#       Agregador Indicadores              #
#                                          #
# Autores:                                 #
#        Alejandro Rodriguez               #
#------------------------------------------#

#------------------------------------------#
#     Banco Inter-americano de Desarrollo  #
#       Numbers for Development (N4D)      #
#------------------------------------------#

#' Download Data from the Numbers for Development (N4D)
#'
#' This function downloads the requested information using the Numbers for Development API
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
#' load.NC.data(pIndicators=c("SOC_046"))
#' pIndicators=c("SOC_046",pStart=2013,pEnd=2015, pCountry='all')
#' @export
load.N4D.data <- function(pIndicators, pCountry = 'all', pStart=2010, pEnd=2015, cache){
  
  if (missing(cache)) cache <- agregadorindicadores::ai_cachelist
  
  df_iadb_ct<-cache$countries_idb
  
  #Transform ISO2 to IDB code
  if(!('all' %in% pCountry))
  {
    pCountry<-as.data.frame(pCountry)
    colnames(pCountry)<-c("WB2code")
    
    pCountry<-as.vector(sqldf::sqldf("select CountryCode from pCountry join df_iadb_ct using (WB2code)")$CountryCode)
  }
  
  #Download data from indicators
  df<-iadbstats::iadbstats.list(indicatorCodes=pIndicators,country = pCountry)
  
  #Select columns
  df <-dplyr::select(df, -CountryTableName, -IndicatorName, -SubTopicName , -Quarter, -Month, -AggregationLevel, -UOM, -TopicName)
  
  #Format Country and filter time
  sql <- sprintf("select df_iadb_ct.WB2Code as iso2, 
                 df_iadb_ct.CountryTableName as country, 
                 df.year as year, 
                 df.IndicatorCode as src_id_ind, 
                 df.AggregatedValue as value 
                 from df join df_iadb_ct using (CountryCode)
                 where df.year>= %s and df.year<= %s", pStart, pEnd)
  
  df_n4d<-sqldf::sqldf(sql)
  
  df_n4d$year<-as.numeric(df_n4d$year)
  df_n4d$value<-as.numeric(df_n4d$value)
  

  return(df_n4d)
  
}


#' Download updated indicator metadata from Numbers for Development (N4D) API
#'
#' @param lang Language in which to return the results. If \code{lang} is unspecified,
#' english is the default.
#'
#' @return A data frame of available indicators with related metadata
#'
#' @note Not all indicators have support for langauges other than english. If the specific return
#' does not support your requested language by default it will return \code{NA}. .
#' The options for \code{lang} are:
#' \itemize{
#' \item \code{en}: English
#' \item \code{es}: Spanish
#' }
#' @examples
#' # default is english. To specific another language use argument lang
#' load.N4D.metadata(lang = "es")
#' @export
load.N4D.metadata<-function(lang = c("en", "es"))
{
  df<-iadbstats::iadbmsearch('ALL',lang = lang)
  
  df_n4d_metada<-schemaMatch(df,api="Numbers for Development",id_api="n4d")
  
  df_n4d_metada
}