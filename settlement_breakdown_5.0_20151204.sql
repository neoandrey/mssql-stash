USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[psp_settlement_summary_breakdown]    Script Date: 12/04/2015 17:59:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE             PROCEDURE [dbo].[psp_settlement_summary_breakdown](
	@start_date DATETIME=NULL,
        @end_date DATETIME=NULL,
        @report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
    @rpt_tran_id1 INT = NULL
)
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,REPLACE(CONVERT(VARCHAR(MAX), DATEADD(D,-1,GETDATE()),111),'/',''))
SET @to_date = ISNULL(@end_date,REPLACE(CONVERT(VARCHAR(MAX), GETDATE(),111),'/',''))

DECLARE @first_post_tran_id BIGINT
DECLARE @last_post_tran_id BIGINT
DECLARE @first_post_tran_cust_id BIGINT
DECLARE @last_post_tran_cust_id BIGINT


IF( DATEDIFF(D,@from_date, @to_date)=0) BEGIN
    
INSERT 
           INTO settlement_summary_session
SELECT TOP 1  (cast (J.business_date as varchar(40)))
       FROM   dbo.sstl_journal_all AS J (NOLOCK) 
	   JOIN  post_tran_leg_internal PT(NOLOCK)
	   ON 
	j.post_tran_id = PT.post_tran_id
        where  
		(J.business_date >= @from_date AND J.business_date <= (@to_date))
		  AND
		PT.rsp_code_rsp in ('00','11','09')
              AND  PT.tran_postilion_originated = 0
     
              AND (
			     PT.settle_amount_impact<> 0 and PT.message_type   in ('0200','0220')
                 or  ((PT.message_type = '0420' and PT.tran_reversed <> 2 ) and ( (PT.settle_amount_impact<> 0 )
				   or (PT.settle_amount_rsp<> 0   and PT.message_type = '0420' and PT.tran_reversed <> 2 and PT.tran_type = 40 and (LEFT(PT.Terminal_id,1) in ('0','1')))))
              or (PT.settle_amount_rsp<> 0 and PT.message_type   in ('0200','0220') and PT.tran_type = 40 and (LEFT(PT.Terminal_id,1) in ('0','1')))
            
			   )

   
        OPTION ( MAXDOP 16)  
	SET @to_date = REPLACE(CONVERT(VARCHAR(MAX), DATEADD(D,1,@to_date),111),'/','')
	SELECT @first_post_tran_id = MIN(post_tran_id ) FROM sstl_journal_all(NOLOCK) where business_date =@from_date
	SELECT @last_post_tran_id =  max(post_tran_id ) FROM sstl_journal_all(NOLOCK) where business_date =@to_date
	SELECT @first_post_tran_cust_id= MIN(post_tran_cust_id) FROM sstl_journal_all (NOLOCK) where business_date =@from_date
	SELECT @last_post_tran_cust_id=  max(post_tran_cust_id) FROM sstl_journal_all (NOLOCK) where business_date =@to_date
END
ELSE BEGIN
SELECT @first_post_tran_id = MIN(post_tran_id ) FROM sstl_journal_all(NOLOCK) where business_date =@from_date
SELECT @last_post_tran_id =  max(post_tran_id ) FROM sstl_journal_all(NOLOCK) where business_date <@to_date
SELECT @first_post_tran_cust_id= MIN(post_tran_cust_id) FROM sstl_journal_all (NOLOCK) where business_date =@from_date
SELECT @last_post_tran_cust_id=  max(post_tran_cust_id) FROM sstl_journal_all (NOLOCK) where business_date <@to_date

INSERT  INTO settlement_summary_session
SELECT TOP 1  (cast (J.business_date as varchar(40)))
       FROM   dbo.sstl_journal_all AS J (NOLOCK) 
	   JOIN post_tran_leg_internal PT(NOLOCK)
	   ON 
	j.post_tran_id = PT.post_tran_id
        where  
		(J.post_tran_id >= @first_post_tran_id AND J.post_tran_id <= (@last_post_tran_id))
		  AND
		PT.rsp_code_rsp in ('00','11','09')
              AND  PT.tran_postilion_originated = 0
     
              AND (
			     PT.settle_amount_impact<> 0 and PT.message_type   in ('0200','0220')
                 or  ((PT.message_type = '0420' and PT.tran_reversed <> 2 ) and ( (PT.settle_amount_impact<> 0 )
				   or (PT.settle_amount_rsp<> 0   and PT.message_type = '0420' and PT.tran_reversed <> 2 and PT.tran_type = 40 and (LEFT(PT.Terminal_id,1) in ('0','1')))))
              or (PT.settle_amount_rsp<> 0 and PT.message_type   in ('0200','0220') and PT.tran_type = 40 and (LEFT(PT.Terminal_id,1) in ('0','1')))
            
			   )

   
        OPTION ( MAXDOP 16)  
END
SELECT @from_date, @to_date
CREATE TABLE [dbo].[#post_tran_temp](
	[post_tran_id] [bigint] NOT NULL,
	[post_tran_cust_id] [bigint] NOT NULL,
	[settle_entity_id] BIGINT NULL,
	[batch_nr] [int] NULL,
	[prev_post_tran_id] [bigint] NULL,
	[next_post_tran_id] [bigint] NULL,
	[sink_node_name] varchar(500) NULL,
	[tran_postilion_originated] int NOT NULL,
	[tran_completed] int NOT NULL,
	[message_type] [char](4) NOT NULL,
	[tran_type] [char](2) NULL,
	[tran_nr] [bigint] NOT NULL,
	[system_trace_audit_nr] [char](6) NULL,
	[rsp_code_req] [char](2) NULL,
	[rsp_code_rsp] [char](2) NULL,
	[abort_rsp_code] [char](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[auth_type] [numeric](1, 0) NULL,
	[auth_reason] [numeric](1, 0) NULL,
	[retention_data] [varchar](999) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [char](4) NULL,
	[sponsor_bank] [char](8) NULL,
	[retrieval_reference_nr] [char](12) NULL,
	[datetime_tran_gmt] [datetime] NULL,
	[datetime_tran_local] [datetime] NOT NULL,
	[datetime_req] [datetime] NOT NULL,
	[datetime_rsp] [datetime] NULL,
	[realtime_business_date] [datetime] NOT NULL,
	[recon_business_date] [datetime] NOT NULL,
	[from_account_type] [char](2) NULL,
	[to_account_type] [char](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] MONEY NULL,
	[tran_amount_rsp] MONEY NULL,
	[settle_amount_impact] MONEY NULL,
	[tran_cash_req] MONEY NULL,
	[tran_cash_rsp] MONEY NULL,
	[tran_currency_code] VARCHAR(5)NULL,
	[tran_tran_fee_req] MONEY NULL,
	[tran_tran_fee_rsp] MONEY NULL,
	[tran_tran_fee_currency_code] VARCHAR(5)NULL,
	[tran_proc_fee_req] MONEY NULL,
	[tran_proc_fee_rsp] MONEY NULL,
	[tran_proc_fee_currency_code] VARCHAR(5)NULL,
	[settle_amount_req] MONEY NULL,
	[settle_amount_rsp] MONEY NULL,
	[settle_cash_req] MONEY NULL,
	[settle_cash_rsp] MONEY NULL,
	[settle_tran_fee_req] MONEY NULL,
	[settle_tran_fee_rsp] MONEY NULL,
	[settle_proc_fee_req] MONEY NULL,
	[settle_proc_fee_rsp] MONEY NULL,
	[settle_currency_code] VARCHAR(5)NULL,
	[pos_entry_mode] [char](3) NULL,
	[pos_condition_code] [char](2) NULL,
	[additional_rsp_data] [varchar](25) NULL,
	[tran_reversed] [char](1) NULL,
	[prev_tran_approved] int NULL,
	[issuer_network_id] [varchar](11) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[extended_tran_type] [char](4) NULL,
	[from_account_type_qualifier] [char](1) NULL,
	[to_account_type_qualifier] [char](1) NULL,
	[bank_details] [varchar](31) NULL,
	[payee] [char](25) NULL,
	[card_verification_result] [char](1) NULL,
	[online_system_id] [int] NULL,
	[participant_id] [int] NULL,
	[opp_participant_id] [int] NULL,
	[receiving_inst_id_code] [varchar](11) NULL,
	[routing_type] [int] NULL,
	[pt_pos_operating_environment] [char](1) NULL,
	[pt_pos_card_input_mode] [char](1) NULL,
	[pt_pos_cardholder_auth_method] [char](1) NULL,
	[pt_pos_pin_capture_ability] [char](1) NULL,
	[pt_pos_terminal_operator] [char](1) NULL,
	[source_node_key] [varchar](32) NULL,
	[proc_online_system_id] [int] NULL,
	[from_account_id_cs] [int] NULL,
	[to_account_id_cs] [int] NULL,
	[pos_geographic_data] [char](17) NULL,
	[apayer_account_id] [varchar](28) NULL,
	[mapped_terminal_id] [char](8) NULL,
	[mapped_extd_ca_term_id] [varchar](28) NULL,
	[mapped_extd_ca_id_code] [varchar](28) NULL,
	[network_program_id_actual] [varchar](8) NULL,
	[network_program_id_min] [varchar](8) NULL,
	[network_fee_actual] [numeric](18, 0) NULL,
	[network_fee_min] [numeric](18, 0) NULL,
	[network_fee_max] [numeric](18, 0) NULL,
	[credit_debit_conversion] [tinyint] NULL,
	[payer_account_id] [varchar](30) NULL
) 

SET ANSI_PADDING OFF


ALTER TABLE [dbo].[#post_tran_temp] ADD  DEFAULT ((0)) FOR [next_post_tran_id]


ALTER TABLE [dbo].[#post_tran_temp] ADD  DEFAULT ((0)) FOR [tran_reversed]


CREATE clustered INDEX ix_post_tran_temp_1 ON  [#post_tran_temp] (
	post_tran_id
)
CREATE INDEX ix_post_tran_temp_2 ON  [#post_tran_temp] (
	post_tran_cust_id
)  INCLUDE(post_tran_id,recon_business_date,datetime_req, datetime_tran_local)
CREATE INDEX ix_post_tran_temp_3 ON  [#post_tran_temp] (
	datetime_req
)  INCLUDE(post_tran_id,recon_business_date,post_tran_cust_id, datetime_tran_local)

CREATE INDEX ix_post_tran_temp_4 ON  [#post_tran_temp] (
	recon_business_date
)  INCLUDE(post_tran_id,datetime_req,post_tran_cust_id, datetime_tran_local)

CREATE INDEX ix_post_tran_temp_5 ON  [#post_tran_temp] (
sink_node_name
)
CREATE INDEX ix_post_tran_temp_6 ON  [#post_tran_temp] (
acquiring_inst_id_code
)
CREATE INDEX ix_post_tran_temp_7 ON  [#post_tran_temp] (
[retention_data]
)
CREATE INDEX ix_post_tran_temp_8 ON  [#post_tran_temp] (
payee
)
CREATE INDEX ix_post_tran_cust_9 ON [#post_tran_temp] (
extended_tran_type
) 

CREATE TABLE [dbo].[#post_tran_cust_temp](
	[post_tran_cust_id] [bigint] NOT NULL,
	[source_node_name] varchar(500) NOT NULL,
	[draft_capture] BIGINT NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [char](4) NULL,
	[service_restriction_code] [char](3) NULL,
	[terminal_id] varchar(10) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [char](15) NULL,
	[mapped_card_acceptor_id_code] [char](15) NULL,
	[merchant_type] [char](4) NULL,
	[card_acceptor_name_loc] [char](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [char](1) NULL,
	[check_data] [varchar](70) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [char](1) NULL,
	[pos_cardholder_auth_ability] [char](1) NULL,
	[pos_card_capture_ability] [char](1) NULL,
	[pos_operating_environment] [char](1) NULL,
	[pos_cardholder_present] [char](1) NULL,
	[pos_card_present] [char](1) NULL,
	[pos_card_data_input_mode] [char](1) NULL,
	[pos_cardholder_auth_method] [char](1) NULL,
	[pos_cardholder_auth_entity] [char](1) NULL,
	[pos_card_data_output_ability] [char](1) NULL,
	[pos_terminal_output_ability] [char](1) NULL,
	[pos_pin_capture_ability] [char](1) NULL,
	[pos_terminal_operator] [char](1) NULL,
	[pos_terminal_type] [char](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [char](18) NULL,
	[pan_reference] [char](42) NULL,
	[card_acceptor_id_code_cs] [int] NULL,
 CONSTRAINT [pk_post_tran_cust_temp] PRIMARY KEY CLUSTERED 
(
	[post_tran_cust_id] ASC
))
ALTER TABLE [dbo].[#post_tran_cust_temp] ADD  DEFAULT ((0)) FOR [draft_capture]
CREATE INDEX ix_post_tran_cust_1 ON [#post_tran_cust_temp] (
terminal_id
) 
CREATE INDEX ix_post_tran_cust_2 ON [#post_tran_cust_temp] (
totals_group
) 
CREATE INDEX ix_post_tran_cust_3 ON [#post_tran_cust_temp] (
card_acceptor_id_code
) 


CREATE INDEX ix_post_tran_cust_4 ON [#post_tran_cust_temp] (
source_node_name
) 

CREATE INDEX ix_post_tran_cust_5 ON [#post_tran_cust_temp] (
pan
) 

CREATE INDEX ix_post_tran_cust_6 ON [#post_tran_cust_temp] (
merchant_type
) 


          
IF(@@ERROR <>0)
RETURN

INSERT INTO  [#post_tran_temp](
       [post_tran_id]
      ,[post_tran_cust_id]
      ,[settle_entity_id]
      ,[batch_nr]
      ,[prev_post_tran_id_fast]
  
      ,[sink_node_name]
      ,[tran_postilion_originated]
      
      ,[message_type]
      ,[tran_type]
      ,[tran_nr]
      ,[system_trace_audit_nr]
      ,[rsp_code_req]
      ,[rsp_code_rsp]
      ,[abort_rsp_code]
      ,[auth_id_rsp]
      ,[auth_type]
      ,[retention_data]
      ,[acquiring_inst_id_code]
      ,[message_reason_code]
      ,[sponsor_bank]
      ,[retrieval_reference_nr]
      ,[datetime_tran_gmt]
      ,[datetime_tran_local]
      ,[datetime_req]
      ,[datetime_rsp]
      ,[realtime_business_date]
      ,[recon_business_date]
      ,[from_account_type]
      ,[to_account_type]
      ,[from_account_id]
      ,[to_account_id]
      ,[tran_amount_req]
      ,[tran_amount_rsp]
      ,[settle_amount_impact]
      ,[tran_cash_req]
      ,[tran_cash_rsp]
      ,[tran_currency_code]
      ,[tran_tran_fee_req]
      ,[tran_tran_fee_rsp]
      ,[tran_tran_fee_currency_code]
      ,[tran_proc_fee_req]
      ,[tran_proc_fee_rsp]
      ,[tran_proc_fee_currency_code]
      ,[settle_amount_req]
      ,[settle_amount_rsp]
      ,[settle_cash_req]
      ,[settle_cash_rsp]
      ,[settle_tran_fee_req]
      ,[settle_tran_fee_rsp]
      ,[settle_proc_fee_req]
      ,[settle_proc_fee_rsp]
      ,[settle_currency_code]
      ,[pos_entry_mode]
      ,[pos_condition_code]
      ,[additional_rsp_data]
      ,[tran_reversed]
      ,[prev_tran_approved]
      ,[issuer_network_id]
      ,[acquirer_network_id]
      ,[extended_tran_type]
      ,[from_account_type_qualifier]
      ,[to_account_type_qualifier]
      ,[bank_details]
      ,[payee]
      ,[card_verification_result]
      ,[online_system_id]
      ,[participant_id]
      ,[opp_participant_id]
      ,[receiving_inst_id_code]
      ,[routing_type]
      ,[source_node_key]
      ,[proc_online_system_id]
      ,[pos_geographic_data]
      ,[mapped_terminal_id]
      ,[mapped_extd_ca_term_id]
      ,[mapped_extd_ca_id_code]
      ,[network_program_id_actual]
      ,[network_program_id_min]
      ,[network_fee_actual]
      ,[network_fee_min]
      ,[network_fee_max]
      ,[credit_debit_conversion]
      ,[payer_account_id])
SELECT   [post_tran_id]
      ,[post_tran_cust_id]
      ,[settle_entity_id]
      ,[batch_nr]
      ,[prev_post_tran_id_fast]
  
      ,[sink_node_name]
      ,[tran_postilion_originated]
      
      ,[message_type]
      ,[tran_type]
      ,[tran_nr]
      ,[system_trace_audit_nr]
      ,[rsp_code_req]
      ,[rsp_code_rsp]
      ,[abort_rsp_code]
      ,[auth_id_rsp]
      ,[auth_type]
      ,[retention_data]
      ,[acquiring_inst_id_code]
      ,[message_reason_code]
      ,[sponsor_bank]
      ,[retrieval_reference_nr]
      ,[datetime_tran_gmt]
      ,[datetime_tran_local]
      ,[datetime_req]
      ,[datetime_rsp]
      ,[realtime_business_date]
      ,[recon_business_date]
      ,[from_account_type]
      ,[to_account_type]
      ,[from_account_id]
      ,[to_account_id]
      ,[tran_amount_req]
      ,[tran_amount_rsp]
      ,[settle_amount_impact]
      ,[tran_cash_req]
      ,[tran_cash_rsp]
      ,[tran_currency_code]
      ,[tran_tran_fee_req]
      ,[tran_tran_fee_rsp]
      ,[tran_tran_fee_currency_code]
      ,[tran_proc_fee_req]
      ,[tran_proc_fee_rsp]
      ,[tran_proc_fee_currency_code]
      ,[settle_amount_req]
      ,[settle_amount_rsp]
      ,[settle_cash_req]
      ,[settle_cash_rsp]
      ,[settle_tran_fee_req]
      ,[settle_tran_fee_rsp]
      ,[settle_proc_fee_req]
      ,[settle_proc_fee_rsp]
      ,[settle_currency_code]
      ,[pos_entry_mode]
      ,[pos_condition_code]
      ,[additional_rsp_data]
      ,[tran_reversed]
      ,[prev_tran_approved]
      ,[issuer_network_id]
      ,[acquirer_network_id]
      ,[extended_tran_type]
      ,[from_account_type_qualifier]
      ,[to_account_type_qualifier]
      ,[bank_details]
      ,[payee]
      ,[card_verification_result]
      ,[online_system_id]
      ,[participant_id]
      ,[opp_participant_id]
      ,[receiving_inst_id_code]
      ,[routing_type]
      ,[source_node_key]
      ,[proc_online_system_id]
      ,[pos_geographic_data]
      ,[mapped_terminal_id]
      ,[mapped_extd_ca_term_id]
      ,[mapped_extd_ca_id_code]
      ,[network_program_id_actual]
      ,[network_program_id_min]
      ,[network_fee_actual]
      ,[network_fee_min]
      ,[network_fee_max]
      ,[credit_debit_conversion]
      ,[payer_account_id]
  FROM [postilion_office].[dbo].[post_tran_leg_internal] (NOLOCK)
WHERE 
post_tran_id >=@first_post_tran_id AND post_tran_cust_id<=@last_post_tran_id
AND
post_tran_cust_id>=@first_post_tran_cust_id  AND post_tran_cust_id<=@last_post_tran_cust_id
    
OPTION (MAXDOP 16)


INSERT INTO [#post_tran_cust_temp](
[post_tran_cust_id]
      ,[source_node_name]
      ,[draft_capture]
      ,[pan]
      ,[card_seq_nr]
      ,[expiry_date]
      ,[service_restriction_code]
      ,[terminal_id]
      ,[terminal_owner]
      ,[card_acceptor_id_code]
      ,[mapped_card_acceptor_id_code]
      ,[merchant_type]
      ,[card_acceptor_name_loc]
      ,[address_verification_data]
      ,[address_verification_result]
      ,[check_data]
      ,[totals_group]
      ,[card_product]
      ,[pos_card_data_input_ability]
      ,[pos_cardholder_auth_ability]
      ,[pos_card_capture_ability]
      ,[pos_operating_environment]
      ,[pos_cardholder_present]
      ,[pos_card_present]
      ,[pos_card_data_input_mode]
      ,[pos_cardholder_auth_method]
      ,[pos_cardholder_auth_entity]
      ,[pos_card_data_output_ability]
      ,[pos_terminal_output_ability]
      ,[pos_pin_capture_ability]
      ,[pos_terminal_operator]
      ,[pos_terminal_type]
      ,[pan_search]
      ,[pan_encrypted]
      ,[pan_reference]
      ,[card_acceptor_id_code_cs]

)

SELECT [post_tran_cust_id]
      ,[source_node_name]
      ,[draft_capture]
      ,[pan]
      ,[card_seq_nr]
      ,[expiry_date]
      ,[service_restriction_code]
      ,[terminal_id]
      ,[terminal_owner]
      ,[card_acceptor_id_code]
      ,[mapped_card_acceptor_id_code]
      ,[merchant_type]
      ,[card_acceptor_name_loc]
      ,[address_verification_data]
      ,[address_verification_result]
      ,[check_data]
      ,[totals_group]
      ,[card_product]
      ,[pos_card_data_input_ability]
      ,[pos_cardholder_auth_ability]
      ,[pos_card_capture_ability]
      ,[pos_operating_environment]
      ,[pos_cardholder_present]
      ,[pos_card_present]
      ,[pos_card_data_input_mode]
      ,[pos_cardholder_auth_method]
      ,[pos_cardholder_auth_entity]
      ,[pos_card_data_output_ability]
      ,[pos_terminal_output_ability]
      ,[pos_pin_capture_ability]
      ,[pos_terminal_operator]
      ,[pos_terminal_type]
      ,[pan_search]
      ,[pan_encrypted]
      ,[pan_reference]
      ,[card_acceptor_id_code_cs]
  FROM [postilion_office].[dbo].[post_tran_leg_internal] (NOLOCK)
  WHERE post_tran_cust_id IN (SELECT post_tran_cust_id FROM [#post_tran_temp])
OPTION (MAXDOP 16)
        
	

EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 
EXEC psp_get_rpt_post_tran_cust_id_NIBSS @from_date,@to_date,@rpt_tran_id1 OUTPUT 

	
CREATE TABLE #report_result
	(
		bank_code				VARCHAR (32),
		trxn_category				VARCHAR (64),  
		Debit_Account_type		        VARCHAR (100), 
		Credit_Account_type 		        VARCHAR (100),
		trxn_amount				money, 
		trxn_fee 				money, 
                trxn_date                               Datetime,
                currency                                VARCHAR (50),
                late_reversal                           CHAR    (1),
                Card_Type                               VARCHAR (25),
                Terminal_type                           VARCHAR (25),
                source_node_name                        VARCHAR (100),
                Unique_key                              VARCHAR (200),
                Acquirer                                VARCHAR (50),
                Issuer                                  VARCHAR (50)
							         )

INSERT INTO  #report_result

SELECT		         
	bank_code = CASE 
	
/*WHEN                     (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                          AND dbo.fn_rpt_CardGroup(ptc.pan) = '6'
                          AND PT.acquiring_inst_id_code = '627480'
                          and dbo.fn_rpt_terminal_type(ptc.terminal_id) <>'3' 
                           THEN 'UBA'
                           
WHEN                      (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                          AND dbo.fn_rpt_CardGroup(ptc.pan) = '6'
                          AND (PT.acquiring_inst_id_code <> '627480' or 
                          (PT.acquiring_inst_id_code = '627480'
                          and dbo.fn_rpt_terminal_type(ptc.terminal_id) ='3')
                          ) 
                           THEN 'GTB'*/
                           
 /* WHEN                     (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                           OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                           and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 1)
                          AND dbo.fn_rpt_CardGroup(ptc.pan) = '6'
                          AND PT.acquiring_inst_id_code = '627480' 
                           THEN 'UBA' */
                           
 /*WHEN                      (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                           OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                           and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 1)
                          AND dbo.fn_rpt_CardGroup(ptc.pan) = '6'
                          --AND PT.acquiring_inst_id_code <> '627480' 
                           THEN 'GTB'*/


WHEN PTT.Retention_data = '1046' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'UBN'
WHEN PTT.Retention_data ='9130' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ABS'
WHEN PTT.Retention_data ='9044' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ABP'
WHEN PTT.Retention_data ='9023'  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'CITI'
WHEN PTT.Retention_data ='9050' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'EBN'
WHEN PTT.Retention_data ='9214' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FCMB'
WHEN PTT.Retention_data ='9070' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FBP'
WHEN PTT.Retention_data ='9011' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FBN'
WHEN PTT.Retention_data ='9058'  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'GTB'
WHEN PTT.Retention_data ='9082' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'KSB'
WHEN PTT.Retention_data ='9076' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SKYE'
WHEN PTT.Retention_data ='9084' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ENT'
WHEN PTT.Retention_data ='9039' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'IBTC'
WHEN PTT.Retention_data ='9068' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SCB'
WHEN PTT.Retention_data ='9232' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SBP'
WHEN PTT.Retention_data ='9032'  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBN'
WHEN PTT.Retention_data ='9033'  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBA'
WHEN PTT.Retention_data ='9215'  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBP'
WHEN PTT.Retention_data ='9035' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'WEMA'
WHEN PTT.Retention_data ='9057' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ZIB'
WHEN PTT.Retention_data ='9301' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'JBP'
			
			
			WHEN PTT.Retention_data = '1131' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'WEMA'
                         WHEN PTT.Retention_data in ('1061','1006') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'

                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'GTB'
                         WHEN PTT.Retention_data = '1708' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'FBN'
                         WHEN PTT.Retention_data in ('1027','1045','1081','1015') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'SKYE'
                         WHEN PTT.Retention_data = '1037' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'IBTC'
                         WHEN PTT.Retention_data = '1034' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'EBN'
                         -- WHEN PTT.Retention_data = '1006' and 
                         --(DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                         -- OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                         -- OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'DBL'
                         WHEN (DebitAccNr.acc_nr LIKE 'UBA%' OR CreditAccNr.acc_nr LIKE 'UBA%') THEN 'UBA'
			 WHEN (DebitAccNr.acc_nr LIKE 'FBN%' OR CreditAccNr.acc_nr LIKE 'FBN%') THEN 'FBN'
                         WHEN (DebitAccNr.acc_nr LIKE 'ZIB%' OR CreditAccNr.acc_nr LIKE 'ZIB%') THEN 'ZIB' 
                         WHEN (DebitAccNr.acc_nr LIKE 'SPR%' OR CreditAccNr.acc_nr LIKE 'SPR%') THEN 'ENT'
                         WHEN (DebitAccNr.acc_nr LIKE 'GTB%' OR CreditAccNr.acc_nr LIKE 'GTB%') THEN 'GTB'
                         WHEN (DebitAccNr.acc_nr LIKE 'PRU%' OR CreditAccNr.acc_nr LIKE 'PRU%') THEN 'SKYE'
                         WHEN (DebitAccNr.acc_nr LIKE 'OBI%' OR CreditAccNr.acc_nr LIKE 'OBI%') THEN 'EBN'
                         WHEN (DebitAccNr.acc_nr LIKE 'WEM%' OR CreditAccNr.acc_nr LIKE 'WEM%') THEN 'WEMA'
                         WHEN (DebitAccNr.acc_nr LIKE 'AFR%' OR CreditAccNr.acc_nr LIKE 'AFR%') THEN 'MSB'
                         WHEN (DebitAccNr.acc_nr LIKE 'IBTC%' OR CreditAccNr.acc_nr LIKE 'IBTC%') THEN 'IBTC'
                         WHEN (DebitAccNr.acc_nr LIKE 'PLAT%' OR CreditAccNr.acc_nr LIKE 'PLAT%') THEN 'KSB'
                         WHEN (DebitAccNr.acc_nr LIKE 'UBP%' OR CreditAccNr.acc_nr LIKE 'UBP%') THEN 'UBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'DBL%' OR CreditAccNr.acc_nr LIKE 'DBL%') THEN 'DBL'

                         WHEN (DebitAccNr.acc_nr LIKE 'FCMB%' OR CreditAccNr.acc_nr LIKE 'FCMB%') THEN 'FCMB'
                         WHEN (DebitAccNr.acc_nr LIKE 'IBP%' OR CreditAccNr.acc_nr LIKE 'IBP%') THEN 'ABP'
                         WHEN (DebitAccNr.acc_nr LIKE 'UBN%' OR CreditAccNr.acc_nr LIKE 'UBN%') THEN 'UBN'
                         WHEN (DebitAccNr.acc_nr LIKE 'ETB%' OR CreditAccNr.acc_nr LIKE 'ETB%') THEN 'ETB'
                         WHEN (DebitAccNr.acc_nr LIKE 'FBP%' OR CreditAccNr.acc_nr LIKE 'FBP%') THEN 'FBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'SBP%' OR CreditAccNr.acc_nr LIKE 'SBP%') THEN 'SBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'ABP%' OR CreditAccNr.acc_nr LIKE 'ABP%') THEN 'ABP'
                         WHEN (DebitAccNr.acc_nr LIKE 'EBN%' OR CreditAccNr.acc_nr LIKE 'EBN%') THEN 'EBN'

                         WHEN (DebitAccNr.acc_nr LIKE 'CITI%' OR CreditAccNr.acc_nr LIKE 'CITI%') THEN 'CITI'
                         WHEN (DebitAccNr.acc_nr LIKE 'FIN%' OR CreditAccNr.acc_nr LIKE 'FIN%') THEN 'FCMB'
                         WHEN (DebitAccNr.acc_nr LIKE 'ASO%' OR CreditAccNr.acc_nr LIKE 'ASO%') THEN 'ASO'
                         WHEN (DebitAccNr.acc_nr LIKE 'OLI%' OR CreditAccNr.acc_nr LIKE 'OLI%') THEN 'OLI'
                         WHEN (DebitAccNr.acc_nr LIKE 'HSL%' OR CreditAccNr.acc_nr LIKE 'HSL%') THEN 'HSL'
                         WHEN (DebitAccNr.acc_nr LIKE 'ABS%' OR CreditAccNr.acc_nr LIKE 'ABS%') THEN 'ABS'
                         WHEN (DebitAccNr.acc_nr LIKE 'PAY%' OR CreditAccNr.acc_nr LIKE 'PAY%') THEN 'PAY'
                         WHEN (DebitAccNr.acc_nr LIKE 'SAT%' OR CreditAccNr.acc_nr LIKE 'SAT%') THEN 'SAT'
                         WHEN (DebitAccNr.acc_nr LIKE '3LCM%' OR CreditAccNr.acc_nr LIKE '3LCM%') THEN '3LCM'
                         WHEN (DebitAccNr.acc_nr LIKE 'SCB%' OR CreditAccNr.acc_nr LIKE 'SCB%') THEN 'SCB'
                         WHEN (DebitAccNr.acc_nr LIKE 'JBP%' OR CreditAccNr.acc_nr LIKE 'JBP%') THEN 'JBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'RSL%' OR CreditAccNr.acc_nr LIKE 'RSL%') THEN 'RSL'
                         WHEN (DebitAccNr.acc_nr LIKE 'PSH%' OR CreditAccNr.acc_nr LIKE 'PSH%') THEN 'PSH'
                         WHEN (DebitAccNr.acc_nr LIKE 'INF%' OR CreditAccNr.acc_nr LIKE 'INF%') THEN 'INF'
                         WHEN (DebitAccNr.acc_nr LIKE 'UML%' OR CreditAccNr.acc_nr LIKE 'UML%') THEN 'UML'

                         WHEN (DebitAccNr.acc_nr LIKE 'ACCI%' OR CreditAccNr.acc_nr LIKE 'ACCI%') THEN 'ACCI'
                         WHEN (DebitAccNr.acc_nr LIKE 'EKON%' OR CreditAccNr.acc_nr LIKE 'EKON%') THEN 'EKON'
                         WHEN (DebitAccNr.acc_nr LIKE 'ATMC%' OR CreditAccNr.acc_nr LIKE 'ATMC%') THEN 'ATMC'
                         WHEN (DebitAccNr.acc_nr LIKE 'HBC%' OR CreditAccNr.acc_nr LIKE 'HBC%') THEN 'HBC'
			 WHEN (DebitAccNr.acc_nr LIKE 'UNI%' OR CreditAccNr.acc_nr LIKE 'UNI%') THEN 'UNI'
                         WHEN (DebitAccNr.acc_nr LIKE 'UNC%' OR CreditAccNr.acc_nr LIKE 'UNC%') THEN 'UNC'
                         WHEN (DebitAccNr.acc_nr LIKE 'NCS%' OR CreditAccNr.acc_nr LIKE 'NCS%') THEN 'NCS' 
			 WHEN (DebitAccNr.acc_nr LIKE 'HAG%' OR CreditAccNr.acc_nr LIKE 'HAG%') THEN 'HAG'
			 WHEN (DebitAccNr.acc_nr LIKE 'EXP%' OR CreditAccNr.acc_nr LIKE 'EXP%') THEN 'DBL'
			 WHEN (DebitAccNr.acc_nr LIKE 'FGMB%' OR CreditAccNr.acc_nr LIKE 'FGMB%') THEN 'FGMB'
                         WHEN (DebitAccNr.acc_nr LIKE 'CEL%' OR CreditAccNr.acc_nr LIKE 'CEL%') THEN 'CEL'
			 WHEN (DebitAccNr.acc_nr LIKE 'RDY%' OR CreditAccNr.acc_nr LIKE 'RDY%') THEN 'RDY'
			 WHEN (DebitAccNr.acc_nr LIKE 'AMJ%' OR CreditAccNr.acc_nr LIKE 'AMJ%') THEN 'AMJU'
			 WHEN (DebitAccNr.acc_nr LIKE 'CAP%' OR CreditAccNr.acc_nr LIKE 'CAP%') THEN 'O3CAP'
			 WHEN (DebitAccNr.acc_nr LIKE 'VER%' OR CreditAccNr.acc_nr LIKE 'VER%') THEN 'VER_GLOBAL'

			 WHEN (DebitAccNr.acc_nr LIKE 'SMF%' OR CreditAccNr.acc_nr LIKE 'SMF%') THEN 'SMFB'
			 WHEN (DebitAccNr.acc_nr LIKE 'SLT%' OR CreditAccNr.acc_nr LIKE 'SLT%') THEN 'SLTD'
			 WHEN (DebitAccNr.acc_nr LIKE 'JES%' OR CreditAccNr.acc_nr LIKE 'JES%') THEN 'JES'
                         WHEN (DebitAccNr.acc_nr LIKE 'MOU%' OR CreditAccNr.acc_nr LIKE 'MOU%') THEN 'MOUA'
                         WHEN (DebitAccNr.acc_nr LIKE 'MUT%' OR CreditAccNr.acc_nr LIKE 'MUT%') THEN 'MUT'
                         WHEN (DebitAccNr.acc_nr LIKE 'LAV%' OR CreditAccNr.acc_nr LIKE 'LAV%') THEN 'LAV'
                         WHEN (DebitAccNr.acc_nr LIKE 'JUB%' OR CreditAccNr.acc_nr LIKE 'JUB%') THEN 'JUB'
						 WHEN (DebitAccNr.acc_nr LIKE 'WET%' OR CreditAccNr.acc_nr LIKE 'WET%') THEN 'WET'
                         WHEN (DebitAccNr.acc_nr LIKE 'AGH%' OR CreditAccNr.acc_nr LIKE 'AGH%') THEN 'AGH'
                         WHEN (DebitAccNr.acc_nr LIKE 'TRU%' OR CreditAccNr.acc_nr LIKE 'TRU%') THEN 'TRU'
						 WHEN (DebitAccNr.acc_nr LIKE 'CON%' OR CreditAccNr.acc_nr LIKE 'CON%') THEN 'CON'
                         WHEN (DebitAccNr.acc_nr LIKE 'CRU%' OR CreditAccNr.acc_nr LIKE 'CRU%') THEN 'CRU'
                         WHEN (DebitAccNr.acc_nr LIKE 'POS_FOODCONCEPT%' OR CreditAccNr.acc_nr LIKE 'POS_FOODCONCEPT%') THEN 'SCB'
			 WHEN ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) THEN 'ISW'
			
			 ELSE 'UNK'	
		
END,
	trxn_category=CASE WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '1'
                           AND PTC.source_node_name = 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE INTERNATIONAL)'
                           
                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='50'  then 'MASTERCARD LOCAL PROCESSING BILLING(PAYMENTS)'

                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='00' and PTC.source_node_name = 'VTUsrc'  then 'MASTERCARD LOCAL PROCESSING BILLING(RECHARGE)'
                
                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='00' and PTC.source_node_name <> 'VTUsrc'  and PT.sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PTC.Terminal_id,1,1) in ('2','5','6')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(POS PURCHASE)'

                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='00' and PTC.source_node_name <> 'VTUsrc'  and PT.sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PTC.Terminal_id,1,1) in ('3')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(WEB PURCHASE)'

                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PT.sink_node_name = 'ESBCSOUTsnk'
                           THEN 'ATM WITHDRAWAL (CARDLESS)'


                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PTC.source_node_name <> 'SWTMEGAsrc'
                           AND PTC.source_node_name <> 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (REGULAR)'
                           
                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 

                           and (DebitAccNr.acc_nr LIKE '%V%BILLING%' OR CreditAccNr.acc_nr LIKE '%V%BILLING%')
                           AND PTC.source_node_name <> 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE BILLING)'

                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PTC.source_node_name = 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (SMARTPOINT)'
 
			   WHEN (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = '1' and 
                           (DebitAccNr.acc_nr like '%BILLPAYMENT MCARD%' or CreditAccNr.acc_nr like '%BILLPAYMENT MCARD%') ) then 'BILLPAYMENT MASTERCARD BILLING'

                          
			   WHEN (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = '1') then 'BILLPAYMENT'
			   
			
                           WHEN (PT.tran_type ='40'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' 

                           or SUBSTRING(PTC.Terminal_id,1,1)= '0' or SUBSTRING(PTC.Terminal_id,1,1)= '4')) THEN 'CARD HOLDER ACCOUNT TRANSFER'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '1'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                            and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                              or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(GENERAL MERCHANT)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '2'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(CHURCHES, FASTFOODS & NGOS)'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '3'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(CONCESSION)PURCHASE'

                           WHEN ( dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '4'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(TRAVEL AGENCIES)PURCHASE'
                           

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '5'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(HOTELS)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '6'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(WHOLESALE)PURCHASE'
                    
                            WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '14'
                            and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                            and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                            or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(WHOLESALE_ACQUIRER_BORNE)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '7'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(FUEL STATION)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '8'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(EASYFUEL)PURCHASE'

                           WHEN  (dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) ='1'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(GENERAL MERCHANT-VISA)PURCHASE'
                     
                           WHEN (dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) ='2'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(2% CATEGORY-VISA)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) ='3'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(3% CATEGORY-VISA)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '9'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '10'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N200)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '11'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N300)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '12'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N150)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '13'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(1.5% CAPPED AT N300)PURCHASE'
                       
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '15'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB COLLEGES ( 1.5% capped specially at 250)'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '16'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB (PROFESSIONAL SERVICES)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '17'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB (SECURITY BROKERS/DEALERS)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '18'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB (COMMUNICATION)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '19'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N400)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '20'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N250)PURCHASE'
                  
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '21'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N265)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '22'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N550)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '23'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'Verify card – Ecash load'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '24'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(1% CAPPED AT 1,000 CATEGORY)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '25'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(0.75% CAPPED AT 2,000 CATEGORY)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1)
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')THEN 'POS(GENERAL MERCHANT)PURCHASE' 

                             WHEN (dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1)
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')THEN 'POS PURCHASE WITH CASHBACK'

                           WHEN (dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2)
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'POS CASHWITHDRAWAL'

                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2 and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'


                           WHEN (pt.tran_type = '50' and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'
                           
                           WHEN (pt.tran_type = '50' and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'Fees collected for all PTSPs'


                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2 and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'



                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1)
                           and SUBSTRING(PTC.Terminal_id,1,1)= '3' THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '313' 
                                 and (DebitAccNr.acc_nr LIKE '%fee%' OR CreditAccNr.acc_nr LIKE '%fee%')
                                 and (PT.tran_type in ('50') or(dbo.fn_rpt_autopay_intra_sett (PT.tran_type,PTC.source_node_name) = 1))
                                 and not (DebitAccNr.acc_nr like '%PREPAIDLOAD%' or CreditAccNr.acc_nr like '%PREPAIDLOAD%')) THEN 'AUTOPAY TRANSFER FEES'
                          
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,

                                  PT.extended_tran_type ,PTC.source_node_name) = '313' 
                                 and (DebitAccNr.acc_nr NOT LIKE '%fee%' OR CreditAccNr.acc_nr NOT LIKE '%fee%')

                                 and PT.tran_type in ('50')
                                 and not (DebitAccNr.acc_nr like '%PREPAIDLOAD%' or CreditAccNr.acc_nr like '%PREPAIDLOAD%')) THEN 'AUTOPAY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '1' and PT.tran_type = '50') THEN 'ATM TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '2' and PT.tran_type = '50') THEN 'POS TRANSFERS'
                           
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '4' and PT.tran_type = '50') THEN 'MOBILE TRANSFERS'

                          WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '35' and PT.tran_type = '50') then 'REMITA TRANSFERS'

       
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '31' and PT.tran_type = '50') then 'OTHER TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,

                                  PT.extended_tran_type ,PTC.source_node_name) = '32' and PT.tran_type = '50') then 'RELATIONAL TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '33' and PT.tran_type = '50') then 'SEAMFIX TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '34' and PT.tran_type = '50') then 'VERVE INTL TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '36' and PT.tran_type = '50') then 'PREPAID CARD UNLOAD'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '37' and PT.tran_type = '50' ) then 'QUICKTELLER TRANSFERS(BANK BRANCH)'
 
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '38' and PT.tran_type = '50') then 'QUICKTELLER TRANSFERS(SVA)'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '39' and PT.tran_type = '50') then 'SOFTPAY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '310' and PT.tran_type = '50') then 'OANDO S&T TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '311' and PT.tran_type = '50') then 'UPPERLINK TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '312'  and PT.tran_type = '50') then 'QUICKTELLER WEB TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '314'  and PT.tran_type = '50') then 'QUICKTELLER MOBILE TRANSFERS'
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '315' and PT.tran_type = '50') then 'WESTERN UNION MONEY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '316' and PT.tran_type = '50') then 'OTHER TRANSFERS(NON GENERIC PLATFORM)'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2)
                                 AND (DebitAccNr.acc_nr NOT LIKE '%AMOUNT%RECEIVABLE' AND CreditAccNr.acc_nr NOT LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2)
                                 AND (DebitAccNr.acc_nr  LIKE '%AMOUNT%RECEIVABLE' or CreditAccNr.acc_nr  LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE DUE ISW'--the unk% is excempted from the bank's net
                           
                                                      
                          WHEN (dbo.fn_rpt_isCardload (PTC.source_node_name ,PTC.pan, PT.tran_type)= '1') then 'PREPAID CARDLOAD'

                          when pt.tran_type = '21' then 'DEPOSIT'

                           /*WHEN (SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN  (SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN  (SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%ISO_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%ISO_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'*/
                           
                          ELSE 'UNK'		

END,
  Debit_account_type=CASE 
                      /*WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 1)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 1)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)' */
                      
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Debit_Nr)'
	                  WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%CO%ACQUIRER%FEE%RECEIVABLE') THEN 'CO-ACQUIRER FEE RECEIVABLE(Debit_Nr)'   
                          WHEN (DebitAccNr.acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%CARDHOLDER%ISSUER%FEE%RECEIVABLE%') THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%SCH%ISSUER%FEE%RECEIVABLE') THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '1')
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1')THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'


                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '2')
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '3') 

                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '4') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'
                           
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '5') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '6') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '7') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '8') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Debit_Nr)'
               
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '10') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '9'
                          AND NOT ((DebitAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')OR (DebitAccNr.acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE 'POS_FOODCONCEPT%')THEN 'FOODCONCEPT_TERMINAL_OWNER_FEE_RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ATMC%FEE%PAYABLE') THEN 'ATMC FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ATMC%FEE%RECEIVABLE') THEN 'ATMC FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%EASYFUEL_ACCOUNT') THEN 'EASYFUEL ACCOUNT(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%YPM%FEE%RECEIVABLE') THEN 'YPM FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') THEN 'FLEETTECH FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%LYSA%FEE%RECEIVABLE') THEN 'LYSA FEE RECEIVABLE(Debit_Nr)'

                         
                          WHEN (DebitAccNr.acc_nr LIKE '%SVA_FEE_RECEIVABLE') THEN 'SVA FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') THEN 'UDIRECT FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Debit_Nr)'
                            
                          WHEN (DebitAccNr.acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Debit_Nr)'  
			  WHEN (DebitAccNr.acc_nr LIKE '%SVA_SPONSOR_FEE_PAYABLE') THEN 'SVA SPONSOR FEE PAYABLE(Debit_Nr)'
			  WHEN (DebitAccNr.acc_nr LIKE '%SVA_SPONSOR_FEE_RECEIVABLE') THEN 'SVA SPONSOR FEE RECEIVABLE(Debit_Nr)'                      

                          ELSE 'UNK'			
END,
  Credit_account_type=CASE  
  
  
                     
                      /*WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                     and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 1)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 1)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)' */
                                           
                          WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Credit_Nr)'
	                  WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%CO%ACQUIRER%FEE%RECEIVABLE') THEN 'CO-ACQUIRER FEE RECEIVABLE(Credit_Nr)'   
                          WHEN (CreditAccNr.acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%CARDHOLDER%ISSUER%FEE%RECEIVABLE%') THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Credit_Nr)' 

                          WHEN (CreditAccNr.acc_nr LIKE '%SCH%ISSUER%FEE%RECEIVABLE') THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Credit_Nr)'
                           WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '1') 

                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'


                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '2') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '3') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'


                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '4') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'
                           
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '5') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '6') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '7') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '8') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '10') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '9'
                          AND NOT ((CreditAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE 'POS_FOODCONCEPT%')THEN 'FOODCONCEPT_TERMINAL_OWNER_FEE_RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ATMC%FEE%PAYABLE') THEN 'ATMC FEE PAYABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%ATMC%FEE%RECEIVABLE') THEN 'ATMC FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%EASYFUEL_ACCOUNT') THEN 'EASYFUEL ACCOUNT(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (CreditAccNr.acc_nr LIKE '%YPM%FEE%RECEIVABLE') THEN 'YPM FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (CreditAccNr.acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') THEN 'FLEETTECH FEE RECEIVABLE(Credit_Nr)' 

                          WHEN (CreditAccNr.acc_nr LIKE '%LYSA%FEE%RECEIVABLE') THEN 'LYSA FEE RECEIVABLE(Credit_Nr)'
                         
                          WHEN (CreditAccNr.acc_nr LIKE '%SVA_FEE_RECEIVABLE') THEN 'SVA FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') THEN 'UDIRECT FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Credit_Nr)'
                          
                          WHEN (CreditAccNr.acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Credit_Nr)' 
			  WHEN (CreditAccNr.acc_nr LIKE '%SVA_SPONSOR_FEE_RECEIVABLE') THEN 'SVA SPONSOR FEE RECEIVABLE(Credit_Nr)'
			  WHEN (CreditAccNr.acc_nr LIKE '%SVA_SPONSOR_FEE_PAYABLE') THEN 'SVA SPONSOR FEE PAYABLE(Credit_Nr)'

                          ELSE 'UNK'			
END,

        amt=SUM(ISNULL(J.amount,0)),
	fee=SUM(ISNULL(J.fee,0)),
	business_date=j.business_date,
        currency = CASE WHEN (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = '1' and 
                           (DebitAccNr.acc_nr like '%BILLPAYMENT MCARD%' or CreditAccNr.acc_nr like '%BILLPAYMENT MCARD%') ) THEN '840'
                        WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%') THEN '840'
          ELSE pt.settle_currency_code END,
        Late_Reversal_id = CASE
						WHEN ( dbo.fn_rpt_late_reversal(pt.post_tran_cust_id,pt.message_type,@rpt_tran_id1) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1)
                               and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') THEN 1
						ELSE 0
					        END,
        card_type =  dbo.fn_rpt_CardGroup(ptc.pan),
        terminal_type = dbo.fn_rpt_terminal_type(ptc.terminal_id),    
        source_node_name =   PTC.source_node_name,
        Unique_key = pt.retrieval_reference_nr+'_'+pt.system_trace_audit_nr+'_'+ptc.terminal_id+'_'+ cast((CONVERT(NUMERIC (15,2),isnull(pt.settle_amount_impact,0))) as VARCHAR(20))+'_'+pt.message_type,
        Acquirer = (case when (not ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) )) then ''
                      when ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) AND (acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code) then acc.bank_code --or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code1 or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code2 or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code3 or SUBSTRING(PTC.terminal_id,2,3) = acc.cbn_code4) THEN acc.bank_code
                      else PT.acquiring_inst_id_code END),
        Issuer = (case when (not ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) )) then ''
                      when ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) and (substring(ptc.totals_group,1,3) = acc.bank_code1) then acc.bank_code
                      else substring(ptc.totals_group,1,3) END)
                     

                        --currency = CASE WHEN (pt.settle_currency_code = '566') then 'Naira'
                        --WHEN (pt.settle_currency_code = '840') then 'US DOLLAR'
                        --ELSE  pt.settle_currency_code
                        --END

FROM  dbo.sstl_journal_all AS J (NOLOCK)
LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS DebitAccNr (NOLOCK)
ON (J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)
LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS CreditAccNr  (NOLOCK)
ON (J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id)
LEFT OUTER JOIN dbo.sstl_se_amount_w AS Amount  (NOLOCK)
ON (J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)
LEFT OUTER JOIN dbo.sstl_se_fee_w AS Fee (NOLOCK)
ON (J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id)
LEFT OUTER JOIN dbo.sstl_coa_w AS Coa  (NOLOCK)
ON (J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id)
RIGHT OUTER JOIN #post_tran_temp AS PT (NOLOCK)
ON (J.post_tran_id = PT.post_tran_id AND J.post_tran_cust_id = PT.post_tran_cust_id)
RIGHT OUTER JOIN #post_tran_cust_temp AS PTC (NOLOCK)
ON (J.post_tran_cust_id = PTC.post_tran_cust_id AND J.post_tran_cust_id = PTC.post_tran_cust_id)
left join #post_tran_temp ptt (nolock) 
on (pt.post_tran_cust_id = ptt.post_tran_cust_id and ptt.tran_postilion_originated = 1
    and pt.tran_nr = ptt.tran_nr)
LEFT OUTER JOIN aid_cbn_code acc ON
(acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code)

WHERE 

      PT.tran_postilion_originated = 0
     
      AND PT.rsp_code_rsp in ('00','11','09')
      
      AND (
          (PT.settle_amount_impact<> 0 and PT.message_type   in ('0200','0220'))

       or ((PT.settle_amount_impact<> 0 and PT.message_type = '0420' 

       and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) <> 1 and PT.tran_reversed <> 2)
       or (PT.settle_amount_impact<> 0 and PT.message_type = '0420' 
       and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 ))

       or (PT.settle_amount_rsp<> 0 and PT.message_type   in ('0200','0220') and PT.tran_type = 40 and (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0'))
       or (PT.message_type = '0420' and PT.tran_reversed <> 2 and PT.tran_type = 40 and (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')))
      
      AND (PT.recon_business_date >= @from_date AND PT.recon_business_date < (@to_date))

      AND not (merchant_type in ('4004','4722') and pt.tran_type = '00' and source_node_name not in ('VTUsrc','CCLOADsrc') and  abs(pt.settle_amount_impact/100)< 200
       and not (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%'))

      AND not (merchant_type in ('5371') and pt.tran_type = '00' and 

                (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) <> 2) 
               and not (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%'))
      AND PTC.post_tran_cust_id >= @rpt_tran_id
      AND PTC.totals_group not in ('CUPGroup','VISAGroup')
      AND
             ptc.source_node_name  NOT LIKE 'SB%'
             AND
             pt.sink_node_name  NOT LIKE 'SB%'

      and not(ptc.source_node_name  LIKE '%TPP%')
       and not(pt.sink_node_name  LIKE '%TPP%')
       and not (ptc.source_node_name  = 'MEGATPPsrc' and pt.tran_type = '00')
      --and source_node_name not in ('SWTWMASBsrc','SWTWEMSBsrc')
      and source_node_name NOT LIKE 'SWTMEGADSsrc'
      --and not (PT.tran_type in ('01','09') or (PT.tran_type = '00' and 
      --dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
      --and (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)in ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'
                                                                             -- ,'16','17','18','19','20','21','22','23') 
      --or dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)is null))
      --and(pt.datetime_req > '2015-08-05 09:20:00.000' and pt.datetime_req < '2015-08-05 10:40:00.000'))

GROUP BY 

 j.business_date,
 DebitAccNr.acc_nr,
 CreditAccNr.acc_nr,
 PT.tran_type,

 dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type),
 dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN),pt.acquiring_inst_id_code,

 ptc.totals_group, SUBSTRING(PTC.Terminal_id,1,1),
 dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan),
dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan),
dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name),
dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan),
dbo.fn_rpt_isCardload (PTC.source_node_name ,PTC.pan, PT.tran_type),
dbo.fn_rpt_CardType (PTC.pan ,PT.sink_node_name ,PT.tran_type,PTC.TERMINAL_ID),
dbo.fn_rpt_autopay_intra_sett (PT.tran_type,PTC.source_node_name),
PTT.Retention_data,
pt.settle_currency_code,
PTC.source_node_name,
PT.sink_node_name,
dbo.fn_rpt_late_reversal(pt.post_tran_cust_id,pt.message_type,@rpt_tran_id1),
dbo.fn_rpt_CardGroup(ptc.pan), dbo.fn_rpt_terminal_type(ptc.terminal_id),
pt.retrieval_reference_nr+'_'+pt.system_trace_audit_nr+'_'+ptc.terminal_id+'_'+ cast((CONVERT(NUMERIC (15,2),isnull(pt.settle_amount_impact,0))) as VARCHAR(20))+'_'+pt.message_type,
dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type),
(case when (not ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) )) then ''
                      when ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) AND (acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code) then acc.bank_code --or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code1 or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code2 or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code3 or SUBSTRING(PTC.terminal_id,2,3) = acc.cbn_code4) THEN acc.bank_code
                      else PT.acquiring_inst_id_code END),
(case when (not ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) )) then ''
                      when ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) and (substring(ptc.totals_group,1,3) = acc.bank_code1) then acc.bank_code1
                      else substring(ptc.totals_group,1,3) END),
acc.bank_code1, acc.bank_code, PT.acquiring_inst_id_code
OPTION(MAXDOP 16)

create table #temp_table
(unique_key varchar(200))

insert into #temp_table 
select unique_key from #report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')
OPTION(MAXDOP 16)

insert into settlement_summary_breakdown	
(bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_amount,trxn_fee,trxn_date, Currency,late_reversal,card_type,terminal_type, Acquirer, Issuer)	
	SELECT 
			bank_code,trxn_category,Debit_Account_type,Credit_Account_type,sum(trxn_amount),sum(trxn_fee),trxn_date, Currency,late_reversal,card_type,terminal_type, Acquirer, Issuer 
	FROM 
			#report_result 
where     not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') 
          and unique_key  IN (SELECT unique_key FROM #temp_table))
          

GROUP BY bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_date,Currency,late_reversal,card_type,terminal_type,Acquirer, Issuer
OPTION(MAXDOP 16)

END  


































































































































































































































































































