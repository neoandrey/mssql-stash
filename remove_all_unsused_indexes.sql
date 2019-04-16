
SELECT ' DROP INDEX '+[INDEX NAME] +' ON   '+[OBJECT NAME], * FROM  #temp_indexes  WHERE  user_seeks = 0  AND user_scans  = 0 AND user_lookups = 0  
AND  [INDEX NAME] is not null