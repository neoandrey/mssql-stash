USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_resolve_autopay_floatcard_diff]    Script Date: 01/08/2015 10:54:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER       PROCEDURE [dbo].[osp_rpt_resolve_autopay_floatcard_diff]
	@MaskedPAN		VARCHAR(19),
	@fullpan		VARCHAR(19),
	@StartDate		varchar(10),
	@EndDate		varchar (10),
	@terminal_id	VARCHAR(12)

AS BEGIN
--- the script was modified by Bolaji on 2015-01-07
-- script was modified to process the reconciliation of transactions with Switch transactions

IF (DATEDIFF(D,@StartDate,@EndDate )=0)BEGIN

    SET @EndDate =  DATEADD(D,1, DATEDIFF(D,0, @EndDate));
    END
    
DECLARE @terminal_id_list TABLE (terminal_id	VARCHAR(12));

INSERT INTO @terminal_id_list SELECT part FROM dbo.usf_split_string(@terminal_id, ',');
IF ( OBJECT_ID('tempdb.dbo.#filter_float_card_trans') IS NOT NULL)
		 BEGIN
		          DROP TABLE #filter_float_card_trans
		 END
IF ( OBJECT_ID('tempdb.dbo.#transaction_batch_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #transaction_batch_data
		 END


;WITH float_card_report_trans 
   (source_node_name,
   datetime_tran_local,
   datetime_req,
   terminal_id,
   card_acceptor_id_code, 
   card_acceptor_name_loc, 
   tran_type_description, 
   retrieval_reference_nr, 
   system_trace_audit_nr,
   settle_amount_impact,
   settle_tran_fee,
   currency_alpha_code,
   from_account_id,
   from_account_type,
   to_account_id,
   to_account_type,
   post_tran_cust_id,
   sink_node_name,
   rsp_code_rsp,
   Response_Code_description,
   acquiring_inst_id_code, 
   terminal_owner,
   payee)   
      AS (
	  SELECT
            source_node_name,	
			t.datetime_tran_local,
			t.datetime_req,
			c.terminal_id,
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) , 
			t.retrieval_reference_nr, 	
			t.system_trace_audit_nr,		
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END, t.settle_currency_code) ,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) ,					
			dbo.currencyAlphaCode(t.settle_currency_code) ,
			t.from_account_id,
			dbo.rpt_fxn_account_type(t.from_account_type),
			t.to_account_id,
			dbo.rpt_fxn_account_type(t.to_account_type),
			c.post_tran_cust_id,
			t.sink_node_name,
			rsp_code_rsp,
			dbo.formatRspCodeStr(t.rsp_code_rsp) ,
			acquiring_inst_id_code,
			terminal_owner,
			payee
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)

	WHERE 		
	(t.datetime_req >= @StartDate and t.datetime_req < @EndDate)
	AND
	      (
	               (LEFT(c.pan,6) = LEFT(@MaskedPAN,6)  AND RIGHT(c.pan,4) = RIGHT(@MaskedPAN,4))
	               OR 
	               	(LEFT(c.pan,6) = LEFT(@fullpan,6)  AND RIGHT(c.pan,4) = RIGHT(@fullpan,4))              
                )
			AND (t.from_account_id = @fullpan or t.to_account_id = @fullpan)
                        and t.tran_completed = 1
			AND 	t.tran_postilion_originated = 0 
			AND	(t.message_type IN ('0200','0220','0420') )
			AND	t.tran_type IN ('00', '01', '09', '20', '21', '40', '50' )
			AND RIGHT(t.sink_node_name,5)= 'CCsnk' or RIGHT(t.sink_node_name,6) ='MPPsnk'
			AND settle_currency_code ='566'
			AND RIGHT(REPLACE(card_acceptor_name_loc, ' ',''), 5) ='/LANG'


),  switch_report_trans( retrieval_reference_nr) AS

(
		SELECT 
			trans.retrieval_reference_nr
		FROM post_tran trans (nolock)
			JOIN post_tran_cust cust (nolock)
				ON trans.post_tran_cust_id = cust.post_tran_cust_id
		WHERE cust.terminal_id IN (SELECT terminal_id FROM @terminal_id_list)
		AND cust.source_node_name IN  ('WEBSWTsrc','WEBsrc','WEB1src','WEB2src','WEB3src') 
		AND (trans.datetime_req >= @StartDate and trans.datetime_req < @EndDate)
		and trans.message_type ='0200'
		and trans.tran_postilion_originated = '0'
		and trans.tran_reversed = '0'
		AND
		(
		   (LEFT(cust.pan,6) = LEFT(@MaskedPAN,6)  AND RIGHT(cust.pan,4) = RIGHT(@MaskedPAN,4))
		   OR 
		(LEFT(cust.pan,6) = LEFT(@fullpan,6)  AND RIGHT(cust.pan,4) = RIGHT(@fullpan,4))              
		)
)
SELECT source_node_name,datetime_tran_local,datetime_req,terminal_id,card_acceptor_id_code, card_acceptor_name_loc, tran_type_description, retrieval_reference_nr, system_trace_audit_nr,settle_amount_impact,settle_tran_fee,currency_alpha_code,from_account_id,from_account_type,to_account_id,to_account_type,post_tran_cust_id,sink_node_name,Response_Code_description, terminal_owner,payee
INTO #filter_float_card_trans	
	FROM
float_card_report_trans WHERE retrieval_reference_nr NOT IN (SELECT retrieval_reference_nr FROM switch_report_trans);


 SELECT 
CASE 

WHEN CHARINDEX('/',card_acceptor_name_loc)=7 THEN
   LEFT(card_acceptor_name_loc,6)
 WHEN CHARINDEX('REV',card_acceptor_name_loc)>0 THEN
  LEFT(REPLACE(card_acceptor_name_loc, 'REV/',''),6)
WHEN RIGHT(REPLACE(card_acceptor_name_loc, ' ',''), 5) ='/LANG' THEN

 REPLACE( REVERSE(SUBSTRING(REVERSE(REPLACE(REPLACE(card_acceptor_name_loc, ' ',''),'/LANG','')), 0,CHARINDEX('/',REVERSE(REPLACE(REPLACE(card_acceptor_name_loc, ' ',''),'/LANG',''))))),'LANG','')
ELSE
card_acceptor_name_loc

END as batch_identifier, retrieval_reference_nr,settle_amount_impact,settle_tran_fee,0 as transaction_count, 0 as total_settlement_impact,0 as total_settle_tran_fee INTO  #transaction_batch_data FROM #filter_float_card_trans WHERE  CHARINDEX('deposit',tran_type_description) <= 0
					
DECLARE @batch_identifier VARCHAR (20);
DECLARE @batch_sum FLOAT;
DECLARE @settle_tran_fee_sum FLOAT;
DECLARE @transaction_count BIGINT = 0;
DECLARE batch_cursor CURSOR STATIC READ_ONLY LOCAL FORWARD_ONLY FOR SELECT DISTINCT batch_identifier FROM #transaction_batch_data;
OPEN batch_cursor;
FETCH NEXT FROM batch_cursor INTO @batch_identifier;

WHILE(@@FETCH_STATUS=0)BEGIN

	SET @batch_sum=0;
	
	SELECT @transaction_count = COUNT(batch_identifier),@batch_sum =SUM(settle_amount_impact),@settle_tran_fee_sum =SUM(settle_tran_fee)  FROM #transaction_batch_data WHERE batch_identifier =@batch_identifier
		
	UPDATE #transaction_batch_data SET  total_settlement_impact =  CONVERT(FLOAT, @batch_sum), total_settle_tran_fee =  CONVERT(FLOAT,@settle_tran_fee_sum), transaction_count = @transaction_count  WHERE batch_identifier =@batch_identifier;

FETCH NEXT FROM batch_cursor INTO @batch_identifier;
END
CLOSE batch_cursor;
DEALLOCATE batch_cursor;

	DECLARE @batch_id VARCHAR(20);
	DECLARE @rrn VARCHAR(50);
	DECLARE @rrn_sttl_impact_total FLOAT;

	DECLARE retrieval_reference_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT DISTINCT retrieval_reference_nr, batch_identifier FROM #transaction_batch_data;

	OPEN retrieval_reference_cursor;

	FETCH NEXT FROM retrieval_reference_cursor INTO @rrn,@batch_id;

WHILE (@@FETCH_STATUS=0) 
BEGIN
	SELECT @rrn_sttl_impact_total = SUM(settle_amount_impact) FROM #transaction_batch_data WHERE retrieval_reference_nr = @rrn AND batch_identifier=@batch_id;
		
	IF(@rrn_sttl_impact_total=0)
	BEGIN
		DELETE FROM #transaction_batch_data WHERE  retrieval_reference_nr = @rrn AND batch_identifier=@batch_id;	
	END

FETCH NEXT FROM retrieval_reference_cursor INTO @rrn,@batch_id;
END
CLOSE retrieval_reference_cursor;
DEALLOCATE retrieval_reference_cursor;

SELECT * FROM #transaction_batch_data ORDER BY batch_identifier;

IF ( OBJECT_ID('tempdb.dbo.#filter_float_card_trans') IS NOT NULL)
		 BEGIN
		          DROP TABLE #filter_float_card_trans
		 END
IF ( OBJECT_ID('tempdb.dbo.#transaction_batch_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #transaction_batch_data
		 END

END