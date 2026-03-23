library(tidyverse)
library(tsibble)
library(readr)
library(stringr)
library(tools)
library(ggplot2)
library(sqldf)
nume_fisiere <- list.files("./../data/csvs")

csvs <- list()
indicators <- list()
for(ind in nume_fisiere ){
  nume_fis <- str_glue("./../data/csvs/", ind)
  indicator <- read_csv(nume_fis, locale = locale(encoding = "UTF-8", decimal_mark = ",", grouping_mark = "."))
  ind <- tools::file_path_sans_ext(ind)
  indicators[[ind]] <- ind
  csvs[[ind]] <- indicator
}


source("./functions/region_selector.R")
source("./functions/descriptive_statistics.R")
source("./functions/add_region_code.R")
source("./functions/add_indicator.R")




summary_stat_by_indicator <- vector("list", 5)
i <- 1
for(ind in indicators){
summary_stat <- tibble(mean = double(),sd  = double(),min = double(),cv = double(),n = integer(),region_code = character(),indicator = character())
  for(r in unique_regions){
    region_selector(csvs[[ind]], r)  |> 
    descriptive_statistics() |> 
    add_region_code(r)  |> 
    add_indicator(ind)  -> summary_stat_by_region
    
    summary_stat <- summary_stat |> add_row(summary_stat_by_region)
  }
  summary_stat_by_indicator[[i]] <-  summary_stat
}

unique_regions <- summary_stat_by_indicator[[1]] |>
                  inner_join(summary_stat_by_indicator[[2]], by = "region_code") |>
                  inner_join(summary_stat_by_indicator[[3]], by = "region_code") |>
                  inner_join(summary_stat_by_indicator[[4]], by = "region_code") |>
                  inner_join(summary_stat_by_indicator[[5]], by = "region_code")
# write_csv(combined_lb_force, "descriptive_statistics_lb_force.csv")
