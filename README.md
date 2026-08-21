# Labor Market Analysis Across European Countries

This repository contains the R code used to analyze labor market indicators (e.g. unemployment, wages, and related economic variables) across European countries. The analysis moves through four stages, each in its own numbered folder — data is cleaned, explored, reduced to key patterns via clustering, and finally modeled with time-series regression per country.

## How the project is organized

The code is meant to be run in order, since each stage builds on the output of the one before it:

```
1-preprocessing/            → clean and reshape the raw data
2.1-descriptive_statistics/ → import data and compute summary statistics
2.2-correlation_matrix/     → measure relationships between indicators
3-data_analysis/            → dimensionality reduction and clustering
4-linear_regression/        → per-country time-series regression models
Legend.csv                  → lookup table explaining what each indicator code means
```

If you're new to the project, start by opening `Legend.csv` to understand what the indicator codes (used throughout the code and plots) actually represent, then work through the folders in the order above.

---

## 1. Preprocessing

**Goal:** turn the raw indicator files into clean, usable dataframes.

- **`processing_csv(curr_dir)`**
  Reads every CSV file in a given directory (each file represents one economic indicator) and keeps only the three columns that matter for the analysis: `country_id`, `year`, and `value`.
  → Returns a list of cleaned dataframes, one per indicator.

- **`common_country_codes(dfs, index = 1, common = NULL)`**
  Since not every country reports every indicator, this function figures out which country codes are actually present in *all* the dataframes, so later steps only compare countries with complete data. It works recursively, checking one dataframe at a time (`index`) and narrowing down the running list of shared codes (`common`) until it has gone through the whole list.

---

## 2.1 Descriptive Statistics

**Goal:** load the cleaned data into R and compute basic statistical summaries (mean, spread, etc.) for each indicator.

- **`import_data(current_folder, upstream)`**
  Loads the preprocessed data into the R session as tibbles, ready for analysis. Because this can overwrite existing files, it interactively asks for confirmation in the terminal before: clearing out the destination folder, copying the data over from the previous stage, and finally loading it into R.
  → Returns a list of dataframes.

---

## 2.2 Correlation Matrix

**Goal:** quantify how strongly each labor-market indicator relates to the others (e.g. does higher GDP per capita correlate with lower unemployment?). This step produces the correlation matrix used to guide which indicators are worth carrying into the next stage.

---

## 3. Dimensionality Reduction and Clustering

**Goal:** the raw dataset has many overlapping indicators, so this step distills them into a smaller number of underlying components (via dimensionality reduction) and then groups countries into clusters based on those components — countries with similar labor-market profiles end up in the same cluster.

---

## 4. Linear Regression

**Goal:** build a time-series regression model *for each country individually*, to test how labor-market indicators evolve and relate to one another over time within that country.

- **`run_ts_ols(cty_code)`**
  Fits an OLS (ordinary least squares) time-series regression for a single country, then runs a full battery of diagnostic checks on it — the classical regression assumptions, plus stationarity and cointegration tests (relevant for time-series data specifically). This function is applied once per country to build up the full set of country-level models.

  Returns a list of results, where each entry is itself a dataframe:

  | Element | What it contains |
  |---|---|
  | `model` | The fitted regression model |
  | `stationarity` | Stationarity test results (checks if the data's statistical properties are stable over time) |
  | `johansen` | Johansen cointegration test results (checks for long-run equilibrium relationships between variables) |
  | `coef` | Estimated regression coefficients |
  | `global_test` | Overall model significance test |
  | `normality` | Test for whether residuals are normally distributed |
  | `autocorrelation` | Test for correlation between residuals across time |
  | `homoscedasticity` | Test for constant variance of residuals |
  | `multicolinearity` | Test for excessive correlation between predictor variables |
  | `fitted` | The model's fitted (predicted) values |
  | `forecast` | Forecasted future values |

---

## Requirements

This project is written in **R**. You'll need R installed along with the packages used for data manipulation (e.g. `dplyr`/`tibble`), time-series analysis, and regression diagnostics referenced in the `4-linear_regression` scripts.

## Notes

- `Legend.csv` is the reference for what each indicator code in the plots and dataframes means — check it first if a variable name is unclear.
- Because `import_data()` deletes and overwrites files interactively, run it from a terminal (not silently) so you can respond to its prompts.
