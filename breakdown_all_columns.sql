USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[psp_settlement_summary_breakdown_dry_run_20160430]    Script Date: 04/30/2016 21:42:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





      ALTER PROCEDURE  [dbo].[psp_settlement_summary_breakdown_dry_run_20160430](
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
    
---INSERT  INTO settlement_summary_session
SELECT TOP 1  (cast (J.business_date as varchar(40)))
       FROM   dbo.sstl_journal_all AS J (NOLOCK) 
	   JOIN post_tran PT(NOLOCK)
	   ON j.post_tran_id = PT.post_tran_id
	   JOIN post_tran_cust PTC(NOLOCK)
	   ON 
	j.post_tran_cust_id = PT.post_tran_cust_id
        where  
		(J.business_date >= @from_date AND J.business_date <= (@to_date))
		  AND
		PT.rsp_code_rsp in ('00','11','09')
              AND  PT.tran_postilion_originated = 0
     
              AND (
			     PT.settle_amount_impact<> 0 and PT.message_type   in ('0200','0220')
                 or  ((PT.message_type = '0420' and PT.tran_reversed <> 2 ) and ( (PT.settle_amount_impact<> 0 )
				   or (PT.settle_amount_rsp<> 0   and PT.message_type = '0420' and PT.tran_reversed <> 2 and PT.tran_type = 40 and (LEFT(PTC.Terminal_id,1) in ('0','1')))))
              or (PT.settle_amount_rsp<> 0 and PT.message_type   in ('0200','0220') and PT.tran_type = 40 and (LEFT(PTC.Terminal_id,1) in ('0','1')))
            
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

--  INTO settlement_summary_session

/**
SELECT TOP 1  (cast (J.business_date as varchar(40)))
       FROM   dbo.sstl_journal_all AS J (NOLOCK) 
	   JOIN post_tran PT(NOLOCK)
	   ON j.post_tran_id = PT.post_tran_id
	   JOIN post_tran_cust PTC(NOLOCK)
	   ON 
	j.post_tran_cust_id = PT.post_tran_cust_id
        where  
		(J.post_tran_id >= @first_post_tran_id) AND 
( J.post_tran_id <= (@last_post_tran_id))
		  AND
		PT.rsp_code_rsp in ('00','11','09')
              AND  PT.tran_postilion_originated = 0
     
              AND (
			     PT.settle_amount_impact<> 0 and PT.message_type   in ('0200','0220')
                 or  ((PT.message_type = '0420' and PT.tran_reversed <> 2 ) and ( (PT.settle_amount_impact<> 0 )
				   or (PT.settle_amount_rsp<> 0   and PT.message_type = '0420' and PT.tran_reversed <> 2 and PT.tran_type = 40 and (LEFT(PTC.Terminal_id,1) in ('0','1')))))
              or (PT.settle_amount_rsp<> 0 and PT.message_type   in ('0200','0220') and PT.tran_type = 40 and (LEFT(PTC.Terminal_id,1) in ('0','1')))
            
			   )

   
        OPTION (recompile )  
        */
END
/*

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
	[proc_online_system_id] [int] NULL
) 

SET ANSI_PADDING OFF


ALTER TABLE [dbo].[#post_tran_temp] ADD  DEFAULT ((0)) FOR [next_post_tran_id]


ALTER TABLE [dbo].[#post_tran_temp] ADD  DEFAULT ((0)) FOR [tran_reversed]



--CREATE NONCLUSTERED INDEX [ix_post_tran_temp_4]
--ON [dbo].[#post_tran_temp] ([tran_postilion_originated],[post_tran_id],[sink_node_name])
--INCLUDE ([post_tran_cust_id],[settle_entity_id],[batch_nr],[prev_post_tran_id],[next_post_tran_id],[tran_completed],[message_type],[tran_type],[tran_nr],
--[system_trace_audit_nr],[rsp_code_req],[rsp_code_rsp],[abort_rsp_code],[auth_id_rsp],[auth_type],[auth_reason],[retention_data],[acquiring_inst_id_code],
--[message_reason_code],[sponsor_bank],[retrieval_reference_nr],[datetime_tran_gmt],[datetime_tran_local],[datetime_req],[datetime_rsp],[realtime_business_date],
--[recon_business_date],[from_account_type],[to_account_type],[from_account_id],[to_account_id],[tran_amount_req],[tran_amount_rsp],[settle_amount_impact]
--,[tran_cash_req],[tran_cash_rsp],[tran_currency_code],[tran_tran_fee_req],[tran_tran_fee_rsp],[tran_tran_fee_currency_code],[tran_proc_fee_req],
--[tran_proc_fee_rsp],[tran_proc_fee_currency_code],[settle_amount_req],[settle_amount_rsp],[settle_cash_req],[settle_cash_rsp],[settle_tran_fee_req],
--[settle_tran_fee_rsp],[settle_proc_fee_req],[settle_proc_fee_rsp],[settle_currency_code],[pos_entry_mode],[pos_condition_code],[additional_rsp_data]
--,[tran_reversed],[prev_tran_approved],[issuer_network_id],[acquirer_network_id],[extended_tran_type],[from_account_type_qualifier],[to_account_type_qualifier],
--[bank_details],[payee],[card_verification_result],[online_system_id],[participant_id],[opp_participant_id],[receiving_inst_id_code],[routing_type],[pt_pos_operating_environment]
--,[pt_pos_card_input_mode],[pt_pos_cardholder_auth_method],[pt_pos_pin_capture_ability],[pt_pos_terminal_operator],[source_node_key],[proc_online_system_id])



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
 CONSTRAINT [pk2_post_tran_cust_temp] PRIMARY KEY CLUSTERED 
(
	[post_tran_cust_id] ASC
))
ALTER TABLE [dbo].[#post_tran_cust_temp] ADD  DEFAULT ((0)) FOR [draft_capture]
CREATE INDEX ind_post_tran_cust_1 ON [#post_tran_cust_temp] (
terminal_id
) 
CREATE INDEX ind_post_tran_cust_2 ON [#post_tran_cust_temp] (
totals_group
) 
CREATE INDEX ind_post_tran_cust_3 ON [#post_tran_cust_temp] (
card_acceptor_id_code
) 


CREATE INDEX ind_post_tran_cust_4 ON [#post_tran_cust_temp] (
source_node_name
) 

CREATE INDEX ind_post_tran_cust_5 ON [#post_tran_cust_temp] (
pan
) 

CREATE INDEX ind_post_tran_cust_6 ON [#post_tran_cust_temp] (
merchant_type
) 

CREATE INDEX ind_post_tran_cust_7 ON  [#post_tran_cust_temp] (
	post_tran_cust_id
)  INCLUDE(pan,terminal_id,totals_group,source_node_name,card_acceptor_id_code, merchant_type)


          
IF(@@ERROR <>0)
RETURN

INSERT INTO  [#post_tran_temp](
       [post_tran_id]
      ,[post_tran_cust_id]
      ,[settle_entity_id]
      ,[batch_nr]
      ,[prev_post_tran_id]
      ,[next_post_tran_id]
      ,[sink_node_name]
      ,[tran_postilion_originated]
      ,[tran_completed]
      ,[message_type]
      ,[tran_type]
      ,[tran_nr]
      ,[system_trace_audit_nr]
      ,[rsp_code_req]
      ,[rsp_code_rsp]
      ,[abort_rsp_code]
      ,[auth_id_rsp]
      ,[auth_type]
      ,[auth_reason]
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
      ,[pt_pos_operating_environment]
      ,[pt_pos_card_input_mode]
      ,[pt_pos_cardholder_auth_method]
      ,[pt_pos_pin_capture_ability]
      ,[pt_pos_terminal_operator]
      ,[source_node_key]
      ,[proc_online_system_id]
      
      )
SELECT [post_tran_id]
      ,[post_tran_cust_id]
      ,[settle_entity_id]
      ,[batch_nr]
      ,[prev_post_tran_id]
      ,[next_post_tran_id]
      ,[sink_node_name]
      ,[tran_postilion_originated]
      ,[tran_completed]
      ,[message_type]
      ,[tran_type]
      ,[tran_nr]
      ,[system_trace_audit_nr]
      ,[rsp_code_req]
      ,t.[rsp_code_rsp]
      ,[abort_rsp_code]
      ,[auth_id_rsp]
      ,[auth_type]
      ,[auth_reason]
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
      ,t.[recon_business_date]
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
      ,[pt_pos_operating_environment]
      ,[pt_pos_card_input_mode]
      ,[pt_pos_cardholder_auth_method]
      ,[pt_pos_pin_capture_ability]
      ,[pt_pos_terminal_operator]
      ,[source_node_key]
      ,[proc_online_system_id]
  FROM [postilion_office].[dbo].[post_tran] t (NOLOCK, index(ix_post_tran_2))
   JOIN
   (  
    select [Date]as recon_business_date  from  dbo.get_dates_in_range(@from_date,@to_date)
    
    ) r
    ON t.recon_business_date = r. recon_business_date
    JOIN
   (SELECT  part AS rsp_code_rsp FROM dbo.usf_split_string('00,11,09',',')) rs
   ON
   t.rsp_code_rsp = rs.rsp_code_rsp

WHERE 
         tran_postilion_originated = 0
    and
	  sink_node_name not like  'SB%'
			       and   master.dbo.fn_rpt_contains(sink_node_name, 'TPP') = 0
	   and 
	   sink_node_name <>'WUESBPBsnk'
	   
    
OPTION (RECOMPILE,MAXDOP 8)


CREATE  INDEX ind_post_tran_temp_1 ON  [#post_tran_temp] (
	post_tran_id,post_tran_cust_id
)   INCLUDE(retrieval_reference_nr, system_trace_audit_nr, sink_node_name,tran_type ,message_type,tran_reversed,acquiring_inst_id_code,retention_data,payee,recon_business_date,datetime_req, datetime_tran_local)

CREATE INDEX ind_post_tran_temp_4 ON  [#post_tran_temp] (
	datetime_req,recon_business_date
)  INCLUDE(post_tran_id,post_tran_cust_id, datetime_tran_local)

CREATE INDEX ind_post_tran_temp_5 ON  [#post_tran_temp] (
sink_node_name
)
CREATE INDEX ind_post_tran_temp_6 ON  [#post_tran_temp] (
acquiring_inst_id_code
)
CREATE INDEX ind_post_tran_temp_7 ON  [#post_tran_temp] (
[retention_data]
)
CREATE INDEX ind_post_tran_temp_8 ON  [#post_tran_temp] (
payee
)
CREATE INDEX ind_post_tran_9 ON [#post_tran_temp] (
extended_tran_type
) 

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
   

)

SELECT  [post_tran_cust_id]
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
  FROM [postilion_office].[dbo].[post_tran_cust] (NOLOCK)
  WHERE
  
   --post_tran_cust_id >=@first_post_tran_cust_id AND post_tran_cust_id <= @last_post_tran_cust_id
   
     post_tran_cust_id in
     
     (SELECT post_tran_cust_id from  [#post_tran_temp] (	nolock) )
     
       and source_node_name <> 'SWTMEGADSsrc'
       and card_acceptor_id_code <> 'IPG000000000001'
        AND
        LEFT( source_node_name,2 ) <> 'SB'
		and  
		 master.dbo.fn_rpt_contains(source_node_name, 'TPP') = 0
	

OPTION (RECOMPILE,MAXDOP 8)
        
*/

EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 
EXEC psp_get_rpt_post_tran_cust_id_NIBSS @from_date,@to_date,@rpt_tran_id1 OUTPUT 

	

--INSERT INTO settlement_summary_breakdown
--(bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_amount,trxn_fee,trxn_date, Currency,late_reversal,card_type,terminal_type)

CREATE TABLE #report_result
	(
		index_no bigint  IDENTITY(1,1),
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
                Unique_key                           VARCHAR(200),
                Acquirer                                VARCHAR (50),
                Issuer                                  VARCHAR (50)
							         )

									 				CREATE  NONCLUSTERED INDEX ind_report_result_6 ON #report_result (
	index_no
	
	)	
				CREATE  NONCLUSTERED INDEX ind_report_result_1 ON #report_result (
	Unique_key
	
	)				         
								         
	CREATE  NONCLUSTERED INDEX ind_report_result_5 ON #report_result (
	bank_code
	
	)						         
	CREATE  NONCLUSTERED INDEX ind_report_result_2 ON #report_result (
	source_node_name
	)

	
CREATE NONCLUSTERED INDEX ind_report_result_3 ON #report_result (
	 Acquirer
	
	)

	CREATE NONCLUSTERED INDEX ind_report_result_4 ON #report_result (
   Issuer 
	
	)
	
        
/*        
INSERT INTO  #report_result

SELECT		         
	bank_code = CASE 
	

                          
                          WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '29'
                           and  master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                            and  (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'FEE_PAYABLE')=1 or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr, 'FEE_PAYABLE')=1)) THEN 'ISW' 
                              
                          
                          
WHEN                      (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)
                          and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                          and ( master.dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                          AND  master.dbo.fn_rpt_CardGroup(ptc.pan) = '6'
                          AND ((PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787') 
                                OR (PTC.source_node_name = 'SWTFBPsrc' AND PT.sink_node_name = 'ASPPOSVISsnk' 
                                 AND totals_group = 'VISAGroup')
                               )
                          THEN 'UBA'
                          
                          
WHEN                      (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)
                          and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                          and ( master.dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                          AND  master.dbo.fn_rpt_CardGroup(ptc.pan) = '6'
                          AND (PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code = '627787')
                          THEN 'UNK'
                         

WHEN tran_postilion_originated  = 1 AND Retention_data = '1046' and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1) THEN 'UBN'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9130','8130') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'ABS'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9044','8044') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'ABP'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9023','8023')  and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1) then 'CITI'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9050','8050') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'EBN'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9214','8214') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'FCMB'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9070','8070','1100') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'FBP'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9011','8011') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'FBN'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9058','8058')  and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1) then 'GTB'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9082','8082') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'KSB'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9076','8076') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'SKYE'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9084','8084') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'ENT'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9039','8039') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'IBTC'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9068','8068') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'SCB'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9232','8232','1105') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'SBP'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9032','8032')  and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1) then 'UBN'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9033','8033')  and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1) then 'UBA'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9215','8215')  and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1) then 'UBP'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9035','8035') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'WEMA'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9057','8057') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'ZIB'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9301','8301') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'JBP'
WHEN tran_postilion_originated  = 1 AND Retention_data in ('9030') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1)  then 'HBC'                        
                          
			
			
			WHEN tran_postilion_originated  = 1 AND Retention_data = '1131' and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1) THEN 'WEMA'
                         WHEN tran_postilion_originated  = 1 AND Retention_data in ('1061','1006') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1

                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1) THEN 'GTB'
                         WHEN tran_postilion_originated  = 1 AND Retention_data = '1708' and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1) THEN 'FBN'
                         WHEN tran_postilion_originated  = 1 AND Retention_data in ('1027','1045','1081','1015') and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1) THEN 'SKYE'
                         WHEN tran_postilion_originated  = 1 AND Retention_data = '1037' and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1) THEN 'IBTC'
                         WHEN tran_postilion_originated  = 1 AND Retention_data = '1034' and 
                         (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                          OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1) THEN 'EBN'
                         -- WHEN tran_postilion_originated  = 1 AND Retention_data = '1006' and 
                         --(master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_PAYABLE')=1
                         -- OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'ISSUER_FEE_RECEIVABLE')=1
                         -- OR master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'AMOUNT_PAYABLE')=1 OR master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'AMOUNT_PAYABLE')=1) THEN 'DBL'
                         WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'UBA')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'UBA')=1) THEN 'UBA'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'FBN')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'FBN')=1) THEN 'FBN'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ZIB')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ZIB')=1) THEN 'ZIB'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'SPR')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'SPR')=1) THEN 'ENT'
                         WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'GTB')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'GTB')=1) THEN 'GTB'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'PRU')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'PRU')=1) THEN 'SKYE'
                         WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'OBI')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'OBI')=1) THEN 'EBN'
                         WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'WEM')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'WEM')=1) THEN 'WEMA'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'AFR')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'AFR')=1) THEN 'MSB'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'IBTC')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'IBTC')=1) THEN 'IBTC'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'PLAT')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'PLAT')=1) THEN 'KSB'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'UBP')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'UBP')=1) THEN 'UBP'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'DBL')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'DBL')=1) THEN 'DBL'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'FCMB')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'FCMB')=1) THEN 'FCMB'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'IBP')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'IBP')=1) THEN 'ABP'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'UBN')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'UBN')=1) THEN 'UBN'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ETB')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ETB')=1) THEN 'ETB'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'FBP')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'FBP')=1) THEN 'FBP'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'SBP')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'SBP')=1) THEN 'SBP'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ABP')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ABP')=1) THEN 'ABP'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'EBN')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'EBN')=1) THEN 'EBN'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'CITI')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'CITI')=1) THEN 'CITI'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'FIN')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'FIN')=1) THEN 'FCMB'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ASO')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ASO')=1) THEN 'ASO'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'OLI')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'OLI')=1) THEN 'OLI'						 
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'HSL')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'HSL')=1) THEN 'HSL'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ABS')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ABS')=1) THEN 'ABS'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'PAY')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'PAY')=1) THEN 'PAY'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'SAT')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'SAT')=1) THEN 'SAT'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'3LCM')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'3LCM')=1) THEN '3LCM'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'SCB')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'SCB')=1) THEN 'SCB'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'JBP')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'JBP')=1) THEN 'JBP'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'RSL')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'RSL')=1) THEN 'RSL'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'PSH')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'PSH')=1) THEN 'PSH'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'INF')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'INF')=1) THEN 'INF'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'UML')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'UML')=1) THEN 'UML'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ACCI')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ACCI')=1) THEN 'ACCI'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'EKON')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'EKON')=1) THEN 'EKON'						 
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ATMC')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ATMC')=1) THEN 'ATMC'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'HBC')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'HBC')=1) THEN 'HBC'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'UNI')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'UNI')=1) THEN 'UNI'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'UNC')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'UNC')=1) THEN 'UNC'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'NCS')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'NCS')=1) THEN 'NCS'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'HAG')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'HAG')=1) THEN 'HAG'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'EXP')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'EXP')=1) THEN 'DBL'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'FGMB')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'FGMB')=1) THEN 'FGMB'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'CEL')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'CEL')=1) THEN 'CEL'	
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'RDY')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'RDY')=1) THEN 'RDY'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'AMJ')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'AMJ')=1) THEN 'AMJU'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'CAP')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'CAP')=1) THEN 'O3CAP'	
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'VER')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'VER')=1) THEN 'VER_GLOBAL'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'SMF')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'SMF')=1) THEN 'SMFB'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'SLT')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'SLT')=1) THEN 'SLTD'						
						WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'JES')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'JES')=1) THEN 'JES'
						 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'MOU')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'MOU')=1) THEN 'MOUA'
						  WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'MUT')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'MUT')=1) THEN 'MUT'
						   WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'LAV')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'LAV')=1) THEN 'LAV'
						    WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'JUB')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'JUB')=1) THEN 'JUB'
							 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'WET')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'WET')=1) THEN 'WET'
							 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'AGH')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'AGH')=1) THEN 'AGH'
							 
							 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'TRU')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'TRU')=1) THEN 'TRU'
							  WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'CON')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'CON')=1) THEN 'CON'
							   WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'CRU')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'CRU')=1) THEN 'CRU'
							    WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'NPR')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'NPR')=1) THEN 'NPR'
								 WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'NPM')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'NPM')=1) THEN 'NPM'
								
  
                         WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'POS_FOODCONCEPT')=1 OR master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'POS_FOODCONCEPT')=1 ) THEN 'SCB'
			 WHEN ((master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'POOL')=0 ) OR (master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ISW')=1
			 and master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'POOL')=0 ) ) THEN 'ISW'
			
			 ELSE 'UNK'	
		
END,
	trxn_category=CASE WHEN (PT.tran_type ='01')  
							AND  master.dbo.fn_rpt_CardGroup(PTC.PAN) in ('1','4')
                           AND PTC.source_node_name = 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE INTERNATIONAL)'
                           
                           WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'MCARD')=1 AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'BILLING')=1) OR (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'MCARD')=1 AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'BILLING')=1))
                           and PT.tran_type ='50'  then 'MASTERCARD LOCAL PROCESSING BILLING(PAYMENTS)'

                           WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'MCARD')=1 AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'BILLING')=1) OR (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'MCARD')=1 AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'BILLING')=1))
                           and PT.tran_type ='00' and PTC.source_node_name = 'VTUsrc'  then 'MASTERCARD LOCAL PROCESSING BILLING(RECHARGE)'
                
                           WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'MCARD')=1 AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'BILLING')=1) OR (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'MCARD')=1 AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'BILLING')=1))
                           and PT.tran_type ='00' and PTC.source_node_name <> 'VTUsrc'  and PT.sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PTC.Terminal_id,1,1) in ('2','5','6')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(POS PURCHASE)'

                           WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'MCARD')=1 AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'BILLING')=1) OR (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'MCARD')=1 AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'BILLING')=1))
                           and PT.tran_type ='00' and PTC.source_node_name <> 'VTUsrc'  and PT.sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PTC.Terminal_id,1,1) in ('3')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(WEB PURCHASE)'

                            WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'V')=0 AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'BILLING')=0) and (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'V')=0 AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'BILLING')=0))
                           AND PT.sink_node_name = 'ESBCSOUTsnk'
                           and  master.dbo.fn_rpt_Cardless(pt.extended_tran_type) = 1 
                           THEN 'ATM WITHDRAWAL (Cardless:Paycode Verve Token)'
                           
                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'V')=0 AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'BILLING')=0) and (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'V')=0 AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'BILLING')=0))
                           AND PT.sink_node_name = 'ESBCSOUTsnk'
                           and  master.dbo.fn_rpt_Cardless(pt.extended_tran_type) = 2 
                           THEN 'ATM WITHDRAWAL (Cardless:Paycode Non-Verve Token)'
                           
                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'V')=0 AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'BILLING')=0) and (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'V')=0 AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'BILLING')=0))
                           AND PT.sink_node_name = 'ESBCSOUTsnk'
                           and  master.dbo.fn_rpt_Cardless(pt.extended_tran_type) = 3 
                           THEN 'ATM WITHDRAWAL (Cardless:Non-Card Generated)'


                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'V')=0 AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'BILLING')=0) and (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'V')=0 AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'BILLING')=0))
                           AND PTC.source_node_name <> 'SWTMEGAsrc'
                           AND PTC.source_node_name <> 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (REGULAR)'
                           
                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 

                           and ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'V')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'BILLING')=1) OR (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'V')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'BILLING')=1))
                           AND PTC.source_node_name <> 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE BILLING)'

                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'V')=0 AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'BILLING')=0) and (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'V')=0 AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'BILLING')=0))
                           AND PTC.source_node_name = 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (SMARTPOINT)'
 
			               WHEN ( master.dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = '1' and 
                           (master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'BILLPAYMENT MCARD')=1 or master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'BILLPAYMENT MCARD')=1) ) then 'BILLPAYMENT MASTERCARD BILLING'

                           WHEN ( master.dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = '1' 
                           and (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'SVA_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'SVA_FEE_RECEIVABLE')=1) ) 
                           AND  master.dbo.fn_rpt_isBillpayment_IFIS(ptc.terminal_id) = 1  then 'BILLPAYMENT IFIS REMITTANCE'
                          
			               WHEN ( master.dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = '1') then 'BILLPAYMENT'
			   
			
                           WHEN (PT.tran_type ='40'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' 

                           or SUBSTRING(PTC.Terminal_id,1,1)= '0' or SUBSTRING(PTC.Terminal_id,1,1)= '4')) THEN 'CARD HOLDER ACCOUNT TRANSFER'

                           WHEN  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           AND SUBSTRING(PTC.Terminal_id,1,1)IN ('2','5','6')AND PT.sink_node_name = 'ESBCSOUTsnk' and  master.dbo.fn_rpt_Cardless(pt.extended_tran_type) = 1 
                           THEN 'POS PURCHASE (Cardless:Paycode Verve Token)'
                           
                           WHEN  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           AND SUBSTRING(PTC.Terminal_id,1,1)IN ('2','5','6')AND PT.sink_node_name = 'ESBCSOUTsnk' and  master.dbo.fn_rpt_Cardless(pt.extended_tran_type) = 2 
                           THEN 'POS PURCHASE (Cardless:Paycode Non-Verve Token)'

                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '1'
                           and  master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                            and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                              or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) THEN 'POS(GENERAL MERCHANT)PURCHASE'
                           
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '2'
                           and  master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                           or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) THEN 'POS(CHURCHES, FASTFOODS & NGOS)'

                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '3'
                           and  master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                           or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) THEN 'POS(CONCESSION)PURCHASE'

                           WHEN (  master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '4'
                           and  master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                           or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) THEN 'POS(TRAVEL AGENCIES)PURCHASE'
                           

                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '5'
                           and  master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                           or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) THEN 'POS(HOTELS)PURCHASE'

                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '6'
                           and  master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                           or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) THEN 'POS(WHOLESALE)PURCHASE'
                    
                            WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '14'
                            and  master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                            and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                            or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) THEN 'POS(WHOLESALE_ACQUIRER_BORNE)PURCHASE'


                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '7'
                           and  master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                           or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) THEN 'POS(FUEL STATION)PURCHASE'
 
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '8'
                           and  master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                           or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) THEN 'POS(EASYFUEL)PURCHASE'

                           WHEN  ( master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) ='1'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                           or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) THEN 'POS(GENERAL MERCHANT-VISA)PURCHASE'
                     
                           WHEN ( master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) ='2'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                           or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) THEN 'POS(2% CATEGORY-VISA)PURCHASE'
                           
                           WHEN ( master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) ='3'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                           or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) THEN 'POS(3% CATEGORY-VISA)PURCHASE'
                           
                           
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '29'
                           and  master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                            and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                              or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) THEN 'POS(VAS CLOSED SCHEME)PURCHASE'+'_'+PTC.merchant_type
                           
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '9'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(GENERIC)PURCHASE'

                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '10'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N200)PURCHASE'

                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '11'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N300)PURCHASE'


                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '12'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N150)PURCHASE'

                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '13'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(1.5% CAPPED AT N300)PURCHASE'
                       
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '15'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB COLLEGES ( 1.5% capped specially at 250)'
                           
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '16'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB (PROFESSIONAL SERVICES)PURCHASE'

                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '17'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB (SECURITY BROKERS/DEALERS)PURCHASE'
 
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '18'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB (COMMUNICATION)PURCHASE'

                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '19'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N400)PURCHASE'

                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '20'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N250)PURCHASE'
                  
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '21'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N265)PURCHASE'

                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '22'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N550)PURCHASE'
                           
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '23'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'Verify card â€“ Ecash load'

                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '24'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(1% CAPPED AT 1,000 CATEGORY)PURCHASE'
                           
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '25'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(0.75% CAPPED AT 2,000 CATEGORY)PURCHASE'
                           
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '26'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(Verve_Payment_Gateway_0.9%)PURCHASE'
                           
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '27'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(Verve_Payment_Gateway_1.25%)PURCHASE'
                           
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '28'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(Verve_Add_Card)PURCHASE'
                           
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) is NULL
                           and  master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1)
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                           or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)THEN 'POS(GENERAL MERCHANT)PURCHASE' 

                             WHEN ( master.dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '1'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1)
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                           or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)THEN 'POS PURCHASE WITH CASHBACK'

                           WHEN ( master.dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '2'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2)
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)
                           or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1) THEN 'POS CASHWITHDRAWAL'

                           
                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) in ( select PART from dbo.usf_split_string('1,2,3,4,5,6,7,8,14',','))
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1))) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1))) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN ( master.dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '1'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1))) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN ( master.dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '2'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2 and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1))) 
                           THEN 'Fees collected for all Terminal_owners'


                           WHEN (pt.tran_type = '50' and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1))) 
                           THEN 'Fees collected for all Terminal_owners'
                           
                           WHEN (pt.tran_type = '50' and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) 
                           THEN 'Fees collected for all PTSPs'


                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN ( master.dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '1'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN ( master.dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '2'
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2 and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1 or master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'



                           WHEN ( master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) is NULL
                           and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1)
                           and SUBSTRING(PTC.Terminal_id,1,1)= '3' THEN 'WEB(GENERIC)PURCHASE'

                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '313' 
                                 and (master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'fee')=1 OR master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'fee')=1)
                                 and (PT.tran_type in ('50') or( master.dbo.fn_rpt_autopay_intra_sett (PT.tran_type,PTC.source_node_name) = 1))
                                 and not (master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'PREPAIDLOAD')=1 or master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'PREPAIDLOAD')=1)) THEN 'AUTOPAY TRANSFER FEES'
                          
                           
                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,

                                  PT.extended_tran_type ,PTC.source_node_name) = '313' 
                                 and (master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'fee')=0 OR master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'fee')=0)

                                 and PT.tran_type in ('50')
                                 and not (master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'PREPAIDLOAD')=1 or master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'PREPAIDLOAD')=1)) THEN 'AUTOPAY TRANSFERS'

                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '1' and PT.tran_type = '50') THEN 'ATM TRANSFERS'

                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '2' and PT.tran_type = '50') THEN 'POS TRANSFERS'
                           
                           
                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '4' and PT.tran_type = '50') THEN 'MOBILE TRANSFERS'

                          WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '35' and PT.tran_type = '50') then 'REMITA TRANSFERS'

       
                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '31' and PT.tran_type = '50') then 'OTHER TRANSFERS'
                           
                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,

                                  PT.extended_tran_type ,PTC.source_node_name) = '32' and PT.tran_type = '50') then 'RELATIONAL TRANSFERS'
                           
                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '33' and PT.tran_type = '50') then 'SEAMFIX TRANSFERS'
                           
                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '34' and PT.tran_type = '50') then 'VERVE INTL TRANSFERS'

                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '36' and PT.tran_type = '50') then 'PREPAID CARD UNLOAD'

                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '37' and PT.tran_type = '50' ) then 'QUICKTELLER TRANSFERS(BANK BRANCH)'
 
                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '38' and PT.tran_type = '50') then 'QUICKTELLER TRANSFERS(SVA)'
                           
                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '39' and PT.tran_type = '50') then 'SOFTPAY TRANSFERS'

                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '310' and PT.tran_type = '50') then 'OANDO S&T TRANSFERS'

                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '311' and PT.tran_type = '50') then 'UPPERLINK TRANSFERS'

                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '312'  and PT.tran_type = '50') then 'QUICKTELLER WEB TRANSFERS'

                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '314'  and PT.tran_type = '50') then 'QUICKTELLER MOBILE TRANSFERS'
                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '315' and PT.tran_type = '50') then 'WESTERN UNION MONEY TRANSFERS'

                           WHEN ( master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '316' and PT.tran_type = '50') then 'OTHER TRANSFERS(NON GENERIC PLATFORM)'
                           
                           WHEN ( master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2)
                                 AND ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'AMOUNT')=0 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=0) AND (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'AMOUNT')=0 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=0)) then 'PREPAID MERCHANDISE'
                           
                           WHEN ( master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2)
                                 AND ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'AMOUNT')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) or (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'AMOUNT')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) then 'PREPAID MERCHANDISE DUE ISW'--the unk% is excempted from the bank's net
                           
                                                      
                          WHEN ( master.dbo.fn_rpt_isCardload (PTC.source_node_name ,PTC.pan, PT.tran_type)= '1') then 'PREPAID CARDLOAD'

                          when pt.tran_type = '21' then 'DEPOSIT'

                   
                           
                          ELSE 'UNK'		

END,
  Debit_account_type=CASE 
              
                      WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'AMOUNT')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PAYABLE')=1)) 
                      and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and ( master.dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND  master.dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISSUER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PAYABLE')=1)) 
                      and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and ( master.dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND  master.dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                          
                       WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISSUER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) 
                      and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and ( master.dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND  master.dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'
                      
                      WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'AMOUNT')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PAYABLE')=1)) THEN 'AMOUNT PAYABLE(Debit_Nr)'
	                  WHEN (( master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'AMOUNT')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'AMOUNT RECEIVABLE(Debit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'RECHARGE')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PAYABLE')=1)) THEN 'RECHARGE FEE PAYABLE(Debit_Nr)'  
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ACQUIRER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PAYABLE')=1)) THEN 'ACQUIRER FEE PAYABLE(Debit_Nr)' 
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'CO')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ACQUIRER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'CO-ACQUIRER FEE RECEIVABLE(Debit_Nr)'   
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ACQUIRER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'ACQUIRER FEE RECEIVABLE(Debit_Nr)'  
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISSUER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PAYABLE')=1)) THEN 'ISSUER FEE PAYABLE(Debit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'CARDHOLDER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISSUER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Debit_Nr)' 
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'SCH')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISSUER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISSUER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PAYIN_INSTITUTION_FEE_RECEIVABLE')=1) THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Debit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PAYABLE')=1)) THEN 'ISW FEE PAYABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISW_ATM_FEE_CARD_SCHEME')=1 ) THEN 'ISW CARD SCHEME FEE RECEIVABLE (Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISW_ATM_FEE_ACQ_')=1 ) THEN 'ISW ACQUIRER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISW_ATM_FEE_ISS_')=1) THEN 'ISW ISSUER FEE RECEIVABLE (Debit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '1')
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1')THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'


                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) 

                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '2')
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '3') 

                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '4') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'
                           
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '5') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Debit_Nr)'

                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '6') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '7') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '8') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Debit_Nr)'
               
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '10') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1) 

                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '9'
                          AND NOT (((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISO')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) OR (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)OR ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) OR ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'PROCESSOR')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) OR ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'NCS')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)))) THEN 'ISW FEE RECEIVABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'POS_FOODCONCEPT')=1)THEN 'FOODCONCEPT_TERMINAL_OWNER_FEE_RECEIVABLE(Debit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ISO')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'ISO FEE RECEIVABLE(Debit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'TERMINAL_OWNER FEE RECEIVABLE(Debit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'PROCESSOR')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'PROCESSOR FEE RECEIVABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'POOL_ACCOUNT')=1) THEN 'POOL ACCOUNT(Debit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ATMC')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PAYABLE')=1)) THEN 'ATMC FEE PAYABLE(Debit_Nr)'  
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'ATMC')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'ATMC FEE RECEIVABLE(Debit_Nr)'  
                          WHEN ( master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'FEE_POOL')=1) THEN 'FEE POOL(Debit_Nr)'  
                          WHEN ( master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'EASYFUEL_ACCOUNT')=1) THEN 'EASYFUEL ACCOUNT(Debit_Nr)'
                          WHEN ( (master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'MERCHANT')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'MERCHANT FEE RECEIVABLE(Debit_Nr)' 
                          WHEN ( (master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'YPM')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'YPM FEE RECEIVABLE(Debit_Nr)' 
                          WHEN ( (master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FLEETTECH')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'FLEETTECH FEE RECEIVABLE(Debit_Nr)' 
                          WHEN ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'LYSA')=1  AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'LYSA FEE RECEIVABLE(Debit_Nr)'

                         
                          WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'SVA_FEE_RECEIVABLE')=1) THEN 'SVA FEE RECEIVABLE(Debit_Nr)'
                          WHEN ( master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'UDIRECT_FEE_RECEIVABLE')=1) THEN 'UDIRECT FEE RECEIVABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1) THEN 'PTSP FEE RECEIVABLE(Debit_Nr)'
                            
                          WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'NCS_FEE_RECEIVABLE')=1) THEN 'NCS FEE RECEIVABLE(Debit_Nr)'  
			  WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'SVA_SPONSOR_FEE_PAYABLE')=1) THEN 'SVA SPONSOR FEE PAYABLE(Debit_Nr)'
			  WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr.acc_nr,'SVA_SPONSOR_FEE_RECEIVABLE')=1 ) THEN 'SVA SPONSOR FEE RECEIVABLE(Debit_Nr)'                      

                          ELSE 'UNK'			
END,
  Credit_account_type=CASE  
  
  
        WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'AMOUNT')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PAYABLE')=1)) 
                      and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and ( master.dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND  master.dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISSUER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PAYABLE')=1)) 
                      and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and ( master.dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND  master.dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                          
                       WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISSUER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) 
                      and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and ( master.dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND  master.dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'
                      
                      WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'AMOUNT')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PAYABLE')=1)) THEN 'AMOUNT PAYABLE(Credit_Nr)'
	                  WHEN (( master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'AMOUNT')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'AMOUNT RECEIVABLE(Credit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'RECHARGE')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PAYABLE')=1)) THEN 'RECHARGE FEE PAYABLE(Credit_Nr)'  
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ACQUIRER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PAYABLE')=1)) THEN 'ACQUIRER FEE PAYABLE(Credit_Nr)' 
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'CO')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ACQUIRER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'CO-ACQUIRER FEE RECEIVABLE(Credit_Nr)'   
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ACQUIRER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'ACQUIRER FEE RECEIVABLE(Credit_Nr)'  
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISSUER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PAYABLE')=1)) THEN 'ISSUER FEE PAYABLE(Credit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'CARDHOLDER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISSUER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Credit_Nr)' 
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'SCH')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISSUER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISSUER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PAYIN_INSTITUTION_FEE_RECEIVABLE')=1) THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Credit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PAYABLE')=1)) THEN 'ISW FEE PAYABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISW_ATM_FEE_CARD_SCHEME')=1 ) THEN 'ISW CARD SCHEME FEE RECEIVABLE (Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISW_ATM_FEE_ACQ_')=1 ) THEN 'ISW ACQUIRER FEE RECEIVABLE (Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISW_ATM_FEE_ISS_')=1) THEN 'ISW ISSUER FEE RECEIVABLE (Credit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '1')
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1')THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'


                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1) 

                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '2')
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '3') 

                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '4') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'
                           
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '5') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Credit_Nr)'

                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '6') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '7') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '8') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Credit_Nr)'
               
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1) 
                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '10') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISW')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1) 

                          AND  master.dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '9'
                          AND NOT (((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISO')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) OR (master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1)OR ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) OR ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'PROCESSOR')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) OR ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'NCS')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)))) THEN 'ISW FEE RECEIVABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'POS_FOODCONCEPT')=1)THEN 'FOODCONCEPT_TERMINAL_OWNER_FEE_RECEIVABLE(Credit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ISO')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'ISO FEE RECEIVABLE(Credit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'TERMINAL_OWNER')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1 AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'TERMINAL_OWNER FEE RECEIVABLE(Credit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'PROCESSOR')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'PROCESSOR FEE RECEIVABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'POOL_ACCOUNT')=1) THEN 'POOL ACCOUNT(Credit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ATMC')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PAYABLE')=1)) THEN 'ATMC FEE PAYABLE(Credit_Nr)'  
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'ATMC')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'ATMC FEE RECEIVABLE(Credit_Nr)'  
                          WHEN ( master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'FEE_POOL')=1) THEN 'FEE POOL(Credit_Nr)'  
                          WHEN ( master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'EASYFUEL_ACCOUNT')=1) THEN 'EASYFUEL ACCOUNT(Credit_Nr)'
                          WHEN ( (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'MERCHANT')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'MERCHANT FEE RECEIVABLE(Credit_Nr)' 
                          WHEN ( (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'YPM')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'YPM FEE RECEIVABLE(Credit_Nr)' 
                          WHEN ( (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FLEETTECH')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'FLEETTECH FEE RECEIVABLE(Credit_Nr)' 
                          WHEN ((master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'LYSA')=1  AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'FEE')=1  AND master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'RECEIVABLE')=1)) THEN 'LYSA FEE RECEIVABLE(Credit_Nr)'

                         
                          WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'SVA_FEE_RECEIVABLE')=1) THEN 'SVA FEE RECEIVABLE(Credit_Nr)'
                          WHEN ( master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'UDIRECT_FEE_RECEIVABLE')=1) THEN 'UDIRECT FEE RECEIVABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'PTSP_FEE_RECEIVABLE')=1) THEN 'PTSP FEE RECEIVABLE(Credit_Nr)'
                            
                          WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'NCS_FEE_RECEIVABLE')=1) THEN 'NCS FEE RECEIVABLE(Credit_Nr)'  
			  WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'SVA_SPONSOR_FEE_PAYABLE')=1) THEN 'SVA SPONSOR FEE PAYABLE(Credit_Nr)'
			  WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr.acc_nr,'SVA_SPONSOR_FEE_RECEIVABLE')=1) THEN 'SVA SPONSOR FEE RECEIVABLE(Credit_Nr)' 

                          ELSE 'UNK'			
END,

        amt=SUM(ISNULL(J.amount,0)),
	fee=SUM(ISNULL(J.fee,0)),
	business_date=j.business_date,
        currency = CASE WHEN ( master.dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = '1' and 
                           (master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'BILLPAYMENT MCARD')=1 or master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'BILLPAYMENT MCARD')=1) ) THEN '840'
                        WHEN (((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'MCARD')=1 AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'BILLING')=1) OR (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'MCARD')=1 AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'BILLING')=1)) and( PT.sink_node_name not in ('SWTFBPsnk','SWTABPsnk','SWTIBPsnk'))) THEN '840'
          ELSE pt.settle_currency_code END,
        Late_Reversal_id = CASE
        
                        WHEN (  master.dbo.fn_rpt_late_reversal(pt.tran_nr,pt.message_type,pt.retrieval_reference_nr) = 1
                               and   master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1)
                               and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                               and PTC.merchant_type in (SELECT part FROM dbo.usf_split_string('5371,2501,2504,2505,2506,2507,2508,2509,2510,2511', ',')) THEN 0
                               
						WHEN (  master.dbo.fn_rpt_late_reversal(pt.tran_nr,pt.message_type,pt.retrieval_reference_nr) = 1
                               and   master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1)
                               and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') THEN 1
						ELSE 0
					        END,
        card_type =   master.dbo.fn_rpt_CardGroup(ptc.pan),
        terminal_type =  master.dbo.fn_rpt_terminal_type(ptc.terminal_id),    
        source_node_name =   PTC.source_node_name,
        Unique_key = pt.retrieval_reference_nr+'_'+pt.system_trace_audit_nr+'_'+ptc.terminal_id+'_'+ cast((CONVERT(NUMERIC (15,2),isnull(pt.settle_amount_impact,0))) as VARCHAR(20))+'_'+pt.message_type,
        Acquirer = (case when (not ((master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'POOL')=0 ) OR (master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'POOL')=0 ) )) then ''
                      when ((master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'POOL')=0 ) OR (master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'POOL')=0 ) ) AND (acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code) then acc.bank_code --or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code1 or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code2 or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code3 or SUBSTRING(PTC.terminal_id,2,3) = acc.cbn_code4) THEN acc.bank_code
                      else PT.acquiring_inst_id_code END),
        Issuer = (case when (not ((master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'POOL')=0 ) OR (master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'POOL')=0 ) )) then ''
                      when ((master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'POOL')=0 ) OR (master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'POOL')=0 ) ) and (substring(ptc.totals_group,1,3) = acc.bank_code1) then acc.bank_code
                      else substring(ptc.totals_group,1,3) END)
                     */
SELECT  

J.adj_id
,J.entry_id
,J.config_set_id
,J.session_id
,J.post_tran_id
,J.post_tran_cust_id
,J.sdi_tran_id
,J.acc_post_id
,J.nt_fee_acc_post_id
,J.coa_id
,J.coa_se_id
,J.se_id
,J.amount
,J.amount_id
,J.amount_value_id
,J.fee
,J.fee_id
,J.fee_value_id
,J.nt_fee
,J.nt_fee_id
,J.nt_fee_value_id
,J.debit_acc_nr_id
,J.debit_acc_id
,J.debit_cardholder_acc_id
,J.debit_cardholder_acc_type
,J.credit_acc_nr_id
,J.credit_acc_id
,J.credit_cardholder_acc_id
,J.credit_cardholder_acc_type
,J.business_date
,J.granularity_element
,J.tag
,J.spay_session_id
,J.spst_session_id
,DebitAccNr.config_set_id DebitAccNr_config_set_id
,DebitAccNr.acc_nr_id  DebitAccNr_acc_nr_id
,DebitAccNr.se_id	DebitAccNr_se_id
,DebitAccNr.acc_id	DebitAccNr_acc_id
,DebitAccNr.acc_nr	DebitAccNr_acc_nr
,DebitAccNr.aggregation_id DebitAccNr_aggregation_id
,DebitAccNr.state	DebitAccNr_state
,DebitAccNr.config_state DebitAccNr_config_state
,CreditAccNr.config_set_id CreditAccNr_config_set_id
,CreditAccNr.acc_nr_id  CreditAccNr_acc_nr_id
,CreditAccNr.se_id	CreditAccNr_se_id
,CreditAccNr.acc_id	CreditAccNr_acc_id
,CreditAccNr.acc_nr	CreditAccNr_acc_nr
,CreditAccNr.aggregation_id CreditAccNr_aggregation_id
,CreditAccNr.state	CreditAccNr_state
,CreditAccNr.config_state CreditAccNr_config_state
,Amount.config_set_id	Amount_config_set_id
,Amount.amount_id	Amount_amount_id
,Amount.se_id	Amount_se_id
,Amount.name	Amount_name
,Amount.description	Amount_description
,Amount.config_state	Amount_config_state
,Fee.config_set_id Fee_config_set_id
,Fee.fee_id	Fee_fee_id
,Fee.se_id	Fee_se_id
,Fee.name	Fee_name
,Fee.description Fee_description
,Fee.type	Fee_type
,Fee.amount_id Fee_amount_id
,Fee.config_state Fee_config_state
,coa.config_set_id coa_config_set_id
,coa.coa_id	coa_coa_id
,coa.name	coa_name
,coa.description	coa_description
,coa.type	coa_type
,coa.config_state	coa_config_state
,PT.[post_tran_id]	PT_post_tran_id
,PT.[post_tran_cust_id]	PT_post_tran_cust_id
,PT.[settle_entity_id]	PT_settle_entity_id
,PT.[batch_nr]	PT_batch_nr
,PT.[prev_post_tran_id]	PT_prev_post_tran_id
,PT.[next_post_tran_id]	PT_next_post_tran_id
,PT.[sink_node_name]	PT_sink_node_name
,PT.[tran_postilion_originated]	PT_tran_postilion_originated
,PT.[tran_completed]	PT_tran_completed
,PT.[message_type]	PT_message_type
,PT.[tran_type]	PT_tran_type
,PT.[tran_nr]	PT_tran_nr
,PT.[system_trace_audit_nr]	PT_system_trace_audit_nr
,PT.[rsp_code_req]	PT_rsp_code_req
,PT.[rsp_code_rsp]	PT_rsp_code_rsp
,PT.[abort_rsp_code]	PT_abort_rsp_code
,PT.[auth_id_rsp]	PT_auth_id_rsp
,PT.[auth_type]	PT_auth_type
,PT.[auth_reason]	PT_auth_reason
,PT.[retention_data]	PT_retention_data
,PT.[acquiring_inst_id_code]	PT_acquiring_inst_id_code
,PT.[message_reason_code]	PT_message_reason_code
,PT.[sponsor_bank]	PT_sponsor_bank
,PT.[retrieval_reference_nr]	PT_retrieval_reference_nr
,PT.[datetime_tran_gmt]	PT_datetime_tran_gmt
,PT.[datetime_tran_local]	PT_datetime_tran_local
,PT.[datetime_req]	PT_datetime_req
,PT.[datetime_rsp]	PT_datetime_rsp
,PT.[realtime_business_date]	PT_realtime_business_date
,PT.[recon_business_date]	PT_recon_business_date
,PT.[from_account_type]	PT_from_account_type
,PT.[to_account_type]	PT_to_account_type
,PT.[from_account_id]	PT_from_account_id
,PT.[to_account_id]	PT_to_account_id
,PT.[tran_amount_req]	PT_tran_amount_req
,PT.[tran_amount_rsp]	PT_tran_amount_rsp
,PT.[settle_amount_impact]	PT_settle_amount_impact
,PT.[tran_cash_req]	PT_tran_cash_req
,PT.[tran_cash_rsp]	PT_tran_cash_rsp
,PT.[tran_currency_code]	PT_tran_currency_code
,PT.[tran_tran_fee_req]	PT_tran_tran_fee_req
,PT.[tran_tran_fee_rsp]	PT_tran_tran_fee_rsp
,PT.[tran_tran_fee_currency_code]	PT_tran_tran_fee_currency_code
,PT.[tran_proc_fee_req]	PT_tran_proc_fee_req
,PT.[tran_proc_fee_rsp]	PT_tran_proc_fee_rsp
,PT.[tran_proc_fee_currency_code]	PT_tran_proc_fee_currency_code
,PT.[settle_amount_req]	PT_settle_amount_req
,PT.[settle_amount_rsp]	PT_settle_amount_rsp
,PT.[settle_cash_req]	PT_settle_cash_req
,PT.[settle_cash_rsp]	PT_settle_cash_rsp
,PT.[settle_tran_fee_req]	PT_settle_tran_fee_req
,PT.[settle_tran_fee_rsp]	PT_settle_tran_fee_rsp
,PT.[settle_proc_fee_req]	PT_settle_proc_fee_req
,PT.[settle_proc_fee_rsp]	PT_settle_proc_fee_rsp
,PT.[settle_currency_code]	PT_settle_currency_code
,PT.[pos_entry_mode]	PT_pos_entry_mode
,PT.[pos_condition_code]	PT_pos_condition_code
,PT.[additional_rsp_data]	PT_additional_rsp_data
,PT.[tran_reversed]	PT_tran_reversed
,PT.[prev_tran_approved]	PT_prev_tran_approved
,PT.[issuer_network_id]	PT_issuer_network_id
,PT.[acquirer_network_id]	PT_acquirer_network_id
,PT.[extended_tran_type]	PT_extended_tran_type
,PT.[from_account_type_qualifier]	PT_from_account_type_qualifier
,PT.[to_account_type_qualifier]	PT_to_account_type_qualifier
,PT.[bank_details]	PT_bank_details
,PT.[payee]	PT_payee
,PT.[card_verification_result]	PT_card_verification_result
,PT.[online_system_id]	PT_online_system_id
,PT.[participant_id]	PT_participant_id
,PT.[opp_participant_id]	PT_opp_participant_id
,PT.[receiving_inst_id_code]	PT_receiving_inst_id_code
,PT.[routing_type]	PT_routing_type
,PT.[pt_pos_operating_environment]	PT_pt_pos_operating_environment
,PT.[pt_pos_card_input_mode]	PT_pt_pos_card_input_mode
,PT.[pt_pos_cardholder_auth_method]	PT_pt_pos_cardholder_auth_method
,PT.[pt_pos_pin_capture_ability]	PT_pt_pos_pin_capture_ability
,PT.[pt_pos_terminal_operator]	PT_pt_pos_terminal_operator
,PT.[source_node_key]	PT_source_node_key
,PT.[proc_online_system_id]	PT_proc_online_system_id,
PTC.[post_tran_cust_id]	PTC_post_tran_cust_id
,PTC.[source_node_name]	PTC_source_node_name
,PTC.[draft_capture]	PTC_draft_capture
,PTC.[pan]	PTC_pan
,PTC.[card_seq_nr]	PTC_card_seq_nr
,PTC.[expiry_date]	PTC_expiry_date
,PTC.[service_restriction_code]	PTC_service_restriction_code
,PTC.[terminal_id]	PTC_terminal_id
,PTC.[terminal_owner]	PTC_terminal_owner
,PTC.[card_acceptor_id_code]	PTC_card_acceptor_id_code
,PTC.[mapped_card_acceptor_id_code]	PTC_mapped_card_acceptor_id_code
,PTC.[merchant_type]	PTC_merchant_type
,PTC.[card_acceptor_name_loc]	PTC_card_acceptor_name_loc
,PTC.[address_verification_data]	PTC_address_verification_data
,PTC.[address_verification_result]	PTC_address_verification_result
,PTC.[check_data]	PTC_check_data
,PTC.[totals_group]	PTC_totals_group
,PTC.[card_product]	PTC_card_product
,PTC.[pos_card_data_input_ability]	PTC_pos_card_data_input_ability
,PTC.[pos_cardholder_auth_ability]	PTC_pos_cardholder_auth_ability
,PTC.[pos_card_capture_ability]	PTC_pos_card_capture_ability
,PTC.[pos_operating_environment]	PTC_pos_operating_environment
,PTC.[pos_cardholder_present]	PTC_pos_cardholder_present
,PTC.[pos_card_present]	PTC_pos_card_present
,PTC.[pos_card_data_input_mode]	PTC_pos_card_data_input_mode
,PTC.[pos_cardholder_auth_method]	PTC_pos_cardholder_auth_method
,PTC.[pos_cardholder_auth_entity]	PTC_pos_cardholder_auth_entity
,PTC.[pos_card_data_output_ability]	PTC_pos_card_data_output_ability
,PTC.[pos_terminal_output_ability]	PTC_pos_terminal_output_ability
,PTC.[pos_pin_capture_ability]	PTC_pos_pin_capture_ability
,PTC.[pos_terminal_operator]	PTC_pos_terminal_operator
,PTC.[pos_terminal_type]	PTC_pos_terminal_type
,PTC.[pan_search]	PTC_pan_search
,PTC.[pan_encrypted]	PTC_pan_encrypted
,PTC.[pan_reference]	PTC_pan_reference
,acc.acquirer_inst_id1	acc_acquirer_inst_id1
,acc.acquirer_inst_id2 acc_acquirer_inst_id2 
,acc.acquirer_inst_id3	acc_acquirer_inst_id3 
,acc.acquirer_inst_id4 acc_acquirer_inst_id4
,acc.acquirer_inst_id5  acc_acquirer_inst_id5
,acc.bank_code acc_bank_code
,acc.bank_code1 acc_bank_code1 

 INTO #temp_results
FROM  dbo.sstl_journal_all AS J (NOLOCK)
JOIN (SELECT  [DATE] business_date FROM  dbo.[get_dates_in_range](@from_date, @to_date))rdate1
ON ( rdate1.business_date=  J.business_date )
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
RIGHT OUTER JOIN post_tran AS PT (NOLOCK, INDEX(ix_post_tran_9))
ON ( J.post_tran_cust_id = PT.post_tran_cust_id)
  JOIN Post_tran_cust AS PTC (NOLOCK)
ON (J.post_tran_cust_id = PTC.post_tran_cust_id AND J.post_tran_cust_id = PTC.post_tran_cust_id)
JOIN (SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range](@from_date, @to_date))rdate
ON (rdate.recon_business_date = PT.recon_business_date)
LEFT OUTER JOIN aid_cbn_code acc ON
(acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or 
acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code)

WHERE 

  
      
       (
          (PT.settle_amount_impact<> 0 and PT.message_type   in ('0200','0220'))

       or ((PT.settle_amount_impact<> 0 and PT.message_type = '0420' 

       and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) <> 1 and PT.tran_reversed <> 2)
       or (PT.settle_amount_impact<> 0 and PT.message_type = '0420' 
       and  master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 ))

       or (PT.settle_amount_rsp<> 0 and PT.message_type   in ('0200','0220') and PT.tran_type = 40 and (SUBSTRING(PTC.Terminal_id,1,1) IN ('0','1') ))
       or (PT.message_type = '0420' and PT.tran_reversed <> 2 and PT.tran_type = 40 and (SUBSTRING(PTC.Terminal_id,1,1)IN ( '0','1' )))
	   )
      
     -- AND (J.Business_date  in (SELECT [DATE] FROM dbo.get_dates_in_range(@from_date, @to_date)))

      AND not (merchant_type in ('4004','4722') and pt.tran_type = '00' and source_node_name not in ('VTUsrc','CCLOADsrc') and  abs(pt.settle_amount_impact/100)< 200
       and not ((master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'MCARD')=1 AND master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'BILLING')=1) OR (master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'MCARD')=1 AND master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'BILLING')=1)))

      AND PTC.totals_group <> ('CUPGroup')
      and NOT (PTC.totals_group ='VISAGroup' and PT.acquiring_inst_id_code = '627787')
	  and NOT (PTC.totals_group  = 'VISAGroup' and PT.sink_node_name <>'ASPPOSVINsnk'
	            and not (ptc.source_node_name = 'SWTFBPsrc' and pt.sink_node_name = 'ASPPOSVISsnk') 
	           )
  
      and not (ptc.source_node_name  = 'MEGATPPsrc' and pt.tran_type = '00')
        and 
        convert(varchar(12),PT.tran_nr)+'_'+PT.retrieval_reference_nr not in
	                  (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 

        WHERE ll.recon_business_date >= @report_date_start

        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1)

         OPTION(	RECOMPILE,MAXDOP 8)
         
         SELECT * FROM #temp_results 
--GROUP BY 

--j.business_date,
--DebitAccNr.acc_nr,
--CreditAccNr.acc_nr,
--PT.tran_type,

--master.dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type),
--master.dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN),pt.acquiring_inst_id_code,

--ptc.totals_group, SUBSTRING(PTC.Terminal_id,1,1),
--master.dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan),
--master.dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan),
--master.dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
--                              PT.extended_tran_type ,PTC.source_node_name),
--master.dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan),
--master.dbo.fn_rpt_isCardload (PTC.source_node_name ,PTC.pan, PT.tran_type),
--master.dbo.fn_rpt_CardType (PTC.pan ,PT.sink_node_name ,PT.tran_type,PTC.TERMINAL_ID),
--master.dbo.fn_rpt_autopay_intra_sett (PT.tran_type,PTC.source_node_name),
--Retention_data,
--tran_postilion_originated,
--pt.settle_currency_code,
--PTC.source_node_name,
--PT.sink_node_name,
--master.dbo.fn_rpt_late_reversal(pt.tran_nr,pt.message_type,pt.retrieval_reference_nr),
--master.dbo.fn_rpt_CardGroup(ptc.pan),  master.dbo.fn_rpt_terminal_type(ptc.terminal_id),
--pt.retrieval_reference_nr+'_'+pt.system_trace_audit_nr+'_'+ptc.terminal_id+'_'+ cast((CONVERT(NUMERIC (15,2),isnull(pt.settle_amount_impact,0))) as VARCHAR(20))+'_'+pt.message_type,
--master.dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type),
--(case when (not ((master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'POOL')=0 ) OR (master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'POOL')=0 ) )) then ''
--                  when ((master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'POOL')=0 ) OR (master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'POOL')=0 ) ) AND (acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code) then acc.bank_code --or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code1 or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code2 or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code3 or SUBSTRING(PTC.terminal_id,2,3) = acc.cbn_code4) THEN acc.bank_code
--                  else PT.acquiring_inst_id_code END),
--(case when (not ((master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'POOL')=0 ) OR (master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'POOL')=0 ) )) then ''
--                  when ((master.dbo.fn_rpt_starts_with(DebitAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(DebitAccNr.acc_nr,'POOL')=0 ) OR (master.dbo.fn_rpt_starts_with(CreditAccNr.acc_nr,'ISW')=1 and master.dbo.fn_rpt_contains(CreditAccNr.acc_nr,'POOL')=0 ) ) and (substring(ptc.totals_group,1,3) = acc.bank_code1) then acc.bank_code1
--                  else substring(ptc.totals_group,1,3) END),
--acc.bank_code1, acc.bank_code, PT.acquiring_inst_id_code,pt.extended_tran_type,PTC.merchant_type,  master.dbo.fn_rpt_isBillpayment_IFIS(ptc.terminal_id)
OPTION(RECOMPILE, MAXDOP 8)

create table #temp_table
(unique_key VARCHAR(200))

create nonclustered index ind_temp_table ON #temp_table(
unique_key
)
insert into #temp_table 
select unique_key from #report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')
OPTION(RECOMPILE, MAXDOP 8)

	
	SELECT 
			bank_code,trxn_category,Debit_Account_type,Credit_Account_type,sum(trxn_amount),sum(trxn_fee),trxn_date, Currency,late_reversal,card_type,terminal_type, Acquirer, Issuer 
	FROM 
			#report_result 
where     index_no not IN (SELECT index_no FROM  #report_result where source_node_name in (SELECT part FROM  dbo.usf_split_string('SWTNCS2src,SWTSHOPRTsrc,WTNCSKIMsrc,SWTNCSKI2src,SWTFBPsrc', ',') )
and 
unique_key  IN (SELECT unique_key FROM #temp_table))  
      
    

GROUP BY bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_date,Currency,late_reversal,card_type,terminal_type,Acquirer, Issuer
OPTION(RECOMPILE, MAXDOP 8)

END  


