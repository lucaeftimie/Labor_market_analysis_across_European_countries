source("./modules/libraries.R")
source("./modules/import_data.R")

dfs <- import_data("./data/csv/", "./../1-preprocessing/data/output")
long_df <- bind_rows(dfs)


desc_stat <-  long_df |>
  group_by(indicator) |>
  summarise(
    N       = sum(!is.na(value)),
    Mean   = round(mean(value, na.rm = TRUE), 3),
    Median = round(median(value, na.rm = TRUE), 3),
    St.Dev  = round(sd(value, na.rm = TRUE), 3),
    Min     = round(min(value, na.rm = TRUE), 3),
    Max     = round(max(value, na.rm = TRUE), 3),
    CV      = round(sd(value, na.rm = TRUE) / mean(value, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  ) |>
  arrange(indicator)

print(desc_stat)

cat("Type Y in the console to delete the files from ./data/output")
delete_data <- readline()

if (tolower(delete_data) == "y"){
	curr_folder_files <- list.files("./data/output/", full.names = TRUE)
	
	if (length(curr_folder_files) > 0) {
		file.remove(curr_folder_files)
	}
	
}else{
	cat("Process failed. Make sure you write \"Y\" in order to continue")
}

cat("Type Y in the console to write the stats desc table to ./data/output")
write_table <- readline()
if (tolower(write_table) == "y"){
	write.csv(desc_stat, file = "./data/output/descriptive_statistics.csv", row.names = FALSE)
}
