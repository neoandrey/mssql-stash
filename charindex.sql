SELECT CHARINDEX('a','ABCDEFGHIJKLMNOPQRSTUVWXYZ');



SELECT DISTINCT REPLACE(REPLACE(REPLACE(online_node_name, 'SWT', ''),'src', ''), 'snk', '') AS bank, online_node_name INTO #temp_switch_node_mapping FROM [172.25.10.68].[postilion_office].dbo.post_online_node

SELECT  DISTINCT swt.bank, asp.online_node_name, swt.online_node_name  FROM #temp_switch_node_mapping swt,post_online_node asp WHERE CHARINDEX(swt.bank, asp.online_node_name) >=1 ORDER BY swt.bank