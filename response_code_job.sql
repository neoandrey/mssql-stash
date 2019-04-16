USE [postilion_office]
GO


CREATE TABLE #response_code_summary
	(	
			          calender_date   VARCHAR (50),
				      sink_node_name    VARCHAR (50),
				      source_node_name    VARCHAR (50), 
				      message_type    VARCHAR (50),
				      tran_type    VARCHAR (50),
				      extended_tran_type    VARCHAR (50),
				      rsp_code_rsp   VARCHAR (10),
				      recon_business_date    VARCHAR (50),
				      tran_postilion_originated    INT,
				      settle_currency_code    VARCHAR (50),
				      tran_count BIGINT,
				      rsp_code_description VARCHAR(250)
		
		)
		
INSERT INTO #response_code_summary  ( calender_date,sink_node_name,source_node_name, message_type,tran_type,extended_tran_type, rsp_code_rsp,recon_business_date,tran_postilion_originated,settle_currency_code,tran_count,rsp_code_description )
 EXEC	 [dbo].[get_swt_response_code_analysis]
		@SinkNode = 'MEGAGTBsnk',
		@SourceNode = NULL,
		@StartDate = NULL,
		@EndDate = NULL,
		@time_interval = 1,
		@report_type = NULL


SELECT * FROM  #response_code_summary

DROP TABLE #response_code_summary