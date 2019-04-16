exec sp_dropdistributiondb @database = N'distribution'
GO


exec sp_dropdistributor @no_checks = 1, @ignore_distributor = 1
GO
