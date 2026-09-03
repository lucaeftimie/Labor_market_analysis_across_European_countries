# Labor Market Analysis Across European Countries

R code for analyzing labor market indicators (unemployment, wages, etc.) across European countries. The project has four steps: cleaning the data, descriptive statistics, clustering, and regression.

## Structure

```
1-preprocessing/            → clean and reshape raw data
2.1-descriptive_statistics/ → import data and compute summary statistics
2.2-correlation_matrix/     → correlations between indicators
3-data_analysis/            → dimensionality reduction and clustering
4-linear_regression/        → per-country regression models
Legend.csv                  → explains what each indicator code means
```

Run the folders in order, since each one uses the output from the previous step. Check `Legend.csv` first to understand the indicator codes.

---

## 1. Preprocessing

Cleans the raw CSV files and keeps only `country_id`, `year`, and `value`.

- `processing_csv(curr_dir)`: reads all CSVs in a folder and returns a list of cleaned dataframes.
- `common_country_codes(dfs, index, common)`: finds which country codes appear in all dataframes (not every country has data for every indicator), keeping only countries with complete data.

## 2.1 Descriptive Statistics

Loads the cleaned data into R and computes basic stats (mean, sd, etc.).

- `import_data(current_folder, upstream)`: copies the data from the previous step and loads it as tibbles. Asks for confirmation before overwriting files, so look out for confirmation messages in the console

## 2.2 Correlation Matrix

Computes correlations between indicators, to see which ones are related (e.g. GDP vs unemployment).

## 3. Dimensionality Reduction and Clustering

Reduces the indicators to fewer components and clusters countries with similar labor-market profiles.

## 4. Linear Regression

Fits a time-series regression per country.

- `run_ts_ols(cty_code)`: fits an OLS model for one country and runs diagnostic tests (stationarity, cointegration, normality, autocorrelation, homoscedasticity, multicollinearity), plus fitted/forecast values.

Returns a list with: `model`, `stationarity`, `johansen`, `coef`, `global_test`, `normality`, `autocorrelation`, `homoscedasticity`, `multicolinearity`, `fitted`, `forecast`.

## Requirements

R, plus packages for data manipulation (dplyr/tibble), time-series analysis, and regression diagnostics.

## Notes

- Check `Legend.csv` if a variable name is unclear.
- Look out for messages in the console when running `import_data()`, since it asks for confirmation before overwriting files.
