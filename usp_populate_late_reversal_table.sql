
create  PROCEDURE usp_populate_late_reversal_table  @start_date DATETIME , @end_date DATETIME

AS

BEGIN

		IF ( OBJECT_ID('tempdb.dbo.#reversals') IS NOT NULL)
		 BEGIN
				  DROP TABLE #reversals
		 END
		 
				IF ( OBJECT_ID('tempdb.dbo.#reversal_categories') IS NOT NULL)
		 BEGIN
				  DROP TABLE #reversal_categories
		 END
		 
		SET @start_date  = ISNULL (@start_date,REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),111),'/', '') )
		
		SET @end_date    = ISNULL (@end_date,REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '') )
		 
		SELECT   post_tran_id, trans.post_tran_cust_id,datetime_req, tran_nr, prev_post_tran_id, rsp_code_rsp, message_type,settle_amount_impact ,settle_amount_req ,settle_amount_rsp  ,settle_currency_code, sink_node_name,system_trace_audit_nr,tran_amount_req ,tran_amount_rsp  ,tran_currency_code, terminal_id,retrieval_reference_nr  INTO #reversals FROM 
		POST_TRAN trans (NOLOCK) LEFT JOIN POST_TRAN_CUST cust (NOLOCK) 
		ON 
		trans.post_tran_cust_id = cust.post_tran_cust_id
		WHERE
		datetime_req>=@start_date  and datetime_req <@end_date AND message_type ='0420'
		
 
		select rev.post_tran_id,rev.post_tran_cust_id rev_post_tran_cust_id,trans.post_tran_cust_id trans_post_tran_cust_id, trans.datetime_req trans_datetime_req, rev.datetime_req  rev_datetime_req, rev.prev_post_tran_id, rev.message_type rev_message_type, rev.rsp_code_rsp rev_rsp_code_rsp,  trans.message_type post_tran_message_type,trans.rsp_code_rsp trans_rsp_code_rsp, rev.tran_nr,rev.settle_amount_impact ,rev.settle_amount_req ,rev.settle_amount_rsp  ,rev.settle_currency_code, rev.sink_node_name,rev.system_trace_audit_nr,rev.tran_amount_req ,rev.tran_amount_rsp  ,rev.tran_currency_code ,  terminal_id,rev.retrieval_reference_nr, rev.recon_business_date, rev.online_system_id,
		 case when datepart(D,rev.datetime_req) - datepart(D, trans.datetime_req )>0  THEN
		'LATE'
		  when datepart(D,rev.datetime_req) - datepart(D, trans.datetime_req )=0 then  'TIMELY'
		END as reversal_type
		INTO #reversal_categories
		from #reversals rev
		JOIN post_tran trans (NOLOCK) 
		on trans.post_tran_id = rev.prev_post_tran_id
		 
		INSERT  INTO  tbl_late_reversals ([post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr],  [recon_business_date],[online_system_id] )  SELECT [post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr], [recon_business_date],[online_system_id] FROM  #reversal_categories WHERE reversal_type = 'LATE'
		
				IF ( OBJECT_ID('tempdb.dbo.#reversals') IS NOT NULL)
		 BEGIN
				  DROP TABLE #reversals
		 END
		 
				IF ( OBJECT_ID('tempdb.dbo.#reversal_categories') IS NOT NULL)
		 BEGIN
				  DROP TABLE #reversal_categories
				  
			
		 END
		 

END

