USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[psp_get_all_dcc_transaction_by_date]    Script Date: 02/25/2015 11:45:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[psp_get_all_dcc_transaction_by_date]
(
    @startDate DateTime,
	@stopDate DateTime,
	@nodeName VARCHAR(100)
)

AS
BEGIN
    SELECT trans.datetime_req, cust.pan,settle_amount_req,
		tran_amount_req, card_currency_code AS base_currency_code, tran_currency_code, message_type,
		cust.terminal_id, cust.card_acceptor_id_code,trans.tran_type,trans.pos_entry_mode,trans.ext_009_conv_rate_settle AS conv_rate
	FROM post_tran trans (NOLOCK)
	JOIN post_tran_cust cust (NOLOCK) ON (trans.post_tran_cust_id=cust.post_tran_cust_id)
	WHERE trans.message_type in('0200','0100','0220') AND
		tran_postilion_originated = '1' AND
		(trans.datetime_req BETWEEN @startDate AND @stopDate) AND
		trans.rsp_code_rsp = '00' AND
		trans.sink_node_name = @nodeName AND
		cust.pos_terminal_type = '01' AND
		card_amount_req is not null AND card_currency_code is not null
		AND ext_009_conv_rate_settle is not null
	ORDER BY datetime_req DESC
END






USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[psp_get_all_atm_dcc_transaction]    Script Date: 02/25/2015 11:48:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[psp_get_all_atm_dcc_transaction]
(
    @startDate DateTime,
	@stopDate DateTime,
	@nodeName VARCHAR(100)
)

AS
BEGIN
    SELECT trans.datetime_req, cust.pan,settle_amount_req,
		tran_amount_req, card_currency_code AS base_currency_code, tran_currency_code, message_type,
		cust.terminal_id, cust.card_acceptor_id_code,trans.tran_type,trans.pos_entry_mode,trans.ext_009_conv_rate_settle AS conv_rate,
		cust.post_tran_cust_id
	FROM post_tran trans (NOLOCK)
	JOIN post_tran_cust cust (NOLOCK) ON (trans.post_tran_cust_id=cust.post_tran_cust_id)
	WHERE trans.message_type in('0200','0100','0220') AND
		tran_postilion_originated = '1' AND
		(trans.datetime_req BETWEEN @startDate AND @stopDate) AND
		trans.rsp_code_rsp = '00' AND
		trans.sink_node_name = @nodeName AND
		cust.pos_terminal_type = '02' AND
		card_amount_req is not null AND card_currency_code is not null
		AND ext_009_conv_rate_settle is not null
END

GO



