USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_0100_no_0220]    Script Date: 05/17/2016 16:30:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










ALTER PROCEDURE [dbo].[osp_rpt_0100_no_0220]

@Start_Date  Varchar(10),
@Sink_Node   Varchar(14),
@message_type Varchar(4),
@Days		Numeric

AS 
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
set NOCOUNT ON

CREATE TABLE #summary
(post_tran_cust_id CHAR(16), tran_count NUMERIC)

IF (@Start_Date IS NULL or Len(@Start_Date)=0) 



SET @Start_Date = CONVERT(VARCHAR(30),(DATEADD (dd, -1, GetDate())), 112)

DECLARE @report_date_start DATETIME;
DECLARE @report_date_end   DATETIME;

SET @report_date_start = CONVERT(Varchar(30), (DATEADD (DAY, -@Days,GETDATE())), 112)
SET @report_date_end = @Start_Date

INSERT INTO #summary

select post_tran_cust_id as post_tran_cust_id, count (*) from post_tran_summary (NOLOCK) as tran_count
where message_type in ('0100','0220')
and post_tran_cust_id in (select distinct post_tran_cust_id from post_tran_summary (NOLOCK) where message_type = @message_type 
AND
recon_business_date >=@report_date_start AND  recon_business_date <=@report_date_end
AND
 sink_node_name = @Sink_Node
and tran_type = '00'
and rsp_code_rsp = '00'
and tran_reversed = 0)

and post_tran_cust_id not in (select post_tran_cust_id from post_tran_summary (NOLOCK) where message_type = '0220' and rsp_code_req != '00' 
and sink_node_name = 'MEGAPRUsnk'
)

group by post_tran_cust_id


select 
       pt.message_type as message_type,
       pt.terminal_id as terminal_id,
system_trace_audit_nr as stan,
  pt.card_acceptor_id_code as card_acceptor_id,
pt.card_acceptor_name_loc as card_acceptor_name_loc,
       
	 dbo.DecryptPan(pan,pan_encrypted,'cardstatement') as pan,
	pt.from_account_id as account_number,
	dbo.formatTranTypeStr(pt.tran_type, pt.extended_tran_type, pt.message_type) AS tran_type_description,
       pt.tran_amount_req/100 as tran_amount,
       dbo.currencyAlphaCode(pt.tran_currency_code) as tran_currency,
       pt.settle_amount_req/100 as settle_amount,
	dbo.currencyAlphaCode(pt.settle_currency_code) as settle_currency,
       pt.datetime_req as date_time,
      pt.auth_id_rsp,
	pt.retrieval_reference_nr,
      
       pt.post_tran_cust_id as tran_id

from post_tran_summary pt (NOLOCK)
join #summary s (nolock)
on s.post_tran_cust_id = pt.post_tran_cust_id
where s.tran_count < 3
and pt.tran_postilion_originated=0
and message_type = @message_type
order by pt.datetime_req
OPTION (RECOMPILE)

END



















GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_0100_no_0220_1]    Script Date: 05/17/2016 16:30:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






ALTER PROCEDURE [dbo].[osp_rpt_0100_no_0220_1]

@Start_Date  Varchar(10),
@Sink_Node   Varchar(14),
@message_type Varchar(4),
@Days		Numeric

AS 
BEGIN
set NOCOUNT ON

CREATE TABLE #summary
(post_tran_cust_id CHAR(16), tran_count NUMERIC)

IF (@Start_Date IS NULL or Len(@Start_Date)=0) 



SET @Start_Date = CONVERT(CHAR(8),(DATEADD (dd, -(@Days+1), GetDate())), 112)


INSERT INTO #summary

select post_tran_cust_id as post_tran_cust_id, count (*) from post_tran_summary (NOLOCK) as tran_count
where message_type in ('0100','0220')
and post_tran_cust_id in (select distinct post_tran_cust_id from post_tran_summary (NOLOCK) where message_type = @message_type 
and datetime_req >= @Start_Date--(SELECT CONVERT(char(8), (DATEADD (DAY, -32,GETDATE())), 112))
and datetime_req < (SELECT CONVERT(char(8), (DATEADD (DAY, -@Days,GETDATE())), 112))
and sink_node_name = @Sink_Node
and tran_type = '00'
and rsp_code_rsp = '00'
and tran_reversed = 0)

and post_tran_cust_id not in (select post_tran_cust_id from post_tran_summary (NOLOCK) where message_type = '0220' and rsp_code_req != '00' and sink_node_name = 'MEGAPRUsnk')



group by post_tran_cust_id


select 
       pt.message_type as message_type,
       pt.terminal_id as terminal_id,
system_trace_audit_nr as stan,
  pt.card_acceptor_id_code as card_acceptor_id,
pt.card_acceptor_name_loc as card_acceptor_name_loc,
       
	dbo.DecryptPan(pan,pan_encrypted,'cardstatement') as pan,
	pt.from_account_id as account_number,
	dbo.formatTranTypeStr(pt.tran_type, pt.extended_tran_type, pt.message_type) AS tran_type_description,
       pt.tran_amount_req/100 as tran_amount,
       dbo.currencyAlphaCode(pt.tran_currency_code) as tran_currency,
       pt.settle_amount_req/100 as settle_amount,
	dbo.currencyAlphaCode(pt.settle_currency_code) as settle_currency,
       pt.datetime_req as date_time,
      pt.auth_id_rsp,
	pt.retrieval_reference_nr,
      
       pt.post_tran_cust_id as tran_id

from post_tran_summary (NOLOCK) pt (nolock)
join #summary s (nolock)
on s.post_tran_cust_id = ptc.post_tran_cust_id

where s.tran_count < 3
and pt.tran_postilion_originated=0
and message_type = @message_type
order by pt.datetime_req


END














GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b01_1]    Script Date: 05/17/2016 16:30:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b01_1]
	@StartDate		CHAR(8),			-- yyyymmdd
	@EndDate			CHAR(8),			-- yyyymmdd
	@SinkNodes		VARCHAR(255),	-- This should be the host where OnUs transactions are routed to, Separated by commas
	@SourceNodes	VARCHAR(255)	-- Separated by commas
AS
BEGIN
	CREATE TABLE #report_result
	(
		Warning 							VARCHAR (255),
		StartDate 						DATETIME,   									
		EndDate							DATETIME,   									
		SourceNodeList					VARCHAR (255),
		SinkNode							VARCHAR (30),
		TranType							CHAR (2),   									
		NrTrans							INT,        									
		TermID							CHAR (8),   									
		CaNameLoc						CHAR (40),  									
		BatchNr							INT,        									
		BatchEndDate					DATETIME,
		SettleCurrency					CHAR (3),
		SinkNodeAlias					VARCHAR (255),
		TransactionAmount				FLOAT,
		SurchargeAmount				FLOAT,
		CurrencyAlphaCode				CHAR (3),
		CurrencyNrDecimals			INT,
		isEnvelopeDeposit				INT,
		isCashDepositBNA				INT,
		isElectronicCheckDeposit	INT
	)
	
	DECLARE @warning 			VARCHAR (255)
	
	IF (@SourceNodes IS NULL OR @SinkNodes IS NULL or Len(@SourceNodes)=0 or Len(@SinkNodes)=0)
	BEGIN
		SET @warning = 'Please supply all the parameters. (Host and ATM Driving nodes)'

		INSERT INTO  #report_result(Warning) VALUES (@warning)		
		
		SELECT * from #report_result
		
		RETURN 1
	END
	
	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next	DATETIME
	DECLARE @node_name_list 		VARCHAR(255)
	DECLARE @node_list				VARCHAR(255)
	DECLARE @date_selection_mode	VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SourceNodes
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT
	
	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes 
	(
		source_node			VARCHAR(30)
	)
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
		
	CREATE TABLE #list_of_sink_nodes 
	(
		sink_node			VARCHAR(30)
	) 
		
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes
	
	-- The main report query
	INSERT INTO 	
		#report_result
	
	SELECT	
		NULL 								AS Warning, 
		@report_date_start 			AS StartDate,  
		@report_date_end 				AS EndDate, 
		@SourceNodes 					AS SourceNodeList,
		t.sink_node_name 				AS SinkNode, 
		t.tran_type 					AS TranType, 
		SUM(t.nr_trans) 				AS NrTrans, 
		t.terminal_id 					AS TermID,
		t.card_acceptor_name_loc 	AS CaNameLoc, 
		t.batch_nr 						AS BatchNr, 
		b.datetime_end 				AS BatchEndDate, 
		t.settle_amount_currency 	AS SettleCurrency, 
		
		SinkNodeAlias = 
			(
				CASE 
					WHEN t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes) THEN '-Our Cardholders-'
					ELSE '-Foreign Cardholders-'
				END
			),

		dbo.formatAmount
			( 
				SUM
				(
					CASE
						-- The settle_amount_impact field will typically be negative for Debit transaction types, but we want to display those amount as positive on this report
						WHEN (cast(t.tran_type as INT) between 0 and 19 or cast(t.tran_type as INT) between 50 and 59) THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
				), t.settle_amount_currency
			) AS TransactionAmount,

		dbo.formatAmount
			(
				SUM
				(
					-1 * t.surcharge_amount_impact
				), t.settle_amount_currency
			) AS SurchargeAmount,
		dbo.currencyAlphaCode(t.settle_amount_currency) 								AS CurrencyAlphaCode, 
		dbo.currencyNrDecimals(t.settle_amount_currency)								AS CurrencyNrDecimals,
		dbo.fn_rpt_isEnvelopeDeposit(t.tran_type, t.extended_tran_type)			AS isEnvelopeDeposit,
		dbo.fn_rpt_isCashDepositBNA(t.tran_type, t.extended_tran_type) 			AS isCashDepositBNA,
		dbo.fn_rpt_isElectronicCheckDeposit(t.tran_type, t.extended_tran_type)	AS isElectronicCheckDeposit
	FROM
		post_ds_terminals t WITH (NOLOCK)
		LEFT JOIN 
		post_batch b WITH (NOLOCK) 
			ON (
					t.batch_nr = b.batch_nr 
					AND 
					t.settle_entity_id = b.settle_entity_id
				)
	WHERE 
		(t.recon_business_date >= @report_date_start) 
		AND 
		(t.recon_business_date <= @report_date_end) 
		AND 
		dbo.fn_rpt_isApprovedTrx(t.rsp_code) = 1
		AND 
		t.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
		AND 
		(
			t.message_type IN ('0200','0220') 
			OR 
			(
				-- We do not want Reversals that do not have any financial impact
				t.message_type IN ('0400', '0420') 
				AND 
				(
					t.settle_amount_impact <> 0 
					OR 
					t.surcharge_amount_impact <> 0
				)
			)
			
		)
		AND
		dbo.fn_rpt_isAutomatedDeposit(t.tran_type, t.extended_tran_type) = 1	
	GROUP BY 
		t.sink_node_name, 
		t.tran_type, 
		t.extended_tran_type, 
		t.terminal_id, 
		t.card_acceptor_name_loc, 
		t.batch_nr, 
		b.datetime_end, 
		t.settle_amount_currency
	ORDER BY 
		t.terminal_id, 
		t.batch_nr
				
		
	IF @@ROWCOUNT = 0
		INSERT 
				INTO  #report_result (Warning, StartDate, EndDate) 
		VALUES 
				('No transactions.', @report_date_start, @report_date_end )
	
	SELECT * from #report_result
				
END

GRANT EXECUTE ON osp_rpt_b01_1 TO postilion, postcfg, postmon


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b01_1_exc]    Script Date: 05/17/2016 16:30:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b01_1_exc]
	@report_date_start		DATETIME,
	@report_date_end			DATETIME,
	@SourceNodes				VARCHAR(255)
AS
BEGIN
	CREATE TABLE #report_result
	(
		NrAborted			INT, 
		NrStandInApproved	INT,
		NrStandInDeclined	INT
	)
	
	-- We do not have to validate the parameter, because this proc will be called from a subreport and the paramaeters have
	--	already been validated by the stored proc of the main report.
	DECLARE @nr_aborted 					INT
	DECLARE @nr_stand_in_approved		INT
	DECLARE @nr_stand_in_declined		INT
	DECLARE @node_list					VARCHAR(255)

	CREATE TABLE #list_of_source_nodes 
	(
		source_node VARCHAR(30)
	) 	
	
	INSERT INTO #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	SET @nr_aborted = 0		-- We should not have any aborted transactions on the source node leg

	SELECT	
		@nr_stand_in_approved = SUM(nr_trans)
	FROM
		post_ds_terminals WITH (NOLOCK)
	WHERE 
		recon_business_date >= @report_date_start 
		AND 
		recon_business_date <= @report_date_end
		AND 
		source_node_name IN (SELECT source_node FROM #list_of_source_nodes) 
		AND 
		postilion_stand_in = 1
		AND 
		message_type IN ('0200')
		AND 
		rsp_code IN ('00','08', '10', '11', '16') 
		AND
		dbo.fn_rpt_isAutomatedDeposit(tran_type, extended_tran_type) = 1

	IF (@@ROWCOUNT = 0 OR @nr_stand_in_approved IS NULL)
	BEGIN
		SELECT @nr_stand_in_approved = 0
	END

	SELECT	
		@nr_stand_in_declined = SUM(nr_trans)
	FROM
		post_ds_terminals WITH (NOLOCK)
	WHERE 
		recon_business_date >= @report_date_start
		AND 
		recon_business_date <= @report_date_end 
		AND 
		source_node_name IN (SELECT source_node FROM #list_of_source_nodes) 
		AND 
		postilion_stand_in = 1
		AND 
		message_type IN ('0200')
		AND 
		rsp_code <> '91'
		AND 
		NOT rsp_code IN ('00','08', '10', '11', '16') 
		AND
		dbo.fn_rpt_isAutomatedDeposit(tran_type, extended_tran_type) = 1

	IF (@@ROWCOUNT = 0 OR @nr_stand_in_declined IS NULL)
	BEGIN
		SELECT @nr_stand_in_declined = 0
	END

	INSERT INTO 
		#report_result
	SELECT 
		@nr_aborted 				AS NrAborted, 
		@nr_stand_in_approved 	AS NrStandInApproved, 
		@nr_stand_in_declined 	AS NrStandInDeclined
	
	SELECT * FROM #report_result
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b03_1]    Script Date: 05/17/2016 16:30:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b03_1]
	@StartDate				CHAR(8),			-- yyyymmdd
	@EndDate					CHAR(8),			-- yyyymmdd
	@SinkNode				VARCHAR(40),	-- Separated by commas
	@SourceNodes			VARCHAR(255),	-- Separated by commas
	@GroupMemberBanks		BIT
AS
BEGIN
	-- This is used by the B03 - Host Summary report
	
	-- PDT: Made the assumption that the Settlement Currency of the Transaction Amount will always be the same as the Settlement Currency of the Surcharge Fee. This was done to keep the report simple.
	
	CREATE TABLE #report_result
	(
		Warning							VARCHAR (255), 
		StartDate						DATETIME,
		EndDate							DATETIME,
		SinkNode							VARCHAR (30), 
		SourceNode						VARCHAR (30), 
		TranType							CHAR (2),
		NrTrans							INT,
		SettleCurrency					CHAR (3),
		SourceNodeAlias				VARCHAR (255),
		TransactionAmount				FLOAT,
		SurchargeAmount				FLOAT,
		SetlleCurrencyNrDecimals	INT,
		SettleCurrencyAlphaCode 	CHAR (3),
		isCheckDeposit					INT,
		isCashDeposit					INT,
		isEnvelopeDeposit				INT
	)

	DECLARE @warning 			VARCHAR (255)
	
	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	
	IF (@SinkNode IS NULL or Len(@SinkNode)=0)
	BEGIN
		SET @warning = 'Please supply the Host name.'
		
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT	* from #report_result
		
		RETURN 1
	END
			
	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next	DATETIME
	DECLARE @node_name_list 		VARCHAR(255)
	DECLARE @node_list				VARCHAR(255)
	DECLARE @date_selection_mode	VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT
	
	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30))
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	-- Only look at 02xx messages that were not fully reversed.
	
	-- We are using the UNION in order to make sure we still return the PARAMETERS, even if there are no transactions in the resultset.
	-- The way the reports has been configured, the FIRST query of the UNION should be the one returning the PARAMETERs only
	INSERT 
			INTO #report_result
	
	SELECT	
			NULL as Warning, 
			@report_date_start as StartDate,  
			@report_date_end as EndDate,
			sink_node_name as SinkNode, 
			source_node_name as SourceNode, 
			tran_type as TranType, 
			SUM(nr_trans) AS NrTrans, 
			settle_amount_currency as SettleCurrency, 
			
			SourceNodeAlias = 
			(
				CASE 
					WHEN source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our Terminals-'
					ELSE
					(
						CASE
							WHEN @GroupMemberBanks = 1 THEN
							(
								CASE
									WHEN '0' IN (SELECT granularity FROM post_nodes WHERE node_name = source_node_name) THEN '-Member Banks-'
									ELSE source_node_name
								END
							)
							ELSE source_node_name
						END
					)
				END
			),
	
			dbo.formatAmount(
				SUM
				(
					CASE
						-- The settle_amount_impact field will typically be negative for Debit transaction types, but we want to display those amount as positive on this report
						WHEN (cast(tran_type as INT) between 0 and 19 or cast(tran_type as INT) between 50 and 59) THEN -1 * settle_amount_impact
						ELSE settle_amount_impact
					END
				), 
				settle_amount_currency) AS TransactionAmount,
	
			dbo.formatAmount(SUM(-1 * surcharge_amount_impact), settle_amount_currency) AS SurchargeAmount,
			
			dbo.currencyNrDecimals(settle_amount_currency) 								AS SetlleCurrencyNrDecimals,
			dbo.currencyAlphaCode(settle_amount_currency) 								AS SettleCurrencyAlphaCode,
			dbo.fn_rpt_isElectronicCheckDeposit(tran_type, extended_tran_type)	AS isCheckDeposit,
			dbo.fn_rpt_isCashDepositBNA(tran_type, extended_tran_type)				AS isCashDeposit,
			dbo.fn_rpt_isEnvelopeDeposit(tran_type, extended_tran_type)				AS isEnvelopeDeposit
	FROM
			post_ds_nodes WITH (NOLOCK)
	WHERE 
			(recon_business_date >= @report_date_start) 
			AND 
			(recon_business_date <= @report_date_end) 
			AND 
			tran_postilion_originated = 1 
			AND 
			rsp_code IN ('00','08', '10', '11', '16') 
			AND 
			sink_node_name = @SinkNode
			AND
			dbo.fn_rpt_isAutomatedDeposit(tran_type, extended_tran_type) = 1
			AND 
			(
				message_type IN ('0200','0220') 
				OR 
				(
					-- We do not want Reversals that do not have any financial impact
					message_type IN ('0400', '0420') 
					AND 
					(
						settle_amount_impact <> 0 
						OR 
						surcharge_amount_impact <> 0
					)
				)	
			)
	
	GROUP BY 
			sink_node_name, source_node_name, tran_type, extended_tran_type, settle_amount_currency
			
			
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result(Warning, StartDate, EndDate) VALUES ('No transactions.', @report_date_start, @report_date_end)
	
	SELECT * FROM #report_result
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b03_1_exceptions]    Script Date: 05/17/2016 16:30:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b03_1_exceptions]
	@report_date_start		DATETIME,
	@report_date_end			DATETIME,
	@SinkNode					VARCHAR(40)
AS
BEGIN
		
	CREATE TABLE #report_result
	(
		NrAborted			INT, 
		NrStandInApproved	INT, 
		NrStandInDeclined	INT
	)

	-- We do not have to validate the parameter, because this proc will be called from a subreport and the paramaeters have
	--	already been validated by the stored proc of the main report.

	DECLARE @nr_aborted 					INT
	DECLARE @nr_stand_in_approved		INT
	DECLARE @nr_stand_in_declined		INT

	SELECT	
		@nr_aborted = SUM(nr_trans)
	FROM
		post_ds_nodes WITH (NOLOCK)
	WHERE 
		(recon_business_date >= @report_date_start) 
		AND 
		(recon_business_date <= @report_date_end) 
		AND 
		tran_postilion_originated = 1
		AND 
		sink_node_name = @SinkNode 
		AND 
		message_type IN ('0200','0220','0420') 
		AND 
		tran_aborted = 1
		AND 
		dbo.fn_rpt_isAutomatedDeposit(tran_type, extended_tran_type) = 1

	IF @@ROWCOUNT = 0 OR @nr_aborted IS NULL
		SELECT @nr_aborted = 0

	SELECT	
		@nr_stand_in_approved = SUM(nr_trans)
	FROM
		post_ds_nodes WITH (NOLOCK)
	WHERE 
		(recon_business_date >= @report_date_start) 
		AND 
		(recon_business_date <= @report_date_end) 
		AND 
		tran_postilion_originated = 1
		AND 
		sink_node_name = @SinkNode 
		AND 
		message_type IN ('0200','0220') 
		AND 
		postilion_stand_in = 1	-- Include 0220's because 0200 on the source node leg are 0220s on the sink node side if we did stand-in. 
		AND 
		rsp_code IN ('00','08', '10', '11', '16') 
		AND 
		dbo.fn_rpt_isAutomatedDeposit(tran_type, extended_tran_type) = 1

	IF @@ROWCOUNT = 0 OR @nr_stand_in_approved IS NULL
		SELECT @nr_stand_in_approved = 0

	SELECT	
		@nr_stand_in_declined = SUM(nr_trans)
	FROM
		post_ds_nodes WITH (NOLOCK)
	WHERE 
		(recon_business_date >= @report_date_start) 
		AND 
		(recon_business_date <= @report_date_end) 
		AND 
		tran_postilion_originated = 1
		AND 
		sink_node_name = @SinkNode 
		AND 
		message_type IN ('0200','0220') 
		AND 
		postilion_stand_in = 1
		AND 
		rsp_code <> '91'	-- PDT: There seems to be a bug in Office where some transacations marked as '91' are also marked as stand-in.
		AND 
		NOT rsp_code IN ('00','08', '10', '11', '16') 
		AND 
		dbo.fn_rpt_isAutomatedDeposit(tran_type, extended_tran_type) = 1

	IF @@ROWCOUNT = 0 OR @nr_stand_in_declined IS NULL
		SELECT @nr_stand_in_declined = 0

	INSERT INTO #report_result
	SELECT @nr_aborted as NrAborted, @nr_stand_in_approved as NrStandInApproved, @nr_stand_in_declined as NrStandInDeclined
	
	SELECT * FROM #report_result
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_Discover]    Script Date: 05/17/2016 16:30:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO








ALTER PROCEDURE [dbo].[osp_rpt_b04_Discover]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@SinkNodes		VARCHAR(40),
	@SourceNodes	VARCHAR(255),	-- Seperated by commas
        @Retention_Data VARCHAR (10),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),  
		EndDate					VARCHAR(30), 
		recon_business_date			DATETIME, 	
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19),
		terminal_id				CHAR (8), 
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (40), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),
		tran_reversed			INT,		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		payee				char(25),
		retention_data			varchar(999),  
		totals_group			varchar(40),
		tran_postilion_originated  varchar(5),
		tran_nr                    varchar(40)
	)

	
	
	IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END
		
	
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @Tempreport_date_start DATETIME
    DECLARE @Tempreport_date_end DATETIME
    DECLARE @isDateNull INT
    SET @isDateNull = 0
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Last business day'
	
	SELECT @StartDate = REPLACE(@StartDate, '-', '');
	SELECT @EndDate = REPLACE(@EndDate, '-', '');
	
	SELECT @StartDate = REPLACE(@StartDate, '.', '');
	SELECT @EndDate = REPLACE(@EndDate, '.', '');
	
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)
	
	
	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

    SELECT @rpt_tran_id = (SELECT MIN(first_post_tran_cust_id)  FROM post_normalization_session (NOLOCK) WHERE datetime_creation  >= DATEADD(dd,-1,@report_date_start))

	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END


	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	DECLARE @list_of_source_nodes TABLE  (source_node	VARCHAR(30)) 

	
	INSERT INTO  @list_of_source_nodes SELECT part as 'source_node' FROM usf_split_string(@SourceNodes,',')
	
	DECLARE @list_of_sink_nodes TABLE  (sink_node	VARCHAR(30)) 
	
	INSERT INTO  @list_of_sink_nodes SELECT part AS 'Sink_Node' FROM usf_split_string(@SinkNodes,',')
	
	DECLARE @sink_node_name VARCHAR(2000)
	DECLARE @sink_node_name_new  VARCHAR(2000)
	
	DECLARE @list_of_bank_codes TABLE  (bank_code	VARCHAR(30)) 
	
	DECLARE sink_node_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT Sink_Node FROM @list_of_sink_nodes
	
	OPEN  sink_node_cursor;
	FETCH NEXT FROM sink_node_cursor INTO @sink_node_name;
	
	WHILE (@@FETCH_STATUS=0)
	  BEGIN
	
	      --SET @sink_node_name_new  =  substring(substring(@sink_node_name,4, LEN(@sink_node_name)), 1,len(substring(@sink_node_name,4, LEN(@sink_node_name)))-3) 	  
		  SET @sink_node_name_new  =  substring(@sink_node_name,4, 3)  	  
	        INSERT INTO @list_of_bank_codes(bank_code) VALUES (@sink_node_name_new) 
		FETCH NEXT FROM sink_node_cursor INTO @sink_node_name;
	END
		
	CLOSE  sink_node_cursor;
	DEALLOCATE sink_node_cursor 
	
    DECLARE @list_of_retention_data TABLE  (Retention_Data VARCHAR(30)) 
	
	INSERT INTO  @list_of_retention_data SELECT part as 'Retention_Data' FROM usf_split_string(@Retention_Data,',')
	
	-- Only look at 02xx messages that were not fully reversed.
    --SELECT @report_date_start AS 'START_DATE', @report_date_end AS 'END_DATE'
	INSERT
				INTO @report_result
	SELECT
	     
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				t.recon_business_date,--oremeyi added this 24/02/2009
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				CASE WHEN @show_full_pan=1 THEN dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan)
					ELSE pan
				END
				 AS pan,
				c.terminal_id, 
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.tran_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
						
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
					
								
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,
				
				t.tran_reversed,
				dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,


				dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				t.from_account_id,
				t.payee,
				isnull(t.retention_data,0),
				c.totals_group,
				t.tran_postilion_originated,
				t.tran_nr+t.online_system_id
	FROM
				post_tran_summary t (NOLOCK)
				
	WHERE 		
			  (t.post_tran_cust_id >= @rpt_tran_id)
			  AND  (t.recon_business_date >= @report_date_start AND t.recon_business_date <= @report_date_end)
			  AND
				t.tran_completed = 1 AND
				(
				 ( t.retention_data IS NOT NULL AND (LEFT(retention_data,4) in (SELECT Retention_Data FROM @list_of_retention_data))   OR 
				  LEFT (c.totals_group,3) IN (SELECT bank_code FROM @list_of_bank_codes)   AND (t.sink_node_name <>'ESBCSOUTsnk' AND t.retention_data is  NULL))
				
				)
				

				AND
				t.message_type IN ('0200', '0220', '0400', '0420')  AND t.tran_type  ='01'
				
				AND
                (
				c.source_node_name  = 'SWTMEGADSsrc'
                )
				AND
				LEFT(t.sink_node_name,2) <> 'SB' 
				

						
			 IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
			ELSE
			BEGIN
		--

		-- Decrypt PAN information if necessary
		--
	IF (@show_full_pan=1)
	  BEGIN

		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)

		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B04 Report'

		-- Get pan and pan_encrypted from @report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					@report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
			--  SELECT @pan_clear = postilion_office.dbo.DecryptPan(@pan, @pan_encrypted, @process_descr);
			EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						@report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
				END
				END

				CLOSE pan_cursor
				DEALLOCATE pan_cursor

				END		

				END		
												

				DECLARE @current_tran_nr VARCHAR (255)
				DECLARE @current_retention_data VARCHAR (255)

				DECLARE tran_nr_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR (SELECT tran_nr,retention_data FROM @report_result WHERE tran_postilion_originated =1 AND retention_data IS NOT NULL AND (LEFT(retention_data,4) in (SELECT Retention_Data FROM @list_of_retention_data)))

				OPEN  tran_nr_cursor;
			
				FETCH NEXT FROM tran_nr_cursor INTO @current_tran_nr, @current_retention_data;

				WHILE (@@FETCH_STATUS=0)
					BEGIN

						UPDATE @report_result SET retention_data = @current_retention_data WHERE tran_nr = @current_tran_nr AND tran_postilion_originated=0
						
						
						FETCH NEXT FROM tran_nr_cursor INTO @current_tran_nr, @current_retention_data;

					END

				CLOSE  tran_nr_cursor;			
				DEALLOCATE tran_nr_cursor;
				
				DELETE FROM @report_result WHERE tran_postilion_originated=1 AND sink_node_name <>'ESBCSOUTsnk'
	

				
	
	SELECT  Warning,StartDate,EndDate,recon_business_date,SourceNodeAlias,pan,terminal_id,card_acceptor_id_code,card_acceptor_name_loc,source_node_name,sink_node_name,tran_type,rsp_code_rsp,message_type,datetime_req,settle_amount_req,settle_amount_rsp,settle_tran_fee_rsp,TranID,prev_post_tran_id,system_trace_audit_nr,message_reason_code,retrieval_reference_nr,datetime_tran_local,from_account_type,to_account_type,settle_currency_code,settle_amount_impact,tran_type_desciption,rsp_code_description,settle_nr_decimals,currency_alpha_code,currency_name,tran_reversed,isPurchaseTrx,isWithdrawTrx,isRefundTrx,isDepositTrx,isInquiryTrx,isTransferTrx,isOtherTrx,pan_encrypted,from_account_id,payee,retention_data,totals_group  FROM 
	
	     @report_result
	ORDER BY 
		datetime_tran_local, source_node_name
		
END






GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_pos_acquirer_CUP]    Script Date: 05/17/2016 16:30:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_pos_acquirer_CUP]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@AcquiringID	VARCHAR(40),
	@CBN_Code		CHAR(3),
	@Period			VARCHAR(20),    -- included by eseosa to support multiple time frames 14/02/2012
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
                terminal_id                     VARCHAR (10),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
                Acquiring_Inst_id_code          VARCHAR (10),
                
		sink_node_name				VARCHAR (40),
		tran_type					CHAR (2),
		rsp_code_rsp				CHAR (2),
		message_type				CHAR (4),
		datetime_req				DATETIME,
		settle_amount_req			FLOAT,
		settle_amount_rsp			FLOAT,
		settle_tran_fee_rsp			FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (255),
		tran_type_description		VARCHAR (255),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@AcquiringID IS NULL or Len(@AcquiringID)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	--SET @node_name_list = @SourceNode
	SET @date_selection_mode = @Period -- modified by eseosa 14/02/2012

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	CREATE TABLE #list_of_AcquiringID (AcquiringID	VARCHAR(30)) 
	
	INSERT INTO  #list_of_AcquiringID EXEC osp_rpt_util_split_nodenames @AcquiringID

        CREATE TABLE #list_of_CBN_Code (CBN_Code CHAR(3)) 
	
	INSERT INTO  #list_of_CBN_Code EXEC osp_rpt_util_split_nodenames @CBN_Code


	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
                        c.card_acceptor_id_code,
			c.card_acceptor_name_loc,
                        t.acquiring_inst_id_code,
			t.sink_node_name,
			t.tran_type,
			t.rsp_code_rsp,
			t.message_type,
			t.datetime_req,

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,

			t.settle_currency_code,


			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran_summary t (nolock)
	WHERE
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0100','0200','0220','0400','0420')---oremeyi removed 0120
			AND
			t.tran_completed = 1
			AND
			(t.acquiring_inst_id_code IN (SELECT AcquiringID FROM #list_of_AcquiringID) 
                         or 
                         (substring (c.terminal_id,2,3) IN (SELECT CBN_Code FROM #list_of_CBN_Code)))
			AND
			 t.sink_node_name = 'CUPsnk'
                        AND
                        c.terminal_id like '2%'
		OPTION (RECOMPILE)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--
		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B06 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_pos_acquirer_CUP_Eloho_Test]    Script Date: 05/17/2016 16:30:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_pos_acquirer_CUP_Eloho_Test]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@AcquiringID	VARCHAR(40),
        @SourceNodes	VARCHAR(255),
	@CBN_Code		CHAR(3),
	@Period			VARCHAR(20),    -- included by eseosa to support multiple time frames 14/02/2012
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
                terminal_id                     VARCHAR (10),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
                Acquiring_Inst_id_code          VARCHAR (10),
                source_node_name		VARCHAR (40),
		sink_node_name				VARCHAR (40),
		tran_type					CHAR (2),
		rsp_code_rsp				CHAR (2),
		message_type				CHAR (4),
		datetime_req				DATETIME,
		settle_amount_req			FLOAT,
		settle_amount_rsp			FLOAT,
		settle_tran_fee_rsp			FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (255),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@AcquiringID IS NULL or Len(@AcquiringID)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	--SET @node_name_list = @SourceNode
	SET @date_selection_mode = @Period -- modified by eseosa 14/02/2012

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	CREATE TABLE #list_of_AcquiringID (AcquiringID	VARCHAR(30)) 
	
	INSERT INTO  #list_of_AcquiringID EXEC osp_rpt_util_split_nodenames @AcquiringID

        CREATE TABLE #list_of_CBN_Code (CBN_Code CHAR(3)) 
	
	INSERT INTO  #list_of_CBN_Code EXEC osp_rpt_util_split_nodenames @CBN_Code

        CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 

        INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes


	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
                        c.card_acceptor_id_code,
			t.card_acceptor_name_loc,
                        t.acquiring_inst_id_code,
                        c.source_node_name,
			t.sink_node_name,
			t.tran_type,
			t.rsp_code_rsp,
			t.message_type,
			t.datetime_req,

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,

			t.settle_currency_code,


			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
		  post_tran_summary t (NOLOCK)
	WHERE
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0100','0200','0220','0400','0420')---oremeyi removed 0120
			AND
			t.tran_completed = 1
			AND
			(t.acquiring_inst_id_code IN (SELECT AcquiringID FROM #list_of_AcquiringID) 
                         or 
                         (substring (c.terminal_id,2,3) IN (SELECT CBN_Code FROM #list_of_CBN_Code)))
			AND
			 t.sink_node_name = 'CUPsnk'
                        AND
                        c.terminal_id like '2%'
                        AND
                        c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--
		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B06 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local, source_node_name
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_pos_acquirer_CUP_Eloho_Test_try]    Script Date: 05/17/2016 16:30:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE[dbo].[osp_rpt_b04_pos_acquirer_CUP_Eloho_Test_try]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@AcquiringID	VARCHAR(40),
        @SourceNodes	VARCHAR(255),
	@CBN_Code		CHAR(3),
	@Period			VARCHAR(20),    -- included by eseosa to support multiple time frames 14/02/2012
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
                terminal_id                     VARCHAR (10),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
                Acquiring_Inst_id_code          VARCHAR (10),
                source_node_name		VARCHAR (40),
		sink_node_name				VARCHAR (40),
		tran_type					CHAR (2),
		rsp_code_rsp				CHAR (2),
		message_type				CHAR (4),
		datetime_req				DATETIME,
		settle_amount_req			FLOAT,
		settle_amount_rsp			FLOAT,
		settle_tran_fee_rsp			FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@AcquiringID IS NULL or Len(@AcquiringID)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	--SET @node_name_list = @SourceNode
	SET @date_selection_mode = @Period -- modified by eseosa 14/02/2012

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	CREATE TABLE #list_of_AcquiringID (AcquiringID	VARCHAR(30)) 
	
	INSERT INTO  #list_of_AcquiringID EXEC osp_rpt_util_split_nodenames @AcquiringID

        CREATE TABLE #list_of_CBN_Code (CBN_Code CHAR(3)) 
	
	INSERT INTO  #list_of_CBN_Code EXEC osp_rpt_util_split_nodenames @CBN_Code

        CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 

        INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes


	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
                        c.card_acceptor_id_code,
			c.card_acceptor_name_loc,
                        t.acquiring_inst_id_code,
                        c.source_node_name,
			t.sink_node_name,
			t.tran_type,
			t.rsp_code_rsp,
			t.message_type,
			t.datetime_req,

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,

			t.settle_currency_code,


			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran_summary t (NOLOCK)
	WHERE
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0100','0200','0220','0400','0420')---oremeyi removed 0120
			AND
			t.tran_completed = 1
			AND
			(t.acquiring_inst_id_code IN (SELECT AcquiringID FROM #list_of_AcquiringID) 
                         or 
                         (substring (c.terminal_id,2,3) IN (SELECT CBN_Code FROM #list_of_CBN_Code)))
			AND
			 t.sink_node_name = 'CUPsnk'
                        AND
                        c.terminal_id like '2%'
                        AND
                        c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
						option (recompile)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--
		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B06 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local, source_node_name
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_pos_acquirer_CUP_source_node]    Script Date: 05/17/2016 16:30:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO










ALTER PROCEDURE [dbo].[osp_rpt_b04_pos_acquirer_CUP_source_node]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@AcquiringID	VARCHAR(40),
	@CBN_Code		CHAR(3),
	@Period			VARCHAR(20),    -- included by eseosa to support multiple time frames 14/02/2012
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),
		StartDate					VARCHAR(30),
		EndDate						VARCHAR(30),
		pan							VARCHAR (19),
                terminal_id                     VARCHAR (10),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
                Acquiring_Inst_id_code          VARCHAR (10),
                source_node_name		VARCHAR (40),
		sink_node_name				VARCHAR (40),
		tran_type					CHAR (2),
		rsp_code_rsp				CHAR (2),
		message_type				CHAR (4),
		datetime_req				DATETIME,
		settle_amount_req			FLOAT,
		settle_amount_rsp			FLOAT,
		settle_tran_fee_rsp			FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description		VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (255),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@AcquiringID IS NULL or Len(@AcquiringID)=0)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM @report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	--SET @node_name_list = @SourceNode
	SET @date_selection_mode = @Period -- modified by eseosa 14/02/2012

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)

		SELECT * FROM @report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM @report_result
		RETURN 1
	END
	
	DECLARE  @list_of_AcquiringID  TABLE(AcquiringID	VARCHAR(30)) 
	
	INSERT INTO  @list_of_AcquiringID SELECT part FROM dbo.usf_split_string(@AcquiringID, ',');

        DECLARE  @list_of_CBN_Code TABLE(CBN_Code CHAR(3)) 
	
	INSERT INTO  @list_of_CBN_Code  SELECT part FROM dbo.usf_split_string(@CBN_Code, ','); 

	INSERT
			INTO @report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			dbo.usf_decrypt_pan(c.pan,c.pan_encrypted) pan,
			c.terminal_id,
                        c.card_acceptor_id_code,
			c.card_acceptor_name_loc,
                        t.acquiring_inst_id_code,
                        c.source_node_name,
			t.sink_node_name,
			t.tran_type,
			t.rsp_code_rsp,
			t.message_type,
			t.datetime_req,

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,

			t.settle_currency_code,


			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran_summary t (NOLOCK)
	WHERE
			t.tran_completed = 1
			AND
	   recon_business_date >= @report_date_start AND recon_business_date <= @report_date_end
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0100','0200','0220','0400','0420')---oremeyi removed 0120
			AND
			t.tran_completed = 1
			AND
			(t.acquiring_inst_id_code IN (SELECT AcquiringID FROM @list_of_AcquiringID) 
                         or 
                         (substring (c.terminal_id,2,3) IN (SELECT CBN_Code FROM @list_of_CBN_Code)))
			AND
			 t.sink_node_name = 'CUPsnk'
                        AND
                        LEFT(t.terminal_id,1) = '2'
						(RECOMPILE)
                        
	IF @@ROWCOUNT = 0
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	--ELSE
	--BEGIN
	--	--
	--	-- Decrypt PAN information if necessary
	--	--
	--	DECLARE @pan VARCHAR (19)
	--	DECLARE @pan_encrypted CHAR (18)
	--	DECLARE @pan_clear VARCHAR (19)
	--	DECLARE @process_descr VARCHAR (100)

	--	SET @process_descr = 'Office B06 Report'

	--	-- Get pan and pan_encrypted from @report_result and post_tran_cust using a cursor
	--	DECLARE pan_cursor CURSOR FORWARD_ONLY
	--	FOR
	--		SELECT
	--				pan,
	--				pan_encrypted
	--		FROM
	--				@report_result
	--	FOR UPDATE OF pan

	--	OPEN pan_cursor

	--	DECLARE @error INT
	--	SET @error = 0

	--	IF (@@CURSOR_ROWS <> 0)
	--	BEGIN
	--		FETCH pan_cursor INTO @pan, @pan_encrypted
	--		WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
	--		BEGIN
	--			-- Handle the decrypting of PANs
	--			EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

	--			-- Update the row if its different
	--			IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
	--			BEGIN
	--				UPDATE
	--					@report_result
	--				SET
	--					pan = @pan_clear
	--				WHERE
	--					CURRENT OF pan_cursor
	--			END

	--			FETCH pan_cursor INTO @pan, @pan_encrypted
	--		END
	--	END

	--	CLOSE pan_cursor
	--	DEALLOCATE pan_cursor
	--END

	SELECT *
	FROM
			@report_result
	ORDER BY
			datetime_tran_local
END
































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_pos_acquirer_CUP_source_node_2]    Script Date: 05/17/2016 16:30:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_pos_acquirer_CUP_source_node_2]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@AcquiringID	VARCHAR(40),
	@CBN_Code		CHAR(3),
	@Period			VARCHAR(20),    -- included by eseosa to support multiple time frames 14/02/2012
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
                terminal_id                     VARCHAR (10),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
                Acquiring_Inst_id_code          VARCHAR (10),
                source_node_name		VARCHAR (40),
		sink_node_name				VARCHAR (40),
		tran_type					CHAR (2),
		rsp_code_rsp				CHAR (2),
		message_type				CHAR (4),
		datetime_req				DATETIME,
		settle_amount_req			FLOAT,
		settle_amount_rsp			FLOAT,
		settle_tran_fee_rsp			FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (255),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@AcquiringID IS NULL or Len(@AcquiringID)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	--SET @node_name_list = @SourceNode
	SET @date_selection_mode = @Period -- modified by eseosa 14/02/2012

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	DECLARE  @list_of_AcquiringID TABLE(AcquiringID	VARCHAR(30)) 
	
	INSERT INTO  @list_of_AcquiringID SELECT part FROM usf_split_string( @AcquiringID, ',')

       DECLARE @list_of_CBN_Code TABLE (CBN_Code CHAR(3)) 
	
	INSERT INTO  @list_of_CBN_Code   SELECT part FROM usf_split_string( @CBN_Code, ',')


	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			dbo.usf_decrypt_pan(c.pan,c.pan_encrypted) as pan,
			c.terminal_id,
                        c.card_acceptor_id_code,
			c.card_acceptor_name_loc,
                        t.acquiring_inst_id_code,
                        c.source_node_name,
			t.sink_node_name,
			t.tran_type,
			t.rsp_code_rsp,
			t.message_type,
			t.datetime_req,

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,

			t.settle_currency_code,


			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran_summary t (NOLOCK)
	WHERE
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0100','0200','0220','0400','0420')---oremeyi removed 0120
			AND
			t.tran_completed = 1
			AND
			(t.acquiring_inst_id_code IN (SELECT AcquiringID FROM @list_of_AcquiringID) 
                         or 
                         (substring (c.terminal_id,2,3) IN (SELECT CBN_Code FROM @list_of_CBN_Code)))
			AND
			 t.sink_node_name = 'CUPsnk'
			AND
			LEFT(c.terminal_id, 1)= '2'
			option(recompile)

	IF (@@ROWCOUNT = 0)BEGIN
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	END
	--ELSE
	--BEGIN
	--	--
	--	-- Decrypt PAN information if necessary
	--	--
	--	DECLARE @pan VARCHAR (19)
	--	DECLARE @pan_encrypted CHAR (18)
	--	DECLARE @pan_clear VARCHAR (19)
	--	DECLARE @process_descr VARCHAR (100)

	--	SET @process_descr = 'Office B06 Report'

	--	-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
	--	DECLARE pan_cursor CURSOR FORWARD_ONLY
	--	FOR
	--		SELECT
	--				pan,
	--				pan_encrypted
	--		FROM
	--				#report_result
	--	FOR UPDATE OF pan

	--	OPEN pan_cursor

	--	DECLARE @error INT
	--	SET @error = 0

	--	IF (@@CURSOR_ROWS <> 0)
	--	BEGIN
	--		FETCH pan_cursor INTO @pan, @pan_encrypted
	--		WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
	--		BEGIN
	--			-- Handle the decrypting of PANs
	--			EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

	--			-- Update the row if its different
	--			IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
	--			BEGIN
	--				UPDATE
	--					#report_result
	--				SET
	--					pan = @pan_clear
	--				WHERE
	--					CURRENT OF pan_cursor
	--			END

	--			FETCH pan_cursor INTO @pan, @pan_encrypted
	--		END
	--	END

	--	CLOSE pan_cursor
	--	DEALLOCATE pan_cursor
	--END

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_acquirer_all_UBAVISA]    Script Date: 05/17/2016 16:30:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_acquirer_all_UBAVISA]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	--@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@AcquiringBIN	VARCHAR(25),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
        @rpt_tran_id1 INT = NULL
         

AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	Create   TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(12),
		terminal_owner  			VARCHAR(32),
		merchant_type				CHAR (4),
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	VARCHAR (255), 
		source_node_name		VARCHAR (255), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		tran_reversed			INT,	 
		settle_amount_impact	FLOAT,
		extended_tran_type		CHAR (4),
		system_trace_audit_nr		CHAR (10),
                Rdm_Amt FLOAT,
                late_reversal_id CHAR (1)
		)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 
    EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(255)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	-- Only look at 02xx messages that were not fully reversed.



	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
				--ISNULL(account_nr,'not available')
				--ISNULL(m.Category_name,'VOID'),
				--ISNULL(m.Fee_type,'VOID'),
				--ISNULL(m.merchant_disc,0.0),
				--ISNULL(m.fee_cap,0),
				--ISNULL(m.amount_cap,99999999999.99),
				--ISNULL(m.bearer,'M'),

				c.card_acceptor_id_code, 

				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				t.tran_reversed,	 
					

				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,
					extended_tran_type,
					system_trace_audit_nr,-----------added by ij 2010/04/01
                                0 as rdm_amt,
                                 Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1
						ELSE 0
					        END
	FROM
			
				post_tran_summary t (NOLOCK)
				--left JOIN tbl_merchant_category_Web m (NOLOCK)
				--ON c.merchant_type = m.category_code 
				--left JOIN tbl_xls_settlement y (NOLOCK)
				
                            --    ON (c.terminal_id= y.terminal_id 
                                 --   AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                 --   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                 --   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                -- and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))

                                
	WHERE 			
				
				t.post_tran_cust_id >= @rpt_tran_id
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				
				(t.message_type IN ('0220','0200', '0400', '0420')) 
				
				AND
				t.tran_postilion_originated = 0  
				AND
				t.tran_completed = 1
				AND
				tran_type NOT IN ('31','39','50')
				--AND 
				--t.sink_node_name = @SinkNode
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				--AND
				--sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')------ij added SWTMEGAsnk
				AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
			 OPTION (RECOMPILE)


	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT *

--		 StartDate,
--		 EndDate,
--		 card_acceptor_id_code, 
--		 card_acceptor_name_loc, 
--		 acquiring_inst_id_code,
--		category_name, 
--		merchant_type,
--		 tran_type,
--		SUM(CASE
--			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200','0220')THEN 1
--                        WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0200','0220')THEN 1
--			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
--			WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0420','0400')THEN -1
--                        --WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1
--			ELSE 0
--			END) AS no_above_limit,
--		SUM(CASE
--			---WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
--			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200','0220') then settle_amount_impact * -1	
--			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
--			--WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 		
--			WHEN ABS(Rdm_amt) >= amount_cap  then rdm_amt
--                        ELSE 0
--            		END) AS amount_above_limit,
--		 SUM(settle_amount_impact * -1+ rdm_amt)as amount,
--		 SUM(settle_tran_fee_rsp *-1) as fee,
--		 SUM(CASE			
--                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
--                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
--                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
--            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
--            		END) as tran_count,
--			extended_tran_type,
--			message_type,
--			settle_amount_rsp,
--			system_trace_audit_nr,
--                        late_reversal_id,
--                  (CASE When  dbo.fn_rpt_CardGroup (pan) = 1 Then 'Verve Card'
--                                  When dbo.fn_rpt_CardGroup (pan) = 2 Then 'Magstripe Card'
--                                  When dbo.fn_rpt_CardGroup (pan) = 3 Then 'MasterCard'
--                                  When dbo.fn_rpt_CardGroup (pan) = 4 Then 'MasterCard Verve Card'
--                                  When dbo.fn_rpt_CardGroup (pan) = 6 Then 'Visa Card'
--                                  When dbo.fn_rpt_CardGroup (pan) = 5 Then 'Unknown Card'
--                                  Else 'Unknown Card'
--	                          END) AS CardType
	FROM 
			#report_result

                        where not (c.merchant_type in ('4004','4722') and  abs(settle_amount_impact * -1)< 200)
                                                     and c.merchant_type not in ('5371')		
--	GROUP BY
--			StartDate, EndDate,category_name,extended_tran_type,
--			merchant_type,acquiring_inst_id_code,tran_type, 
--			card_acceptor_id_code, card_acceptor_name_loc,
--			 message_type,settle_amount_rsp,system_trace_audit_nr,late_reversal_id,dbo.fn_rpt_CardGroup (pan) -- tran_type_description, 
                          
	ORDER BY 
			acquiring_inst_id_code




END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer]    Script Date: 05/17/2016 16:30:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

























GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_2]    Script Date: 05/17/2016 16:30:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_2]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@Currency_code		VARCHAR(3) -- included by eseosa to specify currency
AS
BEGIN

	SET NOCOUNT ON
    SET TRANSACTION ISOLATION LEVEL READ UNARCHIVED
	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
		--tran_tran_fee_rsp		INT,     --sopeju added this
		--merchant_service_charge	INT,	 --sopeju added this
		--tran_amount_rsp			INT		 --sopeju added this
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN

	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM @report_result
		RETURN 1
	END

*/


	DECLARE  @list_of_source_nodes TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM dbo.usf_split_string (@SourceNodes, ',');
	
	DECLARE  @list_of_IINs TABLE(IIN	VARCHAR(30)) 
	INSERT INTO  @list_of_IINs SELECT part FROM dbo.usf_split_string (@IINs, ',');
	
	DECLARE  @list_of_card_acceptor_id_codes TABLE(card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM dbo.usf_split_string (@merchants, ','); 
	-- Only look at 02xx messages that were not fully reversed.

	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				--t.tran_tran_fee_rsp,
				--t.tran_amount_rsp,
				--merchant_service_charge,
				
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
		post_tran_summary t (NOLOCK)
		LEFT JOIN tbl_merchant_account a (NOLOCK, INDEX(card_acceptor_id_code_idx))
		ON			
			c.card_acceptor_id_code = a.card_acceptor_id_code	
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
								(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				--(t.post_tran_cust_id >= @first_post_tran_cust_id) 
				--AND 
				--(t.post_tran_cust_id <= @last_post_tran_cust_id)
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				and
				t.tran_currency_code = @currency_code
				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				OPTION (RECOMPILE)
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_billing]    Script Date: 05/17/2016 16:30:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_billing]
      @StartDate        VARCHAR(30),      -- yyyymmdd
      @EndDate          VARCHAR(30),-- yyyymmdd
      @SourceNodes      VARCHAR(4000),
      @show_full_pan    BIT,
      @report_date_start DATETIME = NULL,
      @report_date_end DATETIME = NULL,
      @rpt_tran_id INT = NULL,
      @Period                 VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
      
AS
BEGIN

      SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

      DECLARE  @report_result TABLE
      (
                seq_num_id          BIGINT IDENTITY(1,1) UNIQUE,
            Warning                             VARCHAR (255),
            StartDate                     VARCHAR(30),
            EndDate                             VARCHAR(30),
            SourceNodeAlias         VARCHAR (50),
            pan                                 VARCHAR (19), 
            terminal_id                   CHAR (9), 
            acquiring_inst_id_code              CHAR(18),
            terminal_owner          CHAR(12),
            merchant_type                       CHAR (4),
            card_acceptor_id_code   CHAR (15),  
            card_acceptor_name_loc  CHAR (70), 
            source_node_name        VARCHAR (40), 
            sink_node_name                VARCHAR (40), 
            tran_type                     CHAR (2), 
            rsp_code_rsp                  CHAR (2), 
            message_type                  CHAR (4), 
            datetime_req                  DATETIME,                     
            settle_amount_req       FLOAT, 
            settle_amount_rsp       FLOAT,
            settle_tran_fee_rsp           FLOAT,                        
            TranID                              INT,
            prev_post_tran_id       INT, 
            system_trace_audit_nr   CHAR (6), 
            message_reason_code           CHAR (4), 
            retrieval_reference_nr  CHAR (12), 
            datetime_tran_local           DATETIME, 
            from_account_type       CHAR (2), 
            to_account_type               CHAR (2), 
            settle_currency_code    CHAR (3),                     
            settle_amount_impact    FLOAT,                  
            tran_type_desciption    VARCHAR (255),
            rsp_code_description    VARCHAR (255),
            settle_nr_decimals            INT,
            currency_alpha_code           CHAR (3),
            currency_name                 VARCHAR (20),           
            isPurchaseTrx                 INT,
            isWithdrawTrx                 INT,
            isRefundTrx                   INT,
            isDepositTrx                  INT,
            isInquiryTrx                  INT,
            isTransferTrx                 INT,
            isOtherTrx                    INT,
            structured_data_req           VARCHAR(MAX),
            tran_reversed                 INT,
            --merchant_acct_nr            VARCHAR(50),      
            payee                   VARCHAR(50),
            extended_tran_type            CHAR (4),--oremeyi added this 2009-04-22
            auth_id_rsp             VARCHAR(10),
            account_nr              VARCHAR(50)
      )

      

      
            
      DECLARE @idx                                    INT
      DECLARE @node_list                        VARCHAR(255)
      
      DECLARE @warning VARCHAR(255)
      DECLARE @report_date_end_next DATETIME
      DECLARE @node_name_list VARCHAR(255)
      DECLARE @date_selection_mode              VARCHAR(50)
      
      -- Get the list of nodes that will be used in determining the last closed batch
      SET @node_name_list = 'MEGAASPsrc'
      SET @date_selection_mode = @Period
                  
      -- Calculate the report dates
      --EXECUTE osp_rpt_get_dates_2015 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

        IF(@StartDate IS NULL OR @EndDate IS NULL ) BEGIN  
  EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT   

   SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)  
 SET @EndDate   = CONVERT(VARCHAR(30), @report_date_end, 112)  
   
   END  
    ELSE BEGIN  
      SET @report_date_start = @StartDate   
   SET @report_date_end = @EndDate   
    END 



      --EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


      DECLARE  @list_of_source_nodes  TABLE (source_node    VARCHAR(30)) 
      INSERT INTO  @list_of_source_nodes  SELECT part FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC;
      
      TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DES

      
      INSERT
                        INTO @report_result
SELECT
                        NULL AS Warning,
                        @StartDate as StartDate,  
                        @EndDate as EndDate, 
                        c.source_node_name,
                        dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
                        c.terminal_id, 
                        t.acquiring_inst_id_code,
                        c.terminal_owner,
                        c.merchant_type,
                        c.card_acceptor_id_code, 
                        c.card_acceptor_name_loc, 
                        c.source_node_name,
                        t.sink_node_name, 
                        t.tran_type, 
                        t.rsp_code_rsp, 
                        t.message_type, 
                        t.datetime_req,
                        dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
                        dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
                        dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
                        
                        t.post_tran_cust_id as TranID,
                        t.prev_post_tran_id, 
                        t.system_trace_audit_nr, 
                        t.message_reason_code, 
                        t.retrieval_reference_nr, 
                        t.datetime_tran_local, 
                        t.from_account_type, 
                        t.to_account_type, 
                        t.settle_currency_code, 
                        
                        dbo.formatAmount(                   
                              CASE
                                    WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
                                    ELSE t.settle_amount_impact
                              END
                              , t.settle_currency_code ) AS settle_amount_impact,                     
                        
                        dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
                        dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


                        dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
                        dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
                        dbo.currencyName(t.settle_currency_code) AS currency_name,

                        
                        dbo.fn_rpt_isPurchaseTrx(tran_type)       AS isPurchaseTrx,
                        dbo.fn_rpt_isWithdrawTrx(tran_type)       AS isWithdrawTrx,
                        dbo.fn_rpt_isRefundTrx(tran_type)         AS isRefundTrx,
                        dbo.fn_rpt_isDepositTrx(tran_type)        AS isDepositTrx,
                        dbo.fn_rpt_isInquiryTrx(tran_type)        AS isInquiryTrx,
                        dbo.fn_rpt_isTransferTrx(tran_type)       AS isTransferTrx,
                        dbo.fn_rpt_isOtherTrx(tran_type)          AS isOtherTrx,
                        t.structured_data_req,
                        t.tran_reversed,
                        payee,--oremeyi added this 2009-04-22
                        extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
                        auth_id_rsp ,
                        account_nr

                        
      FROM
                    post_tran_summary t (NOLOCK)
                         LEFT JOIN
                       tbl_merchant_account a (NOLOCK)
                        on c.card_acceptor_id_code = a.card_acceptor_id_code
                        
      WHERE                   

               (t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
                        AND
                        t.tran_completed = '1'
                        AND

                        t.tran_postilion_originated = 0
                        AND
                        (
                        left(t.message_type,2)='02' 
                        )
                        AND
                        c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
                        AND
                        t.tran_reversed = 0  -- eseosa 141010
                AND
                                      
                         t.settle_currency_code in ('566','840')
						 OPTION (RECOMPILE)
                        
                              
      IF @@ROWCOUNT = 0
            INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)                 
      

SELECT 
             StartDate,
            EndDate,
            isnull(settle_amount_impact * -1,0)  as amount,
            isnull(CASE                  
                  WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                  WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                  
                        WHEN tran_type IN ('20') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN -1
                  WHEN tran_type IN ('20') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN -1

                  WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                  
                        WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                        END,0) as tran_count,
                   settle_currency_code,
                  substring(terminal_id,1,1) as Terminal_type,
                   case when source_node_name like '%MIGS%' then 'MIGS'
                   when source_node_name like 'MEGASP%'
                   then left(RIGHT(source_node_name, LEN(source_node_name) - 6),len(RIGHT(source_node_name, LEN(source_node_name) - 6))-3)
                   when source_node_name like 'ADJ%'
                   then left(RIGHT(source_node_name, LEN(source_node_name) - 3),len(RIGHT(source_node_name, LEN(source_node_name) - 6))-3)
                   else source_node_name end as Bank

      
      FROM 
                  @report_result
      ORDER BY 
                  source_node_name, datetime_req

      
      

        OPTION(MAXDOP 12)
      END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_billing_details]    Script Date: 05/17/2016 16:30:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_billing_details]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SourceNodes	VARCHAR(4000),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE  @report_result TABLE
	(
                seq_num_id		BIGINT IDENTITY(1,1) UNIQUE,
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (9), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	DECLARE  @list_of_source_nodes  TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes  SELECT part FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC;
	


	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
			post_tran_summary t (NOLOCK)
			       LEFT JOIN
			     tbl_merchant_account a (NOLOCK)
				on c.card_acceptor_id_code = a.card_acceptor_id_code
				
	WHERE 			

				t.tran_completed = '1'
				AND

				t.tran_postilion_originated = 0
				AND
				(
				 (LEFT(t.message_type,2)  ='02') 
				)
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND
				t.tran_reversed = 0  -- eseosa 141010
                AND
								(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				
				AND              
				 t.settle_currency_code in ('566','840')
				OPTION(RECOMPILE)
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	


		SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req

	 
	

        OPTION(MAXDOP 12)
	END









































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_billing_investigate]    Script Date: 05/17/2016 16:30:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_billing_investigate]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNodes	text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON
	set TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 


	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	
	
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
		      post_tran_summary t JOIN
				tbl_merchant_account a (NOLOCK)
				on
				t.card_acceptor_id_code = a.card_acceptor_id_code
	WHERE 			

				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				
				AND
				t.tran_reversed = 0  -- eseosa 141010
                                
				
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				OPTION (RECOMPILE)
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
		 isnull(settle_amount_impact * -1,0)  as amount,
		 isnull(CASE			
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	
                        WHEN tran_type IN ('20') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN -1
                	WHEN tran_type IN ('20') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN -1

                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                	
            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END,0) as tran_count,
                   settle_currency_code,
                  substring(terminal_id,1,1) as Terminal_type,
                   case when source_node_name like '%MIGS%' then 'MIGS'
                   when source_node_name like 'MEGASP%'
                   then left(RIGHT(source_node_name, LEN(source_node_name) - 6),len(RIGHT(source_node_name, LEN(source_node_name) - 6))-3)
                   when source_node_name like 'ADJ%'
                   then left(RIGHT(source_node_name, LEN(source_node_name) - 3),len(RIGHT(source_node_name, LEN(source_node_name) - 6))-3)
                   else source_node_name end as Bank

	 
	FROM 
			#report_result
OPTION (RECOMPILE)
					
        
	END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_billing_VISA]    Script Date: 05/17/2016 16:30:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_billing_VISA]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(550),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE  @report_result TABLE
	(   
	       seq_num_id		BIGINT IDENTITY(1,1) UNIQUE,
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				VARCHAR (12), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	If @startdate is null 
set @report_date_start = dbo.DateOnly(getdate()-1)

If @enddate is null 
set @report_date_end = dbo.DateOnly(getdate()-1)




SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	DECLARE  @list_of_source_nodes TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes  SELECT PART FROM dbo.usf_split_string(@SourceNodes,',') ORDER BY PART ASC;

	
	
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp,
				account_nr

				
	FRO
				post_tran_summary t (NOLOCK) join
				tbl_merchant_account a (NOLOCK, INDEX(tbl_merchant_idx))
				ON 	c.card_acceptor_id_code a.card_acceptor_id_code
				
				
	WHERE 			
	
				t.tran_completed = '1'
				AND
								(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				
				AND
				t.tran_reversed = 0  -- eseosa 141010
                                
                                AND not( c.source_node_name = 'GTBMIGSsrc' and not t.settle_currency_code = '840')
				
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				option (recompile)
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
		 isnull(settle_amount_impact * -1,0)  as amount,
		 isnull(CASE			
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	
                        WHEN tran_type IN ('20') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN -1
                	WHEN tran_type IN ('20') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN -1

                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                	
            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END,0) as tran_count,
                   settle_currency_code,
                  substring(terminal_id,1,1)as Terminal_type,
                   case when CHARINDEX('MIGS', source_node_name)>0 then 'MIGS'
                      when LEFT(source_node_name,6)='MGASPV'
                   then left(RIGHT(source_node_name, LEN(source_node_name) - 6),len(RIGHT(source_node_name, LEN(source_node_name) - 6))-3)
                   
                   else source_node_name end as Bank

	 
	FROM 
			@report_result
option (recompile)
        
	END





































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_CUP_towner_ptsp]    Script Date: 05/17/2016 16:30:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_CUP_towner_ptsp]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	--@Acquirer		VARCHAR(255),
	---@AcquirerInstId		VARCHAR(255),
	--@SinkNode		VARCHAR(255),
	--@SourceNodes	VARCHAR(512),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id1 INT = NULL

AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			VARCHAR(20),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
               -- extended_tran_type_reward               CHAR (50),--Chioma added this 2012-07-03
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
	--extended_tran_type		CHAR (4),
		receiving_inst_id_code		VARCHAR(50),--oremeyi added this 2009-04-22
           --   rdm_amount                      float,
             --  Reward_Discount                 float,
              --  Addit_Charge                 DECIMAL(7,6),
              --  Addit_Party                 Varchar (10),
               -- Amount_Cap_RD               DECIMAL(9,0),
               -- Fee_Cap_RD               DECIMAL(9,0),
               -- Fee_Discount_RD          DECIMAL(9,7),
                Terminal_owner_code Varchar (4),
				ptsp_code			varchar (4)
	)

	--IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	--BEGIN	   
	   	--INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   --	SELECT * FROM #report_result
		--RETURN 1
	--END

	/*IF (@Acquirer IS NULL or Len(@Acquirer)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Merchant Acquirer name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END*/
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	--SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN

		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	--SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	--SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	--EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 


	--IF (@report_date_end < @report_date_start)
--	BEGIN
	   --	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   --	SELECT * FROM #report_result
		--RETURN 1
	--END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/

	--CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	--INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
                           --     extended_trans_type = ISNULL(y.extended_trans_type,'0000'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,0),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				ISNULL(account_nr,'not available'),

				payee,--oremeyi added this 2009-04-22
				--extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
                              --  ISNULL(y.rdm_amt,0),
                              --  R.Reward_Discount,
                             --   R.Addit_Charge,
                             --   R.Addit_Party,
                              --  R.Amount_Cap,
                              --  R.Fee_Cap,
                              --  R.Fee_Discount,
                                tt.Terminal_code,
								tp.ptsp_code	
				
	FROM
				post_tran_summary t (NOLOCK)
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				
				--left JOIN tbl_xls_settlement y (NOLOCK)

				--ON (c.terminal_id= y.terminal_id 
                                    --AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    --AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    --= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                --and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                --left JOIN Reward_Category r (NOLOCK)
                               -- ON y.extended_trans_type = r.reward_code
                                left JOIN tbl_terminal_owner tt (NOLOCK)
                                ON c.terminal_id = tt.terminal_id
							left JOIN tbl_ptsp tp (NOLOCK)
                                ON c.terminal_id = tp.terminal_id

	WHERE 			
				
					t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0100','0200','0220','0400','0420')---oremeyi removed 0120
			AND
			t.tran_completed = 1
			--AND
			--(t.acquiring_inst_id_code IN (SELECT AcquiringID FROM #list_of_AcquiringID) 
                   --      or 
                         --(substring (c.terminal_id,2,3) IN (SELECT CBN_Code FROM #list_of_CBN_Code)))
			AND
			 t.sink_node_name = 'CUPsnk'
                        AND
                        c.terminal_id like '2%'
						OPTION (RECOMPILE)
						
								
				
								
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req, message_type
END































































































































































































GO


/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa]    Script Date: 05/17/2016 16:30:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(255),	
	@IINs		VARCHAR(255)=NULL,
	@AcquirerInstId		VARCHAR (255)= NULL,
	@merchants		VARCHAR(512) = NULL,--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT = NULL ,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning, EndDate) VALUES ('Please supply the Web channel source node name.','yes')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr
				
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220')) 
				)
				--AND 
				--t.tran_completed = '1' 
				AND
				t.tran_reversed = '0'
				--AND
				--t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
				pan,				
				terminal_id,
				card_acceptor_id_code,
				card_acceptor_name_loc,
				message_type,
				datetime_req,
				system_trace_audit_nr,
				retrieval_reference_nr,
				settle_amount_req, 
				tran_type_desciption,
				rsp_code_description,
				currency_name,
				auth_id_rsp,
				account_nr ,
				TranID
	FROM 
			#report_result
	ORDER BY 
			datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa_omc]    Script Date: 05/17/2016 16:30:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa_omc]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(255),	
	@IINs		VARCHAR(255)=NULL,
	@AcquirerInstId		VARCHAR (255)= NULL,
	@merchants		VARCHAR(512) = NULL,--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT = NULL ,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		tran_amount_req		FLOAT, 
		tran_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50),
		acquirer_ref_no			VARCHAR(50),
		service_restriction_code	VARCHAR(50),
		src				VARCHAR(50),
		pos_card_data_input_ability   VARCHAR(50),
		pos_card_data_input_mode      VARCHAR(50),
		ird				VARCHAR(50),
		fileid				VARCHAR(50),
		session_id			VARCHAR(50)
		
		
		
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req, 
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.tran_currency_code,
				 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.tran_amount_req
						ELSE t.tran_amount_rsp
					END
					, t.tran_currency_code ) AS settle_amount_req,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.tran_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				m.acquirer_ref_no,	
				service_restriction_code,
				SUBSTRING(service_restriction_code,1,1) as src,	
				pos_card_data_input_ability,
				pos_card_data_input_mode,
				m.ird as ird,
				m.file_id as fileid,
				s.session_id
				
				
			
				
				
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK),
				mcipm_extract_trans m (nolock),
				mcipm_extract_transmission s (nolock)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				and m.post_tran_id = t.post_tran_id
				and s.transmission_nr = m.transmission_nr
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220')) 
				)
				--AND 
				--t.tran_completed = '1' 
				AND
				t.tran_reversed = '0'
				--AND
				--t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	
	SELECT 
				pan,				
				terminal_id,
				merchant_type,
				card_acceptor_id_code,
				card_acceptor_name_loc,
				message_type,
				datetime_req,
				system_trace_audit_nr,
				retrieval_reference_nr,
				tran_amount_req, 
				tran_type_desciption,
				rsp_code_description,
				currency_name,
				auth_id_rsp,
				account_nr ,
				TranID,
				acquirer_ref_no,
				service_restriction_code,
				src,
				pos_card_data_input_ability,
				pos_card_data_input_mode,
				ird,
				session_id,
				fileid
				
				
				
			
				
				
	FROM 
			#report_result
	ORDER BY 
			datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa_unextracted]    Script Date: 05/17/2016 16:30:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa_unextracted]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(255),	
	@IINs		VARCHAR(255)=NULL,
	@AcquirerInstId		VARCHAR (255)= NULL,
	@merchants		VARCHAR(512) = NULL,--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT = NULL ,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr
				
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				--mcipm_extract_trans m (nolock)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				--and m.post_tran_id = t.post_tran_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220')) 
				)
				--AND 
				--t.tran_completed = '1' 
				AND
				t.tran_reversed = '0'
				AND t.post_tran_id not in (select post_tran_id from mcipm_extract_trans)
				--AND
				--t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	
	SELECT 
				pan,				
				terminal_id,
				card_acceptor_id_code,
				card_acceptor_name_loc,
				message_type,
				datetime_req,
				system_trace_audit_nr,
				retrieval_reference_nr,
				settle_amount_req, 
				tran_type_desciption,
				rsp_code_description,
				currency_name,
				auth_id_rsp,
				account_nr ,
				TranID
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa_unextracted_test]    Script Date: 05/17/2016 16:30:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa_unextracted_test]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(255)
AS
BEGIN

	DECLARE
	 @IINs	VARCHAR(255),
	 @AcquirerInstId	VARCHAR(255)	,
	@merchants	VARCHAR(255)	 ,--this is the c.card_acceptor_id_code,
	 @show_full_pan	BIT  ,
	 @report_date_start DATETIME,
	@report_date_end DATETIME,
	@rpt_tran_id INT	

	
	
	

SET NOCOUNT ON
	
	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr
				
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				--mcipm_extract_trans m (nolock)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				--and m.post_tran_id = t.post_tran_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220')) 
				)
				--AND 
				--t.tran_completed = '1' 
				AND
				t.tran_reversed = '0'
				AND t.post_tran_id not in (select post_tran_id from mcipm_extract_trans)
				--AND
				--t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
 	and @IINs = NULL	
	and @AcquirerInstId = NULL		
	and @merchants = NULL	--this is the c.card_acceptor_id_code,
	and @show_full_pan = NULL	
	and @report_date_start = NULL 
	and @report_date_end = NULL 
	and @rpt_tran_id = NULL 	

					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	
	SELECT 
				pan,				
				terminal_id,
				card_acceptor_id_code,
				card_acceptor_name_loc,
				message_type,
				datetime_req,
				system_trace_audit_nr,
				retrieval_reference_nr,
				settle_amount_req, 
				tran_type_desciption,
				rsp_code_description,
				currency_name,
				auth_id_rsp,
				account_nr ,
				TranID
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_FBN]    Script Date: 05/17/2016 16:30:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_FBN]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		tran_amount_rsp			FLOAT,
		tran_currency_code		FLOAT, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_rsp,
				t.tran_currency_code,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran_summary t (NOLOCK) JOIN
				tbl_merchant_account a (NOLOCK)
				on
				t.card_acceptor_id_code = a.card_acceptor_id_code
	WHERE 			
				
	
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				t.tran_reversed = '0'
				--AND 
				--t.tran_completed = 1 
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				OPTION (recompile)
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_gtb_naira]    Script Date: 05/17/2016 16:30:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_gtb_naira]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@Currency_code		VARCHAR(4), -- included by eseosa to specify currency
	@rate			numeric
AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount((t.settle_amount_req/@rate), t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount((t.settle_amount_rsp/@rate), t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount((t.settle_tran_fee_rsp/@rate), t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * (t.settle_amount_impact/@rate)
						ELSE (t.settle_amount_impact/@rate)
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM  
	          post_tran_summary t (NOLOCK)
			 left join
			  tbl_merchant_account a (NOLOCK)
			  t.card_acceptor_id_code = a.card_acceptor_id_code
				
				
	WHERE 			
				
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				and
				t.tran_currency_code = @currency_code
				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				OPTION (RECOMPILE)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_monthly]    Script Date: 05/17/2016 16:30:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_monthly]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Previous month'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	

	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran_summary t  (nolock) 
				LEFT JOIN
				tbl_merchant_account a (NOLOCK)
				ON
				t.card_acceptor_id_code = a.card_acceptor_id_code
				
				
	WHERE 			
	
				
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220')) 
				)
				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
			 OPTION (RECOMPILE)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_msc]    Script Date: 05/17/2016 16:30:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_msc]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@Currency_code		VARCHAR(3), -- included by eseosa to specify currency
	@local_msc		NUMERIC(18,2), 		-- Included by eseosa on 9/07/13 to specify msc based on card brands
	@foreign_msc	NUMERIC(18,2)			-- saa
AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50),
		merchant_service_charge		NUMERIC(18,2)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM @report_result
		RETURN 1
	END

*/


	 DECLARE  @list_of_source_nodes TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes,',') ORDER BY part ASC

	DECLARE  @list_of_IINs  TABLE(IIN VARCHAR(30)) 
	INSERT INTO  @list_of_IINs SELECT part FROM usf_split_string(@IINs,',') ORDER BY part ASC 

	DECLARE  @list_of_card_acceptor_id_codes  TABLE(card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM usf_split_string(@merchants,',') ORDER BY part ASC 
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				case (select top 1 country_numeric from mcipm_ip0040t1 (nolock) where LEFT (issuer_acct_range_low,6) = LEFT (c.pan,6)) when '566' then @local_msc else @foreign_msc end as merchant_service_charge

				
	FROM
				post_tran_summary t (NOLOCK)
				LEFT JOIN
				tbl_merchant_account a (NOLOCK)
				ON
				c.card_acceptor_id_code = a.card_acceptor_id_code
	WHERE 			
				t.tran_completed = '1'
				AND
								(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				and
				t.tran_currency_code = @currency_code
				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				
				OPTION (RECOMPILE)
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_msc1_old]    Script Date: 05/17/2016 16:30:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_msc1_old]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@Currency_code		VARCHAR(3), -- included by eseosa to specify currency
	@local_msc		NUMERIC(18,4), 		-- Included by eseosa on 9/07/13 to specify msc based on card brands
	@foreign_msc	NUMERIC(18,4)			-- saa
AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		tran_amount_req		FLOAT, 
		tran_amount_rsp		FLOAT,
		tran_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		tran_currency_code	CHAR (3),				
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		tran_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50),
		merchant_service_charge		NUMERIC(18,4)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req, 
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_rsp,
				dbo.formatAmount(t.tran_tran_fee_rsp, t.tran_currency_code) AS tran_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.tran_currency_code, 
				
				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.tran_currency_code) AS tran_nr_decimals,
				dbo.currencyAlphaCode(t.tran_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.tran_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				case (select top 1 country_numeric from mcipm_ip0040t1 (nolock) where substring (issuer_acct_range_low,1,6) = substring (c.pan,1,6)) when '566' then @local_msc else @foreign_msc end as merchant_service_charge

				
	FROM
				post_tran_summary t (NOLOCK) 
				LEFT JOIN
				tbl_merchant_account a (NOLOCK)
				ON
				t.card_acceptor_id_code = a.card_acceptor_id_code
				
	WHERE 			

				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				and
				t.tran_currency_code = @currency_code
				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				OPTION (RECOMPILE)
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_msc2_old]    Script Date: 05/17/2016 16:30:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_msc2_old]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@Currency_code		VARCHAR(3), -- included by eseosa to specify currency
	@local_msc		NUMERIC(18,4), 		-- Included by eseosa on 9/07/13 to specify msc based on card brands
	@foreign_msc	NUMERIC(18,4)			-- saa
AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		tran_amount_req		FLOAT, 
		tran_amount_rsp		FLOAT,
		tran_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		tran_currency_code	CHAR (3),				
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		tran_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50),
		merchant_service_charge		NUMERIC(18,4)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req, 
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_rsp,
				dbo.formatAmount(t.tran_tran_fee_rsp, t.tran_currency_code) AS tran_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.tran_currency_code, 
				
				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.tran_currency_code) AS tran_nr_decimals,
				dbo.currencyAlphaCode(t.tran_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.tran_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				case ((select top 1 country_numeric from mcipm_ip0040t1 (nolock) where substring (issuer_acct_range_low,1,6) = substring (c.pan,1,6))union (select top 1 country_numeric from visa_bin_table (nolock) where substring (issuer_acct_range_low,1,6) = substring (c.pan,1,6))) when '566' then @local_msc else @foreign_msc end as merchant_service_charge
				

				
	FROM
				 post_tran_summary t (NOLOCK) 
				 LEFT JOIN
				tbl_merchant_account a (NOLOCK)
				ON
				t.card_acceptor_id_code = a.card_acceptor_id_code
				
				
	WHERE 			
			
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				t.rsp_code_req = '00'
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				and
				t.tran_amount_req != '0'
				and
				t.tran_currency_code = @currency_code

				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				OPTION (RECOMPILE)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_naira_FBN]    Script Date: 05/17/2016 16:30:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_naira_FBN]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@rate		FLOAT(6)	

AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate					VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(12),
		terminal_owner  		CHAR(25),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		tran_amount_rsp			FLOAT,
		tran_currency_code		FLOAT,
		settle_currency_amount		FLOAT,		
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,                                                               
		structured_data_req		TEXT,
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(12),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	
	SET @StartDate =  REPLACE(CONVERT(VARCHAR(10),@report_date_start,111),'/', '-') 
	SET @EndDate = REPLACE(CONVERT(VARCHAR(10),@report_date_end,111),'/', '-') 
	
	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM @report_result
		RETURN 1
	END

*/

	DECLARE   @list_of_source_nodes  TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes, ',') ORDER BY part ASC;
	
	DECLARE  @list_of_IINs TABLE(IIN	VARCHAR(30)) 
	INSERT INTO  @list_of_IINs  SELECT part FROM usf_split_string(@IINs, ',') ORDER BY part ASC;
	
	DECLARE  @list_of_card_acceptor_id_codes TABLE (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM usf_split_string(@merchants, ',') ORDER BY part ASC;
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_response,
				t.tran_currency_code,
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				(tran_amount_rsp / @rate) AS settle_currency_amount,
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,	
			
				--dbo.formatAmount(t.tran_amount_rsp * 150) AS tran_settle_value,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran_summary t (NOLOCK) 
				LEFT JOIN
				tbl_merchant_account a (NOLOCK)
				ON
				t.card_acceptor_id_code = a.card_acceptor_id_code
				
	WHERE 			

				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				tran_currency_code = '566'
				
				AND
				t.tran_reversed = '0'
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				OPTION (RECOMPILE)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_naira_msc_apply]    Script Date: 05/17/2016 16:30:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_naira_msc_apply]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50),
		merchant_service_charge		VARCHAR(15)--adeola added 27/09/2013
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				e.merchant_service_charge
				
				
	FROM
				post_tran_summary t  (NOLOCK)
				LEFT JOIN
				tbl_merchant_account a (NOLOCK)
				ON
				t.card_acceptor_id_code = a.card_acceptor_id_code
				JOIN
				merchant_msc_table e (NOLOCK)
				ON
				c.card_acceptor_id_code = e.card_acceptor_id_code
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code = a.card_acceptor_id_code
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				settle_currency_code = '566'
				AND 
				t.tran_completed = '1' 
				AND
				t.tran_reversed = '0' -- included by eseosa -- exclude reversals

				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				OPTION (RECOMPILE)
				
					
	IF @@ROWCOUNT = 0

		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_new]    Script Date: 05/17/2016 16:30:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_new]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran_summary t (NOLOCK) 
				LEFT JOIN
				tbl_merchant_account a (NOLOCK)
				ON
				c.card_acceptor_id_code = a.card_acceptor_id_code
				
	WHERE 			

				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				t.tran_reversed = '0'
				--AND 
				--t.tran_completed = 1 
				
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				OPTION (RECOMPILE)
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_NGN]    Script Date: 05/17/2016 16:30:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_NGN]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL
	

AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30), 
		EndDate					VARCHAR(30),
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		tran_amount_rsp			FLOAT,
		tran_currency_code		FLOAT,
		settle_currency_amount		FLOAT,		
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50),
		dollar_amount			FLOAT(10),
		RATE				varchar(50)
		
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	SET @StartDate =  REPLACE(CONVERT(VARCHAR(10),@report_date_start,111),'/', '-') 
	SET @EndDate = REPLACE(CONVERT(VARCHAR(10),@report_date_end,111),'/', '-') 

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM @report_result
		RETURN 1
	END

*/

	DECLARE  @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string( @SourceNodes, ',');
	
	DECLARE  @list_of_IINs TABLE (IIN	VARCHAR(30)) 
	INSERT INTO  @list_of_IINs SELECT part FROM usf_split_string( @IINs, ',');
	
	DECLARE  @list_of_card_acceptor_id_codes  TABLE(card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM usf_split_string(@merchants, ',');
	-- Only look at 02xx messages that were not fully reversed.
	
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_response,
				t.tran_currency_code,
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				(tran_amount_rsp / (select round (rate,2) from tm_currencies
					where currency_code = 566 ))/100 AS settle_currency_amount,
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,	
			
				--dbo.formatAmount(t.tran_amount_rsp * 150) AS tran_settle_value,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				(t.tran_amount_rsp / (select round (rate,2) from tm_currencies
					where currency_code = 566 ))/100 AS dollar_amount,
				(t.tran_amount_rsp)/(t.tran_amount_rsp / (select round (rate,2) from tm_currencies
					where currency_code = 566 )) AS RATE

				
	FROM
		     post_tran_summary t (NOLOCK)
		  join
		  tbl_merchant_account a (NOLOCK, INDEX(card_acceptor_id_code_idx))	
		  t.card_acceptor_id_code = a.card_acceptor_id_code
	WHERE 			

				t.tran_completed = '1'
				AND
				(t.post_tran_cust_id >= @first_post_tran_cust_id) 
				AND 
				(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				tran_currency_code = '566'
				
				AND
				t.tran_reversed = '0'
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				OPTION (RECOMPILE)
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_omc]    Script Date: 05/17/2016 16:30:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_omc]
	@StartDate		VARCHAR (30),	-- yyyymmdd
	@EndDate		VARCHAR (30),	-- yyyymmdd
	@SourceNodes	VARCHAR(255),	
	@IINs		VARCHAR(255)=NULL,
	@AcquirerInstId		VARCHAR (255)= NULL,
	@merchants		VARCHAR(512) = NULL,--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT = NULL ,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

		DECLARE @report_result  TABLE (

			Warning	VARCHAR(255), 
			StartDate	DATETIME,
			EndDate	DATETIME,
			source_node_name	varchar(30),
			pan	varchar(20),
			terminal_id	VARCHAR(10),
			acquiring_inst_id_code	varchar(20),
			terminal_owner	varchar(25),
			merchant_type	VARCHAR(10),
			card_acceptor_id_code	VARCHAR(20),
			card_acceptor_name_loc	VARCHAR(40),
			sink_node_name	varchar(30),
			tran_type	VARCHAR(5),
			rsp_code_rsp	VARCHAR(5),
			message_type	VARCHAR(10),
			datetime_req	DATETIME,
			tran_amount_req	FLOAT,
			tran_amount_rsp	FLOAT,
			settle_tran_fee_rsp	FLOAT	,
			TranID	BIGINT,
			prev_post_tran_id	BIGINT,
			system_trace_audit_nr	VARCHAR(10),
			message_reason_code	VARCHAR(10),
			retrieval_reference_nr	VARCHAR(15),
			datetime_tran_local	DATETIME,
			from_account_type	VARCHAR(10),
			to_account_type		VARCHAR(10),
			tran_currency_code	VARCHAR(10),
			settle_amount_req	float,
			tran_type_desciption	VARCHAR(255),
			rsp_code_description   VARCHAR(255),
			settle_nr_decimals	int,
			currency_alpha_code	VARCHAR(10),
			currency_name	VARCHAR(50),
			isPurchaseTrx	int	,
			isWithdrawTrx	int	,
			isRefundTrx	int	,
			isDepositTrx	int	,
			isInquiryTrx	int	,
			isTransferTrx	int	,
			isOtherTrx	int	,
			structured_data_req	text,
			tran_reversed	VARCHAR(10),
			payee		VARCHAR(30),
			extended_tran_type	VARCHAR(10),
			auth_id_rsp	VARCHAR(10),
			account_nr	VARCHAR(70),
			acquirer_ref_no	VARCHAR(50),
			service_restriction_code	VARCHAR(10),
			src	VARCHAR(10),
			pos_card_data_input_ability	VARCHAR(10),
			pos_card_data_input_mode	VARCHAR(10),
			ird		VARCHAR(10),
			fileid		VARCHAR(50),
			session_id	int	

		)


	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	

	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
	
    SELECT @StartDate = REPLACE(@StartDate, '-', '');
	SELECT @EndDate = REPLACE(@EndDate, '-', '');
	
	SELECT @StartDate = REPLACE(@StartDate, '.', '');
	SELECT @EndDate = REPLACE(@EndDate, '.', '');
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates_2 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	 SET @StartDate =  DATEADD(D, 0, DATEDIFF(D, 0, @report_date_start))
	 SET @EndDate =   DATEADD(D, 0, DATEDIFF(D, 0, @report_date_end))

	SELECT @rpt_tran_id = (SELECT MIN(first_post_tran_cust_id)  FROM post_normalization_session (NOLOCK) WHERE datetime_creation  >= DATEADD(dd,-1,@report_date_start))


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM @report_result
		RETURN 1
	END

*/


	DECLARE @list_of_source_nodes  TABLE  (source_node	VARCHAR(4000)) 
   
	INSERT INTO  @list_of_source_nodes  SELECT part AS 'source_node' FROM usf_split_string(@SourceNodes,',')
	
	DECLARE  @list_of_IINs TABLE(IIN	VARCHAR(100)) 
	INSERT INTO  @list_of_IINs SELECT part AS 'iin' FROM usf_split_string( @IINs,',')
	
	DECLARE  @list_of_card_acceptor_id_codes TABLE (card_acceptor_id_code	VARCHAR(100)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part AS 'card_acceptor_id_code' FROM usf_split_string( @merchants,',');

	--INSERT INTO  @list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req, 
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.tran_currency_code,
				 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.tran_amount_req
						ELSE t.tran_amount_rsp
					END
					, t.tran_currency_code ) AS settle_amount_req,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,

				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.tran_currency_code)  AS currency_name,			
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				m.acquirer_ref_no,	
				service_restriction_code,
				SUBSTRING(service_restriction_code,1,1) as src,	
				pos_card_data_input_ability,
				pos_card_data_input_mode,
				m.ird as ird,
				m.file_id as fileid,
				s.session_id
				
				
	FROM
				post_tran_summary t (NOLOCK) 
				join
				tbl_merchant_account a (NOLOCK)
				ON
				t.card_acceptor_id_code = a.card_acceptor_id_code
				JOIN
				mcipm_extract_trans m (nolock) 
				ON
				 m.post_tran_id = t.post_tran_id
				 JOIN
				mcipm_extract_transmission s (nolock)
				ON s.transmission_nr = m.transmission_nr
				
	WHERE 			
			
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				--AND 
				--t.tran_completed = '1' 
				AND
				t.tran_reversed = '0'
				--AND
				--t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				OPTION (recompile)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	
	SELECT 
				pan,				
				terminal_id,
				merchant_type,
				card_acceptor_id_code,
				card_acceptor_name_loc,
				message_type,
				datetime_req,
				system_trace_audit_nr,
				retrieval_reference_nr,
				tran_amount_req, 
				tran_type_desciption,
				rsp_code_description,
				currency_name,
				auth_id_rsp,
				account_nr ,
				TranID,
				acquirer_ref_no,
				service_restriction_code,
				src,
				pos_card_data_input_ability,
				pos_card_data_input_mode,
				ird,
				session_id,
				fileid
				
				
				
			
				
				
	FROM 
			@report_result
	ORDER BY 
			datetime_req
			
			

END






/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_rates_2]    Script Date: 05/17/2016 16:30:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_rates_2]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@rate		FLOAT(6),
	@currency	VARCHAR(5)	

AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		tran_amount_rsp			FLOAT,
		tran_currency_code		FLOAT,
		settle_currency_amount		FLOAT,		
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	set @currency	= isnull(@currency, '566');
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_response,
				t.tran_currency_code,
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				(tran_amount_rsp / @rate) AS settle_currency_amount,
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,	
			
				--dbo.formatAmount(t.tran_amount_rsp * 150) AS tran_settle_value,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran_summary t (NOLOCK) left  join
				tbl_merchant_account a (NOLOCK)
				on
				c.card_acceptor_id_code = a.card_acceptor_id_code
				
	WHERE 			
			
				
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				tran_currency_code = @currency
				
				AND
				t.tran_reversed = '0'
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				OPTION (RECOMPILE)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_rates_3]    Script Date: 05/17/2016 16:30:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_rates_3]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate	     VARCHAR(30),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@rate		FLOAT(6)	

AS
BEGIN

	SET NOCOUNT ON
	set transaction isolation read uncommited

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		tran_amount_rsp			FLOAT,
		tran_currency_code		FLOAT,
		settle_currency_amount		FLOAT,		
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM @report_result
		RETURN 1
	END

*/

	
	DECLARE @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT PART FROM usf_split_string(@SourceNodes, ',')
	
	DECLARE  @list_of_IINs TABLE(IIN	VARCHAR(30)) 
	INSERT INTO  @list_of_IINs SELECT PART FROM usf_split_string(@IINs, ',')
	
	DECLARE  @list_of_card_acceptor_id_codes TABLE(card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT PART FROM usf_split_string(@merchants, ',')
	-- Only look at 02xx messages that were not fully reversed.

	
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_response,
				t.tran_currency_code,
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				(tran_amount_rsp / @rate) AS settle_currency_amount,
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,	
			
				--dbo.formatAmount(t.tran_amount_rsp * 150) AS tran_settle_value,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
	   post_tran_summary t (NOLOCK)
		LEFT JOIN
				tbl_merchant_account a (NOLOCK, INDEX(card_acceptor_id_code_idx))
			ON	c.card_acceptor_id_code = a.card_acceptor_id_code
	WHERE 			
					
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_completed = '1'
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				tran_currency_code = '566'
				
				AND
				t.tran_reversed = '0'
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND 
				tran_amount_rsp > 0
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_rates_msc]    Script Date: 05/17/2016 16:30:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_rates_msc]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@rate		FLOAT(6)	

AS
BEGIN

	SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABlE   #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		tran_amount_rsp			FLOAT,
		tran_currency_code		FLOAT,
		settle_currency_amount		FLOAT,		
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50),
		merchant_service_charge		VARCHAR(15)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')


	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABlE   #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABlE   #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABlE   #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_response,
				t.tran_currency_code,
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				(tran_amount_rsp / @rate) AS settle_currency_amount,
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,	
			
				--dbo.formatAmount(t.tran_amount_rsp * 150) AS tran_settle_value,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				e.merchant_service_charge

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK),
				merchant_msc_table e (NOLOCK)
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				tran_currency_code = '566'
				
				AND
				t.tran_reversed = '0'
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND
				c.card_acceptor_id_code = e.card_acceptor_id_code
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_settle_currency]    Script Date: 05/17/2016 16:30:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_settle_currency]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	

	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				AND
				c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--(
				--(t.message_type IN ('0100')) --- changed from 0220 to 0110 to pick settlement amt in settlement currency
				--)
				AND 
				t.tran_completed = 1 
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0

		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_uba_visa_acquiring]    Script Date: 05/17/2016 16:30:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_uba_visa_acquiring]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@Currency_code		VARCHAR(3) -- included by eseosa to specify currency
AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE   @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate					VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(25),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (512),	 
		card_acceptor_name_loc	CHAR (999), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(max),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
		--tran_tran_fee_rsp		INT,     --sopeju added this
		--merchant_service_charge	INT,	 --sopeju added this
		--tran_amount_rsp			INT		 --sopeju added this
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	SET  @StartDate= CONVERT(CHAR(8),@report_date_start  , 112)
	SET @EndDate= CONVERT(CHAR(8), @report_date_end , 112)

--	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')	   	SELECT * FROM @report_result
		RETURN 1
	END*/
		DECLARE  @list_of_source_nodes TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM dbo.usf_split_string (@SourceNodes, ',') ORDER BY part ASC;
	
	DECLARE  @list_of_IINs TABLE(IIN	VARCHAR(30)) 
	INSERT INTO  @list_of_IINs SELECT part FROM dbo.usf_split_string (@IINs, ',') ORDER BY part ASC;
	
	DECLARE  @list_of_card_acceptor_id_codes TABLE(card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM dbo.usf_split_string (@merchants, ',') ORDER BY part ASC; 
	-- Only look at 02xx messages that were not fully reversed.
	

DECLARE @first_post_tran_id BIGINT

		DECLARE @last_post_tran_id BIGINT

		EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT
	-- Only look at 02xx messages that were not fully reversed.
	print @first_post_tran_id 

		print @last_post_tran_id 
		print @report_date_start 
		print @report_date_end 
	INSERT
				INTO @report_result
	SELECT 
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				--t.tran_tran_fee_rsp,
				--t.tran_amount_rsp,
				--merchant_service_charge,
				
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

	
				
	FROM
		 post_tran t (nolock)
		 JOIN post_tran_cust c (nolock)
			ON t.post_tran_cust_id = c.post_tran_cust_id
		LEFT JOIN tbl_merchant_account a (NOLOCK)
			ON c.card_acceptor_id_code = a.card_acceptor_id_code		
				
	WHERE 			
				
				t.tran_completed = '1'
                 AND
							(t.post_tran_id >= @first_post_tran_id) 
			AND 
			datetime_req >=@report_date_start
			AND
			
			(t.post_tran_id <= @last_post_tran_id) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				LEFT(t.message_type,2) = '02' 
				)
				and
				t.tran_currency_code = @currency_code
				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				--AND
				--(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				c.source_node_name =  @SourceNodes
				-- IN (SELECT source_node FROM @list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END
















GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_visa]    Script Date: 05/17/2016 16:30:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE[dbo].[osp_rpt_b04_web_pos_acquirer_visa]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@Currency_code		VARCHAR(3) -- included by eseosa to specify currency
AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MGASPVGTBsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result

		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				and
				t.tran_currency_code = @currency_code
				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b05_1]    Script Date: 05/17/2016 16:30:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b05_1]
	@StartDate		CHAR(8),		-- yyyymmdd
	@EndDate			CHAR(8),		-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@SinkNode		VARCHAR(40)
AS
BEGIN
	-- This is used by the B05 - Switched IN report

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				DATETIME,
		EndDate					DATETIME,
		SourceNode				VARCHAR (30),
		SinkNode					VARCHAR (30),
		SinkNodeAlias			VARCHAR (30),
		TranType					CHAR (2),
		NrTrans					INT,
		SettleCurrency			CHAR (3),
		TransactionAmount		FLOAT,
		SurchargeAmount		FLOAT,
		CurrencyName			VARCHAR (20),
		CurrencyNrDecimals	INT,
		isCheckDeposit			INT,
		isCashDeposit			INT,
		isEnvelopeDeposit		INT
	)

	DECLARE @warning 			VARCHAR (255)

	-- Validate source node
	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		SET @warning = 'Please supply the Network Name parameter.'

		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next	DATETIME
	DECLARE @node_name_list			VARCHAR(255)
	DECLARE @date_selection_mode	VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SourceNode
	SET @date_selection_mode = 'Last business day'

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Only look at 02xx messages that were not fully reversed.

	-- We are using the UNION in order to make sure we still return the PARAMETERS, even if there are no transactions in the resultset.
	-- The way the reports has been configured, the FIRST query of the UNION should be the one returning the PARAMETERs only

	INSERT INTO 
		#report_result
	SELECT
		NULL as Warning,
		@report_date_start as StartDate,
		@report_date_end as EndDate,
		@SourceNode as SourceNode,
		sink_node_name as SinkNode,
		SinkNodeAlias =
		(
			CASE
				WHEN @SinkNode IS NULL THEN sink_node_name
				ELSE
					(
						CASE
							WHEN sink_node_name = @SinkNode THEN sink_node_name
							ELSE '-Other-'
						END
					)
			END
		),
		tran_type as TranType,
		SUM(nr_trans) AS NrTrans,
		settle_amount_currency as SettleCurrency,
		dbo.formatAmount
		(
			SUM
			(
				CASE
					-- The settle_amount_impact field will typically be negative for Debit transaction types, but we want to display those amount as positive on this report
					WHEN (cast(tran_type as INT) between 0 and 19 or cast(tran_type as INT) between 50 and 59) THEN -1 * settle_amount_impact
					ELSE settle_amount_impact
				END
			), settle_amount_currency
		) AS TransactionAmount,
	
		dbo.formatAmount
		(
			SUM(-1 * surcharge_amount_impact), settle_amount_currency
		) AS SurchargeAmount,
		dbo.currencyName(settle_amount_currency) 										AS CurrencyName,
		dbo.currencyNrDecimals(settle_amount_currency) 								AS CurrencyNrDecimals,
		dbo.fn_rpt_isElectronicCheckDeposit(tran_type, extended_tran_type)	AS isCheckDeposit,
		dbo.fn_rpt_isCashDepositBNA(tran_type, extended_tran_type)				AS isCashDeposit,
		dbo.fn_rpt_isEnvelopeDeposit(tran_type, extended_tran_type)				AS isEnvelopeDeposit
	FROM
		post_ds_nodes WITH (NOLOCK)
	WHERE
		recon_business_date >= @report_date_start
		AND
		recon_business_date <= @report_date_end
		AND
		tran_postilion_originated = 0
		AND
		rsp_code IN ('00','08', '10', '11', '16')
		AND
		source_node_name = @SourceNode
		AND
		(
			message_type IN ('0200','0220')
			OR
			(
				-- We do not want Reversals that do not have any financial impact
				message_type IN ('0400', '0420')
				AND
				(
					settle_amount_impact <> 0 
					OR 
					surcharge_amount_impact <> 0
				)
			)
		)
		AND
		dbo.fn_rpt_isAutomatedDeposit(tran_type, extended_tran_type) = 1
	GROUP BY
		sink_node_name, 
		tran_type, 
		extended_tran_type,
		settle_amount_currency

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO #report_result 
			(Warning, 
			StartDate, 
			EndDate, 
			SourceNode, 
			SinkNode) 
		VALUES 
			('No transactions.', 
			@report_date_start, 
			@report_date_end, 
			@SourceNode, 
			@SinkNode)
	END

	SELECT * FROM #report_result
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b05_1_exceptions]    Script Date: 05/17/2016 16:30:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b05_1_exceptions]
	@report_date_start		DATETIME,
	@report_date_end		DATETIME,
	@SourceNode			VARCHAR(40),
	@SinkNode			VARCHAR(40)
AS
BEGIN
	-- This is used by the B05 - Switched IN report

	CREATE TABLE #report_result
	(
		NrAborted				INT,
		NrStandInApproved		INT,
		NrStandInDeclined		INT,
		NrDeclinedForcePost	INT
	)

	-- We do not have to validate the parameter, because this proc will be called from a subreport and the paramaeters have
	--	already been validated by the stored proc of the main report.

	DECLARE @nr_aborted 					INT
	DECLARE @nr_stand_in_approved		INT
	DECLARE @nr_stand_in_declined		INT
	DECLARE @nr_declined_force_post	INT

	--Aborted Transactions
	SELECT
		@nr_aborted = SUM(nr_trans)
	FROM
		post_ds_nodes WITH (NOLOCK)
	WHERE 
		recon_business_date >= @report_date_start
		AND 
		recon_business_date <= @report_date_end 
		AND 
		tran_postilion_originated = 0
		AND 
		source_node_name = @SourceNode 
		AND 
		(
			@SinkNode IS NULL 
			OR 
			sink_node_name = @SinkNode
		)
		AND 
		message_type IN ('0200','0220','0420') 
		AND 
		tran_aborted = 1
		AND
		dbo.fn_rpt_isAutomatedDeposit(tran_type, extended_tran_type) = 1

	IF (@@ROWCOUNT = 0 OR @nr_aborted IS NULL)
	BEGIN
		SELECT @nr_aborted = 0
	END	
	-----------------------------------------------------------------------------
	
	--Stand-in Transactions
	SELECT
		@nr_stand_in_approved = SUM(nr_trans)
	FROM
		post_ds_nodes WITH (NOLOCK)
	WHERE 
		recon_business_date >= @report_date_start
		AND 
		recon_business_date <= @report_date_end
		AND 
		tran_postilion_originated = 0
		AND 
		source_node_name = @SourceNode 
		AND 
		(
			@SinkNode IS NULL 
			OR 
			sink_node_name = @SinkNode
		) 
		AND 
		message_type IN ('0200') 
		AND 
		postilion_stand_in = 1
		AND 
		rsp_code IN ('00','08', '10', '11', '16')
		AND
		dbo.fn_rpt_isAutomatedDeposit(tran_type, extended_tran_type) = 1

	IF (@@ROWCOUNT = 0 OR @nr_stand_in_approved IS NULL)
	BEGIN
		SELECT @nr_stand_in_approved = 0
	END
	-----------------------------------------------------------------------------
	
	--Declined Transactions
	SELECT
		@nr_stand_in_declined = SUM(nr_trans)
	FROM
		post_ds_nodes WITH (NOLOCK)
	WHERE 
		recon_business_date >= @report_date_start 
		AND 
		recon_business_date <= @report_date_end 
		AND 
		tran_postilion_originated = 0
		AND 
		source_node_name = @SourceNode AND 
		(
			@SinkNode IS NULL 
			OR 
			sink_node_name = @SinkNode
		) 
		AND 
		message_type IN ('0200') 
		AND 
		postilion_stand_in = 1
		AND 
		rsp_code <> '91'	-- There seems to be a bug in Office where some transacations marked as '91' are also marked as stand-in.
		AND 
		NOT rsp_code IN ('00','08', '10', '11', '16')
		AND
		dbo.fn_rpt_isAutomatedDeposit(tran_type, extended_tran_type) = 1

	IF (@@ROWCOUNT = 0 OR @nr_stand_in_declined IS NULL)
	BEGIN
		SELECT @nr_stand_in_declined = 0
	END
	-----------------------------------------------------------------------------
	
	--Declined Force Post Transations
	SELECT
		@nr_declined_force_post = SUM(nr_trans)
	FROM
		post_ds_nodes WITH (NOLOCK)
	WHERE
		recon_business_date >= @report_date_start
		AND
		recon_business_date <= @report_date_end
		AND
		tran_postilion_originated = 0
		AND
		source_node_name = @SourceNode
		AND
		(
			@SinkNode IS NULL 
			OR 
			sink_node_name = @SinkNode 
			OR sink_node_name IS NULL
		)
		AND
		message_type IN ('0220','0420')
		AND
		NOT rsp_code IN ('00','08','10','11','16')
		AND
		dbo.fn_rpt_isAutomatedDeposit(tran_type, extended_tran_type) = 1

	IF (@@ROWCOUNT = 0 OR @nr_declined_force_post IS NULL)
	BEGIN
		SELECT @nr_declined_force_post = 0
	END
	-----------------------------------------------------------------------------

	INSERT INTO 
		#report_result
	SELECT 
		@nr_aborted 				AS NrAborted, 
		@nr_stand_in_approved 	AS NrStandInApproved, 
		@nr_stand_in_declined 	AS NrStandInDeclined, 
		@nr_declined_force_post AS NrDeclinedForcePost

	SELECT * FROM #report_result
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06]    Script Date: 05/17/2016 16:30:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_Detailed_verve_int]    Script Date: 05/17/2016 16:30:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[osp_rpt_b06_all_Detailed_verve_int]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2),
		acquiring_inst_id_code		VARCHAR (225),
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 
		Tran_amount_rsp				FLOAT,
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 	
		tran_reversed				INT,	
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description		VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999)
	)			

	IF (@SinkNode IS NULL or Len(@SinkNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	

	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id,
			c.terminal_owner,
                        c.source_node_name, 
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.acquiring_inst_id_code,
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS Tran_amount_rsp,

			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,	
			--t.tran_amount_rsp,		
			t.settle_currency_code, 
			
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN t.settle_amount_impact
						ELSE -1 * t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			isnull(t.retention_data,0)
			
	FROM

			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
            --left join 
            --post_tran tt (nolock) on (t.post_tran_cust_id = tt.post_tran_cust_id and 
                                         -- tt.tran_postilion_originated = 1
                                          --and t.tran_nr = tt.tran_nr)
	
WHERE 		c.post_tran_cust_id >= @rpt_tran_id
            AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end)
			/*AND
			(t.datetime_req >= @report_date_start) 
			AND 
			(t.datetime_req <= @report_date_end) */
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420')
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01','00')
			AND
			t.rsp_code_rsp IN ('00','11','08','10','16')
		
		
             AND
             t.sink_node_name  = 'MEGASWTsnk'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
           
			--AND
			--c.terminal_id like '1%'
			
	--insert into 		
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   *

	
	FROM
			#report_result 
	
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_Detailed_verve_int-test]    Script Date: 05/17/2016 16:30:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[osp_rpt_b06_all_Detailed_verve_int-test]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2),
		acquiring_inst_id_code		VARCHAR (225),
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 
		Tran_amount_rsp				FLOAT,
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 	
		tran_reversed				INT,	
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description		VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999)
	)			

	IF (@SinkNode IS NULL or Len(@SinkNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	

	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id,
			c.terminal_owner,
                        c.source_node_name, 
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.acquiring_inst_id_code,
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS Tran_amount_rsp,

			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,	
			--t.tran_amount_rsp,		
			t.settle_currency_code, 
			
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN t.settle_amount_impact
						ELSE -1 * t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			isnull(t.retention_data,0)
			
	FROM

			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
            --left join 
            --post_tran tt (nolock) on (t.post_tran_cust_id = tt.post_tran_cust_id and 
                                         -- tt.tran_postilion_originated = 1
                                          --and t.tran_nr = tt.tran_nr)
	
WHERE 		c.post_tran_cust_id >= @rpt_tran_id
            AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end)
			/*AND
			(t.datetime_req >= @report_date_start) 
			AND 
			(t.datetime_req <= @report_date_end) */
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420')
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01')
			AND
			t.rsp_code_rsp IN ('00','11','08','10','16')
		
		
             AND
             t.sink_node_name  = 'MEGASWTsnk'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
           
			--AND
			--c.terminal_id like '1%'
			
	--insert into 		
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   *

	
	FROM
			#report_result 
	
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_Eloho_Test]    Script Date: 05/17/2016 16:30:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b06_all_Eloho_Test]--oremeyi modified the previous
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2), 
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 		
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 	
		tran_reversed				INT,	
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description	VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999),
                Late_Reversal                          CHAR (1)
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	

	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
			c.terminal_owner,
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,			
			t.settle_currency_code, 
			
			
			/*	
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			*/
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN t.settle_amount_impact
						ELSE -1 * t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data,
			Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id) THEN 1
						ELSE 0
					        END
			
	FROM

			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE 		c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40')
			AND
			rsp_code_rsp IN ('00','11','08','10','16')
			AND 
			c.source_node_name not like 'SWTASP%'
			AND 
			c.source_node_name not like 'TSS%'
			AND 
			c.source_node_name not like '%WEB%'
			AND
			c.source_node_name not in ('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','SWTSMPsrc')
			AND 
			t.sink_node_name not like 'TSS%'
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTMEGAsnk','VAUMOsnk')
			AND
			(terminal_id not like '2%')
			--AND
			--c.terminal_id like '1%'
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp = 0 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp <> 0 THEN 0
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name
	ORDER BY 
			source_node_name
	END


GO

































































































































GO

































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_CUP_all_POS]    Script Date: 05/17/2016 16:30:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE[dbo].[osp_rpt_b06_CUP_all_POS]
	@Start_Date DATETIME=NULL,	-- yyyymmdd
	@End_Date    DATETIME=NULL,	-- yyyymmdd
	@rpt_tran_id INT = NULL

	
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON
	


If @start_date is null 
set @start_date = dbo.DateOnly(getdate()-1)

If @end_date is null 
set @end_date = dbo.DateOnly(getdate()-1)
END

BEGIN
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,dbo.DateOnly(getdate()-1))
SET @to_date = ISNULL(@end_date,dbo.DateOnly(getdate()-1))

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (11),  
		EndDate						CHAR (11),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2), 
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 		
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 	
		tran_reversed				INT,	
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description	VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999)
	)			

	




	


	EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 


	IF (@to_date < @from_date)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			convert ( char(11),@start_date) as StartDate,  
			convert ( char(11),@end_date) as EndDate,
			c.pan AS pan,
			c.terminal_id, -- oremeyi added this
			c.terminal_owner,
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,			
			t.settle_currency_code, 
			
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN t.settle_amount_impact
						ELSE -1 * t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
			
	FROM
			post_tran_summary t (NOLOCK)
	WHERE 		c.post_tran_cust_id >= @rpt_tran_id
			AND
			t.tran_completed = 1
			

                        AND (t.recon_business_date  >= @from_date AND t.recon_business_date < (@to_date+1))
			AND			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('00')
			AND
			rsp_code_rsp IN ('11','00')
			
			AND
			(terminal_id  like '2%')

                         AND
			t.sink_node_name = 'CUPsnk'
			OPTION (RECOMPILE)
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @from_date, @to_date)
			


SELECT   *

	
	FROM
			#report_result

where (message_type in ( '0200','0100') and tran_reversed IN(0,1)) or ( message_type = '0420' and tran_reversed = 1)
	--GROUP BY
			--StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name, tran_type
	ORDER BY 
			source_node_name
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_CUP_Summary]    Script Date: 05/17/2016 16:30:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO














ALTER PROCEDURE [dbo].[osp_rpt_b06_CUP_Summary]
	@Start_Date DATETIME=NULL,	-- yyyymmdd
	@End_Date    DATETIME=NULL,	-- yyyymmdd
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON


If @start_date is null 
set @start_date = dbo.DateOnly(getdate()-1)

If @end_date is null 
set @end_date = dbo.DateOnly(getdate()-1)
END

BEGIN
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,dbo.DateOnly(getdate()-1))
SET @to_date = ISNULL(@end_date,dbo.DateOnly(getdate()-1))

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (11),  
		EndDate						CHAR (11),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2), 
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 		
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 	
		tran_reversed				INT,	
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description		VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (255),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999)
	)			

	




	


	EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 


	IF (@to_date < @from_date)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			convert ( char(11),@start_date) as StartDate,  
			convert ( char(11),@end_date) as EndDate,
			c.pan AS pan,
			c.terminal_id, -- oremeyi added this
			c.terminal_owner,
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,			
			t.settle_currency_code, 
			
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN t.settle_amount_impact
						ELSE -1 * t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
			
	FROM
    post_tran_summary t (NOLOCK)
	WHERE 		c.post_tran_cust_id >= @rpt_tran_id
			AND
			t.tran_completed = 1
			

                        AND (t.recon_business_date  >= @from_date AND t.recon_business_date < (@to_date+1))
			AND			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40','31')
			AND
			rsp_code_rsp IN ('11','00')
			
			AND
			(terminal_id not like '2%')

                         AND
			t.sink_node_name = 'CUPsnk'
			OPTION(RECOMPILE)	
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @from_date, @to_date)
			


SELECT   StartDate,
		 EndDate,
		 
                 tran_type,
		 sum(settle_amount_impact) as Total_amount,
		count(settle_amount_impact) as Total_Count,
                source_node_name,
                substring(terminal_id,2,3) as CBN_Code

	
	FROM
			#report_result

where (message_type in ( '0200','0100') and tran_reversed IN(0,1)) or ( message_type = '0420' and tran_reversed = 1)
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name, tran_type, substring(terminal_id,2,3)
	ORDER BY 
			source_node_name
END





























































/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_CUP_Summary_SAM]    Script Date: 05/17/2016 16:30:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b06_CUP_Summary_SAM]
	@Start_Date DATETIME=NULL,	-- yyyymmdd
	@End_Date    DATETIME=NULL,	-- yyyymmdd
	@rpt_tran_id INT = NULL

--SET FMTONLY OFF
--GO
	                                                                                             
AS
BEGIN
	


If @start_date is null 
set @start_date = dbo.DateOnly(getdate()-1)

If @end_date is null 
set @end_date = dbo.DateOnly(getdate()-1)
END

BEGIN
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,dbo.DateOnly(getdate()-1))
SET @to_date = ISNULL(@end_date,dbo.DateOnly(getdate()-1))

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (11),  
		EndDate						CHAR (11),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2), 
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 		
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 	
		tran_reversed				INT,	
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999)
	)			

	




	


	EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 


	IF (@to_date < @from_date)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			convert ( char(11),@start_date) as StartDate,  
			convert ( char(11),@end_date) as EndDate,
			c.pan AS pan,
			c.terminal_id, -- oremeyi added this
			c.terminal_owner,
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,			
			t.settle_currency_code, 
			
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN t.settle_amount_impact
						ELSE -1 * t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
			
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)


	WHERE 		c.post_tran_cust_id >= @rpt_tran_id
			AND
			t.tran_completed = 1
			

                        AND (t.recon_business_date  >= @from_date AND t.recon_business_date < (@to_date+1))
			AND			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40','31')
			AND
			rsp_code_rsp IN ('11','00')
			
			AND
			(terminal_id not like '2%')

                         AND
			t.sink_node_name = 'CUPsnk'
			
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @from_date, @to_date)
			


SELECT   StartDate,
		 EndDate,
		 
                 tran_type,
		 sum(settle_amount_impact) as Total_amount,
		count(settle_amount_impact) as Total_Count,
                source_node_name,
                substring(terminal_id,2,3) as CBN_Code

	
	FROM
			#report_result

where (message_type in ( '0200','0100') and tran_reversed IN(0,1)) or ( message_type = '0420' and tran_reversed = 1)
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name, tran_type, substring(terminal_id,2,3)
	ORDER BY 
			source_node_name
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_CUP_TEST]    Script Date: 05/17/2016 16:30:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO













ALTER PROCEDURE [dbo].[osp_rpt_b06_CUP_TEST]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
        @CBN_Code CHAR(3),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL
	
AS
BEGIN
	-- The B06 report uses this stored proc.
SET NOCOUNT ON


	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		recon_business_date				DATETIME, 
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2), 
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 		
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 			
		settle_currency_code		CHAR (3), 	
		settle_amount_impact		FLOAT,	
		rsp_code_description		VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),	
		tran_reversed				INT,	
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999)
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	

	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @sourcenode
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 
	

	IF (@report_date_end < @report_date_start)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END



	CREATE TABLE #list_of_source_nodes (source_node_name VARCHAR(40)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode
	
        CREATE TABLE #list_of_CBN_Codes (CBN_Codes VARCHAR(40)) 
	INSERT INTO  #list_of_CBN_Codes EXEC osp_rpt_util_split_nodenames @CBN_Code

	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/2009
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 

			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.settle_currency_code, 
			
			
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
						
					END
					, t.settle_currency_code) AS settle_amount_impact,

					

			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			t.tran_reversed,
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE 		
			c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			--t.post_tran_cust_id >= '170126684'	
			
			AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND 
			t.tran_postilion_originated = 0 
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40','31')	
			AND
			
			(c.source_node_name IN (SELECT source_node_name FROM #list_of_source_nodes)
                        or substring (c.terminal_id,2,3) in (SELECT CBN_Codes from #list_of_CBN_Codes))
			
			AND
			(terminal_id not like '2%')
                          AND
			t.sink_node_name = 'CUPsnk'

	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			#report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
END
































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_monthly]    Script Date: 05/17/2016 16:30:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b06_monthly]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@SinkNode		VARCHAR(40),
	@Period			VARCHAR(20),
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
		sink_node_name				VARCHAR (40),
		tran_type					CHAR (2),
		rsp_code_rsp				CHAR (2),
		message_type				CHAR (4),
		datetime_req				DATETIME,
		settle_amount_req			FLOAT,
		settle_amount_rsp			FLOAT,
		settle_tran_fee_rsp			FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SourceNode
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode


	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
			c.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			isnull(t.rsp_code_rsp,'99'),
			t.message_type,
			t.datetime_req,

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,

			t.settle_currency_code,


			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact

						ELSE t.settle_amount_impact

					END

					, t.settle_currency_code) AS settle_amount_impact,

			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0100','0200','0220','0400','0420')---oremeyi removed 0120
			AND
			t.tran_completed = 1
			AND
			c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
			AND
			(@SinkNode IS NULL or t.sink_node_name = @SinkNode)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--
		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B06 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_REGION]    Script Date: 05/17/2016 16:30:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE[dbo].[osp_rpt_b06_REGION]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
		terminal_id					varchar (8),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
		sink_node_name				VARCHAR (40),
		tran_type					CHAR (2),
		rsp_code_rsp				CHAR (2),
		message_type				CHAR (4),
		datetime_req				DATETIME,
		settle_amount_req			FLOAT,
		settle_amount_rsp			FLOAT,
		settle_tran_fee_rsp			FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10),
		islocalAcqTrx		INT,  -- added by eseosa on 17th
		network_stan		varchar (8),
		Region				varchar(10)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	
	
	
	INSERT
				INTO #report_result
	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
			c.card_acceptor_id_code,
			c.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			isnull(t.rsp_code_rsp,'99'),
			t.message_type,
			t.datetime_req,

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,


			t.settle_currency_code,


			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp,
			dbo.fn_rpt_islocalAcqTrx(c.pan) as islocalAcqTrx,
			dbo.mc_stan(t.tran_nr) as network_stan,
			dbo.fn_rpt_getRegion_Acquirer(pan) as Region

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			#report_result
	ORDER BY
			datetime_tran_local

        
	END


GO



/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Terminal]    Script Date: 05/17/2016 16:30:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE[dbo].[osp_rpt_b06_Terminal]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@terminalID		VARCHAR(40),	
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL
	
AS
BEGIN
	-- The B06 report uses this stored proc.
SET NOCOUNT ON


	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),	
		StartDate					VARCHAR(30),
		EndDate						VARCHAR(30),
		recon_business_date				DATETIME, 
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2), 
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 		
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 			
		settle_currency_code		CHAR (3), 	
		settle_amount_impact		FLOAT,	
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),	
		tran_reversed				INT,	
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999)
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM @report_result
		RETURN 1
	END
	
	

	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SourceNode
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 
	

	IF (@report_date_end < @report_date_start)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM @report_result
		RETURN 1
	END

	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM @report_result
		RETURN 1
	END
		
		DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT
		

	IF(@report_date_start<> @report_date_end) BEGIN
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req >=  @report_date_start  AND recon_business_date >=  @report_date_start   ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end AND (recon_business_date < @report_date_end ) ORDER BY datetime_req DESC)
	     SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=  @report_date_start   AND recon_business_date >= @report_date_start     ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end AND (recon_business_date < @report_date_end) ORDER BY datetime_req DESC)
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	    SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	    SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	    SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 

		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req >= @report_date_start  AND (recon_business_date >= @report_date_start )  ORDER BY recon_business_date ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req < @report_date_end  AND (recon_business_date < @report_date_end ) ORDER BY recon_business_date DESC)
		
		SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >= @report_date_start AND (recon_business_date >= @report_date_start )  ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE  datetime_req < @report_date_end AND (recon_business_date < @report_date_end  ) ORDER BY datetime_req DESC)
	END
	
	
	INSERT
			INTO @report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/2009
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 

			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.settle_currency_code, 
			
			
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
						
					END
					, t.settle_currency_code) AS settle_amount_impact,

					

			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			t.tran_reversed,
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
	FROM
			post_tran t (NOLOCK, INDEX(ix_post_tran_2))
			INNER JOIN 
			post_tran_cust c (NOLOCK, INDEX(pk_post_tran_cust)) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE 		
			c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			--t.post_tran_cust_id >= '170126684'	
			
			AND
			t.tran_completed = 1
			AND
			(t.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(t.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(t.post_tran_id >= @first_post_tran_id) 
	AND 
	(t.post_tran_id <= @last_post_tran_id) 
			AND 
			t.tran_postilion_originated = 0 
			AND
			t.message_type IN ('0100','0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40')	
			AND
			( 
			c.source_node_name = @SourceNode
			OR
			substring (c.terminal_id,1,4)=substring (@terminalID,1,4)
			)
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTCTLsnk')

	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			@report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Terminal_settle_currency]    Script Date: 05/17/2016 16:30:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE[dbo].[osp_rpt_b06_Terminal_settle_currency]--oremeyi modified the previous
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@terminalID		VARCHAR(40),	
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL
	
AS
BEGIN
	-- The B06 report uses this stored proc.
SET NOCOUNT ON


	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		recon_business_date				DATETIME, 
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2), 
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 		
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 			
		settle_currency_code		CHAR (3), 	
		settle_amount_impact		FLOAT,	
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),	
		tran_reversed				INT,	
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999)
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	

	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SourceNode
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 
	

	IF (@report_date_end < @report_date_start)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/2009
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 

			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.settle_currency_code, 
			
			
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
						
					END
					, t.settle_currency_code) AS settle_amount_impact,

					

			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			t.tran_reversed,
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE 		
			c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			--t.post_tran_cust_id >= '170126684'	
			
			AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND 
			t.tran_postilion_originated = 1 
			AND
			t.message_type IN ('0100','0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40')	
			AND
			( 
			c.source_node_name = @SourceNode
			OR
			substring (c.terminal_id,1,4)=substring (@terminalID,1,4)
			)
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTCTLsnk')

	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			#report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_VISA International Acquiring Billing]    Script Date: 05/17/2016 16:30:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










ALTER PROCEDURE [dbo].[osp_rpt_b06_VISA International Acquiring Billing]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SourceNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

			SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),
		StartDate					VARCHAR (30),
		EndDate						VARCHAR (30),
		pan							VARCHAR (19),
		terminal_id					varchar (8),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
		sink_node_name				VARCHAR (40),
		tran_type					CHAR (2),
		rsp_code_rsp				CHAR (2),
		message_type				CHAR (4),
		datetime_req				DATETIME,
		settle_amount_req			FLOAT,
		settle_amount_rsp			FLOAT,
		settle_tran_fee_rsp			FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description		VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10),
		islocalAcqTrx		INT,  -- added by eseosa on 17th
		network_stan		varchar (8),
		acquiring_inst_id_code VARCHAR(20)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report date

	
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR (30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR (30), @report_date_end, 112)

	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	
	DECLARE @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT PART FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC

		

	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT


	IF(@report_date_start<> @report_date_end) BEGIN
	SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
	SELECT TOP  1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
	SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
	SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	
	
	INSERT
				INTO @report_result
	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(VARCHAR (30), @report_date_start, 112) as StartDate,
			CONVERT(VARCHAR (30), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
			c.card_acceptor_id_code,
			c.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			isnull(t.rsp_code_rsp,'99'),
			t.message_type,
			t.datetime_req,

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,


			t.settle_currency_code,


			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp,
			dbo.fn_rpt_islocalAcqTrx(c.pan) as islocalAcqTrx,
			dbo.mc_stan(t.tran_nr) as network_stan,
			t.acquiring_inst_id_code

				
	FROM
				post_tran t (NOLOCK) 
				JOIN
				
				post_tran_cust c (NOLOCK)
				ON
			t.post_tran_cust_id = c.post_tran_cust_id
			
				
				
	WHERE 			
			
				t.tran_completed = '1'
				AND
(t.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(t.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(t.post_tran_id >= @first_post_tran_id) 
	AND 
	(t.post_tran_id <= @last_post_tran_id) 
				AND
				t.tran_postilion_originated = 0
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
					)
				)
				
				--and t.acquiring_inst_id_code = '447118'
				and c.totals_group like '%OtherVisaGroup%'
				and c.pan like '4%'
				and t.tran_type = '01'
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local

        
	END





























































GO


/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_VISA Local Acquiring Billing]    Script Date: 05/17/2016 16:30:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










ALTER PROCEDURE [dbo].[osp_rpt_b06_VISA Local Acquiring Billing]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SourceNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),
		StartDate					VARCHAR (30),
		EndDate						VARCHAR (30),
		pan							VARCHAR (19),
		terminal_id					varchar (8),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
		sink_node_name				VARCHAR (40),
		tran_type					CHAR (2),
		rsp_code_rsp				CHAR (2),
		message_type				CHAR (4),
		datetime_req				DATETIME,
		settle_amount_req			FLOAT,
		settle_amount_rsp			FLOAT,
		settle_tran_fee_rsp			FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description		VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10),
		islocalAcqTrx		INT,  -- added by eseosa on 17th
		network_stan		varchar (8),
		acquiring_inst_id_code VARCHAR(20),
		totals_group                    varchar(40)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report date

	
	EXECUTE osp_rpt_get_dates_2015 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR (30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR (30), @report_date_end, 112)

	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	
	DECLARE @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT PART FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC

		
	
	
	INSERT
				INTO @report_result
	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(VARCHAR (30), @report_date_start, 112) as StartDate,
			CONVERT(VARCHAR (30), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
			c.card_acceptor_id_code,
			c.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			isnull(t.rsp_code_rsp,'99'),
			t.message_type,
			t.datetime_req,

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,


			t.settle_currency_code,


			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp,
			dbo.fn_rpt_islocalAcqTrx(c.pan) as islocalAcqTrx,
			dbo.mc_stan(t.tran_nr) as network_stan,
			t.acquiring_inst_id_code,
			c.totals_group

				
	FROM
		post_tran_summary t (NOLOCK)
				
				
	WHERE 			
			
				t.tran_completed = '1'
				AND

				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
					)
				)
				
				--and t.acquiring_inst_id_code = '447118'
				and c.totals_group <> 'OtherVisaGroup'
				and c.pan like '4%'
				and substring(c.terminal_id,2,3) = '070'
				and t.tran_type = '01'
				and t.settle_currency_code = '566'
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local

        
	END





























































GO
























































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_VISA Local Acquiring Billing_test]    Script Date: 05/17/2016 16:30:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










ALTER PROCEDURE [dbo].[osp_rpt_b06_VISA Local Acquiring Billing_test]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SourceNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@TotalsGroup VARCHAR(30)
AS
BEGIN

			SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),
		StartDate					VARCHAR (30),
		EndDate						VARCHAR (30),
		pan							VARCHAR (19),
		terminal_id					varchar (8),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
		sink_node_name				VARCHAR (40),
		tran_type					CHAR (2),
		rsp_code_rsp				CHAR (2),
		message_type				CHAR (4),
		datetime_req				DATETIME,
		settle_amount_req			FLOAT,
		settle_amount_rsp			FLOAT,
		settle_tran_fee_rsp			FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description		VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10),
		islocalAcqTrx		INT,  -- added by eseosa on 17th
		network_stan		varchar (8),
		acquiring_inst_id_code VARCHAR(20),
		totals_group                    varchar(40)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report date

	
	EXECUTE osp_rpt_get_dates_2015 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR (30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR (30), @report_date_end, 112)

	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	
	DECLARE @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT PART FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC

		
	CREATE TABLE #list_of_TotalsGroup(TotalsGroup	VARCHAR(30)) 
	
	INSERT INTO  #list_of_TotalsGroup EXEC osp_rpt_util_split_nodenames @TotalsGroup

	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT


	IF(@report_date_start<> @report_date_end) BEGIN
	SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
	SELECT TOP  1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
	SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
	SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	
	
	INSERT
				INTO @report_result
	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(VARCHAR (30), @report_date_start, 112) as StartDate,
			CONVERT(VARCHAR (30), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
			c.card_acceptor_id_code,
			c.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			isnull(t.rsp_code_rsp,'99'),
			t.message_type,
			t.datetime_req,

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,


			t.settle_currency_code,


			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp,
			dbo.fn_rpt_islocalAcqTrx(c.pan) as islocalAcqTrx,
			dbo.mc_stan(t.tran_nr) as network_stan,
			t.acquiring_inst_id_code,
			c.totals_group

				
	FROM
				post_tran t (NOLOCK) 
				JOIN
				
				post_tran_cust c (NOLOCK)
				ON
			t.post_tran_cust_id = c.post_tran_cust_id
			
				
				
	WHERE 			
			
				t.tran_completed = '1'
				AND
(t.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(t.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(t.post_tran_id >= @first_post_tran_id) 
	AND 
	(t.post_tran_id <= @last_post_tran_id) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
					)
				)
				
				--and t.acquiring_inst_id_code = '447118'
				--and c.totals_group <> 'OtherVisaGroup'
				and c.pan like '4%'
				and substring(c.terminal_id,2,3) = '070'
				and t.tran_type = '01'
				and t.settle_currency_code = '566'
				and @TotalsGroup = left(totals_group,3)--FROM #list_of_totalsgroup)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local

        
	END





























































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_VISA Local_Issuing_Detail]    Script Date: 05/17/2016 16:30:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO













































GO


/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Voice_Auth_monthly]    Script Date: 05/17/2016 16:30:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE[dbo].[osp_rpt_b06_Voice_Auth_monthly]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@SinkNode		VARCHAR(40),
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
		sink_node_name				VARCHAR (40),
		tran_type					CHAR (2),
		rsp_code_rsp				CHAR (2),
		message_type				CHAR (4),
		datetime_req				DATETIME,
		settle_amount_req			FLOAT,
		settle_amount_rsp			FLOAT,
		settle_tran_fee_rsp			FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SourceNode
	SET @date_selection_mode = 'Previous month'

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode


	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
			c.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			t.rsp_code_rsp,
			t.message_type,
			t.datetime_req,

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,

			t.settle_currency_code,


			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type = '0220'---eseosa
			AND
			t.tran_completed = 1
			and t.rsp_code_rsp = '00'  ---eseosa
			and t.pos_entry_mode in ( '010','000')--eseosa
			and t.tran_reversed = '0' --eseosa
			AND
			c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
			AND
			(@SinkNode IS NULL or t.sink_node_name = @SinkNode)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--
		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B06 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Voice_Auth_weekly]    Script Date: 05/17/2016 16:30:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE[dbo].[osp_rpt_b06_Voice_Auth_weekly]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@SinkNode		VARCHAR(40),
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
		sink_node_name				VARCHAR (40),
		tran_type					CHAR (2),
		rsp_code_rsp				CHAR (2),
		message_type				CHAR (4),
		datetime_req				DATETIME,
		settle_amount_req			FLOAT,
		settle_amount_rsp			FLOAT,
		settle_tran_fee_rsp			FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SourceNode
	SET @date_selection_mode = 'Last business day'

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode


	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
			c.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			t.rsp_code_rsp,
			t.message_type,
			t.datetime_req,

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,

			t.settle_currency_code,


			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			--AND
			--t.message_type = '0220'---eseosa
			AND
			t.tran_completed = 1
			--and t.rsp_code_rsp = '00'  ---eseosa
			and t.pos_entry_mode in ( '010','000')--eseosa
			and t.tran_reversed = '0' --eseosa
			AND
			c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
			AND
			(@SinkNode IS NULL or t.sink_node_name = @SinkNode)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--
		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B06 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_weekly]    Script Date: 05/17/2016 16:30:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b06_weekly]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@SinkNode		VARCHAR(40),
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
		sink_node_name				VARCHAR (40),
		tran_type					CHAR (2),
		rsp_code_rsp				CHAR (2),
		message_type				CHAR (4),
		datetime_req				DATETIME,
		settle_amount_req			FLOAT,
		settle_amount_rsp			FLOAT,
		settle_tran_fee_rsp			FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SourceNode
	SET @date_selection_mode = 'Previous week'

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode


	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
			c.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			isnull(t.rsp_code_rsp,'99'),
			t.message_type,
			t.datetime_req,

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,

			t.settle_currency_code,


			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0100','0200','0220','0400','0420')---oremeyi removed 0120
			AND
			t.tran_completed = 1
			AND
			c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
			AND
			(@SinkNode IS NULL or t.sink_node_name = @SinkNode)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--
		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B06 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06b]    Script Date: 05/17/2016 16:30:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b06b]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
		sink_node_name				VARCHAR (40),
		tran_type					CHAR (2),
		rsp_code_rsp				CHAR (2),
		message_type				CHAR (4),
		datetime_req				DATETIME,
		settle_amount_req			FLOAT,
		settle_amount_rsp			FLOAT,
		settle_tran_fee_rsp			FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10),
		islocalAcqTrx		INT  -- added by eseosa on 17th
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	
	
	
	INSERT
				INTO #report_result
	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
			c.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			isnull(t.rsp_code_rsp,'99'),
			t.message_type,
			t.datetime_req,

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,


			t.settle_currency_code,


			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp,
			dbo.fn_rpt_islocalAcqTrx(c.pan) as islocalAcqTrx

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			#report_result
	ORDER BY
			datetime_tran_local

        
	END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b07_1]    Script Date: 05/17/2016 16:30:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b07_1]
	@StartDate			CHAR(8),			-- yyyymmdd
	@EndDate				CHAR(8),			-- yyyymmdd
	@SinkNode			VARCHAR(40),
	@SourceNodes		VARCHAR(255),	-- Separated by commas
	@DisplayAsGroup	BIT
AS
BEGIN
	
	-- Made the assumption that the Settlement Currency of the Transaction 
	-- Amount will always be the same as the Settlement Currency of the 
	-- Surcharge Fee. This was done to keep the report simple.
	
	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255), 
		StartDate				DATETIME,  
		EndDate					DATETIME,
		SinkNode					VARCHAR (30),
		SourceNodeAlias		VARCHAR (30),
		TranType					CHAR (2),
		NrTrans					INT, 
		SettleCurrency			CHAR (3),
		TransactionAmount 	FLOAT,
		SurchargeAmount	  	FLOAT,
		CurrencyNrDecimals	INT,
		CurrencyName 			VARCHAR (20),
		isCheckDeposit			INT,
		isCashDeposit			INT,
		isEnvelopeDeposit		INT
	)
	
	DECLARE @warning 			VARCHAR (255)
	
	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
		SET @warning = 'Please supply the Network Name parameter.'
		
		INSERT INTO #report_result (Warning) VALUES (@warning)
				
		SELECT * FROM #report_result
		
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next	DATETIME
	DECLARE @node_name_list 		VARCHAR(255)
	DECLARE @node_list				VARCHAR(255)
	DECLARE @date_selection_mode	VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT
	
	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes 
	(
		source_node			VARCHAR(30)
	) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	-- Only look at 02xx messages that were not fully reversed.

	-- We are using the UNION in order to make sure we still return the 
	-- PARAMETERS, even if there are no transactions in the resultset. The way 
	-- the reports has been configured, the FIRST query of the UNION should be
	-- the one returning the PARAMETERs only
	
	INSERT INTO 
		#report_result
	SELECT	
		NULL 							AS Warning, 
		@report_date_start 		AS StartDate, 
		@report_date_end 			AS EndDate, 
		sink_node_name 			AS SinkNode, 
		SourceNodeAlias =
			(
				CASE
					WHEN (@DisplayAsGroup = 1) THEN '-Our Terminals-'
					ELSE
						source_node_name
				END
			),
		tran_type 					AS TranType, 
		SUM(nr_trans) 				AS NrTrans, 
		settle_amount_currency 	AS SettleCurrency, 
	
		dbo.formatAmount
		(
			SUM
			(
				CASE
				-- The settle_amount_impact field will typically be negative for 
				-- Debit transaction types, but we want to display those amount as
				-- positive on this report
					WHEN
					 (
						CAST(tran_type AS INT) BETWEEN 0 AND 19 
						OR 
						CAST(tran_type AS INT) BETWEEN 50 AND 59
						) THEN -1 * settle_amount_impact
					ELSE settle_amount_impact
				END
			), settle_amount_currency
		) AS TransactionAmount,

		dbo.formatAmount
		(
			SUM(-1 * surcharge_amount_impact),
			settle_amount_currency
		) AS SurchargeAmount,
		
		dbo.currencyNrDecimals(settle_amount_currency) 								AS CurrencyNrDecimals, 
		dbo.currencyName(settle_amount_currency) 										AS CurrencyName,
		dbo.fn_rpt_isElectronicCheckDeposit(tran_type, extended_tran_type)	AS isCheckDeposit,
		dbo.fn_rpt_isCashDepositBNA(tran_type, extended_tran_type)				AS isCashDeposit,
		dbo.fn_rpt_isEnvelopeDeposit(tran_type, extended_tran_type)				AS isEnvelopeDeposit
	FROM
		post_ds_nodes WITH (NOLOCK)
	WHERE 
		recon_business_date >= @report_date_start
		AND 
		recon_business_date <= @report_date_end 
		AND 
		tran_postilion_originated = 1 
		AND 
		rsp_code IN ('00','08', '10', '11', '16')
		AND 
		sink_node_name = @SinkNode
		AND 
		(
			message_type IN ('0200','0220') 
			OR 
			(
				-- We do not want Reversals that do not have any financial impact
				message_type IN ('0400','0420') 
				AND 
				(
					settle_amount_impact <> 0 
					OR 
					surcharge_amount_impact <> 0
				)
			)
			OR
			(
				-- We include authorization inquiry transactions.
				message_type IN ('0100') 
				AND
				dbo.fn_rpt_isATMCustomerInquiryTrx(tran_type) = 1
			)
		)	
		AND
		(
			@SourceNodes IS NULL
			OR
			(
				@SourceNodes IS NOT NULL
				AND
				source_node_name IN (SELECT source_node FROM #list_of_source_nodes) 
			)
		)
	GROUP BY 
		sink_node_name, 
		source_node_name, 
		tran_type, 
		extended_tran_type,
		settle_amount_currency
			
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO #report_result 
			(Warning,
			StartDate, 
			EndDate)
		VALUES 
			('No transactions.', 
			@report_date_start, 
			@report_date_end)
	END
	
	SELECT * FROM #report_result
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b07_1_exceptions]    Script Date: 05/17/2016 16:30:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b07_1_exceptions]
	@report_date_start		DATETIME,
	@report_date_end			DATETIME,
	@SinkNode					VARCHAR(40)
AS
BEGIN
	
	CREATE TABLE #report_result
	(
		NrAborted			INT,
		NrStandInApproved INT,
		NrStandInDeclined	INT
	)

	-- We do not have to validate the parameter, because this proc will be 
	-- called from a subreport and the paramaeters have already been validated
	-- by the stored proc of the main report.

	DECLARE @nr_aborted 					INT
	DECLARE @nr_stand_in_approved		INT
	DECLARE @nr_stand_in_declined		INT

	-- Aborted Transactions
	SELECT
		@nr_aborted = SUM(nr_trans)
	FROM
		post_ds_nodes WITH (NOLOCK)
	WHERE
		recon_business_date >= @report_date_start
		AND
		recon_business_date <= @report_date_end
		AND 
		tran_postilion_originated = 1
		AND
		sink_node_name = @SinkNode
		AND
		message_type IN ('0200','0220','0420')
		AND
		tran_aborted = 1
	
	IF (@@ROWCOUNT = 0 OR @nr_aborted IS NULL)
	BEGIN
		SELECT @nr_aborted = 0
	END
	-----------------------------------------------------------------------------

	-- Stand-in Transactions
	SELECT
		@nr_stand_in_approved = SUM(nr_trans)
	FROM
		post_ds_nodes WITH (NOLOCK)
	WHERE 
		recon_business_date >= @report_date_start 
		AND 
		recon_business_date <= @report_date_end 
		AND 
		tran_postilion_originated = 1
		AND 
		sink_node_name = @SinkNode 
		AND 
		message_type IN ('0200') 
		AND 
		postilion_stand_in = 1
		AND 
		rsp_code IN ('00','08', '10', '11', '16')

	IF (@@ROWCOUNT = 0 OR @nr_stand_in_approved IS NULL)
	BEGIN
		SELECT @nr_stand_in_approved = 0
	END
	-----------------------------------------------------------------------------

	-- Declined Transactions
	SELECT
		@nr_stand_in_declined = SUM(nr_trans)
	FROM
		post_ds_nodes WITH (NOLOCK)
	WHERE 
		recon_business_date >= @report_date_start
		AND 
		recon_business_date <= @report_date_end 
		AND 
		tran_postilion_originated = 1
		AND 
		sink_node_name = @SinkNode 
		AND 
		message_type IN ('0200') 
		AND 
		postilion_stand_in = 1
		AND 
		rsp_code <> '91'	--  There seems to be a bug in Office where some transacations marked as '91' are also marked as stand-in.
		AND NOT rsp_code IN ('00','08', '10', '11', '16')

	IF (@@ROWCOUNT = 0 OR @nr_stand_in_declined IS NULL)
	BEGIN
		SELECT @nr_stand_in_declined = 0
	END
	-----------------------------------------------------------------------------

	INSERT INTO 
		#report_result
	SELECT 
		@nr_aborted 				AS NrAborted, 
		@nr_stand_in_approved 	AS NrStandInApproved, 
		@nr_stand_in_declined 	AS NrStandInDeclined

	SELECT * FROM #report_result
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08]    Script Date: 05/17/2016 16:30:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_2]    Script Date: 05/17/2016 16:30:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE[dbo].[osp_rpt_b08_2]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate	    VARCHAR(30),	-- yyyymmdd
	@SinkNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	DECLARE  @report_result TABLE
	(
		Warning 				VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		from_account_id			VARCHAR(20),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		iscompletionTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		Region				varchar(10)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(varchar(30), @report_date_start, 112)
	SET @EndDate = CONVERT(varchar(30),  @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

	DECLARE  @list_of_sink_nodes  TABLE(sink_node	VARCHAR(30)) 
	INSERT INTO  @list_of_sink_nodes SELECT part FROM dbo.usf_split_string( @SinkNodes, ',');
	
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	
	IF(@report_date_start<> @report_date_end) BEGIN
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=@report_date_start  ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req < @report_date_end  ORDER BY datetime_req DESC)
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	    SET  @report_date_start = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	    SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	    SET  @report_date_end = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=CONVERT(DATETIME,@report_date_start)  ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req < CONVERT(DATETIME,@report_date_end)  ORDER BY datetime_req DESC)
	END
	
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				CONVERT(VARCHAR(30), @report_date_start, 112) as StartDate,
				CONVERT(VARCHAR(30), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,

				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,


				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,


				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,
				t.from_account_type,
				t.from_account_id,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,

				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				dbo.fn_rpt_isApprovedTrx(rsp_code_req)		AS iscompletionTrx,
				c.pan_encrypted,
				auth_id_rsp,
				dbo.fn_rpt_getRegion_Issuer(card_acceptor_name_loc) as Region

				
	FROM
					 post_tran t (nolock, INDEX(ix_post_tran_2 ))
		, post_tran_cust c (nolock,INDEX(pk_post_tran_cust))
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.post_tran_cust_id >= @first_post_tran_cust_id) 
				AND 
				(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)
					)
				)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local

        
	END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_aborted]    Script Date: 05/17/2016 16:30:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE[dbo].[osp_rpt_b08_aborted]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		from_account_id						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		tran_amount_req			FLOAT,
		tran_currency_code		CHAR (6),
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		TranCurrencyName		VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		Trancurrency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30))

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				dbo.DecryptPan(c.pan,pan_encrypted,'CardStatement'),
				t.from_account_id,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,
				--t.tran_amount_req,
				
				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req,
				t.tran_currency_code,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,
				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,
				t.from_account_type,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,
				dbo.currencyName(t.tran_currency_code) AS  TranCurrencyName,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyAlphaCode(t.tran_currency_code) AS Trancurrency_alpha_code,
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				auth_id_rsp
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)

	WHERE			abort_rsp_code is not null
				--t.tran_completed = 1
				and
				(t.recon_business_date >= @report_date_start)
				and
				(t.recon_business_date <= @report_date_end)
				--AND
				--t.tran_postilion_originated = 0
				--AND
				--t.message_type IN ('0100','0200','0220','0420', '0400')--oremeyi removed the 0120
				--AND
				--t.tran_type in  ('22', '20')
				--AND
				--t.tran_completed = 1
				--AND 
				and
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--

		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B08 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT
			*
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END


GO










GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_card_product]    Script Date: 05/17/2016 16:30:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b08_card_product]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		card_product			varchar(20)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30))

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,

				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,
				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,
				t.from_account_type,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				c.pan_encrypted,
				auth_id_rsp,
				card_product
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100','0200','0220','0420', '0400')--oremeyi removed the 0120
				AND
				t.tran_completed = 1
				AND 
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--

		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B08 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT
			*
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_channels]    Script Date: 05/17/2016 16:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b08_channels]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		channel				varchar(10)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30))

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,

				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,
				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,
				t.from_account_type,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				auth_id_rsp,
				case when ((c.pos_terminal_type in ('01')) and merchant_type not in ('6011')) then 'Pos' when ((c.pos_terminal_type not in ('01','02')) and merchant_type not in ('6011')) then 'Web' when ((c.pos_terminal_type = '02') or (c.pos_terminal_type = '01' and (merchant_type = '6011' or merchant_type is NULL))) then 'Atm' else 'others'  end as channel
				
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
			
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100','0200','0220','0420', '0400')--oremeyi removed the 0120
				AND
				t.tran_completed = 1
				AND 
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--

		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B08 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT
			*
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_credit_adj]    Script Date: 05/17/2016 16:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO
















GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_credit_adj_NEW]    Script Date: 05/17/2016 16:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO
















ALTER PROCEDURE [dbo].[osp_rpt_b08_credit_adj_NEW]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		from_account_id						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		tran_amount_req			FLOAT,
		tran_currency_code		CHAR (6),
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		TranCurrencyName		VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		Trancurrency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30))

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				dbo.DecryptPan(c.pan,pan_encrypted,'CardStatement'),
				t.from_account_id,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,
				--t.tran_amount_req,
				
				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req,
				t.tran_currency_code,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,
				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,
				t.from_account_type,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,
				dbo.currencyName(t.tran_currency_code) AS  TranCurrencyName,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyAlphaCode(t.tran_currency_code) AS Trancurrency_alpha_code,
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				auth_id_rsp
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 0
				AND
				t.message_type IN ('0100','0200','0420', '0400')--oremeyi removed the 0120
				AND
				t.tran_type in  ('22', '20')
				AND
				t.tran_completed = 1
				AND
			        t.rsp_code_rsp IN ('00', '11','10','08','16')	
				AND 
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--

		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B08 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT
			*
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END


















GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_failed]    Script Date: 05/17/2016 16:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b08_failed]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.

	DECLARE  @report_result TABLE 
	(
		Warning 				VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply all the parameters.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)

		SELECT * FROM @report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	DECLARE  @list_of_source_nodes TABLE(source_node	VARCHAR(30))

	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes, ',');

	DECLARE  @list_of_Sink_nodes TABLE(sink_node	VARCHAR(30))

	INSERT INTO  @list_of_Sink_nodes SELECT part FROM usf_split_string(@SinkNode, ',');

		
		DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT
		

	IF(@report_date_start<> @report_date_end) BEGIN
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req >=  @report_date_start  AND recon_business_date >=  @report_date_start   ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end AND (recon_business_date < @report_date_end ) ORDER BY datetime_req DESC)
	     SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=  @report_date_start   AND recon_business_date >= @report_date_start     ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end AND (recon_business_date < @report_date_end) ORDER BY datetime_req DESC)
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	    SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	    SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	    SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 

		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req >= @report_date_start  AND (recon_business_date >= @report_date_start )  ORDER BY recon_business_date ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req < @report_date_end  AND (recon_business_date < @report_date_end ) ORDER BY recon_business_date DESC)
		
		SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >= @report_date_start AND (recon_business_date >= @report_date_start )  ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE  datetime_req < @report_date_end AND (recon_business_date < @report_date_end  ) ORDER BY datetime_req DESC)
	END
	

				
	

	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				CONVERT(VARCHAR(30), @report_date_start, 112) as StartDate,
				CONVERT(VARCHAR(30), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,

				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,
				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,

				t.from_account_type,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				auth_id_rsp
	FROM
				post_tran t (NOLOCK, INDEX(ix_post_tran_2))
				 JOIN
					post_tran_cust c (NOLOCK, INDEX(pk_post_tran_cust))
				ON 
					t.post_tran_cust_id = c.post_tran_cust_id
	WHERE
				t.tran_completed = 1
				AND
(t.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(t.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(t.post_tran_id >= @first_post_tran_id) 
	AND 
	(t.post_tran_id <= @last_post_tran_id) 
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100','0200','0220','0420', '0400')--oremeyi removed the 0120
                                AND
                                 t.rsp_code_rsp not in ('00')
                                AND
				t.tran_completed = 1
				AND 
				t.sink_node_name IN (SELECT sink_node FROM @list_of_Sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
					)
				)

	IF @@ROWCOUNT = 0
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--

		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B08 Report'

		-- Get pan and pan_encrypted from @report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					@report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						@report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_ksb]    Script Date: 05/17/2016 16:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b08_ksb]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30))

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				isnull(t.rsp_code_rsp,'99'),
				t.message_type,
				t.datetime_req,

				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,
				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,
				t.from_account_type,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				c.pan_encrypted,
				auth_id_rsp
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100','0200','0220','0420', '0400')--oremeyi removed the 0120
				AND
				t.tran_completed = 1
				AND 
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--

		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B08 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT
			*
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_monthly_old]    Script Date: 05/17/2016 16:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b08_monthly_old]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(40),
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30))

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				isnull(t.rsp_code_rsp,'99'),
				t.message_type,
				t.datetime_req,

				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,
				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,
				t.from_account_type,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				auth_id_rsp
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100','0200','0220','0420', '0400')--oremeyi removed the 0120
				AND
				t.tran_completed = 1
				AND 
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--

		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B08 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT
			*
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_in_All]    Script Date: 05/17/2016 16:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

















































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_in_All_FBN]    Script Date: 05/17/2016 16:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b08_Switched_in_All_FBN]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	Text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		pan				VARCHAR (19), 
		terminal_id				VARCHAR (18), 
		acquiring_inst_id_code			VARCHAR(18),
		--terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
                islocalTrx			INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		
		
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes
	
	
	
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				--c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
					)
				
				)
				AND t.sink_node_name LIKE 'FBN'
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   sink_node_name as Rem_Bank,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr	

	 
	FROM 
			#report_result
Group by startdate, enddate, settle_currency_code, sink_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr	

        
	END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_in_All_review]    Script Date: 05/17/2016 16:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE[dbo].[osp_rpt_b08_Switched_in_All_review]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		from_account_id			VARCHAR(20),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		iscompletionTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes
	
	
	
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,

				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,


				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,


				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,
				t.from_account_type,
				t.from_account_id,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,

				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				dbo.fn_rpt_isApprovedTrx(rsp_code_req)		AS iscompletionTrx,
				c.pan_encrypted,
				auth_id_rsp

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
					)
				)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			#report_result
	ORDER BY
			datetime_tran_local

        
	END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_in_All_test]    Script Date: 05/17/2016 16:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[osp_rpt_b08_Switched_in_All_test]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	Text,
        --@SourceNodes	Text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		pan				VARCHAR (19), 
		terminal_id				VARCHAR (18), 
		acquiring_inst_id_code			VARCHAR(18),
		--terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
                islocalTrx			INT,
		isforeignFinancial0200		INT,
		islocalfinancial0200		INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		
		
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
        SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes

--CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	--INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	
	
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				--c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isforeignfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as isforeignfinancial0200,
				dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as islocalfinancial0200,

				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
			        
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
					)
				
				)
                                AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   sink_node_name as Rem_Bank,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr,
		TranID,
		prev_post_tran_id,
		isforeignfinancial0200,
		islocalfinancial0200
		

	 
	FROM 
			#report_result
Group by startdate, enddate, settle_currency_code, sink_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr,TranID,prev_post_tran_id,isforeignfinancial0200,islocalfinancial0200	

        
	END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_in_All_VISA]    Script Date: 05/17/2016 16:30:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



















ALTER PROCEDURE [dbo].[osp_rpt_b08_Switched_in_All_VISA]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@SinkNodes	VARCHAR(4000),
        --@SourceNodes	Text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	DECLARE  @report_result TABLE
	(
		seq_num_id        BIGINT IDENTITY (1,1) UNIQUE,
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),  
		EndDate					VARCHAR(30),
		pan				VARCHAR (19), 
		terminal_id				VARCHAR (18), 
		acquiring_inst_id_code			VARCHAR(18),
		--terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
                islocalTrx			INT,
		isforeignFinancial0200		INT,
		islocalfinancial0200		INT,
		islocalfinancial0200TrxNOTCashWdrl		INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
        CardType CHAR(19)
			)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
        SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates_2015 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT   


	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	DECLARE  @list_of_sink_nodes TABLE (sink_node	VARCHAR(30)) 
	INSERT INTO  @list_of_sink_nodes SELECT part from  usf_split_string( @SinkNodes,',') ORDER BY PART ASC

--CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	--INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	
	DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT


		IF(@report_date_start<> @report_date_end) BEGIN
		SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP  1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
		END
		ELSE IF(@report_date_start= @report_date_end) BEGIN
		SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
		SET  @report_date_end = DATEADD(D, 1,@report_date_end)
		SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
		SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
		END
	
	
	INSERT
				INTO @report_result
	SELECT 
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				--c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isforeignfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as isforeignfinancial0200,
				dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as islocalfinancial0200,
				dbo.fn_rpt_islocalfinancial0200TrxNOTCashWdrl(t.message_type,t.tran_amount_req,t.rsp_code_rsp,c.card_acceptor_name_loc,t.tran_type) as islocalfinancial0200TrxNOTCashWdrl,


				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp,
                dbo.fn_rpt_CardType(c.pan,t.sink_node_name,t.tran_type,c.terminal_id) AS CardType
				

				
	FROM
				post_tran t (NOLOCK)
				join
				post_tran_cust c (NOLOCK)
				on 
				t.post_tran_cust_id = c.post_tran_cust_id				
	WHERE 			
				
				
				t.tran_completed = '1'
				AND
				(t.post_tran_cust_id >= @first_post_tran_cust_id) 
				AND 
				(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				AND
				(t.post_tran_id >= @first_post_tran_id) 
				AND 
				(t.post_tran_id <= @last_post_tran_id)
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
			        
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)
					)
				
				)
                                AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
and c.pan like '4%'
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
         tran_type,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   sink_node_name as Rem_Bank,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr,
		TranID,
		prev_post_tran_id,
		isforeignfinancial0200,
		islocalfinancial0200,
		islocalfinancial0200TrxNOTCashWdrl
		

	 
	FROM 
			@report_result
Group by startdate, enddate, tran_type,settle_currency_code, sink_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr,TranID,prev_post_tran_id,isforeignfinancial0200,islocalfinancial0200,islocalfinancial0200TrxNOTCashWdrl

        
	END






































































GO


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_out_All_bkp]    Script Date: 05/17/2016 16:30:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE[dbo].[osp_rpt_b08_Switched_out_All_bkp]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SourceNodes	VARCHAR(4000),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

		SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED



	DECLARE  @report_result TABLE
	(
		seq_num_id        BIGINT IDENTITY (1,1) UNIQUE,
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		pan				VARCHAR (19), 
		terminal_id				VARCHAR (18), 
		acquiring_inst_id_code			VARCHAR(18),
		--terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		islocalTrx			INT,
		isforeignfinancial0200		INT,
		islocalfinancial0200		INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10)
		
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

	DECLARE  @list_of_source_nodes  TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes  SELECT part FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC;
	
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT


	IF(@report_date_start<> @report_date_end) BEGIN
	SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
	SELECT TOP  1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
	SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
	SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END

	
	
	INSERT
				INTO @report_result
	SELECT 
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				--c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 

				t.to_account_type, 
				t.settle_currency_code, 
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isforeignfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as isforeignfinancial0200,
				dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as islocalfinancial0200,

				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp

				
	FROM
				post_tran t (NOLOCK) join

				post_tran_cust c (NOLOCK)
on
				
				
			t.post_tran_cust_id = c.post_tran_cust_id
				
	WHERE 			
				
				t.tran_completed = '1'
				AND
				t.post_tran_cust_id >= @first_post_tran_cust_id
				AND 
				(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				AND
				(t.post_tran_id >= @first_post_tran_id) 
				AND 
				(t.post_tran_id <= @last_post_tran_id)
				AND
				t.tran_postilion_originated = 0
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes )
					)
					
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   source_node_name as Acq_Bank,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr,
		isforeignfinancial0200,
		islocalfinancial0200

	 
	FROM 
			@report_result
Group by startdate, enddate, settle_currency_code, source_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr,isforeignfinancial0200,islocalfinancial0200

        
	END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_out_verveintl_All]    Script Date: 05/17/2016 16:30:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[osp_rpt_b08_Switched_out_verveintl_All]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	Text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		pan				VARCHAR (19), 
		terminal_id				VARCHAR (18), 
		acquiring_inst_id_code			VARCHAR(18),
		--terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
                islocalTrx			INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'SWTMEGAsnk'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	

CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes
	
	
	
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				--c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0
				
				AND totals_group like 'VerveTGrp'
				
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
					)
					
				)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   source_node_name as Acq_Bank,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr	

	 
	FROM 
			#report_result


Group by startdate, enddate, settle_currency_code, source_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr	

      
	END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Verve_Intl]    Script Date: 05/17/2016 16:30:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[osp_rpt_b08_Verve_Intl]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	
		SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	DECLARE  @report_result TABLE
	(
		Warning 				VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		tran_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		from_account_id			VARCHAR(20),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		iscompletionTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		Region				varchar(10),
                totals_group                    varchar(40)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	DECLARE @list_of_sink_nodes TABLE(sink_node	VARCHAR(30)) 
	INSERT INTO  @list_of_sink_nodes SELECT PART FROM usf_split_string(@SinkNodes, ',') ORDER BY PART ASC
	
		DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT


		IF(@report_date_start<> @report_date_end) BEGIN
		SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP  1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
		END
		ELSE IF(@report_date_start= @report_date_end) BEGIN
		SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
		SET  @report_date_end = DATEADD(D, 1,@report_date_end)
		SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
		SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
		END
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				CONVERT(VARCHAR(30), @report_date_start, 112) as StartDate,
				CONVERT(VARCHAR(30), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,

				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,


				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,


				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,
				t.from_account_type,
				t.from_account_id,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,

				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				dbo.fn_rpt_isApprovedTrx(rsp_code_req)		AS iscompletionTrx,
				c.pan_encrypted,
				auth_id_rsp,
				dbo.fn_rpt_getRegion_Issuer(card_acceptor_name_loc) as Region,
                                c.totals_group

				
	FROM
							post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
(t.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(t.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(t.post_tran_id >= @first_post_tran_id) 
	AND 
	(t.post_tran_id <= @last_post_tran_id) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)
					)
				)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local

        
	END
































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_verveintl_All]    Script Date: 05/17/2016 16:30:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE[dbo].[osp_rpt_b08_verveintl_All]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	Text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

SET NOCOUNT ON

CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2),
		acquiring_inst_id_code		VARCHAR (225),
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 
		--tran_amount_rsp				FLOAT,
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 	
		tran_reversed				INT,	
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999)
	)	

DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	 --Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAUBAsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	

CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes

INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id,
			c.terminal_owner,
                        c.source_node_name, 
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.acquiring_inst_id_code,
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,	
			--t.tran_amount_rsp,		
			t.settle_currency_code, 
			
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN t.settle_amount_impact
						ELSE -1 * t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			isnull(t.retention_data,0)
			
	FROM

			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
            --left join 
            --post_tran tt (nolock) on (t.post_tran_cust_id = tt.post_tran_cust_id and 
                                         -- tt.tran_postilion_originated = 1
                                          --and t.tran_nr = tt.tran_nr)
	
WHERE 		c.post_tran_cust_id >= @rpt_tran_id
            AND
			t.tran_completed = 1
			--AND
			--(t.recon_business_date >= @report_date_start) 
			--AND 
			--(t.recon_business_date <= @report_date_end)
			/*AND
			(t.datetime_req >= @report_date_start) 
			AND 
			(t.datetime_req <= @report_date_end) */
			AND
			t.tran_postilion_originated = 1
			AND
			t.message_type IN ('0200','0220','0400','0420')
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01')
			AND
			t.rsp_code_rsp IN ('00','11','08','10','16')
		
		
           -- AND
         -- t.sink_node_name = 'MEGASWTsnk'
            -- AND
          --.sink_node_name  NOT LIKE 'SB%'
           
			--AND
			--c.terminal_id like '1%'
			
		AND totals_group in('VerveTGrp','VerveTSBGrp')
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   *

	
	FROM
			#report_result 
	
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_VISA Billing]    Script Date: 05/17/2016 16:30:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO













ALTER PROCEDURE [dbo].[osp_rpt_b08_VISA Billing]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	
		SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	DECLARE  @report_result TABLE
	(
		Warning 				VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		from_account_id			VARCHAR(20),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		iscompletionTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		Region				varchar(10),
                totals_group                    varchar(40)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	DECLARE @list_of_sink_nodes TABLE(sink_node	VARCHAR(30)) 
	INSERT INTO  @list_of_sink_nodes SELECT PART FROM usf_split_string(@SinkNodes, ',') ORDER BY PART ASC

	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				CONVERT(VARCHAR(30), @report_date_start, 112) as StartDate,
				CONVERT(VARCHAR(30), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,

				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,


				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,


				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,
				t.from_account_type,
				t.from_account_id,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,

				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				dbo.fn_rpt_isApprovedTrx(rsp_code_req)		AS iscompletionTrx,
				c.pan_encrypted,
				auth_id_rsp,
				dbo.fn_rpt_getRegion_Issuer(card_acceptor_name_loc) as Region,
                                c.totals_group

				
	FROM
					post_tran_summary  t (NOLOCK)
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND

				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)
					)
				)
and c.pan like '468219%'
--and settle_currency_code not in ('566')
and rsp_code_rsp = ('00')
and c.card_acceptor_name_loc like '%NG%'
OPTION (RECOMPILE)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local

        
	END
































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_VISA International_Issuing_Billing]    Script Date: 05/17/2016 16:30:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_VISA International_Issuing_Billing_All]    Script Date: 05/17/2016 16:30:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO













ALTER PROCEDURE [dbo].[osp_rpt_b08_VISA International_Issuing_Billing_All]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	
		SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	DECLARE  @report_result TABLE
	(
		Warning 				VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		from_account_id			VARCHAR(20),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		iscompletionTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		Region				varchar(10),
                totals_group                    varchar(40),
		isforeignFinancial0200		INT,
		islocalfinancial0200		INT,
		islocalfinancial0200TrxNOTCashWdrl		INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		tran_reversed  INT
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	DECLARE @list_of_sink_nodes TABLE(sink_node	VARCHAR(30)) 
	INSERT INTO  @list_of_sink_nodes SELECT PART FROM usf_split_string(@SinkNodes, ',') ORDER BY PART ASC

	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				CONVERT(VARCHAR(30), @report_date_start, 112) as StartDate,
				CONVERT(VARCHAR(30), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,

				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,


				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,


				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,
				t.from_account_type,
				t.from_account_id,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,

				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				dbo.fn_rpt_isApprovedTrx(rsp_code_req)		AS iscompletionTrx,
				c.pan_encrypted,
				auth_id_rsp,
				dbo.fn_rpt_getRegion_Issuer(card_acceptor_name_loc) as Region,
                                c.totals_group,
                                
				dbo.fn_rpt_isforeignfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as isforeignfinancial0200,
				dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as islocalfinancial0200,
				dbo.fn_rpt_islocalfinancial0200TrxNOTCashWdrl(t.message_type,t.tran_amount_req,t.rsp_code_rsp,c.card_acceptor_name_loc,t.tran_type) as islocalfinancial0200TrxNOTCashWdrl,


				extended_tran_type,
				tran_reversed

				
	FROM
				post_tran_summary t (NOLOCK)
				
				
	WHERE 			

				t.tran_completed = '1'
				AND

				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)
					)
				)
and c.pan like '468219%'
--and settle_currency_code not in ('566')
and rsp_code_rsp = ('00')
and RIGHT (c.card_acceptor_name_loc,2) <> 'NG'
and tran_type in ('01','31')
OPTION (RECOMPILE)

				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
         tran_type,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                    left(totals_group,3) as totals_group,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type
		

	 
	FROM 
			@report_result
Group by startdate, enddate, tran_type,settle_currency_code, totals_group,rsp_code_rsp,message_type,islocalTrx

       OPTION (MAXDOP 8) 
	END































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_VISA Local_Issuing_Billing]    Script Date: 05/17/2016 16:30:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO













ALTER PROCEDURE [dbo].[osp_rpt_b08_VISA Local_Issuing_Billing]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	DECLARE  @report_result TABLE
	(
		Warning 				VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		from_account_id			VARCHAR(20),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		iscompletionTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		Region				varchar(10),
                totals_group                    varchar(40)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	DECLARE @list_of_sink_nodes TABLE(sink_node	VARCHAR(30)) 
	INSERT INTO  @list_of_sink_nodes SELECT PART FROM usf_split_string(@SinkNodes, ',') ORDER BY PART ASC

	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				CONVERT(VARCHAR(30), @report_date_start, 112) as StartDate,
				CONVERT(VARCHAR(30), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,

				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,


				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,


				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,
				t.from_account_type,
				t.from_account_id,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,

				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				dbo.fn_rpt_isApprovedTrx(rsp_code_req)		AS iscompletionTrx,
				c.pan_encrypted,
				auth_id_rsp,
				dbo.fn_rpt_getRegion_Issuer(card_acceptor_name_loc) as Region,
                                c.totals_group

				
	FROM
		 post_tran_summary  t (NOLOCK)
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)
					)
				)
and c.pan like '4%'
--and settle_currency_code not in ('566')
--and rsp_code_rsp = ('00')
and RIGHT (c.card_acceptor_name_loc,2) = 'NG'
--and t.totals_group like '%FBPVisa%'
and tran_type = '01'
OPTION (RECOMPILE)
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local

        
	END
































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b12_3]    Script Date: 05/17/2016 16:30:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE[dbo].[osp_rpt_b12_3]
	@BusinessDate		CHAR(8),			-- yyyymmdd. If this is NULL, then yesterday will be used. 
	@HostNodes			VARCHAR(255),	-- A list of all the host nodes that process 'OnUs' transactions.
	@AtmSourceNodes	VARCHAR(255),	-- All the ATM driving nodes that support Deposit Automation
	@UseBusinessDate 	BIT				-- Specify whether to use the Business Date or the "'Previous Deposit Clear' to 'Current Deposit Clear'"
AS
BEGIN
	-- Ensure that the business date is not equal to the empty string. This would 
	-- cause an exception to be thrown.
	IF (RTRIM(@BusinessDate) = '')
	BEGIN
		SET @BusinessDate = NULL
	END
	
	CREATE TABLE #report_result
	(
		Warning				VARCHAR (255), 
		BusinessDate			DATETIME,
		TermID				CHAR (8),
		CardAcceptorNameLoc		CHAR (40), 
		NrTrans				INT, 
		TranType			VARCHAR (19),
		SinkNodeAlias			VARCHAR (255), 
		TransactionAmount		FLOAT,
		SettleCurrency			CHAR (3),
		settle_currency_alpha_code CHAR (3),
		settle_nr_decimals INT,
	)

	DECLARE @warning 		VARCHAR (255)
	
	-------------------------------------
	-- Step 1 Validate some Parameters --
	-------------------------------------
	IF (@AtmSourceNodes IS NULL)
	BEGIN
		SET @warning = 'Please supply the Terminal Driving Node(s) that drive the terminals having the BNA/IDM'

		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * 
		FROM #report_result
		
		RETURN 1
	END
	IF (@HostNodes IS NULL)
	BEGIN
		SET @warning = 'Please supply the Host Node(s).'

		INSERT INTO #report_result (Warning) VALUES (@warning)
			
		SELECT * 
		FROM #report_result
			
		RETURN 1
	END

	--------------------------------------
	-- Extract the report data --
	--------------------------------------
	IF (@UseBusinessDate IS NULL) OR (@UseBusinessDate = 1)
	BEGIN
		EXEC osp_rpt_b12_3_business_date @BusinessDate, @HostNodes, @AtmSourceNodes
	END
	ELSE
	BEGIN
		EXEC osp_rpt_b12_3_calendar_date @BusinessDate, @HostNodes, @AtmSourceNodes
	END


	IF EXISTS (SELECT * FROM #report_result (nolock))
	BEGIN
		SELECT 
			* 
		FROM 	
			#report_result (nolock) 
		ORDER BY 
			TermID, 
			SinkNodeAlias, 
			SettleCurrency
	END
	ELSE
	BEGIN
		INSERT INTO #report_result
		SELECT 
			'No BNA or IDM operations were performed on this business date for the specified terminal driver(s) and host(s)' AS Warning, 
		 	@BusinessDate,
		 	NULL AS TermID, 
		 	NULL AS CardAcceptorNameLoc,
		  	0 AS NrTrans, 
		  	NULL AS TranType, 
		  	NULL AS SinkNodeAlias, 
		  	0 AS TransactionAmount, 
		  	NULL as SettleCurrency, 
		  	NULL, 
		  	NULL
				
		SELECT 
			* 
		FROM 
			#report_result		
	END
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b12_3_business_date]    Script Date: 05/17/2016 16:30:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE[dbo].[osp_rpt_b12_3_business_date]
	@BusinessDate		CHAR(8),			-- yyyymmdd. If this is NULL, then yesterday will be used. 
	@HostNodes			VARCHAR(255),	-- A list of all the host nodes that process 'OnUs' transactions.
	@AtmSourceNodes	VARCHAR(255)	-- All the ATM driving nodes that support Deposit Automation
AS
BEGIN
	
	DECLARE @warning 			VARCHAR (255)
	DECLARE @report_date 	DATETIME
	
	-- Create the list of source nodes
	CREATE TABLE #list_of_source_nodes 
	(
		source_node	VARCHAR(30)
	) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @AtmSourceNodes

	-- Create the list of host nodes
	CREATE TABLE #list_of_host_nodes 
	(
		sink_node	VARCHAR(30)
	) 
	
	INSERT INTO  #list_of_host_nodes EXEC osp_rpt_util_split_nodenames @HostNodes

	-- Get the Business Date into the correct format. If the @BusinessDate 
	-- parameter is NULL, the last closed batch will be used
	IF (@BusinessDate IS NULL)
	BEGIN
		SELECT
			@report_date = MAX (b.settle_date)
		FROM
			post_batch b WITH (NOLOCK)
			INNER JOIN
			post_settle_entity s WITH (NOLOCK)
				ON (b.settle_entity_id = s.settle_entity_id)
		WHERE
			s.node_name IN (SELECT node_name FROM #list_of_source_nodes)
			AND
			b.datetime_end IS NOT NULL
	END				
	ELSE
	BEGIN
		EXECUTE osp_rpt_date_from_user @BusinessDate, @report_date OUTPUT, @warning OUTPUT
	END
	
	-- Extract the report data from the database		
	INSERT 
		INTO #report_result
	SELECT
		NULL 								AS WARNING,
		@report_date 					AS BusinessDate,
		c.terminal_id 					AS TermID,
		c.card_acceptor_name_loc 	AS CardAcceptorNameLoc,
		1 AS NrTrans,
		TranType = 
		(
			CASE 
				WHEN p.tran_type = '21'
				THEN 'BNA Deposits'
				ELSE 'Check Deposits'
			END
		),
		SinkNodeAlias = 
		(
			CASE 
			WHEN p.sink_node_name IN 
				(
					SELECT 
						sink_node 
					FROM 
						#list_of_host_nodes
					) THEN '-Our Cardholders-'
			ELSE '-Foreign Cardholders-'
			END
		),
		dbo.formatAmount(p.settle_amount_impact, p.settle_currency_code) 	AS TransactionAmount,
		p.settle_currency_code 															AS SettleCurrency,
		dbo.currencyAlphaCode (p.settle_currency_code) 							AS settle_currency_alpha_code,
		dbo.currencyNrDecimals(p.settle_currency_code) 							AS settle_nr_decimals
	FROM 		
		post_tran p WITH (NOLOCK)
		LEFT JOIN 
		post_tran_cust c WITH(NOLOCK) 
			ON (p.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
		p.tran_postilion_originated = 0
		AND 
		p.rsp_code_rsp IN ('00','08', '10', '11', '16') 
		AND 
		p.tran_completed = 1
		AND 
		p.tran_type IN ('21','24')
		AND 
		c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) 
		AND 
		(
			p.message_type IN ('0200','0220') 
			OR 
			(
				p.message_type IN ('0420', '0400') 
				AND 
				(
					p.settle_amount_impact <> 0 OR p.settle_tran_fee_rsp <> 0
				)
			)
		)	-- We do not want Reversals that do not have any financial impact
		AND 
		p.extended_tran_type in (6100,6101,6102,6103,6110)
		AND 
		p.recon_business_date = @report_date
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b12_3_calendar_date]    Script Date: 05/17/2016 16:30:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




ALTER PROCEDURE [dbo].[osp_rpt_b12_3_calendar_date]
	@CalendarDate		CHAR(8),			-- yyyymmdd. If this is NULL, then yesterday will be used. 
	@HostNodes			VARCHAR(255),	-- A list of all the host nodes that process 'OnUs' transactions.
	@AtmSourceNodes	VARCHAR(255)	-- All the ATM driving nodes that support Deposit Automation
AS
BEGIN
	
	DECLARE @warning 							VARCHAR (255)
	DECLARE @report_date_start				DATETIME
	DECLARE @report_date_end				DATETIME
	DECLARE @report_date_end_next			DATETIME
	DECLARE @FirstDateTime					DATETIME
	DECLARE @TermID							CHAR(8)
	DECLARE @PrevClearDepositDateTime	DATETIME		-- Value used in queries
	DECLARE @CaNameLoc						CHAR(40)
	DECLARE @ClearDepositDateTime			DATETIME
	DECLARE @SourceNodeName					VARCHAR(255)
	
	-- Create the list of source nodes
	CREATE TABLE #list_of_source_nodes 
	(
		source_node	VARCHAR(30)
	) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @AtmSourceNodes

	-- Create the list of host nodes
	CREATE TABLE #list_of_host_nodes 
	(
		sink_node	VARCHAR(30)
	) 
	INSERT INTO  #list_of_host_nodes EXEC osp_rpt_util_split_nodenames @HostNodes

	CREATE TABLE #terminal_date_info 
	(
		range_id						INT IDENTITY,
		source_node_name			VARCHAR(255),
		terminal_id 				CHAR(8),
		card_acceptor_name_loc	CHAR (40),
		datetime_start				DATETIME,
		datetime_end				DATETIME
	)

	----------------------------------------------------------
	-- Determine the date range of the report
	----------------------------------------------------------
			
	-- Step 1. 	
	-- Calculate the report dates. If the CalendarDate is NULL, 
	--	yesterday's date will be used as the calendar date
	DECLARE @next_day	VARCHAR(8)
	SET @next_day = CONVERT(VARCHAR(8), DATEADD(d, 1, @CalendarDate), 112)
	EXECUTE osp_rpt_get_dates 'Yesterday', @AtmSourceNodes, @CalendarDate, @next_day, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT
	
	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END
	

	-- Step 2. 	
	-- Get a list of all ATMs who performed a 'Clear Deposit' between these two dates.
	CREATE TABLE #terminals_who_performed_clear_deposits 
	(
		terminal_id					CHAR(8),
		card_acceptor_name_loc	CHAR(40),
		datetime_req			DATETIME,
		source_node_name		VARCHAR(255)
	) 

	-- If an ATM has more than one 'Clear Deposit' on this calendar date, then we should handle them all.
	INSERT INTO #terminals_who_performed_clear_deposits (
		terminal_id, 
		card_acceptor_name_loc, 
		datetime_req, 
		source_node_name)
	SELECT 
		pds.terminal_id, 
		c.card_acceptor_name_loc, 
		pds.datetime_req,
		pds.source_node_name
	FROM
		post_ds_atm_admin pds
		LEFT JOIN 
		(
			post_tran t WITH (NOLOCK)
			INNER JOIN 
			post_tran_cust c WITH (NOLOCK)
				ON (t.post_tran_cust_id = c.post_tran_cust_id)
		)
			ON t.post_tran_id = pds.post_tran_id
	WHERE 
		c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) 
      AND
		pds.datetime_req >= @report_date_start
		AND 
		pds.datetime_req < @report_date_end_next
		AND
		t.message_type = '0620' 
		AND 
		(			
			-- This is for AtmApp 3.2 or later
			(
				t.tran_type = '93' 
				AND 
				t.extended_tran_type = '2001'
			) 
			OR
			-- To cater for AtmApp 3.1 or 3.0, we need to look for Deposit Clear Only events manually:
      	(
      		t.tran_type = '93' 
      		AND 
      		t.extended_tran_type IN ('2001','2002') 
      		AND 
  				CHARINDEX ('<Function>CLEAR', t.structured_data_req) > 0
  			)
		)		
			 
	-- Step 4. 
	-- Determine the previous date of a Clear Deposit Event for every ATM in #terminals_who_performed_clear_deposits
	DECLARE term_cursor CURSOR 
	FOR 
		SELECT 
			terminal_id, card_acceptor_name_loc, datetime_req, source_node_name
		FROM 
			#terminals_who_performed_clear_deposits WITH (nolock) 
	FOR READ ONLY
	
	OPEN term_cursor

	SET @FirstDateTime = DateAdd(yyyy, 2000 - 1900, 0) -- This should cover all the transactions in the DB !!

	IF (@@CURSOR_ROWS <> 0)
	BEGIN	
		FETCH term_cursor INTO @TermID, @CaNameLoc, @ClearDepositDateTime, @SourceNodeName

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			-- First get the previous Clear Deposit Event for this terminal
			SELECT 
				@PrevClearDepositDateTime = MAX(pds.datetime_req)
			FROM 
				post_ds_atm_admin pds
				LEFT JOIN
				post_tran t WITH (NOLOCK)
					ON t.post_tran_id = pds.post_tran_id
			WHERE 
				pds.terminal_id = @TermID 
				AND
				pds.datetime_req < @ClearDepositDateTime 
				AND 
				pds.message_type = '0620' 
				AND 
				(			
					-- This is for AtmApp 3.2 or later
					(
						t.tran_type = '93' 
						AND 
						t.extended_tran_type = '2001'
					)
					OR
					-- To cater for AtmApp 3.1 or 3.0, we need to look for Deposit Clear Only events manually:
		      	(
		      		t.tran_type = '93' 
		      		AND 
		      		t.extended_tran_type IN ('2001','2002') 
		      		AND 
		  				CHARINDEX ('<Function>CLEAR', t.structured_data_req) > 0
		  			)	
				)	 				 						

			IF (@@ROWCOUNT = 0 or @PrevClearDepositDateTime IS NULL)
			BEGIN
				SET @PrevClearDepositDateTime = @FirstDateTime
			END
			
			-- Insert into the temporary table used to do the scans
			INSERT INTO 
				#terminal_date_info
			VALUES(
				@SourceNodeName, 
				@TermID, 
				@CaNameLoc, 
				@PrevClearDepositDateTime, 
				@ClearDepositDateTime)

			FETCH term_cursor INTO @TermID, @CaNameLoc, @ClearDepositDateTime, @SourceNodeName
		END
	END

	CLOSE term_cursor		
	DEALLOCATE term_cursor		

	-- Extract the report data from the database		
	INSERT 
		INTO #report_result
	SELECT
		NULL 												AS WARNING,
		CONVERT(DATETIME, @CalendarDate, 112) 	AS BusinessDate,
		c.terminal_id 									AS TermID,
		c.card_acceptor_name_loc 					AS CardAcceptorNameLoc,
		1 													AS NrTrans,
		TranType = 
		(
			CASE 
				WHEN t.tran_type = '21'
				THEN 'BNA Deposits'
				ELSE 'Check Deposits'
			END
		),
		SinkNodeAlias = 
		(
			CASE 
				WHEN t.sink_node_name IN (SELECT sink_node FROM #list_of_host_nodes) 
				THEN '-Our Cardholders-'
				ELSE '-Foreign Cardholders-'
			END
		),
		dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) 	AS TransactionAmount,
		t.settle_currency_code 															AS SettleCurrency,
		dbo.currencyAlphaCode (t.settle_currency_code) 							AS settle_currency_alpha_code,
		dbo.currencyNrDecimals(t.settle_currency_code) 							AS settle_nr_decimals
	FROM 		
		#terminal_date_info tdi
		LEFT JOIN
		(
			post_tran t WITH (NOLOCK)
			LEFT JOIN post_tran_cust c WITH (NOLOCK) 
				ON (t.post_tran_cust_id = c.post_tran_cust_id)
		)
		ON
		(
			c.source_node_name = tdi.source_node_name
			AND
			c.terminal_id = tdi.terminal_id
			AND
			t.datetime_req >= tdi.datetime_start
			AND
			t.datetime_req <= tdi.datetime_end
		)
	WHERE
		t.tran_postilion_originated = 0
		AND 
		t.rsp_code_rsp IN ('00','08', '10', '11', '16') 
		AND 
		t.tran_completed = 1
		AND 
		t.tran_type IN ('21','24')
		AND 
		c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) 
		AND 
		(
			t.message_type IN ('0200','0220') 
			OR 
			(
				t.message_type IN ('0420', '0400') 
				AND 
				(
					t.settle_amount_impact <> 0 
					OR 
					t.settle_tran_fee_rsp <> 0
				)
			)
		)	-- We do not want Reversals that do not have any financial impact
		AND 
		t.extended_tran_type in (6100,6101,6102,6103,6110)
END




GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b26]    Script Date: 05/17/2016 16:30:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO
















-- a new report created by Eseosa on 7/05/2013 to generate a summary of switched-out transactions
-- the report became necessry due to the bulkiness of the detail repoRT

ALTER PROCEDURE [dbo].[osp_rpt_b26]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(80),
	@SinkNode		VARCHAR(40),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.
CREATE TABLE #report_result
	(
		
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		Source_node				VARCHAR (40),
		local_Acq_fin_0100				NUMERIC,
		local_Acq_fin_0200				NUMERIC,
		local_Acq_fin_0220				NUMERIC,
		foreign_Acq_0100				NUMERIC,
		foreign_Acq_0200				NUMERIC,
		foreign_Acq_fin_0220			NUMERIC)

		

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30))

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
	NULL AS Warning,
	CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
	CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
	c.source_node_name as Source_node,
	sum (dbo.fn_rpt_islocalfinancial0100AcqTrx(t.message_type,t.tran_amount_req,t.rsp_code_rsp,c.pan)) as local_Acq_fin_0100,
	sum (dbo.fn_rpt_islocalfinancial0200AcqTrx(t.message_type,t.tran_amount_req,t.rsp_code_rsp,c.pan)) as local_Acq_fin_0200,
	sum (dbo.fn_rpt_islocalfinancial0220AcqTrx(t.message_type,t.tran_amount_req,t.rsp_code_rsp,t.rsp_code_req, c.pan)) as local_Acq_fin_0220,

	sum (dbo.fn_rpt_isforeign0100AcqTrx(t.message_type,c.pan)) as foreign_Acq_0100,
	sum (dbo.fn_rpt_isforeign0200AcqTrx(t.message_type,c.pan)) as foreign_Acq_0200,
	sum (dbo.fn_rpt_isforeignfinancial0220AcqTrx (t.message_type,t.tran_amount_req,t.rsp_code_rsp,t.rsp_code_req, c.pan)) as foreign_Acq_fin_0220	
	
				
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100','0200','0220')--oremeyi removed the 0120
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND
				(@SinkNode IS NULL or t.sink_node_name = @SinkNode)


	group by c.source_node_name

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	

	SELECT
			*
	FROM
			#report_result
	order by Source_node
	
END




























GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b28]    Script Date: 05/17/2016 16:30:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO











-- a new report created by Eseosa on 7/05/2013 to generate a summary of switched-in transactions
-- the report became necessry due to the bulkiness of the detail repoRT

ALTER PROCEDURE [dbo].[osp_rpt_b28]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.
CREATE TABLE #report_result
	(
		
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		Bin 					VARCHAR (6),
		local_fin_0100				NUMERIC,
		local_fin_0200				NUMERIC,
		local_fin_0220				NUMERIC,
		foreign_0100				NUMERIC,
		foreign_0200				NUMERIC,
		foreign_fin_0220			NUMERIC)

		
	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30))

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
	NULL AS Warning,
	CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
	CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
	left (c.pan,6) as Bin,
	sum (dbo.fn_rpt_islocalfinancial0100Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp,c.card_acceptor_name_loc)) as local_fin_0100,
	sum (dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp,c.card_acceptor_name_loc)) as local_fin_0200,
	sum (dbo.fn_rpt_islocalfinancial0220Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp,t.rsp_code_req, c.card_acceptor_name_loc)) as local_fin_0220,

	sum (dbo.fn_rpt_isforeign0100Trx(t.message_type,c.card_acceptor_name_loc)) as foreign_0100,
	sum (dbo.fn_rpt_isforeign0200Trx(t.message_type,c.card_acceptor_name_loc)) as foreign_0200,
	sum (dbo.fn_rpt_isforeignfinancial0220Trx (t.message_type,t.tran_amount_req,t.rsp_code_rsp,t.rsp_code_req, c.card_acceptor_name_loc)) as foreign_fin_0220	
	
				
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100','0200','0220')--oremeyi removed the 0120
				AND
				
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)
	group by left(c.pan,6)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	

	SELECT
			*
	FROM
			#report_result
	order by Bin
	
END






















GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b36]    Script Date: 05/17/2016 16:30:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



















-- a new report created by Eseosa on 7/05/2013 to generate a summary of switched-out transactions
-- the report became necessry due to the bulkiness of the detail repoRT

ALTER PROCEDURE [dbo].[osp_rpt_b36]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(80),
	@SinkNode		VARCHAR(40),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.
CREATE TABLE #report_result
	(
		
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		Source_node				VARCHAR (40),
		message_type				varchar (6),
		Volume				NUMERIC,
		Response				VARCHAR (15),
		Region				VARCHAR (20))

		

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30))

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
	NULL AS Warning,
	CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
	CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
	c.source_node_name as Source_node,
	t.message_type,
	count(*) as Volume,
	case rsp_code_rsp when '00' then 'Successful' else 'Unsuccessful' end as Response,
	case dbo.fn_rpt_islocalAcqTrx (c.pan) when 1 then 'Local' else 'Foreign' end as Region
	
				
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 0
				AND
				t.message_type IN ('0100','0200','0220')--oremeyi removed the 0120
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND
				(@SinkNode IS NULL or t.sink_node_name = @SinkNode)


	group by c.source_node_name,t.message_type,case rsp_code_rsp when '00' then 'Successful' else 'Unsuccessful' end,case dbo.fn_rpt_islocalAcqTrx (c.pan) when 1 then 'Local' else 'Foreign' end

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	

	SELECT
			*
	FROM
			#report_result
	order by Source_node
	
END






























GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_card_on_foreign_atm]    Script Date: 05/17/2016 16:30:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




















ALTER PROCEDURE [dbo].[osp_rpt_card_on_foreign_atm]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(255),	
	@IINs		VARCHAR(255)=NULL,
	@AcquirerInstId		VARCHAR (255)= NULL,
	@merchants		VARCHAR(512) = NULL,--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT = NULL ,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr
				
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				AND
				c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220')) 
				)
				AND 
				t.tran_completed = 1 
				--AND
				--t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
				pan,				
				terminal_id,
				card_acceptor_id_code,
				card_acceptor_name_loc,
				message_type,
				datetime_req,
				system_trace_audit_nr,
				retrieval_reference_nr,
				settle_amount_req, 
				tran_type_desciption,
				rsp_code_description,
				currency_name,
				auth_id_rsp,
				account_nr 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END














GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_date_from_user]    Script Date: 05/17/2016 16:30:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

--
-- Converts a user supplied date to a DATETIME value.
-- A NULL user supplied date will not result in a warning. The output date is set to NULL.
--

ALTER PROCEDURE [dbo].[osp_rpt_date_from_user]
	@YearMonthDay		CHAR(8),	-- yyyymmdd
	@the_datetime		DATETIME OUTPUT,
	@warning		VARCHAR(255) OUTPUT
AS
BEGIN

	DECLARE @y INTEGER
	DECLARE @m INTEGER
	DECLARE @d INTEGER

	SET @warning = NULL									-- Default value, no error

	IF (@YearMonthDay IS NULL)							-- Then use yesterday the default value
	BEGIN
		SET @the_datetime = NULL
	END
	ELSE
	BEGIN
		-- Convert the Date parameter to DateTime
		-- The TIME portion should be 00:00:00

		SET @y = CAST(SubString(@YearMonthDay, 1, 4) AS INT)
		SET @m = CAST(SubString(@YearMonthDay, 5, 2) AS INT)
		SET @d = CAST(SubString(@YearMonthDay, 7, 2) AS INT)
	END

	--
	-- Validate the different date components
	--

	IF NOT (@y >= 1970 AND @y <= 2099)
		SET @warning = 'Invalid year specified: "' + @YearMonthDay + '"'
	ELSE IF NOT (@m >= 1 AND @m <= 12)
		SET @warning = 'Invalid month specified: "' + @YearMonthDay + '"'
	ELSE IF NOT (@d >= 1 AND @d <= 31)
		SET @warning = 'Invalid day specified: "' + @YearMonthDay + '"'

	--
	-- Construct the actual datetime variable (returned)
	--

	SET @the_datetime = CONVERT(DATETIME, '19000101', 112)
	SET @the_datetime = DATEADD(yy, @y - 1900, @the_datetime)
	SET @the_datetime = DATEADD(mm, @m - 1, @the_datetime)
	SET @the_datetime = DATEADD(dd, @d - 1, @the_datetime)

END

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_date_today]    Script Date: 05/17/2016 16:30:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_date_today]
	@date_today		DATETIME OUTPUT

as
BEGIN
	DECLARE @t DATETIME

	SELECT @t = getDate()
	SET @date_today = CONVERT(DATETIME, CONVERT(VARCHAR(10), @t, 101), 101)
END

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_diff_tran_amts_0100_0220]    Script Date: 05/17/2016 16:30:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO












-- script developed by eseosa osaikhuiwu @ interswitch ltd 02/05/2012
-- modified by eseosa osaikhuiwu @ interswitch ltd to include retrieval reference number 04/05/2012
-- 







ALTER PROCEDURE [dbo].[osp_rpt_diff_tran_amts_0100_0220]

@Start_Date  Varchar(10),
@End_Date  Varchar(10),
@Sink_Node   Varchar(14)


AS 
BEGIN
set NOCOUNT ON


IF (@Start_Date IS NULL or Len(@Start_Date)=0) 

BEGIN
SET @Start_Date = CONVERT(CHAR(8),(DATEADD (dd, -1, GetDate())), 112)
SET @End_Date = @Start_Date

END

CREATE TABLE #summary2
(post_tran_cust_id CHAR(16), tran_count NUMERIC)

CREATE TABLE #summary3
(post_tran_cust_id CHAR(16), mean_amount NUMERIC)

CREATE TABLE #summary4
(auth_stan varchar (10),post_tran_cust_id CHAR(16), auth_tran_amount NUMERIC, auth_tran_currency char (5), auth_settle_amount NUMERIC, auth_settle_currency char (5), auth_datetime DATETIME)

INSERT INTO #summary2

select post_tran_cust_id as post_tran_cust_id, count (*) from post_tran as tran_count
where message_type in ('0100','0220')
and tran_reversed = 0
and rsp_code_rsp = '00'
and post_tran_cust_id in (select distinct post_tran_cust_id from post_tran where message_type = '0220'
and datetime_req >= @Start_Date--(SELECT CONVERT(char(8), (DATEADD (DAY, -32,GETDATE())), 112))
and datetime_req < (SELECT CONVERT(char(8), (DATEADD (DAY, +1,@End_Date)), 112))
and sink_node_name = @Sink_Node)

and post_tran_cust_id not in (select post_tran_cust_id from post_tran where message_type = '0220' and rsp_code_req != '00' and sink_node_name = 'MEGAPRUsnk')
group by post_tran_cust_id

INSERT INTO #summary3

select s2.post_tran_cust_id as post_tran_cust_id, sum (tran_amount_req)/4 as mean_amount
from post_tran ptr (nolock) join #summary2 s2 (nolock)
on ptr.post_tran_cust_id = s2.post_tran_cust_id
where s2.tran_count = 4
group by s2.post_tran_cust_id

INSERT INTO #summary4

select ptr.system_trace_audit_nr as auth_stan, s2.post_tran_cust_id as post_tran_cust_id, tran_amount_req/100 as auth_tran_amount,dbo.currencyAlphaCode(ptr.tran_currency_code) as auth_tran_currency,ptr.settle_amount_req/100 as auth_settle_amount,dbo.currencyAlphaCode(ptr.settle_currency_code) as auth_settle_currency, datetime_req as auth_datetime
from post_tran ptr (nolock) join #summary2 s2 (nolock)
on ptr.post_tran_cust_id = s2.post_tran_cust_id
where s2.tran_count = 4
and ptr.message_type = '0100'
and ptr.tran_postilion_originated=0
--group by s2.post_tran_cust_id


select 
       pt.message_type as message_type,
       ptc.terminal_id as terminal_id,
	s4.auth_stan,
system_trace_audit_nr as completion_stan,
  ptc.card_acceptor_id_code as card_acceptor_id,
ptc.card_acceptor_name_loc as card_acceptor_name_loc,
       
	pan as pan,
	pt.from_account_id as account_number,
	dbo.formatTranTypeStr(pt.tran_type, pt.extended_tran_type, pt.message_type) AS tran_type_description,
       s4.auth_tran_amount,
	s4.auth_tran_currency,
	pt.tran_amount_req/100 as completion_tran_amount,
	dbo.currencyAlphaCode(pt.tran_currency_code) as completion_tran_currency,
	s4.auth_settle_amount,
	s4.auth_settle_currency,
        pt.settle_amount_req/100 as completion_settle_amount,
	dbo.currencyAlphaCode(pt.settle_currency_code) as completion_settle_currency,
       	s4.auth_datetime,
	pt.datetime_req as completion_date_time,
      pt.auth_id_rsp,
	pt.retrieval_reference_nr,
       
       pt.post_tran_cust_id as tran_id

from post_tran_cust ptc (nolock)
join #summary3 s (nolock)
on s.post_tran_cust_id = ptc.post_tran_cust_id
join post_tran pt (nolock) 
on s.post_tran_cust_id = pt.post_tran_cust_id
join #summary4 s4 (nolock)
on s.post_tran_cust_id = s4.post_tran_cust_id
where s.mean_amount != pt.tran_amount_req
and pt.tran_postilion_originated=0
and message_type = '0220'
order by pt.datetime_req


END


















GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_diff_tran_amts_0100_0220_issuer]    Script Date: 05/17/2016 16:30:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO













-- script developed by eseosa osaikhuiwu @ interswitch ltd 02/05/2012
-- modified by eseosa osaikhuiwu @ interswitch ltd to include retrieval reference number 04/05/2012
-- 







ALTER PROCEDURE [dbo].[osp_rpt_diff_tran_amts_0100_0220_issuer]

@Start_Date  Varchar(10),
@End_Date  Varchar(10),
@Source_Node   Varchar(14)


AS 
BEGIN
set NOCOUNT ON


IF (@Start_Date IS NULL or Len(@Start_Date)=0) 

BEGIN
SET @Start_Date = CONVERT(CHAR(8),(DATEADD (dd, -1, GetDate())), 112)
SET @End_Date = @Start_Date

END

CREATE TABLE #summary2
(post_tran_cust_id CHAR(16), tran_count NUMERIC)

CREATE TABLE #summary3
(post_tran_cust_id CHAR(16), mean_amount NUMERIC)

CREATE TABLE #summary4
(auth_stan varchar (10),post_tran_cust_id CHAR(16), auth_tran_amount NUMERIC, auth_tran_currency char (5), auth_settle_amount NUMERIC, auth_settle_currency char (5), auth_datetime DATETIME)

INSERT INTO #summary2

select pt.post_tran_cust_id as post_tran_cust_id, count (*)as tran_count from post_tran pt join post_tran_cust ptc on pt.post_tran_cust_id = ptc.post_tran_cust_id 
where message_type in ('0100','0220')
and tran_reversed = 0
and rsp_code_rsp = '00'
and pt.post_tran_cust_id in (select distinct pt.post_tran_cust_id from post_tran pt join post_tran_cust ptc on pt.post_tran_cust_id = ptc.post_tran_cust_id where message_type = '0220'
and datetime_req >= @Start_Date--(SELECT CONVERT(char(8), (DATEADD (DAY, -32,GETDATE())), 112))
and datetime_req < (SELECT CONVERT(char(8), (DATEADD (DAY, +1,@End_Date)), 112))
and source_node_name = @Source_Node)

and pt.post_tran_cust_id not in (select pt.post_tran_cust_id from post_tran pt join post_tran_cust ptc on pt.post_tran_cust_id = ptc.post_tran_cust_id  where message_type = '0220' and rsp_code_req != '00' and source_node_name = @Source_Node)
group by pt.post_tran_cust_id

INSERT INTO #summary3

select s2.post_tran_cust_id as post_tran_cust_id, sum (tran_amount_req)/4 as mean_amount
from post_tran ptr (nolock) join #summary2 s2 (nolock)
on ptr.post_tran_cust_id = s2.post_tran_cust_id
where s2.tran_count = 4
group by s2.post_tran_cust_id

INSERT INTO #summary4

select ptr.system_trace_audit_nr as auth_stan, s2.post_tran_cust_id as post_tran_cust_id, tran_amount_req/100 as auth_tran_amount,dbo.currencyAlphaCode(ptr.tran_currency_code) as auth_tran_currency,ptr.settle_amount_req/100 as auth_settle_amount,dbo.currencyAlphaCode(ptr.settle_currency_code) as auth_settle_currency, datetime_req as auth_datetime
from post_tran ptr (nolock) join #summary2 s2 (nolock)
on ptr.post_tran_cust_id = s2.post_tran_cust_id
where s2.tran_count = 4
and ptr.message_type = '0100'
and ptr.tran_postilion_originated=0
--group by s2.post_tran_cust_id


select 
       pt.message_type as message_type,
       ptc.terminal_id as terminal_id,
	s4.auth_stan,
system_trace_audit_nr as completion_stan,
  ptc.card_acceptor_id_code as card_acceptor_id,
ptc.card_acceptor_name_loc as card_acceptor_name_loc,
       
	pan as pan,
	pt.from_account_id as account_number,
	dbo.formatTranTypeStr(pt.tran_type, pt.extended_tran_type, pt.message_type) AS tran_type_description,
       s4.auth_tran_amount,
	s4.auth_tran_currency,
	pt.tran_amount_req/100 as completion_tran_amount,
	dbo.currencyAlphaCode(pt.tran_currency_code) as completion_tran_currency,
	s4.auth_settle_amount,
	s4.auth_settle_currency,
        pt.settle_amount_req/100 as completion_settle_amount,
	dbo.currencyAlphaCode(pt.settle_currency_code) as completion_settle_currency,
       	s4.auth_datetime,
	pt.datetime_req as completion_date_time,
      pt.auth_id_rsp,
	pt.retrieval_reference_nr,
       
       pt.post_tran_cust_id as tran_id

from post_tran_cust ptc (nolock)
join #summary3 s (nolock)
on s.post_tran_cust_id = ptc.post_tran_cust_id
join post_tran pt (nolock) 
on s.post_tran_cust_id = pt.post_tran_cust_id
join #summary4 s4 (nolock)

on s.post_tran_cust_id = s4.post_tran_cust_id
where s.mean_amount != pt.tran_amount_req
and pt.tran_postilion_originated=0
and message_type = '0220'
order by pt.datetime_req


END



















GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_different_amounts_in_0100_0220]    Script Date: 05/17/2016 16:30:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




















ALTER PROCEDURE [dbo].[osp_rpt_different_amounts_in_0100_0220]

@Start_Date  Varchar(10),
@End_Date  Varchar(10),
@Sink_Node   Varchar(14)
AS 
BEGIN
set NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF (@Start_Date IS NULL or Len(@Start_Date)=0) 

BEGIN
SET @Start_Date =  CONVERT(CHAR(8),(DATEADD (dd, -1, GetDate())), 112)


END

SET @End_Date =  CONVERT(CHAR(8),(DATEADD (dd, 1, @Start_Date)), 112) 

CREATE TABLE #summary2
(post_tran_cust_id CHAR(16), tran_count NUMERIC)

CREATE TABLE #summary3
(post_tran_cust_id CHAR(16), mean_amount NUMERIC)

CREATE TABLE #summary4
(auth_stan varchar (10),post_tran_cust_id CHAR(16), auth_tran_amount NUMERIC, auth_tran_currency char (5), auth_settle_amount NUMERIC, auth_settle_currency char (5), auth_datetime DATETIME)

INSERT INTO #summary2

select post_tran_cust_id as post_tran_cust_id, count (*) from post_tran_summary (NOLOCK) as tran_count
where message_type in ('0100','0220')
and tran_reversed = 0
and rsp_code_rsp = '00'
and post_tran_cust_id in (select distinct post_tran_cust_id from post_tran_summary (NOLOCK) where message_type = '0220'
and datetime_req >= @Start_Date--(SELECT CONVERT(char(8), (DATEADD (DAY, -32,GETDATE())), 112))
and datetime_req < @ENd_date
and sink_node_name = @Sink_Node)

and post_tran_cust_id not in (select post_tran_cust_id from post_tran_summary (NOLOCK) where message_type = '0220' and rsp_code_req != '00' and sink_node_name = 'MEGAPRUsnk')
group by post_tran_cust_id

INSERT INTO #summary3

select s2.post_tran_cust_id as post_tran_cust_id, sum (tran_amount_req)/4 as mean_amount
from post_tran_summary (NOLOCK) ptr (nolock) join #summary2 s2 (nolock)
on ptr.post_tran_cust_id = s2.post_tran_cust_id
where s2.tran_count = 4
group by s2.post_tran_cust_id

INSERT INTO #summary4

select ptr.system_trace_audit_nr as auth_stan, s2.post_tran_cust_id as post_tran_cust_id, tran_amount_req/100 as auth_tran_amount,dbo.currencyAlphaCode(ptr.tran_currency_code) as auth_tran_currency,ptr.settle_amount_req/100 as auth_settle_amount,dbo.currencyAlphaCode(ptr.settle_currency_code) as auth_settle_currency, datetime_req as auth_datetime
from post_tran_summary ptr (nolock) join #summary2 s2 (nolock)
on ptr.post_tran_cust_id = s2.post_tran_cust_id
where s2.tran_count = 4
and ptr.message_type = '0100'
and ptr.tran_postilion_originated=0
--group by s2.post_tran_cust_id


select 
       pt.message_type as message_type,
       ptc.terminal_id as terminal_id,
	s4.auth_stan,
system_trace_audit_nr as completion_stan,
  ptc.card_acceptor_id_code as card_acceptor_id,
ptc.card_acceptor_name_loc as card_acceptor_name_loc,
       
	pan,
	pt.from_account_id as account_number,
	dbo.formatTranTypeStr(pt.tran_type, pt.extended_tran_type, pt.message_type) AS tran_type_description,
       s4.auth_tran_amount,
	s4.auth_tran_currency,
	pt.tran_amount_req/100 as completion_tran_amount,
	dbo.currencyAlphaCode(pt.tran_currency_code) as completion_tran_currency,
	s4.auth_tran_amount - pt.tran_amount_req/100 as difference_in_amounts,
         
	s4.auth_settle_amount,
	s4.auth_settle_currency,
        pt.settle_amount_req/100 as completion_settle_amount,
	dbo.currencyAlphaCode(pt.settle_currency_code) as completion_settle_currency,
       	s4.auth_datetime,
	pt.datetime_req as completion_date_time,
      pt.auth_id_rsp,
	pt.retrieval_reference_nr,
       
       pt.post_tran_cust_id as tran_id

FROM post_tran_summary  pt (nolock)
join #summary3 s (nolock)
ON s.post_tran_cust_id = ptc.post_tran_cust_id
join #summary4 s4 (nolock)
on s.post_tran_cust_id = s4.post_tran_cust_id
where s.mean_amount != pt.tran_amount_req
and pt.tran_postilion_originated=1
and message_type = '0220'
order by pt.datetime_req


END



















GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_e02_card_on_foreign_atm]    Script Date: 05/17/2016 16:30:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO









ALTER PROCEDURE [dbo].[osp_rpt_e02_card_on_foreign_atm]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNodes		VARCHAR(255),	
	@MessageType		VARCHAR(255)
	
AS
BEGIN
-- my card on foreign atm
select count (*)as 'my card on foreign atm''@MessageType'
from post_tran pt (nolock)
inner join post_tran_cust ptc (nolock)
on pt.post_tran_cust_id = ptc.post_tran_cust_id
where pt.sink_node_name in ('MEGAGTBsnk','MEGAPWCsnk')
and (pt.datetime_req >= @StartDate and pt.datetime_req < @EndDate)
and (pt.message_type = @MessageType)
and (pt.tran_type not in ('00'))
and ((ptc.terminal_id not like '1058%')
and (ptc.terminal_id not like '1082%')
and (ptc.terminal_id not like '1701%'))
and (pt.tran_postilion_originated=0)
and (pt.tran_completed=1)

END







GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_e02_get_transaction_details]    Script Date: 05/17/2016 16:30:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO











ALTER PROCEDURE [dbo].[osp_rpt_e02_get_transaction_details]
	@StartDate		VARCHAR(8),	-- yyyymmdd
	@EndDate		VARCHAR(8),	-- yyyymmdd
	@Tran_Amount		VARCHAR(255)
	
	
AS
BEGIN

select b.pan,b.expiry_date,b.service_restriction_code,b.terminal_id,a.retrieval_reference_nr,a.system_trace_audit_nr,a.auth_id_rsp,a.retrieval_reference_nr,a.datetime_tran_local,a.tran_amount_req
from post_tran a(nolock), post_tran_cust b(nolock)
where a.post_tran_cust_id = b.post_tran_cust_id
and a.datetime_tran_local > @StartDate and a.datetime_tran_local < @EndDate
--and a.post_tran_cust_id = '4553505'
and tran_amount_req = @Tran_Amount
--and b.pan like %@Pan_Last_four
and tran_postilion_originated = 0


END










GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_format_pan]    Script Date: 05/17/2016 16:30:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_format_pan]
		@pan		VARCHAR (19),
		@pan_encrypted	CHAR (18),
		@process_descr	VARCHAR (100),		-- The name of the report calling this procedure (for error-handling purposes)
		@show_full_pan	INT,			-- 0/1/2/3: Partially masked/Clear/As is/Completely masked
		@pan_return	VARCHAR (19)	OUTPUT,
		@error		INT		OUTPUT	-- If > 0, an error occurred
AS
BEGIN
	-- If the PAN should be viewed in the clear
	IF (@show_full_pan = 1)
	BEGIN
		-- Decrypt PAN (if the user has permissions)
		EXEC osp_decrypt_pan @pan, @pan_encrypted, @process_descr, @pan_return OUTPUT, @error OUTPUT
	END
	-- If the PAN should be viewed partially masked
	ELSE IF (@show_full_pan = 0)
	BEGIN
		DECLARE @pan_clear VARCHAR(19)
		SET @pan_clear = @pan

		-- If PAN is not empty, and is completely masked,
		IF (LEN(@pan) > 0) AND 
			(CHARINDEX('5', @pan) = 0) AND 
			(CHARINDEX('4', @pan) = 0) AND 
			(CHARINDEX('9', @pan) = 0) AND 
			(CHARINDEX('1', @pan) = 0) AND 
			(CHARINDEX('2', @pan) = 0) AND 
			(CHARINDEX('3', @pan) = 0) AND 
			(CHARINDEX('6', @pan) = 0) AND 
			(CHARINDEX('7', @pan) = 0) AND 
			(CHARINDEX('8', @pan) = 0) AND
			(CHARINDEX('0', @pan) = 0)
		BEGIN
			-- Decrypt PAN (if the user has permissions)
			EXEC osp_decrypt_pan @pan, @pan_encrypted, @process_descr, @pan_clear OUTPUT, @error OUTPUT

			-- Ensure that even if decryption failed, we have something to mask
			IF @pan_clear IS NULL
			BEGIN
				SET @pan_clear = @pan
			END
		END

		-- Mask the PAN partially
		EXEC osp_mask_pan_2 @pan_clear, @process_descr, 0, @pan_return OUTPUT, @error OUTPUT
	END
	-- If the PAN should be viewed completely masked
	ELSE IF (@show_full_pan = 3)
	BEGIN
		-- Mask the PAN completely
		EXEC osp_mask_pan_2 @pan, @process_descr, 1, @pan_return OUTPUT, @error OUTPUT
	END
	ELSE
	BEGIN
		-- Else just leave the PAN as is
		SET @pan_return = @pan
	END
END

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates]    Script Date: 05/17/2016 16:30:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





--
-- Used the Report SP's for the selection of dates for which the report will run for.
-- Algo:
--    1. The user's start and end date will be the first option to choose.
--    2. IF the user dates are not specified, the 'default_date_method'
--        will be used to determine the date range
--
-- NB: The report_start_date and report_end_date parameter will be set to the same day if the
--      report needs to be generated for a single date only.
--
ALTER PROCEDURE [dbo].[osp_rpt_get_dates]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (30),
	@user_end_date		VARCHAR (30),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN
    
    
    IF (@user_start_date IS NULL AND @user_end_date IS NULL)
		BEGIN
			DECLARE @norm_cutover INT;
			EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
		        IF  (@norm_cutover=0) BEGIN
				SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'
			RETURN
			END
			
		END


	END 
 
	
	IF (@default_date_method = 'Last business day'  and @user_start_date is null and @user_end_date is null) 
		BEGIN
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
		     -- SELECT @user_start_date, @user_start_date, @user_end_date
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	END 

	IF (@default_date_method = 'Previous week')
	BEGIN
		
	
	        SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-7,GETDATE()),111),'/', '')
		SET @report_date_start = @user_start_date
		SET @report_date_end = @user_end_date
		
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
               
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	END
			

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SET @user_end_date = GETDATE()
		SET @report_date_start = @user_start_date;
		SET @report_date_end = @user_end_date;
	END

	ELSE IF (@default_date_method = 'Previous month')
		BEGIN
	
SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(Month,-1,GETDATE()),111),'/', '')
			SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
		END
		
	else BEGIN
	
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;


	end









GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_2]    Script Date: 05/17/2016 16:30:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_get_dates_2]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (8),
	@user_end_date		VARCHAR (8),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN

	DECLARE  @rpt_get_dates TABLE
	(
		node_name	VARCHAR (12)
	)

	DELETE FROM @rpt_get_dates

	DECLARE @yy INT
	DECLARE @mm INT
	DECLARE @dd INT

	SELECT @warning = NULL

	IF @default_date_method IS NULL
		SET @default_date_method = '<Not specified>'


	IF (@user_start_date IS NOT NULL OR @user_end_date IS NOT NULL)
	BEGIN

		--
		-- At least one date was specified, so use the specified dates
		--

		IF (@user_start_date IS NULL OR @user_end_date IS NULL)
		BEGIN
				SET @warning = 'Both the from- and to- dates should be specified.'
				RETURN
		END

		--
		-- Start date
		--

		EXECUTE osp_rpt_date_from_user @user_start_date, @report_date_start OUTPUT, @warning OUTPUT

		IF (@warning IS NOT NULL)
		BEGIN
			RETURN
		END

		--
		-- End date
		--

		EXECUTE osp_rpt_date_from_user @user_end_date, @report_date_end OUTPUT, @warning OUTPUT

		IF (@warning IS NOT NULL)
		BEGIN
			RETURN
		END

		--
		-- Some validation
		--

		IF (@report_date_end < @report_date_start)
		BEGIN
			SET @warning = 'The End Date must be AFTER the Start Date.'
			RETURN
		END
	END -- use specified dates

	ELSE

	IF (@default_date_method = 'Last business day')
	BEGIN

		--
		-- Generate our list of source node names
		--

		DECLARE @tmp_node_list VARCHAR (2048)
		SET @tmp_node_list = @node_name_list

		WHILE (@tmp_node_list IS NOT NULL)
		BEGIN
				INSERT INTO @rpt_get_dates (node_name) VALUES (dbo.fn_rpt_nextelem(@tmp_node_list))
				SET @tmp_node_list = dbo.fn_rpt_remainelem(@tmp_node_list)
		END

		--
		-- We need to get the business date of the last closed batch.
		--

		SET @report_date_start = NULL

		SELECT
				@report_date_start = MAX (b.settle_date)

		FROM
				post_batch b WITH (NOLOCK)
				INNER JOIN
				post_settle_entity s WITH (NOLOCK)
					ON (b.settle_entity_id = s.settle_entity_id)

		WHERE
				s.node_name IN (SELECT node_name FROM @rpt_get_dates)
				AND
				b.datetime_end IS NOT NULL

		IF (@report_date_start IS NULL)
		BEGIN
			SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'

			RETURN
		END

		--IF (@report_date_start
		SET @report_date_end = @report_date_start

        DECLARE @yesterday VARCHAR(30)
        SET @yesterday = DATEADD(D, -1, DATEDIFF(D, 0, GETDATE()))

        IF( @report_date_start >= @yesterday)
           BEGIN
             SET @report_date_start = @yesterday
             SET @report_date_end = @yesterday
           END

      --  SELECT @report_date_end AS 'report_date_end';
       -- SELECT @report_date_start AS 'report_date_start';

	END -- Last business day


        ELSE

	IF (@default_date_method = 'Two Days Ago')
	BEGIN
		

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_start = @report_date_end

		SELECT @report_date_start = DATEADD (dd, -2, @report_date_start)

		SELECT @report_date_end = DATEADD (dd, -2, @report_date_end)
	END


	ELSE

	IF (@default_date_method = 'Previous week')
	BEGIN
		--
		-- Previous week
		-- We do not know if the week should start on a Sun, or a Mon. We, for now, consider a week as the last 7 days - up to yesterday
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_start = @report_date_end

		SELECT @report_date_start = DATEADD (dd, -7, @report_date_start)

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
		--
		-- Previous day
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)

		SELECT @report_date_start = @report_date_end
	END

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		--
		-- Today
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_start = @report_date_end
	END

	ELSE

	IF (@default_date_method = 'Previous month')
	BEGIN

		-- Previous month

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_end = DATEADD (dd, -DATEPART(dd, @report_date_end), @report_date_end)

		SELECT @report_date_start = @report_date_end

		SELECT @report_date_start = DATEADD (dd, - DATEPART(dd, @report_date_start) + 1, @report_date_start)

		SELECT @report_date_end = DATEADD (dd, 1, @report_date_end)

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)
	END

	ELSE

	IF (@default_date_method = 'Last closed batch end calendar day')
	BEGIN

		--
		-- Generate our list of source node names
		--

		DECLARE @tmp_node_list_2 VARCHAR (2048)
		SET @tmp_node_list_2 = @node_name_list

		WHILE (@tmp_node_list_2 IS NOT NULL)
		BEGIN
				INSERT INTO @rpt_get_dates (node_name) VALUES (dbo.fn_rpt_nextelem(@tmp_node_list_2))
				SET @tmp_node_list_2 = dbo.fn_rpt_remainelem(@tmp_node_list_2)
		END

		--
		-- We need to get the calendar date of the end of the last closed batch.
		--

		SET @report_date_start = NULL

		SELECT
				@report_date_start = MAX (b.datetime_end)

		FROM
				post_batch b WITH (NOLOCK)
				INNER JOIN
				post_settle_entity s WITH (NOLOCK)
					ON (b.settle_entity_id = s.settle_entity_id)

		WHERE
				s.node_name IN (SELECT node_name FROM @rpt_get_dates)
				AND
				b.datetime_end IS NOT NULL

		IF (@report_date_start IS NULL)
		BEGIN
			SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The calendar date of the last closed batch could not be determined.'

			RETURN
		END

		-- Get only the date portion of the datetime_begin
		SET @report_date_start = CONVERT(DATETIME, CONVERT(VARCHAR(10), @report_date_start, 101), 101)
		SET @report_date_end = @report_date_start

	END -- Last closed batch end calendar day

	ELSE

	BEGIN
		SET @warning = 'Invalid default date method specified: ' + @default_date_method
	END

	SET @report_date_end_next = DATEADD(dd, 1, @report_date_end)


END













GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_2015]    Script Date: 05/17/2016 16:30:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



--
-- Used the Report SP's for the selection of dates for which the report will run for.
-- Algo:
--    1. The user's start and end date will be the first option to choose.
--    2. IF the user dates are not specified, the 'default_date_method'
--        will be used to determine the date range
--
-- NB: The report_start_date and report_end_date parameter will be set to the same day if the
--      report needs to be generated for a single date only.
--

ALTER PROCEDURE [dbo].[osp_rpt_get_dates_2015]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (30),
	@user_end_date		VARCHAR (30),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN
    
  /*  
    IF (@user_start_date IS NULL AND @user_end_date IS NULL)
		BEGIN
			DECLARE @norm_cutover INT;
			EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
		        IF  (@norm_cutover=0) BEGIN
				SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'
			RETURN
			END
			
		END


	END 
	*/
 
	
	IF (@default_date_method = 'Last business day' OR @default_date_method IS NULL)
		BEGIN
			
			SELECT  @user_start_date =isnull(@user_start_date, REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', ''))
			SET       @user_end_date =isnull(@user_end_date,REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', ''))
		     -- SELECT @user_start_date, @user_start_date, @user_end_date
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	END 

	IF (@default_date_method = 'Previous week')
	BEGIN
		
	
	        SET @user_start_date =isnull(@user_start_date,REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', ''))
		SELECT @user_end_date =isnull(@user_end_date,REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-7,GETDATE()),111),'/', ''))
		SET @report_date_start = @user_start_date
		SET @report_date_end = @user_end_date
		
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
               
			
			SELECT  @user_start_date =isnull(@user_start_date,REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', ''))
			SET      @user_end_date =isnull(@user_end_date, REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', ''))
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	END
			

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		SELECT  @user_start_date =isnull(@user_start_date, REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', ''));
		SET @user_end_date =isnull(@user_end_date, GETDATE())
		SET @report_date_start = @user_start_date;
		SET @report_date_end = @user_end_date;
	END

	ELSE IF (@default_date_method = 'Previous month')
		BEGIN
	
SELECT  @user_start_date =isnull(@user_start_date, REPLACE(CONVERT(VARCHAR(10), DATEADD(Month,-1,GETDATE()),111),'/', ''))
			SET @user_end_date =isnull(@user_end_date,REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', ''))
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
		END
		
	else BEGIN
	
	
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	
	end




end
GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_2015_bkp]    Script Date: 05/17/2016 16:30:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



--
-- Used the Report SP's for the selection of dates for which the report will run for.
-- Algo:
--    1. The user's start and end date will be the first option to choose.
--    2. IF the user dates are not specified, the 'default_date_method'
--        will be used to determine the date range
--
-- NB: The report_start_date and report_end_date parameter will be set to the same day if the
--      report needs to be generated for a single date only.
--

ALTER PROCEDURE [dbo].[osp_rpt_get_dates_2015_bkp]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (30),
	@user_end_date		VARCHAR (30),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN
    
    
    IF (@user_start_date IS NULL AND @user_end_date IS NULL)
		BEGIN
			DECLARE @norm_cutover INT;
		--	EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
		 --       IF  (@norm_cutover=0) BEGIN
			--	SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'
			--RETURN
			--END
			
		END


	END 
 
	
	IF (@default_date_method = 'Last business day' --OR @default_date_method IS NULL
	)
		BEGIN
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
		     -- SELECT @user_start_date, @user_start_date, @user_end_date
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	END 

	IF (@default_date_method = 'Previous week')
	BEGIN
		
	
	        SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-7,GETDATE()),111),'/', '')
		SET @report_date_start = @user_start_date
		SET @report_date_end = @user_end_date
		
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
               
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	END
			

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SET @user_end_date = GETDATE()
		SET @report_date_start = @user_start_date;
		SET @report_date_end = @user_end_date;
	END

	ELSE IF (@default_date_method = 'Previous month')
		BEGIN
	
SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(Month,-1,GETDATE()),111),'/', '')
			SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
		END
		
	else BEGIN
	
	
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	
	end





GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_2015_old]    Script Date: 05/17/2016 16:30:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



--
-- Used the Report SP's for the selection of dates for which the report will run for.
-- Algo:
--    1. The user's start and end date will be the first option to choose.
--    2. IF the user dates are not specified, the 'default_date_method'
--        will be used to determine the date range
--
-- NB: The report_start_date and report_end_date parameter will be set to the same day if the
--      report needs to be generated for a single date only.
--

ALTER PROCEDURE [dbo].[osp_rpt_get_dates_2015_old]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (30),
	@user_end_date		VARCHAR (30),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN
    
    
    IF (@user_start_date IS NULL AND @user_end_date IS NULL)
		BEGIN
			DECLARE @norm_cutover INT;
			EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
		        IF  (@norm_cutover=0) BEGIN
				SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'
			RETURN
			END
			
		END


	END 
 
	
	IF (@default_date_method = 'Last business day' OR @default_date_method IS NULL)
		BEGIN
			
			SELECT  @report_date_start = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET      @report_date_end =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
			SET @report_date_start = ISNULL(@user_start_date, @report_date_start)
				SET @report_date_end = ISNULL(@user_end_date, @report_date_end)
		
	
	END 

	IF (@default_date_method = 'Previous week')
	BEGIN
		
	
	        SET @report_date_end  = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
	    	SELECT @report_date_start = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-7,GETDATE()),111),'/', '')
			SET @report_date_start = ISNULL(@user_start_date, @report_date_start)
				SET @report_date_end = ISNULL(@user_end_date, @report_date_end)
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
	        SET @report_date_end  = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
	    	SELECT @report_date_start = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET @report_date_start = ISNULL(@user_start_date, @report_date_start)
				SET @report_date_end = ISNULL(@user_end_date, @report_date_end)
	END
			

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		SELECT  @report_date_start = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SET @report_date_end = GETDATE()
			SET @report_date_start = ISNULL(@user_start_date, @report_date_start)
				SET @report_date_end = ISNULL(@user_end_date, @report_date_end)
	END

	ELSE IF (@default_date_method = 'Previous month')
		BEGIN

				SELECT  @report_date_start = REPLACE(CONVERT(VARCHAR(10), DATEADD(Month,-1,GETDATE()),111),'/', '')
				SET @report_date_end = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
			SET @report_date_start = ISNULL(@user_start_date, @report_date_start)
				SET @report_date_end = ISNULL(@user_end_date, @report_date_end)
		END
		
	else BEGIN
	
	SELECT  @report_date_start = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET @report_date_end = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
				SET @report_date_start = ISNULL(@user_start_date, @report_date_start)
				SET @report_date_end = ISNULL(@user_end_date, @report_date_end)
	
	end




GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_20160215]    Script Date: 05/17/2016 16:30:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




--
-- Used the Report SP's for the selection of dates for which the report will run for.
-- Algo:
--    1. The user's start and end date will be the first option to choose.
--    2. IF the user dates are not specified, the 'default_date_method'
--        will be used to determine the date range
--
-- NB: The report_start_date and report_end_date parameter will be set to the same day if the
--      report needs to be generated for a single date only.
--

ALTER PROCEDURE [dbo].[osp_rpt_get_dates_20160215]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (30),
	@user_end_date		VARCHAR (30),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN
    
    
    IF (@user_start_date IS NULL AND @user_end_date IS NULL)
		BEGIN
			DECLARE @norm_cutover INT;
			EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
		        IF  (@norm_cutover=0) BEGIN
				SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'
			RETURN
			END
			
		END


	END 
 
	
	IF (@default_date_method = 'Last business day' and @user_start_date IS NULL AND @user_end_date IS NULL
)
		BEGIN
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
		     -- SELECT @user_start_date, @user_start_date, @user_end_date
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	END 

	IF (@default_date_method = 'Previous week')
	BEGIN
		
	
	        SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-7,GETDATE()),111),'/', '')
		SET @report_date_start = @user_start_date
		SET @report_date_end = @user_end_date
		
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
               
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	END
			

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SET @user_end_date = GETDATE()
		SET @report_date_start = @user_start_date;
		SET @report_date_end = @user_end_date;
	END

	ELSE IF (@default_date_method = 'Previous month')
		BEGIN
	
SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(Month,-1,GETDATE()),111),'/', '')
			SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
		END
		
	else BEGIN
	
	
	
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	
	end





GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_3]    Script Date: 05/17/2016 16:30:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





--
-- Used the Report SP's for the selection of dates for which the report will run for.
-- Algo:
--    1. The user's start and end date will be the first option to choose.
--    2. IF the user dates are not specified, the 'default_date_method'
--        will be used to determine the date range
--
-- NB: The report_start_date and report_end_date parameter will be set to the same day if the
--      report needs to be generated for a single date only.
--

ALTER PROCEDURE [dbo].[osp_rpt_get_dates_3]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (8),
	@user_end_date		VARCHAR (8),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN

	CREATE TABLE #rpt_get_dates
	(
		node_name	VARCHAR (12)
	)

	DELETE FROM #rpt_get_dates

	DECLARE @yy INT
	DECLARE @mm INT
	DECLARE @dd INT

	SELECT @warning = NULL

	IF @default_date_method IS NULL
		SET @default_date_method = '<Not specified>'


	IF (@user_start_date IS NOT NULL OR @user_end_date IS NOT NULL)
	BEGIN

		--
		-- At least one date was specified, so use the specified dates
		--

		IF (@user_start_date IS NULL OR @user_end_date IS NULL)
		BEGIN
				SET @warning = 'Both the from- and to- dates should be specified.'
				RETURN
		END

		--
		-- Start date
		--

		EXECUTE osp_rpt_date_from_user @user_start_date, @report_date_start OUTPUT, @warning OUTPUT

		IF (@warning IS NOT NULL)
		BEGIN
			RETURN
		END

		--
		-- End date
		--

		EXECUTE osp_rpt_date_from_user @user_end_date, @report_date_end OUTPUT, @warning OUTPUT

		IF (@warning IS NOT NULL)
		BEGIN
			RETURN
		END

		--
		-- Some validation
		--

		IF (@report_date_end < @report_date_start)
		BEGIN
			SET @warning = 'The End Date must be AFTER the Start Date.'
			RETURN
		END
	END -- use specified dates

	ELSE

	IF (@default_date_method = 'Last business day')
	BEGIN

		--
		-- Generate our list of source node names
		--

		DECLARE @tmp_node_list VARCHAR (2048)
		SET @tmp_node_list = @node_name_list

		WHILE (@tmp_node_list IS NOT NULL)
		BEGIN
				INSERT INTO #rpt_get_dates (node_name) VALUES (dbo.fn_rpt_nextelem(@tmp_node_list))
				SET @tmp_node_list = dbo.fn_rpt_remainelem(@tmp_node_list)
		END

		--
		-- We need to get the business date of the last closed batch.
		--

		SET @report_date_start = NULL

		SELECT
				@report_date_start = MAX (b.settle_date)

		FROM
				post_batch b WITH (NOLOCK)
				INNER JOIN
				post_settle_entity s WITH (NOLOCK)
					ON (b.settle_entity_id = s.settle_entity_id)

		WHERE
				s.node_name IN (SELECT node_name FROM #rpt_get_dates)
				AND
				b.datetime_end IS NOT NULL

		IF (@report_date_start IS NULL)
		BEGIN
			SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'

			RETURN
		END

		SET @report_date_end = @report_date_start

	END -- Last business day

	ELSE

	IF (@default_date_method = 'Previous week')
	BEGIN
		--
		-- Previous week
		-- We do not know if the week should start on a Sun, or a Mon. We, for now, consider a week as the last 7 days - up to yesterday
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_start = @report_date_end

		SELECT @report_date_start = DATEADD (dd, -7, @report_date_start)

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
		--
		-- Previous day
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)

		SELECT @report_date_start = @report_date_end
	END

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		--
		-- Today
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_start = @report_date_end
	END

	ELSE

	IF (@default_date_method = 'Previous month')
	BEGIN

		-- Previous month

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_end = DATEADD (dd, -DATEPART(dd, @report_date_end), @report_date_end)

		SELECT @report_date_start = @report_date_end

		SELECT @report_date_start = DATEADD (dd, - DATEPART(dd, @report_date_start) + 1, @report_date_start)

		SELECT @report_date_end = DATEADD (dd, 1, @report_date_end)

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)
	END

	ELSE

	IF (@default_date_method = 'Last closed batch end calendar day')
	BEGIN

		--
		-- Generate our list of source node names
		--

		DECLARE @tmp_node_list_2 VARCHAR (2048)
		SET @tmp_node_list_2 = @node_name_list

		WHILE (@tmp_node_list_2 IS NOT NULL)
		BEGIN
				INSERT INTO #rpt_get_dates (node_name) VALUES (dbo.fn_rpt_nextelem(@tmp_node_list_2))
				SET @tmp_node_list_2 = dbo.fn_rpt_remainelem(@tmp_node_list_2)
		END

		--
		-- We need to get the calendar date of the end of the last closed batch.
		--

		SET @report_date_start = NULL

		SELECT
				@report_date_start = MAX (b.datetime_end)

		FROM
				post_batch b WITH (NOLOCK)
				INNER JOIN
				post_settle_entity s WITH (NOLOCK)
					ON (b.settle_entity_id = s.settle_entity_id)

		WHERE
				s.node_name IN (SELECT node_name FROM #rpt_get_dates)
				AND
				b.datetime_end IS NOT NULL

		IF (@report_date_start IS NULL)
		BEGIN
			SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The calendar date of the last closed batch could not be determined.'

			RETURN
		END

		-- Get only the date portion of the datetime_begin
		SET @report_date_start = CONVERT(DATETIME, CONVERT(VARCHAR(10), @report_date_start, 101), 101)
		SET @report_date_end = @report_date_start

	END -- Last closed batch end calendar day

	ELSE

	BEGIN
		SET @warning = 'Invalid default date method specified: ' + @default_date_method
	END

	SET @report_date_end_next = DATEADD(dd, 1, @report_date_end)

	DROP TABLE #rpt_get_dates
END





GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_backup]    Script Date: 05/17/2016 16:30:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




--
-- Used the Report SP's for the selection of dates for which the report will run for.
-- Algo:
--    1. The user's start and end date will be the first option to choose.
--    2. IF the user dates are not specified, the 'default_date_method'
--        will be used to determine the date range
--
-- NB: The report_start_date and report_end_date parameter will be set to the same day if the
--      report needs to be generated for a single date only.
--

ALTER PROCEDURE [dbo].[osp_rpt_get_dates_backup]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (30),
	@user_end_date		VARCHAR (30),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN
    
    
    IF (@user_start_date IS NULL AND @user_end_date IS NULL)
		BEGIN
			DECLARE @norm_cutover INT;
			EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
		        IF  (@norm_cutover=0) BEGIN
				SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'
			RETURN
			END
			
		END


	END 
 
	
	IF (@default_date_method = 'Last business day' and @user_start_date IS NULL AND @user_end_date IS NULL
)
		BEGIN
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
		     -- SELECT @user_start_date, @user_start_date, @user_end_date
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	END 

	IF (@default_date_method = 'Previous week')
	BEGIN
		
	
	        SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-7,GETDATE()),111),'/', '')
		SET @report_date_start = @user_start_date
		SET @report_date_end = @user_end_date
		
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
               
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	END
			

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SET @user_end_date = GETDATE()
		SET @report_date_start = @user_start_date;
		SET @report_date_end = @user_end_date;
	END

	ELSE IF (@default_date_method = 'Previous month')
		BEGIN
	
SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(Month,-1,GETDATE()),111),'/', '')
			SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
		END
		
	else BEGIN
	
	SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	
	end






GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_servername]    Script Date: 05/17/2016 16:30:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_get_servername]
AS
BEGIN
	SELECT @@SERVERNAME as servername
END

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_yearmonth]    Script Date: 05/17/2016 16:30:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_get_yearmonth]
	@YearMonth		CHAR(6) OUTPUT,	-- yyyymm
	@y					INT OUTPUT,
	@m					INT OUTPUT,
	@warning			VARCHAR(255) OUTPUT
AS
BEGIN
	DECLARE @def_date	DATETIME

	SET @warning = ''									-- Default value

	IF (@YearMonth IS NULL)							-- Then use last month as the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(mm,-1,@def_date)	-- Get the previous month
		SET @y = DATEPART(yy,@def_date)
		SET @m = DATEPART(mm,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @YearMonth = CONVERT(CHAR(4),@y) +  Right('0' + CONVERT(VARCHAR(2),@m),2)
	END
	ELSE
	BEGIN
		SET @y = CAST(SubString(@YearMonth, 1, 4) AS INT)
		SET @m = CAST(SubString(@YearMonth, 5, 2) AS INT)
	END

	IF NOT (@y BETWEEN 1970 AND 2099 and @m BETWEEN 0 AND 13)
	BEGIN
		IF NOT (@y BETWEEN 1970 AND 2099)
			SET @warning = 'Invalid year specified: "' + @YearMonth + '"'
		ELSE
			SET @warning = 'Invalid month specified: "' + @YearMonth + '"'
	END
END

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_yearmonthday]    Script Date: 05/17/2016 16:30:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_get_yearmonthday]
	@YearMonthDay		CHAR(8) OUTPUT,	-- yyyymmdd
	@y						INT OUTPUT,
	@m						INT OUTPUT,
	@d						INT OUTPUT,
	@warning				VARCHAR(255) OUTPUT
AS
BEGIN
	DECLARE @def_date	DATETIME

	SET @warning = ''									-- Default value

	IF (@YearMonthDay IS NULL)							-- Then use yesterday the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(dd,-1,@def_date)	-- Get the previous day
		SET @y = DATEPART(yy,@def_date)
		SET @m = DATEPART(mm,@def_date)
		SET @d = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @YearMonthDay = CONVERT(CHAR(4),@y) +  Right('0' + CONVERT(VARCHAR(2),@m),2) +  Right('0' + CONVERT(VARCHAR(2),@d),2)
	END
	ELSE
	BEGIN
		-- Convert the Date parameter to DateTime
		-- The TIME portion should be 00:00:00
		SET @y = CAST(SubString(@YearMonthDay, 1, 4) AS INT)
		SET @m = CAST(SubString(@YearMonthDay, 5, 2) AS INT)
		SET @d = CAST(SubString(@YearMonthDay, 7, 2) AS INT)
	END

	IF NOT (@y BETWEEN 1970 AND 2099 and @m BETWEEN 0 AND 13 and @d BETWEEN 0 AND 32)
	BEGIN
		IF NOT (@y BETWEEN 1970 AND 2099)
			SET @warning = 'Invalid year specified: "' + @YearMonthDay + '"'
		ELSE IF NOT (@m BETWEEN 0 AND 13)
			SET @warning = 'Invalid month specified: "' + @YearMonthDay + '"'
		ELSE
			SET @warning = 'Invalid day specified: "' + @YearMonthDay + '"'
	END
END

GO


