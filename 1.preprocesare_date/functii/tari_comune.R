tari_comune <- function(set_date, index = 1, comun = NULL) {
  if (index > length(set_date)) {
    return(comun)
  }
  
  regiuni_curente <- unique(set_date[[index]]$cod_tara)
  
  if (is.null(comun)) {
    comun <- regiuni_curente
  } else {
    comun <- intersect(comun, regiuni_curente)
  }
  
  tari_comune(set_date, index + 1, comun)
}

