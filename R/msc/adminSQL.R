readSQLCommands <- function(file)
{
  sqlcmds <- readLines(file)
  sqlcmds <- sqlcmds[!grepl(pattern = "^\\s*--", x = sqlcmds)] # remove full-line comments
  sqlcmds <- sub(pattern = "--.*", replacement="", x = sqlcmds) # remove midline comments
  sqlcmds <- paste(sqlcmds, collapse=" ")
  
  sqlcmdlist<<-as.list(strsplit(sqlcmds, ";")[[1]])
  
  sqlcmdlist
}

runSQL<-function(sqlcmdlist,conn)
{
  #idaInit(con)
  #print(length(sqlcmdlist))
  
  for(i in 1:length(sqlcmdlist))
  {
    q<-gdata::trim(sqlcmdlist[[i]])
    
    if(q!="")
    {
      #print(paste0("index: ",i))
      #print(q)
      try(dbExecute(conn,q))
    }
  }
  
}