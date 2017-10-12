#------------------------------------------#
#                                          #
#   Banco Inter-americano de Desarrollo    #
#       Agregador Indicadores              #
#                                          #
# Autores:                                 #
#        Alejandro Rodriguez               #
#------------------------------------------#

############################################
# Load and Harmonize a dataset from:       #
############################################
#                                          #
#             World Bank Data              #
#                                          #
#   Accessible through wbstats and WDI     #
#     packages in R                        #
#                                          #
############################################

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

load.WB.medatada<-function()
{
  ############################################
  #                                          #
  #       Download metadata                  #
  #                                          #
  ############################################

  #Download indicator list from WB (filter those indicators that have FINDEX as the source)
  findex_ind <-  wbsearch(pattern = 'Global Findex', 'source', extra = TRUE)

  #filter those indicators that are disagregated by gender using "male" as the pattern
  findex_ind <- findex_ind %>%
    filter(grepl (pattern= "male|women", indicator))

  #Write metadata to csv
  write.csv(findex_ind, file="WB_STG_METADATA_INDICATOR.csv", quote=TRUE, row.names=FALSE)
}
