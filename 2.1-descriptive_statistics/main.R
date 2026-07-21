source("./functii/librarii.R")
source("./functii/citire_fisiere.R")
date <- citire_fisiere("./date")
df_lung <- bind_rows(date)


stats_desc_panel <- df_lung |>
  group_by(indicator) |>
  summarise(
    N       = sum(!is.na(valoare)),
    Media   = round(mean(valoare, na.rm = TRUE), 3),
    Mediana = round(median(valoare, na.rm = TRUE), 3),
    St.Dev  = round(sd(valoare, na.rm = TRUE), 3),
    Min     = round(min(valoare, na.rm = TRUE), 3),
    Max     = round(max(valoare, na.rm = TRUE), 3),
    CV      = round(sd(valoare, na.rm = TRUE) / mean(valoare, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  ) |>
  arrange(indicator)

print(stats_desc_panel)

write.csv(stats_desc_panel, 
          file = "./date/output/statistici_descriptive_panel.csv",
          row.names = FALSE)
