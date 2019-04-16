USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[reset_settlement_to_yesterday]    Script Date: 01/02/2017 19:04:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[reset_settlement_to_yesterday] 

AS
BEGIN 
	DECLARE @last_settlement_date DATETIME;
	DECLARE @config_version INT;
	DECLARE @config_set_id INT;
	DECLARE @post_tran_id INT;
	DECLARE @num_of_days_ago INT;

	SET @num_of_days_ago =ISNULL(@num_of_days_ago,1);

	SET @num_of_days_ago = 0 *  @num_of_days_ago;

	SELECT @last_settlement_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,@num_of_days_ago, GETDATE()),111),'/', '-');

	SELECT  @config_version = MAX(config_version) , @config_set_id = MAX(config_set_id) FROM sstl_config_version
	
	
	
		DECLARE @backup_table_name VARCHAR(2000)
		DECLARE @date_suffix VARCHAR(1000)
		DECLARE @current_datetime DATETIME
		
		SELECT  @current_datetime = GETDATE();
	  exec postilion_office.[dbo].[usp_get_sstl_journal_daily];
	    
	    SELECT @date_suffix=REPLACE(REPLACE(REPLACE(REPLACE(GETDATE(), '-', '_'), ' ', '__'),':','_'), '.', '__');
		
		SELECT @backup_table_name ='sstl_journal_'+@date_suffix
         EXEC('SELECT [adj_id]
      ,[entry_id]
      ,[config_set_id]
      ,[session_id]
      ,j.[post_tran_id]
      ,j.[post_tran_cust_id]
      ,[sdi_tran_id]
      ,[acc_post_id]
      ,[nt_fee_acc_post_id]
      ,[coa_id]
      ,[coa_se_id]
      ,[se_id]
      ,[amount]
      ,[amount_id]
      ,[amount_value_id]
      ,[fee]
      ,[fee_id]
      ,[fee_value_id]
      ,[nt_fee]
      ,[nt_fee_id]
      ,[nt_fee_value_id]
      ,[debit_acc_nr_id]
      ,[debit_acc_id]
      ,[debit_cardholder_acc_id]
      ,[debit_cardholder_acc_type]
      ,[credit_acc_nr_id]
      ,[credit_acc_id]
      ,[credit_cardholder_acc_id]
      ,[credit_cardholder_acc_type]
      ,[business_date]
      ,[granularity_element]
      ,[tag]
      ,[spay_session_id]
      ,[spst_session_id], t.tran_nr, t.retrieval_reference_nr, t.system_trace_audit_nr,message_type,rsp_code_rsp,auth_id_rsp INTO '+@backup_table_name+' FROM sstl_journal_all j(NOLOCK) JOIN post_tran t (NOLOCK) ON t.post_tran_cust_id = J.post_tran_cust_id and t.post_tran_id = J.post_tran_id');

	EXEC  dbo.osp_sstl_jrnl_man_reset

    DELETE FROM sstl_session
 DELETE   FROM sstl_exception

         
         SET @post_tran_id =(SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req<@last_settlement_date  ORDER BY datetime_req DESC);
         
	INSERT INTO sstl_session (session_id, entity_id, config_set_id,config_version,datetime_started, last_post_tran_id,last_sdi_tran_id, completed)
	values(1,	1,	@config_set_id,	@config_version, GETDATE(), @post_tran_id,	0	,1)

END

