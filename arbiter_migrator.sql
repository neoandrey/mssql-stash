
DECLARE @pan VARCHAR(100);
DECLARE @pan_list VARCHAR(8000)

SET @pan_list =  '519911**1226,506102**5415,519911**4225,519911**5670,519911**5670,506102**1619,506102**1619,506102**1619,506102**4415,519911**5684,506102**5312,506102**5312,519911**1807';

DECLARE @masked_pan_table TABLE (serial_number INT IDENTITY(1,1), pan VARCHAR(100), left_pan_six CHAR(6), right_pan_four CHAR(4));
INSERT INTO @masked_pan_table (pan) SELECT part FROM usf_split_string(@pan_list, ',')

DECLARE pan_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT pan FROM  @masked_pan_table
OPEN pan_cursor
FETCH NEXT FROM pan_cursor INTO @pan

WHILE (@@FETCH_STATUS =0) BEGIN

 	INSERT INTO @masked_pan_table (left_pan_six, right_pan_four) VALUES (LEFT(@pan, 6), RIGHT(@pan,4))
	FETCH NEXT FROM pan_cursor INTO @pan
END

CLOSE pan_cursor;
DEALLOCATE pan_cursor


DECLARE @report_date_start datetime;
DECLARE @report_date_end datetime;
INSERT INTO [172.25.15.14].[arbiter].dbo.[tbl_postilion_office_transactions](

post_tran_id, 
post_tran_cust_id,
tran_nr,
masked_pan,
terminal_id,
cc.card_acceptor_id_code,
cc.card_acceptor_name_loc, 
issuer_code, 
tran_type_description, 
tran_amount_req, 
tran_fee_req, 
currency_alpha_code, 
system_trace_audit_nr,
datetime_req, 
retrieval_reference_nr, 
tran_tran_fee_req, 
acquirer_code, 
rsp_code_rsp, 
terminal_owner, 
sink_node_name, 
merchant_type, 
source_node_name, 
from_account_id,
online_system_id,
settle_currency_code,
tran_currency_code,
pos_terminal_type,
settle_amount_impact, 
settle_amount_rsp, 
auth_id_rsp,
tran_currency_alpha_code 

)
SELECT  
	pp.post_tran_id, pp.post_tran_cust_id,pp.tran_nr,cc.pan AS masked_pan, cc.terminal_id, cc.card_acceptor_id_code, cc.card_acceptor_name_loc, 
	dbo.GetIssuerCode(cc.totals_group) AS issuer_code, 
	dbo.formatTranTypeStr(pp.tran_type, pp.extended_tran_type, pp.message_type) AS tran_type_description, 
	dbo.formatAmount(pp.tran_amount_req, 
    pp.tran_currency_code) AS tran_amount_req, 
	dbo.formatAmount(pp.tran_tran_fee_req, pp.tran_currency_code) * - 1 AS tran_fee_req, 
    dbo.currencyAlphaCode(pp.settle_currency_code) AS currency_alpha_code, 
	pp.system_trace_audit_nr, pp.datetime_req, pp.retrieval_reference_nr, 
    pp.tran_tran_fee_req * - 1 AS tran_tran_fee_req, 
	pp.acquiring_inst_id_code AS acquirer_code, 
	pp.rsp_code_rsp, 
	cc.terminal_owner, 
	pp.sink_node_name, 
    cc.merchant_type, 
	cc.source_node_name, 
	pp.from_account_id,
	pp.online_system_id,
	settle_currency_code,
	tran_currency_code,
	pos_terminal_type,
	dbo.formatAmount(pp.settle_amount_impact,pp.settle_currency_code) AS settle_amount_impact, 
	dbo.formatAmount(pp.settle_amount_rsp,pp.settle_currency_code) AS settle_amount_rsp, 
	auth_id_rsp,
    dbo.currencyAlphaCode(pp.tran_currency_code) AS tran_currency_alpha_code 




FROM dbo.post_tran pp(NOLOCK) INNER JOIN
     dbo.post_tran_cust cc (NOLOCK) 
	ON pp.post_tran_cust_id = cc.post_tran_cust_id
WHERE

datetime_req>='20160309' AND datetime_req<='20160310'
AND
 LEFT(pan,6) IN (SELECT left_pan_six FROM @masked_pan_table) AND RIGHT(pan,4) IN (SELECT right_pan_four FROM @masked_pan_table) 
AND
system_trace_audit_nr 
IN
('004217','005534','006987','004128','004127','003898','003898','003899','001338','001559','001657','001658','001712')
AND 
retrieval_reference_nr 
IN
('000045506990','000338898930','000050226108','000050229878','000050229553','000562307548','000562307548','000562307969','000019407948','000050234292','000029946601','000029946956','000050229319')
and  (pp.tran_completed = 1) 
	AND (pp.tran_reversed = 0) 
	AND (pp.tran_type IN ( '01','00','09')) 
	AND (pp.message_type IN ('0200', '0220')) 
	AND (pp.tran_postilion_originated = 0) 