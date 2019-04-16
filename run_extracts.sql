exec master.dbo.xp_cmdshell 'start /wait C:\postilion\office\base\bin\run_office_process.cmd /ndc Extract 3LEx1'

 WHILE ((SELECT COUNT(*) FROM post_process_queue (NOLOCK) WHERE process_name in ('Extracts','Normalization'))>0)  WAITFOR DELAY '00:00:45'; 

exec master.dbo.xp_cmdshell 'C:\postilion\office\base\bin\run_office_process.cmd /ndc Extract 3LEx2'

 WHILE ((SELECT COUNT(*) FROM post_process_queue (NOLOCK) WHERE process_name in ('Extracts','Normalization'))>0)  WAITFOR DELAY '00:00:45'; 

exec master.dbo.xp_cmdshell 'C:\postilion\office\base\bin\run_office_process.cmd /ndc Extract 3LEx3'
 WHILE ((SELECT COUNT(*) FROM post_process_queue (NOLOCK) WHERE process_name in ('Extracts','Normalization'))>0)  WAITFOR DELAY '00:00:45'; 

exec master.dbo.xp_cmdshell 'C:\postilion\office\base\bin\run_office_process.cmd /ndc Extract 3LEx4'
 WHILE ((SELECT COUNT(*) FROM post_process_queue (NOLOCK) WHERE process_name in ('Extracts','Normalization'))>0)  WAITFOR DELAY '00:00:45'; 

exec master.dbo.xp_cmdshell 'C:\postilion\office\base\bin\run_office_process.cmd /ndc Extract 3LEx5'
 WHILE ((SELECT COUNT(*) FROM post_process_queue (NOLOCK) WHERE process_name in ('Extracts','Normalization'))>0)  WAITFOR DELAY '00:00:45'; 

exec master.dbo.xp_cmdshell 'C:\postilion\office\base\bin\run_office_process.cmd /ndc Extract 3LEx6'
 WHILE ((SELECT COUNT(*) FROM post_process_queue (NOLOCK) WHERE process_name in ('Extracts','Normalization'))>0)  WAITFOR DELAY '00:00:45'; 

exec master.dbo.xp_cmdshell 'C:\postilion\office\base\bin\run_office_process.cmd /ndc Extract 3LEx7'