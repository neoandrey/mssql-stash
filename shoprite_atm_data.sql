

DECLARE @start_date DATETIME;
DECLARE @end_date DATETIME;
DECLARE @date_cursor DATETIME;

SET @start_date ='2014-04-01'
SET @end_date = GETDATE();
SET @date_cursor = DATEADD(D,1, DATEDIFF(D, 0,@start_date))
DROP TABLE #merchant_transaction_summary 
CREATE TABLE  #merchant_transaction_summary (
  
pan    VARCHAR(20),
terminal_id VARCHAR(30),
sink_node_name VARCHAR(30),
source_node_name VARCHAR(30),
card_acceptor_id_code VARCHAR(50),
card_acceptor_name_loc VARCHAR(250),
volume BIGINT,
value_requested NUMERIC (20,2),
value_responsed NUMERIC (20,2)


)


WHILE (@date_cursor <=@end_date)BEGIN

INSERT INTO   #merchant_transaction_summary(
pan ,
terminal_id,
sink_node_name,
source_node_name ,
card_acceptor_id_code,
card_acceptor_name_loc,
volume,
value_requested,
value_responsed 
)
SELECT 
pan, 
terminal_id,
sink_node_name, 
source_node_name, 
card_acceptor_id_code,
card_acceptor_name_loc,
COUNT(pan) AS volume,
SUM(tran_amount_req) AS   value_requested,
SUM(tran_amount_req) AS   value_responded
FROM 
dbo.isw_data_megaoffice
WHERE 
 terminal_id IN  (
'10321274'
,'10582613'
,'10717110'
,'17016023'
,'10321274'
,'10331716'
,'190177'
,'10321272'
,'10321273'
,'10331178'
,'10331717'
,'151466'
,'17016024'
,'10500046'
,'17016025' 
   )
   AND 

   datetime_req >= @start_date AND datetime_req <=@date_cursor
GROUP BY
pan,
terminal_id,
sink_node_name,
source_node_name ,
card_acceptor_id_code,
card_acceptor_name_loc,
tran_amount_req,
tran_amount_rsp

set @start_date =@date_cursor
SET @date_cursor = DATEADD(D,1, DATEDIFF(D, 0,@start_date))

END

SELECT * FROM  #merchant_transaction_summary;
