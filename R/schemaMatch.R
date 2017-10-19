schemaMatch<-function(df,api="World Bank",id_api="wb")
{
  #Indicator data
  schema<-read.csv("./data/schemaMatch.csv")
  df<-df[,as.vector(schema[schema$action == "keep" & schema$source==id_api, ]$column)]
  
  #Add missing columns
  xx<-as.vector(schema[schema$action == "add" & schema$source==id_api, ]$metadata_schema)
  
  if(length(xx)>0)
  {
    df<-cbind(df, setNames( lapply(xx, function(x) x=NA), xx) )
  }
  #Sort and change column names
  df_cn<-schema[schema$action != "rm" & schema$source==id_api, ]
  
  colnames(df)<-as.vector(df_cn$metadata_schema)
  
  df_cn<-df_cn[with(df_cn, order(sort)), ]
  
  df<-df[,as.vector(df_cn$metadata_schema)]
  
  df$api<-api
  
  
  return(df)
    
}