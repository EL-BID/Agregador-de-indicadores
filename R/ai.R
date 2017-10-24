ai <- function(country = "all", indicator, startdate=2010, enddate=2015,
               lang = c("en", "es", "fr", "ar", "zh"), meta=TRUE,cache)
{
  
  if (missing(cache)) cache <- agregadorindicadores::ai_cachelist
  
  ind<-cache$indicators
  
  df_ind<-as.data.frame(indicator)
  colnames(df_ind)<-"src_id_ind"
  indicators<-sqldf::sqldf("select src_id_ind,api from df_ind join ind using(src_id_ind)")
  
  nr_df=1
  df_list<-list()
  
  #WB
  wb_ind<-indicators[indicators$api=="World Bank",]$src_id_ind
  if(length(wb_ind)>0)
  {
    df_list[[nr_df]]<-load.WB.data(pIndicators = wb_ind, pCountry=country,pStart = startdate,pEnd=enddate)
    nr_df=nr_df+1
  }
  
  #N4D
  n4d_ind<-indicators[indicators$api=="Numbers for Development",]$src_id_ind
  if(length(n4d_ind)>0)
  {
    df_list[[nr_df]]<-load.N4D.data(pIndicators = n4d_ind, pCountry=country,pStart = startdate,pEnd=enddate)
    nr_df=nr_df+1
  }
  
  #NCD
  nc_ind<-indicators[indicators$api=="No Ceilings",]$src_id_ind
  if(length(nc_ind)>0)
  {
    df_list[[nr_df]]<-load.NC.data(pIndicators = nc_ind, pCountry=country,pStart = startdate,pEnd=enddate)
  }
  
  df<-bind_rows(df_list)
  
  if(meta)
  {
    df<-sqldf::sqldf("select * from df join ind using(src_id_ind)")
   
    #remove rows where indicator name=NA
    df <- df[!is.na(df$indicator),]
    
  }
  
  df
}