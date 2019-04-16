DECLARE @startDate VARCHAR (30)
DECLARE @endDate VARCHAR (30)

SET @startDate='2014-07-01'
SET @endDate='2014-07-31'

select ds.sink_node_name,ds.rsp_code_rsp,dbo.formatRspCodeStr(ds.rsp_code_rsp) as rsp_code_description, COUNT(tran_nr) as count_nr, tcount_tab.tr_count as total, Convert(FLOAT, COUNT(tran_nr)/tcount_tab.tr_count *100.00) AS 'percentage (%)'

from post_tran ds(nolock), (SELECT  sink_node_name, COUNT(tran_nr) as tr_count FROM post_tran WHERE /*tran_type = '01'  AND*/ (datetime_req >= @startDate and datetime_req < @endDate)  group by sink_node_name)  tcount_tab

where ds.sink_node_name = tcount_tab.sink_node_name  
AND(datetime_req >= @startDate and datetime_req < @endDate)
--Use beginning of report month and begining of the next m
--and ds.sink_node_name not in ( 'PAYDIRECTsnk','BILLSsnk','VTUsnk','CCLOADsnk','FDsnk')
--and LEFT(ds.sink_node_name,3) = 'SWT'
/*and tran_type = '01'*/
group by ds.sink_node_name,ds.rsp_code_rsp,tcount_tab.tr_count
order by ds.sink_node_name,ds.rsp_code_rsp