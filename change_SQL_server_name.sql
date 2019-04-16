
--SELECT @@SERVERNAME AS 'Server Name';
SELECT * FROM sys.servers

EXEC sp_dropserver 'ASP-OFFICE' 
GO 
EXEC sp_addserver 'ASPOFFICE64', 'local' 
GO 

ALTER TABLE appzone_post_tran_temp ADD source_node_name VARCHAR(25) NULL;


sp_configure 'remote login timeout', 30
go 
reconfigure with override 
go 
					
Set the remote query timeout to 0 (infinite wait), by using this code:
sp_configure 'remote query timeout', 0 
go 
reconfigure with override 
go 


SELECT * FROM INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME like '%host%' OR COLUMN_NAME like '%address%'
	