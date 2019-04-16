CREATE                                  PROCEDURE [dbo].[usp_rpt_card_statement_1]    
 @fullPAN  VARCHAR(19)    
 
    
AS    
BEGIN    
    
    DECLARE @report_date_start DATETIME
	DECLARE @report_date_end   DATETIME
	DECLARE @StartDate DATETIME
	DECLARE @EndDate   DATETIME

	
	SELECT  @StartDate = ISNULL(@StartDate, MIN(datetime_req)) FROM  post_tran (NOLOCK);
	SELECT @EndDate = ISNULL(@EndDate, MAX(datetime_req)) FROM  post_tran (NOLOCK);
	
	SET @report_date_start =   REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @StartDate),111),'/', '') 
	SET @report_date_end=  REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @EndDate),111),'/', '') 
	

	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT
	
create table #statement    
	(row bigint,    
	pan varchar(20),    
	datetimelocal datetime,    
	datetime_req datetime,    
	tran_type_description varchar (50),    
	card_acceptor_id_code varchar (20),    
	card_acceptor_name_loc varchar (50),    
	retrieval_reference_nr varchar (50),    
	auth_id varchar(6),    
	tran_amount numeric(18,2),    
	tran_currency_alpha_code varchar (3),    
	settle_amount numeric(18,2),    
	settle_tran_fee numeric(18,2),    
	total_impact  numeric (18,2),    
	settle_currency_alpha_code varchar (3)    
)    
    
    
    
    
insert into #statement    
    
SELECT  ROW_NUMBER() OVER(ORDER BY datetime_req) AS Row,     
    dbo.usf_decrypt_pan(pan, pan_encrypted)  pan,    
   t.datetime_tran_local,    
   --c.terminal_id,    
   t.datetime_req,    
   dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,    
   c.card_acceptor_id_code,    
   c.card_acceptor_name_loc,     
   t.retrieval_reference_nr,        
   auth_id_rsp as auth_id,    
   dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount,    
   dbo.currencyAlphaCode(t.tran_currency_code) AS tran_currency_alpha_code,    
   dbo.formatAmount(-1 * t.settle_amount_impact, t.settle_currency_code) AS settle_amount,    
       
   dbo.formatAmount(-1*t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee,     
   dbo.formatAmount((t.settle_amount_impact + t.settle_tran_fee_rsp), t.settle_currency_code) as Total_Impact,    
            
   dbo.currencyAlphaCode(t.settle_currency_code) AS settle_currency_alpha_code    
   --t.from_account_id,    
   --dbo.rpt_fxn_account_type(t.from_account_type) AS from_account_type,    
   --t.to_account_id,    
   --dbo.rpt_fxn_account_type(t.to_account_type) AS to_account_type,    
   --c.post_tran_cust_id,    
   --c.source_node_name,    
   --t.sink_node_name,    
   --rsp_code_rsp,    
   --acquiring_inst_id_code,    
   --terminal_owner,    
   --payee,    
                       -- system_trace_audit_nr as stan    
   --(select sum(settle_amount_impact) from post_tran r(nolock) where r.datetime_tran_local <= t.datetime_tran_local) as balance    
          
 FROM    
   post_tran t (NOLOCK)    
   INNER JOIN     
   post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)    
    
 WHERE   (
                         (	LEFT(c.pan,6) = LEFT(@fullpan,6) AND  RIGHT (@fullpan,4) = RIGHT (c.pan,4))  OR  c.pan = @fullpan
 
 )
   AND (t.from_account_id = @fullpan or t.to_account_id = @fullpan)    

                        and t.tran_completed = 1    
                        AND
                        	(t.post_tran_id >= @first_post_tran_id) 
	AND 
	(t.post_tran_id <= @last_post_tran_id)
	AND datetime_req >=  @report_date_start
  
   AND  t.tran_postilion_originated = 1    

   AND (t.message_type IN ('0200','0220','0420') )--AND t.tran_reversed IN ('0', '1')    
       
   --AND t.tran_type IN ('00', '01', '09', '20', '21', '40', '50','22','02' )    
   AND t.rsp_code_rsp IN ('00', '11')    
 ORDER BY     
   t.datetime_req --desc    
   
   delete from #statement where pan <> @fullpan
    
    
select pan, datetimelocal,datetime_req,tran_type_description,card_acceptor_id_code,card_acceptor_name_loc,retrieval_reference_nr,auth_id,tran_amount,tran_currency_alpha_code,settle_amount,settle_tran_fee,total_impact,settle_currency_alpha_code,(select sum
  
(total_impact) from #statement r(nolock) where r.row <= e.row) as Balance    
    
    
from #statement e    
    
END    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  