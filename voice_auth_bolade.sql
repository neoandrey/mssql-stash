SELECT
	CONVERT(CHAR(8), datetime_req, 112) as Month,
	source_bank as Acquirer,
	count(*) as volume

				
	FROM
				isw_data_megaoffice_201502 t (NOLOCK) join isw_source_nodes isn (nolock)
				on t.source_node_name = isn.source_node
				
	WHERE 			
			
				(t.datetime_req >= '20150201')
				AND
				(t.datetime_req < '20150301')
			AND
			t.message_type = '0220'---eseosa
			AND
			t.tran_completed = 1
			and t.rsp_code_rsp = '00'  ---eseosa
			and t.pos_entry_mode in ('010','000')--eseosa
			and t.tran_reversed = '0' --eseosa
	
	group by CONVERT(CHAR(8), datetime_req, 112),source_bank