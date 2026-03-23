select 
	unique(df1.region_id) 
from 
	df1, df2, df3, df4, df5 
where
	df1.region_id = df2.region_id and
	df2.region_id = df3.region_id and
	df3.region_id = df4.region_id and
	df4.region_id = df5.region_id;
