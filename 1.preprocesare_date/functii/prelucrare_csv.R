prelucrare_csv <- function(locatie_fisiere){
  

  nume_fisiere <- list.files(locatie_fisiere)
  
  date <- list()
  
  for(i in 1:length(nume_fisiere)){
    locatie_citire <- str_glue(locatie_fisiere, nume_fisiere[i])
    
    
    date[[i]] <- as_tibble(read.csv(locatie_citire))
    
    
    date[[i]] %>% 
      select(geo, TIME_PERIOD, OBS_VALUE) %>%
      rename(cod_tara = geo, an = TIME_PERIOD, valoare = OBS_VALUE) -> date[[i]]
    
    if(nume_fisiere[i] == "demo_gind.csv"){
      nume_fisiere[i] <- "migratie_neta"
    }
    if(nume_fisiere[i] == "earn_nt_net.csv"){
      nume_fisiere[i] <- "venit_anual"
    }
    if(nume_fisiere[i] == "edat_lfse_03_facultate.csv"){
      nume_fisiere[i] <- "educatie_tertiara"
    }
    if(nume_fisiere[i] == "edat_lfse_03_max_liceu.csv"){
      nume_fisiere[i] <- "abandon_scolar_timpuriu"
    }
    if(nume_fisiere[i] == "htec_emp_reg2.csv"){
      nume_fisiere[i] <- "angajati_tech"
    }
    if(nume_fisiere[i] == "lfsa_egised.csv"){
      nume_fisiere[i] <- "ocupare_educatie_superioara"
    }
    if(nume_fisiere[i] == "lfsa_ergan.csv"){
      nume_fisiere[i] <- "rata_ocupare"
    }
    if(nume_fisiere[i] == "lfsi_pt_a.csv"){
      nume_fisiere[i] <- "rata_contracte_temporare"
    }
    if(nume_fisiere[i] == "nama_10_lp_ulc.csv"){
      nume_fisiere[i] <- "productivitatea_muncii"
    }
    if(nume_fisiere[i] == "rd_e_gerdtot.csv"){
      nume_fisiere[i] <- "cheltuieli_cd_rap_la_pib"
    }
    if(nume_fisiere[i] == "trng_lfs_09.csv"){
      nume_fisiere[i] <- "formare_continua"
    }
    if(nume_fisiere[i] == "une_rt_a.csv"){
      nume_fisiere[i] <- "rata_somaj"
    }
    if(nume_fisiere[i] == "yth_empl_090.csv"){
      nume_fisiere[i] <- "somaj_tineri"
    }
    
    date[[i]]$indicator <- nume_fisiere[i]
    
  }
  
  
  return(date)
}
