
Arbiter:
                SELECT * INTO dup_transfers_all FROM   [arbiter].[dbo].[tbl_postilion_office_transactions_staging_transfers] WITH (nolock)
WHERE  postilion_office_transactions_id in  (
SELECT  postilion_office_transactions_id FROM  
[arbiter].[dbo].[tbl_postilion_office_transactions_staging] WITH (nolock)
)

DECLARE  @current_postilion_office_transactions_id  bigint 
DECLARE office_tran_id_cursor CURSOR STATIC READ_ONLY LOCAL FORWARD_ONLY FOR  select   postilion_office_transactions_id FROM  dup_transfers_all  (NOLOCK) 
OPEN office_tran_id_cursor
FETCH NEXT FROM  office_tran_id_cursor  INTO @current_postilion_office_transactions_id

WHILE (@@FETCH_STATUS = 0 ) BEGIN
      DELETE FROM   [tbl_postilion_office_transactions_staging_transfers] WHERE  postilion_office_transactions_id = @current_postilion_office_transactions_id
      SET IDENTITY_INSERT [tbl_postilion_office_transactions_staging_transfers] ON
            INSERT INTO [arbiter].[dbo].[tbl_postilion_office_transactions_staging_transfers] (             [postilion_office_transactions_id]        ,[issuer_code]          ,[post_tran_id]            ,[post_tran_cust_id]          ,[tran_nr]        ,[masked_pan]           ,[terminal_id]          ,[card_acceptor_id_code]            ,[card_acceptor_name_loc]           ,[tran_type_description]            ,[tran_amount_req]            ,[tran_fee_req]         ,[currency_alpha_code]        ,[system_trace_audit_nr]            ,[datetime_req]         ,[retrieval_reference_nr]           ,[acquirer_code]        ,[rsp_code_rsp]         ,[terminal_owner]       ,[sink_node_name]       ,[merchant_type]        ,[source_node_name]           ,[from_account_id]            ,[tran_tran_fee_req]            ,[auth_id_rsp]          ,[settle_amount_rsp]          ,[settle_amount_impact]       ,[pos_terminal_type]          ,[settle_currency_code]       ,[tran_currency_code]         ,[tran_currency_alpha_code]         ,[online_system_id]           ,[server_id]            ,[tran_reversed]        ,  [Logged]       , [Type]          ,[to_account]            ,[extended_tran_type] )
            SELECT      ([postilion_office_transactions_id]+6000000000),[issuer_code]      ,[post_tran_id]   ,[post_tran_cust_id]    ,[tran_nr]  ,[masked_pan]      ,[terminal_id]    ,[card_acceptor_id_code]      ,[card_acceptor_name_loc]      ,[tran_type_description]      ,[tran_amount_req]      ,[tran_fee_req]      ,[currency_alpha_code]  ,[system_trace_audit_nr]      ,[datetime_req]      ,[retrieval_reference_nr]     ,[acquirer_code]  ,[rsp_code_rsp]      ,[terminal_owner] ,[sink_node_name] ,[merchant_type]  ,[source_node_name]      ,[from_account_id]      ,[tran_tran_fee_req]    ,[auth_id_rsp]      ,[settle_amount_rsp]    ,[settle_amount_impact] ,[pos_terminal_type]      ,[settle_currency_code] ,[tran_currency_code]   ,[tran_currency_alpha_code]      ,[online_system_id]     ,[server_id]      ,[tran_reversed]  ,  [Logged] , [Type]      ,[to_account]     ,[extended_tran_type] FROM dup_transfers_all WITH  (NOLOCK)
            WHERE postilion_office_transactions_id = @current_postilion_office_transactions_id
          SET IDENTITY_INSERT [tbl_postilion_office_transactions_staging_transfers] OFF
FETCH NEXT FROM  office_tran_id_cursor  INTO @current_postilion_office_transactions_id
END
CLOSE office_tran_id_cursor
DEALLOCATE office_tran_id_cursor

ExtraSwitch

insert into  [172.25.15.14].ARBITER.dbo.dispute_log_in_dups_tab

SELECT  * FROM tbl_dispute_log (NOLOCK) WHERE   

postilion_office_transactions_id  IN ( 
SELECT postilion_office_transactions_id FROM [172.25.15.14].arbiter.dbo.dup_transfers_all WITH (nolock)
)


SELECT  *  INTO #temp_dup_dispute_log FROM   [172.25.15.14].ARBITER.dbo.dispute_log_in_dups_tab with (NOLOCK)

DECLARE  @current_postilion_office_transactions_id  bigint 
DECLARE  @current_dispute_log_id  bigint 

DECLARE office_tran_id_cursor CURSOR STATIC READ_ONLY LOCAL FORWARD_ONLY FOR  select  dispute_log_id, postilion_office_transactions_id FROM  #temp_dup_dispute_log  (NOLOCK) 
OPEN office_tran_id_cursor
FETCH NEXT FROM  office_tran_id_cursor  INTO @current_dispute_log_id,@current_postilion_office_transactions_id

WHILE (@@FETCH_STATUS = 0 ) BEGIN
       update  tbl_dispute_log set  postilion_office_transactions_id = @current_postilion_office_transactions_id+6000000000 where  dispute_log_id = @current_dispute_log_id AND postilion_office_transactions_id = @current_postilion_office_transactions_id
FETCH NEXT FROM  office_tran_id_cursor  INTO @current_dispute_log_id, @current_postilion_office_transactions_id
END
CLOSE office_tran_id_cursor
DEALLOCATE office_tran_id_cursor

l