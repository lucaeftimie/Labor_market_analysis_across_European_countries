processing_csv <- function(curr_dir){
  

  file_names <- list.files(curr_dir)
  
  dfs <- list()
  
  for(i in 1:length(file_names)){
    file_path <- str_glue(curr_dir, file_names[i])
    
    
    dfs[[i]] <- as_tibble(read.csv(file_path))
    
    
    dfs[[i]] %>% 
      select(geo, TIME_PERIOD, OBS_VALUE) %>%
      rename(country_code = geo, year = TIME_PERIOD, value = OBS_VALUE) -> dfs[[i]]
    
    if(file_names[i] == "demo_gind.csv"){
      file_names[i] <- "net_migration"
    }
    if(file_names[i] == "earn_nt_net.csv"){
      file_names[i] <- "annual_revenue"
    }
    if(file_names[i] == "edat_lfse_03_facultate.csv"){
      file_names[i] <- "tertiary_education"
    }
    if(file_names[i] == "edat_lfse_03_max_liceu.csv"){
      file_names[i] <- "early_school_leaving"
    }
    if(file_names[i] == "htec_emp_reg2.csv"){
      file_names[i] <- "rate_of_tech_employment"
    }
    if(file_names[i] == "lfsa_egised.csv"){
      file_names[i] <- "employment_superior_education"
    }
    if(file_names[i] == "lfsa_ergan.csv"){
      file_names[i] <- "employment_rate"
    }
    if(file_names[i] == "lfsi_pt_a.csv"){
      file_names[i] <- "rate_of_temporary_contracts"
    }
    if(file_names[i] == "nama_10_lp_ulc.csv"){
      file_names[i] <- "labour_productivity"
    }
    if(file_names[i] == "rd_e_gerdtot.csv"){
      file_names[i] <- "r_n_d_expenses_relative_to_GDP" 
    }
    if(file_names[i] == "trng_lfs_09.csv"){
      file_names[i] <- "continuous_development_of_employees"
    }
    if(file_names[i] == "une_rt_a.csv"){
      file_names[i] <- "unemployment_rate"
    }
    if(file_names[i] == "yth_empl_090.csv"){
      file_names[i] <- "unemployment_rate_young"
    }
    
    dfs[[i]]$indicator <- file_names[i]
    
  }
  
  
  return(dfs)
}
