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
  df_n4d<-iadbstats.list(IndicatorCodes=pIndicators)


  #Select columns
  df_n4d <-select(df_n4d, -CountryTableName, -IndicatorName, -SubTopicName , -Quarter, -Month, -AggregationLevel, -UOM, -TopicName)

  #TO-DO
  #Filter time and country

  return(df_n4d)

}

load.N4D.metadata<-function(lang = c("en", "es", "fr", "ar", "zh"))
{
  df<-iadbmsearch('ALL',lang = lang)
  
  #Indicator data
  schema<-read.csv("./data/schemaMatch.csv",quote = "\"")
  df_n4d_metada<-df[,as.vector(schema[schema$metadata_schema != "rm" & schema$source=="n4d", ]$column)]
  colnames(df_n4d_metada)<-as.vector(schema[schema$metadata_schema != "rm" & schema$source=="n4d",]$metadata_schema)
  
  df_n4d_metada$api<-"Numbers for Development"
  
  df_n4d_metada
}
