USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[check_atm_transfer_anomalies]    Script Date: 06/03/2014 15:35:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[check_atm_transfer_anomalies]  @start_date DATETIME, @end_date DATETIME

AS

BEGIN

SELECT @start_date = ISNULL(@start_date, GETDATE());
SELECT @end_date = ISNULL(@end_date, DATEADD(D,1, GETDATE()));

IF (DATEDIFF(D,@start_date,  @end_date)=0)
BEGIN
SELECT @end_date=  DATEADD(D,1, GETDATE());
END

IF (DATEDIFF(D,@start_date,@end_date )>1) BEGIN

	DECLARE @date_cursor DATETIME;

	SET @date_cursor = DATEADD(D, 1,@start_date);
	WHILE (@date_cursor <=@end_date) 

		BEGIN
			SELECT

				datetime_req,
				pan,
				from_account_id,
				to_account_id,
				source_node_name,
				sink_node_name,
				terminal_id,	
				card_acceptor_name_loc,
				system_trace_audit_nr,
				rsp_code_req,rsp_code_rsp,
				tran_type,
				message_type,
				dbo.formatAmount(trans.settle_amount_impact, trans.settle_currency_code) AS settle_amount,
				dbo.formatAmount(trans.settle_tran_fee_rsp, trans.settle_currency_code) AS settle_tran_fee,
				SUM(settle_amount_impact) AS total_settle_amount,
				COUNT(tran_nr) AS number_of_transaction,
				COUNT(terminal_id) AS number_of_terminals,
				CASE WHEN COUNT(pan)>1 THEN 'Transaction Frequency Breach'
				WHEN SUM(settle_amount_impact)>=200000 THEN 'Transaction Amount Breach'
				WHEN  COUNT(terminal_id)>1  THEN 'Terminal Location Breach'
				END  AS 'Breach_Type'
			FROM  
			 post_tran trans (NOLOCK)
			JOIN
			 post_tran_cust cust (NOLOCK)
			 ON
			 trans.post_tran_cust_id=cust.post_tran_cust_id
			WHERE
			LEFT(source_node_name,3) = 'TSS'
			AND 
			LEFT(terminal_id,1)  = '1'
			AND 
			datetime_req >= @start_date
			AND 
			datetime_req <=@date_cursor
			GROUP BY
				datetime_req,
				pan,
				from_account_id,
				to_account_id,
				source_node_name,
				sink_node_name,
				terminal_id,	
				card_acceptor_name_loc,
				system_trace_audit_nr,
				rsp_code_req,rsp_code_rsp,
				tran_type,
				message_type,
				trans.settle_currency_code,
				trans.settle_amount_impact,
				trans.settle_currency_code,
				trans.settle_tran_fee_rsp
			HAVING 
			SUM(settle_amount_impact)>=200000
			OR 
	        COUNT(tran_nr)>1  AND ABS(DATEDIFF(hour, CAST(AVG(CAST(datetime_req AS FLOAT)) AS datetime), MAX(datetime_req)))>=1
			OR
			COUNT(terminal_id)>1


		SET @start_date = @date_cursor;

		SET @date_cursor = DATEADD(D, 1,@start_date);
		END
END
   ELSE 
			 BEGIN
		SELECT

			datetime_req,
			pan,
			from_account_id,
			to_account_id,
			source_node_name,
			sink_node_name,
			terminal_id,	
			card_acceptor_name_loc,
			system_trace_audit_nr,
			rsp_code_req,rsp_code_rsp,
			tran_type,
			message_type,
				dbo.formatAmount(trans.settle_amount_impact, trans.settle_currency_code) AS settle_amount,
			dbo.formatAmount(trans.settle_tran_fee_rsp, trans.settle_currency_code) AS settle_tran_fee,
			SUM(settle_amount_impact) AS total_settle_amount,
			COUNT(tran_nr) AS number_of_transaction,
			COUNT(terminal_id) AS number_of_terminals,
			CASE WHEN COUNT(tran_nr)>1 THEN 'Transaction Frequency Breach'
			WHEN SUM(settle_amount_impact)>=200000 THEN 'Transaction Amount Breach'
			WHEN  COUNT(terminal_id)>1  THEN 'Terminal Location Breach'
			END  AS 'Breach_Type'
		FROM  
		 post_tran trans (NOLOCK)
		JOIN
		 post_tran_cust cust (NOLOCK)
		ON
		 trans.post_tran_cust_id=cust.post_tran_cust_id
		WHERE
		LEFT(source_node_name,3) = 'TSS'
		AND 
		LEFT(terminal_id,1)  = '1'
		AND 
		datetime_req >= @start_date
		AND 
		datetime_req <=@end_date
		GROUP BY
			datetime_req,
				pan,
				from_account_id,
				to_account_id,
				source_node_name,
				sink_node_name,
				terminal_id,	
				card_acceptor_name_loc,
				system_trace_audit_nr,
				rsp_code_req,rsp_code_rsp,
				tran_type,
				message_type,
				trans.settle_currency_code,
				trans.settle_amount_impact,
				trans.settle_currency_code,
				trans.settle_tran_fee_rsp
	 HAVING 
		SUM(settle_amount_impact)>=200000
		OR 
		COUNT(pan)>1  AND ABS(DATEDIFF(hour, CAST(AVG(CAST(datetime_req AS FLOAT)) AS datetime), MAX(datetime_req)))/(COUNT(pan)/2) <=1
		OR
		COUNT(terminal_id) > 1
END

END