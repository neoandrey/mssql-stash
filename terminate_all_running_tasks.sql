Reports: select  'exec master.dbo.xp_cmdshell ''TASKKILL /IM '+spawned_name+' /F /T''' as kill_command, 'exec master.dbo.xp_cmdshell ''C:\postilion\Office\base\bin\run_office_process.cmd Reports '+process_entity+''';  WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY ''00:00:45''; WAITFOR DELAY ''00:00:45'';' as start_command,   * from post_process_queue where process_name ='Reports'
Extracts:  select  'exec master.dbo.xp_cmdshell ''TASKKILL /IM '+spawned_name+' /F /T''' as kill_command, 'exec master.dbo.xp_cmdshell ''C:\postilion\Office\base\bin\run_office_process.cmd Extracts '+process_entity+''';  WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY ''00:00:45''; WAITFOR DELAY ''00:00:45'';' as start_command,   * from post_process_queue where process_name ='Extract'
--select * from post_process_queue
SELECT  'TASKKILL /IM '+spawned_name+' /F /T' FROM post_process_queue

SELECT  'exec xp_cmdshell ''TASKKILL /IM '+spawned_name+' /F /T''' FROM post_process_queue


SET _JAVA_OPTIONS = -Xms256m -Xmx4096m

tasklist| findstr "POR"