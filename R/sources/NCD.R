#------------------------------------------#
#                                          #
#   Banco Inter-americano de Desarrollo    #
#       Agregador Indicadores              #
#                                          #
# Autores:                                 #
#        Alejandro Rodriguez               #
#------------------------------------------#

#------------------------------------------#
#            No Ceilings Data              #
#                                          #
#   Downloaded from www.noceilings.org     #
#   Set the folder where the data can      #
#    be found in the NCD_FOLDER variable   #
#    (config.R file)                       #
#                                          #
#------------------------------------------#

load.NC.data <- function(pIndicators=c("ADFERRAT"),pStart=2010,pEnd=2015, pCountry='all'){

  dfList<-list()
  
  #Download data
  for (i in 1:length(pIndicators)) {

  src_id_ind=pIndicators[i]

  url_data<-paste0("https://raw.githubusercontent.com/fathominfo/noceilings-data/master/csv/",src_id_ind,".csv")
  df<-read.csv(url(url_data))
  
  df$src_id_ind<-src_id_ind
    
  #put in the appropriate structure (from wide to long form)
  df <- gather(df, year, value, 2:(length(names(df))-1)) %>%  filter(value != "")
  
  #remove rows that have NAs in value variable
  df <- df[!is.na(df$value),]
  
  #convert text "yes/no" rows into numeric 1/0 values  
  df <- df %>%
    mutate(value = ifelse(value=="yes","1",ifelse(value=="no","0",value)))
  
  #ensure that all data have numeric value
  df$value <- as.numeric(df$value)
  
  df$year<-gsub("X","",df$year)
  df$year <- as.numeric(df$year)
  
  #Filter time
  df<-df[df$year>=pStart & df$year<=pEnd,]

  dfList[[i]]<-df
  }
  
  #merge all indicators
  df<-bind_rows(dfList)
  
  
  #Format Country and filter time
  df_wb_ct<-wbstats::wbcountries()
  
  sql <- sprintf("select df_wb_ct.iso2c as iso2, 
                         df_wb_ct.country, 
                         df.year as year, 
                         df.src_id_ind, 
                         df.value 
                          from df join df_wb_ct on df.iso=df_wb_ct.iso3c")
  
  df_ncd<-sqldf::sqldf(sql)
  
  #Filter Countries
  if(length(pCountry)>1&&pCountry!='all')
  {
    df_ct<-as.data.frame(pCountry)
    colnames(df_ct)<-"iso2"
    
    df_ncd<-sqldf::sqldf("select * 
                    from df_ncd where iso2 in (select iso from df_ct)")
  }
  
  df_ncd$iso2<-as.character(df_ncd$iso2)
  
  return(df_ncd)

}

load.NC.metadata<-function()
{

 #Download Metadata
 url_meta="https://raw.githubusercontent.com/fathominfo/noceilings-data/master/indicators.csv"
 df_nc_meta<-read.csv(url(url_meta))
 
 #Filter World Bank
 df_nc_meta<-df_nc_meta %>% filter(!grepl("World Bank", source))
 
 df_nc_meta<-schemaMatch(df_nc_meta,api="No Ceilings",id_api="ncd")
 
 df_nc_meta
 
}
