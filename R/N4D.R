#------------------------------------------#
#                                          #
#   Banco Inter-americano de Desarrollo    #
#       Agregador Indicadores              #
#                                          #
# Autores:                                 #
#        Alejandro Rodriguez               #
#------------------------------------------#

#------------------------------------------#
#       Numbers for Development (N4D)      #
#     Banco Inter-americano de Desarrollo  #
#------------------------------------------#

setup<-function()
{
  install.packages('devtools')
  library(devtools)
  install_github('arcuellar88/iadbstats')
  library('iadbstats')
}



load.N4D.data <- function(pIndicators, pCountry = 'all', pStart=2010, pEnd=2015){


  #Download data from indicators
  df<-iadbstats.list(indicatorCodes=pIndicators)


  #Select columns
  df <-select(df, -CountryTableName, -IndicatorName, -SubTopicName , -Quarter, -Month, -AggregationLevel, -UOM, -TopicName)

  #Format Country
  url<-"http://api-data.iadb.org/metadata/country?searchtype=name&searchvalue=All&Languagecode=en&Responsetype=json"
  return_get <- httr::GET(url)
  return_json <- httr::content(return_get, as = "text")
  return_list <- jsonlite::fromJSON(return_json,  flatten = TRUE)
  df_iadb_ct<-as.data.frame(return_list)
  
  #iadb data
  df_n4d<-sqldf::sqldf("select df_iadb_ct.WB2Code as iso2, df_iadb_ct.CountryTableName as country, df.year as year, df.IndicatorCode as src_id_ind, df.AggregatedValue as value from df join df_iadb_ct using (CountryCode)")
  
  #TO-DO
  # Get country in iadbstats package
  #Filter time 
  # Add country to iadbstats.list

  return(df_n4d)

}

load.N4D.metadata<-function(lang = c("en", "es", "fr", "ar", "zh"))
{
  df<-iadbmsearch('ALL',lang = lang)
  
  df_n4d_metada<-schemaMatch(df,api="Numbers for Development",id_api="n4d")
  
  df_n4d_metada
}
