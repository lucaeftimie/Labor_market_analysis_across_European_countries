
region_selector <- function(df, id){
  return (df |> filter (region_id == id))
}