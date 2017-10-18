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

load.WB.data <- function(pIndicators, pCountry = 'all', pStart=2010, pEnd=2015){

  #General indicators and Global Findex Data are included in this dataframe

  ############################################
  #                                          #
  #       Download indicator data            #
  #                                          #
  ############################################


    df_wb <- WDI(indicator = pIndicators, country = pCountry, start=pStart, end=pEnd)

    #Rename country code
    df_wb <- df_wb %>% rename (iso2=iso2c)

    #Reshape wide to long and paste
    df_wb <- df_wb %>% gather('indicatorID', 'value', 4:length(df_wb))

    #Remove rows where value=NA
    df_wb <- df_wb[!is.na(df_wb$value),]

    #remove rows where indicator name=NA
    df_wb <- df_wb[!is.na(df_wb$indicator),]

  return(df_wb)

}


load.WB.medatada<-function(lang = c("en", "es", "fr", "ar", "zh"))
{
  #------------------------------------------#
  #       Download metadata                  #
  #------------------------------------------#
  url<-paste0("http://api.worldbank.org/",lang,"/indicators?format=json&per_page=100")
  return_get <- httr::GET(url)
  return_json <- httr::content(return_get, as = "text")
  return_list <- jsonlite::fromJSON(return_json,  flatten = TRUE)
  df<-as.data.frame(return_list)
  
  #Topics 
  df_wb_ind_topic<-df[,c("id","topics")]
  df_wb_ind_topic<-unnest(df_wb_ind_topic,topics)
  df_wb_ind_topic<-df_wb_ind_topic[,c("id","id1")]
  colnames(df_wb_ind_topic)<-c("src_ind_id","topic_id")
  
  #Indicator data
  schema<-read.csv("./data/schemaMatch.csv")
  df_wb_metada<-df[,as.vector(schema[schema$action == "keep" & schema$source=="wb", ]$column)]
  
  #Add missing columns
  xx<-as.vector(schema[schema$action == "add" & schema$source=="wb", ]$metadata_schema)
  
  df_wb_metada<-cbind(df_wb_metada, setNames( lapply(xx, function(x) x=NA), xx) )
  
  colnames(df_wb_metada)<-as.vector(schema[schema$action != "rm" & schema$source=="wb",]$metadata_schema)
  
  df_wb_metada$api<-"World Bank"
  
   # create a list with required components
   s <- list(topics = df_wb_ind_topic, ind_metadata=df_wb_metada, src = "wb")
   s
}
