USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_resolve_autopay_floatcard_diff]    Script Date: 12/18/2014 11:26:39 ******/
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
--- the script was modified by Bolaji on 17-10-2014
-- script was modified to process the reconciliation of transactions with Switch transactions


IF ( OBJECT_ID('tempdb.dbo.#temp_pan_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #temp_tran_data
		 END
		 
IF ( OBJECT_ID('tempdb.dbo.#transaction_batch_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #transaction_batch_data
		 END
IF ( OBJECT_ID('tempdb.dbo.#transaction_batch_data_2') IS NOT NULL)
		 BEGIN
		          DROP TABLE #transaction_batch_data_2
		 END
IF ( OBJECT_ID('tempdb.dbo.#temp_tran_data_2') IS NOT NULL)
		 BEGIN
		          DROP TABLE #temp_tran_data_2
		 END
IF ( OBJECT_ID('tempdb.dbo.#temp_batch_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #temp_batch_data
		 END
IF ( OBJECT_ID('tempdb.dbo.#temp_tran_data_2') IS NOT NULL)
		 BEGIN
		          DROP TABLE #temp_tran_data_2
		 END
		 
IF (DATEDIFF(D,@StartDate,@EndDate )=0)BEGIN
    SET @EndDate =  DATEADD(D,1, DATEDIFF(D,0, @EndDate));
    END
 		 IF ( OBJECT_ID('tempdb.dbo.#temp_switch_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #temp_switch_data
		 END
    
DECLARE @terminal_id_list TABLE (terminal_id	VARCHAR(12));

INSERT INTO @terminal_id_list SELECT part FROM dbo.usf_split_string(@terminal_id, ',');
    
            SELECT	
			t.datetime_tran_local,
			t.datetime_req,
			c.terminal_id,
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description, 
			t.retrieval_reference_nr, 	
			t.system_trace_audit_nr,		
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END, t.settle_currency_code) AS settle_amount_impact,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee,					
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			t.from_account_id,
			dbo.rpt_fxn_account_type(t.from_account_type) AS from_account_type,
			t.to_account_id,
			dbo.rpt_fxn_account_type(t.to_account_type) AS to_account_type,
			c.post_tran_cust_id,
			t.sink_node_name,
			rsp_code_rsp,
			dbo.formatRspCodeStr(t.rsp_code_rsp) AS Response_Code_description,
			acquiring_inst_id_code,
			terminal_owner,
			payee
			
			INTO
			
			#temp_tran_data
						
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

--SELECT * FROM 	#temp_tran_data;


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

END as batch_identifier, retrieval_reference_nr,settle_amount_impact,settle_tran_fee,0 as transaction_count, 0 as total_settlement_impact,0 as total_settle_tran_fee INTO  #transaction_batch_data FROM #temp_tran_data 
					
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
	
	--PRINT CHAR(10)+'batch_identifier: '+CONVERT(VARCHAR(50),@batch_identifier)+'; total_settlement_impact: '+CONVERT(VARCHAR(50),@batch_sum)+' transaction_count: '+CONVERT(VARCHAR(50),@transaction_count)+'; settle_tran_fee: '+CONVERT(VARCHAR(50),@settle_tran_fee_sum);
	
	UPDATE #transaction_batch_data SET  total_settlement_impact =  CONVERT(FLOAT, @batch_sum), total_settle_tran_fee =  CONVERT(FLOAT,@settle_tran_fee_sum), transaction_count = @transaction_count  WHERE batch_identifier =@batch_identifier;

FETCH NEXT FROM batch_cursor INTO @batch_identifier;
END
CLOSE batch_cursor;
DEALLOCATE batch_cursor;

SELECT  batch_identifier, retrieval_reference_nr, settle_amount_impact,settle_tran_fee,transaction_count, total_settle_tran_fee,total_settlement_impact, (total_settle_tran_fee+total_settlement_impact) 'outstanding_amount' INTO #temp_batch_data FROM #transaction_batch_data WHERE (total_settlement_impact+total_settle_tran_fee) <> 0  ORDER BY batch_identifier

SELECT 
  cust.pan,
  cust.terminal_id,
  cust.card_acceptor_id_code,
  cust.merchant_type,
  cust.card_acceptor_name_loc,
  trans.message_type,
  trans.datetime_req,
  trans.system_trace_audit_nr,
  trans.retrieval_reference_nr,
  CONVERT(FLOAT, dbo.formatAmount(trans.tran_amount_req,tran_currency_code)) AS tran_amount_req,
  CONVERT(FLOAT, dbo.formatAmount(trans.tran_amount_rsp,tran_currency_code))AS tran_amount_rsp,
  dbo.currencyAlphaCode(trans.tran_currency_code) tran_currency_code,
  dbo.formatTranTypeStr(trans.tran_type, trans.extended_tran_type, trans.message_type)  tran_type_description,
  dbo.formatRspCodeStr(trans.rsp_code_rsp)  response_code_description,
  CONVERT(FLOAT, dbo.formatAmount(trans.settle_tran_fee_rsp, trans.settle_currency_code)) AS settle_tran_fee,
  CONVERT(FLOAT, dbo.formatAmount(trans.settle_amount_impact, trans.settle_currency_code)) AS settle_amount_impact
INTO
			
   #temp_tran_data_2

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

END as batch_identifier, retrieval_reference_nr,settle_amount_impact,settle_tran_fee,0 as transaction_count, 0 as total_settlement_impact,0 as total_settle_tran_fee INTO  #transaction_batch_data_2 FROM #temp_tran_data_2

SELECT batch_identifier, retrieval_reference_nr, settle_amount_impact,settle_tran_fee,transaction_count, total_settle_tran_fee,total_settlement_impact, (total_settle_tran_fee+total_settlement_impact) outstanding_amount INTO  #temp_batch_data_2 FROM #temp_batch_data WHERE retrieval_reference_nr NOT IN (SELECT retrieval_reference_nr FROM #transaction_batch_data_2 )  ORDER BY batch_identifier

DECLARE @retrieval_reference_nr VARCHAR(20);
DECLARE @rrn_sttl_impact_total INT;
DECLARE @excluded_rrns TABLE (batch_identifier VARCHAR(20));

DECLARE retrieval_reference_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT DISTINCT retrieval_reference_nr, batch_identifier FROM #temp_batch_data_2;

OPEN retrieval_reference_cursor;

FETCH NEXT FROM retrieval_reference_cursor INTO @retrieval_reference_nr,@batch_identifier;

WHILE (@@FETCH_STATUS=0) 
BEGIN
	SELECT @rrn_sttl_impact_total = SUM(settle_amount_impact) FROM #temp_batch_data_2 WHERE retrieval_reference_nr = @retrieval_reference_nr AND batch_identifier=@batch_identifier;
		
	IF(@rrn_sttl_impact_total=0)
	BEGIN
		DELETE FROM #temp_batch_data_2 WHERE  retrieval_reference_nr = @retrieval_reference_nr AND batch_identifier=@batch_identifier;
		
	END

FETCH NEXT FROM retrieval_reference_cursor INTO @retrieval_reference_nr,@batch_identifier;;
END
CLOSE retrieval_reference_cursor;
DEALLOCATE retrieval_reference_cursor;

SELECT * FROM #temp_batch_data_2 
--WHERE batch_identifier NOT IN (SELECT batch_identifier FROM @excluded_rrns);

IF(@@rowcount=0)BEGIN
  	 SELECT batch_identifier, retrieval_reference_nr, settle_amount_impact,settle_tran_fee,transaction_count, total_settle_tran_fee,total_settlement_impact, (total_settle_tran_fee+total_settlement_impact) outstanding_amount FROM #temp_batch_data WHERE retrieval_reference_nr NOT IN (SELECT retrieval_reference_nr FROM #transaction_batch_data_2 )  ORDER BY batch_identifier
	IF(@@rowcount=0)BEGIN
		 SELECT 'FloatCard Report and Report from Switch have the same contents. See Contents in table below: ';

		--SELECT  batch_identifier, retrieval_reference_nr, settle_amount_impact,settle_tran_fee,transaction_count, total_settle_tran_fee,total_settlement_impact, (total_settle_tran_fee+total_settlement_impact) outstanding_amount FROM #transaction_batch_data WHERE (total_settlement_impact+total_settle_tran_fee) <> 0  ORDER BY batch_identifier



Select 
        c.pan pan,
            c.terminal_id terminal_id,
            c.card_acceptor_id_code card_acceptor_id_code,
            c.merchant_type merchant_type,
            c.card_acceptor_name_loc card_acceptor_name_loc,
            pt.message_type message_type,
            pt.datetime_req datetime_req,
            pt.system_trace_audit_nr system_trace_audit_nr,
            pt.retrieval_reference_nr retrieval_reference_nr,
            pt.tran_amount_req/100 tran_amount_req,
            pt.tran_amount_rsp/100 tran_amount_rsp,
            dbo.currencyAlphaCode(pt.tran_currency_code) tran_currency_code,
            dbo.formatTranTypeStr(pt.tran_type, pt.extended_tran_type, pt.message_type) AS tran_type_description,
            dbo.formatRspCodeStr(pt.rsp_code_rsp) AS Response_Code_description,
            pt.auth_id_rsp AS auth_id_rsp

  INTO #temp_switch_data  
FROM post_tran pt (nolock)
JOIN post_tran_cust c (nolock)
ON pt.post_tran_cust_id = c.post_tran_cust_id
WHERE c.terminal_id IN (SELECT terminal_id FROM @terminal_id_list)
  AND  (
	               (LEFT(c.pan,6) = LEFT(@MaskedPAN,6)  AND RIGHT(c.pan,4) = RIGHT(@MaskedPAN,4))
	               OR 
	               	(LEFT(c.pan,6) = LEFT(@fullpan,6)  AND RIGHT(c.pan,4) = RIGHT(@fullpan,4))              
                )
and c.source_node_name IN ('WEBSWTsrc','WEBsrc','WEB1src','WEB2src','WEB3src') 
AND (pt.datetime_req >= @StartDate and pt.datetime_req < @EndDate)
and pt.message_type ='0200'
--and pt.rsp_code_rsp = '00'
and pt.tran_postilion_originated = '0'
and pt.tran_reversed = '0'
order by datetime_req

SELECT  batch_identifier, retrieval_reference_nr, settle_amount_impact,settle_tran_fee,transaction_count, total_settle_tran_fee,total_settlement_impact, (total_settle_tran_fee+total_settlement_impact) outstanding_amount FROM #transaction_batch_data WHERE (total_settlement_impact+total_settle_tran_fee) <> 0 AND retrieval_reference_nr NOT IN (SELECT retrieval_reference_nr FROM #temp_switch_data)  ORDER BY batch_identifier

	END

END


IF ( OBJECT_ID('tempdb.dbo.#temp_batch_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #temp_batch_data
		 END
IF ( OBJECT_ID('tempdb.dbo.#transaction_batch_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #transaction_batch_data
		 END
IF ( OBJECT_ID('tempdb.dbo.#transaction_batch_data_2') IS NOT NULL)
		 BEGIN
		          DROP TABLE #transaction_batch_data_2
		 END
IF ( OBJECT_ID('tempdb.dbo.#temp_tran_data_2') IS NOT NULL)
		 BEGIN
		          DROP TABLE #temp_tran_data_2
		 END

IF ( OBJECT_ID('tempdb.dbo.#temp_tran_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #temp_tran_data
		 END

IF ( OBJECT_ID('tempdb.dbo.#temp_tran_data_2') IS NOT NULL)
		 BEGIN
		          DROP TABLE #temp_tran_data_2
		 END
		 
		 IF ( OBJECT_ID('tempdb.dbo.#temp_switch_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #temp_switch_data
		 END
END

