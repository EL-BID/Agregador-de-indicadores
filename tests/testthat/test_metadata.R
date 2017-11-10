

test_that("Metadata all sources", {
  
  
  df_wb<-load.WB.medatada()
  expect_that(nrow(df_wb),is_more_than(15000))
  expect_equal(length(df_wb),9)
  expect_equal(colnames(df_wb)[5],"src_id_dataset")
  expect_equal(colnames(df_wb)[8],"topic")
  expect_equal(colnames(df_wb)[9],"api")
  
  df_n4d<-load.N4D.metadata()
  expect_that(nrow(df_n4d),is_more_than(50))
  expect_equal(length(df_n4d),9)
  expect_equal(colnames(df_n4d)[5],"src_id_dataset")
  expect_equal(colnames(df_n4d)[8],"topic")
  expect_equal(colnames(df_n4d)[9],"api")
  
  df_ncd<-load.NC.metadata()
  expect_that(nrow(df_ncd),is_more_than(50))
  expect_equal(length(df_ncd),9)
  expect_equal(colnames(df_ncd)[5],"src_id_dataset")
  expect_equal(colnames(df_ncd)[8],"topic")
  expect_equal(colnames(df_ncd)[9],"api")
  
  
  df_360<-load.360.metadata()
  expect_that(nrow(df_360),is_more_than(3000))
  expect_equal(length(df_360),9)
  expect_equal(colnames(df_360)[5],"src_id_dataset")
  expect_equal(colnames(df_360)[8],"topic")
  expect_equal(colnames(df_360)[9],"api")
  
})

