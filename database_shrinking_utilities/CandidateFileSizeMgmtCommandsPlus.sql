USE tempdb
GO

SET NOCOUNT ON
SET	QUOTED_IDENTIFIER ON

DECLARE @target DECIMAL(5,2)		-- Target Free Space (MB)
DECLARE	@file sysname				-- Modified Candidate Commands Query
SET		@target = 30				-- Modify to desired value of DB Free space %
SET		@file = N'c:\dpg\CC.sql'		-- Modify directory and file name as needed

/***************************************************************************
Candidate Commands Plus	Utility
							
Written by: David Paul Giroux							
Date: Fall 2008															
Purpose: Assist in file size management.  Will produce candidate shrink/grow commands based on given Target.
	This script will execute a modified version of the Candidate Commands script against a list of designated servers.
Calls: xp_fixeddrives, cc.sql (Modified Candidate Commands script)
Data Modifications: None

Built on the Pusher engine.	

User Modifications:
 * Modify @target to desired value of free space percent
 * Pass the fully qualified name of the Candidate Commands script to @file.  The script needs to be accessible by the sql server service.
 * Mody INSERT @Servers with the desired list of servers to query

Known Issue: There is an issue when dealing with smaller values because the
candidate commands use int data type. The candidate command may round to a value equal to the current file size.
Thus a MODIFY FILE statement will fail. Workaround: Add 1 to the candidate command

After you execute this script, copy and paste the candidate commands into a new window
Sample output:
:connect Server1  ALTER DATABASE [master]  MODIFY FILE (   NAME = master,   SIZE = 4   )  GO
:connect Server2  USE [Testy] DBCC SHRINKFILE('TestyData1', 3)  GO

Then add carriage returns in the appropriate places, for example:
:connect Server1  
ALTER DATABASE [master]  MODIFY FILE (   NAME = master,   SIZE = 4   ) 
GO
:connect Server2 
USE [Testy] DBCC SHRINKFILE('TestyData1', 1) 
GO

Then execute in SQLCMD mode (MUST EXECUTE IN SQLCMD MODE)
									
***************************************************************************/

DECLARE @xcmd nvarchar(MAX)		-- Large insert statement
DECLARE @counter tinyint		-- Number of servers (adjust data type as needed)
DECLARE @cmd nvarchar(75)		-- command that pushes query
DECLARE	@Server sysname			-- ServerName
DECLARE @crlf nchar(2)			-- carriage return line feed

SET		@crlf = CHAR(13) + CHAR(10)
SET		@target = (100.0 - @target) * .01

-- List of Servers
DECLARE	@Servers TABLE (
	SID1 smallint IDENTITY(1,1) primary key,
	ServerName sysname
	)

-- Initial raw data from sqlcmd (one wide column)
DECLARE @RawResults TABLE (
	RawData nvarchar(800) -- adjust data type as needed
	)

-- Table to hold your final result set
IF OBJECT_ID('tempdb..#FinalResults') IS NOT NULL DROP TABLE #FinalResults
CREATE TABLE #FinalResults   (
	ServerName sysname,
	DBName sysname,
	[FileName] sysname,
	FileType sysname,
	Drive nchar(1),
	UsedData nvarchar(25),
	TotalDataSize nvarchar(25),
	MBFree nvarchar(10),
	Smallest decimal(10,2)
	)

-- Modify list as needed
INSERT @Servers
SELECT N'Server1' UNION ALL
SELECT N'Server2' UNION ALL
SELECT N'Server3' UNION ALL
SELECT N'Server4' UNION ALL
SELECT N'Server5' 

SET	@counter = SCOPE_IDENTITY()

-- Beginning of xp_cmdshell wrapper
-- The xp_cmdshell wrapper is used to maintain the current configuration setting of xp_cmdshell
DECLARE @xp_flag bit

IF EXISTS (SELECT * FROM sys.configurations WITH (NOLOCK)
			WHERE [NAME] = 'xp_cmdshell'
			AND		value_in_use = 1)
BEGIN	
	SET @xp_flag = 1
END
ELSE BEGIN
	SET @xp_flag = 0
	EXEC sp_configure 'show advanced options', 1
	RECONFIGURE WITH OVERRIDE
	EXEC sp_configure 'xp_cmdshell', 1
	RECONFIGURE 
END

WHILE @counter > 0
BEGIN
	SELECT	@Server = ServerName
	FROM	@Servers
	WHERE	SID1 = @counter

	SET		@cmd = N'sqlcmd -E -S ' + @Server + N' -I -h-1 -W -s"|" -i ' + @file

	INSERT @RawResults
	EXEC master..xp_cmdshell @cmd

	-- Error checking (connection)
	IF EXISTS(SELECT * FROM @RawResults WHERE RawData LIKE N'HResult%')
	BEGIN
		GOTO SkipServer
	END
	
	-- Cleanup
	DELETE	@RawResults 
	WHERE	NULLIF(RawData, '') IS NULL
	OR		RawData LIKE N'Changed%'

	-- Parse data to build SELECT statement
	SET		@xcmd = ''
	SELECT	@xcmd = @xcmd + 
			N'SELECT ' + QUOTENAME(@server, '''') + ', ' + 
			'''' + REPLACE(RawData, '|', ''', ''') + '''' + @crlf
	FROM @RawResults

	-- Store results
	INSERT #FinalResults
	(ServerName, DBName, [FileName], FileType, Drive, UsedData, TotalDataSize, MBFree)
	EXEC (@xcmd)

	IF 1 = 2
	BEGIN
		SkipServer:
		SELECT N'Server ' + @server + N' is not reachable.  Please remove the server from your list.'
	END
	
	-- Prepare for next server
	DELETE @RawResults
	SET	@counter = @counter - 1
END

-- End of xp_cmdshell wrapper
IF @xp_flag = 0
BEGIN
	EXEC sp_configure 'xp_cmdshell', 0
	RECONFIGURE 
END

ALTER TABLE #FinalResults
ALTER COLUMN TotalDataSize decimal(10,2)

ALTER TABLE #FinalResults
ALTER COLUMN UsedData decimal(10,2)

ALTER TABLE #FinalResults
ALTER COLUMN MBFree bigint

UPDATE	#FinalResults
SET		Smallest = UsedData / @target


-- Uncomment this section only if you want to perform additional queries against #FinalResults using existing data
-- DECLARE @crlf char(2)			-- carriage return line feed
-- SET		@crlf = CHAR(13) + CHAR(10)

SELECT	ServerName,
		DBName,
		[FileName],
		FileType,
		Drive,
		UsedData,
		TotalDataSize - UsedData N'FreeData',
		TotalDataSize,
		CAST(((TotalDataSize - UsedData) / TotalDataSize) * 100 as decimal(5,2)) [%DataFeeSpace],
		MBFree N'DiskFreeSpace',
		Smallest N'SmallestForTarget',
		CASE
			  WHEN TotalDataSize > Smallest THEN CAST(TotalDataSize - Smallest as varchar(10)) + N' Decrease'
			  ELSE CAST(Smallest - TotalDataSize as varchar(10)) + N' Increase'
		END N'CandidateResult',
		CASE 
			WHEN Smallest - TotalDataSize > MBFree THEN N'Insufficient Disk Space'
			WHEN TotalDataSize > Smallest 
				THEN N':connect ' + ServerName + @crlf + N'USE [' + DBName + N'] DBCC SHRINKFILE(' + QUOTENAME([FileName], '''') + N', ' + CAST(CAST(Smallest as int) as varchar(10)) + N')' + @crlf + N'GO'
			ELSE	N':connect ' + ServerName + @crlf +
					N'ALTER DATABASE [' + DBName + N']' + @crlf + 
					N'MODIFY FILE (' + @crlf + 
					N'	NAME = ' + [FileName] + N',' + @crlf + 
					N'	SIZE = ' + CAST(CAST(Smallest as int) as varchar(10)) + @crlf + 
					N'	)' + @crlf + N'GO'
		END N'CandidateCommand'
FROM	#FinalResults 
ORDER BY (TotalDataSize - UsedData) / TotalDataSize

--DROP TABLE #FinalResults


