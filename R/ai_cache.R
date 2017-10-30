#' Download updated indicator information from World Bank API, Numbers for Development API and No Celings 
#'
#' Download updated information on available indicators
#' from from World Bank API, Numbers for Development API and No Celings 
#'
#' @param lang Language in which to return the results. If \code{lang} is unspecified,
#' english is the default.
#'
#' @return A data frame of available indicators with related information
#'
#' @note Not all data returns have support for langauges other than english. If the specific return
#' does not support your requested language by default it will return \code{NA}. For an enumeration of
#' supported languages by data source please see TODO.
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
#' meta_indicators(lang = "es")
#' @export
meta_indicators <- function(lang = c("en", "es", "fr", "ar", "zh")) {
  
  # if none supplied english is default
  lang <- match.arg(lang)
  
  #World Bank Metadata
  wb<-load.WB.medatada(lang)
  
  #N4D Metadata
  n4d<-load.N4D.metadata(lang)
  
  #NCD
  ncd<-load.NC.metadata()
  
  indicators_df<-rbind(wb,n4d,ncd)
  
  indicators_df<-ai_classify_indicators(indicators_df)
  
  indicators_df
}


#' Download an updated list of country, indicator, and source information
#'
#' Download an updated list of information regarding countries, indicators
#' from the World Bank API, Numbers for Development API and No Celings
#'
#' @param lang Language in which to return the results. If \code{lang} is unspecified,
#' english is the default.
#'
#' @return A list containing the following items:
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
#'
#' Saving this return and using it has the \code{cache} parameter in \code{\link{ai_search}} and \code{\link{ind_search}}
#' replaces the default cached version \code{\link{ai_cachelist}} that comes with the package itself
#' @examples
#' # default is english. To specific another language use argument lang
#' ai_cache(lang = "es")
#' @export
ai_cache <- function(lang = c("en", "es", "fr", "ar", "zh")) {
  
  # if none supplied english is default
  lang <- match.arg(lang)
  
  cache_list <- list(
                     "countries_wb" = wbstats::wbcountries(lang),
                     "countries_idb" = iadbstats::iadbstats.countries(),
                     "indicators" = meta_indicators(lang = lang)
                     #"sources" = wbsources(lang = lang),
                     #"datacatalog" = wbdatacatalog(), # does not take lang input
                     #"topics" = wbtopics(lang = lang),
                     #"income" = wbincome(lang = lang),
                     #"lending" = wblending(lang = lang)
                     )
  
  cache_list
}

ai_classify_indicators<-function(indicator_df)
{
  keywords<-read.csv("classify.csv", stringsAsFactors = FALSE)
  
  #Gender
  kw_female<-aggregate(keyword ~.,data =  keywords[keywords$classify=='gender' & keywords$val=='female',],paste, collapse="|")
  kw_male<-aggregate(keyword ~.,data =  keywords[keywords$classify=='gender' & keywords$val=='male',],paste, collapse="|")
  indicator_df<-indicator_df %>% mutate (gender = ifelse(grepl (kw_female$keyword,indicator), 'female', ifelse(grepl (kw_male$keyword,indicator),'male','total') %>% as.character()))
  
  
  #Multiplier
  kw_multiplier<-aggregate(keyword ~.,data =  keywords[keywords$classify=='multiplier' & keywords$val=='-1',],paste, collapse="|")
  indicator_df<-indicator_df %>% mutate (multiplier = ifelse(grepl (kw_multiplier$keyword,indicator), -1, 1) %>% as.character())
  
  #Area
  indicator_df<-indicator_df %>% mutate (area = ifelse (grepl("urban",indicator), "urban", ifelse (grepl("rural",indicator), "rural", "total")) %>% as.character())
  
  return(indicator_df)
}