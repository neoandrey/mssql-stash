SELECT * FROM post_tran trans (nolock)
       JOIN post_tran_cust cust (nolock) 
       ON trans.post_tran_cust_id =cust.post_tran_cust_id 
WHERE 
cust.pan ='506117*********2376' 
AND
trans.retrieval_reference_nr= '000092515543'
AND
trans.datetime_req  >= '2013-12-18'
AND
cust.terminal_id = '10324532'
