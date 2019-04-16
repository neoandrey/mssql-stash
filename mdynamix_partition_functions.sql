CREATE PARTITION FUNCTION [mdynamix_nov_partition_function] (datetime)
AS RANGE RIGHT FOR VALUES ('20141108', '20141116', '20141124', '20141201');


CREATE PARTITION SCHEME [mdynamix_nov_partition_scheme]
 AS
 PARTITION [mdynamix_nov_partition_function] TO 
   ( [WEEK1]  
   , [WEEK2] 
   , [WEEK3]  
   , [WEEK4]
   , [PRIMARY]) 