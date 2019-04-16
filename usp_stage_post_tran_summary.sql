ALTER PROCEDURE usp_stage_post_tran_summary  AS BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

 DECLARE @report_date VARCHAR (30)
 DECLARE @report_table VARCHAR(255)
 DECLARE @server_name VARCHAR(255)
  
 SELECT @report_date = CONVERT(varchar(10), [reportDate],112), @report_table =[tableName],   @server_name = [serverName] FROM [postilion_office].[dbo].[post_tran_summary_staging_info]  (nolock)
 
 IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@report_table) AND type in (N'U')) BEGIN
    EXEC ( 'DROP TABLE '+@report_table);
 
 END
 
 EXEC('CREATE TABLE '+@report_table+' (
 	[post_tran_id] [bigint] NOT NULL,[post_tran_cust_id] [bigint] NOT NULL,[prev_post_tran_id] [bigint] NULL,[sink_node_name] [dbo].[POST_NAME] NULL,[tran_postilion_originated] [dbo].[POST_BOOL] NOT NULL,[tran_completed] [dbo].[POST_BOOL] NOT NULL,[message_type] [char](4) NOT NULL,[tran_type] [char](2) NULL,[tran_nr] [bigint] NOT NULL,[system_trace_audit_nr] [char](6) NULL, '+
 	'[rsp_code_req] [char](2) NULL,[rsp_code_rsp] [char](2) NULL,[abort_rsp_code] [char](2) NULL,[auth_id_rsp] [char](6) NULL,[retention_data] [varchar](999) NULL,[acquiring_inst_id_code] [varchar](11) NULL,[message_reason_code] [char](4) NULL,[retrieval_reference_nr] [char](12) NULL,[datetime_tran_gmt] [datetime] NULL,[datetime_tran_local] [datetime] NOT NULL,[datetime_req] [datetime] NOT NULL,[datetime_rsp] [datetime] NULL,[realtime_business_date] [datetime] NOT NULL,[recon_business_date] [datetime] NOT NULL,[from_account_type] [char](2) NULL,[to_account_type] [char](2) NULL,[from_account_id] [varchar](28) NULL,[to_account_id] [varchar](28) NULL,[tran_amount_req] [dbo].[POST_MONEY] NULL,[tran_amount_rsp] [dbo].[POST_MONEY] NULL,[settle_amount_impact] [dbo].[POST_MONEY] NULL,[tran_cash_req] [dbo].[POST_MONEY] NULL,[tran_cash_rsp] [dbo].[POST_MONEY] NULL,[tran_currency_code] [dbo].[POST_CURRENCY] NULL,[tran_tran_fee_req] [dbo].[POST_MONEY] NULL,[tran_tran_fee_rsp] [dbo].[POST_MONEY] NULL,[tran_tran_fee_currency_code] [dbo].[POST_CURRENCY] NULL,[settle_amount_req] [dbo].[POST_MONEY] NULL,[settle_amount_rsp] [dbo].[POST_MONEY] NULL,[settle_tran_fee_req] [dbo].[POST_MONEY] NULL,[settle_tran_fee_rsp] [dbo].[POST_MONEY] NULL,[settle_currency_code] [dbo].[POST_CURRENCY] NULL,[tran_reversed] [char](1) NULL,[prev_tran_approved] [dbo].[POST_BOOL] NULL,[extended_tran_type] [char](4) NULL,[payee] [char](25) NULL,[online_system_id] [int] NULL,[receiving_inst_id_code] [varchar](11) NULL,[routing_type] [int] NULL,[source_node_name] [dbo].[POST_NAME] NOT NULL,[pan] [varchar](19) NULL,[card_seq_nr] [varchar](3) NULL,[expiry_date] [char](4) NULL,[terminal_id] [dbo].[POST_TERMINAL_ID] NULL,[terminal_owner] [varchar](25) NULL,[card_acceptor_id_code] [char](15) NULL,[merchant_type] [char](4) NULL,[card_acceptor_name_loc] [char](40) NULL,[address_verification_data] [varchar](29) NULL,[totals_group] [varchar](12) NULL,[pan_encrypted] [char](18) NULL, pos_entry_mode VARCHAR(3) ) ON [PRIMARY]
')

exec('INSERT INTO '+@report_table +' SELECT * FROM  OPENQUERY(['+@server_name +'],  ''SELECT  [post_tran_id],t.[post_tran_cust_id],[prev_post_tran_id],[sink_node_name],[tran_postilion_originated],[tran_completed],[message_type],[tran_type],[tran_nr],[system_trace_audit_nr],[rsp_code_req],[rsp_code_rsp],[abort_rsp_code],[auth_id_rsp],[retention_data],[acquiring_inst_id_code],[message_reason_code],[retrieval_reference_nr],[datetime_tran_gmt],[datetime_tran_local],[datetime_req],[datetime_rsp],[realtime_business_date],[recon_business_date],[from_account_type],[to_account_type],[from_account_id],[to_account_id],[tran_amount_req],[tran_amount_rsp],[settle_amount_impact],[tran_cash_req],[tran_cash_rsp],[tran_currency_code],[tran_tran_fee_req],[tran_tran_fee_rsp],[tran_tran_fee_currency_code],[settle_amount_req],[settle_amount_rsp],[settle_tran_fee_req],[settle_tran_fee_rsp],[settle_currency_code],[tran_reversed],[prev_tran_approved],[extended_tran_type],[payee],[online_system_id],[receiving_inst_id_code],[routing_type],[source_node_name],[pan],[card_seq_nr],[expiry_date],[terminal_id],[terminal_owner],[card_acceptor_id_code],[merchant_type],[card_acceptor_name_loc],[address_verification_data],[totals_group],[pan_encrypted],[pos_entry_mode] 
FROM 
(  SELECT * FROM post_tran pt (NOLOCK, index (ix_post_tran_9))   JOIN 
 (SELECT [date] rec_business_date FROM [get_dates_in_range]('''''+ @report_date + ''''','''''+@report_date+'''''))r ON r.rec_business_date = pt.recon_business_date 
 ) t 

  JOIN POST_TRAN_CUST c (NOLOCK, INDEX(pk_post_tran_cust)) 
 ON  t.post_tran_cust_id = c.post_tran_cust_id

OPTION (recompile)'')' );


EXEC ('ALTER VIEW  post_tran_summary AS SELECT * FROM  '+@report_table+' WITH (nolock)')


END