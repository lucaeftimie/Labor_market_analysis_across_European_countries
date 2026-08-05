stationarity_test <- function(var, df_test, cty_code) {
	# Select the variable as "var"
  df <- df_test[[var]]
  # Take out na values
  df <- df[!is.na(df)]
  
  # Apply adf test
  adf  <- adf.test(df)
  
  # Apply kpss test
  kpss <- kpss.test(df, null = "Level")
  
  # Conclusion about the test
  conclusion <- case_when(
    adf$p.value < 0.05 & kpss$p.value > 0.05 ~ "Stationary I(0) ",
    adf$p.value > 0.05 & kpss$p.value < 0.05 ~ "Not stationary I(1) ",
    TRUE                                       ~ "Unclear "
  )
  
  # Create a tibble as result of tests
  tibble(
    country_code   = cty_code,
    variable       = var,
    adf_statistic  = round(adf$statistic, 4),
    adf_pvalue     = round(adf$p.value, 4),
    kpss_statistic = round(kpss$statistic, 4),
    kpss_pvalue    = round(kpss$p.value, 4),
    conclusion     = conclusion
  )
}

run_ts_ols <- function(cty_code) {
  
	# Filter the data for cty_code
  df_test <- df |> filter(country_code == cty_code)
  

  # 1 - Stationarity test 

  vars <- c("annual_revenue", "r_n_d_expenses_relative_to_GDP", "employment_rate")
  
  stationarity <- map_dfr(vars, stationarity_test, df_test, cty_code)
  
  
  # 2 - Cointegration test Johansen
  
  df_johansen <- df_test |>
  	select(all_of(vars)) |>
		drop_na()
  	
  
  johansen <- ca.jo(
    df_johansen,
    type  = "trace",
    ecdet = "const",
    K     = 2
  )
  
  johansen_summary <- summary(johansen)
  
  stat   <- as.numeric(johansen_summary@teststat[1])
  critical_val <- as.numeric(johansen_summary@cval[1, 2])
  
  test_johansen <- tibble(
    country_code      = cty_code,
    test_statistic    = round(stat, 4),
    critical_value    = round(critical_val, 4),
    Cointregreation   = ifelse(isTRUE(stat > critical_val), "YES", "NO"),
    recommended_model = ifelse(isTRUE(stat > critical_val), "Other models", "Diferentiation")
  )
  

  # 3 - Natural logarithm and differentiation
  
  df_test <- df_test |>
    arrange(year) |>
    mutate(
      orig_annual_rev   = annual_revenue,                              # Original values from annual revenue          
      log_annual_rev    = log(annual_revenue),                         # Natural logarithm of annual revenue
      d_annual_revenue  = c(NA, diff(log(annual_revenue))),            # First order differentiation of annual revenue
      d_r_n_d_expenses  = c(NA, diff(r_n_d_expenses_relative_to_GDP)), # First order differentitation of RnD expenses
      d_employment_rate = c(NA, diff(employment_rate)),                # First order differentation of employment rate
    ) |>
    drop_na()
  
  model <- lm(
    d_annual_revenue ~ d_r_n_d_expenses + d_employment_rate,
    data = df_test
  )
  

  # 4 - Coefficients
  
  tidy_ols <- tidy(model) |>
    mutate(
      country_code     = cty_code,
      r_squared    = round(summary(model)$r.squared, 4),
      is_valid = case_when(
        p.value < 0.01 ~ "***",
        p.value < 0.05 ~ "**",
        p.value < 0.10 ~ "*",
        TRUE           ~ "ns"
      ),
      across(where(is.numeric), ~round(., 4))
    )
  

  # 5 - Model evalution — F, R2, AIC, BIC
  
  f_stat   <- summary(model)$fstatistic
  f_pvalue <- pf(f_stat[1], f_stat[2], f_stat[3], lower.tail = FALSE)
  
  global_test <- tibble(
    country_code    = cty_code,
    f_statistic = round(f_stat[1], 4),
    f_pvalue    = round(f_pvalue, 4),
    r_squared   = round(summary(model)$r.squared, 4),
    adj_r2      = round(summary(model)$adj.r.squared, 4),
    aic         = round(AIC(model), 4),
    bic         = round(BIC(model), 4),
    is_valid = ifelse(f_pvalue < 0.05, "YES", "NO")
  )
  

  # 6 - Hypothesis testing for regression
  
  # 6.1 - Error normality — Jarque-Bera
  jb <- jarque.bera.test(residuals(model))
  
  normal_test <- tibble(
    country_code      = cty_code,
    jb_statistic      = round(jb$statistic, 4),
    jb_pvalue         = round(jb$p.value, 4),
    are_normal        = ifelse(jb$p.value > 0.05, "YES", "NO")
  )
  
  # 6.2 - Autocorrelation — Durbin-Watson + Breusch-Godfrey
  dw <- dwtest(model)
  bg <- bgtest(model, order = 2)
  
  autocorrelation <- tibble(
    country_code     = cty_code,
    dw_statistic = round(dw$statistic, 4),
    dw_pvalue    = round(dw$p.value, 4),
    bg_statistic = round(bg$statistic, 4),
    bg_pvalue    = round(bg$p.value, 4),
    autocorrelation = ifelse(bg$p.value < 0.05, "YES", "NO")
  )
  
  # 6.3 - Homoscedasticity — Breusch-Pagan
  bp <- bptest(model)
  
  homoscedasticity <- tibble(
    country_code      = cty_code,
    bp_statistic  = round(bp$statistic, 4),
    bp_pvalue     = round(bp$p.value, 4),
    homoscedastic = ifelse(bp$p.value > 0.05, "YES", "NO")
  )
  
  # 6.4 - Multicolinearity — VIF
  vif_values <- vif(model)
  
  multicolinearity <- tibble(
    country_code  = cty_code,
    var = names(vif_values),
    vif       = round(vif_values, 4),
    problema  = case_when(
      vif_values < 5  ~ "NO MULTICOLIN",
      vif_values < 10 ~ "MODERATE MULTICOLIN",
      TRUE            ~ "STRONG MULTICOLIN"
    )
  )
  

  # 7. FITTED VS ACTUAL
  
  first_log <- first(df_test$log_annual_rev)
  
  df_fitted <- df_test |>
    mutate(
      fitted             = fitted(model),
      residuals          = residuals(model),
      venit_actual_euro  = orig_annual_rev,
      venit_fitted_euro  = exp(first_log + cumsum(fitted))
    )
  

  # 8. PROGNOZA — interval de predictie

  last_year    <- max(df_test$year)
  last_log   <- tail(df_test$log_annual_rev, 1)
  last_orig  <- tail(df_test$orig_annual_rev, 1)
  
  forecast_df <- tibble(
    year               = (last_year + 1):(last_year + 5),
    d_r_n_d_expenses  = mean(df_test$d_r_n_d_expenses,  na.rm = TRUE),
    d_employment_rate   = mean(df_test$d_employment_rate,   na.rm = TRUE),
  )
  
  forecast_result <- predict(
    model,
    newdata  = forecast_df,
    interval = "prediction",
    level    = 0.95
  )
  
  df_actual_level <- tibble(
    country_code       = cty_code,
    year             = last_year,
    fit            = NA_real_,
    lower_95       = NA_real_,
    upper_95       = NA_real_,
    forecasted_revenue = round(last_orig, 4),
    lower_revenue    = round(last_orig, 4),
    upper_revenue    = round(last_orig, 4)
  )
  
  # Forecast over the next 5 years
  forecast_df <- forecast_df |>
    mutate(
      country_code       = cty_code,
      fit                = round(forecast_result[, "fit"],   4),
      lower_95           = round(forecast_result[, "lwr"],   4),
      upper_95           = round(forecast_result[, "upr"],   4),
      forecasted_revenue = round(exp(last_log + cumsum(fit)),      4),
      lower_reveneu      = round(exp(last_log + cumsum(lower_95)), 4),
      uppper_revenue     = round(exp(last_log + cumsum(upper_95)), 4)
    )
  
  forecast_df <- bind_rows(df_actual_level, forecast_df)
  

  # OUTPUT
  
  list(
    model              = model,
    stationarity       = stationarity,
    johansen           = test_johansen,
    coef               = tidy_ols,
    global_test        = global_test,
    normality          = normal_test,
    autocorrelation    = autocorrelation,
    homoscedasticity   = homoscedasticity,
    multicolinearity   = multicolinearity,
    fitted             = df_fitted,
    forecast           = forecast_df
  )
}
