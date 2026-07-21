testare_stationaritate <- function(var, df_t, tara_cod) {
  serie <- df_t[[var]]
  serie <- serie[!is.na(serie)]
  
  if (length(serie) < 10) {
    return(tibble(
      cod_tara       = tara_cod,
      variabila      = var,
      adf_statistic  = NA,
      adf_pvalue     = NA,
      kpss_statistic = NA,
      kpss_pvalue    = NA,
    ))
  }
  
  adf  <- adf.test(serie)
  kpss <- kpss.test(serie, null = "Level")
  
  concluzie <- case_when(
    adf$p.value < 0.05 & kpss$p.value > 0.05 ~ "Stationara I(0) ",
    adf$p.value > 0.05 & kpss$p.value < 0.05 ~ "Nestationara I(1) ",
    TRUE                                       ~ "Neclar "
  )
  
  tibble(
    cod_tara       = tara_cod,
    variabila      = var,
    adf_statistic  = round(adf$statistic, 4),
    adf_pvalue     = round(adf$p.value, 4),
    kpss_statistic = round(kpss$statistic, 4),
    kpss_pvalue    = round(kpss$p.value, 4),
    concluzie      = concluzie
  )
}

run_ts_ols <- function(tara_cod) {
  
  df_t <- df %>% filter(cod_tara == tara_cod)
  

  # 1. TESTAREA STATIONARITATII

  variabile <- c("venit_anual", "cheltuieli_cd_rap_la_pib", "rata_ocupare")
  
  stationaritate <- map_dfr(variabile, testare_stationaritate,
                            df_t = df_t, tara_cod = tara_cod)
  
  
  # 2. TESTAREA COINTEGRARII — Johansen
  
  date_johansen <- df_t %>%
    select(all_of(variabile)) %>%
    drop_na()
  
  johansen <- ca.jo(
    date_johansen,
    type  = "trace",
    ecdet = "const",
    K     = 2
  )
  
  johansen_summary <- summary(johansen)
  
  stat   <- as.numeric(johansen_summary@teststat[1])
  critic <- as.numeric(johansen_summary@cval[1, 2])
  
  test_johansen <- tibble(
    cod_tara             = tara_cod,
    test_statistic       = round(stat, 4),
    valoare_critica_5pct = round(critic, 4),
    cointegrat           = ifelse(isTRUE(stat > critic), "DA ", "NU "),
    model_recomandat     = ifelse(isTRUE(stat > critic), "Niveluri + ECM", "Diferentiere")
  )
  

  # 3. LOGARITMARE + DIFERENTIERE + MODELUL DE REGRESIE
  
  df_t <- df_t %>%
    arrange(an) %>%
    mutate(
      venit_anual_original = venit_anual,          # nivel original in euro
      venit_anual_log      = log(venit_anual),      # logaritmare
      d_venit_anual        = c(NA, diff(log(venit_anual))),
      d_cheltuieli_cd      = c(NA, diff(cheltuieli_cd_rap_la_pib)),
      d_rata_ocupare       = c(NA, diff(rata_ocupare)),
    ) %>%
    drop_na()
  
  model <- lm(
    d_venit_anual ~ d_cheltuieli_cd + d_rata_ocupare,
    data = df_t
  )
  

  # 4. COEFICIENTI + SEMNIFICATIE
  
  tidy_ols <- tidy(model) |>
    mutate(
      cod_tara     = tara_cod,
      r_squared    = round(summary(model)$r.squared, 4),
      semnificativ = case_when(
        p.value < 0.01 ~ "***",
        p.value < 0.05 ~ "**",
        p.value < 0.10 ~ "*",
        TRUE           ~ "ns"
      ),
      across(where(is.numeric), ~round(., 4))
    )
  

  # 5. EVALUAREA MODELULUI — F, R2, AIC, BIC
  
  f_stat   <- summary(model)$fstatistic
  f_pvalue <- pf(f_stat[1], f_stat[2], f_stat[3], lower.tail = FALSE)
  
  test_global <- tibble(
    cod_tara    = tara_cod,
    f_statistic = round(f_stat[1], 4),
    f_pvalue    = round(f_pvalue, 4),
    r_squared   = round(summary(model)$r.squared, 4),
    adj_r2      = round(summary(model)$adj.r.squared, 4),
    aic         = round(AIC(model), 4),
    bic         = round(BIC(model), 4),
    model_valid = ifelse(f_pvalue < 0.05, "DA", "NU")
  )
  

  # 6. TESTAREA IPOTEZELOR MODELULUI
  
  # 6.1 Normalitatea erorilor — Jarque-Bera
  jb <- jarque.bera.test(residuals(model))
  
  normalitate <- tibble(
    cod_tara      = tara_cod,
    jb_statistic  = round(jb$statistic, 4),
    jb_pvalue     = round(jb$p.value, 4),
    erori_normale = ifelse(jb$p.value > 0.05, "DA", "NU")
  )
  
  # 6.2 Autocorelare — Durbin-Watson + Breusch-Godfrey
  dw <- dwtest(model)
  bg <- bgtest(model, order = 2)
  
  autocorelare <- tibble(
    cod_tara     = tara_cod,
    dw_statistic = round(dw$statistic, 4),
    dw_pvalue    = round(dw$p.value, 4),
    bg_statistic = round(bg$statistic, 4),
    bg_pvalue    = round(bg$p.value, 4),
    autocorelare = ifelse(bg$p.value < 0.05, "DA", "NU")
  )
  
  # 6.3 Homoscedasticitate — Breusch-Pagan
  bp <- bptest(model)
  
  homoscedasticitate <- tibble(
    cod_tara      = tara_cod,
    bp_statistic  = round(bp$statistic, 4),
    bp_pvalue     = round(bp$p.value, 4),
    homoscedastic = ifelse(bp$p.value > 0.05, "DA", "NU")
  )
  
  # 6.4 Multicoliniaritate — VIF
  vif_values <- vif(model)
  
  multicoliniaritate <- tibble(
    cod_tara  = tara_cod,
    variabila = names(vif_values),
    vif       = round(vif_values, 4),
    problema  = case_when(
      vif_values < 5  ~ "NU",
      vif_values < 10 ~ "MODERATA",
      TRUE            ~ "GRAVA"
    )
  )
  

  # 7. FITTED VS ACTUAL
  
  primul_log <- first(df_t$venit_anual_log)
  
  df_fitted <- df_t %>%
    mutate(
      fitted             = fitted(model),
      residuals          = residuals(model),
      venit_actual_euro  = venit_anual_original,
      venit_fitted_euro  = exp(primul_log + cumsum(fitted))
    )
  

  # 8. PROGNOZA — interval de predictie

  ultim_an    <- max(df_t$an)
  ultim_log   <- tail(df_t$venit_anual_log, 1)
  ultim_euro  <- tail(df_t$venit_anual_original, 1)
  
  df_prognoza <- tibble(
    an               = (ultim_an + 1):(ultim_an + 5),
    d_cheltuieli_cd  = mean(df_t$d_cheltuieli_cd,  na.rm = TRUE),
    d_rata_ocupare   = mean(df_t$d_rata_ocupare,   na.rm = TRUE),
    d_rata_inflatiei = mean(df_t$d_rata_inflatiei, na.rm = TRUE)
  )
  
  predictie <- predict(
    model,
    newdata  = df_prognoza,
    interval = "prediction",
    level    = 0.95
  )
  
  df_nivel_actual <- tibble(
    cod_tara       = tara_cod,
    an             = ultim_an,
    fit            = NA_real_,
    lower_95       = NA_real_,
    upper_95       = NA_real_,
    venit_progozat = round(ultim_euro, 4),
    venit_lower    = round(ultim_euro, 4),
    venit_upper    = round(ultim_euro, 4)
  )
  
  # Prognoza urmatorii 5 ani 
  df_prognoza <- df_prognoza %>%
    mutate(
      cod_tara       = tara_cod,
      fit            = round(predictie[, "fit"],   4),
      lower_95       = round(predictie[, "lwr"],   4),
      upper_95       = round(predictie[, "upr"],   4),
      venit_progozat = round(exp(ultim_log + cumsum(fit)),      4),
      venit_lower    = round(exp(ultim_log + cumsum(lower_95)), 4),
      venit_upper    = round(exp(ultim_log + cumsum(upper_95)), 4)
    )
  
  # nivel actual + prognoza
  df_prognoza <- bind_rows(df_nivel_actual, df_prognoza)
  

  # OUTPUT
  
  list(
    model              = model,
    stationaritate     = stationaritate,
    johansen           = test_johansen,
    coef               = tidy_ols,
    test_global        = test_global,
    normalitate        = normalitate,
    autocorelare       = autocorelare,
    homoscedasticitate = homoscedasticitate,
    multicoliniaritate = multicoliniaritate,
    fitted             = df_fitted,
    prognoza           = df_prognoza
  )
}
