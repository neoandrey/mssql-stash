 SELECT TOP 100  * FROM  
 
 (SELECT * FROM post_tran t with (NOLOCK, INDEX(ix_post_tran_9)) join
 (SELECT [DATE] rec_business_date  FROM dbo.get_dates_in_range('20161012','20161012'))r
 on
 r.rec_business_date = t.recon_business_date
  JOIN 
 ( SELECT * FROM post_tran_cust (NOLOCK) where   
   card_acceptor_id_code like '%IS' and  card_acceptor_name_loc like 'CO;%') c (NOLOCK)
 on
 t.post_tran_cust_id = c.post_tran_cust_id
 and  CHARINDEX('bufferc', convert(varchar(max), structured_data_rsp)) >0  
 and tran_postilion_originated  = 0
 AND  SUBSTRING(structured_data_rsp, CHARINDEX('BufferC>',structured_data_rsp)+8, CHARINDEX('</BufferC>',structured_data_rsp)
  -(CHARINDEX('BufferC>',structured_data_rsp)+8)) 
 
 ='12608122781' 
 
 )
 t

  

