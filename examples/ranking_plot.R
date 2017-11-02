#Get all the indicator related to gender= female
ind<- ind_search(pattern = "female", c("gender"))

#Download all the available data for those indicators 
df<-ai(indicator = ind$src_id_ind, startdate=2014, enddate=2014)

#Normalize data
df_gender<- ai_normalize(data=df)
  
#select only two countries to compare
df_gender$fCountry <- factor(df_gender$country)
df_gender_s <- subset(df_gender, country %in% c("Colombia", "Somalia", "Germany","Andorra","Canada","Iraq","Argentina") & year %in% 2014)

# Graph
library(plotly)

#define the plot
p <- ggplot(df_gender_s, aes(x=value_norm, y=fCountry,colour=fCountry,hover = indicator)) +
  geom_point(shape=1) 
  
# create plot
p <- ggplotly(p)

# Create a shareable link to your chart
# Set up API credentials: https://plot.ly/r/getting-started
chart_link = api_create(p, filename="bid_normalization",sharing="public", fileopt="overwrite")
chart_link

#View graph locally 
p

#References
#https://plot.ly/ggplot2/geom_point/



