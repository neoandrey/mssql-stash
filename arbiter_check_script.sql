SELECT  convert(date, datetime_req ) tran_day, issuer_code,  tran_type_description, COUNT(*) tran_count FROM  tbl_postilion_office_transactions_staging (NOLOCK) WHERE CONVERT(date, datetime_req) >= '20170901'
group by   convert(date, datetime_req ), issuer_code,  tran_type_description
order by   convert(date, datetime_req )