	FROM
			 (
			 SELECT * FROM post_tran_summary pt JOIN
			 (SELECT [DATE]rec_bus_date FROM dbo.get_dates_in_range(@report_date_start,@report_date_end))r
			ON   pt.recon_business_date = r.rec_bus_date
			 )	t		
			
	
WHERE 			
	
-
			t.tran_completed = 1
			  AND
			  post_tran_id NOT IN (
				SELECT tbl.post_tran_id FROM tbl_late_reversals tbl (NOLOCK) JOIN
				post_tran_summary pts ON tbl.recon_business_date >= @report_date_start 
				AND
				tbl.tran_nr  = pts.tran_nr 
				 AND
				 datepart(D,tbl.rev_datetime_req) - datepart(D, tbl.trans_datetime_req )>1

				 AND 
				 tbl.retrieval_reference_nr =   pts.retrieval_reference_nr

			  ) 
	
			AND
			t.tran_postilion_originated = 0