library(FactoMineR)
library(ggplot2)
library(tidyverse)
library(factoextra)
renv::update("rlang")

?PCA()


lb_force <- read_csv("./csvs/labour_force_total_20_64_y.csv")
View(lb_force)

periods <- seq(from = 2015, to = 2024, by = 1)
