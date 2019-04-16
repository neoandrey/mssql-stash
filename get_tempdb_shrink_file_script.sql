
DECLARE @current_logfile  VARCHAR(255);
PRINT 'USE tempdb;'
DECLARE logfile_cursor CURSOR STATIC READ_ONLY LOCAL FORWARD_ONLY FOR SELECT name FROM tempdb.sys.master_files WHERE database_id = db_id('tempdb');
PRINT 'CHECKPOINT;'+CHAR(10)+' GO'+CHAR(10)
PRINT 'DBCC DROPCLEANBUFFERS;'+CHAR(10)+' GO'+CHAR(10)
PRINT 'DBCC FREEPROCCACHE;'+CHAR(10)+'  GO'+CHAR(10)
PRINT 'DBCC FREESYSTEMCACHE (''ALL'');'+CHAR(10)+'  GO'+CHAR(10)
PRINT 'DBCC FREESESSIONCACHE'+CHAR(10)+' GO'+CHAR(10)
OPEN logfile_cursor
FETCH NEXT FROM logfile_cursor INTO @current_logfile;
WHILE (@@FETCH_STATUS =0)BEGIN
pRINT('DBCC SHRINKFILE ('+ @current_logfile+',0, TRUNCATEONLY);')
FETCH NEXT FROM logfile_cursor INTO @current_logfile;
END
CLOSE logfile_cursor
DEALLOCATE  logfile_cursor
PRINT CHAR(10)+' GO'


DECLARE @log_action VARCHAR(MAX)
DECLARE @database_name VARCHAR(MAX)
SET  @database_name = 'TEMPDB'

SELECT @log_action = log_reuse_wait_desc  FROM sys.databases WHERE name = @database_name
IF (@log_action  = 'NOTHING') BEGIN

	DECLARE @log_file_shrink_table TABLE (log_file_name_shrink VARCHAR(MAX))
	DECLARE @current_logfile  VARCHAR(255);
	DECLARE logfile_cursor CURSOR STATIC READ_ONLY LOCAL FORWARD_ONLY FOR SELECT name FROM postilion_office.sys.master_files WHERE database_id = db_id(@database_name) 
	OPEN logfile_cursor
	FETCH NEXT FROM logfile_cursor INTO @current_logfile;
	WHILE (@@FETCH_STATUS =0)BEGIN
	INSERT INTO @log_file_shrink_table VALUES  ('DBCC SHRINKFILE ('+ @current_logfile+',0, TRUNCATEONLY);')
	FETCH NEXT FROM logfile_cursor INTO @current_logfile;
	END
	CLOSE logfile_cursor
	DEALLOCATE  logfile_cursor
    DECLARE @current_log_file_command VARCHAR(MAX)
    DECLARE shrink_command CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR  SELECT log_file_name_shrink FROM @log_file_shrink_table
    OPEN shrink_command
    FETCH NEXT FROM shrink_command INTO @current_log_file_command
    WHILE (@@FETCH_STATUS = 0) BEGIN
      EXEC (@current_log_file_command)
      FETCH NEXT FROM shrink_command INTO @current_log_file_command
    END
	
END


shrink file  


DECLARE @log_action VARCHAR(MAX)
DECLARE @database_name VARCHAR(MAX)
SET  @database_name = 'TEMPDB'

SELECT @log_action = log_reuse_wait_desc  FROM sys.databases WHERE name = @database_name
IF (@log_action  = 'NOTHING') BEGIN

	DECLARE @log_file_shrink_table TABLE (log_file_name_shrink VARCHAR(MAX))
	DECLARE @current_logfile  VARCHAR(255);
	DECLARE logfile_cursor CURSOR STATIC READ_ONLY LOCAL FORWARD_ONLY FOR SELECT name FROM postilion_office.sys.master_files WHERE database_id = db_id(@database_name) 
	OPEN logfile_cursor
	FETCH NEXT FROM logfile_cursor INTO @current_logfile;
	WHILE (@@FETCH_STATUS =0)BEGIN
	INSERT INTO @log_file_shrink_table VALUES  ('DBCC SHRINKFILE ('+ @current_logfile+',0, TRUNCATEONLY);')
	FETCH NEXT FROM logfile_cursor INTO @current_logfile;
	END
	CLOSE logfile_cursor
	DEALLOCATE  logfile_cursor
    DECLARE @current_log_file_command VARCHAR(MAX)
    DECLARE shrink_command CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR  SELECT log_file_name_shrink FROM @log_file_shrink_table
    OPEN shrink_command
    FETCH NEXT FROM shrink_command INTO @current_log_file_command
    WHILE (@@FETCH_STATUS = 0) BEGIN
      EXEC (@current_log_file_command)
      FETCH NEXT FROM shrink_command INTO @current_log_file_command
    END
	
END
