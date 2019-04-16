USE [postilion_office]
GO


CREATE PROCEDURE osp_rpt_rsp_code_analysis	@startDate VARCHAR(30), @endDate  VARCHAR(30)

AS
BEGIN

SELECT   @startDate = isnull(@startDate, CONVERT(VARCHAR(10), DATEADD(D, -1, GETDATE()),112));

SELECT   @endDate = isnull(@startDate,  CONVERT(VARCHAR(10), GETDATE(),112));

EXEC('SELECT * FROM  OPENQUERY([172.19.75.18], '';with  rsp_code_table  ( 	Warning, StartDate,EndDate, NrTrans,sink_node_name,tran_type, extended_tran_type, message_type,rsp_code)
  AS  (
		 SELECT	
			''''NULL'''' AS Warning,
			'''''+@startDate+''''' as StartDate,  
			'''''+@endDate+''''' as EndDate,
            nr_trans as NrTrans,
			sink_node_name, 
			tran_type,
			extended_tran_type, 
			message_type,	
			rsp_code
	
		
	FROM
			 postilion_office.dbo.post_ds_nodes (NOLOCK )
	WHERE  
	(calendar_date >= '''''+@startDate+''''') 
			AND 
			(calendar_date <=  '''''+@endDate+''''') 
			AND 
			tran_postilion_originated = 1 
  )					
	SELECT 
		  null as Warning,
			'''''+@startDate+''''' as StartDate,  
			'''''+@endDate+''''' as EndDate,
		 	dbo.formatRspCodeStr(rsp_code)  rsp_code_description,
		 rsp_code,
		 sink_node_name, 
		 tran_type,
		dbo.formatTranTypeStr(tran_type, extended_tran_type, message_type)    tran_type_desciption,
		 sum(NrTrans) as NrResponses
	
	 FROM
	rsp_code_table

	GROUP BY
		 sink_node_name, rsp_code, dbo.formatRspCodeStr(rsp_code)  , tran_type,dbo.formatTranTypeStr(tran_type, extended_tran_type, message_type), extended_tran_type, message_type
	ORDER BY 
		sink_node_name, rsp_code'')')
END
			
			
		