SELECT * FROM settlement_summary_session  ORDER BY Business_Date DESC
DELETE FROM settlement_summary_session where Business_Date =''

SELECT * FROM settlement_summary_breakdown WHERE trxn_date = ''
delete  FROM settlement_summary_breakdown WHERE trxn_date = ''


SELECT * FROM settlement_summary_session WHERE Business_Date LIKE '%SEP%2017%'  ORDER BY Business_Date DESC
DELETE FROM settlement_summary_session where Business_Date ='Sep  8 2017 12:00AM'

SELECT * FROM settlement_summary_breakdown WHERE trxn_date = '20170908' AND trxn_category NOT LIKE '%REWARD%'
delete  FROM settlement_summary_breakdown WHERE trxn_date = '20170908' AND trxn_category NOT LIKE '%REWARD%'