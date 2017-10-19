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

load.WB.data <- function(pIndicators, pCountry = 'all', pStart=2010, pEnd=2015,meta=TRUE){

  #General indicators and Global Findex Data are included in this dataframe

  ############################################
  #                                          #
  #       Download indicator data            #
  #                                          #
  ############################################

    df_wb <- WDI(indicator = pIndicators, country = pCountry, start=pStart, end=pEnd)

    #Rename country code
    df_wb <- df_wb %>% rename (iso2=iso2c)

    #Sort Columns
    df_cn<-c("iso2","country","year",pIndicators)
    
    df_wb<-df_wb[,as.vector(df_cn)]
    
    #Reshape wide to long and paste
    df_wb <- df_wb %>% gather('src_id_ind', 'value', 4:length(df_wb))

    #Remove rows where value=NA
    df_wb <- df_wb[!is.na(df_wb$value),]

      
    if(meta)
    {
      #missing(ind)
      
      df_wb<-sqldf::sqldf("select * from df_wb join ind using(src_id_ind)")
      #remove rows where indicator name=NA
      df_wb <- df_wb[!is.na(df_wb$indicator),]
      
    }

  return(df_wb)

}

load.WB.medatada<-function(lang = c("en", "es", "fr", "ar", "zh"))
{
  #------------------------------------------#
  #       Download metadata                  #
  #------------------------------------------#
  
  url<-paste0("http://api.worldbank.org/",lang,"/indicators?format=json&per_page=20000")
  return_get <- httr::GET(url)
  return_json <- httr::content(return_get, as = "text")
  return_list <- jsonlite::fromJSON(return_json,  flatten = TRUE)
  df<-as.data.frame(return_list)
  
  #Topics 
  df_wb_ind_topic<-df[,c("id","topics")]
  df_wb_ind_topic<-unnest(df_wb_ind_topic,topics)
  df_wb_ind_topic<-df_wb_ind_topic[,c("id","id1")]
  colnames(df_wb_ind_topic)<-c("src_ind_id","topic_id")
  
  df_wb_metada<-schemaMatch(df,api="World Bank",id_api="wb")
  
   # create a list with required components
   s <- list(topics = df_wb_ind_topic, ind_metadata=df_wb_metada, src = "wb")
  
  df_wb_metada
}
