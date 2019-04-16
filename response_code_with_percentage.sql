select ds.sink_node_name,ds.source_node_name,ds.rsp_code_rsp,dbo.formatRspCodeStr(ds.rsp_code_rsp) as rsp_code_description, COUNT(*)as count_nr, tcount_tab.tr_count as total, COUNT(*)/tcount_tab.tr_count *100.00 AS 'percentage (%)'

from isw_data_switchoffice ds(nolock), (SELECT  sink_node_name, COUNT(*) as tr_count FROM isw_data_switchoffice WHERE tran_type = '01'  AND(datetime_req >= '20140422' and datetime_req < '20140430')  group by sink_node_name)  tcount_tab

where ds.sink_node_name = tcount_tab.sink_node_name    AND(datetime_req >= '20140422' and datetime_req < '20140430') --Use beginning of report month and begining of the next m

and ds.sink_node_name not in ( 'PAYDIRECTsnk','BILLSsnk','VTUsnk','CCLOADsnk','FDsnk')
and LEFT(ds.sink_node_name,3) = 'SWT'
and tran_type = '01'
group by ds.sink_node_name,ds.source_node_name,ds.rsp_code_rsp,tcount_tab.tr_count
order by ds.sink_node_name,ds.source_node_name,ds.rsp_code_rsp