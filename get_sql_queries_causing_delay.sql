--sp_whoisactive @get_plans=1, @get_additional_info=1

SELECT 'kill '+CONVERT(VARCHAR(5),spid) kill_command, loginame,physical_io,cpu, *  FROM sys.sysprocesses procs 

 WHERE physical_io >=200  AND program_name  NOT IN ( 'jTDS', 'Office Normalization', 'Certificate Manager')
and loginame NOT IN('SA','reportadmin')
and  loginame NOT LIKE '%admin%'  order by physical_io desc, cpu desc 