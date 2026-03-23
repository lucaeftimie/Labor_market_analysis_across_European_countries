library(tidyverse)
library(tsibble)
library(readr)
library(stringr)
library(tools)
library(ggplot2)
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


unique_regions <- unique(csvs[[1]]$region_id)

lapply(csvs, colnames)
summary_stat_by_indicator <- vector("list", 5)

i <- 1
for(ind in indicators){
summary_stat <- tibble(mean = double(),sd  = double(),min = double(),max = double(), cv = double(),n = integer(),region_id = character(),indicator = character() )
  for(r in unique_regions){
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

for(summ in summary_stat_by_indicator){
  write_csv(summ, str_glue("./summary_statistics/" ,summ$indicator[1], ".csv"))
}

