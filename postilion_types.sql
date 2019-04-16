if exists (select * from dbo.systypes where name = N'POST_BOOL')
exec sp_droptype N'POST_BOOL'
GO

if exists (select * from dbo.systypes where name = N'POST_CURRENCY')
exec sp_droptype N'POST_CURRENCY'
GO

if exists (select * from dbo.systypes where name = N'POST_FLOAT_MONEY')
exec sp_droptype N'POST_FLOAT_MONEY'
GO

if exists (select * from dbo.systypes where name = N'POST_ID')
exec sp_droptype N'POST_ID'
GO

if exists (select * from dbo.systypes where name = N'POST_MONEY')
exec sp_droptype N'POST_MONEY'
GO

if exists (select * from dbo.systypes where name = N'POST_NAME')
exec sp_droptype N'POST_NAME'
GO

if exists (select * from dbo.systypes where name = N'POST_NOTES')
exec sp_droptype N'POST_NOTES'
GO

if exists (select * from dbo.systypes where name = N'POST_PLUGIN_ID')
exec sp_droptype N'POST_PLUGIN_ID'
GO

if exists (select * from dbo.systypes where name = N'POST_TERMINAL_ID')
exec sp_droptype N'POST_TERMINAL_ID'
GO

if exists (select * from dbo.systypes where name = N'RECON_TABLE_NAME_EXTENSION')
exec sp_droptype N'RECON_TABLE_NAME_EXTENSION'
GO

setuser
GO

EXEC sp_addtype N'POST_BOOL', N'numeric(1,0)', N'null'
GO

setuser
GO

setuser
GO

EXEC sp_addtype N'POST_CURRENCY', N'char (3)', N'null'
GO

setuser
GO

setuser
GO

EXEC sp_addtype N'POST_FLOAT_MONEY', N'numeric(20,4)', N'null'
GO

setuser
GO

setuser
GO

EXEC sp_addtype N'POST_ID', N'int', N'null'
GO

setuser
GO

setuser
GO

EXEC sp_addtype N'POST_MONEY', N'numeric(16,0)', N'null'
GO

setuser
GO

setuser
GO

EXEC sp_addtype N'POST_NAME', N'varchar (30)', N'null'
GO

setuser
GO

setuser
GO

EXEC sp_addtype N'POST_NOTES', N'varchar (255)', N'null'
GO

setuser
GO

setuser
GO

EXEC sp_addtype N'POST_PLUGIN_ID', N'varchar (20)', N'null'
GO

setuser
GO

setuser
GO

EXEC sp_addtype N'POST_TERMINAL_ID', N'char (8)', N'null'
GO

setuser
GO

setuser
GO

EXEC sp_addtype N'RECON_TABLE_NAME_EXTENSION', N'varchar (50)', N'null'
GO

setuser
GO

