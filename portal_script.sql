USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_geticcdata]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_geticcdata]
	@post_tran_id	BIGINT
AS
BEGIN
	SELECT
		icc_data_req,
		icc_data_rsp
	FROM
		post_tran WITH (NOLOCK)
	WHERE
		post_tran_id = @post_tran_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_getstructdata]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_getstructdata]
	@post_tran_id	BIGINT
AS
BEGIN
	SELECT
		structured_data_req,
		structured_data_rsp
	FROM
  		post_tran pt WITH (NOLOCK)
	WHERE
		pt.post_tran_id = @post_tran_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_getretentiondata]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_getretentiondata]
	@post_tran_id	BIGINT
AS
BEGIN
	SELECT
		retention_data
	FROM
		post_tran WITH (NOLOCK)
	WHERE
		post_tran_id = @post_tran_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_cs_tranqry_getleg]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_cs_tranqry_getleg]
	@post_tran_id	BIGINT
AS
BEGIN
	-- for compatibility with Microsoft OLEDB
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
 
	SELECT
		CAST(post_tran.post_tran_id AS BIGINT) AS post_tran_id,
		CAST(post_tran.post_tran_cust_id AS BIGINT) AS post_tran_cust_id,
		post_tran.settle_entity_id,
		post_tran.sponsor_bank,
		post_tran.batch_nr,
		post_tran.sink_node_name,
		post_tran.tran_postilion_originated,
		post_tran.tran_completed,
		post_tran.message_type,
		post_tran.tran_type,
		CAST(post_tran.tran_nr AS BIGINT) AS tran_nr,
		post_tran.system_trace_audit_nr,
		post_tran.rsp_code_req,
		post_tran.rsp_code_rsp,
		post_tran.auth_id_rsp,
		post_tran.auth_type,
		post_tran.auth_reason,
		CAST(post_tran.retention_data AS VARCHAR) AS retention_data,
		post_tran.message_reason_code,
		post_tran.retrieval_reference_nr,
		post_tran.datetime_tran_gmt,
		post_tran.datetime_tran_local,
		post_tran.datetime_req,
		post_tran.datetime_rsp,
		post_tran.from_account_type,
		post_tran.from_account_id,
		post_tran.to_account_type,
		post_tran.to_account_id,
		post_tran.tran_amount_req,
		post_tran.tran_amount_rsp,
		post_tran.tran_cash_req,
		post_tran.tran_cash_rsp,
		post_tran.tran_currency_code,
		post_tran.tran_tran_fee_req,
		post_tran.tran_tran_fee_rsp,
		post_tran.tran_tran_fee_currency_code,
		post_tran.tran_proc_fee_req,
		post_tran.tran_proc_fee_rsp,
		post_tran.tran_proc_fee_currency_code,
		post_tran.settle_amount_req,
		post_tran.settle_amount_rsp,
		post_tran.settle_cash_req,
		post_tran.settle_cash_rsp,
		post_tran.settle_tran_fee_req,
		post_tran.settle_tran_fee_rsp,
		post_tran.settle_proc_fee_req,
		post_tran.settle_proc_fee_rsp,
		post_tran.settle_currency_code,
		post_tran.icc_data_req,
		post_tran.icc_data_rsp,
		post_tran.pos_entry_mode,
		post_tran.pos_condition_code,
		post_tran.additional_rsp_data,
		post_tran.structured_data_req,
		post_tran.structured_data_rsp,
		post_tran.prev_tran_approved,
		post_tran.tran_reversed,
		post_tran.recon_business_date,
		post_tran.realtime_business_date,
		post_tran.settle_amount_impact,
		post_tran.abort_rsp_code,
		post_tran.acquiring_inst_id_code,
		post_tran.ucaf_data,
		post_tran.extended_tran_type,
		post_tran.from_account_type_qualifier,
		post_tran.to_account_type_qualifier,
		post_tran.issuer_network_id,
		post_tran.acquirer_network_id,
		post_tran.bank_details,
		post_tran.payee,
		post_tran.card_verification_result,
		ISNULL(post_tran.online_system_id, 1) AS online_system_id,
		post_tran.receiving_inst_id_code,
		post_tran.routing_type,
		post_tran_extract.primary_file_reference,
		post_tran_extract.extr_extended_data
	FROM
		post_tran WITH (NOLOCK)
	LEFT OUTER JOIN
		post_tran_extract WITH (NOLOCK)
	ON
		post_tran_extract.post_tran_id = @post_tran_id
	WHERE
		post_tran.post_tran_id = @post_tran_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_open_tran_nr]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_open_tran_nr]
	@participant_id INT,
	@tran_nr BIGINT,
	@online_system_id INT
AS
BEGIN
	-- For compatibility with Microsoft OLEDB
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
 
		SELECT
			post_tran.tran_nr,
			post_tran.post_tran_id,
			post_tran.datetime_req,
			post_tran.datetime_tran_local,
			post_tran.message_type,
			post_tran.message_reason_code,
			post_tran.tran_type,
			post_tran.extended_tran_type,
			post_tran.tran_amount_req,
			post_tran.tran_currency_code,
			post_tran.rsp_code_rsp,
			post_tran.sink_node_name,
			post_tran_cust.pan,
			post_tran_cust.pan_encrypted,
			post_tran_cust.card_acceptor_id_code,
			post_tran_cust.terminal_id,
			post_tran.from_account_id,
			post_tran.to_account_id,
			post_tran.structured_data_req,
			post_tran.system_trace_audit_nr,
			post_tran_cust.source_node_name,
			post_tran_cust.post_tran_cust_id,
			post_tran.online_system_id,
			post_tran.tran_postilion_originated
	FROM
		post_tran WITH (NOLOCK, INDEX = ix_post_tran_8)
	INNER LOOP JOIN
		post_tran_cust WITH (NOLOCK, INDEX = pk_post_tran_cust)
	ON
		post_tran_cust.post_tran_cust_id = post_tran.post_tran_cust_id
	WHERE
		tran_nr = @tran_nr
		AND (tran_postilion_originated = 0 OR (tran_postilion_originated = 1 AND message_type IN ('0522', '0523', '0322', '0323')))
		AND (@online_system_id IS NULL OR online_system_id = @online_system_id)
		AND (@participant_id IS NULL OR (participant_id = @participant_id OR opp_participant_id = @participant_id))
	ORDER BY
		post_tran.datetime_req DESC
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_open_ptc_id]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_open_ptc_id]
	@participant_id INT,
	@post_tran_cust_id BIGINT
AS
BEGIN
	-- For compatibility with Microsoft OLEDB
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
 
	SELECT
		post_tran.tran_nr,
		post_tran.post_tran_id,
		post_tran.datetime_req,
		post_tran.datetime_tran_local,
		post_tran.message_type,
		post_tran.message_reason_code,
		post_tran.tran_type,
		post_tran.extended_tran_type,
		post_tran.tran_amount_req,
		post_tran.tran_currency_code,
		post_tran.rsp_code_rsp,
		post_tran.sink_node_name,
		post_tran_cust.pan,
		post_tran_cust.pan_encrypted,
		post_tran_cust.card_acceptor_id_code,
		post_tran_cust.terminal_id,
		post_tran.from_account_id,
		post_tran.to_account_id,
		post_tran.structured_data_req,
		post_tran.system_trace_audit_nr,
		post_tran_cust.source_node_name,
		post_tran_cust.post_tran_cust_id,
		post_tran.online_system_id,
		post_tran.tran_postilion_originated
	FROM
		post_tran WITH (NOLOCK, INDEX = ix_post_tran_2)
	INNER JOIN
		post_tran_cust WITH (NOLOCK, INDEX = pk_post_tran_cust)
	ON
		post_tran_cust.post_tran_cust_id = @post_tran_cust_id
	WHERE
		post_tran.post_tran_cust_id = @post_tran_cust_id
		AND (tran_postilion_originated = 0 OR (tran_postilion_originated = 1 AND message_type IN ('0522', '0523', '0322', '0323')))
		AND (@participant_id IS NULL OR (participant_id = @participant_id OR opp_participant_id = @participant_id))
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_open_last_x_transactions]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_open_last_x_transactions]
	@participant_id INT,
	@source_node_name VARCHAR(30),
	@sink_node_name VARCHAR(30),
	@card_acceptor_id_code CHAR(15),
	@terminal_id CHAR(8),
	@online_system_id INT,
	@max_nr_rows INT = 1000
AS
BEGIN
	-- For compatibility with Microsoft OLEDB
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
 
	IF (@terminal_id IS NOT NULL)
	BEGIN
		SELECT TOP (@max_nr_rows)
			post_tran.tran_nr,
			post_tran.post_tran_id,
			post_tran.datetime_req,
			post_tran.datetime_tran_local,
			post_tran.message_type,
			post_tran.message_reason_code,
			post_tran.tran_type,
			post_tran.extended_tran_type,
			post_tran.tran_amount_req,
			post_tran.tran_currency_code,
			post_tran.rsp_code_rsp,
			post_tran.sink_node_name,
			post_tran_cust.pan,
			post_tran_cust.pan_encrypted,
			post_tran_cust.card_acceptor_id_code,
			post_tran_cust.terminal_id,
			post_tran.from_account_id,
			post_tran.to_account_id,
			post_tran.structured_data_req,
			post_tran.system_trace_audit_nr,
			post_tran_cust.source_node_name,
			post_tran_cust.post_tran_cust_id,
            post_tran.online_system_id,
            post_tran.tran_postilion_originated
		FROM
			(
				SELECT
					post_tran_cust_id
				FROM
					post_tran_cust WITH (NOLOCK, INDEX = ix_post_tran_cust_2)
		WHERE
					terminal_id = @terminal_id
			) X
		INNER LOOP JOIN
			post_tran WITH (NOLOCK, INDEX = ix_post_tran_2)
		ON
			post_tran.post_tran_cust_id = X.post_tran_cust_id
			AND (tran_postilion_originated = 0 OR (tran_postilion_originated = 1 AND message_type IN ('0522', '0523', '0322', '0323')))
			AND (@sink_node_name IS NULL OR sink_node_name = @sink_node_name)
			AND (@online_system_id IS NULL OR online_system_id = @online_system_id)
			AND (@participant_id IS NULL OR (participant_id = @participant_id OR opp_participant_id = @participant_id))
		INNER LOOP JOIN
			post_tran_cust WITH (NOLOCK, INDEX = pk_post_tran_cust)
		ON
			post_tran_cust.post_tran_cust_id = X.post_tran_cust_id
			AND (@source_node_name IS NULL OR source_node_name = @source_node_name)
			AND (@card_acceptor_id_code IS NULL OR card_acceptor_id_code = @card_acceptor_id_code)
			--AND (@terminal_id IS NULL OR terminal_id = @terminal_id)
		ORDER BY
			post_tran.datetime_req DESC
	END
	ELSE IF (@card_acceptor_id_code IS NOT NULL)
	BEGIN
		DECLARE @card_acceptor_id_code_cs INT
		SET @card_acceptor_id_code_cs = dbo.ofn_checksum(@card_acceptor_id_code)
 
		SELECT TOP (@max_nr_rows)
			post_tran.tran_nr,
			post_tran.post_tran_id,
			post_tran.datetime_req,
			post_tran.datetime_tran_local,
			post_tran.message_type,
			post_tran.message_reason_code,
			post_tran.tran_type,
			post_tran.extended_tran_type,
			post_tran.tran_amount_req,
			post_tran.tran_currency_code,
			post_tran.rsp_code_rsp,
			post_tran.sink_node_name,
			post_tran_cust.pan,
			post_tran_cust.pan_encrypted,
			post_tran_cust.card_acceptor_id_code,
			post_tran_cust.terminal_id,
			post_tran.from_account_id,
			post_tran.to_account_id,
			post_tran.structured_data_req,
			post_tran.system_trace_audit_nr,
			post_tran_cust.source_node_name,
			post_tran_cust.post_tran_cust_id,
			post_tran.online_system_id,
			post_tran.tran_postilion_originated
		FROM
			(
				SELECT
					post_tran_cust_id
				FROM
					post_tran_cust WITH (NOLOCK, INDEX = ix_post_tran_cust_5)
				WHERE
					card_acceptor_id_code_cs = @card_acceptor_id_code_cs
			) X
		INNER LOOP JOIN
			post_tran WITH (NOLOCK, INDEX = ix_post_tran_2)
		ON
			post_tran.post_tran_cust_id = X.post_tran_cust_id
			AND (tran_postilion_originated = 0 OR (tran_postilion_originated = 1 AND message_type IN ('0522', '0523', '0322', '0323')))
			AND (@sink_node_name IS NULL OR sink_node_name = @sink_node_name)
			AND (@online_system_id IS NULL OR online_system_id = @online_system_id)
			AND (@participant_id IS NULL OR (participant_id = @participant_id OR opp_participant_id = @participant_id))
		INNER LOOP JOIN
			post_tran_cust WITH (NOLOCK, INDEX = pk_post_tran_cust)
		ON
			post_tran_cust.post_tran_cust_id = X.post_tran_cust_id
			AND (@source_node_name IS NULL OR source_node_name = @source_node_name)
			AND (card_acceptor_id_code = @card_acceptor_id_code)
			AND (@terminal_id IS NULL OR terminal_id = @terminal_id)
		ORDER BY
			post_tran.datetime_req DESC
	END
	ELSE
	BEGIN
		SELECT TOP (@max_nr_rows)
			post_tran.tran_nr,
			post_tran.post_tran_id,
			post_tran.datetime_req,
			post_tran.datetime_tran_local,
			post_tran.message_type,
			post_tran.message_reason_code,
			post_tran.tran_type,
			post_tran.extended_tran_type,
			post_tran.tran_amount_req,
			post_tran.tran_currency_code,
			post_tran.rsp_code_rsp,
			post_tran.sink_node_name,
			post_tran_cust.pan,
			post_tran_cust.pan_encrypted,
			post_tran_cust.card_acceptor_id_code,
			post_tran_cust.terminal_id,
			post_tran.from_account_id,
			post_tran.to_account_id,
			post_tran.structured_data_req,
			post_tran.system_trace_audit_nr,
			post_tran_cust.source_node_name,
			post_tran_cust.post_tran_cust_id,
			post_tran.online_system_id,
			post_tran.tran_postilion_originated
		FROM
			post_tran WITH (NOLOCK, INDEX = ix_post_tran_7)
		INNER LOOP JOIN
			post_tran_cust WITH (NOLOCK, INDEX = pk_post_tran_cust)
		ON
			post_tran_cust.post_tran_cust_id = post_tran.post_tran_cust_id
			AND (@source_node_name IS NULL OR source_node_name = @source_node_name)
			AND (@card_acceptor_id_code IS NULL OR card_acceptor_id_code = @card_acceptor_id_code)
			AND (@terminal_id IS NULL OR terminal_id = @terminal_id)
		WHERE
			(tran_postilion_originated = 0 OR (tran_postilion_originated = 1 AND message_type IN ('0522', '0523', '0322', '0323')))
			AND (@sink_node_name IS NULL OR sink_node_name = @sink_node_name)
			AND (@online_system_id IS NULL OR online_system_id = @online_system_id)
			AND (@participant_id IS NULL OR (participant_id = @participant_id OR opp_participant_id = @participant_id))
		ORDER BY
			post_tran.datetime_req DESC
	END
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_open_first_x_transactions]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_open_first_x_transactions]
	@participant_id INT,
	@from_datetime_req DATETIME,
	@to_datetime_req DATETIME,
	@source_node_name VARCHAR(30),
	@sink_node_name VARCHAR(30),
	@card_acceptor_id_code CHAR(15),
	@terminal_id CHAR(8),
	@online_system_id INT,
	@max_nr_rows INT = 1000
AS
BEGIN
	-- For compatibility with Microsoft OLEDB
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
 
	IF (@terminal_id IS NOT NULL)
	BEGIN
		SELECT TOP (@max_nr_rows)
			post_tran.tran_nr,
			post_tran.post_tran_id,
			post_tran.datetime_req,
			post_tran.datetime_tran_local,
			post_tran.message_type,
			post_tran.message_reason_code,
			post_tran.tran_type,
			post_tran.extended_tran_type,
			post_tran.tran_amount_req,
			post_tran.tran_currency_code,
			post_tran.rsp_code_rsp,
			post_tran.sink_node_name,
			post_tran_cust.pan,
			post_tran_cust.pan_encrypted,
			post_tran_cust.card_acceptor_id_code,
			post_tran_cust.terminal_id,
			post_tran.from_account_id,
			post_tran.to_account_id,
			post_tran.structured_data_req,
			post_tran.system_trace_audit_nr,
			post_tran_cust.source_node_name,
			post_tran_cust.post_tran_cust_id,
			post_tran.online_system_id,
			post_tran.tran_postilion_originated
		FROM
			(
				SELECT
					post_tran_cust_id
				FROM
					post_tran_cust WITH (NOLOCK, INDEX = ix_post_tran_cust_2)
		WHERE
					terminal_id = @terminal_id
			) X
		INNER LOOP JOIN
			post_tran WITH (NOLOCK, INDEX = ix_post_tran_2)
		ON
			post_tran.post_tran_cust_id = X.post_tran_cust_id
			AND datetime_req BETWEEN @from_datetime_req AND @to_datetime_req
			AND (tran_postilion_originated = 0 OR (tran_postilion_originated = 1 AND message_type IN ('0522', '0523', '0322', '0323')))
			AND (@sink_node_name IS NULL OR sink_node_name = @sink_node_name)
			AND (@online_system_id IS NULL OR online_system_id = @online_system_id)
			AND (@participant_id IS NULL OR (participant_id = @participant_id OR opp_participant_id = @participant_id))
		INNER LOOP JOIN
			post_tran_cust WITH (NOLOCK, INDEX = pk_post_tran_cust)
		ON
			post_tran_cust.post_tran_cust_id = X.post_tran_cust_id
			AND (@source_node_name IS NULL OR source_node_name = @source_node_name)
			AND (@card_acceptor_id_code IS NULL OR card_acceptor_id_code = @card_acceptor_id_code)
			--AND (@terminal_id IS NULL OR terminal_id = @terminal_id)
		ORDER BY
			post_tran.datetime_req ASC
	END
	ELSE IF (@card_acceptor_id_code IS NOT NULL)
	BEGIN
		DECLARE @card_acceptor_id_code_cs INT
		SET @card_acceptor_id_code_cs = dbo.ofn_checksum(@card_acceptor_id_code)
 
		SELECT TOP (@max_nr_rows)
			post_tran.tran_nr,
			post_tran.post_tran_id,
			post_tran.datetime_req,
			post_tran.datetime_tran_local,
			post_tran.message_type,
			post_tran.message_reason_code,
			post_tran.tran_type,
			post_tran.extended_tran_type,
			post_tran.tran_amount_req,
			post_tran.tran_currency_code,
			post_tran.rsp_code_rsp,
			post_tran.sink_node_name,
			post_tran_cust.pan,
			post_tran_cust.pan_encrypted,
			post_tran_cust.card_acceptor_id_code,
			post_tran_cust.terminal_id,
			post_tran.from_account_id,
			post_tran.to_account_id,
			post_tran.structured_data_req,
			post_tran.system_trace_audit_nr,
			post_tran_cust.source_node_name,
			post_tran_cust.post_tran_cust_id,
			post_tran.online_system_id,
			post_tran.tran_postilion_originated
		FROM
			(
				SELECT
					post_tran_cust_id
				FROM
					post_tran_cust WITH (NOLOCK, INDEX = ix_post_tran_cust_5)
				WHERE
					card_acceptor_id_code_cs = @card_acceptor_id_code_cs
			) X
		INNER LOOP JOIN
			post_tran WITH (NOLOCK, INDEX = ix_post_tran_2)
		ON
			post_tran.post_tran_cust_id = X.post_tran_cust_id
			AND datetime_req BETWEEN @from_datetime_req AND @to_datetime_req
			AND (tran_postilion_originated = 0 OR (tran_postilion_originated = 1 AND message_type IN ('0522', '0523', '0322', '0323')))
			AND (@sink_node_name IS NULL OR sink_node_name = @sink_node_name)
			AND (@online_system_id IS NULL OR online_system_id = @online_system_id)
			AND (@participant_id IS NULL OR (participant_id = @participant_id OR opp_participant_id = @participant_id))
		INNER LOOP JOIN
			post_tran_cust WITH (NOLOCK, INDEX = pk_post_tran_cust)
		ON
			post_tran_cust.post_tran_cust_id = X.post_tran_cust_id
			AND (@source_node_name IS NULL OR source_node_name = @source_node_name)
			AND (card_acceptor_id_code = @card_acceptor_id_code)
			AND (@terminal_id IS NULL OR terminal_id = @terminal_id)
		ORDER BY
			post_tran.datetime_req ASC
	END
	ELSE
	BEGIN
		SELECT TOP (@max_nr_rows)
			post_tran.tran_nr,
			post_tran.post_tran_id,
			post_tran.datetime_req,
			post_tran.datetime_tran_local,
			post_tran.message_type,
			post_tran.message_reason_code,
			post_tran.tran_type,
			post_tran.extended_tran_type,
			post_tran.tran_amount_req,
			post_tran.tran_currency_code,
			post_tran.rsp_code_rsp,
			post_tran.sink_node_name,
			post_tran_cust.pan,
			post_tran_cust.pan_encrypted,
			post_tran_cust.card_acceptor_id_code,
			post_tran_cust.terminal_id,
			post_tran.from_account_id,
			post_tran.to_account_id,
			post_tran.structured_data_req,
			post_tran.system_trace_audit_nr,
			post_tran_cust.source_node_name,
			post_tran_cust.post_tran_cust_id,
			post_tran.online_system_id,
			post_tran.tran_postilion_originated
		FROM
			post_tran WITH (NOLOCK, INDEX = ix_post_tran_7)
		INNER LOOP JOIN
			post_tran_cust WITH (NOLOCK, INDEX = pk_post_tran_cust)
		ON
			post_tran_cust.post_tran_cust_id = post_tran.post_tran_cust_id
			AND (@source_node_name IS NULL OR source_node_name = @source_node_name)
			AND (@card_acceptor_id_code IS NULL OR card_acceptor_id_code = @card_acceptor_id_code)
			AND (@terminal_id IS NULL OR terminal_id = @terminal_id)
		WHERE
			datetime_req BETWEEN @from_datetime_req AND @to_datetime_req
			AND (tran_postilion_originated = 0 OR (tran_postilion_originated = 1 AND message_type IN ('0522', '0523', '0322', '0323')))
			AND (@sink_node_name IS NULL OR sink_node_name = @sink_node_name)
			AND (@online_system_id IS NULL OR online_system_id = @online_system_id)
			AND (@participant_id IS NULL OR (participant_id = @participant_id OR opp_participant_id = @participant_id))
		ORDER BY
			post_tran.datetime_req ASC
	END
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_getchaininfo]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_getchaininfo]
	@post_tran_cust_id	BIGINT
AS
BEGIN
	SELECT
		CAST(post_tran_id AS BIGINT) AS post_tran_id,
		CAST(pt.tran_nr AS BIGINT) AS realtime_post_tran_id,
		message_type,
		tran_type,
		tran_completed,
		tran_postilion_originated,
		message_reason_code,
		datetime_req,
		datetime_rsp,
		source_node_name,
		sink_node_name
	FROM
  		post_tran pt WITH (NOLOCK)
   INNER JOIN
		post_tran_cust ptc WITH (NOLOCK)
   ON
		ptc.post_tran_cust_id = @post_tran_cust_id
	WHERE
		pt.post_tran_cust_id = @post_tran_cust_id
	ORDER BY
		pt.datetime_req
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_crdhldr_open_pan_wldcrd]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_crdhldr_open_pan_wldcrd]
	@participant_id INT,
	@bin_term VARCHAR(30),
	@pan_bottom INT,
	@pan_top INT,
	@from_datetime_tran_local DATETIME,
	@to_datetime_tran_local DATETIME,
	@source_node_name VARCHAR(30),
	@card_acceptor_id_code CHAR(15),
	@terminal_id CHAR(8),
	@online_system_id INT,
	@system_trace_audit_nr CHAR(6),
	@max_nr_rows INT = 1000
AS
BEGIN
	-- For compatibility with Microsoft OLEDB
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
 
	SET @to_datetime_tran_local = @to_datetime_tran_local + 1
 
	IF(@bin_term IS NOT NULL)
	BEGIN
		DECLARE @pan_like VARCHAR(30)
		SET @pan_like = @bin_term + '%'
 
		SELECT TOP (@max_nr_rows)
			post_tran.tran_nr,
			post_tran.post_tran_id,
			post_tran.datetime_req,
			post_tran.datetime_tran_local,
			post_tran.message_type,
			post_tran.message_reason_code,
			post_tran.tran_type,
			post_tran.extended_tran_type,
			post_tran.tran_amount_req,
			post_tran.tran_currency_code,
			post_tran.rsp_code_rsp,
			post_tran.sink_node_name,
			post_tran_cust.pan,
			post_tran_cust.pan_encrypted,
			post_tran_cust.card_acceptor_id_code,
			post_tran_cust.terminal_id,
			post_tran.from_account_id,
			post_tran.to_account_id,
			post_tran.structured_data_req,
			post_tran.system_trace_audit_nr,
			post_tran_cust.source_node_name,
			post_tran_cust.post_tran_cust_id,
			post_tran.online_system_id,
			post_tran.tran_postilion_originated
		FROM
			(
				SELECT
					post_tran_cust_id
				FROM
					post_tran_cust WITH (NOLOCK, INDEX = ix_post_tran_cust_1)
				WHERE
					pan LIKE @pan_like
			) X
		INNER LOOP JOIN
			post_tran WITH (NOLOCK, INDEX = ix_post_tran_2)
		ON
			post_tran.post_tran_cust_id = X.post_tran_cust_id
			AND datetime_tran_local BETWEEN @from_datetime_tran_local AND @to_datetime_tran_local
			AND (tran_postilion_originated = 0 OR (tran_postilion_originated = 1 AND message_type IN ('0522', '0523', '0322', '0323')))
			AND (@system_trace_audit_nr IS NULL OR system_trace_audit_nr = @system_trace_audit_nr)
			AND (@online_system_id IS NULL OR online_system_id = @online_system_id)
			AND (@participant_id IS NULL OR (participant_id = @participant_id OR opp_participant_id = @participant_id))
		INNER LOOP JOIN
			post_tran_cust WITH (NOLOCK, INDEX = pk_post_tran_cust)
		ON
			post_tran_cust.post_tran_cust_id = X.post_tran_cust_id
			AND (@source_node_name IS NULL OR source_node_name = @source_node_name)
			AND (@card_acceptor_id_code IS NULL OR card_acceptor_id_code = @card_acceptor_id_code)
			AND (@terminal_id IS NULL OR terminal_id = @terminal_id)
		ORDER BY
			post_tran.datetime_tran_local DESC,
			post_tran.datetime_req DESC
	END
	ELSE
	BEGIN
		SELECT TOP (@max_nr_rows)
			post_tran.tran_nr,
			post_tran.post_tran_id,
			post_tran.datetime_req,
			post_tran.datetime_tran_local,
			post_tran.message_type,
			post_tran.message_reason_code,
			post_tran.tran_type,
			post_tran.extended_tran_type,
			post_tran.tran_amount_req,
			post_tran.tran_currency_code,
			post_tran.rsp_code_rsp,
			post_tran.sink_node_name,
			post_tran_cust.pan,
			post_tran_cust.pan_encrypted,
			post_tran_cust.card_acceptor_id_code,
			post_tran_cust.terminal_id,
			post_tran.from_account_id,
			post_tran.to_account_id,
			post_tran.structured_data_req,
			post_tran.system_trace_audit_nr,
			post_tran_cust.source_node_name,
			post_tran_cust.post_tran_cust_id,
			post_tran.online_system_id,
			post_tran.tran_postilion_originated
		FROM
			(
				SELECT
					post_tran_cust_id
				FROM
					post_tran_cust WITH (NOLOCK, INDEX = ix_post_tran_cust_3)
		WHERE
					pan_search BETWEEN @pan_bottom AND @pan_top
			) X
		INNER LOOP JOIN
			post_tran WITH (NOLOCK, INDEX = ix_post_tran_2)
		ON
			post_tran.post_tran_cust_id = X.post_tran_cust_id
			AND datetime_tran_local BETWEEN @from_datetime_tran_local AND @to_datetime_tran_local
			AND (tran_postilion_originated = 0 OR (tran_postilion_originated = 1 AND message_type IN ('0522', '0523', '0322', '0323')))
			AND (@system_trace_audit_nr IS NULL OR system_trace_audit_nr = @system_trace_audit_nr)
			AND (@online_system_id IS NULL OR online_system_id = @online_system_id)
			AND (@participant_id IS NULL OR (participant_id = @participant_id OR opp_participant_id = @participant_id))
		INNER LOOP JOIN
			post_tran_cust WITH (NOLOCK, INDEX = pk_post_tran_cust)
		ON
			post_tran_cust.post_tran_cust_id = X.post_tran_cust_id
			AND (@source_node_name IS NULL OR source_node_name = @source_node_name)
			AND (@card_acceptor_id_code IS NULL OR card_acceptor_id_code = @card_acceptor_id_code)
			AND (@terminal_id IS NULL OR terminal_id = @terminal_id)
		ORDER BY
			post_tran.datetime_tran_local DESC,
			post_tran.datetime_req DESC
	END
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_crdhldr_open_pan]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_crdhldr_open_pan]
	@participant_id INT,
	@pan VARCHAR(19),
	@pan_reference VARCHAR(42),
	@from_datetime_tran_local DATETIME,
	@to_datetime_tran_local DATETIME,
	@source_node_name VARCHAR(30),
	@card_acceptor_id_code CHAR(15),
	@terminal_id CHAR(8),
	@online_system_id INT,
	@system_trace_audit_nr CHAR(6),
	@max_nr_rows INT = 1000
AS
BEGIN
	-- For compatibility with Microsoft OLEDB
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
 
	SET @to_datetime_tran_local = @to_datetime_tran_local + 1
 
	SELECT TOP (@max_nr_rows)
		post_tran.tran_nr,
		post_tran.post_tran_id,
		post_tran.datetime_req,
		post_tran.datetime_tran_local,
		post_tran.message_type,
		post_tran.message_reason_code,
		post_tran.tran_type,
		post_tran.extended_tran_type,
		post_tran.tran_amount_req,
		post_tran.tran_currency_code,
		post_tran.rsp_code_rsp,
		post_tran.sink_node_name,
		post_tran_cust.pan,
		post_tran_cust.pan_encrypted,
		post_tran_cust.card_acceptor_id_code,
		post_tran_cust.terminal_id,
		post_tran.from_account_id,
		post_tran.to_account_id,
		post_tran.structured_data_req,
		post_tran.system_trace_audit_nr,
		post_tran_cust.source_node_name,
		post_tran_cust.post_tran_cust_id,
		post_tran.online_system_id,
		post_tran.tran_postilion_originated
	FROM
		(
			SELECT
				post_tran_cust_id
			FROM
				post_tran_cust WITH (NOLOCK, INDEX = ix_post_tran_cust_1)
			WHERE
				pan = @pan
			UNION
			SELECT
				post_tran_cust_id
			FROM
				post_tran_cust WITH (NOLOCK, INDEX = ix_post_tran_cust_4)
			WHERE
				pan_reference = @pan_reference
		) X
		INNER LOOP JOIN
			post_tran WITH (NOLOCK, INDEX = ix_post_tran_2)
		ON
			post_tran.post_tran_cust_id = X.post_tran_cust_id
			AND datetime_tran_local BETWEEN @from_datetime_tran_local AND @to_datetime_tran_local
			AND (tran_postilion_originated = 0 OR (tran_postilion_originated = 1 AND message_type IN ('0522', '0523', '0322', '0323')))
		AND (@system_trace_audit_nr IS NULL OR system_trace_audit_nr = @system_trace_audit_nr)
		AND (@online_system_id IS NULL OR online_system_id = @online_system_id)
		AND (@participant_id IS NULL OR (participant_id = @participant_id OR opp_participant_id = @participant_id))
		INNER LOOP JOIN
			post_tran_cust WITH (NOLOCK, INDEX = pk_post_tran_cust)
		ON
			post_tran_cust.post_tran_cust_id = X.post_tran_cust_id
			AND (@source_node_name IS NULL OR source_node_name = @source_node_name)
			AND (@card_acceptor_id_code IS NULL OR card_acceptor_id_code = @card_acceptor_id_code)
			AND (@terminal_id IS NULL OR terminal_id = @terminal_id)
	ORDER BY
		post_tran.datetime_tran_local DESC,
		post_tran.datetime_req DESC
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_by_account]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_by_account]
	@participant_id INT,
	@account_id VARCHAR(28),
	@account_type VARCHAR(2),
	@from_datetime_tran_local DATETIME,
	@to_datetime_tran_local DATETIME,
	@source_node_name VARCHAR(30),
	@card_acceptor_id_code CHAR(15),
	@terminal_id CHAR(8),
	@online_system_id INT,
	@max_nr_rows INT = 1000
AS
BEGIN
	-- For compatibility with Microsoft OLEDB
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
 
	SET @to_datetime_tran_local = @to_datetime_tran_local + 1
 
	DECLARE @account_id_cs INT
	SET @account_id_cs = dbo.ofn_checksum(@account_id)
 
	SELECT TOP (@max_nr_rows)
		post_tran.tran_nr,
		post_tran.post_tran_id,
		post_tran.datetime_req,
		post_tran.datetime_tran_local,
		post_tran.message_type,
		post_tran.message_reason_code,
		post_tran.tran_type,
		post_tran.extended_tran_type,
		post_tran.tran_amount_req,
		post_tran.tran_currency_code,
		post_tran.rsp_code_rsp,
		post_tran.sink_node_name,
		post_tran_cust.pan,
		post_tran_cust.pan_encrypted,
		post_tran_cust.card_acceptor_id_code,
		post_tran_cust.terminal_id,
		post_tran.from_account_id,
		post_tran.to_account_id,
		post_tran.structured_data_req,
		post_tran.system_trace_audit_nr,
		post_tran_cust.source_node_name,
		post_tran_cust.post_tran_cust_id,
		post_tran.online_system_id,
		post_tran.tran_postilion_originated
	FROM
	(
		SELECT
			post_tran_cust_id
		FROM
			post_tran WITH (NOLOCK, INDEX = ix_post_tran_12)
		WHERE
			from_account_id_cs = @account_id_cs
			AND datetime_tran_local BETWEEN @from_datetime_tran_local AND @to_datetime_tran_local
		UNION
		SELECT
			post_tran_cust_id
		FROM
			post_tran WITH (NOLOCK, INDEX = ix_post_tran_13)
		WHERE
			to_account_id_cs = @account_id_cs
			AND datetime_tran_local BETWEEN @from_datetime_tran_local AND @to_datetime_tran_local
		) X
	INNER LOOP JOIN
		post_tran WITH (NOLOCK, INDEX = ix_post_tran_2)
	ON
		post_tran.post_tran_cust_id = X.post_tran_cust_id
		AND ((from_account_id = @account_id AND (@account_type IS NULL OR from_account_type = @account_type))
			  OR (to_account_id = @account_id AND (@account_type IS NULL OR to_account_type = @account_type)))
		AND datetime_tran_local BETWEEN @from_datetime_tran_local AND @to_datetime_tran_local
		AND (tran_postilion_originated = 0 OR (tran_postilion_originated = 1 AND message_type IN ('0522', '0523', '0322', '0323')))
		AND (@online_system_id IS NULL OR online_system_id = @online_system_id)
		AND (@participant_id IS NULL OR (participant_id = @participant_id OR opp_participant_id = @participant_id))
	INNER LOOP JOIN
		post_tran_cust WITH (NOLOCK, INDEX = pk_post_tran_cust)
	ON
		post_tran_cust.post_tran_cust_id = X.post_tran_cust_id
		AND (@source_node_name IS NULL OR source_node_name = @source_node_name)
		AND (@card_acceptor_id_code IS NULL OR card_acceptor_id_code = @card_acceptor_id_code)
		AND (@terminal_id IS NULL OR terminal_id = @terminal_id)
	ORDER BY
		post_tran.datetime_tran_local DESC,
		post_tran.datetime_req DESC
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_office_find_trans_by_account]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_office_find_trans_by_account]
(
	@participant_id	INT,
	@from_datetime_tran_local	DATETIME,
	@to_datetime_tran_local	DATETIME,
	@accounts_list	VARCHAR(8000),
	@max_nr_rows	INT = 10000
)
AS
BEGIN
	-- For compatibility with Microsoft OLEDB
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
 
	IF (	(DATEPART(hour,@to_datetime_tran_local) = 0) AND
			(DATEPART(minute,@to_datetime_tran_local) = 0) AND
			(DATEPART(second,@to_datetime_tran_local) = 0)	)
BEGIN
		SET @to_datetime_tran_local = DATEADD(hour, 23, @to_datetime_tran_local)
		SET @to_datetime_tran_local = DATEADD(minute, 59, @to_datetime_tran_local)
		SET @to_datetime_tran_local = DATEADD(second, 59, @to_datetime_tran_local)
END
 
	DECLARE @accounts TABLE
	(
		account_id VARCHAR(28),
		account_type CHAR(2),
		PRIMARY KEY (account_id, account_type)
	)
 
	INSERT INTO @accounts
	SELECT
		item AS account_id,
		item_2 AS account_type
FROM
		dbo.ofn_split_list_2 (@accounts_list, ',')
 
	DECLARE @account_id_checksums TABLE
	(
		account_id_cs INT
	)
 
	INSERT INTO @account_id_checksums
	SELECT
		dbo.ofn_checksum(item) AS account_id_cs
	FROM
		dbo.ofn_split_list_2 (@accounts_list, ',')
 
	SELECT TOP (@max_nr_rows)
		post_tran.tran_nr,
		post_tran.post_tran_id,
		post_tran.datetime_req,
		post_tran.datetime_tran_local,
		post_tran.message_type,
		post_tran.message_reason_code,
		post_tran.tran_type,
		post_tran.extended_tran_type,
		post_tran.tran_amount_req,
		post_tran.tran_currency_code,
		post_tran.rsp_code_rsp,
		post_tran.sink_node_name,
		post_tran_cust.pan,
		post_tran_cust.pan_encrypted,
		post_tran_cust.card_acceptor_id_code,
		post_tran_cust.terminal_id,
		post_tran.from_account_id,
		post_tran.to_account_id,
		post_tran.structured_data_req,
		post_tran.system_trace_audit_nr,
		post_tran_cust.source_node_name,
		post_tran_cust.post_tran_cust_id,
		post_tran.online_system_id,
		post_tran.tran_postilion_originated
	FROM
		(
			SELECT
				post_tran_cust_id
			FROM
				@account_id_checksums
			INNER LOOP JOIN
				post_tran WITH (NOLOCK, INDEX = ix_post_tran_12)
			ON
				from_account_id_cs = account_id_cs
				AND datetime_tran_local BETWEEN @from_datetime_tran_local AND @to_datetime_tran_local
			UNION
			SELECT
				post_tran_cust_id
			FROM
				@account_id_checksums
			INNER LOOP JOIN
				post_tran WITH (NOLOCK, INDEX = ix_post_tran_13)
			ON
				to_account_id_cs = account_id_cs
				AND datetime_tran_local BETWEEN @from_datetime_tran_local AND @to_datetime_tran_local
		) X
	INNER LOOP JOIN
		post_tran WITH (NOLOCK, INDEX = ix_post_tran_2)
	ON
		post_tran.post_tran_cust_id = X.post_tran_cust_id
		AND tran_postilion_originated = 0
		AND datetime_tran_local BETWEEN @from_datetime_tran_local AND @to_datetime_tran_local
		AND (@participant_id IS NULL OR (participant_id = @participant_id OR opp_participant_id = @participant_id))
		AND ((EXISTS(SELECT 1 FROM @accounts WHERE account_id = from_account_id AND (account_type = '' OR from_account_type = account_type)))
			  OR (EXISTS(SELECT 1 FROM @accounts WHERE account_id = to_account_id AND (account_type = '' OR to_account_type = account_type))))
	INNER LOOP JOIN
		post_tran_cust WITH (NOLOCK, INDEX = pk_post_tran_cust)
	ON
		post_tran_cust.post_tran_cust_id = X.post_tran_cust_id
	ORDER BY
		post_tran.datetime_tran_local DESC,
		post_tran.datetime_req DESC
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_getextrextendeddata]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_getextrextendeddata]
	@post_tran_id	BIGINT
AS
BEGIN
	SELECT
		extr_extended_data
	FROM
  		post_tran_extract WITH (NOLOCK)
	WHERE
		post_tran_id = @post_tran_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_get_terminals]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_get_terminals]
	@rtfw_participant VARCHAR(25),
	@filter VARCHAR(50),
	@max_results INT
AS
BEGIN
	IF (@rtfw_participant IS NULL)
	BEGIN
		SELECT DISTINCT TOP (@max_results)
			terminal_id,
			short_name
		FROM
			post_online_terminals WITH (NOLOCK)
		WHERE
			((terminal_id LIKE @filter)
			OR (short_name LIKE @filter))
		ORDER BY
			terminal_id,
			short_name
	END
	ELSE
	BEGIN
		SELECT DISTINCT TOP (@max_results)
			terminal_id,
			short_name
		FROM
			post_online_terminals WITH (NOLOCK)
		WHERE
			rtfw_participant_name = @rtfw_participant
			AND ((terminal_id LIKE @filter)
				  OR (short_name LIKE @filter))
		ORDER BY
			terminal_id,
			short_name
	END
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_get_card_acceptors]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_get_card_acceptors]
	@rtfw_participant VARCHAR(25),
	@filter VARCHAR(50),
	@max_results INT
AS
BEGIN
	IF (@rtfw_participant IS NULL)
	BEGIN
		SELECT DISTINCT TOP (@max_results)
			card_acceptor,
			name_location
		FROM
			post_card_acceptor WITH (NOLOCK)
		WHERE
			((card_acceptor LIKE @filter)
			 OR (name_location LIKE @filter))
		ORDER BY
			card_acceptor,
			name_location
	END ELSE
	BEGIN
		SELECT DISTINCT TOP (@max_results)
			pca.card_acceptor,
			pca.name_location
		FROM
			post_card_acceptor pca WITH (NOLOCK)
		INNER JOIN
			post_online_terminals pot WITH (NOLOCK)
		ON
			pca.card_acceptor = pot.card_acceptor
		WHERE
		 	pot.rtfw_participant_name = @rtfw_participant
			AND ((pca.card_acceptor LIKE @filter)
				  OR (pca.name_location LIKE @filter))
		ORDER BY
			pca.card_acceptor,
			pca.name_location
	END
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_get_settle_entity]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_get_settle_entity]
	@node_name POST_NAME,
	@acquiring_institution_id VARCHAR(11),
	@card_acceptor_id CHAR(15),
	@terminal_id POST_TERMINAL_ID
AS
BEGIN
	IF EXISTS (
		SELECT
			*
		FROM
			post_nodes WITH (NOLOCK)
		WHERE
			node_name = @node_name
		)
	BEGIN
		DECLARE @granularity INT
 
		-- The list of entities is dependant on the type of batch granularity configured on the node.
		SELECT
			@granularity = granularity
		FROM
			post_nodes WITH (NOLOCK)
		WHERE
			node_name = @node_name
 
		IF (@granularity = 0)
		BEGIN
			-- If the granularity is 'Terminal'
 
			SELECT
			 	terminal_id
			FROM
				post_settle_entity WITH (NOLOCK)
			WHERE
				RTRIM(card_acceptor_id_code) = @card_acceptor_id
			AND
				RTRIM(terminal_id) = @terminal_id
			AND
				node_name = @node_name
		END
		ELSE IF (@granularity = 1)
		BEGIN
			-- If the granularity is 'Card acceptor'
 
			SELECT
			 	card_acceptor_id_code
			FROM
				post_settle_entity WITH (NOLOCK)
			WHERE
				RTRIM(card_acceptor_id_code) = @card_acceptor_id
			AND
				node_name = @node_name
		END
		ELSE IF (@granularity = 2)
		BEGIN
			-- If the granularity is 'Acquirer'
 
			SELECT
			 	acquiring_inst_id_code
			FROM
				post_settle_entity WITH (NOLOCK)
			WHERE
				acquiring_inst_id_code = @acquiring_institution_id
			AND
				node_name = @node_name
		END
	END
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_get_node_granularity]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_get_node_granularity]
	@node_name POST_NAME
AS
BEGIN
	-- VALID GRANULARITY VALUES :
	--	0 = Terminal
	--	1 = Card acceptor
	--	2 = Acquirer
	--	3 = Node
 
	-- Get the granularity from the post_nodes table if there is an entry for this node
	IF EXISTS (
		SELECT
			*
		FROM
			post_nodes WITH (NOLOCK)
		WHERE
			node_name = @node_name
		)
	BEGIN
		SELECT
			granularity
		FROM
			post_nodes WITH (NOLOCK)
		WHERE
			node_name = @node_name
	END
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_get_node_entities]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_get_node_entities]
	@rtfw_participant VARCHAR(25),
	@node_name POST_NAME,
	@filter VARCHAR(50),
	@max_results INT
AS
BEGIN
	IF EXISTS (
		SELECT
			*
		FROM
			post_nodes WITH (NOLOCK)
		WHERE
			node_name = @node_name
		)
	BEGIN
		DECLARE @granularity INT
 
		-- The list of entities is dependant on the type of batch granularity configured on the ndoe.
		SELECT
			@granularity = granularity
		FROM
			post_nodes WITH (NOLOCK)
		WHERE
			node_name = @node_name
 
		IF (@granularity = 0)
		BEGIN
			-- If the granularity is 'Terminal' then retrieve the list of card acceptors
			-- that have terminals in post_settle_entity. The card acceptor will ultimately
			-- be used to retrieve a list of terminals.
 
			IF (@rtfw_participant IS NULL)
			BEGIN
				SELECT DISTINCT TOP (@max_results)
					pse.card_acceptor_id_code,
					pca.name_location
				FROM
					post_settle_entity pse WITH (NOLOCK)
				LEFT JOIN
					post_card_acceptor pca WITH (NOLOCK)
				ON
					pse.card_acceptor_id_code = pca.card_acceptor
				WHERE
					pse.terminal_id IS NOT NULL
					AND pse.node_name = @node_name
					AND ((pse.card_acceptor_id_code LIKE @filter)
						  OR (pca.name_location LIKE @filter))
				ORDER BY
					pse.card_acceptor_id_code,
					pca.name_location
			END ELSE
			BEGIN
				SELECT DISTINCT TOP (@max_results)
					pse.card_acceptor_id_code,
					pca.name_location
				FROM
					post_settle_entity pse WITH (NOLOCK)
				LEFT JOIN
					post_card_acceptor pca WITH (NOLOCK)
				ON
					pse.card_acceptor_id_code = pca.card_acceptor
				LEFT JOIN
					post_online_terminals pot WITH (NOLOCK)
				ON
					pse.card_acceptor_id_code = pot.card_acceptor
				WHERE
					ISNULL(pot.rtfw_participant_name, @rtfw_participant) = @rtfw_participant
					AND pse.terminal_id IS NOT NULL
					AND pse.node_name = @node_name
					AND ((pse.card_acceptor_id_code LIKE @filter)
						  OR (pca.name_location LIKE @filter))
				ORDER BY
					pse.card_acceptor_id_code,
					pca.name_location
			END
 
		END
		ELSE IF (@granularity = 1)
		BEGIN
			-- If the granularity is 'Card acceptor' then retrieve a list of card acceptors
			-- that do not have terminals in post_settle_entity.
 
			IF (@rtfw_participant IS NULL)
			BEGIN
				SELECT DISTINCT TOP (@max_results)
					pse.card_acceptor_id_code,
					pca.name_location
				FROM
					post_settle_entity pse WITH (NOLOCK)
				LEFT JOIN
					post_card_acceptor pca WITH (NOLOCK)
				ON
					pse.card_acceptor_id_code = pca.card_acceptor
				WHERE
					pse.terminal_id IS NULL
					AND pse.card_acceptor_id_code IS NOT NULL
					AND pse.node_name = @node_name
					AND ((pse.card_acceptor_id_code LIKE @filter)
						  OR (pca.name_location LIKE @filter))
				ORDER BY
					pse.card_acceptor_id_code,
					pca.name_location
			END ELSE
			BEGIN
				SELECT DISTINCT TOP (@max_results)
					pse.card_acceptor_id_code,
					pca.name_location
				FROM
					post_settle_entity pse WITH (NOLOCK)
				LEFT JOIN
					post_card_acceptor pca WITH (NOLOCK)
				ON
					pse.card_acceptor_id_code = pca.card_acceptor
				LEFT JOIN
					post_online_terminals pot WITH (NOLOCK)
				ON
					pse.card_acceptor_id_code = pot.card_acceptor
				WHERE
					ISNULL(pot.rtfw_participant_name, @rtfw_participant) = @rtfw_participant
					AND pse.terminal_id IS NULL
					AND pse.card_acceptor_id_code IS NOT NULL
					AND pse.node_name = @node_name
					AND ((pse.card_acceptor_id_code LIKE @filter)
						  OR (pca.name_location LIKE @filter))
				ORDER BY
					pse.card_acceptor_id_code,
					pca.name_location
			END
 
		END
		ELSE IF (@granularity = 2)
		BEGIN
			-- If the granularity is 'Acquirer' then retrieve a list of acquirers.
			-- This method does not support limiting by participant as there is
			-- no way to link the acquiring institution with the participant.
 
			-- Also select the same value into two columns so that the result set
			-- returned by this query is consistent in the number of columns
 
			SELECT DISTINCT TOP (@max_results)
				acquiring_inst_id_code,
				acquiring_inst_id_code AS acquiring_inst_id_code_2
			FROM
				post_settle_entity WITH (NOLOCK)
			WHERE
				acquiring_inst_id_code IS NOT NULL
				AND node_name = @node_name
				AND acquiring_inst_id_code LIKE @filter
			ORDER BY
				acquiring_inst_id_code
		END
	END
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_get_node_card_acceptor_terminals]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_get_node_card_acceptor_terminals]
	@rtfw_participant VARCHAR(25),
	@node_name POST_NAME,
	@card_acceptor_id CHAR(15),
	@filter VARCHAR(50),
	@max_results INT
AS
BEGIN
	IF (@rtfw_participant IS NULL)
	BEGIN
		SELECT DISTINCT TOP (@max_results)
			pse.terminal_id,
			pot.short_name
		FROM
			post_settle_entity pse WITH (NOLOCK)
		LEFT JOIN
			post_online_terminals pot WITH (NOLOCK)
		ON
			pse.terminal_id = pot.terminal_id
		WHERE
			pse.node_name = @node_name
			AND RTRIM(pse.card_acceptor_id_code) = @card_acceptor_id
			AND ((pse.terminal_id LIKE @filter)
				  OR (pot.short_name LIKE @filter))
		ORDER BY
			pse.terminal_id,
			pot.short_name
	END ELSE
	BEGIN
		SELECT DISTINCT TOP (@max_results)
			pse.terminal_id,
			pot.short_name
		FROM
			post_settle_entity pse WITH (NOLOCK)
		LEFT JOIN
			post_online_terminals pot WITH (NOLOCK)
		ON
			pse.terminal_id = pot.terminal_id
		WHERE
			ISNULL(pot.rtfw_participant_name, @rtfw_participant) = @rtfw_participant
			AND pse.node_name = @node_name
			AND RTRIM(pse.card_acceptor_id_code) = @card_acceptor_id
			AND ((pse.terminal_id LIKE @filter)
			     OR (pot.short_name LIKE @filter))
		ORDER BY
			pse.terminal_id,
			pot.short_name
	END
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_get_settle_entity]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_get_settle_entity]
	@settle_entity_id INT
AS
BEGIN
	SELECT
		settle_entity_id,
		node_name,
		acquiring_inst_id_code,
		card_acceptor_id_code,
		terminal_id
	FROM
		post_settle_entity WITH (NOLOCK)
	WHERE
		settle_entity_id = @settle_entity_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_get_online_systems]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_get_online_systems]
AS
BEGIN
	SELECT
		online_system_id,
		name
	FROM
		post_online_system WITH (NOLOCK)
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_office_reports_get_categories]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_office_reports_get_categories]
(
	@participant_name	VARCHAR(25)
)
AS
BEGIN
	SELECT
		DISTINCT(category_name)
	FROM
		pp_office_participant_reports_entity WITH (NOLOCK)
	WHERE
		participant_name = @participant_name
	ORDER BY
		category_name
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_getptc]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_getptc]
	@post_tran_cust_id	BIGINT
AS
BEGIN
	SELECT
		source_node_name,
		pan,
		pan_encrypted,
		card_seq_nr,
		expiry_date,
		service_restriction_code,
		terminal_id,
		terminal_owner,
		check_data,
		card_acceptor_id_code,
		card_acceptor_name_loc,
		draft_capture,
		merchant_type,
		pos_card_data_input_ability,
		pos_cardholder_auth_ability,
		pos_card_capture_ability,
		pos_operating_environment,
		pos_cardholder_present,
		pos_card_present,
		pos_card_data_input_mode,
		pos_cardholder_auth_method,
		pos_cardholder_auth_entity,
		pos_card_data_output_ability,
		pos_terminal_output_ability,
		pos_pin_capture_ability,
		pos_terminal_operator,
		pos_terminal_type,
		totals_group,
		card_product,
		address_verification_data,
		address_verification_result,
		pan_encrypted
	FROM
		post_tran_cust WITH (NOLOCK)
	WHERE
		post_tran_cust_id = @post_tran_cust_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_reports_entity_unlink_participant]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_reports_entity_unlink_participant]
(
	@entity_name POST_NAME
)
AS
BEGIN
	IF EXISTS (
		SELECT
			*
		FROM
			pp_office_participant_reports_entity WITH (NOLOCK)
		WHERE
			reports_entity_name = @entity_name)
	BEGIN
		DELETE FROM
			pp_office_participant_reports_entity
		WHERE
			reports_entity_name = @entity_name
	END
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_reports_entity_link_participant]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_reports_entity_link_participant]
(
	@entity_name POST_NAME,
	@participant VARCHAR(25)
)
AS
BEGIN
	IF NOT EXISTS (
		SELECT
			*
		FROM
			pp_office_participant_reports_entity WITH (NOLOCK)
		WHERE
			reports_entity_name = @entity_name
		AND
			participant_name = @participant)
	BEGIN
		INSERT INTO
			pp_office_participant_reports_entity (reports_entity_name, participant_name)
		VALUES
			(@entity_name, @participant)
	END
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_batches]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_batches]
	@node_name VARCHAR(30),
	@card_acceptor_id_code CHAR(15),
	@terminal_id CHAR(8),
	@acquiring_inst_id_code VARCHAR (11)
AS
BEGIN
	-- For compatibility with Microsoft OLEDB
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
 
	IF @terminal_id IS NOT NULL
	BEGIN
		SELECT
			pb.batch_nr,
			pb.settle_date,
			pb.datetime_begin,
			pb.datetime_end
		FROM
			post_settle_entity pse WITH (NOLOCK, INDEX=ix_post_settle_entity_3)
			INNER JOIN
			post_batch pb WITH (NOLOCK)
		ON
			pb.settle_entity_id = pse.settle_entity_id
      WHERE
			pse.terminal_id = @terminal_id
			AND card_acceptor_id_code = @card_acceptor_id_code
			AND node_name = @node_name
		ORDER BY
			pb.batch_nr DESC
	END
	ELSE IF @card_acceptor_id_code IS NOT NULL
	BEGIN
		SELECT
			pb.batch_nr,
			pb.settle_date,
			pb.datetime_begin,
			pb.datetime_end
		FROM
			post_settle_entity pse WITH (NOLOCK, INDEX=ix_post_settle_entity_4)
		INNER JOIN
			post_batch pb WITH (NOLOCK)
		ON
			pb.settle_entity_id = pse.settle_entity_id
      WHERE
			card_acceptor_id_code = @card_acceptor_id_code
			AND node_name = @node_name
		ORDER BY
			pb.batch_nr DESC
	END
	ELSE
	BEGIN
		SELECT
			pb.batch_nr,
			pb.settle_date,
			pb.datetime_begin,
			pb.datetime_end
		FROM
			post_settle_entity pse WITH (NOLOCK, INDEX=ix_post_settle_entity_2)
		INNER JOIN
			post_batch pb WITH (NOLOCK)
		ON
			pb.settle_entity_id = pse.settle_entity_id
      WHERE
			node_name = @node_name
			AND (@acquiring_inst_id_code IS NULL OR acquiring_inst_id_code = @acquiring_inst_id_code)
		ORDER BY
			pb.batch_nr DESC
	END
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_tranqry_batch_totals]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_tranqry_batch_totals]
	@batch_nr INT,
	@node_name VARCHAR(30),
	@card_acceptor_id_code CHAR(15),
	@terminal_id CHAR(8),
	@acquiring_inst_id_code VARCHAR (11)
AS
BEGIN
	-- For compatibility with Microsoft OLEDB
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
 
 
	IF @terminal_id IS NOT NULL
	BEGIN
		SELECT
			pb.batch_nr,
			pse.node_name,
			pse.acquiring_inst_id_code,
			pse.card_acceptor_id_code,
			pse.terminal_id,
			pb.settle_date,
	      pb.datetime_begin,
	      pb.datetime_end,
	      pb.count_credit,
	      pb.count_credit_reversal,
	      pb.count_debit,
	      pb.count_debit_reversal,
	      pb.count_transfer,
	      pb.count_transfer_reversal,
	      pb.count_payment,
	      pb.count_payment_reversal,
	      pb.count_inquiry,
	      pb.count_auth,
	      pb.amount_credit_proc_fee,
	      pb.amount_credit_tran_fee,
	      pb.amount_debit_proc_fee,
	      pb.amount_debit_tran_fee,
	      pb.amount_credit,
	      pb.amount_credit_reversal,
	      pb.amount_debit,
	      pb.amount_debit_reversal,
	      pb.amount_net_settle,
	      pb.remote_count_credit,
	      pb.remote_count_credit_reversal,
	      pb.remote_count_debit,
	      pb.remote_count_debit_reversal,
	      pb.remote_count_transfer,
	      pb.remote_count_transfer_reversal,
	      pb.remote_count_payment,
	      pb.remote_count_payment_reversal,
	      pb.remote_count_inquiry,
	      pb.remote_count_auth,
	      pb.remote_amount_credit_proc_fee,
	      pb.remote_amount_credit_tran_fee,
	      pb.remote_amount_debit_proc_fee,
	      pb.remote_amount_debit_tran_fee,
	      pb.remote_amount_credit,
	      pb.remote_amount_credit_reversal,
	      pb.remote_amount_debit,
	      pb.remote_amount_debit_reversal,
	      pb.remote_amount_net_settle,
	      pb.currency_code
	  FROM post_settle_entity pse WITH (NOLOCK, INDEX=ix_post_settle_entity_3)
			INNER JOIN
			post_batch pb WITH (NOLOCK)
		ON
			pb.settle_entity_id = pse.settle_entity_id
      WHERE
			pb.batch_nr = @batch_nr
         AND pse.terminal_id = @terminal_id
			AND card_acceptor_id_code = @card_acceptor_id_code
			AND node_name = @node_name
	END
	ELSE IF @card_acceptor_id_code IS NOT NULL
	BEGIN
		SELECT
			pb.batch_nr,
			pse.node_name,
			pse.acquiring_inst_id_code,
			pse.card_acceptor_id_code,
			pse.terminal_id,
			pb.settle_date,
	      pb.datetime_begin,
	      pb.datetime_end,
	      pb.count_credit,
	      pb.count_credit_reversal,
	      pb.count_debit,
	      pb.count_debit_reversal,
	      pb.count_transfer,
	      pb.count_transfer_reversal,
	      pb.count_payment,
	      pb.count_payment_reversal,
	      pb.count_inquiry,
	      pb.count_auth,
	      pb.amount_credit_proc_fee,
	      pb.amount_credit_tran_fee,
	      pb.amount_debit_proc_fee,
	      pb.amount_debit_tran_fee,
	      pb.amount_credit,
	      pb.amount_credit_reversal,
	      pb.amount_debit,
	      pb.amount_debit_reversal,
	      pb.amount_net_settle,
	      pb.remote_count_credit,
	      pb.remote_count_credit_reversal,
	      pb.remote_count_debit,
	      pb.remote_count_debit_reversal,
	      pb.remote_count_transfer,
	      pb.remote_count_transfer_reversal,
	      pb.remote_count_payment,
	      pb.remote_count_payment_reversal,
	      pb.remote_count_inquiry,
	      pb.remote_count_auth,
	      pb.remote_amount_credit_proc_fee,
	      pb.remote_amount_credit_tran_fee,
	      pb.remote_amount_debit_proc_fee,
	      pb.remote_amount_debit_tran_fee,
	      pb.remote_amount_credit,
	      pb.remote_amount_credit_reversal,
	      pb.remote_amount_debit,
	      pb.remote_amount_debit_reversal,
	      pb.remote_amount_net_settle,
	      pb.currency_code
		FROM
			post_settle_entity pse WITH (NOLOCK, INDEX=ix_post_settle_entity_4)
		INNER JOIN
			post_batch pb WITH (NOLOCK)
		ON
			pb.settle_entity_id = pse.settle_entity_id
      WHERE
			pb.batch_nr = @batch_nr
      	AND card_acceptor_id_code = @card_acceptor_id_code
			AND node_name = @node_name
	END
	ELSE
	BEGIN
		SELECT
			pb.batch_nr,
			pse.node_name,
			pse.acquiring_inst_id_code,
			pse.card_acceptor_id_code,
			pse.terminal_id,
			pb.settle_date,
	      pb.datetime_begin,
	      pb.datetime_end,
	      pb.count_credit,
	      pb.count_credit_reversal,
	      pb.count_debit,
	      pb.count_debit_reversal,
	      pb.count_transfer,
	      pb.count_transfer_reversal,
	      pb.count_payment,
	      pb.count_payment_reversal,
	      pb.count_inquiry,
	      pb.count_auth,
	      pb.amount_credit_proc_fee,
	      pb.amount_credit_tran_fee,
	      pb.amount_debit_proc_fee,
	      pb.amount_debit_tran_fee,
	      pb.amount_credit,
	      pb.amount_credit_reversal,
	      pb.amount_debit,
	      pb.amount_debit_reversal,
	      pb.amount_net_settle,
	      pb.remote_count_credit,
	      pb.remote_count_credit_reversal,
	      pb.remote_count_debit,
	      pb.remote_count_debit_reversal,
	      pb.remote_count_transfer,
	      pb.remote_count_transfer_reversal,
	      pb.remote_count_payment,
	      pb.remote_count_payment_reversal,
	      pb.remote_count_inquiry,
	      pb.remote_count_auth,
	      pb.remote_amount_credit_proc_fee,
	      pb.remote_amount_credit_tran_fee,
	      pb.remote_amount_debit_proc_fee,
	      pb.remote_amount_debit_tran_fee,
	      pb.remote_amount_credit,
	      pb.remote_amount_credit_reversal,
	      pb.remote_amount_debit,
	      pb.remote_amount_debit_reversal,
	      pb.remote_amount_net_settle,
	      pb.currency_code
		FROM
			post_settle_entity pse WITH (NOLOCK, INDEX=ix_post_settle_entity_2)
		INNER JOIN
			post_batch pb WITH (NOLOCK)
		ON
			pb.settle_entity_id = pse.settle_entity_id
      WHERE
			pb.batch_nr = @batch_nr
      	AND node_name = @node_name
			AND (@acquiring_inst_id_code IS NULL OR acquiring_inst_id_code = @acquiring_inst_id_code)
	END
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_office_reports_get_template_categories]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_office_reports_get_template_categories]
AS
BEGIN
	SELECT
		DISTINCT(category)
	FROM
		reports_template WITH (NOLOCK)
	WHERE
		plugin_id = 'Crystal'
	ORDER BY
		category
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_office_reports_entity_check_participant]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_office_reports_entity_check_participant]
(
	@entity_id			POST_ID,
	@participant_name	VARCHAR(25)
)
AS
BEGIN
	DECLARE @entity_name POST_NAME
	SELECT @entity_name = name FROM reports_entity WHERE entity_id = @entity_id
 
	IF @entity_name IS NOT NULL
	BEGIN
		SELECT
			1
		FROM
			pp_office_participant_reports_entity WITH (NOLOCK)
		WHERE
			reports_entity_name = @entity_name
		AND
			participant_name = @participant_name
	END
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_office_reports_add_report_entity]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_office_reports_add_report_entity]
(
	@name	VARCHAR(30),
	@plugin_id VARCHAR(20),
	@template_id INT
)
AS
BEGIN
	IF EXISTS(
		SELECT *	FROM reports_entity
		WHERE	name = @name)
	BEGIN
		SELECT -1
		RETURN
	END
 
	DECLARE @entity_id INT
 
	SELECT
		@entity_id = MAX(entity_id)
	FROM
		reports_entity
 
	IF @entity_id IS NULL
	BEGIN
		SET @entity_id = 0
	END
	ELSE BEGIN
		SET @entity_id = @entity_id + 1
	END
 
	INSERT INTO reports_entity (
		entity_id,
		name,
		plugin_id,
		template_id)
	VALUES (
		@entity_id,
		@name,
		@plugin_id,
		@template_id)
 
	SELECT @entity_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_office_reports_get_scheduled_run_history]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_office_reports_get_scheduled_run_history]
(
	@max_nr_items	INT,
	@entity_id   	POST_ID,
	@start_date 	DATETIME,
	@end_date		DATETIME
)
AS
BEGIN
	DECLARE @entity_name POST_NAME
 
	SELECT
		@entity_name = name
	FROM
		reports_entity WITH (NOLOCK)
	WHERE
		entity_id = @entity_id
 
	IF (@max_nr_items != 0)
	BEGIN
		SET ROWCOUNT @max_nr_items
	END
 
	SELECT
		ppr.process_run_id,
		ppr.datetime_begin,
		ppr.result_value,
		pfh.external_file_name
	FROM
		post_process_run ppr WITH (NOLOCK)
	LEFT OUTER JOIN
		post_file_history pfh WITH (NOLOCK)
	ON
		ppr.process_run_id = pfh.process_run_id
	AND
		pfh.external_file_name IS NOT NULL
	WHERE
		ppr.process_name = 'Reports'
	AND
		ppr.process_entity = @entity_name
	AND
		ppr.datetime_end IS NOT NULL
	AND
		((@start_date IS NULL) OR (datetime_begin >= @start_date))
	AND
		((@end_date IS NULL) OR (datetime_begin <= @end_date))
	ORDER BY
		ppr.datetime_begin DESC
 
	SET ROWCOUNT 0
 
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_office_reports_get_scheduled_output_file]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_office_reports_get_scheduled_output_file]
(
	@run_id			INT
)
AS
BEGIN
	SELECT
		rt.template_name,
		rt.category,
		rs.report_params,
		rs.pan_masking_level,
		ppr.datetime_begin,
		pfh.external_file_name
	FROM
		post_file_history pfh WITH (NOLOCK)
	INNER JOIN
		post_process_run ppr WITH (NOLOCK)
	ON
		pfh.process_run_id = ppr.process_run_id
	INNER JOIN
		reports_session rs WITH (NOLOCK)
	ON
		rs.process_run_id = pfh.process_run_id
	INNER JOIN
		reports_entity re WITH (NOLOCK)
	ON
		pfh.entity_name = re.name
	INNER JOIN
		reports_template rt WITH (NOLOCK)
	ON
		re.template_id = rt.template_id
	WHERE
		pfh.external_file_name IS NOT NULL
	AND
		pfh.process_run_id = @run_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_office_reports_update_report_entity]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_office_reports_update_report_entity]
(
	@entity_id INT,
	@name	VARCHAR(30),
	@plugin_id VARCHAR(20),
	@template_id INT,
	@report_exist INT OUTPUT
)
AS
BEGIN
	DECLARE @orig_entity_name VARCHAR(30)
	SELECT @orig_entity_name = name FROM reports_entity WHERE entity_id = @entity_id
 
	IF (@orig_entity_name <> @name)
	BEGIN
		IF EXISTS(
		SELECT *	FROM reports_entity
		WHERE	name = @name
		AND entity_id <> @entity_id)
		BEGIN
			SET @report_exist = 1
			RETURN
		END
		ELSE BEGIN
			UPDATE pp_office_participant_reports_entity
			SET reports_entity_name = @name
			WHERE reports_entity_name = @orig_entity_name
		END
	END
	SET @report_exist = 0
	UPDATE reports_entity SET
		name = @name,
		plugin_id = @plugin_id,
		template_id = @template_id
		WHERE entity_id = @entity_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_reports_get_entity]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_reports_get_entity]
(
	@entity_id POST_ID
)
AS
BEGIN
	SELECT
		rt.plugin_id,
		re.entity_id,
		re.name,
		rt.template_id,
		rt.template_name,
		rt.category
	FROM
		reports_entity re WITH (NOLOCK)
	INNER JOIN
		reports_template rt WITH (NOLOCK)
	ON
		re.template_id = rt.template_id
	WHERE
		re.entity_id = @entity_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_reports_delete_entity]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_reports_delete_entity]
(
	@entity_id POST_ID
)
AS
BEGIN
	DELETE FROM
		reports_entity
	WHERE
		entity_id = @entity_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_reports_crystal_get_parameters]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_reports_crystal_get_parameters]
(
	@crystal_entity_id POST_ID
)
AS
BEGIN
	SELECT
		destination,
		output_format,
		retention_period,
		dsn_list,
		output_params,
		report_params,
		visible_in_portal
	FROM
		reports_crystal WITH (NOLOCK)
	WHERE
		entity = @crystal_entity_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_reports_crystal_delete_entity]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_reports_crystal_delete_entity]
(
	@crystal_entity_id POST_ID
)
AS
BEGIN
	DELETE FROM
		reports_crystal
	WHERE
		entity = @crystal_entity_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_office_reports_update_entity_output_parameters]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_office_reports_update_entity_output_parameters]
(
	@reports_entity_name		POST_NAME,
	@output_params				TEXT
)
AS
BEGIN
	DECLARE @entity_id POST_ID
	SET @entity_id = (SELECT entity_id FROM reports_entity WITH (NOLOCK) WHERE name = @reports_entity_name)
 
	UPDATE
		reports_crystal
	SET
		output_params = @output_params
	WHERE
		entity = @entity_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_office_reports_update_crystal_report]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_office_reports_update_crystal_report]
(
	@entity_id INT,
	@destination INT,
	@output_format INT,
	@output_params TEXT,
	@report_params TEXT,
	@retention_period INT,
	@dsn_list VARCHAR(255),
	@visible_in_portal INT
)
AS
BEGIN
	UPDATE reports_crystal SET
		destination = @destination,
		output_format = @output_format,
		output_params = @output_params,
		report_params = @report_params,
		retention_period = @retention_period,
		dsn_list = @dsn_list,
		visible_in_portal = @visible_in_portal
	WHERE entity = @entity_id
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_office_reports_set_crystal_param]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_office_reports_set_crystal_param]
(
	@entity_id INT,
	@destination INT,
	@output_format INT,
	@output_params TEXT,
	@report_params TEXT,
	@crystal_version INT,
	@retention_period INT,
	@dsn_list VARCHAR(255),
	@visible_in_portal INT
)
AS
BEGIN
	INSERT INTO reports_crystal (
		entity,
		template,
		destination,
		output_format,
		output_params,
		report_params,
		crystal_version,
		retention_period,
		dsn_list,
		visible_in_portal)
	VALUES (
		@entity_id,
		'',
		@destination,
		@output_format,
		@output_params,
		@report_params,
		@crystal_version,
		@retention_period,
		@dsn_list,
		@visible_in_portal)
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_office_reports_get_entity_run_history]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_office_reports_get_entity_run_history]
(
	@max_nr_history_items	INT,
	@reports_entity_name   	POST_NAME,
	@start_date 		     	DATETIME,
	@end_date					DATETIME
)
AS
BEGIN
	DECLARE @destination INT
 
	SELECT
		@destination = c.destination
	FROM
		reports_entity e WITH (NOLOCK)
	INNER JOIN
		reports_crystal c WITH (NOLOCK)
	ON
		e.entity_id = c.entity
	WHERE
		e.name = @reports_entity_name
 
	IF (@max_nr_history_items != 0)
	BEGIN
		SET ROWCOUNT @max_nr_history_items
	END
 
	SELECT
		a.process_run_id,
		a.datetime_begin,
		a.result_value,
		@destination AS destination,
		b.file_location
	FROM
		post_process_run a WITH (NOLOCK)
	LEFT OUTER JOIN
		post_process_run_mail_attachment b WITH (NOLOCK)
	ON
		a.process_run_id = b.process_run_id
	WHERE
		a.process_name = 'Reports'
		AND a.process_entity = @reports_entity_name
		AND a.datetime_end IS NOT NULL
		AND ((@start_date IS NULL) OR (datetime_begin >= @start_date))
		AND ((@end_date IS NULL) OR (datetime_begin <= @end_date))
	ORDER BY
		a.datetime_begin DESC
 
	SET ROWCOUNT 0
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_office_reports_get_entity_output_parameters]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_office_reports_get_entity_output_parameters]
(
	@reports_entity_name	POST_NAME
)
AS
BEGIN
	SELECT
		b.destination, b.output_params
	FROM
		reports_entity a WITH (NOLOCK)
	INNER JOIN
		reports_crystal b WITH (NOLOCK)
	ON
		a.entity_id = b.entity
	WHERE
		a.name = @reports_entity_name
END
GO
/****** Object:  StoredProcedure [dbo].[opsp_office_reports_get_entities_details]    Script Date: 06/23/2014 10:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[opsp_office_reports_get_entities_details]
(
	@participant_name	VARCHAR(25),
	@category_name	VARCHAR(30),		-- either the category name or the reports entity name paramater will be null; not both
	@reports_entity_name	POST_NAME
)
AS
BEGIN
 
	-- DECLARE THE RESULT TABLE: EACH RECORD IN THIS TABLE RELATES TO A SINGLE REPORT
	DECLARE @result_table TABLE
	(
		reports_entity_name 		VARCHAR(30),
		description 			NVARCHAR(512),
		previous_run_datetime 		DATETIME,
		previous_run_result 		INT,
		next_run_date 			INT,
		next_run_time 			INT,
		category_name 			VARCHAR(30),
		job_name			VARCHAR(200),
		destination 			INT	-- POST_ID does not work here - isqlw moans.
	)
 
	CREATE TABLE #report_entities
	(
		reports_entity_name VARCHAR (30),
		category_name VARCHAR (30)
	)
 
	INSERT INTO #report_entities
	SELECT
		reports_entity_name AS reports_entity_name,
		category_name
	FROM
		pp_office_participant_reports_entity WITH (NOLOCK)
	INNER JOIN
		reports_entity WITH (NOLOCK)
	ON
		pp_office_participant_reports_entity.reports_entity_name = reports_entity.name
	WHERE
		participant_name = @participant_name
	AND
		reports_entity.plugin_id = 'Crystal'
 
	-- DECLARE THE REPORTS ENTITY CURSOR BASED ON THE REPORTS ENTITY NAME PARAMETER:
	-- A NULL PARAMETER INDICATES THAT ALL REPORTS FOR THIS PARTICIPANT SHOULD BE RETRIEVED
	IF @category_name IS NOT NULL
	BEGIN
		DECLARE reports_entity_cursor CURSOR FOR
		(
			SELECT
				reports_entity_name
			FROM
				#report_entities
			WHERE
				category_name = @category_name
		)
	END
	ELSE IF @reports_entity_name IS NOT NULL
	BEGIN
		DECLARE reports_entity_cursor CURSOR FOR
		(
			SELECT
				reports_entity_name
			FROM
				#report_entities
			WHERE
				reports_entity_name = @reports_entity_name
		)
	END
	ELSE
	BEGIN
		DECLARE reports_entity_cursor CURSOR FOR
		(
			SELECT reports_entity_name FROM #report_entities
		)
	END
 
	OPEN reports_entity_cursor
 
	DECLARE @cur_val POST_NAME
 
	FETCH NEXT FROM reports_entity_cursor INTO @cur_val
 
	WHILE @@FETCH_STATUS = 0
	BEGIN
 
		-- INSERT THE NAME OF THE REPORT ENTITY
 
		INSERT INTO @result_table
		VALUES(@cur_val,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 
		-- GET THE DESCRIPTION AND JOB SCHEDULE INFORMATION FROM THE SQL SERVER SCHEDULED JOBS TABLES IN THE MSDB DATABASE
 
		DECLARE @job_name VARCHAR(255)
		SET @job_name = (SELECT job_name FROM pp_office_participant_reports_entity WITH (NOLOCK) WHERE reports_entity_name = @cur_val)
 
		IF @job_name IS NOT NULL
		BEGIN
 
			DECLARE @description NVARCHAR(512)
			DECLARE @next_run_date INT
			DECLARE @next_run_time INT
 
			SET ROWCOUNT 1
 
			SELECT
				@description = a.description,
				@next_run_date = b.next_run_date,
				@next_run_time = b.next_run_time
			FROM
				msdb..sysjobs a WITH (NOLOCK)
			LEFT OUTER JOIN
				msdb..sysjobschedules b WITH (NOLOCK)
			ON
				a.job_id = b.job_id
			WHERE
				a.name = @job_name
 
			SET ROWCOUNT 0
 
			-- UPDATE THE RESULT TABLE
 
			UPDATE
				@result_table
			SET
				job_name = @job_name,
				description = @description,
				next_run_date = @next_run_date,
				next_run_time = @next_run_time
			WHERE
				reports_entity_name = @cur_val
		END
 
		-- GET THE CATEGORY NAME FROM PARTICIPANT REPORTS ENTITY TABLE
		-- GET THE LAST RUN'S DETAILS FROM THE OFFICE PROCESS LOG
		-- GET THE DESTINATION (REPORT TYPE) FROM THE CRYSTAL REPORTS TABLE
 
		DECLARE @category VARCHAR(30)
		DECLARE @previous_run_datetime DATETIME
		DECLARE @previous_run_result INT
		DECLARE @destination POST_ID
 
      SET  @category =  null
		SET @previous_run_datetime = null
		SET @previous_run_result =  null
		SET @destination = null
 
		SET ROWCOUNT 1
 
		SELECT
			@previous_run_datetime = b.datetime_begin,
			@previous_run_result = result_value
		FROM
			pp_office_participant_reports_entity a WITH (NOLOCK)
		INNER JOIN
			post_process_run b WITH (NOLOCK)
		ON
			a.reports_entity_name = b.process_entity
		WHERE
			a.reports_entity_name = @cur_val AND
			b.process_name = 'Reports' AND
			b.datetime_end IS NOT NULL
		ORDER BY
			b.datetime_begin DESC
 
		SELECT
			@category = p.category_name
		FROM
			pp_office_participant_reports_entity p WITH (NOLOCK)
		WHERE
			p.reports_entity_name = @cur_val AND
			p.participant_name = @participant_name
 
		SELECT
			@destination = destination
		FROM
			reports_crystal c WITH (NOLOCK)
		INNER JOIN
			reports_entity e WITH (NOLOCK)
		ON
			c.entity = e.entity_id
		WHERE
			e.name = @cur_val
 
		SET ROWCOUNT 0
 
		-- UPDATE THE RESULT TABLE
 
		UPDATE
			@result_table
		SET
			category_name = @category,
			previous_run_datetime = @previous_run_datetime,
			previous_run_result = @previous_run_result,
			destination = @destination
		WHERE
			reports_entity_name = @cur_val
 
		FETCH NEXT FROM reports_entity_cursor INTO @cur_val
 
	END
 
	CLOSE reports_entity_cursor
	DEALLOCATE reports_entity_cursor
 
	SELECT * FROM @result_table
END
GO
