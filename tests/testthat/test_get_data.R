context("Test Download data")
library(agregadorindicadores)

test_that("erros in range queries", {
  
  #Get all the indicator related to gender= female
  ind<- ind_search(pattern = "female", c("gender"))
  
  #No Ceilings
  df_ncd<-ind[ind$api=="No Ceilings",]
  
  expect_that(nrow(df_ncd), is_more_than(200))
  
  #Download all the available data for those indicators 
  df_data_ncd<-ai(indicator = df_ncd$src_id_ind, startdate=2010, enddate=2010)
  expect_that(nrow(df_data_ncd), is_more_than(14400))
  expect_equal(min(df_data_ncd$year), 2010)
  expect_equal(max(df_data_ncd$year), 2010)
  
  
  #Numbers for Development
  df_n4d<-ind[ind$api=="Numbers for Development",]
  
  expect_that(nrow(df_n4d), is_more_than(12))
  
  #Download all the available data for those indicators 
  df_data_n4d<-ai(indicator = df_n4d$src_id_ind, startdate=2014, enddate=2014)
  expect_that(nrow(df_data_n4d), is_more_than(230))
  expect_equal(min(df_data_n4d$year), 2014)
  expect_equal(max(df_data_n4d$year), 2014)
  
  
  #Gov data 360
  df_360<-ind[ind$api=="Govdata360",]
  
  expect_that(nrow(df_360), is_more_than(50))
  
  #Download all the available data for those indicators 
  df_data_360<-ai(indicator = df_360$src_id_ind, startdate=2010, enddate=2010)
  expect_that(nrow(df_data_360), is_more_than(2000))
  expect_equal(min(df_data_360$year), 2010)
  expect_equal(max(df_data_360$year), 2010)
  
  #World Bank
  df_wb<-ind[ind$api=="World Bank",]
  
  expect_that(nrow(df_wb), is_more_than(1200))
  
  df_wb<-head(df_wb)
  
  #Download all the available data for those indicators 
  df_data_wb<-ai(indicator = df_wb$src_id_ind, startdate=2010, enddate=2015)
  expect_that(nrow(df_data_wb), is_more_than(440))
  expect_that(min(df_data_wb$year), is_more_than(2009))
  expect_that(max(df_data_wb$year), is_less_than(2016))
  
  #Normalize data
  df_norm<- ai_normalize(data=df_data_360)
  expect_that(nrow(df_norm), is_more_than(2000))
  
})


test_that("Numbers for Development", {
  
df<-ai(indicator = "SOC_046", startdate=2014, enddate=2014)
expect_equal(min(df$year), 2014)
expect_equal(max(df$year), 2014)
expect_that(nrow(df), is_more_than(10))

})

test_that("World Bank", {
  
  df<-ai(indicator = "SL.UEM.TOTL.NE.ZS", startdate=2014, enddate=2014)
  expect_equal(min(df$year), 2014)
  expect_equal(max(df$year), 2014)
  expect_that(nrow(df), is_more_than(140))
  
})

test_that("No Ceilings", {
  
  df<-ai(indicator = "CONTFEHQ", startdate=2002, enddate=2014)
  expect_that(min(df$year), is_more_than(2001))
  expect_that(max(df$year), is_less_than(2015))
  expect_that(nrow(df), is_more_than(100))
  
})

test_that("Gov Data 360", {
  
  df<-ai(indicator = "27870", startdate=2012, enddate=2014)
  expect_that(min(df$year), is_more_than(2011))
  expect_that(max(df$year), is_less_than(2015))
  expect_that(nrow(df), is_more_than(100))
  
})


test_that("Wrong indicators", {
  
  df<-ai(indicator = "asaxadsa", startdate=2012, enddate=2014)
  expect_equal(df, "No data")
  
  df<-ai(indicator = c("AXA","asdasd"), startdate=2012, enddate=2014)
  expect_equal(df, "No data")

})

test_that("Wrong countries", {
  
  expect_error(ai(indicator = "SL.UEM.TOTL.NE.ZS", country = "XASDA",startdate=2012, enddate=2014))
  
  expect_error(ai(indicator = "SL.UEM.TOTL.NE.ZS", country = c("xsa","@asda"),startdate=2012, enddate=2014))
  
  #Numbers for Development Unexpected country
  df<-ai(indicator = "SOC_046", country = c("US"),startdate=2012, enddate=2014)
  expect_equal(df, "No data")
  
  df<-ai(indicator = "SOC_046", country = c("US","AR"),startdate=2012, enddate=2014)
  expect_that(min(df$year), is_more_than(2011))
  expect_that(max(df$year), is_less_than(2015))
  expect_that(nrow(df), is_more_than(1))
})
