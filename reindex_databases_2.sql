USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[reindex_databases]    Script Date: 10/29/2014 12:57:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[reindex_databases] (@exception_list VARCHAR(1000))

AS

BEGIN
	DECLARE @Database VARCHAR(255)  
	DECLARE @Table VARCHAR(255)  
	DECLARE @cmd NVARCHAR(500)  
	DECLARE @general_exception_list NVARCHAR(1500) 
	DECLARE @fillfactor INT

        DECLARE @database_table TABLE (
        database_name VARCHAR(250)

        )
      INSERT INTO @database_table ( database_name) SELECT part FROM usf_split_string( @general_exception_list,',');
	SET @fillfactor = 90
	SET @general_exception_list = 'master,msdb,tempdb,model,postilion,Northwind,pubs';
	SET @exception_list =ISNULL(@exception_list,'');
	SET @general_exception_list =@general_exception_list+@exception_list;
	
	DECLARE DatabaseCursor CURSOR FOR  SELECT name FROM master.dbo.sysdatabases  
	WHERE name NOT IN (SELECT database_name FROM @database_table)  
	ORDER BY 1  
	
	OPEN DatabaseCursor  
	
	FETCH NEXT FROM DatabaseCursor INTO @Database  
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
	
	   SET @cmd = 'DECLARE TableCursor CURSOR FOR SELECT ''['' + table_catalog + ''].['' + table_schema + ''].['' +
	  table_name + '']'' as tableName FROM [' + @Database + '].INFORMATION_SCHEMA.TABLES
	  WHERE table_type = ''BASE TABLE'''  
	
	   -- create table cursor  
	   EXEC (@cmd)  
	   OPEN TableCursor  
	
	   FETCH NEXT FROM TableCursor INTO @Table  
	   WHILE @@FETCH_STATUS = 0  
	   BEGIN  
	
	       IF (@@MICROSOFTVERSION / POWER(2, 24) >= 9)
	       BEGIN
	           -- SQL 2005 or higher command
	           PRINT 'Rebuilding indexes on table: '+@Table
	           SET @cmd = 'ALTER INDEX ALL ON ' + @Table + '  WITH (  PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON,  ONLINE = OFF, SORT_IN_TEMPDB = OFF,FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ')'
	           EXEC (@cmd)
	       END
	       ELSE
	       BEGIN
	          -- SQL 2000 command
	          DBCC DBREINDEX(@Table,' ',@fillfactor)  
	       END
	
	       FETCH NEXT FROM TableCursor INTO @Table  
	   END  
	
	   CLOSE TableCursor  
	   DEALLOCATE TableCursor  
	
	   FETCH NEXT FROM DatabaseCursor INTO @Database  
	END  
	CLOSE DatabaseCursor  
	DEALLOCATE DatabaseCursor 
END

