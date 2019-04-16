
USE [isw_data]
GO

/****** Object:  Index [ix_datetime_req]    Script Date: 9/7/2017 12:36:54 PM ******/
CREATE NONCLUSTERED INDEX [ix_datetime_req_2] ON [dbo].[isw_data_switchoffice_201708]
(
	[datetime_req] ASC
)

include (
post_tran_id
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



DECLARE @missing_date_table TABLE (missing_date DATETIME)

DECLARE @missing_post_tran_id TABLE (post_tran_id BIGINT)

INSERT INTO @missing_date_table (missing_date) VALUES('20170820'), ('20170822'), ('20170823'), ('20170824'), ('20170825'), ('20170826'), ('20170827'), ('20170828'), ('20170829')

DECLARE @current_date DATETIME
DECLARE @current_date_plus_one DATETIME
DECLARE @sql VARCHAR(MAX)
DECLARE @super_table_post_tran_ids TABLE (post_tran_id BIGINT)
DECLARE @isw_table_post_tran_ids TABLE (post_tran_id BIGINT)
DECLARE @post_tran_diff_table TABLE (post_tran_id BIGINT)

DECLARE  date_cursor CURSOR LOCAL FORWARD_ONLY LOCAL FORWARD_ONLY FOR  SELECT missing_date FROM   @missing_date_table
OPEN  date_cursor
FETCH NEXT FROM date_cursor INTO @current_date 
WHILE (@@FETCH_STATUS =0 ) BEGIN
set @current_date_plus_one = DATEADD(D, 1, @current_date)

DELETE FROM  @super_table_post_tran_ids
INSERT INTO @super_table_post_tran_ids exec('SELECT  post_tran_id FROM  OPENQUERY ([172.25.10.85],''SELECT  post_tran_id FROM  post_tran (NOLOCK, index = ix_post_tran_7) WHERE  datetime_req >= CONVERT(VARCHAR(10),'''+@current_date+''',112) AND datetime_req <  CONVERT(VARCHAR(10),'''+@current_date_plus_one+''',112)');

DELETE FROM  @isw_table_post_tran_ids
INSERT INTO @isw_table_post_tran_ids
SELECT  post_tran_id FROM  [isw_data_switchoffice_201708] WITH  (nolock) where datetime_req >= @current_date AND datetime_req < @current_date_plus_one

DELETE FROM @post_tran_diff_table
INSERT INTO @post_tran_diff_table

SELECT post_tran_id FROM   @super_table_post_tran_ids  WHERE   post_tran_id NOT IN (
SELECT post_tran_id FROM   @isw_table_post_tran_ids
)

INSERT INTO [isw_data_switchoffice_201708] 
SELECT tran_nr,post_tran_id,ptc.post_tran_cust_id,sink_node_name,message_type,tran_type,system_trace_audit_nr,rsp_code_req,rsp_code_rsp,auth_id_rsp,acquiring_inst_id_code,retrieval_reference_nr,
datetime_req,datetime_tran_local,from_account_id,to_account_id,tran_amount_req,tran_amount_rsp,tran_currency_code,settle_amount_req,settle_amount_rsp,settle_tran_fee_req,settle_tran_fee_rsp,
settle_currency_code,pos_entry_mode,tran_reversed,source_node_name,pan,terminal_id,card_acceptor_id_code,merchant_type,card_acceptor_name_loc,totals_group,card_product,pos_terminal_type,
pan_encrypted,payee,extended_tran_type,settle_amount_impact,tran_completed,
structured_data_req,online_system_id FROM  (SELECT  * FROM  [172.25.10.85].[postilion_office].dbo.post_tran  WITH (NOLOCK)  WHERE post_tran_id IN (SELECT  post_tran_id  FROM  @post_tran_diff_table) )pt JOIN  [172.25.10.85].[postilion_office].dbo.post_tran_cust ptc (NOLOCK)
 on pt.post_tran_id = ptc.post_tran_cust_id
 
 
  OPTION(RECOMPILE)
 
FETCH NEXT FROM date_cursor INTO @current_date 
END
CLOSE date_cursor
DEALLOCATE date_cursor


