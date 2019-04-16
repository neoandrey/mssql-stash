CREATE TRIGGER  [trig_migs_transaction_struct_data_res] on post_tran_cust
INSTEAD OF INSERT 
AS 
BEGIN
IF  EXISTS(SELECT * FROM  INSERTED  WHERE  CHARINDEX('MIGS', source_node_name)>0) BEGIN
  IF  EXISTS(SELECT post_tran_cust_id FROM  post_tran   WITH (NOLOCK) WHERE  post_tran_cust_id IN  (SELECT  post_tran_cust_id FROM  inserted) ) BEGIN
     
     
       UPDATE post_tran SET  t.structured_data_rsp  = t.structured_data_req
       
       FROM  post_tran t JOIN  
       
       inserted i  ON
       i.post_tran_cust_id = t.post_tran_cust_id
       AND t.structured_data_req IS NOT  NULL
       
    END
	
END
	INSERT INTO  post_tran_cust SELECT * FROM inserted  
END 