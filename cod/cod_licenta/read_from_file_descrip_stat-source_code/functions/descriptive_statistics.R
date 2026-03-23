descriptive_statistics <- function(df){
  return (summarise(df, mean = mean(value), sd = sd(value), min = min(value), max = max(value), cv = sd(value) / mean(value),  n = n()))
}