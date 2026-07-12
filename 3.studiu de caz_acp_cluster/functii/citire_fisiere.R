citire_fisiere <- function(locatie_de_baza){
  
  locatie_fisiere <- str_glue(locatie_de_baza, "/csv/")
  nume_fisiere <- list.files(locatie_fisiere)
  
  
  seturi_de_date <- list()
  
  for(i in 1:length(nume_fisiere)){
    locatie_citire <- str_glue(locatie_fisiere, nume_fisiere[i] )
    seturi_de_date[[i]] <- as_tibble(read.csv(locatie_citire))
  }
  
  return(seturi_de_date)
  
}