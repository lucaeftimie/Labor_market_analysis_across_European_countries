# Legend of the datasets


<img width="1400" height="408" alt="image" src="https://github.com/user-attachments/assets/8ce077a0-638b-4459-b24b-b8cf775a4489" />






# Sections


### 1 - Preprocessing: 
The purpose of this section is to clean the data.

**Processing csv:**  
&emsp; Function which reads the csv files containing the data about economic indicators.  
&emsp; The function selects the columns "country_id" "year" and "value" from each file.


```
processing_csv <- function(curr_dir)
return value = list of dataframes
```


**Common country codes:**  
&emsp; Function which recursively identifies the common country codes between two or more dataframes.  
&emsp; Exit condition: if (index > length(dfs))


```
common_country_codes <- function(dfs, index = 1, common = NULL)
return value = common_country_codes(dfs, index + 1, common)
```


### 2.1 - Descriptive statistics

The purpose of this section is to import the data and calculate the statistical indicators. 


<img width="896" height="331" alt="image" src="https://github.com/user-attachments/assets/e03db656-d164-4318-9ff0-0de78c10eb37" />


**Import data:**    
&emsp; Function which imports the data into the R environment from a specific folder  
&emsp; The function asks, in the terminal, for deleting the contents of the destination folder, for copying the the data from the upstream folder
and for loading the dataframes into R as tibbles.


```
import_data <- function(current_folder, upstream)
return value = list of dataframes
```


### 2.2 - Correlation matrix
The purpose of this section is to calculate the correlation matrix between the indicators.


<img width="800" height="665" alt="image" src="https://github.com/user-attachments/assets/c8d33aec-7850-4f00-adc4-cbdf9cfdb70e" />


### 3 - Dimensionality reduction and clustering
The purpose of this section is to synthesize the information in the datasets and group the countries based on the components discovered in the dimensionality reduction algorithm.

</br>
</br>
</br>
</br>

<img width="900" height="564" alt="image" src="https://github.com/user-attachments/assets/016d8ba6-730d-4f01-9f20-1387589eed8c" />

</br>
</br>
</br>
</br>

<img width="900" height="564" alt="image" src="https://github.com/user-attachments/assets/7ebd2a23-fd3e-43bb-9c64-b39ea56ee308" />


### 4 - Linear Regression
The purpose of these modules is to create the linear regression model and to apply the hypothesis testing on the model.  
The function is dedicated for one country at a time. 
Then the function is applied for each indicator or country respectively.  

**Regression model**  
Function which fits the linear regression model and applies the hypothesis testing for the classical assumptions of the model alongside stationarity and cointegration
```
run_ts_ols <- function(cty_code)
return value = list of dfs which are named in accordance with the data in them:
list(
    model              
    stationarity       
    johansen          
    coef               
    global_test        
    normality          
    autocorrelation   
    homoscedasticity   
    multicolinearity  
    fitted             
    forecast           
  )
```
