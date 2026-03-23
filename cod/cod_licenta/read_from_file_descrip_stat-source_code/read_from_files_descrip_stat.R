library(tidyverse)
library(tsibble)
library(readr)
library(stringr)
library(tools)
library(ggplot2)

nume_fisiere <- list.files("./../data/csvs")

csvs <- list()
for(ind in nume_fisiere ){
  nume_fis <- str_glue("./../data/csvs/", ind)
  indicator <- read_csv(nume_fis, locale = locale(encoding = "UTF-8", decimal_mark = ",", grouping_mark = "."))
  ind <- tools::file_path_sans_ext(ind)
  csvs[[ind]] <- indicator
}

View(csvs$emp_pers_total_20_64_y)


csvs_final <- csvs[[1]] %>% 
  inner_join(csvs[[2]], by = c("region_id", "year")) %>%
  inner_join(csvs[[3]], by = c("region_id", "year")) %>%
  inner_join(csvs[[4]], by = c("region_id", "year")) %>%
  inner_join(csvs[[4]], by = c("region_id", "year"))


View(csvs_final)

source("./region_selector.R")
source("./descriptive_statistics.R")
source("./standardise.R")


region_codes <- unique(csvs_final$region_id)

descriptive_statistics <- list()
for(r in region_codes){
  region_selector(lb_force, r)  |>  descriptive_statistics()  -> descriptive_statistics_lb_force[[r]]
}

combined_lb_force <- bind_rows(descriptive_statistics_lb_force, .id = "region_code")
View(combined_lb_force)

# write_csv(combined_lb_force, "descriptive_statistics_lb_force.csv")
