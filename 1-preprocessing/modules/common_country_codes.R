common_country_codes <- function(dfs, index = 1, common = NULL) {
  if (index > length(dfs)) {
    return(common)
  }
  
  current_regions <- unique(dfs[[index]]$country_code)
  
  if (is.null(common)) {
    common <- current_regions
  } else {
    common <- intersect(common, current_regions)
  }
  
  common_country_codes(dfs, index + 1, common)
}

