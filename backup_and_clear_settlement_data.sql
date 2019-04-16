
SELECT *  INTO settlement_summary_breakdown_20161102 FROM settlement_summary_breakdown (NOLOCK)
 WHERE trxn_date = '20161103' 
AND trxn_category NOT LIKE '%reward%'

select * from settlement_summary_session (NOLOCK) where Business_Date like  '%nov%'




DELETE FROM settlement_summary_breakdown  WHERE trxn_date = '20161102' 
AND trxn_category NOT LIKE '%reward%'

DELETE FROM 
settlement_summary_session  where Business_Date =
'Nov  2 2016 12:00AM'

SELECT * FROM tbl_wpos_acq_nibss_ceaser