#------------------------------------------#
#                                          #
#   Banco Inter-americano de Desarrollo    #
#       Agregador Indicadores              #
#                                          #
# Autores:                                 #
#        Alejandro Rodriguez               #
#------------------------------------------#

#-------------------------------------------------------
#------Load required library
#-------------------------------------------------------

list.of.packages <- c("dplyr","tidyr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

rm(list.of.packages)
rm(new.packages)

library(dplyr)
library(tidyr)

#-------------------------------------------------------
#------govdata360
#-------------------------------------------------------
download.govdata360<-function(pIndicators)
{
  df_gd360 <-  govdata360R::gov360stats.list(indicatorCodes=pIndicators)

  return(df_gd360)
}

#Join With Metadata
#library(sqldf)
#result<-sqldf("select idMySQL as idIndicador, country as ISO3, year as anio, value as valor, idSource from db join indicators ind on db.id=ind.id_govdata360")
#detach("package:sqldf", unload=TRUE)


download.datasetByID.govdata360 <- function(idSource=428)
{

  #Get Data
  df=govdata360R::govdata360DS(idDS)

  #Transforma data
  df = df %>% gather('year','value',5:length(df))

  #remove N/A
  df <- df[!is.na(df$value),]

  df=as.data.frame( apply(df,2, function(x) gsub("X2","2",x)))

  df
}

download.datasetByName.govdata360<-function(sourceName="Global Integrity")
{
  dfGovData <- govdata360R::gov360msearch(sourceSearch = sourceName)

  #Add row ids
  dfGovData$rid<- seq.int(nrow(dfGovData))

  dfGovData <- dfGovData[,c(1,2,3,4,5,8,10,11,15,16,17)]

  dfGovData
}
