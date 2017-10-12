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

  #TODO
  #Filter time and country

  return(df_n4d)

}

load.N4D.metadata()
{
  meta_ind<-iadbmsearch('ALL')
  meta_ind <- meta_ind %>% filter(grepl (pattern= "male|women", tolower(IndicatorName)))

  write.table(meta_ind,paste0(outputDir,"N4D_STG_METADATA_INDICATOR.csv"), quote=T, sep=',', fileEncoding='UTF8',  append = FALSE, row.names=F)

}
