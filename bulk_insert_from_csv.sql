BULK
       INSERT 
           Flowers 
           		FROM  'c:\path_to_csv_file'
   WITH (

			FIELDTERMINATOR =',',
			ROWTERMINATOR ='\n'

		)
           		
           		GO

  BULK INSERT [stored_procedure_paramaters] FROM 'C:\temp\stored_proc_params.txt' WITH(
     FIELDTERMINATOR ='\t', ROWTERMINATOR ='\n',KEEPNULLS
  )