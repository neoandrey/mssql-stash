select transaction_id, terminal_id,ltrim( rtrim(postilion_ref_id)),subscriber_msisdn, host_sequence_nr,req_datetime,txn_value,e_product_data,postilion_response_code,vtu_response_code,prev_postilion_response_code
--* 
from tbl_transactions_20170415(nolock) 
where req_datetime between '2017-04-01' and '2017-04-24' 
and product_code in ('6280515024601','6280515024602')
--and postilion_response_code in ('00') 
--and payment_reference is NULL
and postilion_ref_id in ('1710239909','1710339052')



select transaction_id, terminal_id,ltrim( rtrim(postilion_ref_id)),subscriber_msisdn, host_sequence_nr,req_datetime,txn_value,e_product_data,postilion_response_code,vtu_response_code,prev_postilion_response_code
--* 
from tbl_transactions (nolock) 
where req_datetime between '2017-04-01' and '2017-04-24' 
and product_code in ('6280515024601','6280515024602')
--and postilion_response_code in ('00') 
--and payment_reference is NULL
and postilion_ref_id in ('1710239909','1710339052')
and 
vtu_response_code is null  





SELECT t1.transaction_id,  t2.terminal_id,ltrim( rtrim( t2.postilion_ref_id)) postilion_ref_id, t2.subscriber_msisdn,  t2.host_sequence_nr, t2.req_datetime, t2.txn_value,
 t2.e_product_data, t2.postilion_response_code, t2.vtu_response_code, t2.prev_postilion_response_code 
INTO transactions_with_discrepancies FROM   VTUCARE.DBO.tbl_transactions t1 (NOLOCK)
 JOIN 
VTUCARE.DBO.tbl_transactions_20170415 t2 (nolock) 
 ON  t1.transaction_id = t2.transaction_id and  (t1.vtu_response_code is null   and t2.vtu_response_code is not null)

 


 
DECLARE @transaction_id BIGINT
DECLARE @terminal_id  VARCHAR(50)
DECLARE @postilion_ref_id VARCHAR(50)
DECLARE @subscriber_msisdn VARCHAR(50)
DECLARE @host_sequence_nr  VARCHAR(100)
DECLARE @e_product_data VARCHAR(250)
DECLARE @postilion_response_code  VARCHAR(2)
DECLARE @vtu_response_code VARCHAR(2)
DECLARE @prev_postilion_response_code VARCHAR(2)

DECLARE transaction_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR  SELECT transaction_id, terminal_id, postilion_ref_id, subscriber_msisdn, host_sequence_nr, 
e_product_data,postilion_response_code, vtu_response_code,prev_postilion_response_code from transactions_with_discrepancies
open  transaction_cursor
FETCH NEXT FROM transaction_cursor INTO @transaction_id, @terminal_id, @postilion_ref_id, @subscriber_msisdn,@host_sequence_nr, @e_product_data,@postilion_response_code, @vtu_response_code,@prev_postilion_response_code
WHILE (@@FETCH_STATUS = 0 )BEGIN

UPDATE tbl_transactions
  SET     subscriber_msisdn =@subscriber_msisdn, host_sequence_nr=@host_sequence_nr, 
  e_product_data=@e_product_data,postilion_response_code=@postilion_response_code, vtu_response_code=@vtu_response_code,
  prev_postilion_response_code=@prev_postilion_response_code
WHERE 
transaction_id = @transaction_id
FETCH NEXT FROM transaction_cursor INTO @transaction_id, @terminal_id, @postilion_ref_id, @subscriber_msisdn,@host_sequence_nr, @e_product_data,@postilion_response_code, @vtu_response_code,@prev_postilion_response_code
END
CLOSE transaction_cursor
DEALLOCATE transaction_cursor
 

