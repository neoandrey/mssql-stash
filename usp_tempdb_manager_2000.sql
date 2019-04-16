
/****** Object:  StoredProcedure [dbo].[usp_tempdb_manager]    Script Date: 01/24/2014 11:46:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec usp_tempdb_manager @growth_factor =5, @set_checkpoint= 1, @save_to ='G:\tempdb_backup',  @possible_growth_space =18920000
--exec sp_helpfile;	
CREATE PROCEDURE [dbo].[usp_tempdb_manager] (@growth_factor INT, @set_checkpoint BIT, @save_to VARCHAR (255),  @possible_growth_space BIGINT) AS 

    BEGIN

	DECLARE @fileName VARCHAR(500)

	DECLARE @file_save_location VARCHAR (1000)

	DECLARE @free_space BIGINT
	
	DECLARE @growth BIGINT
	DECLARE @growth_space_factor INT
	DECLARE @run_shrink BIT
	DECLARE @error INT
	DECLARE @file_save_location_file VARCHAR(1000)
	DECLARE @file_save_location_log VARCHAR(1000)
   
    
	CREATE TABLE #TEMP_FILE_PROPS_TABLE (
	       [name] VARCHAR(500),
		   [filesize] BIGINT,
	       [maxsize] BIGINT,
		   [free_space] BIGINT,
		   [growth] BIGINT
	)
    SELECT @save_to = ISNULL(@save_to,'F:');
    INSERT INTO #TEMP_FILE_PROPS_TABLE (name, filesize, maxsize, free_space,growth )SELECT [name],size,maxsize, free_space = ([MAXSIZE] - [SIZE]),growth FROM tempdb.dbo.sysfiles; 
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
			SELECT  @run_shrink =1
			BREAK
		   END
		ELSE 		
			BEGIN
                         
                          SELECT @free_space = @possible_growth_space - ABS(@free_space+1)
                          SELECT @free_space AS ACTUAL_FREESPACE,  @possible_growth_space AS POSSIBLE_GROWTH_SPACE;
                          SELECT @growth_space_factor = @free_space / @growth
                          IF (@growth_space_factor < @growth_factor) 
			                 BEGIN
			  	               SELECT  @run_shrink =1
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

	IF  (@run_shrink=1) 
		BEGIN

			SELECT @file_save_location = @save_to+'\tempdb_'+REPLACE((SELECT CONVERT(VARCHAR (50),GETDATE(), 105)),'-', '_')+'.bak'
			SELECT @file_save_location =REPLACE (@file_save_location, '\\','\');

			CREATE TABLE #TEMP_FILENAME_TABLE (FILE_NAME VARCHAR(500))

			INSERT INTO #TEMP_FILENAME_TABLE (FILE_NAME) SELECT LTRIM(RTRIM(name)) FROM tempdb.dbo.sysfiles

			SELECT * FROM #TEMP_FILENAME_TABLE
			SELECT * FROM #TEMP_FILE_PROPS_TABLE;
			 
				    BEGIN TRANSACTION
				IF (@set_checkpoint=1)
					 BEGIN
							CHECKPOINT
							SET @error = @@ERROR
							IF @error <> 0
							BEGIN  
								GOTO LogError1    
							END	
				END  					 
				PRINT 'Checkpoint has been succesfully created'+CHAR(10)
				COMMIT TRANSACTION
				GOTO  MainSection			  
				LogError1:
					PRINT 'Checkpoint could not be created'+CHAR(10)
					ROLLBACK TRANSACTION
					GOTO  MainSection 
				MainSection:
				 SET @error  =0;
					PRINT 'Backing up  files...'+CHAR(10)
					IF (RIGHT(@file_save_location,4) <> '.trn')
					 BEGIN
					 SELECT @file_save_location_file = @file_save_location+'.bak'
					    SELECT @file_save_location_log = @file_save_location+'.trn'
					 END
					BACKUP DATABASE tempdb TO DISK =@file_save_location_file
					BACKUP LOG tempdb TO DISK =@file_save_location_log
					IF(@error <> 0) BEGIN
						GOTO LogError1 
                    END
                    ELSE
                        BEGIN
                        
                                 PRINT 'Backup command complete.'+CHAR(10)
                                
                                 GOTO Subsection
                          
                        END
                        
                        LogError2:
				PRINT 'Backup failed!'+CHAR(10)
				ROLLBACK TRANSACTION
			
			Subsection:
			
			DECLARE file_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT FILE_NAME FROM #TEMP_FILENAME_TABLE
			OPEN file_cursor
			FETCH NEXT FROM file_cursor INTO @fileName

			WHILE (@@FETCH_STATUS =0)BEGIN
				
				PRINT CHAR(10)+'Shrinking file : '+@fileName+'...'+CHAR(10)
				 exec ('USE [tempdb];  DBCC SHRINKFILE ('+@fileName+',TRUNCATEONLY)');
				IF (@@ERROR=0) BEGIN 
				    PRINT CHAR(10)+'Shrink complete.'
				END
				ELSE
				   BEGIN
				    PRINT CHAR(10)+'Unable to shrink file: '+@fileName;
				   END
		
				FETCH NEXT FROM file_cursor INTO @fileName
			  END

			CLOSE file_cursor;
			DEALLOCATE file_cursor

			DROP TABLE #TEMP_FILENAME_TABLE

			DROP TABLE #TEMP_FILE_PROPS_TABLE

	       END
	   ELSE 
	   BEGIN
	    SELECT 'No files to shrink.';
	   PRINT CHAR(10)+'No files to shrink.';
	   END
	END



