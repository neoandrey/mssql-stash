DECLARE @databaseName VARCHAR(255);
DECLARE @loginName VARCHAR(255);
DECLARE @maxNumOfConnections INT;
DECLARE @maxDurationInMins INT;


 year	yy, yyyy

quarter qq, q

month   mm, m

dayofyear dy, y

day dd, d

week wk, ww

Hour hh 

minute mi, n

second ss, s

millisecond ms 


--select db_name(dbid) , count(*) 'connections count' from sysprocesses where spid > 50 and  @@spid group by db_name(dbid) order by count(*) desc

SELECT DB_NAME (dbid), * FROM sysprocesses WHERE dbid=0;
SELECT DB_NAME (dbid), * FROM sysprocesses WHERE dbid=1;
SELECT  DATEDIFF(mi, last_batch, GETDATE())/60.0, * FROM sysprocesses WHERE dbid=6;
SELECT  dbid AS DATABASE_ID,  DB_NAME (dbid) AS DATABASE_NAME, LOGINAME, COUNT(dbid) AS NUMBER_OF_CONNECTIONS FROM sysprocesses GROUP BY dbid,LOGINAME  HAVING  COUNT(dbid)  >1  ORDER BY dbid;


SELECT
procs.spid
, procs.blocked AS BLOCKING_PROCESS
, DB_NAME(procs.dbid) AS DATABASE_NAME
,right(convert(varchar, 
            dateadd(ms, datediff(ms, procs.last_batch, getdate()), '1900-01-01'), 
            121), 12) as 'QUERY_DURATION'
, procs.loginame AS LOGIN_NAME
, CAST(text AS VARCHAR(1000)) AS SQL_QUERY
FROM sys.sysprocesses procs 
OUTER APPLY sys.dm_exec_sql_text (procs.sql_handle) WHERE procs.dbid = 6 
and DATEDIFF (mi,procs.last_batch,getdate())>0.500



select
    p.spid
,   right(convert(varchar, 
            dateadd(ms, datediff(ms, P.last_batch, getdate()), '1900-01-01'), 
            121), 12) as 'batch_duration'
,   P.program_name
,   P.hostname
,   P.loginame
from master.dbo.sysprocesses P
where P.spid > 50
and      P.status not in ('background', 'sleeping')
and      P.cmd not in ('AWAITING COMMAND'
                    ,'MIRROR HANDLER'
                    ,'LAZY WRITER'
                    ,'CHECKPOINT SLEEP'
                    ,'RA MANAGER')
order by batch_duration desc





USE AdventureWorksDW2008R2;
GO

IF EXISTS  (SELECT *FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[neo_get_key_total_new]') AND type in (N'P', N'PC'))
	BEGIN
		DROP PROCEDURE [dbo].[neo_get_key_total_new]
	END
GO

CREATE PROCEDURE neo_get_key_total_new AS
BEGIN

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
--SET NOCOUNT ON

	DECLARE @TABLE_STORE TABLE ( FACT_FINANCE_COLUMN VARCHAR(30));
	DECLARE @currentColumn VARCHAR(30);
	DECLARE @tempName VARCHAR(20);
	DECLARE @SCENARIOKEY_TOTAL_ONE BIGINT;
	DECLARE @SCENARIOKEY_TOTAL_TWO BIGINT;
	DECLARE @SCENARIOKEY_TOTAL_THREE BIGINT;
	DECLARE @DEPARTMENTGROUPKEY_TOTAL_ONE BIGINT;
	DECLARE @DEPARTMENTGROUPKEY_TOTAL_TWO BIGINT;
	DECLARE @DEPARTMENTGROUPKEY_TOTAL_THREE BIGINT;
	INSERT INTO @TABLE_STORE(FACT_FINANCE_COLUMN) VALUES
		 ('scenarioKey')	 ,('DepartmentGroupKey')
	 ;
	DECLARE columnCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT FACT_FINANCE_COLUMN FROM @TABLE_STORE;
	
	OPEN columnCursor;
	
	FETCH NEXT FROM columnCursor INTO @currentColumn;
	
	WHILE @@FETCH_STATUS=0
	BEGIN
	
	IF (@currentColumn = 'scenarioKey')
				BEGIN
					SELECT  @SCENARIOKEY_TOTAL_ONE= SUM(Amount) FROM FactFinance WHERE scenarioKey=1
					SELECT  @SCENARIOKEY_TOTAL_TWO= SUM(Amount) FROM FactFinance WHERE scenarioKey=2
					SELECT  @SCENARIOKEY_TOTAL_THREE= SUM(Amount) FROM FactFinance WHERE scenarioKey=3
				END
	ELSE IF	(@currentColumn =  'DepartmentGroupKey') 
			BEGIN
				SELECT @DEPARTMENTGROUPKEY_TOTAL_ONE= SUM(Amount)FROM FactFinance WHERE DepartmentGroupKey=1
				SELECT @DEPARTMENTGROUPKEY_TOTAL_TWO= SUM(Amount) FROM FactFinance WHERE DepartmentGroupKey=2
				SELECT @DEPARTMENTGROUPKEY_TOTAL_THREE= SUM(Amount) FROM FactFinance WHERE DepartmentGroupKey=3
			END	
			FETCH NEXT FROM columnCursor INTO @currentColumn;
	END
	CLOSE columnCursor;
	
	DEALLOCATE  columnCursor;
	
	SELECT @SCENARIOKEY_TOTAL_ONE AS SCENARIOKEY_TOTAL_ONE,@SCENARIOKEY_TOTAL_TWO AS SCENARIOKEY_TOTAL_TWO,@SCENARIOKEY_TOTAL_THREE AS SCENARIOKEY_TOTAL_THREE,@DEPARTMENTGROUPKEY_TOTAL_ONE AS DEPARTMENTGROUPKEY_TOTAL_ONE,@DEPARTMENTGROUPKEY_TOTAL_TWO AS DEPARTMENTGROUPKEY_TOTAL_TWO,@DEPARTMENTGROUPKEY_TOTAL_THREE ASDEPARTMENTGROUPKEY_TOTAL_THREE; 
	
END


/*
USE master;

GO

ALTER DATABASE AdventureWorksDW2008r2 SET OFF;
USE AdventureWorksDW2008r2;

exec sp_helpfile ;
GO
*/
DECLARE @databaseName VARCHAR(255) =NULL;
DECLARE @query NVARCHAR(500) =NULL;
DECLARE @handle INT =0;

--SET @databaseName='AdventureWorksDW2008R2';
--EXEC sp_execute @query,@handle OUTPUT;

EXEC sp_prepare @handle OUTPUT, N'@databaseName VARCHAR(255)',N'ALTER DATABASE AdventureWorksDW2008R2 MODIFY FILE (NAME =AdventureWorksDW2008R2_Data,FILENAME='++' )';
--EXEC sp_execute  @query,@handle OUTPUT;

EXEC sp_execute @handle,'AdventureWorksDW2008R2';

--REPAIR DATABASE STATEMENT
--ALTER DATABASE AdventureWorksDW2008R2 MODIFY FILE (NAME=AdventureWorksDW2008R2_Data, FILENAME='C:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\AdventureWorks2008R2_Data.mdf');

use AdventureWorksDW2008R2; 
exec sp_helpfile;
DBCC SQLPERF
DBCC SHRINKFILE (AdventureWorksDW2008R2_log 

use AdventureWorksDW2008R2; 
SELECT * FROM SYS.database_files WHERE name LIKE '%AdventureWorksDW2008R2%';

/*
USE master;

GO

ALTER DATABASE AdventureWorksDW2008r2 SET OFF;
USE AdventureWorksDW2008r2;

exec sp_helpfile ;
GO
*/
DECLARE @databaseName VARCHAR(255) =NULL;
DECLARE @query NVARCHAR(500) =NULL;
DECLARE @handle INT =0;

--SET @databaseName='AdventureWorksDW2008R2';
--EXEC sp_execute @query,@handle OUTPUT;

EXEC sp_prepare @handle OUTPUT, N'@databaseName VARCHAR(255)',N'ALTER DATABASE AdventureWorksDW2008R2 MODIFY FILE (NAME =AdventureWorksDW2008R2_Data,FILENAME='++' )';
--EXEC sp_execute  @query,@handle OUTPUT;

EXEC sp_execute @handle,'AdventureWorksDW2008R2';

--REPAIR DATABASE STATEMENT
--ALTER DATABASE AdventureWorksDW2008R2 MODIFY FILE (NAME=AdventureWorksDW2008R2_Data, FILENAME='C:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\AdventureWorks2008R2_Data.mdf');

use AdventureWorksDW2008R2; 
exec sp_helpfile;
DBCC SQLPERF
DBCC SHRINKFILE (AdventureWorksDW2008R2_log 

use AdventureWorksDW2008R2; 
SELECT * FROM SYS.database_files WHERE name LIKE '%AdventureWorksDW2008R2%';

USE [AdventureWorksDW2008R2]
GO

/****** Object:  StoredProcedure [dbo].[neo_get_key_total]    Script Date: 09/30/2013 07:15:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[neo_get_key_total]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[neo_get_key_total]
GO

USE [AdventureWorksDW2008R2]
GO

/****** Object:  StoredProcedure [dbo].[neo_get_key_total]    Script Date: 09/30/2013 07:15:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[neo_get_key_total] AS
BEGIN

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
--SET NOCOUNT ON

	DECLARE @TABLE_STORE TABLE ( FACT_FINANCE_COLUMN VARCHAR(30));
	DECLARE @currentColumn VARCHAR(30);
	DECLARE @tempName VARCHAR(20);
	INSERT INTO @TABLE_STORE(FACT_FINANCE_COLUMN) VALUES
		 ('scenarioKey')	 ,('DepartmentGroupKey')
	 ;
	DECLARE columnCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT FACT_FINANCE_COLUMN FROM @TABLE_STORE;
	
	OPEN columnCursor;
	
	FETCH NEXT FROM columnCursor INTO @currentColumn;
	
	WHILE @@FETCH_STATUS=0
	BEGIN
	
	IF (@currentColumn = 'scenarioKey')
				BEGIN
					SELECT  'SCENARIOKEY_TOTAL_ONE'= SUM(Amount),TEST_COLUMN =1 FROM FactFinance WHERE scenarioKey=1
					SELECT  'SCENARIOKEY_TOTAL_TWO'= SUM(Amount) FROM FactFinance WHERE scenarioKey=2
					SELECT  'SCENARIOKEY_TOTAL_THREE'= SUM(Amount) FROM FactFinance WHERE scenarioKey=3
				END
	ELSE IF	(@currentColumn =  'DepartmentGroupKey') 
			BEGIN
				SELECT 'DEPARTMENTGROUPKEY_TOTAL_ONE'= SUM(Amount)FROM FactFinance WHERE DepartmentGroupKey=1
				SELECT 'DEPARTMENTGROUPKEY_TOTAL_TWO'= SUM(Amount) FROM FactFinance WHERE DepartmentGroupKey=2
				SELECT 'DEPARTMENTGROUPKEY_TOTAL_THREE'= SUM(Amount) FROM FactFinance WHERE DepartmentGroupKey=3
			END	
			FETCH NEXT FROM columnCursor INTO @currentColumn;
	END
	CLOSE columnCursor;
	
	DEALLOCATE  columnCursor;
	
	
END
GO


 The query governor does not allow the execution of any query that has a running time that exceeds a specified query cost. The query cost is the estimated time, in seconds, required to execute a query, and it is estimated prior to execution based on an analysis by the query engine. By default, the query governor is turned off, meaning there is no maximum cost. To activate the query governor, complete the following steps:
1. In the Server Properties dialog box, go to the Connections page.
2. Select the option Use Query Governor To Prevent Long-Running Queries.
3. In the box below the option, type a maximum query cost limit. The valid range is 0 through 2,147,483,647. A value of 0 disables the query governor; any other value sets a maximum query cost limit.
4. Click OK.
With sp_configure, the following Transact-SQL statement will activate the query governor:
exec sp_configure "query governor cost limit", <limit>
You can also set a per-connection query cost limit in Transact-SQL using the following statement:
set query_governor_cost_limit <limit> 

