source("./functii/librarii.R")
source("./functii/citire_fisiere.R")
source("./functii/regresie.R")
source("./functii/grafic_regresie_pe_tara.R")

date <- citire_fisiere("./date")
df_long <- bind_rows(date)

df <- df_long |>
  pivot_wider(
    id_cols     = c(cod_tara, an),
    names_from  = indicator,
    values_from = valoare
  ) |>
  arrange(cod_tara, an)


tari      <- unique(df$cod_tara)
rezultate <- map(tari, run_ts_ols) |> set_names(tari)

for(tara in tari){
  print(rezultate[[tara]]$prognoza, n = Inf)
}

rezultate$DE


# ADF si KPSS
tabel_stationaritate <- map_dfr(rezultate, "stationaritate")
print(tabel_stationaritate, n = 20) # afișează primele 20 de rânduri în consolă
# write.csv(tabel_stationaritate, "./date/output/1.rezultate_ols_stationaritate.csv", row.names = FALSE)

# Cointegrare Johansen
tabel_johansen <- map_dfr(rezultate, "johansen")
print(tabel_johansen, n = Inf)
# write.csv(tabel_johansen, "./date/output/2.rezultate_ols_johansen.csv", row.names = FALSE)

# Coeficienți
tabel_coef <- map_dfr(rezultate, "coef") |>
  select(cod_tara, term, estimate, std.error, statistic, p.value, semnificativ, r_squared)
# write.csv(tabel_coef, "./date/output/3.rezultate_ols_coef.csv", row.names = FALSE)

# Evaluare Globală (F-stat, R2, AIC, BIC)
tabel_global <- map_dfr(rezultate, "test_global")
# write.csv(tabel_global, "./date/output/4.rezultate_ols_global.csv", row.names = FALSE)

# Normalitate Erori (Jarque-Bera)
tabel_normalitate <- map_dfr(rezultate, "normalitate")
print(tabel_normalitate, n = Inf)
# write.csv(tabel_normalitate, "./date/output/5.rezultate_ols_normalitate.csv", row.names = FALSE)

# Autocorelare (Durbin-Watson + Breusch-Godfrey)
tabel_autocorelare <- map_dfr(rezultate, "autocorelare")
# write.csv(tabel_autocorelare, "./date/output/6.rezultate_ols_autocorelare.csv", row.names = FALSE)

# Homoscedasticitate (Breusch-Pagan)
tabel_homoscedasticitate <- map_dfr(rezultate, "homoscedasticitate")
print(tabel_homoscedasticitate, n = Inf)
# write.csv(tabel_homoscedasticitate, "./date/output/7.rezultate_ols_homoscedasticitate.csv", row.names = FALSE)

# Multicoliniaritate (VIF)
tabel_multicoliniaritate <- map_dfr(rezultate, "multicoliniaritate")
print(tabel_multicoliniaritate, n = 30)
# write.csv(tabel_multicoliniaritate, "./date/output/8.rezultate_ols_multicoliniaritate.csv", row.names = FALSE)

# Prognoză pe următorii 5 ani (Valori estimate + Interval de incredere)
tabel_prognoza <- map_dfr(rezultate, "prognoza")
print(tabel_prognoza, n = 30)
# write.csv(tabel_prognoza, "./date/output/9.rezultate_ols_prognoza_5ani.csv", row.names = FALSE)









