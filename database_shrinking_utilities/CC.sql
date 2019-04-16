USE tempdb
GO

SET NOCOUNT ON
SET	QUOTED_IDENTIFIER ON

/***************************************************************************
CC
							
Written by: David Paul Giroux							
Date: Fall 2008															
Purpose: This script is designed to be called by Candidate Commands Plus.
	See CandidateFileSizeMgmtCommandsPlus.sql for more info.
			
A specially modified version of Candidate Commands
									
***************************************************************************/

DECLARE	@cmd nvarchar(1000)          -- various commands
DECLARE	@counter tinyint            -- Number of databases
DECLARE	@crlf nchar(2)               -- carriage return line feed
DECLARE	@db sysname                 -- Database Name

SET		@crlf = NCHAR(13) + NCHAR(10)

-- Databases to examine
DECLARE @Databases TABLE  (
	DID tinyint IDENTITY(1,1) primary key,
	db sysname NULL
	)

DECLARE @Results TABLE  (
	DBName sysname,
	[FileName] sysname,
	FileType sysname,
	Drive char(1),
	UsedData varchar(25),
	TotalDataSize varchar(25)
	)

-- Hold values from xp_fixeddrives
DECLARE @DiskInfo TABLE(
	Drive char(1) primary key,
	MBFree int
	)

-- Gather databases
INSERT @Databases
SELECT	DISTINCT sd.[name]
FROM	sys.master_files mf WITH (NOLOCK)
JOIN	sys.databases sd WITH (NOLOCK)
ON		mf.database_id = sd.database_id
WHERE	sd.[state] = 0
AND		sd.is_read_only = 0
AND		sd.is_in_standby = 0
AND		sd.[name] NOT IN ('model', 'tempdb')
AND		mf.[type] = 0
-- to exclude databases that have a full text-catalog offline
AND		sd.database_id NOT IN (
                            SELECT DISTINCT database_id
                            FROM  sys.master_files WITH (NOLOCK)
                            WHERE [state] <> 0)

SET		@counter = SCOPE_IDENTITY()

WHILE	@counter > 0
BEGIN
		SELECT	@db = db
		FROM	@Databases
		WHERE	DID = @counter    

		SELECT @cmd = 

		N'USE [' + @db + N']' +  @crlf + 
		N'SET NOCOUNT ON' + @crlf + 
		N'SELECT     '+ QUOTENAME(@db, '''') + N',' + @crlf + 
		N'[name],' + @crlf + 
		N'CASE type ' + @crlf + 
		N'     WHEN 0 THEN ''DATA''' + @crlf + 
		N'     WHEN 1 THEN ''LOG'''  + @crlf + 
		N'     ELSE ''Other''' + @crlf + 
		N'END,' + @crlf + 
		N'LEFT(physical_name, 1), ' + @crlf + 
		N'CAST(FILEPROPERTY ([name], ''SpaceUsed'')/128.0 as varchar(15)),' + @crlf + 
		N'CAST([size]/128.0 as varchar(15))' + @crlf + 
		N'FROM sys.database_files WITH (NOLOCK)' + @crlf + 
		N'WHERE      [state] = 0' + @crlf + 
		N'AND        [type] IN (0,1)'
	
		-- Preliminary results
		INSERT @Results
		(DBName, [FileName], FileType, Drive, UsedData, TotalDataSize)
		EXEC (@cmd)

		SET   @counter = @counter - 1
END

-- Command determines free space in MB
INSERT INTO @DiskInfo
EXEC master..xp_fixeddrives

SELECT	DBName,
		[FileName],
		FileType,
		r.Drive,
		UsedData,
		TotalDataSize,
		MBFree
FROM	@Results r
JOIN	@DiskInfo d
ON		r.Drive = d.Drive
	

