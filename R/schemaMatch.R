schemaMatch<-function(df,api="World Bank",id_api="wb")
{
  #Indicator data
  schema<-agregadorindicadores::schema
    
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

topicMatch<-function(df,lang = c("en", "es"),id_api="wb")
{
  #Indicator data
  topics<-agregadorindicadores::topics
  
  t<-paste0("topic_",lang)
  t_ext<-paste0("topic_",id_api,"_",lang)
  df_topic<-topics[c(t,t_ext)]
  
  sql <- sprintf("select * from df left join df_topic on topic_id=%s",t_ext)
  
  df_s<-sqldf::sqldf(sql)
  
  df<-df_s[c(names(df)[names(df) != "topic_id"],t)]
  
  names(df)[names(df) == t] <- 'topic'
  
  return(df)
  
}