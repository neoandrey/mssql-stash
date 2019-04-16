USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[psp_retrieve_all_extracted_transactions_pbf]    Script Date: 04/30/2015 09:18:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER   PROCEDURE [dbo].[psp_retrieve_all_extracted_transactions_pbf]
(
    @startDate datetime,
    @stopDate datetime
)
AS

BEGIN
 SELECT 
    dbo.usf_decrypt_pan(pt.pan,pt.pan_encrypted)pan , 
   pt.expiry_date, pt.terminal_id, pt.card_acceptor_id_code, p.datetime_req AS datetime_tran_local, p.tran_amount_req
  FROM post_tran_cust pt with (NOLOCK)
  join post_tran p with (NOLOCK)
  on pt.post_tran_cust_id = p.post_tran_cust_id
   join tbl_reward_OutofBand rb with (NOLOCK)
  on pt.card_acceptor_id_code = rb.Card_Acceptor_Id_Code AND pt.terminal_id = rb.terminal_id
  WHERE    p.datetime_req >= @startDate and p.datetime_req < @stopDate AND
     p.tran_completed = 1 and p.tran_postilion_originated = 1 AND
  p.message_type = '0200' and p.rsp_code_rsp = '00' and  LEFT(pt.terminal_id ,1) = '2'
END



