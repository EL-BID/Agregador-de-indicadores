#------------------------------------------#
#                                          #
#   Banco Inter-americano de Desarrollo    #
#       Agregador Indicadores              #
#                                          #
# Autores:                                 #
#        Alejandro Rodriguez               #
#------------------------------------------#

#------------------------------------------#
# Load and Harmonize a dataset from:       #
#------------------------------------------#
#                                          #
#             World Bank Data              #
#                                          #
#   Accessible through wbstats and WDI     #
#     packages in R                        #
#                                          #
#------------------------------------------#

#' Download Data from the World Bank data catalog using an API
#'
#' This function downloads the requested information using the World Bank API
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
#' load.WB.data(pIndicators=c("SL.UEM.TOTL.NE.ZS"))
#' 
#' load.WB.data(pIndicators=c("SL.UEM.TOTL.NE.ZS"),pStart=2013,pEnd=2015, pCountry='all')
#' @export
load.WB.data <- function(pIndicators, pCountry = 'all', pStart=2010, pEnd=2015){
  
  require(WDI)
  require(dplyr)
  
  #Download indicator data 
  df_wb <- suppressWarnings(WDI::WDI(indicator = pIndicators, country = pCountry, start=pStart, end=pEnd))

  #Rename country code
  df_wb <- df_wb %>% dplyr::rename (iso2=iso2c)
  
  # When only one indicator is returned
  if(length(colnames(df_wb))==4)
  {
    #Sort Columns
    df_cn<-c("iso2","country","year",colnames(df_wb)[3])
    
    df_wb<-df_wb[,as.vector(df_cn)]
  }
  
  #Reshape wide to long and paste
  df_wb <- df_wb %>% tidyr::gather('src_id_ind', 'value', 4:length(df_wb))
  
  #Remove rows where value=NA
  df_wb <- df_wb[!is.na(df_wb$value),]
  
  return(df_wb)
  
}

#' Download updated indicator metadata from World Bank API
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
#' }
#' @examples
#' # default is english. To specific another language use argument lang
#' load.WB.medatada(lang = "es")
#' @export
load.WB.medatada<-function(lang = c("en", "es"))
{
  #Select language
  lang <- match.arg(lang)
  
  #Download metadata
  url<-paste0("http://api.worldbank.org/",lang,"/indicators?format=json&per_page=20000")
  return_get <- httr::GET(url)
  return_json <- httr::content(return_get, as = "text")
  return_list <- jsonlite::fromJSON(return_json,  flatten = TRUE)
  df<-as.data.frame(return_list)
  df$per_page<-as.character(df$per_page)
  
  #Topics 
  df_wb_ind_topic<-df[,c("id","topics")]
  df_wb_ind_topic<-tidyr::unnest(df_wb_ind_topic,topics)
  df_wb_ind_topic<-df_wb_ind_topic[,c("id","value")]
  colnames(df_wb_ind_topic)<-c("src_id_ind","topic_id")
  df_wb_ind_topic$topic_id<-trimws(df_wb_ind_topic$topic_id)
  
  df_wb_ind_topic<-topicMatch(df_wb_ind_topic,lang,id_api="wb")
  df_wb_ind_topic$topic<-as.character(df_wb_ind_topic$topic)
  
  df<-df[c(names(df)[names(df) != "topics"])]
  
  df<-sqldf::sqldf("select page,pages,per_page,total,id,name,sourceNote,sourceOrganization,`source.id`,`source.value`, 
                   group_concat(df_wb_ind_topic.topic) as topic_id 
                   from df left join df_wb_ind_topic on id=src_id_ind 
                   group by page,pages,per_page,total,id,name,sourceNote,
                   sourceOrganization,`source.id`,`source.value`")
  
  df_wb_metada<-schemaMatch(df,api="World Bank",id_api="wb")
  
  df_wb_metada
}