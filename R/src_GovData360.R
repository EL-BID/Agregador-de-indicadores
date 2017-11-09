#------------------------------------------#
#                                          #
#   Banco Inter-americano de Desarrollo    #
#       Agregador Indicadores              #
#                                          #
# Autores:                                 #
#        Alejandro Rodriguez               #
#------------------------------------------#


#' Download updated indicator metadata from Govdata360 platform govdata360.worldbank.org
#'
#' @param lang Language in which to return the results. If \code{lang} is unspecified,
#' english is the default.
#'
#' @return A data frame of available indicators with related metadata
#'
#' @note Not all data returns have support for langauges other than english. If the specific return
#' does not support your requested language by default it will return \code{NA}.
#' The options for \code{lang} are:
#' \itemize{
#' \item \code{en}: English
#' \item \code{es}: Spanish
#' \item \code{fr}: French
#' \item \code{ar}: Arabic
#' \item \code{zh}: Mandarin
#' }
#' @examples
#' # default is english. To specific another language use argument lang
#' load.WB.medatada(lang = "es")
#' @export
load.360.medatada<-function(lang = c("en", "es", "fr", "ar", "zh"))
{
  #------------------------------------------#
  #       Download metadata                  #
  #------------------------------------------#
  
  df <- govdata360R::gov360msearch()
  
  df_360_metada<-schemaMatch(df,api="Govdata360",id_api="360")
  
  df_360_metada
}

#' Download indicator data from Govdata360 platform govdata360.worldbank.org
#'
#' This function downloads the requested information using govdata360 API
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
#' load.360.data(pIndicators=c("27870"))
#' 
#' load.360.data(pIndicators=c("27870","27873"),pStart=2013,pEnd=2015, pCountry='all')
#' @export
load.360.data <- function(pIndicators, pCountry = 'ALL', pStart=2010, pEnd=2015, cache){
  
  if (missing(cache)) cache <- agregadorindicadores::ai_cachelist
  
  #Format Countries

  #load countries
  df_wb_ct<-cache$countries_wb
  
  pCountry=toupper(pCountry)
  
  #Transform iso2 to iso3
  if(as.character(pCountry)!='ALL')
  {
    pCountry<-as.data.frame(pCountry)
    colnames(pCountry)<-c("iso3")
    
    #Format Country and filter time
    sql <- sprintf("select df_wb_ct.iso3c as iso3
                   from pCountry join df_wb_ct on pCountry.iso3=df_wb_ct.iso2c")
    
    pCountry<-as.vector(sqldf::sqldf(sql))
  }
   
  dr<-paste0(pStart:pEnd,collapse = ",")
 
  
  df_360 <- suppressWarnings(govdata360R::gov360stats.list(pIndicators = pIndicators, pCountry = pCountry,dateRange =dr ))
  
  
  #Change to iso2 country code
  sql <- sprintf("select 
                 df_wb_ct.iso2c as iso2, 
                 df_wb_ct.country as country, 
                 df_360.year as year, 
                 df_360.id as src_id_ind, 
                 df_360.value as value 
                 from df_360 join df_wb_ct on df_360.country=df_wb_ct.iso3c")
  df_360<-sqldf::sqldf(sql)
  
  df_360$year<-as.numeric(df_360$year)
  
  return(df_360)
  
}

