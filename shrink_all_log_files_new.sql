IF (   OBJECT_ID('tempdb.dbo.##log_table') is not null ) BEGIN

    DROP TABLE ##log_table
END


CREATE TABLE  ##log_table (log_file VARCHAR(300))

EXEC sp_MSforeachdb @command1 =  'DECLARE @current_logfile  VARCHAR(255);
DECLARE logfile_cursor CURSOR STATIC READ_ONLY LOCAL FORWARD_ONLY FOR SELECT name FROM [?].sys.sysfiles WHERE  groupid = 0;
OPEN logfile_cursor
FETCH NEXT FROM logfile_cursor INTO @current_logfile;
WHILE (@@FETCH_STATUS =0)BEGIN
INSERT INTO ##log_table (log_file)  VALUES (''USE  [?]; CHECKPOINT; DBCC SHRINKFILE ([''+ @current_logfile+''],0); '')
FETCH NEXT FROM logfile_cursor INTO @current_logfile;
END
CLOSE logfile_cursor
DEALLOCATE  logfile_cursor';



DECLARE  @log_shrink_command  VARCHAR(500)

DECLARE shrink_cursor CURSOR STATIC READ_ONLY LOCAL FORWARD_ONLY FOR SELECT log_file FROM ##log_table
OPEN shrink_cursor
FETCH NEXT FROM  shrink_cursor INTO @log_shrink_command 
WHILE( @@FETCH_STATUS = 0 ) BEGIN
PRINT 'Running query: '+@log_shrink_command;
EXEC(@log_shrink_command)
FETCH NEXT FROM  shrink_cursor INTO @log_shrink_command 
END
CLOSE shrink_cursor
DEALLOCATE shrink_cursor



