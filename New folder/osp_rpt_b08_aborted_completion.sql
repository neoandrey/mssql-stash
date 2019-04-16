USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_aborted_completion]    Script Date: 03/25/2015 12:44:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO







ALTER               PROCEDURE [dbo].[osp_rpt_b08_aborted_completion]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN

IF ((@Period is NULL or @Period = 'Daily') and (@StartDate IS NULL or @EndDate is NULL OR Len(@StartDate)=0)) 

BEGIN
SET @StartDate  = CONVERT(CHAR(8),(DATEADD (dd, -1, GetDate())), 112)
SET @EndDate = CONVERT(CHAR(8),(DATEADD (dd,-1, GetDate())), 112)
END

IF (@Period = 'Weekly' and (@StartDate IS NULL or @EndDate is NULL OR Len(@StartDate)=0)) 

BEGIN
SET @StartDate  = CONVERT(CHAR(8),(DATEADD (dd, -7, GetDate())), 112)
SET @EndDate = CONVERT(CHAR(8),(DATEADD (dd, 0, GetDate())), 112)
END


IF (@Period = 'Monthly' and (@StartDate IS NULL or @EndDate is NULL OR Len(@StartDate)=0)) 

BEGIN
SET @StartDate = (select CONVERT(char(6), (DATEADD (MONTH, -1,GETDATE())), 112)+ '01') 
SET @EndDate = (select CONVERT(char(6), GETDATE(), 112)+ '01')
END


create table #aborted
(post_tran_cust_id	varchar(20),
tran_nr		varchar (16))
insert into #aborted 
select post_tran_cust_id,tran_nr from post_tran a (nolock)
where message_type in ('0220')
	and a.tran_amount_req != '0'
	and a.rsp_code_req = '00'
	and a.datetime_req >= @StartDate
	and a.datetime_req < dateadd(dd,1,@EndDate)
	and a.abort_rsp_code is not null
	and a.sink_node_name = @SinkNode

	SELECT		c.pan,
			t.from_account_id,
			t.to_account_id,
			convert(char, t.datetime_req, 109) as Tran_Date,
			c.terminal_id,
			c.card_acceptor_id_code,
			c.card_acceptor_name_loc, 
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description, 
			t.retrieval_reference_nr, 			
			
			dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount,
			dbo.currencyAlphaCode(t.tran_currency_code) AS tran_currency_alpha_code,
			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee,	
			dbo.formatAmount((t.settle_amount_req + t.settle_tran_fee_rsp), t.settle_currency_code) as Total_Impact,
			dbo.currencyAlphaCode(t.settle_currency_code) AS settle_currency_alpha_code,
			dbo.formatRspCodeStr(t.rsp_code_rsp) AS Response_Code_description,
			auth_id_rsp AS Auth_Id,
			system_trace_audit_nr as stan,
			t.tran_nr,
			t.post_tran_cust_id
			
						
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			join #aborted a (nolock) on (a.post_tran_cust_id = c.post_tran_cust_id)



	where t.message_type = '0220' 
	and t.tran_postilion_originated = 0

	order by t.datetime_req
END







