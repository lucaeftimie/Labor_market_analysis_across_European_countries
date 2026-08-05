source("./modules/libraries.R") # Loading the libraries
source("./modules/processing_csv.R") # Clean datasets
source("./modules/common_country_codes.R") # Find the country codes common between 		all datasets

dfs <- processing_csv("./data/csv/eurostat/")

common_countries <- common_country_codes(dfs)
interval <- seq(2010, 2024, 1)
#interval <- c(2019,2020,2024)

missing_values <- list()

for(i in 1:length(dfs)){
	# Select data based on country codes common between all datasets
  dfs[[i]] |> 
		filter(country_code %in% common_countries) -> dfs[[i]]
	# Select the interval 
  dfs[[i]] |> 
  	filter(year %in% interval) -> dfs[[i]]
  
  # Identifying which countries have missing values in the interval
  dfs[[i]] |> 
    group_by(country_code) |> 
    summarise(existing_years = n_distinct(year)) |> 
    filter(!existing_years %in% length(interval)) -> missing_values[[i]]
  
    missing_values[[i]]$indicator <- unique(dfs[[i]]$indicator)
  
}

# Make a list of countries which have missing values
cty_codes <- c() 
for(i in 1:length(missing_values)){
  cty_codes <- append(cty_codes, unique(missing_values[[i]]$country_code))
}

# Filter out the countries with missing data, from all the datasets
for(i in 1:length(dfs)){
  dfs[[i]] |>
    filter(!country_code %in% cty_codes) -> dfs[[i]]
    
  cat(dfs[[i]]$indicator[1], ": ", nrow(dfs[[i]]), "\n")
}

# Outliers 
outliers <- c("IE", "MT", "IS", "CH", "CY")
for(i in 1:length(dfs)){
  dfs[[i]] |>
    filter(!country_code %in% outliers) -> dfs[[i]]
  
  cat(dfs[[i]]$indicator[1], ": ", nrow(dfs[[i]]), "\n")
}

common_countries <- setdiff(common_countries, outliers)
print(common_countries)


# Delete existing files from the output folder

cat("Type Y in the console to delete all files from ./date/output/")
delete_files <- readline()

if (tolower(delete_files) == "y"){
	fis <- list.files("./data/output/", full.names = TRUE)
	
	if (length(fis) > 0) {
	  file.remove(fis)
	}
}else{
	cat("Process failed. Make sure you write \"Y\" in order to continue")
}



# Write the files to the output folder
cat("Type Y in the console to write the csvs to ./data/output/")
write_files <- readline()

if(tolower(write_files) == "y"){
	for(i in 1:length(dfs)){
	    write.csv(dfs[[i]], str_glue("./data/output/", unique(dfs[[i]]$indicator), ".csv"), row.names = FALSE)
	}
}else{
	cat("Process failed. Make sure you write \"Y\" in order to continue")
}
