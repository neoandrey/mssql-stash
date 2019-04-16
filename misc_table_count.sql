SELECT  'tbl_merchant_account', count= COUNT(*) FROM tbl_merchant_account (nolock)
union
SELECT 'NIBSS_T1_Returns_table', count=COUNT(*) FROM NIBSS_T1_Returns_table(nolock)
union
SELECT 'NIBSS_T1_Paid_table', count=COUNT(*) FROM NIBSS_T1_Paid_table(nolock)
