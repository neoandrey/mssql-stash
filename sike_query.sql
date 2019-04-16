DECLARE @startdate DATETIME
DECLARE @enddate DATETIME

SET @startdate = dbo.dateOnly(GETDATE())-1
SET @enddate = dbo.dateOnly(GETDATE())

/*this is a temporay table to hold all the payment item ids that currently use a flat fee*/
DECLARE @temp_table TABLE(
payment_item_id BIGINT
)

              INSERT INTO @temp_table
              SELECT i.payment_item_id FROM
              (SELECT  productID FROM [paydirect_core].[dbo].[products] pp (NOLOCK) WHERE product_parent_id IN (8,9)) p 
              JOIN 
			  (SELECT item_product_id, payment_item_id,item_fees_id FROM [paydirect_core].[dbo].[tbl_payment_items] ii (NOLOCK)  ) i 
			  ON p.productID = i.item_product_id
			  JOIN 
			  (SELECT  fees_id FROM [paydirect_core].[dbo].[tbl_fees] ff (nolock) WHERE uses_percentage = 0  )f
			   ON i.item_fees_id = f.fees_id

SELECT *
FROM 
( SELECT * FROM [paydirect_channels].[dbo].[tbl_settlement] st1  (NOLOCK)WHERE settlement_date between @startdate and @enddate) st 
INNER JOIN
 (SELECT * FROM  [paydirect_channels].[dbo].[tbl_payments_log] pg1 (NOLOCK) WHERE payment_item_id IN (SELECT payment_item_id FROM @temp_table))pg
ON st.settlement_id=pg.payment_log_id
 
