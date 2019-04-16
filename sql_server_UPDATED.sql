DECLARE @startdate datetime
  DECLARE @enddate datetime
	
  SET @startdate = dbo.dateonly(getdate())
  SET @enddate = dbo.dateonly(getdate())+1
  
  DECLARE @transaction_table  (
   product_name VARCHAR(500),
   subscriber_msisdn VARCHAR(500),
   stan VARCHAR(500),
   pan VARCHAR(500),
   req_datetime VARCHAR(500),
   terminal_id VARCHAR(500),
   customer_account_no VARCHAR(500),
   postilion_ref_id VARCHAR(500),
   txn_value VARCHAR(500),
   postilion_response_code VARCHAR(500),
   location VARCHAR(500),
    settlement_date VARCHAR(500)
  
  
  )

insert @transaction_table
  SELECT p.product_name as 'Product',
         t.subscriber_msisdn as 'Subscriber',
	     t.stan as 'STAN',
		 t.pan as 'PAN',
		 t.req_datetime as 'Date',
		 t.terminal_id as 'TerminalID',
		 t.customer_account_no as 'AccountNo',
		 t.postilion_ref_id as 'RetrievalRefNum',
		 t.txn_value as 'Amount',
		 t.postilion_response_code as 'ResponseCode',
		 t.location as 'Narration',
		 t.settlement_date as 'SettlementDate',
                                      t.issuer_domain_id as 'Bank'
  FROM [Vtu_ReadOnly].[vtucare].[dbo].[tbl_settlement] s (nolock) 
  INNER JOIN [Vtu_ReadOnly].[vtucare].[dbo].[tbl_transactions] t(nolock)
  ON s.transaction_id = t.transaction_id  
  INNER JOIN [Vtu_ReadOnly].[vtucare].[dbo].tbl_products p (nolock)
  ON t.product_code = p.product_code
  WHERE s.settlement_date >= @startdate and s.settlement_date < @enddate
  AND t.issuer_domain_id in (16,18,20,30,17,27)
 -- GROUP BY p.product_name, t.subscriber_msisdn, t.stan, t.pan, t.req_datetime, t.terminal_id, 
 -- t.postilion_ref_id, t.txn_value,t.postilion_response_code, t.location,t.settlement_date,t.alt_ref,t.customer_account_no, t.issuer_domain_id
  ORDER BY t.req_datetime
  
  SELECT DISTINCT * FROM @transaction_table