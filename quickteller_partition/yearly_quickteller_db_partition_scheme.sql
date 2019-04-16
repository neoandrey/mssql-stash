
CREATE PARTITION SCHEME yearly_quickteller_db_partition_scheme AS PARTITION
	partition_quickteller_db_by_year TO
	(
[Transaction_2008]
,[Transaction_2009]
, [Transaction_2010]
,[Transaction_2011]
,[Transaction_2012]
,[Transaction_2013]
,[Transaction_2014]
,[Transaction_2015]
,[Transaction_2016]
,[Transaction_2017]
,[Transaction_2018]
,[Transaction_2019]
,[Transaction_2020]
,[Transaction_2021]
,[Transaction_2022]
,[Transaction]
	)
	
	