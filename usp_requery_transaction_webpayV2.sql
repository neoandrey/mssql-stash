USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_requery_transaction_webpay]    Script Date: 08/31/2016 12:52:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_requery_transaction_webpayV2]
       @transaction_reference_bank_details VARCHAR(1000)
AS
                        
       SET NOCOUNT ON
       SET  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        
       DECLARE  @transaction_reference VARCHAR(1000)
       SET @transaction_reference =  (SELECT REPLACE(@transaction_reference_bank_details,'|','-'))  
               
       SELECT                 post_tran_id
                             ,rsp_code_rsp
                             ,retrieval_reference_nr 
                             
                             ,tran_amount_rsp 
                             ,tran_reversed
                             ,dbo.usf_decrypt_pan(pan,pan_encrypted) pan
                             ,system_trace_audit_nr stan
                             ,bank_details
                             ,datetime_tran_local
       FROM
        post_tran trans (nolock, INDEX(idx_bank_details)) 
        JOIN post_tran_cust cst (NOLOCK, INDEX(pk_post_tran_cust)) ON
        trans.post_tran_cust_id  =cst.post_tran_cust_id
       WHERE
        bank_details = @transaction_reference 
       AND tran_postilion_originated = 0 
       AND message_type = '0200'
       OPTION (recompile)
