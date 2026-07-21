source("./functii/librarii.R") # pachete externe pentru procesarea datelor
source("./functii/prelucrare_csv.R") # curățare datelor
source("./functii/tari_comune.R") # identificarea setului comun de țări


date <- prelucrare_csv("./date/csv/eurostat/")

comun <- tari_comune(date)
valori_lipsa <- list()
perioada <- seq(2010, 2024, 1)
#perioada <- c(2019,2020,2024)

for(i in 1:length(date)){
  date[[i]] |> filter(cod_tara %in% comun ) -> date[[i]]
  date[[i]] |> filter( an %in% perioada ) -> date[[i]]
  date[[i]] |> 
    group_by(cod_tara) |> 
    summarise(nr_ani_existenti = n_distinct(an)) |> 
    filter(!nr_ani_existenti %in% length(perioada)) -> valori_lipsa[[i]]
    valori_lipsa[[i]]$indicator <- unique(date[[i]]$indicator)
  
}

# tari_cu_date_lipsa <- c()
# for(i in 1:length(valori_lipsa)){
#   tari_cu_date_lipsa <- append(tari_cu_date_lipsa, unique(valori_lipsa[[i]]$cod_tara))
# }
# for(i in 1:length(date)){
#   date[[i]] |>
#     filter(!cod_tara %in% tari_cu_date_lipsa) -> date[[i]]
#     
#   cat(date[[i]]$indicator[1], ": ", nrow(date[[i]]), "\n")
# }

# outlieri sunt observati manual din date / din informatii de pe internet
outlieri <- c("IE", "MT", "IS", "CH", "CY")
for(i in 1:length(date)){
  date[[i]] |>
    filter(!cod_tara %in% outlieri) -> date[[i]]
  
  cat(date[[i]]$indicator[1], ": ", nrow(date[[i]]), "\n")
}


# tarile ramase in analiza:
comun <- setdiff(comun, outlieri)
print(comun)


fis <- list.files("./date/output/", full.names = TRUE)

if (length(fis) > 0) {
  file.remove(fis)
}

for(i in 1:length(date)){
    write.csv(date[[i]], str_glue("./date/output/", unique(date[[i]]$indicator),  ".csv"), row.names = FALSE)
}
