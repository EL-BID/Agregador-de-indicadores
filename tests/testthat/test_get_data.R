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





