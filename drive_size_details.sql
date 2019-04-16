DECLARE	@Drive TINYINT,
	@SQL VARCHAR(100)

SET	@Drive = 97

-- Setup Staging Area
DECLARE	@Drives TABLE
	(
		Drive CHAR(1),
		Info VARCHAR(80)
	)

WHILE @Drive <= 122
	BEGIN
		SET	@SQL = 'EXEC XP_CMDSHELL ''fsutil volume diskfree ' + CHAR(@Drive) + ':'''
		
		INSERT	@Drives
			(
				Info
			)
		EXEC	(@SQL)

		UPDATE	@Drives
		SET	Drive = CHAR(@Drive)
		WHERE	Drive IS NULL

		SET	@Drive = @Drive + 1
	END

-- Show the expected output
SELECT		Drive,
		CONVERT(FLOAT,SUM(CASE WHEN Info LIKE 'Total # of bytes             : %' THEN CAST(REPLACE(SUBSTRING(Info, 32, 48), CHAR(13), '') AS BIGINT) ELSE CAST(0 AS BIGINT) END)) /1024.0 AS DriveSize,
		CONVERT(FLOAT,SUM(CASE WHEN Info LIKE 'Total # of free bytes        : %' THEN CAST(REPLACE(SUBSTRING(Info, 32, 48), CHAR(13), '') AS BIGINT) ELSE CAST(0 AS BIGINT) END))/1024.0  AS FreeSpace,
		CONVERT(FLOAT, SUM(CASE WHEN Info LIKE 'Total # of avail free bytes  : %' THEN CAST(REPLACE(SUBSTRING(Info, 32, 48), CHAR(13), '') AS BIGINT) ELSE CAST(0 AS BIGINT) END)) /1024.0  AS AvalableSpace
FROM		(
			SELECT	Drive,
				Info
			FROM	@Drives
			WHERE	Info LIKE 'Total # of %'
		) AS d
GROUP BY	Drive
ORDER BY	Drive


	SELECT
	      name
	    , filename
	    , convert(decimal(12,2),round(a.size/128.000,2)) as FileSizeMB
	    , convert(decimal(12,2),round(fileproperty(a.name,'SpaceUsed')/128.000,2)) as SpaceUsedMB
	    , convert(decimal(12,2),round((a.size-fileproperty(a.name,'SpaceUsed'))/128.000,2)) as FreeSpaceMB
	FROM dbo.sysfiles a;