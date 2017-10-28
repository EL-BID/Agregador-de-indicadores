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

  #dependencies: dplyr, sqldf
  
  #Download data from indicators
  df<-iadbstats.list(indicatorCodes=pIndicators,country = pCountry)

  #Select columns
  df <-dplyr::select(df, -CountryTableName, -IndicatorName, -SubTopicName , -Quarter, -Month, -AggregationLevel, -UOM, -TopicName)

  #Format Country and filter time
  df_iadb_ct<-iadbstats.countries()
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
  
  #TO-DO
  # Cache countries
  
  return(df_n4d)

}

load.N4D.metadata<-function(lang = c("en", "es", "fr", "ar", "zh"))
{
  df<-iadbstats::iadbmsearch('ALL',lang = lang)
  
  df_n4d_metada<-schemaMatch(df,api="Numbers for Development",id_api="n4d")
  
  df_n4d_metada
}
