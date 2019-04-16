DROP TABLE #temp_pan_table
SELECT TOP 99999 ROW_NUMBER() OVER (ORDER BY datetime_creation DESC) AS datetime_creation_sorted ,tran_nr  INTO  #temp_pan_table FROM post_tran_exception 

DELETE FROM post_tran_exception WHERE tran_nr NOT IN (SELECT tran_nr FROM #temp_pan_table)