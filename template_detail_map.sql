select * from reports_crystal_template  temp (NOLOCK)JOIN  reports_crystal cry (NOLOCK)
  ON  TEMP.template = replace (convert(varchar(max),CRY.template),'C:\postilion\', '')
  JOIN reports_entity ent (nolock) on
  cry.entity = ent.entity_id
  where template = 'B04 -TPP Settlement File Detail_naira_dollar_with_rate_issuer'
  
  
  select 'C:\postilion\Office\base\bin\run_office_process.cmd Reports '+name start_report_job_command,* from reports_crystal_template  temp (NOLOCK)JOIN  reports_crystal cry (NOLOCK)
  ON  TEMP.template = replace (convert(varchar(max),CRY.template),'C:\postilion\', '')
  JOIN reports_entity ent (nolock) on
  cry.entity = ent.entity_id
  where cry.template LIKE  '%B04 -TPP Settlement File Detail_naira_dollar_with_rate_issuer%'
     or  cry.template LIKE  '%B04 -TPP Settlement File Detail_csv.rpt%'
     or  cry.template LIKE  '%B04 -TPP Settlement File Detail_csv_IBTC.rpt%'
     or  cry.template LIKE  '%B04 -TPP Settlement File Detail_msc2.rpt%'
     or  cry.template LIKE  '%B04 -TPP Settlement File Detail_msc2_universal.rpt%'
	 
	 
	      
     SELECT  name job_name, step_name,step_id, command FROM  msdb.dbo.sysjobs s JOIN msdb.dbo.sysjobsteps t ON s.job_id = t.job_id  where command in (select 'C:\postilion\Office\base\bin\run_office_process.cmd Reports '+name+' - ' from reports_crystal_template  temp (NOLOCK)JOIN  reports_crystal cry (NOLOCK)
  ON  TEMP.template = replace (convert(varchar(max),CRY.template),'C:\postilion\', '')
  JOIN reports_entity ent (nolock) on
  cry.entity = ent.entity_id
  where cry.template LIKE  '%B04 -TPP Settlement File Detail_naira_dollar_with_rate_issuer%' or  cry.template LIKE  '%B04 -TPP Settlement File Detail_csv.rpt%' or  cry.template LIKE  '%B04 -TPP Settlement File Detail_csv_IBTC.rpt%'  or  cry.template LIKE  '%B04 -TPP Settlement File Detail_msc2.rpt%' or  cry.template LIKE  '%B04 -TPP Settlement File Detail_msc2_universal.rpt%'
     )
     