SELECT MIN(datetime_req) AS FIRST_DAY, MAX(datetime_req) AS LAST_DAY , DATEDIFF(DAY, MIN(datetime_req), MAX(datetime_req)) AS NUMBER_OF_DAYS_STORED FROM post_tran WITH (NOLOCK)
