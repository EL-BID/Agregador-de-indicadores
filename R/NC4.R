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

load.NC.data <- function(){


  #No ceiling data is an innitiative developed by the Clinton Foundation.
  #This was a one time effort that gathered data from multiple sources.
  #Information regarding renovating this effort is not yet defined.

  ############################################
  #                                          #
  #       Download and unzip data            #
  #                                          #
  ############################################

  library(downloader)

  download("https://github.com/fathominfo/noceilings-data/archive/master.zip", dest="dataset.zip", mode="wb")

  unzip ("dataset.zip", exdir=NCD_FOLDER, overwrite=T)

  ############################################
  #                                          #
  #        Importing untransformed data      #
  #                                          #
  ############################################

  df <- NA

  #setwd(NCD_FOLDER)

  # Get file names
  files <- list.files(paste0(NCD_FOLDER,'/noceilings-data-master/csv'))

  #files <- list.files (paste (getwd(), '/csv', sep = ''), full.names = TRUE)

  wd <- getwd()
  setwd(paste0(NCD_FOLDER,'/noceilings-data-master/csv'))

  outputNCD<-paste0(OUTPUT_FOLDER,"/NCD.csv")

  write.table(c("iso,indicator_id,year,value"),outputNCD, row.names=F,na="NA",append=FALSE, quote= FALSE, sep=",", col.names=F)

  # LOOP to create dataframes from all csv files
  #indicator_list <- list()
  for(i in 1:length(files)){

    f = readLines(files[i])                           # used for counts
    temp = read.csv(files[i], nrows = length(f) - 7)  # removes the last 7 lines of csv
    fname = str_sub(files[1],1,-5) # remove .csv from the file name
    temp$series = rep(fname, nrow(temp)) # creates a variable with the indicator name
    #df_name = paste('IND-', 1, sep = '')
    #assign(df_name, temp)
    #expression <- parse(text = names[i]) # results in: expression(AllstarFull)
    #print(eval(expression))

    #put in the appropriate structure (from wide to long form)
    temp <- gather(temp, year, value, 2:(length(names(temp))-1)) %>%  filter(value != "")

    #remove rows that have NAs in value variable
    temp <- temp[!is.na(temp$value),]

    #convert text "yes/no" rows into numeric 1/0 values
    temp <- temp %>%
      mutate(value = ifelse(value=="yes","1",ifelse(value=="no","0",value)))

    #ensure that all data have numeric value
    temp$value <- as.numeric(temp$value)

    write.table(temp,outputNCD, row.names=F,na="NA",append=T, quote= FALSE, sep=",", col.names=F)
    #indicator_list[[i]] = temp   # adds indicator df to list
  }

  setwd(wd)

  ############################################
  #                                          #

  #       Append untsransformed data         #
  #                                          #
  ############################################


  # Collapses list with data frames into single dataframe (must have same variables - missing replaced with NAs)
  #full_data <- bind_rows(indicator_list)

  #free memory
  #rm(indicator_list)

  # Remove csv extension from series names
  #full_data$series <- sub (".csv", "", full_data$series)


  #write.csv(full_data, file=outputFile, row.names = FALSE)


  return(df)

}
