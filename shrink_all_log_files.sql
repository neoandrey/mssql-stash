USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_log_file_manager]    Script Date: 11/28/2013 08:12:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec usp_log_file_manager  @growth_factor =5, @set_checkpoint= 1, @save_to ='G:\postilion_log_backup',  @possible_growth_space =18920000
--exec sp_helpfile;	
ALTER PROCEDURE [dbo].[usp_log_file_manager] (@growth_factor INT, @set_checkpoint BIT, @save_to VARCHAR (255),  @possible_growth_space BIGINT) AS 

    BEGIN

	DECLARE @logFileName VARCHAR(500)

	DECLARE @log_file_save_location VARCHAR(50)

	DECLARE @free_space BIGINT
	
	DECLARE @growth BIGINT
	DECLARE @growth_space_factor INT
	DECLARE @run_shrink_log BIT
	DECLARE @error INT

	CREATE TABLE #TEMP_FILE_PROPS_TABLE (
	       [name] VARCHAR(500),
		   [filesize] BIGINT,
	       [maxsize] BIGINT,
		   [free_space] BIGINT,
		   [growth] BIGINT
	)
    SELECT @save_to = ISNULL(@save_to,'F:');
	INSERT INTO #TEMP_FILE_PROPS_TABLE (name, filesize, maxsize, free_space,growth )SELECT [name],size,maxsize, free_space = ([MAXSIZE] - [SIZE]),growth FROM sysfiles WHERE [NAME] LIKE '%log%'; 
    SELECT * FROM #TEMP_FILE_PROPS_TABLE;
    
	DECLARE space_cursor  CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT [free_space] FROM #TEMP_FILE_PROPS_TABLE
    DECLARE  growth_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT growth FROM #TEMP_FILE_PROPS_TABLE

	OPEN  space_cursor
	OPEN growth_cursor

	FETCH NEXT FROM space_cursor INTO @free_space 
    FETCH NEXT FROM growth_cursor INTO @growth 
    
	WHILE (@@FETCH_STATUS =0)
	  BEGIN
		SELECT @growth_space_factor = @free_space / @growth
		
		IF (@growth_space_factor < @growth_factor AND @free_space>= 0) 
		   BEGIN
			SELECT  @run_shrink_log =1
			BREAK
		   END
		ELSE 		
			BEGIN
                         
                          SELECT @free_space = @possible_growth_space - ABS(@free_space+1)
                          SELECT @free_space AS ACTUAL_FREESPACE,  @possible_growth_space AS POSSIBLE_GROWTH_SPACE;
                          SELECT @growth_space_factor = @free_space / @growth
                          IF (@growth_space_factor < @growth_factor) 
			                 BEGIN
			  	               SELECT  @run_shrink_log =1
			                 BREAK
		  	 END
                     
		 END
		FETCH NEXT FROM space_cursor INTO @free_space 
    FETCH NEXT FROM  growth_cursor INTO @growth 
	  END
	        CLOSE space_cursor;
	  		CLOSE growth_cursor;
			DEALLOCATE space_cursor
			DEALLOCATE growth_cursor

	IF  (@run_shrink_log=1) 
		BEGIN

			SELECT @log_file_save_location = @save_to+'\postilion_office_log_'+REPLACE((SELECT CONVERT(VARCHAR (50),GETDATE(), 105)),'-', '_')+'.trn'
			SELECT @log_file_save_location =REPLACE (@log_file_save_location, '\\','\');

			CREATE TABLE #TEMP_LOG_TABLE (LOG_FILE_NAME VARCHAR(500))

			INSERT INTO #TEMP_LOG_TABLE (LOG_FILE_NAME) SELECT LTRIM(RTRIM(name)) FROM sysfiles WHERE name like '%log%'

			SELECT * FROM #TEMP_LOG_TABLE
			 SELECT * FROM #TEMP_FILE_PROPS_TABLE;
			 
			IF (@set_checkpoint=1)
			 BEGIN
			  BEGIN TRY
			  			     
			  	CHECKPOINT;

			  	PRINT 'Checkpoint has been succesfully created'+CHAR(10)
			  	
			  END TRY
			    BEGIN CATCH
			    
			    PRINT 'Checkpoint could not be created'+CHAR(10)
			    
			    END CATCH
             END

            ALTER DATABASE postilion_office SET RECOVERY FULL

		    BEGIN TRY
				PRINT 'Backing up log files...'+CHAR(10)
				BACKUP LOG postilion_office TO DISK =@log_file_save_location
				PRINT 'Backup command complete.'+CHAR(10)
            END TRY
            BEGIN CATCH
				PRINT 'Backup failed...'+CHAR(10)
            END CATCH
			
			DECLARE log_file_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT LOG_FILE_NAME FROM #TEMP_LOG_TABLE
			OPEN log_file_cursor
			FETCH NEXT FROM log_file_cursor INTO @logFileName

			WHILE (@@FETCH_STATUS =0)BEGIN
				    PRINT CHAR(10)+'Shrinking log file : '+@logFileName+'...'+CHAR(10)
					DBCC SHRINKFILE (@logFileName,TRUNCATEONLY)
					PRINT CHAR(10)+'Shrink complete.'
		
				FETCH NEXT FROM log_file_cursor INTO @logFileName
			  END

			CLOSE log_file_cursor;
			DEALLOCATE log_file_cursor

			ALTER DATABASE postilion_office SET RECOVERY SIMPLE

			DROP TABLE #TEMP_LOG_TABLE

			DROP TABLE #TEMP_FILE_PROPS_TABLE

	       END
	   ELSE 
	   BEGIN
	    SELECT 'No log files to shrink.';
	   PRINT CHAR(10)+'No log files to shrink.';
	   END
	
      DELETE FROM extract_tran;    
	

	
	END



