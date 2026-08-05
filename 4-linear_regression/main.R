source("./modules/libraries.R")
source("./modules/import_data.R")
source("./modules/regression.R")

dfs <- import_data("./data/csv/", "./../1-preprocessing/data/output/")
long_df <- bind_rows(dfs)

df <- long_df |>
  pivot_wider(
    id_cols     = c(country_code, year),
    names_from  = indicator,
    values_from = value
  ) |>
  arrange(country_code, year)

countries <- unique(df$country_code)
results <- map(countries, run_ts_ols) |> set_names(countries)

for(country in countries){
  print(results[[country]]$forecast, n = Inf)
}


# ADF and KPSS
stationarity <- map_dfr(results, "stationarity")

# Johansen cointegration
johansen <- map_dfr(results, "johansen")

# Coefficients
coefficients <- map_dfr(results, "coef") |>
  select(country_code, term, estimate, std.error, statistic, p.value, is_valid, r_squared)

# Global validity(F-stat, R2, AIC, BIC)
global_validity <- map_dfr(results, "global_test")

# Normality of errors (Jarque-Bera)
normality <- map_dfr(results, "normality")

# Autocorrelation (Durbin-Watson + Breusch-Godfrey)
autocorrelation <- map_dfr(results, "autocorrelation")

# Homoscedasticity (Breusch-Pagan)
homoscedasticity <- map_dfr(results, "homoscedasticity")

# Multicolinearity (VIF)
multicolinearity <- map_dfr(results, "multicolinearity")

# Forecast for the next 5 years (Estimated values + Confidence interval)
forecast_5_years <- map_dfr(results, "forecast_5_years")


# Delete files from output folder
cat("Type Y in the console to delete all files from ./data/output/")
delete_files <- readline()

if (tolower(delete_files) == "y"){
	curr_folder_files <- list.files("./data/output/", full.names = TRUE)
	
	if (length(curr_folder_files) > 0) {
		file.remove(curr_folder_files)
	}
	
}else{
	cat("Process failed. Make sure you write \"Y\" in order to continue")
}

# Write results table as separate csvs to the folder "output"
cat("Type Y in the console to write the csvs to the output folder.")
write_csv_tables <- readline()

if (tolower(write_csv_tables) == "y"){
	
	write.csv(stationarity, "./data/output/1-stationarity.csv", row.names = FALSE)
	write.csv(johansen, "./data/output/2-johansen.csv", row.names = FALSE)
	write.csv(coefficients, "./data/output/3-coefficients.csv", row.names = FALSE)
	write.csv(global_validity, "./data/output/4-global_validity.csv", row.names = FALSE)
	write.csv(normality, "./data/output/5-normality.csv", row.names = FALSE)
	write.csv(autocorrelation, "./data/output/6-autocorrelation.csv", row.names = FALSE)
	write.csv(homoscedasticity, "./data/output/7-homoscedasticity.csv", row.names = FALSE)
	write.csv(multicolinearity, "./data/output/8-multicolinearity.csv", row.names = FALSE)
	write.csv(forecast_5_years, "./data/output/9-forecast_5_years.csv", row.names = FALSE)
	
}else{
	cat("Process failed. Make sure you write \"Y\" in order to continue")
}


