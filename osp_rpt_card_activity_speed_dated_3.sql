USE [postilion_office]
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER       PROCEDURE [dbo].[osp_rpt_resolve_autopay_floatcard_diff]
	@MaskedPAN		VARCHAR(19),
	@fullpan		VARCHAR(19),
	@StartDate		varchar(10),
	@EndDate		varchar (10)


--- the script was modified by eseosa on 26-10-2011
-- script was modified to include requested date and time and also response code description
AS
BEGIN

IF ( OBJECT_ID('tempdb.dbo.#temp_pan_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #temp_tran_data
		 END
		 
IF ( OBJECT_ID('tempdb.dbo.#transaction_batch_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #transaction_batch_data
		 END		 
		 
IF (DATEDIFF(D,@StartDate,@EndDate )=0)BEGIN
    SET @EndDate =  DATEADD(D,1, DATEDIFF(D,0, @EndDate));
    END
    
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
	ORDER BY 
			t.datetime_req desc



SELECT * FROM 	#temp_tran_data;


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
DECLARE @transaction_count INT;
DECLARE batch_cursor CURSOR STATIC READ_ONLY LOCAL FORWARD_ONLY FOR SELECT DISTINCT batch_identifier FROM #transaction_batch_data;
OPEN batch_cursor;
FETCH NEXT FROM batch_cursor INTO @batch_identifier;

WHILE(@@FETCH_STATUS=0)BEGIN

	SET @batch_sum=0;
	
	SELECT @transaction_count = COUNT(batch_identifier),@batch_sum =SUM(settle_amount_impact),@settle_tran_fee_sum =SUM(settle_tran_fee)  FROM #transaction_batch_data WHERE batch_identifier =@batch_identifier
	
	--SELECT @batch_sum =SUM(settle_amount_impact) FROM #transaction_batch_data WHERE batch_identifier =@batch_identifier
	
	--SELECT @settle_tran_fee_sum =SUM(settle_tran_fee) FROM #transaction_batch_data WHERE batch_identifier =@batch_identifier
	
	PRINT CHAR(10)+'batch_identifier: '+CONVERT(VARCHAR(50),@batch_identifier)+'; total_settlement_impact: '+CONVERT(VARCHAR(50),@batch_sum)+' transaction_count: '+CONVERT(VARCHAR(50),@transaction_count)+'; settle_tran_fee: '+CONVERT(VARCHAR(50),@settle_tran_fee_sum);
	
	UPDATE #transaction_batch_data SET  total_settlement_impact = @batch_sum, total_settle_tran_fee = @settle_tran_fee_sum, transaction_count = @transaction_count  WHERE batch_identifier =@batch_identifier;

FETCH NEXT FROM batch_cursor INTO @batch_identifier;
END
CLOSE batch_cursor;
DEALLOCATE batch_cursor;

SELECT  batch_identifier, retrieval_reference_nr, settle_amount_impact,settle_tran_fee,transaction_count, total_settle_tran_fee,total_settlement_impact, (total_settle_tran_fee+total_settlement_impact) outstanding_amount FROM #transaction_batch_data WHERE (total_settlement_impact+total_settle_tran_fee) <> 0  ORDER BY batch_identifier
 -- SELECT  datetime_tran_local,datetime_req,terminal_id,card_acceptor_name_loc,tran_type_description,tran_data.retrieval_reference_nr,system_trace_audit_nr,tran_data.settle_amount_impact,settle_tran_fee,currency_alpha_code,from_account_id,from_account_type,batch_identifier,total_settlement_impact FROM #temp_tran_data tran_data JOIN  #transaction_batch_data batch_data ON tran_data.retrieval_reference_nr=batch_data.retrieval_reference_nr where total_settlement_impact <> 0
 

IF ( OBJECT_ID('tempdb.dbo.#transaction_batch_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #transaction_batch_data
		 END

IF ( OBJECT_ID('tempdb.dbo.#amount_total') IS NOT NULL)
		 BEGIN
		          DROP TABLE #amount_total
		 END



IF ( OBJECT_ID('tempdb.dbo.#temp_pan_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #temp_tran_data
		 END


END



















