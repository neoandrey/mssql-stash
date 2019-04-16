
alter procedure [dbo].[get_post_office_drive_and_file_details] as

BEGIN

		IF ( OBJECT_ID('tempdb.dbo.#temp_drive_info') IS NOT NULL)
		 BEGIN
				  DROP TABLE #temp_drive_info
		 END
		IF ( OBJECT_ID('tempdb.dbo.#temp_file_info') IS NOT NULL)
		 BEGIN
				  DROP TABLE #temp_file_info
		 END

		IF ( OBJECT_ID('tempdb.dbo.#Drive') IS NOT NULL)
		 BEGIN
				  DROP TABLE #Drive
		 END
		 
		DECLARE	@Drive TINYINT,
			@SQL VARCHAR(100)

		SET	@Drive = 97

		-- Setup Staging Area
		CREATE	TABLE #Drives 
			(
				Drive CHAR(1),
				Info VARCHAR(80)
			)

		WHILE @Drive <= 122
			BEGIN
				SET	@SQL = 'EXEC master.dbo.xp_cmdshell ''fsutil volume diskfree ' + CHAR(@Drive) + ':'''
				print @SQL+char(10)
				 INSERT  INTO #Drives ( Info)  exec(@SQL)
			

				UPDATE	#Drives
				SET	Drive = CHAR(@Drive)
				WHERE	Drive IS NULL

				SET	@Drive = @Drive + 1
			END

		-- Show the expected output
		SELECT		Drive,
				CONVERT(FLOAT,SUM(CASE WHEN Info LIKE 'Total # of bytes             : %' THEN CAST(REPLACE(SUBSTRING(Info, 32, 48), CHAR(13), '') AS BIGINT) ELSE CAST(0 AS BIGINT) END)) /1024.0 AS DriveSize,
				CONVERT(FLOAT,SUM(CASE WHEN Info LIKE 'Total # of free bytes        : %' THEN CAST(REPLACE(SUBSTRING(Info, 32, 48), CHAR(13), '') AS BIGINT) ELSE CAST(0 AS BIGINT) END))/1024.0  AS FreeSpace,
				CONVERT(FLOAT, SUM(CASE WHEN Info LIKE 'Total # of avail free bytes  : %' THEN CAST(REPLACE(SUBSTRING(Info, 32, 48), CHAR(13), '') AS BIGINT) ELSE CAST(0 AS BIGINT) END)) /1024.0  AS AvailableSpace

		 INTO
		 
		 #temp_drive_info
		FROM		(
					SELECT	Drive,
						Info
					FROM	#Drives
					WHERE	Info LIKE 'Total # of %'
				) AS d
		GROUP BY	Drive

			SELECT name
				, filename
				, convert(decimal(12,2),round(size/128.000,2)) as FileSizeMB
				, convert(decimal(12,2),round(fileproperty(name,'SpaceUsed')/128.000,2)) as SpaceUsedMB
				, convert(decimal(12,2),round((size-fileproperty(name,'SpaceUsed'))/128.000,2)) as FreeSpaceMB
				,  convert(decimal(12,2),round((growth)/128.000,2)) as growth
				,  convert(decimal(12,2),round((maxsize)/128.000,2)) as maxsize
				, CASE WHEN left(name, 3)='tem' THEN 'TEMPDB'
			      WHEN left(name, 3)='pos' THEN 'POSTILION_OFFICE'
			      WHEN left(name, 3)='isw' THEN 'ISW_DATA'
			      END [DbName]
				INTO
		 
		 #temp_file_info
			FROM postilion_office.dbo.sysfiles 
			
			INSERT INTO #temp_file_info
			SELECT
	      			name
				, filename
				, convert(decimal(12,2),round(size/128.000,2)) as FileSizeMB
				, convert(decimal(12,2),round(fileproperty(name,'SpaceUsed')/128.000,2)) as SpaceUsedMB
				, convert(decimal(12,2),round((size-fileproperty(name,'SpaceUsed'))/128.000,2)) as FreeSpaceMB
				,  convert(decimal(12,2),round((growth)/128.000,2)) as growth
				,  convert(decimal(12,2),round((maxsize)/128.000,2)) as maxsize
				, CASE WHEN left(name, 3)='tem' THEN 'TEMPDB'
			      WHEN left(name, 3)='pos' THEN 'POSTILION_OFFICE'
			      WHEN left(name, 3)='isw' THEN 'ISW_DATA'
			      END [DbName]
			FROM tempdb.dbo.sysfiles
			
			SELECT UPPER(Drive+ ':') [DriveLetter] , name, filename [FileName],
			CASE
				WHEN FileSizeMB/(1024.0 *1024.0)>1 THEN  CONVERT(VARCHAR(100), FileSizeMB/(1024.0 *1024.0)) +'TB'
				WHEN FileSizeMB/(1024.0 *1024.0)<1 AND FileSizeMB/(1024.0)>1 THEN    CONVERT(VARCHAR(100),FileSizeMB/(1024.0)) +'GB'
				ELSE  CONVERT(VARCHAR(100),FileSizeMB) +'MB'
			END Size,
			[DbName], 
			CASE
				WHEN growth/(1024.0 *1024.0)>1 THEN  CONVERT(VARCHAR(100), growth/(1024.0 *1024.0)) +'TB'
				WHEN growth/(1024.0 *1024.0)<1 AND growth/(1024.0)>1 THEN    CONVERT(VARCHAR(100),growth/(1024.0)) +'GB'
				ELSE  CONVERT(VARCHAR(100),growth) +'MB'
			END growth,
			  
			  	CASE
							WHEN maxsize/(1024.0 *1024.0)>1 THEN  CONVERT(VARCHAR(100), maxsize/(1024.0 *1024.0)) +'TB'
				WHEN maxsize/(1024.0 *1024.0)<1 AND maxsize/(1024.0)>1 THEN    CONVERT(VARCHAR(100),maxsize/(1024.0)) +'GB'
				ELSE  CONVERT(VARCHAR(100),maxsize) +'MB'
			END
			 maxsize,	
			CASE
				WHEN DriveSize/(1024.0 *1024.0 * 1024.0)>1 THEN   CONVERT(VARCHAR(100),DriveSize/(1024.0 *1024.0 * 1024.0)) +'TB'
				WHEN DriveSize/(1024.0 *1024.0 * 1024.0)<1 AND DriveSize/(1024.0 *1024.0)>1 THEN   CONVERT(VARCHAR(100),DriveSize/(1024.0*1024.0))+'GB'
				WHEN DriveSize/(1024.0 *1024.0)<1 AND DriveSize/(1024.0)>1 THEN   CONVERT(VARCHAR(100),DriveSize/(1024.0)) +'MB'
				ELSE  CONVERT(VARCHAR(100),DriveSize)+'KB'
			END TotalSize, 
			 CONVERT(VARCHAR(100),CONVERT (FLOAT, FreeSpace)/CONVERT (FLOAT, DriveSize)* 100.0)+'%' [PercentageFree],
			CASE
				WHEN FreeSpace/(1024.0 *1024.0 * 1024.0)>1 THEN    CONVERT(VARCHAR(100),FreeSpace/(1024.0 *1024.0 * 1024.0))+'TB'
				WHEN FreeSpace/(1024.0 *1024.0 * 1024.0)<1 AND FreeSpace/(1024.0 *1024.0)>1 THEN   CONVERT(VARCHAR(100), FreeSpace/(1024.0*1024.0)) +'GB'
				WHEN FreeSpace/(1024.0 *1024.0)<1 AND FreeSpace/(1024.0)>1 THEN   CONVERT(VARCHAR(100), FreeSpace/(1024.0))+'MB'
				ELSE  CONVERT(VARCHAR(100),FreeSpace)+'KB'
			END
			 UsableSpace FROM #temp_file_info finfo   left JOIN #temp_drive_info dinfo ON
			  
			LEFT(finfo.filename,1) = dinfo.Drive
END
GO
