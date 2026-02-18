library(FactoMineR)
library(ggplot2)
library(factoextra)
library(openxlsx)
library(stringr)
library(readr)
library(vroom)
library(dplyr)

setwd("c:\\Users\\lucac\\Desktop\\licenta\\cod\\cod_licenta")
legenda <- read.xlsx("./metadata/legend.xlsx", sheet = 1, fillMergedCells = TRUE, colNames = TRUE, rowNames = FALSE);

library(tidyverse)

setwd("c:\\Users\\lucac\\Desktop\\licenta\\cod\\cod_licenta\\outputs_csv")
files <- list.files(path = ".", pattern = "\\.csv$", full.names = FALSE)

all_dfs <- list()
for(i in 1:length(files) ){
  csv_file <- read.csv(files[i], header = TRUE, sep = ",", dec = ".", check.names = FALSE)
  all_dfs[[sub("\\.csv$", "", files[i])]] <- csv_file 
}


library(dplyr)
library(tidyr)
library(readr)


long_data <- all_dfs %>%  bind_rows()
unique(long_data$indicator)

wide_data <- long_data %>%
  pivot_wider(
    names_from = indicator,  
    values_from = value      
  )


library(missMDA)

n_est <- estim_ncpPCA(wide_data[,-c(1,2)], ncp.max = 5)

res.impute <- imputePCA(wide_data[, -c(1,2)], ncp = n_est$ncp)

df_complete <- res.impute$completeObs
df_complete <- cbind(wide_data[,c(1,2)], df_complete)
View(df_complete)

res.pca <- PCA(df_complete, scale.unit = TRUE, graph = FALSE, quali.sup = c(1,2))

fviz_pca_ind(res.pca,geom = "point", col.ind = as.factor(df_complete$years), palette = "jco", addEllipses = TRUE,  legend.title = "Year", title = "PCA: Regions Trajectory Over Time")
