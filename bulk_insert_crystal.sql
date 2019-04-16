BULK INSERT  [crystal].[dbo].[stored_procedure_paramaters] FROM 'C:\temp\procedure_params.txt' WITH(
  fieldterminator='\t', rowterminator='\n',KEEPNULLS

)

GO

  BULK INSERT [routines] FROM 'C:\temp\domain_stage.txt' WITH(
     FIELDTERMINATOR ='\t', ROWTERMINATOR ='\n',KEEPNULLS
  )