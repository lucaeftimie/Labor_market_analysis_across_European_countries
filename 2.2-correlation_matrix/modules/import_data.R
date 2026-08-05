import_data <- function(current_folder, upstream){
	
	# Delete files from current folder
	cat("Type Y in the console to delete all files from ./data/csv/ .")
	delete_files <- readline()
	
	if (tolower(delete_files) == "y"){
		curr_folder_files <- list.files("./data/csv/", full.names = TRUE)
		
		if (length(curr_folder_files) > 0) {
			file.remove(curr_folder_files)
		}
		
	}else{
		cat("Process failed. Make sure you write \"Y\" in order to continue")
	}
	
	# Copy files from upstream to current folder
	cat("Type Y in the console to copy files from", upstream, "to ./data/csv/")
	copy_files <- readline()
	
	if (tolower(copy_files) == "y"){
		upstream_files <- list.files(upstream, full.names = TRUE)
		file.copy(upstream_files, current_folder)
		
	}else{
		cat("Process failed. Make sure you write \"Y\" in order to continue")
	}
	
	# Import files into R, as tibbles
	cat("Type Y in the console to import the files into R, as tibbles")
	imp_files <- readline()
	if(tolower(imp_files) == "y"){
	  dfs <- list()
	  file_names <- list.files(current_folder)
	  for(i in 1:length(file_names)){
	    file_path <- str_glue(current_folder, file_names[i])
	    dfs[[i]] <- as_tibble(read.csv(file_path))
	  }
	  return(dfs)
	}else{
		cat("Process failed. Make sure you write \"Y\" in order to continue")
	}
	
	return(NULL)
}