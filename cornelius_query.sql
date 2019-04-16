	Select 
			ptc.pan,
				ptc.terminal_id,
				ptc.card_acceptor_id_code,
				ptc.merchant_type,
				ptc.card_acceptor_name_loc,
				pt.message_type,
				pt.datetime_req,
				pt.tran_amount_req/100.0 tran_amount_req,
				pt.tran_amount_rsp/100.0 tran_amount_rsp,
				pt.system_trace_audit_nr,
				pt.retrieval_reference_nr,
				dbo.currencyAlphaCode(pt.tran_currency_code) transaction_currency_code,
				dbo.formatTranTypeStr(pt.tran_type, pt.extended_tran_type, pt.message_type) AS tran_type_description,
				dbo.formatRspCodeStr(pt.rsp_code_rsp) AS Response_Code_description,
				pt.auth_id_rsp

		
	from post_tran pt (nolock)
	 join post_tran_cust ptc (nolock)
	on pt.post_tran_cust_id = ptc.post_tran_cust_id
	where 	 pt.recon_business_date>='20141208' AND pt.recon_business_date<'20141215'
		and pt.rsp_code_rsp = '00'
	and pt.tran_postilion_originated = '0'
	and pt.tran_reversed = '0'
	and
	 pt.sink_node_name = 'ASPMEGFBNsnk'
 and  CHARINDEX('KMON',ptc.source_node_name) >0  -- IN ('ASPKIMONOsrc','ASPKIMON2src','ASPKIMON3src') ---
	and pt.message_type = '0100'
	---AND	pt.message_type in ('0100', '0200','0220')

	and LEFT(PTC.terminal_id,5) =  '2701A'

	AND 
	retrieval_reference_nr NOT IN (SELECT retrieval_reference_nr from post_tran pt (nolock)
	 join post_tran_cust ptc (nolock)
	on pt.post_tran_cust_id = ptc.post_tran_cust_id
	where 	 pt.recon_business_date>='20141208' AND pt.recon_business_date<'20141215'
		and pt.rsp_code_rsp = '00'
	and pt.tran_postilion_originated = '0'
	and pt.tran_reversed = '0'
	and
	 pt.sink_node_name = 'ASPMEGFBNsnk'
 and  CHARINDEX('KMON',ptc.source_node_name) >0  -- IN ('ASPKIMONOsrc','ASPKIMON2src','ASPKIMON3src') ---
AND	pt.message_type in ('0200','0220') 


	and LEFT(PTC.terminal_id,5) =  '2701A'
	)
