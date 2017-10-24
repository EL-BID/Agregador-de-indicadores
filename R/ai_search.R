#' Search indicator information available through all sources
#'
#' This function allows finds indicators that match a search term and returns
#' a data frame of matching results
#'
#' @param pattern Character string or regular expression to be matched
#' @param fields Character vector of column names through which to search from: "src_id_ind","indicator","ind_description","source","src_id_dataset","dataset","uom","api"  
#' @param extra if \code{FALSE}, only the indicator ID and short name are returned,
#' if \code{TRUE}, all columns of the \code{cache} parameter's indicator data frame
#' are returned
#' @param cache List of data frames returned from \code{\link{ai_cache}}. If omitted,
#' \code{\link{ai_cache_list}} is used
#' @return Data frame with indicators that match the search pattern.
#' @examples
#' ind_search(pattern = "education")
#'
#' ind_search(pattern = "Food and Agriculture Organization", fields = "sourceOrg")
#'
#' # with regular expression operators
#' # 'poverty' OR 'unemployment' OR 'employment'
#' ind_search(pattern = "poverty|unemployment|employment")
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
