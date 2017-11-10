#' Search indicator information available through all sources
#'
#' This function allows finds indicators that match a search term and returns
#' a data frame of matching results
#'
#' @param pattern Character string or regular expression to be matched
#' @param fields Character vector of column names through which to search from:   
#' @note 
#  The options for \code{fields} are:
#' \itemize{
#' \item \code{src_id_ind}: id of the indicator in the source (World Bank, Numbers for Development, No Celings and GovData360)
#' \item \code{indicator}: name of the indicator
#' \item \code{ind_description}: description of the indicator
#' \item \code{source}: source of the indicator
#' \item \code{src_id_dataset}: id of the dataset in the source
#' \item \code{dataset}: name of the dataset in the source
#' \item \code{gender}: female, male or total
#' \item \code{area}: rural, urban or total
#' \item \code{api}: World Bank, Numbers for Development and No Celings.
#' 
#' }
#' @param extra if \code{FALSE}, only the indicator ID and short name are returned,
#' if \code{TRUE}, all columns of the \code{cache} parameter's indicator data frame
#' are returned
#' @param cache List of data frames returned from \code{\link{ai_cache}}. If omitted,
#' \code{\link{ai_cache_list}} is used
#' @return Data frame with indicators that match the search pattern.
#' @examples
#' # Search by keyword
#' ind_search(pattern = "education")
#' 
#' # Search by source organization
#' ind_search(pattern = "Food and Agriculture Organization", fields = "sourceOrg")
#'
#' # Regular expression operators
#' 'poverty' OR 'unemployment' OR 'employment'
#' ind_search(pattern = "poverty|unemployment|employment")
#' 
#' # Search for gender related indicators
#' ind_search(pattern = "male", c("gender"))
#' 
#' # Get all indicators from the Numbers for Development
#' ind_search(pattern = "Numbers for Development", c("api"))
#' 
#' # Get all Rural indicators
#' ind_search(pattern = "rural", c("area"))
#' 
#' # Search by topic 
#' df<-ind_search(pattern = "Health", fields="topic")
#' @export
ind_search <- function(pattern = "poverty", fields = c("indicator", "ind_description"), extra = FALSE, cache){
  
  if (missing(cache)) cache <- agregadorindicadores::ai_cachelist
  
  ind_cache <- cache$indicators
  
  match_index <- sort(unique(unlist(sapply(fields, FUN = function(i)
    grep(pattern, ind_cache[, i], ignore.case = TRUE), USE.NAMES = FALSE)
  )))
  
  if (length(match_index) == 0) warning(paste0("no matches were found for the search term ", pattern,
                                               ". Returning an empty data frame."))
  
  if (extra) {
    
    match_df <-  ind_cache[match_index, ]
    
  } else {
    
    match_df <- ind_cache[match_index, c("src_id_ind", "indicator","api")]
    
  }
  
  
  match_df
}
