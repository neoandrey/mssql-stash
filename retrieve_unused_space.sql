USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[retrieve_unused_space]    Script Date: 9/29/2017 8:46:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[retrieve_unused_space]  AS BEGIN


	DECLARE @name VARCHAR(30);
	DECLARE @targetsize VARCHAR(30);
	DECLARE @query VARCHAR(1000);


	IF ( OBJECT_ID('tempdb.dbo.#data_file_info') IS NOT NULL)
			 BEGIN
				  DROP TABLE #data_file_info
			 END
	CHECKPOINT

	SELECT
	      name
	    , filename
	    , convert(decimal(12,2),round(a.size/128.000,2)) as FileSizeMB
	    , convert(decimal(12,2),round(fileproperty(a.name,'SpaceUsed')/128.000,2)) as SpaceUsedMB
	    , convert(decimal(12,2),round((a.size-fileproperty(a.name,'SpaceUsed'))/128.000,2)) as FreeSpaceMB
	INTO #data_file_info
	FROM dbo.sysfiles a;

	DECLARE file_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT name,SpaceUsedMB FROM #data_file_info WHERE FreeSpaceMB >2000
	OPEN file_cursor;
	FETCH NEXT FROM file_cursor INTO @name,@targetsize

	WHILE (@@FETCH_STATUS=0)BEGIN
    	SET @name =RTRIM(@name);
		SET @targetsize =FLOOR(@targetsize - 1000);
		SET @query = 'DBCC SHRINKFILE('''+@name+''','+@targetsize+')'
		EXEC (@query);
		PRINT 'Running shrink command: ';
		PRINT @query+CHAR(10)
	FETCH NEXT FROM file_cursor INTO @name,@targetsize
	END

	CLOSE file_cursor;
	DEALLOCATE file_cursor;

end



GO


