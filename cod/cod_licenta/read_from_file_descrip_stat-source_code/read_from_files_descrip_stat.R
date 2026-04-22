library(tidyverse)
library(tsibble)
library(readr)
library(stringr)
library(tools)
library(ggplot2)
library(openxlsx)
nume_fisiere <- list.files("./../data/csvs")

csvs <- list()
indicators <- list()
for(ind in nume_fisiere ){
  nume_fis <- str_glue("./../data/csvs/", ind)
  indicator <- read_csv(nume_fis, locale = locale(encoding = "UTF-8", decimal_mark = ",", grouping_mark = "."))
  ind <- tools::file_path_sans_ext(ind)
  indicators[[ind]] <- ind
  csvs[[ind]] <- indicator
  csvs[[ind]]$value <- as.numeric(csvs[[ind]]$value)
}
source("./functions/region_selector.R")
source("./functions/descriptive_statistics.R")
source("./functions/add_region_code.R")
source("./functions/add_indicator.R")



regions_1 <- unique(csvs[[1]]$region_id)
regions_2 <- unique(csvs[[2]]$region_id)
regions_3 <- unique(csvs[[3]]$region_id)
regions_4 <- unique(csvs[[4]]$region_id)
regions_5 <- unique(csvs[[5]]$region_id)

common_regions <- intersect(regions_1, regions_2)
common_regions <- intersect(common_regions, regions_3)
common_regions <- intersect(common_regions, regions_4)
common_regions <- intersect(common_regions, regions_5)


summary_stat_by_indicator <- vector("list", 5)

i <- 1
for(ind in indicators){
summary_stat <- tibble(mean = double(),sd  = double(),min = double(),max = double(), cv = double(),n = integer(),region_id = character(),indicator = character() )
  for(r in common_regions){
    colnames(csvs[[ind]])
    region_selector(csvs[[ind]], r)  |> 
    descriptive_statistics() |> 
    add_region_code(r)  |> 
    add_indicator(ind)  -> summary_stat_by_region
    
    summary_stat <- summary_stat |> add_row(summary_stat_by_region)
  }
  summary_stat_by_indicator[[i]] <-  summary_stat
  i <- i + 1
}


s1 <- summary_stat_by_indicator[[1]]
s2 <- summary_stat_by_indicator[[2]]
s3 <- summary_stat_by_indicator[[3]]
s4 <- summary_stat_by_indicator[[4]]
s5 <- summary_stat_by_indicator[[5]]


wb <- createWorkbook()

addWorksheet(wb, "Employed Persons")
writeData(wb, "Employed Persons", s1)
addWorksheet(wb, "gdp_mil_euro Persons")
writeData(wb, "gdp_mil_euro Persons", s2)
addWorksheet(wb, "Labour force")
writeData(wb, "Labour force", s3)
addWorksheet(wb, "Market slack")
writeData(wb, "Market slack", s4)
addWorksheet(wb, "Total population")
writeData(wb, "Total population", s5)
saveWorkbook(wb, "C:\\Users\\lucac\\Desktop\\licenta\\cod\\cod_licenta\\read_from_file_descrip_stat-source_code\\summary_statistics\\summary_statistics.xlsx", overwrite = TRUE)




#for(summ in summary_stat_by_indicator){
#  write_csv(summ, str_glue("./summary_statistics/" ,summ$indicator[1], ".csv"))
#}

