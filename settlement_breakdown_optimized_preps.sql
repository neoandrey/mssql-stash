CREATE TABLE dbo.post_tran_sstl_journal_summary_20160703(
			[entry_id] [bigint] NOT NULL,
			[config_set_id] [int] NOT NULL,
			[session_id] [int] NOT NULL,
			[post_tran_id] [bigint] NULL,
			[post_tran_cust_id] [bigint] NULL,
			[sdi_tran_id] [bigint] NULL,
			[acc_post_id] [int] NULL,
			[nt_fee_acc_post_id] [int] NULL,
			[coa_id] [int] NOT NULL,
			[coa_se_id] [int] NOT NULL,
			[se_id] [int] NOT NULL,
			[amount] [float] NULL,
			[amount_id] [int] NULL,
			[amount_value_id] [int] NULL,
			[fee] [float] NULL,
			[fee_id] [int] NULL,
			[fee_value_id] [int] NULL,
			[nt_fee] [float] NULL,
			[nt_fee_id] [int] NULL,
			[nt_fee_value_id] [int] NULL,
			[debit_acc_nr_id] [int] NULL,
			[debit_acc_id] [int] NULL,
			[debit_cardholder_acc_id] [varchar](28) NULL,
			[debit_cardholder_acc_type] [char](2) NULL,
			[credit_acc_nr_id] [int] NULL,
			[credit_acc_id] [int] NULL,
			[credit_cardholder_acc_id] [varchar](28) NULL,
			[credit_cardholder_acc_type] [char](2) NULL,
			[business_date] [datetime] NOT NULL,
			[granularity_element] [varchar](100) NULL,
			[tag] [varchar](4000) NULL,
			[spay_session_id] [int] NULL,
			[spst_session_id] [int] NULL
		)
		
		
		CREATE TABLE dbo.post_tran_sstl_journal_summary_20160704(
			[entry_id] [bigint] NOT NULL,
			[config_set_id] [int] NOT NULL,
			[session_id] [int] NOT NULL,
			[post_tran_id] [bigint] NULL,
			[post_tran_cust_id] [bigint] NULL,
			[sdi_tran_id] [bigint] NULL,
			[acc_post_id] [int] NULL,
			[nt_fee_acc_post_id] [int] NULL,
			[coa_id] [int] NOT NULL,
			[coa_se_id] [int] NOT NULL,
			[se_id] [int] NOT NULL,
			[amount] [float] NULL,
			[amount_id] [int] NULL,
			[amount_value_id] [int] NULL,
			[fee] [float] NULL,
			[fee_id] [int] NULL,
			[fee_value_id] [int] NULL,
			[nt_fee] [float] NULL,
			[nt_fee_id] [int] NULL,
			[nt_fee_value_id] [int] NULL,
			[debit_acc_nr_id] [int] NULL,
			[debit_acc_id] [int] NULL,
			[debit_cardholder_acc_id] [varchar](28) NULL,
			[debit_cardholder_acc_type] [char](2) NULL,
			[credit_acc_nr_id] [int] NULL,
			[credit_acc_id] [int] NULL,
			[credit_cardholder_acc_id] [varchar](28) NULL,
			[credit_cardholder_acc_type] [char](2) NULL,
			[business_date] [datetime] NOT NULL,
			[granularity_element] [varchar](100) NULL,
			[tag] [varchar](4000) NULL,
			[spay_session_id] [int] NULL,
			[spst_session_id] [int] NULL
		)
		
		USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[psp_settlement_summary_breakdown_optimized_v2]    Script Date: 07/04/2016 11:03:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE      PROCEDURE [dbo].[psp_settlement_summary_breakdown_optimized_v2](
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

/*Deprecated  - no use
--DECLARE @first_post_tran_id BIGINT
--DECLARE @last_post_tran_id BIGINT
--DECLARE @first_post_tran_cust_id BIGINT
--DECLARE @last_post_tran_cust_id BIGINT

*/
--IF( DATEDIFF(D,@from_date, @to_date)=0) BEGIN

	--Check if settlement has run for same period, if not, insert timestamp else, raise error
	--need to include a process to check that settlement has completed
	IF NOT EXISTS (select top 1 * from settlement_summary_session_optimized(nolock) where business_date = CONVERT(DATE, @from_date))
	BEGIN
		INSERT 
				   INTO settlement_summary_session_optimized
		SELECT TOP 1  (cast (J.business_date as varchar(40)))
			   FROM   dbo.post_tran_sstl_journal_summary AS J (NOLOCK) 
			   JOIN post_tran_summary_settle PT(NOLOCK)
			   ON j.post_tran_id = PT.post_tran_id
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
	END
	ELSE
	BEGIN
		RAISERROR('Duplicate Run of Settlement Breakdown',16,1)
		RETURN
	END
	
		-- Not sure what these do
	EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 
	EXEC psp_get_rpt_post_tran_cust_id_NIBSS @from_date,@to_date,@rpt_tran_id1 OUTPUT 

	IF (OBJECT_ID('tempdb.dbo.#report_result') is not null )begin
		drop table #tbl_late_reversals
	end
	
	IF (OBJECT_ID('tempdb.dbo.#tbl_late_reversals') is not null )begin
		drop table #tbl_late_reversals
	end
	
	IF (OBJECT_ID('tempdb.dbo.#post_tran_temp1') is not null )begin
		drop table #post_tran_temp1
	end
	
	IF (OBJECT_ID('tempdb.dbo.#post_tran_temp2') is not null )begin
		drop table #post_tran_temp2
	end
	
	IF (OBJECT_ID('tempdb.dbo.#report_result') is not null )begin
		drop table #report_result
	end
	
	IF (OBJECT_ID('tempdb.dbo.#temp_post_tran_exclusion') is not null )begin
		drop table #temp_post_tran_exclusion
	end
	
	IF (OBJECT_ID('tempdb.dbo.#sstl_journal_summary') is not null )begin
		drop table #sstl_journal_summary
	end
	
	declare @sql_statement varchar(8000)
	set @sql_statement = '
			declare @action_2 varchar(10)
			if not exists (select top 1 * from sys.objects where name = ''post_tran_summary_settle'' and type =''V'')
			begin
				set @action_2 = ''CREATE''
			end
			else
			begin
				set @action_2 = ''ALTER''
			end
				exec(@action_2+'' VIEW dbo.post_tran_summary_settle
				AS
					SELECT  post_tran_id
						  ,post_tran_cust_id
						  ,prev_post_tran_id
						  ,sink_node_name
						  ,tran_postilion_originated
						  ,tran_completed
						  ,message_type
						  ,tran_type
						  ,tran_nr
						  ,system_trace_audit_nr
						  ,rsp_code_req
						  ,rsp_code_rsp
						  ,abort_rsp_code
						  ,auth_id_rsp
						  ,retention_data
						  ,acquiring_inst_id_code
						  ,message_reason_code
						  ,retrieval_reference_nr
						  ,datetime_tran_gmt
						  ,datetime_tran_local
						  ,datetime_req
						  ,datetime_rsp
						  ,realtime_business_date
						  ,recon_business_date
						  ,from_account_type
						  ,to_account_type
						  ,from_account_id
						  ,to_account_id
						  ,tran_amount_req
						  ,tran_amount_rsp
						  ,settle_amount_impact
						  ,tran_cash_req
						  ,tran_cash_rsp
						  ,tran_currency_code
						  ,tran_tran_fee_req
						  ,tran_tran_fee_rsp
						  ,tran_tran_fee_currency_code
						  ,settle_amount_req
						  ,settle_amount_rsp
						  ,settle_tran_fee_req
						  ,settle_tran_fee_rsp
						  ,settle_currency_code
						  ,tran_reversed
						  ,prev_tran_approved
						  ,extended_tran_type
						  ,payee
						  ,online_system_id
						  ,receiving_inst_id_code
						  ,routing_type
						  ,source_node_name
						  ,pan
						  ,card_seq_nr
						  ,expiry_date
						  ,terminal_id
						  ,terminal_owner
						  ,card_acceptor_id_code
						  ,merchant_type
						  ,card_acceptor_name_loc
						  ,address_verification_data
						  ,totals_group
						  ,pan_encrypted
					  FROM post_tran_summary_'+CONVERT(varchar(10),DATEADD(DD,-1,GETDATE()),112)+' (NOLOCK)
		'')'
		
		print @sql_statement
		exec (@sql_statement)
				

		print('Creating view for post_tran_sstl_journal_summary')
		declare @table_part varchar(50)
		declare @table_date varchar(10)
		set @table_date = CONVERT(varchar(10),DATEADD(DD,-1,GETDATE()),112)
		declare @sql_view_str varchar(4000)
		
		declare @sstl_tbls table (sstl_tbl varchar(50))
			
		set @sql_view_str = 'ALTER VIEW post_tran_sstl_journal_summary as
			'
		declare cr cursor for select name from sys.objects 
		where name like 'sstl_journal_%' and ISNUMERIC(SUBSTRING(name,LEN('sstl_journal_')+1,LEN(name)-LEN('sstl_journal_')))=1
				
		open cr
		
		fetch next from cr into @table_part
		while @@FETCH_STATUS = 0
		begin
			
			insert into @sstl_tbls exec('
			IF EXISTS(SELECT TOP 1 * FROM '+@table_part+' (NOLOCK) where business_date = CONVERT(DATE,'''+@table_date+''') )
			BEGIN
				SELECT '''+@table_part+'''
			END')
			
			IF EXISTS(SELECT * FROM @sstl_tbls)
			BEGIN
				set @sql_view_str = @sql_view_str + 'SELECT NULL as adj_id, * FROM '+@table_part+ ' WITH (NOLOCK) UNION ALL 
				'
				DELETE FROM @sstl_tbls
			END
			fetch next from cr into @table_part
		end
		
		close cr
		deallocate cr
		
		set @sql_view_str = @sql_view_str + '
			SELECT
				adj_id,
				entry_id,
				config_set_id,
				session_id,
				post_tran_id,
				post_tran_cust_id,
				sdi_tran_id,
				acc_post_id,
				nt_fee_acc_post_id,
				coa_id,
				coa_se_id,
				se_id,
				amount,
				amount_id,
				amount_value_id,
				fee,
				fee_id,
				fee_value_id,
				nt_fee,
				nt_fee_id,
				nt_fee_value_id,
				debit_acc_nr_id,
				debit_acc_id,
				debit_cardholder_acc_id,
				debit_cardholder_acc_type,
				credit_acc_nr_id,
				credit_acc_id,
				credit_cardholder_acc_id,
				credit_cardholder_acc_type,
				business_date,
				granularity_element,
				tag,
				spay_session_id,
				spst_session_id
			FROM
				sstl_journal_adj  WITH (NOLOCK)'

		exec(@sql_view_str)
		
	-- Prep a temp table for late reversals
	-- these are usually small but we have linked this up with post_tran_summary with a join...which works faster than NOT IN
	-- its not the same if you use post_tran_ids cos this is ensuring that both the 0200 and the 0420 do not appear in the report
	-- must have been written by a wise person.
	SELECT tran_nr, retrieval_reference_nr
	INTO #tbl_late_reversals 
	FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @from_date
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
    
    --keep them indexed and agile, would be the join criteria. This process takes less than 10 secs
	CREATE  NONCLUSTERED INDEX ix_tbl_late_reversals_temp ON #tbl_late_reversals (
		tran_nr, retrieval_reference_nr
	)				         
	
	--this seems to mean exclude all NIBBs, shoprite and fidelity VISA POS acquired traffic
	--identifiers are same transaction deltails from indicated sources...we're most likely looping the same transaction.
	--in future, just make sure any exclusions are put in here 
	
	--also note we're selecting off post_tran_summary_settle view which is different from the summary view because it 
	--doesnt include structured data. this block takes about 1 minute to run...cool.
	
	create table #sstl_journal_summary
	(
		post_tran_id	bigint,
		post_tran_cust_id	bigint,
		debit_acc_nr_id		int,
		credit_acc_nr_id	int,
		amount				float,
		fee					float,
		business_date		datetime,
		config_set_id		int,
		coa_id				int,
		amount_id			int,
		fee_id				int
	)
	
	
	insert into #sstl_journal_summary
	select post_tran_id, 
			post_tran_cust_id, 
			debit_acc_nr_id, 
			credit_acc_nr_id, 
			amount, 
			fee, 
			business_date, 
			J.config_set_id,
			J.coa_id,
			J.amount_id,
			J.fee_id 
	from post_tran_sstl_journal_summary J (NOLOCK)
	
	LEFT OUTER JOIN dbo.sstl_se_amount_w AS Amount  (NOLOCK)
		--4.	OK
	ON (J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)
	LEFT OUTER JOIN dbo.sstl_se_fee_w AS Fee (NOLOCK)
		--5.	OK
	ON (J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id)
	LEFT OUTER JOIN dbo.sstl_coa_w AS Coa  (NOLOCK)
		--6.	OK
	ON (J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id)
	where 
	(J.Business_date >= @from_date AND J.Business_date< (@to_date))
	
	CREATE  NONCLUSTERED INDEX ix_temp_sstl_journal_summary_1 ON #sstl_journal_summary (
		business_date,
		config_set_id,
		debit_acc_nr_id,
		credit_acc_nr_id,
		post_tran_id,
		post_tran_cust_id
	)INCLUDE (amount,fee)
	/*
	CREATE  NONCLUSTERED INDEX ix_temp_sstl_journal_summary_2 ON #sstl_journal_summary (config_set_id)
	CREATE  NONCLUSTERED INDEX ix_temp_sstl_journal_summary_3 ON #sstl_journal_summary (post_tran_id)
	CREATE  NONCLUSTERED INDEX ix_temp_sstl_journal_summary_4 ON #sstl_journal_summary (post_tran_cust_id)
	CREATE  NONCLUSTERED INDEX ix_temp_sstl_journal_summary_5 ON #sstl_journal_summary (debit_acc_nr_id)
	CREATE  NONCLUSTERED INDEX ix_temp_sstl_journal_summary_6 ON #sstl_journal_summary (credit_acc_nr_id)
	*/
	
	select post_tran_id INTO  #temp_post_tran_exclusion
	from post_tran_summary_settle (nolock) 
	where source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc')
		and retrieval_reference_nr+'_'+
		system_trace_audit_nr+'_'+
		terminal_id+'_'+ 
		cast((CONVERT(NUMERIC (15,2),isnull(settle_amount_impact,0))) as VARCHAR(20))+'_'+
		message_type 
	in(  select retrieval_reference_nr+'_'+
			system_trace_audit_nr+'_'+
			terminal_id+'_'+ 
			cast((CONVERT(NUMERIC (15,2),isnull(settle_amount_impact,0))) as VARCHAR(20))+'_'+
			message_type as unique_key
		 from post_tran_summary_settle (nolock) 
		 where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')
	)
	 

	--also need an exclusion table for posttran ids that meet the following criteria
	-- CREATE TABLE #temp_post_tran_exclusion (post_tran_id bigint)
	CREATE  NONCLUSTERED INDEX ix_temp_post_tran_exclusion ON #temp_post_tran_exclusion (post_tran_id)	
	
 
	select retention_data, post_tran_cust_id, tran_nr, post_tran_id, tran_postilion_originated 
	into #post_tran_temp1
	from  post_tran_summary_settle (nolock)
	
	
	CREATE  NONCLUSTERED INDEX ix_post_tran_temp1_1 ON #post_tran_temp1 (
		tran_postilion_originated,
		post_tran_cust_id,
		tran_nr,
		post_tran_id
	) INCLUDE (retention_data)
	
	
	select
		sink_node_name, 
		message_type,
		tran_type,
		PTT.tran_nr,
		system_trace_audit_nr,
		retention_data,
		acquiring_inst_id_code,
		PTT.retrieval_reference_nr,
		settle_amount_impact,
		settle_currency_code,
		extended_tran_type,
		payee,
		source_node_name,
		pan,
		terminal_id,
		terminal_owner,
		card_acceptor_id_code,
		merchant_type,
		card_acceptor_name_loc,
		totals_group,
		PTT.post_tran_id,
		post_tran_cust_id
		
		INTO #post_tran_temp2
		
		from post_tran_summary_settle PTT (NOLOCK) 
		
		where (post_tran_id not in (select post_tran_id from #temp_post_tran_exclusion))
		and (CONVERT(varchar(50),tran_nr)+'_'+retrieval_reference_nr not in (select CONVERT(varchar(50),tran_nr)+'_'+retrieval_reference_nr from #tbl_late_reversals))
		/*
		left outer join #temp_post_tran_exclusion TBL
		on PTT.post_tran_id = TBL.post_tran_id
		
		left outer join #tbl_late_reversals TBL2
		on PTT.retrieval_reference_nr = TBL2.retrieval_reference_nr and PTT.tran_nr = TBL2.tran_nr
		*/
		
	  and 
      PTT.tran_postilion_originated = 0
     
      AND PTT.rsp_code_rsp in ('00','11','09')
      
      AND (
          (PTT.settle_amount_impact<> 0 and PTT.message_type   in ('0200','0220'))

       or ((PTT.settle_amount_impact<> 0 and PTT.message_type = '0420' 

       and dbo.fn_rpt_isPurchaseTrx_sett(PTT.tran_type, PTT.source_node_name, PTT.sink_node_name, PTT.terminal_id ,PTT.totals_group ,PTT.pan) <> 1 and PTT.tran_reversed <> 2)
       or (PTT.settle_amount_impact<> 0 and PTT.message_type = '0420' 
       and dbo.fn_rpt_isPurchaseTrx_sett(PTT.tran_type, PTT.source_node_name, PTT.sink_node_name, PTT.terminal_id ,PTT.totals_group ,PTT.pan) = 1 ))

       or (PTT.settle_amount_rsp<> 0 and PTT.message_type   in ('0200','0220') and PTT.tran_type = 40 and (SUBSTRING(PTT.Terminal_id,1,1) IN ('0','1') ))
       or (PTT.message_type = '0420' and PTT.tran_reversed <> 2 and PTT.tran_type = 40 and (SUBSTRING(PTT.Terminal_id,1,1)IN ( '0','1' ))))
      
      /* This block was the old way we tried to fetch from the tempdbs
      and 
	     (convert(varchar(50),PTT.tran_nr))+'_'+PTT.retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	  and post_tran_id not in (select post_tran_id from @temp_post_tran_exclusion)
	  */  
      --AND PTT.post_tran_cust_id >= @rpt_tran_id
      AND PTT.totals_group not in ('CUPGroup')
      and NOT (PTT.totals_group in ('VISAGroup') and PTT.acquiring_inst_id_code = '627787')
	  and NOT (PTT.totals_group in ('VISAGroup') and PTT.sink_node_name not in ('ASPPOSVINsnk')
	            and not (PTT.source_node_name = 'SWTFBPsrc' and PTT.sink_node_name = 'ASPPOSVISsnk') 
	           )
      AND
            LEFT( PTT.source_node_name,2 ) <> 'SB'
             AND
            LEFT( PTT.sink_node_name,2)<> 'SB'

      and (PTT.source_node_name not LIKE '%TPP%')
       and (PTT.sink_node_name  not LIKE '%TPP%')
       and not (PTT.source_node_name  = 'MEGATPPsrc' and PTT.tran_type = '00')
      --and source_node_name not in ('SWTWMASBsrc','SWTWEMSBsrc')
      and source_node_name <> 'SWTMEGADSsrc'
      and PTT.card_acceptor_id_code not in ('IPG000000000001')
      and PTT.sink_node_name not in ('WUESBPBsnk')

	OPTION(MAXDOP 16) 
	
	
	CREATE  NONCLUSTERED INDEX ix_post_tran_temp2_1 ON #post_tran_temp2 (
		merchant_type,
		tran_type,
		source_node_name
	)
	INCLUDE
	(	
		system_trace_audit_nr,
		retrieval_reference_nr,
		retention_data,
		pan,
		settle_amount_impact,
		settle_currency_code,
		card_acceptor_id_code,
		card_acceptor_name_loc
	)
	
	CREATE  NONCLUSTERED INDEX ix_post_tran_temp2_2 ON #post_tran_temp2 (
		sink_node_name, 
		message_type,
		acquiring_inst_id_code,
		extended_tran_type,
		payee,
		pan,
		terminal_id,
		terminal_owner,
		totals_group,
		card_acceptor_name_loc,
		settle_currency_code,
		system_trace_audit_nr,
		card_acceptor_id_code,
		settle_amount_impact
	)
	
	CREATE  NONCLUSTERED INDEX ix_post_tran_temp2_4 ON #post_tran_temp2 (
		retention_data
	)
	
	CREATE  NONCLUSTERED INDEX ix_post_tran_temp2_3 ON #post_tran_temp2 (
		tran_nr,
		retrieval_reference_nr,
		post_tran_id,
		post_tran_cust_id
	)
	-- like they'll give us 16 processors

	--we'll be inserting into temp table before grouping in the final select.
	--much cleaner to group here...
	 -- like they'll give us 16 processors

	--we'll be inserting into temp table before grouping in the final select.
	--much cleaner to group here...
	
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
		Acquirer                                VARCHAR (50),
		Issuer                                  VARCHAR (50)
	 )
		 
	/*					         
	CREATE  NONCLUSTERED INDEX ix_report_result_5 ON #report_result (
		bank_code
	)
	CREATE NONCLUSTERED INDEX ix_report_result_3 ON #report_result (
		Acquirer
	)
	CREATE NONCLUSTERED INDEX ix_report_result_4 ON #report_result (
		Issuer
	)*/
       
       
    --massive insert, case statements are not as expensive though...about the same time with and without ...about 2 hours   
    --placed a COLUMN comment just before each column
	INSERT INTO  #report_result
	SELECT		         
		bank_code = CASE 
		
	/*WHEN                    (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.pan) = '6'
                          AND PT.acquiring_inst_id_code = '627480'
                          and dbo.fn_rpt_terminal_type(PT.terminal_id) <>'3' 
                           THEN 'UBA'*/
                           
	/*WHEN                   (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.pan) = '6'
                          AND (PT.source_node_name = 'SWTASPUBAsrc' AND PT.sink_node_name = 'SWTWEBUBAsnk')
                          THEN 'UBA'*/
                          
                          
                          WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '29'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                            and  (DebitAccNr.acc_nr LIKE '%FEE_PAYABLE' or CreditAccNr.acc_nr LIKE '%FEE_PAYABLE')) THEN 'ISW' 
                              
                          
                          
WHEN                      (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.pan) = '6'
                          AND ((PT.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787') 
                                OR (PT.source_node_name = 'SWTFBPsrc' AND PT.sink_node_name = 'ASPPOSVISsnk' 
                                 AND PT.totals_group = 'VISAGroup')
                               )
                          THEN 'UBA'
                          
                          
WHEN                      (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.pan) = '6'
                          AND (PT.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code = '627787')
                          THEN 'UNK'
                          
                          --AND (PT.acquiring_inst_id_code <> '627480' or 
                          --(PT.acquiring_inst_id_code = '627480'
                          --and dbo.fn_rpt_terminal_type(PT.terminal_id) ='3'))
                           
                           
                           
 /* WHEN                     (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                           OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                           and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 1)
                          AND dbo.fn_rpt_CardGroup(PT.pan) = '6'
                          AND PT.acquiring_inst_id_code = '627480' 
                           THEN 'UBA' */
                           
 /*WHEN                      (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                           OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                           and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 1)
                          AND dbo.fn_rpt_CardGroup(PT.pan) = '6'
                          --AND PT.acquiring_inst_id_code <> '627480' 
                           THEN 'GTB'*/


WHEN PTT.Retention_data = '1046' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'UBN'
WHEN PTT.Retention_data in ('9130','8130') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ABS'
WHEN PTT.Retention_data in ('9044','8044') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ABP'
WHEN PTT.Retention_data in ('9023','8023')  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'CITI'
WHEN PTT.Retention_data in ('9050','8050') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'EBN'
WHEN PTT.Retention_data in ('9214','8214') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FCMB'
WHEN PTT.Retention_data in ('9070','8070','1100') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FBP'
WHEN PTT.Retention_data in ('9011','8011') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FBN'
WHEN PTT.Retention_data in ('9058','8058')  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'GTB'
WHEN PTT.Retention_data in ('9082','8082') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'KSB'
WHEN PTT.Retention_data in ('9076','8076') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SKYE'
WHEN PTT.Retention_data in ('9084','8084') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ENT'
WHEN PTT.Retention_data in ('9039','8039') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'IBTC'
WHEN PTT.Retention_data in ('9068','8068') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SCB'
WHEN PTT.Retention_data in ('9232','8232','1105') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SBP'
WHEN PTT.Retention_data in ('9032','8032')  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBN'
WHEN PTT.Retention_data in ('9033','8033')  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBA'
WHEN PTT.Retention_data in ('9215','8215')  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBP'
WHEN PTT.Retention_data in ('9035','8035') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'WEMA'
WHEN PTT.Retention_data in ('9057','8057') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ZIB'
WHEN PTT.Retention_data in ('9301','8301') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'JBP'
WHEN PTT.Retention_data in ('9030') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'HBC'                        
                          
			
			
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
WHEN (DebitAccNr.acc_nr LIKE 'NPR%' OR CreditAccNr.acc_nr LIKE 'NPR%') THEN 'NPR'
--WHEN (DebitAccNr.acc_nr LIKE 'NPM%' OR CreditAccNr.acc_nr LIKE 'NPM%') THEN 'NPM'
                         WHEN (DebitAccNr.acc_nr LIKE 'POS_FOODCONCEPT%' OR CreditAccNr.acc_nr LIKE 'POS_FOODCONCEPT%') THEN 'SCB'
			 WHEN ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) THEN 'ISW'
			
			 ELSE 'UNK'	
		
END,
	trxn_category=CASE WHEN (PT.tran_type ='01')  
							AND dbo.fn_rpt_CardGroup(PT.PAN) in ('1','4')
                           AND PT.source_node_name = 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE INTERNATIONAL)'
                           
                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='50'  then 'MASTERCARD LOCAL PROCESSING BILLING(PAYMENTS)'

                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='00' and PT.source_node_name = 'VTUsrc'  then 'MASTERCARD LOCAL PROCESSING BILLING(RECHARGE)'
                
                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='00' and PT.source_node_name <> 'VTUsrc'  and PT.sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PT.Terminal_id,1,1) in ('2','5','6')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(POS PURCHASE)'

                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='00' and PT.source_node_name <> 'VTUsrc'  and PT.sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PT.Terminal_id,1,1) in ('3')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(WEB PURCHASE)'

                            WHEN (PT.tran_type ='01'  AND (SUBSTRING(PT.Terminal_id,1,1)= '1' or SUBSTRING(PT.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PT.sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(pt.extended_tran_type) = 1 
                           THEN 'ATM WITHDRAWAL (Cardless:Paycode Verve Token)'
                           
                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PT.Terminal_id,1,1)= '1' or SUBSTRING(PT.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PT.sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(pt.extended_tran_type) = 2 
                           THEN 'ATM WITHDRAWAL (Cardless:Paycode Non-Verve Token)'
                           
                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PT.Terminal_id,1,1)= '1' or SUBSTRING(PT.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PT.sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(pt.extended_tran_type) = 3 
                           THEN 'ATM WITHDRAWAL (Cardless:Non-Card Generated)'

						   WHEN (PT.tran_type ='01'  AND (SUBSTRING(PT.Terminal_id,1,1)= '1' or SUBSTRING(PT.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr  LIKE '%ATM%ISO%' OR CreditAccNr.acc_nr LIKE '%ATM%ISO%')
                           AND PT.source_node_name <> 'SWTMEGAsrc'
                           AND PT.source_node_name <> 'ASPSPNOUsrc'                           
                           THEN 'ATM WITHDRAWAL (MASTERCARD ISO)'


                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PT.Terminal_id,1,1)= '1' or SUBSTRING(PT.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PT.source_node_name <> 'SWTMEGAsrc'
                           AND PT.source_node_name <> 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (REGULAR)'
                           
                                                                           
                           
                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PT.Terminal_id,1,1)= '1' or SUBSTRING(PT.Terminal_id,1,1)= '0')) 

                           and (DebitAccNr.acc_nr LIKE '%V%BILLING%' OR CreditAccNr.acc_nr LIKE '%V%BILLING%')
                           AND PT.source_node_name <> 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE BILLING)'

                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PT.Terminal_id,1,1)= '1' or SUBSTRING(PT.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PT.source_node_name = 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (SMARTPOINT)'
 
			               WHEN (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = '1' and 
                           (DebitAccNr.acc_nr like '%BILLPAYMENT MCARD%' or CreditAccNr.acc_nr like '%BILLPAYMENT MCARD%') ) then 'BILLPAYMENT MASTERCARD BILLING'

                           WHEN (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = '1' 
                           and (DebitAccNr.acc_nr like '%SVA_FEE_RECEIVABLE' or CreditAccNr.acc_nr like '%SVA_FEE_RECEIVABLE') ) 
                           AND dbo.fn_rpt_isBillpayment_IFIS(PT.terminal_id) = 1  then 'BILLPAYMENT IFIS REMITTANCE'
                          
			               WHEN (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = '1') then 'BILLPAYMENT'
			   
			
                           WHEN (PT.tran_type ='40'  AND (SUBSTRING(PT.Terminal_id,1,1)= '1' 

                           or SUBSTRING(PT.Terminal_id,1,1)= '0' or SUBSTRING(PT.Terminal_id,1,1)= '4')) THEN 'CARD HOLDER ACCOUNT TRANSFER'

                           WHEN dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           AND SUBSTRING(PT.Terminal_id,1,1)IN ('2','5','6')AND PT.sink_node_name = 'ESBCSOUTsnk' and dbo.fn_rpt_Cardless(pt.extended_tran_type) = 1 
                           THEN 'POS PURCHASE (Cardless:Paycode Verve Token)'
                           
                           WHEN dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           AND SUBSTRING(PT.Terminal_id,1,1)IN ('2','5','6')AND PT.sink_node_name = 'ESBCSOUTsnk' and dbo.fn_rpt_Cardless(pt.extended_tran_type) = 2 
                           THEN 'POS PURCHASE (Cardless:Paycode Non-Verve Token)'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '1'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                            and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                              or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(GENERAL MERCHANT)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '2'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(CHURCHES, FASTFOODS & NGOS)'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '3'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(CONCESSION)PURCHASE'

                           WHEN ( dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '4'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(TRAVEL AGENCIES)PURCHASE'
                           

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '5'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(HOTELS)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '6'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(WHOLESALE)PURCHASE'
                    
                            WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '14'
                            and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                            and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                            or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(WHOLESALE_ACQUIRER_BORNE)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '7'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(FUEL STATION)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '8'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(EASYFUEL)PURCHASE'

                           WHEN  (dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) ='1'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(GENERAL MERCHANT-VISA)PURCHASE'
                     
                           WHEN (dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) ='2'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(2% CATEGORY-VISA)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) ='3'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(3% CATEGORY-VISA)PURCHASE'
                           
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '29'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                            and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                              or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(VAS CLOSED SCHEME)PURCHASE'+'_'+PT.merchant_type
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '9'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '10'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(FLAT FEE OF N200)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '11'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(FLAT FEE OF N300)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '12'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(FLAT FEE OF N150)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '13'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(1.5% CAPPED AT N300)PURCHASE'
                       
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '15'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB COLLEGES ( 1.5% capped specially at 250)'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '16'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB (PROFESSIONAL SERVICES)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '17'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB (SECURITY BROKERS/DEALERS)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '18'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB (COMMUNICATION)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '19'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(FLAT FEE OF N400)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '20'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(FLAT FEE OF N250)PURCHASE'
                  
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '21'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(FLAT FEE OF N265)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '22'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(FLAT FEE OF N550)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '23'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'Verify card â€“ Ecash load'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '24'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(1% CAPPED AT 1,000 CATEGORY)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '25'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(0.75% CAPPED AT 2,000 CATEGORY)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '26'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(Verve_Payment_Gateway_0.9%)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '27'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(Verve_Payment_Gateway_1.25%)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '28'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(Verve_Add_Card)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1)
                           and SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6') 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')THEN 'POS(GENERAL MERCHANT)PURCHASE' 

                             WHEN (dbo.fn_rpt_MCC_cashback (PT.terminal_id, PT.tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1)
                           and SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6') 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')THEN 'POS PURCHASE WITH CASHBACK'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.terminal_id, PT.tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 2)
                           and SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6')
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'POS CASHWITHDRAWAL'

                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           and SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.terminal_id, PT.tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 and 

                           SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.terminal_id, PT.tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 2 and 

                           SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'


                           WHEN (pt.tran_type = '50' and 

                           SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'
                           
                           WHEN (pt.tran_type = '50' and 

                           SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'Fees collected for all PTSPs'


                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           and SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.terminal_id, PT.tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 and 

                           SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.terminal_id, PT.tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 2 and 

                           SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'



                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1)
                           and SUBSTRING(PT.Terminal_id,1,1)= '3' THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '313' 
                                 and (DebitAccNr.acc_nr LIKE '%fee%' OR CreditAccNr.acc_nr LIKE '%fee%')
                                 and (PT.tran_type in ('50') or(dbo.fn_rpt_autopay_intra_sett (PT.tran_type,PT.source_node_name,PT.payee) = 1))
                                 and not (DebitAccNr.acc_nr like '%PREPAIDLOAD%' or CreditAccNr.acc_nr like '%PREPAIDLOAD%')) THEN 'AUTOPAY TRANSFER FEES'
                          
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,

                                  PT.extended_tran_type ,PT.source_node_name) = '313' 
                                 and (DebitAccNr.acc_nr NOT LIKE '%fee%' OR CreditAccNr.acc_nr NOT LIKE '%fee%')

                                 and PT.tran_type in ('50')
                                 and not (DebitAccNr.acc_nr like '%PREPAIDLOAD%' or CreditAccNr.acc_nr like '%PREPAIDLOAD%')) THEN 'AUTOPAY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '1' and PT.tran_type = '50') THEN 'ATM TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '2' and PT.tran_type = '50') THEN 'POS TRANSFERS'
                           
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '4' and PT.tran_type = '50') THEN 'MOBILE TRANSFERS'

                          WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '35' and PT.tran_type = '50') then 'REMITA TRANSFERS'

       
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '31' and PT.tran_type = '50') then 'OTHER TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,

                                  PT.extended_tran_type ,PT.source_node_name) = '32' and PT.tran_type = '50') then 'RELATIONAL TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '33' and PT.tran_type = '50') then 'SEAMFIX TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '34' and PT.tran_type = '50') then 'VERVE INTL TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '36' and PT.tran_type = '50') then 'PREPAID CARD UNLOAD'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '37' and PT.tran_type = '50' ) then 'QUICKTELLER TRANSFERS(BANK BRANCH)'
 
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '38' and PT.tran_type = '50') then 'QUICKTELLER TRANSFERS(SVA)'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '39' and PT.tran_type = '50') then 'SOFTPAY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '310' and PT.tran_type = '50') then 'OANDO S&T TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '311' and PT.tran_type = '50') then 'UPPERLINK TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '312'  and PT.tran_type = '50') then 'QUICKTELLER WEB TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '314'  and PT.tran_type = '50') then 'QUICKTELLER MOBILE TRANSFERS'
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '315' and PT.tran_type = '50') then 'WESTERN UNION MONEY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '316' and PT.tran_type = '50') then 'OTHER TRANSFERS(NON GENERIC PLATFORM)'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 2)
                                 AND (DebitAccNr.acc_nr NOT LIKE '%AMOUNT%RECEIVABLE' AND CreditAccNr.acc_nr NOT LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 2)
                                 AND (DebitAccNr.acc_nr  LIKE '%AMOUNT%RECEIVABLE' or CreditAccNr.acc_nr  LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE DUE ISW'--the unk% is excempted from the bank's net
                           
                                                      
                          WHEN (dbo.fn_rpt_isCardload (PT.source_node_name ,PT.pan, PT.tran_type)= '1') then 'PREPAID CARDLOAD'

                          when pt.tran_type = '21' then 'DEPOSIT'

                           /*WHEN (SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN  (SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN  (SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%ISO_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%ISO_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'*/
                           
                          ELSE 'UNK'	
						END,
	--COLUMN
  Debit_account_type =
					CASE 
                      WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' 
                      AND (PT.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' 
                      AND (PT.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                          
                       WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' 
                      AND (PT.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'
                      
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
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '1')
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1')THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'


                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PT.TERMINAL_ID) = '2')
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '3') 

                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '4') 
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'
                           
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '5') 
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '6') 
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '7') 
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '8') 
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Debit_Nr)'
               
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PT.TERMINAL_ID) = '10') 
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '9'
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
	--COLUMN
	Credit_account_type=CASE                          
                      WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' 
                      AND (PT.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' 
                      AND (PT.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                      PT.acquiring_inst_id_code <> '627787')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' 
                      AND (PT.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                           PT.acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'
                                               
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
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '1') 

                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'


                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PT.TERMINAL_ID) = '2') 
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '3') 
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'


                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '4') 
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'
                           
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '5') 
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '6') 
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '7') 
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '8') 
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PT.TERMINAL_ID) = '10') 
                          and SUBSTRING(PT.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '9'
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
	--COLUMN
    trxn_amount=SUM(ISNULL(J.amount,0)), 
    --COLUMN
	trxn_fee=SUM(ISNULL(J.fee,0)), 
	--COLUMN
	trxn_date=j.business_date,
	--COLUMN
    currency = CASE WHEN (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = '1' and 
                       (DebitAccNr.acc_nr like '%BILLPAYMENT MCARD%' or CreditAccNr.acc_nr like '%BILLPAYMENT MCARD%') ) THEN '840'
                    WHEN ((DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%') and( PT.sink_node_name not in ('SWTFBPsnk','SWTABPsnk','SWTIBPsnk'))) THEN '840'
					WHEN ((DebitAccNr.acc_nr LIKE '%ATM%ISO%ISSUER%' OR CreditAccNr.acc_nr LIKE '%ATM%ISO%ISS%') and( PT.sink_node_name not in ('SWTFBPsnk','SWTABPsnk','SWTIBPsnk','SWTPLAsnk'))) THEN '840'
				    WHEN ((DebitAccNr.acc_nr LIKE '%ATM%ISO%ACQUIRER%' OR CreditAccNr.acc_nr LIKE '%ATM%ISO%ACQ%') ) THEN '840'
		   ELSE pt.settle_currency_code END,
	--COLUMN
    late_reversal = CASE
        
                        WHEN ( dbo.fn_rpt_late_reversal(pt.tran_nr,pt.message_type,pt.retrieval_reference_nr) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1)
                               and SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6')
                               and PT.merchant_type in ('5371','2501','2504','2505','2506','2507','2508','2509','2510','2511') THEN 0
                               
						WHEN ( dbo.fn_rpt_late_reversal(pt.tran_nr,pt.message_type,pt.retrieval_reference_nr) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1)
                               and SUBSTRING(PT.Terminal_id,1,1) in ( '2','5','6') THEN 1
						ELSE 0
					        END,
	--COLUMN
    card_type =  dbo.fn_rpt_CardGroup(PT.pan),
    --COLUMN
    terminal_type = dbo.fn_rpt_terminal_type(PT.terminal_id),    
     --source_node_name =   PT.source_node_name, -- not necessary
     --Unique_key = pt.retrieval_reference_nr+'_'+pt.system_trace_audit_nr+'_'+PT.terminal_id+'_'+ cast((CONVERT(NUMERIC (15,2),isnull(pt.settle_amount_impact,0))) as VARCHAR(20))+'_'+pt.message_type,
     --COLUMN
    Acquirer = (case when (not ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) )) then ''
                  when ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) AND (acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code) then acc.bank_code --or SUBSTRING(PT.terminal_id,2,3)= acc.cbn_code1 or SUBSTRING(PT.terminal_id,2,3)= acc.cbn_code2 or SUBSTRING(PT.terminal_id,2,3)= acc.cbn_code3 or SUBSTRING(PT.terminal_id,2,3) = acc.cbn_code4) THEN acc.bank_code
                  else PT.acquiring_inst_id_code END),
	--COLUMN
    Issuer = (case when (not ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) )) then ''
                  when ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) and (substring(PT.totals_group,1,3) = acc.bank_code1) then acc.bank_code
                  else substring(PT.totals_group,1,3) END)

	--INTO #report_result
	--FROM BLOCK----
	--equally as complex
	--from just the fields we need ein each table....cos the larger the joins, the more sluggish
	--1. 	From the view we created for yesterday's journal...select just these fields
	FROM  #sstl_journal_summary J 
	LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS DebitAccNr (NOLOCK)
		--2.	Get account details for debit side
	ON (J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)
	LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS CreditAccNr  (NOLOCK)
		--3.	Get account details for credit side
	ON (J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id)
	-- 7.  creating an inline table with just the required fields from post_tran_summary_settle
	--	must be right join to factor all post_tran_data
	RIGHT OUTER JOIN #post_tran_temp2 PT	-- ends the inline table definition. 
	ON (J.post_tran_id = PT.post_tran_id AND J.post_tran_cust_id = PT.post_tran_cust_id)
		--RIGHT OUTER JOIN #post_tran_cust_temp AS PTC (NOLOCK)  -- not needed since summary has the data
		--ON (J.post_tran_cust_id = PT.post_tran_cust_id AND J.post_tran_cust_id = PT.post_tran_cust_id)
	left join #post_tran_temp1 ptt 
		-- another table. retention data is only in the leg sent by TM
	on (pt.post_tran_cust_id = ptt.post_tran_cust_id and ptt.tran_postilion_originated = 1  and pt.tran_nr = ptt.tran_nr)
		LEFT OUTER JOIN aid_cbn_code acc ON
	(acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code)

		--END FROM --
WHERE 
      (J.Business_date >= @from_date AND J.Business_date< (@to_date))

      AND not (PT.merchant_type in ('4004','4722') and pt.tran_type = '00' and PT.source_node_name not in ('VTUsrc','CCLOADsrc') and  abs(pt.settle_amount_impact/100)< 200
       and not (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%'))
GROUP BY
 j.business_date,
 DebitAccNr.acc_nr,
 CreditAccNr.acc_nr,
 PT.tran_type,
 dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type),
 dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN),pt.acquiring_inst_id_code,

 PT.totals_group, SUBSTRING(PT.Terminal_id,1,1),
 dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan),
dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan),
dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name),
dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan),
dbo.fn_rpt_isCardload (PT.source_node_name ,PT.pan, PT.tran_type),
dbo.fn_rpt_CardType (PT.pan ,PT.sink_node_name ,PT.tran_type,PT.TERMINAL_ID),
dbo.fn_rpt_autopay_intra_sett (PT.tran_type,PT.source_node_name,PT.payee),
PTT.Retention_data,
pt.settle_currency_code,
PT.source_node_name,
PT.sink_node_name,
dbo.fn_rpt_late_reversal(pt.tran_nr,pt.message_type,pt.retrieval_reference_nr),
dbo.fn_rpt_CardGroup(PT.pan), dbo.fn_rpt_terminal_type(PT.terminal_id),
pt.retrieval_reference_nr+'_'+pt.system_trace_audit_nr+'_'+PT.terminal_id+'_'+ cast((CONVERT(NUMERIC (15,2),isnull(pt.settle_amount_impact,0))) as VARCHAR(20))+'_'+pt.message_type,
dbo.fn_rpt_MCC_cashback (PT.terminal_id, PT.tran_type),
(case when (not ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) )) then ''
                      when ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) AND (acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code) then acc.bank_code --or SUBSTRING(PT.terminal_id,2,3)= acc.cbn_code1 or SUBSTRING(PT.terminal_id,2,3)= acc.cbn_code2 or SUBSTRING(PT.terminal_id,2,3)= acc.cbn_code3 or SUBSTRING(PT.terminal_id,2,3) = acc.cbn_code4) THEN acc.bank_code
                      else PT.acquiring_inst_id_code END),
(case when (not ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) )) then ''
                      when ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) and (substring(PT.totals_group,1,3) = acc.bank_code1) then acc.bank_code1
                      else substring(PT.totals_group,1,3) END),
acc.bank_code1, acc.bank_code, PT.acquiring_inst_id_code,pt.extended_tran_type,PT.merchant_type, dbo.fn_rpt_isBillpayment_IFIS(PT.terminal_id)

		-- just the ones we couldnt perform in-line
	OPTION(RECOMPILE)
	
	insert into settlement_summary_breakdown_optimized
	(bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_amount,trxn_fee,trxn_date, Currency,late_reversal,card_type,terminal_type, Acquirer, Issuer)
	
	SELECT 
		bank_code,trxn_category,Debit_Account_type,Credit_Account_type,sum(trxn_amount),sum(trxn_fee),trxn_date, Currency,late_reversal,card_type,terminal_type, Acquirer, Issuer 
	FROM #report_result
		GROUP BY bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_date,Currency,late_reversal,card_type,terminal_type,Acquirer,Issuer
		
	OPTION ( MAXDOP 16)  
END 

GO


USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[norm_post_tran_sstl_journal_summary]    Script Date: 07/04/2016 11:05:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[norm_post_tran_sstl_journal_summary]
			@date	char(8)
as
begin
	createtable:
	declare @date_specified BIT
	set @date_specified = 1

	if(@date is null)
	begin
		set @date_specified  = 0
		set @date = CONVERT(varchar(10),dateadd(dd,-1,getdate()),112)
	end
	if not exists (select top 1 name from sys.objects where name like 'post_tran_sstl_journal_summary_'+@date  and type = 'U' )
	begin
		print 'creating new post_tran_sstl_journal_summary partition'
		
		declare @sql_statement varchar(8000)
		set @sql_statement = '
		
		declare @completed_table varchar (50)
		set @completed_table = (select top 1 name from sys.objects where name like ''post_tran_sstl_journal_summary_%'' and type = ''U'' order by name desc)
		declare @view_created BIT
		set @view_created = 0
		declare @action VARCHAR(10)
		
		if @completed_table is not null
		begin
			print ''previous completed table: ''+@completed_table
			print ''updating view.....''
			set @view_created = 1
			if not exists (select top 1 * from sys.objects where name = ''post_tran_sstl_journal_summary'' and type =''V'')
			begin
				set @action = ''CREATE''
			end
			else
			begin
				set @action = ''ALTER''
			end
			
				exec(@action+'' VIEW dbo.post_tran_sstl_journal_summary
				as
					SELECT [entry_id]
					  ,[config_set_id]
					  ,[session_id]
					  ,[post_tran_id]
					  ,[post_tran_cust_id]
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
					  ,[spst_session_id]
					  
					  FROM ''+@completed_table+''  (NOLOCK)'')
		end
		else
		begin
			set @view_created = 0
		end
		
		print ''creating table post_tran_sstl_journal_summary_'+@date+'''
		CREATE TABLE dbo.post_tran_sstl_journal_summary_20160703'+@date+'
		(
			[entry_id] [bigint] NOT NULL,
			[config_set_id] [int] NOT NULL,
			[session_id] [int] NOT NULL,
			[post_tran_id] [bigint] NULL,
			[post_tran_cust_id] [bigint] NULL,
			[sdi_tran_id] [bigint] NULL,
			[acc_post_id] [int] NULL,
			[nt_fee_acc_post_id] [int] NULL,
			[coa_id] [int] NOT NULL,
			[coa_se_id] [int] NOT NULL,
			[se_id] [int] NOT NULL,
			[amount] [float] NULL,
			[amount_id] [int] NULL,
			[amount_value_id] [int] NULL,
			[fee] [float] NULL,
			[fee_id] [int] NULL,
			[fee_value_id] [int] NULL,
			[nt_fee] [float] NULL,
			[nt_fee_id] [int] NULL,
			[nt_fee_value_id] [int] NULL,
			[debit_acc_nr_id] [int] NULL,
			[debit_acc_id] [int] NULL,
			[debit_cardholder_acc_id] [varchar](28) NULL,
			[debit_cardholder_acc_type] [char](2) NULL,
			[credit_acc_nr_id] [int] NULL,
			[credit_acc_id] [int] NULL,
			[credit_cardholder_acc_id] [varchar](28) NULL,
			[credit_cardholder_acc_type] [char](2) NULL,
			[business_date] [datetime] NOT NULL,
			[granularity_element] [varchar](100) NULL,
			[tag] [varchar](4000) NULL,
			[spay_session_id] [int] NULL,
			[spst_session_id] [int] NULL
		)
		
		if(@view_created = 0)
		begin
			print ''setting view to new post_tran_sstl_journal_summary partition''
			declare @action_2 varchar(10)
			if not exists (select top 1 * from sys.objects where name = ''post_tran_sstl_journal_summary'' and type =''V'')
			begin
				set @action_2 = ''CREATE''
			end
			else
			begin
				set @action_2 = ''ALTER''
			end
				exec(@action_2+'' VIEW dbo.post_tran_sstl_journal_summary
				AS
					SELECT [entry_id]
					  ,[config_set_id]
					  ,[session_id]
					  ,[post_tran_id]
					  ,[post_tran_cust_id]
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
					  ,[spst_session_id]
					  
					  FROM post_tran_sstl_journal_summary_'+@date+' (NOLOCK)'')
		end'
		
		print @sql_statement
		exec (@sql_statement)
		
		exec('		
		if not exists (select top 1 * from sys.objects where name = ''post_tran_sstl_journal_summary_shadow'' and type =''V'')
		begin
			exec(''CREATE VIEW dbo.post_tran_sstl_journal_summary_shadow
			AS
				select  * from post_tran_sstl_journal_summary_'+@date+''')
		end
		else
		begin
			exec(''ALTER VIEW dbo.post_tran_sstl_journal_summary_shadow
			as
				select  * from post_tran_sstl_journal_summary_'+@date+''')
		end
		')
		
		--print @sql_statement
		--exec (@sql_statement)
	end
	declare @current_table varchar(50)
	declare @table_date char(8)
	if(@date_specified = 1)
	begin
		set @current_table = 'post_tran_sstl_journal_summary_'+@date
	end
	else
	begin
		set @current_table = (select top 1 name from sys.objects where name like 'post_tran_sstl_journal_summary_%' and type = 'U' order by name desc)
	end
		
	set @table_date = SUBSTRING(@current_table,32,8)
	
	declare @last_entry_id bigint
	if exists (select top 1 entry_id from post_tran_sstl_journal_summary_shadow (nolock))
	begin
		select @last_entry_id = (select MAX(entry_id) from post_tran_sstl_journal_summary_shadow (nolock))
	end
	else
	begin
		set @last_entry_id =0
	end
	
	--if(@last_entry_id =0)
	--begin
		--select @last_entry_id = min(post_tran_id) from post_tran (nolock) where CONVERT(char(8),recon_business_date,112) = @table_date
	--end
	
	declare @closed_session_id bigint
	set @closed_session_id = (select top 1 session_id from sstl_session (nolock) where completed =1 order by session_id desc)
	
	print 'copying data ' ---+ cast(@last_entry_id as varchar(16))
	INSERT INTO post_tran_sstl_journal_summary_shadow
					SELECT [entry_id]
					  ,[config_set_id]
					  ,[session_id]
					  ,[post_tran_id]
					  ,[post_tran_cust_id]
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
					  ,[spst_session_id]
			
			FROM	sstl_journal_custom (NOLOCK) 
			where
				entry_id >@last_entry_id
				and session_id <= @closed_session_id
				and business_date = CONVERT(DATE,@table_date)
			order by entry_id
	
	if @@ROWCOUNT =0 -- nothing copied
	BEGIN
		print 'Nothing copied'
		if(@table_date = CONVERT(varchar(8),getdate(),112) OR @date_specified = 1) -- today
		begin
			print 'Either a date was specified for which there is no data or no additional data has been normalized'
			RETURN
		end
		/*checking whether settlement has cut over */
		
		DECLARE @norm_cutover INT;
		declare @today varchar(8)
		set @today = CONVERT(varchar(8),getdate(),112)
		set @norm_cutover = 0
		declare @proceed_tbl table (proceed BIT)
		insert into @proceed_tbl exec('
		if not exists (select name from sys.objects where name = ''post_tran_summary'+@today+'''  and type = ''U'')
		begin
			SELECT 0
		end
		else
		begin
			IF EXISTS(SELECT TOP 1 * FROM sstl_journal_custom WHERE post_tran_id in (select MAX(post_tran_id) from post_tran_summary'+@table_date+' (NOLOCK)))
			BEGIN
				SELECT 1
			END
			ELSE
			BEGIN
				SELECT 0
			END
		end')
			
		if(1 = (select top 1 * from @proceed_tbl))
		begin
			set @norm_cutover =1 
		end
		
		--EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
		
		if(CAST((CONVERT(varchar(8),getdate(),112)) as int) > cast (@table_date as int)) -- today > last table date & cant copy any more data
		begin
			print 'Its next day...'
			if(@norm_cutover=0) begin print '...but normalization has not caught up' RETURN end  -- wait for normalization to cut-over
			else -- normalization has cut-over to a new date, create new table and start copying again...
			begin
				-- check that the last closed batch is greater than the max post_tran_id from that recon_biz_date
				declare @max_session_id bigint
				set @max_session_id = (select MAX(session_id) from sstl_journal_custom (nolock) where business_date = CONVERT(DATE,@table_date))
				if(@closed_session_id < @max_session_id)
				begin
					-- CHECK AGAIN
					RETURN
				end
				print 'Lets check to see if we missed out any other transactions before cutting over. Querying...'
					INSERT INTO post_tran_sstl_journal_summary_shadow
					SELECT [entry_id]
					  ,[config_set_id]
					  ,[session_id]
					  ,[post_tran_id]
					  ,[post_tran_cust_id]
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
					  ,[spst_session_id]
			
			FROM	sstl_journal_custom (NOLOCK) 
				where business_date = CONVERT(DATE,@table_date)
				and session_id < @closed_session_id
				and post_tran_id not in (select post_tran_id from dbo.post_tran_sstl_journal_summary_shadow (nolock))
				
				print 'Done!'
				print 'Cutting over to next business day then...'
				--create indexes on current table with @table_date 
				
				declare @old_data datetime
				set @old_data = DATEADD(dd,-2,CONVERT(DATE,@table_date))
				declare @old_data_timestamp  char(8)
				set @old_data_timestamp = CONVERT(char(8),@old_data,112)
				
				print 'Housekeeping: deleting old table post_tran_sstl_journal_summary_'+@old_data_timestamp
				exec ('
					if exists (select top 1 * from sys.objects where name = ''post_tran_sstl_journal_summary_'+@old_data_timestamp+''' and type =''U'')
					begin
						drop table post_tran_sstl_journal_summary_'+@old_data_timestamp+'
					end
				')
				
				print('Creating view for sstl_journal_custom')
				declare @table_part varchar(50)
				declare @sql_view_str varchar(4000)
				
				declare @sstl_tbls table (sstl_tbl varchar(50))
					
				set @sql_view_str = 'ALTER VIEW sstl_journal_custom as
					'
				declare cr cursor for select name from sys.objects 
				where name like 'sstl_journal_%' and ISNUMERIC(SUBSTRING(name,LEN('sstl_journal_')+1,LEN(name)-LEN('sstl_journal_')))=1
						
				open cr
				
				fetch next from cr into @table_part
				while @@FETCH_STATUS = 0
				begin
					
					insert into @sstl_tbls exec('
					IF EXISTS(SELECT TOP 1 * FROM '+@table_part+' (NOLOCK) where business_date = CONVERT(DATE,'''+@table_date+''') )
					BEGIN
						SELECT '''+@table_part+'''
					END')
					
					IF EXISTS(SELECT * FROM @sstl_tbls)
					BEGIN
						set @sql_view_str = @sql_view_str + 'SELECT NULL as adj_id, * FROM '+@table_part+ ' WITH (NOLOCK) UNION ALL 
						'
						DELETE FROM @sstl_tbls
					END
					fetch next from cr into @table_part
				end
				
				close cr
				deallocate cr
				
				set @sql_view_str = @sql_view_str + '
					SELECT
						adj_id,
						entry_id,
						config_set_id,
						session_id,
						post_tran_id,
						post_tran_cust_id,
						sdi_tran_id,
						acc_post_id,
						nt_fee_acc_post_id,
						coa_id,
						coa_se_id,
						se_id,
						amount,
						amount_id,
						amount_value_id,
						fee,
						fee_id,
						fee_value_id,
						nt_fee,
						nt_fee_id,
						nt_fee_value_id,
						debit_acc_nr_id,
						debit_acc_id,
						debit_cardholder_acc_id,
						debit_cardholder_acc_type,
						credit_acc_nr_id,
						credit_acc_id,
						credit_cardholder_acc_id,
						credit_cardholder_acc_type,
						business_date,
						granularity_element,
						tag,
						spay_session_id,
						spst_session_id
					FROM
						sstl_journal_adj  WITH (NOLOCK)'
	
				exec(@sql_view_str)
				
				print 'Creating indexes on last table...post_tran_sstl_journal_summary_'+@table_date
				exec (
				' 
					CREATE NONCLUSTERED INDEX [ix_sstl_journal_'+@table_date+'_1] ON post_tran_sstl_journal_summary_'+@table_date+' 
					(
						[business_date] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_sstl_journal_'+@table_date+'_10] ON post_tran_sstl_journal_summary_'+@table_date+' 
					(
						[spst_session_id] ASC,
						[config_set_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
					GO


					CREATE NONCLUSTERED INDEX [ix_sstl_journal_'+@table_date+'_11] ON post_tran_sstl_journal_summary_'+@table_date+' 
					(
						[spay_session_id] ASC,
						[config_set_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
					GO


					CREATE NONCLUSTERED INDEX [ix_sstl_journal_'+@table_date+'_2] ON post_tran_sstl_journal_summary_'+@table_date+' 
					(
						[session_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_sstl_journal_'+@table_date+'_3] ON post_tran_sstl_journal_summary_'+@table_date+' 
					(
						[post_tran_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_sstl_journal_'+@table_date+'_4] ON post_tran_sstl_journal_summary_'+@table_date+' 
					(
						[sdi_tran_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_sstl_journal_'+@table_date+'_5] ON post_tran_sstl_journal_summary_'+@table_date+' 
					(
						[amount_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_sstl_journal_'+@table_date+'_6] ON post_tran_sstl_journal_summary_'+@table_date+' 
					(
						[fee_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_sstl_journal_'+@table_date+'_7] ON post_tran_sstl_journal_summary_'+@table_date+' 
					(
						[nt_fee_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_sstl_journal_'+@table_date+'_8] ON post_tran_sstl_journal_summary_'+@table_date+' 
					(
						[coa_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
					GO

					CREATE NONCLUSTERED INDEX [ix_sstl_journal_'+@table_date+'_9] ON post_tran_sstl_journal_summary_'+@table_date+' 
					(
						[se_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
					GO

					ALTER TABLE post_tran_sstl_journal_summary_'+@table_date+' ADD  CONSTRAINT [pk_sstl_journal_'+@table_date+'] PRIMARY KEY CLUSTERED 
					(
						[entry_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
					GO
				'
				)
				set @date = CONVERT(varchar(8),getdate(),112)
				goto createtable
			end
		END
	END

end
