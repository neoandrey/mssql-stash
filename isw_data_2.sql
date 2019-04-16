use isw_data
go
/****** Object:  UserDefinedFunction [dbo].[currencyAlphaCode]    Script Date: 11/21/2014 09:11:59 ******/


CREATE  FUNCTION  [dbo].[currencyAlphaCode] (@currency_code CHAR (3))
RETURNS CHAR (3)
AS
BEGIN
	IF (@currency_code IS NULL)
	BEGIN
		SET @currency_code = '840'
	END

	IF (@currency_code = '000')
	BEGIN
		SET @currency_code = '840'
	END	


	DECLARE @c CHAR (3)
	
	SELECT @c = alpha_code
	FROM
		post_currencies WITH (NOLOCK)
	WHERE		
		currency_code = @currency_code

	IF (@c IS NULL)
	BEGIN
		SET @c = '???'
	END
	
	RETURN @c
END


GO

USE [isw_data]
GO



CREATE  FUNCTION  [dbo].[formatAmount] (@amount float, @currency_code CHAR (3))
	RETURNS FLOAT
AS
BEGIN
	IF (@currency_code IS NULL)
	BEGIN
		SET @currency_code = '840'
	END
		IF (@currency_code = '000')
	BEGIN
		SET @currency_code = '840'
	END	

	DECLARE @d INT

	SELECT @d = nr_decimals
	FROM
		post_currencies (NOLOCK)
	WHERE		
		currency_code = @currency_code
	IF (@d IS NULL)
	BEGIN
		SET @d = 2
	END
	
	RETURN (CAST ( (@amount / POWER (10, @d)) AS FLOAT))
END

/****** Object:  UserDefinedFunction [dbo].[formatRspCodeStr]    Script Date: 11/21/2014 09:18:57 ******/

go

CREATE FUNCTION [dbo].[formatRspCodeStr] (	@rsp_code CHAR (2))
RETURNS VARCHAR (30)
AS
BEGIN
		DECLARE @s		VARCHAR (30)
			
		SELECT @s =
				CASE
					WHEN @rsp_code = '00' THEN 'Approved'
					WHEN @rsp_code = '01' THEN 'Refer to card issuer'
					WHEN @rsp_code = '02' THEN 'Refer to card issuer, special condition'
					WHEN @rsp_code = '03' THEN 'Invalid merchant'
					WHEN @rsp_code = '04' THEN 'Pick-up card'
					WHEN @rsp_code = '05' THEN 'Do not honor'
					WHEN @rsp_code = '06' THEN 'Error'
					WHEN @rsp_code = '07' THEN 'Pick-up card, special condition'
					WHEN @rsp_code = '08' THEN 'Honor with identification'
					WHEN @rsp_code = '09' THEN 'Request in progress'
			
					WHEN @rsp_code = '10' THEN 'Approved, partial'
					WHEN @rsp_code = '11' THEN 'Approved, VIP'
					WHEN @rsp_code = '12' THEN 'Invalid transaction'
					WHEN @rsp_code = '13' THEN 'Invalid amount'
					WHEN @rsp_code = '14' THEN 'Invalid card number'
					WHEN @rsp_code = '15' THEN 'No such issuer'
					WHEN @rsp_code = '16' THEN 'Approved, update track 3'
					WHEN @rsp_code = '17' THEN 'Customer cancellation'
					WHEN @rsp_code = '18' THEN 'Customer dispute'
					WHEN @rsp_code = '19' THEN 'Re-enter transaction'
			
					WHEN @rsp_code = '20' THEN 'Invalid response'
					WHEN @rsp_code = '21' THEN 'No action taken'
					WHEN @rsp_code = '22' THEN 'Suspected malfunction'
					WHEN @rsp_code = '23' THEN 'Unacceptable transaction fee'
					WHEN @rsp_code = '24' THEN 'File update not supported'
					WHEN @rsp_code = '25' THEN 'Unable to locate record'
					WHEN @rsp_code = '26' THEN 'Duplicate record'
					WHEN @rsp_code = '27' THEN 'File update field edit error'
					WHEN @rsp_code = '28' THEN 'File update file locked'
					WHEN @rsp_code = '29' THEN 'File update failed'
			
					WHEN @rsp_code = '30' THEN 'Format error'
					WHEN @rsp_code = '31' THEN 'Bank not supported'
					WHEN @rsp_code = '32' THEN 'Completed partially'
					WHEN @rsp_code = '33' THEN 'Expired card, pick-up'
					WHEN @rsp_code = '34' THEN 'Suspected fraud, pick-up'
					WHEN @rsp_code = '35' THEN 'Contact acquirer, pick-up'
					WHEN @rsp_code = '36' THEN 'Restricted card, pick-up'
					WHEN @rsp_code = '37' THEN 'Call acquirer security, pick-up'
					WHEN @rsp_code = '38' THEN 'PIN tries exceeded, pick-up'
					WHEN @rsp_code = '39' THEN 'No credit account'
			
					WHEN @rsp_code = '40' THEN 'Function not supported'
					WHEN @rsp_code = '41' THEN 'Lost card, pick-up'
					WHEN @rsp_code = '42' THEN 'No universal account'
					WHEN @rsp_code = '43' THEN 'Stolen card, pick-up'
					WHEN @rsp_code = '44' THEN 'No investment account'
					WHEN @rsp_code = '45' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '46' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '47' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '48' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '49' THEN 'Reserved for future Postilion use'
			
					WHEN @rsp_code = '50' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '51' THEN 'Not sufficient funds'
					WHEN @rsp_code = '52' THEN 'No check account'
					WHEN @rsp_code = '53' THEN 'No savings account'
					WHEN @rsp_code = '54' THEN 'Expired card'
					WHEN @rsp_code = '55' THEN 'Incorrect PIN'
					WHEN @rsp_code = '56' THEN 'No card record'
					WHEN @rsp_code = '57' THEN 'Transaction not permitted to cardholder'
					WHEN @rsp_code = '58' THEN 'Transaction not permitted on terminal'
					WHEN @rsp_code = '59' THEN 'Suspected fraud'
			
					WHEN @rsp_code = '60' THEN 'Contact acquirer'
					WHEN @rsp_code = '61' THEN 'Exceeds withdrawal limit'
					WHEN @rsp_code = '62' THEN 'Restricted card'
					WHEN @rsp_code = '63' THEN 'Security violation'
					WHEN @rsp_code = '64' THEN 'Original amount incorrect'
					WHEN @rsp_code = '65' THEN 'Exceeds withdrawal frequency'
					WHEN @rsp_code = '66' THEN 'Call acquirer security'
					WHEN @rsp_code = '67' THEN 'Hard capture'
					WHEN @rsp_code = '68' THEN 'Response received too late'
					WHEN @rsp_code = '69' THEN 'Reserved for future Postilion use'
			
					WHEN @rsp_code = '70' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '71' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '72' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '73' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '74' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '75' THEN 'PIN tries exceeded'
					WHEN @rsp_code = '76' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '77' THEN 'Intervene, bank approval required'
					WHEN @rsp_code = '78' THEN 'Intervene, bank approval required for partial amount'
					WHEN @rsp_code = '79' THEN 'Reserved for client-specific use (declined)'
			
					WHEN @rsp_code = '80' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '81' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '82' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '83' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '84' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '85' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '86' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '87' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '88' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '89' THEN 'Reserved for client-specific use (declined)'
			
					WHEN @rsp_code = '90' THEN 'Cut-off in progress'
					WHEN @rsp_code = '91' THEN 'Issuer or switch inoperative'
					WHEN @rsp_code = '92' THEN 'Routing error'
					WHEN @rsp_code = '93' THEN 'Violation of law'
					WHEN @rsp_code = '94' THEN 'Duplicate transaction'
					WHEN @rsp_code = '95' THEN 'Reconcile error'
					WHEN @rsp_code = '96' THEN 'System malfunction'
					WHEN @rsp_code = '97' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '98' THEN 'Exceeds cash limit'
					WHEN @rsp_code = '99' THEN 'Reserved for future Postilion use'
			
					WHEN @rsp_code BETWEEN '0A' AND 'A0' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'A1' THEN 'ATC not incremented'
					WHEN @rsp_code = 'A2' THEN 'ATC limit exceeded'
					WHEN @rsp_code = 'A3' THEN 'ATC configuration error'
					WHEN @rsp_code = 'A4' THEN 'CVR check failure'
					WHEN @rsp_code = 'A5' THEN 'CVR configuration error'
					WHEN @rsp_code = 'A6' THEN 'TVR check failure'
					WHEN @rsp_code = 'A7' THEN 'TVR configuration error'
			
					WHEN @rsp_code BETWEEN 'A8' AND 'BZ' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'C0' THEN 'Unacceptable PIN'
					WHEN @rsp_code = 'C1' THEN 'PIN Change failed'
					WHEN @rsp_code = 'C2' THEN 'PIN Unblock failed'
			
					WHEN @rsp_code BETWEEN 'C3' AND 'D0' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'D1' THEN 'MAC Error'
			
					WHEN @rsp_code BETWEEN 'D2' AND 'E0' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'E1' THEN 'Prepay error'
			
					WHEN @rsp_code BETWEEN 'E2' AND 'MZ' THEN @rsp_code+'-Reserved for future Postilion use'
					WHEN @rsp_code BETWEEN 'N0' AND 'ZZ' THEN @rsp_code+'-Reserved for client use'
			
					ELSE @rsp_code+'-Unlisted Response Code'
			
				END
		
		RETURN @s
END


GO


USE [isw_data]
GO

/****** Object:  UserDefinedFunction [dbo].[formatTranTypeStr]    Script Date: 11/21/2014 09:19:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF

go


CREATE FUNCTION [dbo].[formatTranTypeStr] (	@tran_type CHAR (2), 
										@extended_tran_type CHAR (4),
										@message_type CHAR (4))
RETURNS VARCHAR (60)
AS
BEGIN
		DECLARE @s		VARCHAR (60)			
		SET		@s 		= 	NULL
		
		DECLARE @msg VARCHAR (15)
		SET @msg = ''
		
		IF (@message_type IN ('0100', '0120'))
			SET @msg = ' (Auth)'
			
		IF (@message_type IN ('0400', '0420'))
			SET @msg = ' (Rev)'
		
		
		IF (@tran_type NOT IN ('12', '25', '32', '42', '52', '91'))
		BEGIN
		
			-- Transaction type which have no extended types
			
			SELECT
					@s = description
			FROM
					post_tran_types WITH (NOLOCK)
			WHERE
					code = @tran_type
					
			IF (@s IS NULL)
				SET @s = 'Unknown'
			
			RETURN (@s + @msg)
		END
		
		IF (@tran_type = '91')
		BEGIN
			SELECT
					@s = description
			FROM
					post_tran_types WITH (NOLOCK)
			WHERE
					code = @extended_tran_type
					
			IF (@s IS NULL)
				SET @s = 'General Admin'
			
			RETURN (@s + @msg)
		END
		
		
		DECLARE @s2		VARCHAR (60)			
		SET		@s2 		= 	NULL
		
		
		
		SELECT
				@s = description
		FROM
				post_tran_types WITH (NOLOCK)
		WHERE
				code = @tran_type
				
		
				
		SELECT
				@s2 = description
		FROM
				post_tran_types WITH (NOLOCK)
		WHERE
				code = @extended_tran_type
				
		
		
		IF (@s IS NULL)
		BEGIN
			SET @s = 'Unknown'
		END
		
		IF (@s2 IS NULL)
		BEGIN
			RETURN @s 
		END
		ELSE
		BEGIN
			RETURN (@s + ' - ' + @s2 + @msg)
		END
		
		RETURN NULL		
END


GO

/****** Object:  View [dbo].[all_channels_Nov_14]    Script Date: 11/14/2014 12:31:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[all_channels_Nov_14] as 
select * from  ALL_channels_data (nolock)
where MONTH ='201409'
GO
/****** Object:  View [dbo].[home_depot]    Script Date: 11/14/2014 12:31:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[home_depot] as 

Select 
    pt.pan,
    from_account_id,
    to_account_id,
	pt.terminal_id,
	pt.card_acceptor_id_code,
	pt.card_acceptor_name_loc,
  	pt.message_type,
	pt.datetime_req,
	pt.system_trace_audit_nr,
	pt.retrieval_reference_nr,
	pt.tran_amount_req/100 as tran_amount,
	dbo.currencyAlphaCode(pt.tran_currency_code) as tran_currency,
	dbo.formatTranTypeStr(pt.tran_type, pt.extended_tran_type, pt.message_type) AS tran_type_description,
	dbo.formatRspCodeStr(pt.rsp_code_rsp) AS Response_Code_description,
	pt.settle_amount_rsp/100 as settle_amount,
	pt.settle_amount_impact/100 as settle_amount_Impact,
	dbo.currencyAlphaCode(pt.settle_currency_code) as settle_currency,
	pt.auth_id_rsp,
	pt.post_tran_cust_id,
	pt.sink_node_name,
	pt.source_node_name,
	pt.acquiring_inst_id_code,
	merchant_type,
	totals_bank
    
 
from isw_data_megaoffice pt (nolock)
left outer join isw_mega_totals_groups imt(nolock)
on pt.totals_group = imt.totals_group
where card_acceptor_name_loc like '%THE HOME DEPOT%'

--and sink_node_name like 'MEG%'
GO
