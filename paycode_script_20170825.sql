
SELECT top  100 card_acceptor_name_loc, structured_data_req, CONVERT( XML,  REPLACE(SUBSTRING(CONVERT(VARCHAR(MAX),structured_data_req), CHARINDEX('<', CONVERT(VARCHAR(MAX),structured_data_req)), LEN(CONVERT(VARCHAR(MAX),structured_data_req)) ),';','')
  ).value('(//*/BufferC)[1]', 'VARCHAR(MAX)') paycode ,  * from 
post_tran  t with (NOLOCK,index(IX_POST_TRAN_9)) join
 (SELECT [DATE] rec_business_date  FROM dbo.get_dates_in_range('20170812','20170812'))r
 on
 r.rec_business_date = t.recon_business_date
 and  CONVERT(VARCHAR(MAX),structured_data_req) LIKE '%BufferC%'


  JOIN post_tran_cust c WITH (nolock)
  on
  t.post_tran_cust_id = c.post_tran_cust_id