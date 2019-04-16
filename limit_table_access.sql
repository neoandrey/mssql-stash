USE AdventureWorks2008R2;
GO

exec sp_msforeachtable "DENY SELECT ON ? TO [neotest];"
GO

GRANT SELECT ON  AdventureWorks2008R2.[Person].[Person] to [neotest]
GO 
