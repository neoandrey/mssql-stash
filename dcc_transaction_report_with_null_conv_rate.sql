USE [postilion_office]
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT trans.datetime_req, cust.pan, trans2.settle_amount_req,
		 trans2.tran_amount_req, trans.card_currency_code AS base_currency_code, trans.tran_currency_code, trans.message_type,
		cust.terminal_id, cust.card_acceptor_id_code,trans.tran_type,trans.pos_entry_mode,SUBSTRING( trans.structured_data_req, (CHARINDEX('CONV_RATE_SETTLE18', trans.structured_data_req)+18), 8) AS conv_rate,
		cust.post_tran_cust_id
	FROM post_tran trans (NOLOCK, index(ix_post_tran_9))
	 JOIN (SELECT [DATE] recon_business_date FROM dbo.get_dates_in_range('20160701','20160802') )r
	 ON
	 r.recon_business_date = trans.recon_business_date
	JOIN post_tran_cust cust (NOLOCK) ON (trans.post_tran_cust_id=cust.post_tran_cust_id and
	LEFT(pan, 8) !='52769901'
AND
LEFT(pan, 9) !='52769901'
AND
LEFT(pan,6) NOT IN
 ('536613','519908','531667','532968','548458','548712','529751','537010','531992','559441','521963','524275','521963','527699','524282 ','519830 ','527699','521973','539923','519878','533853','541569','539983','533856','552279','540761','532732','522340','520053','521623','557693','526897','531213','557694','555940','546557','549531','519909','519908','523740','537610','523776','518304','516195','517058','519899','519905','519904','528650','559424','524687','524275','559432','526116','526142','526162','526131','527074','512092','541409','536024','518539','517214','517294','517294','524289','519911','517868','519885','519863  ','536399','521988','532155','512336','515803','530519','531525','533301','539941','547160','549970','540884','559443','542231','529720','521982','514585','524271','524275','521101'
 )
 

	) AND
	(trans.message_type in('0200','0220') AND
		tran_postilion_originated = '1' 
		AND tran_reversed  = 0
		AND
		trans.rsp_code_rsp = '00' AND
		trans.sink_node_name = 'MEGGTBMDSsnk' AND
		cust.pos_terminal_type = '02' AND
		   CHARINDEX('conv_rate_settle', dbo.stripXML(trans.structured_data_req))>0
		)
		JOIN  post_tran trans2 (NOLOCK,INDEX(ix_post_tran_2))ON (trans.post_tran_cust_id=trans2.post_tran_cust_id and trans2.tran_postilion_originated =0)
OPTION (RECOMPILE)