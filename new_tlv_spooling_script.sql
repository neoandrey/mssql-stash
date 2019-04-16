  CREATE TABLE #temp_tlv_table (pan VARCHAR(20), amount VARCHAR(30), stan VARCHAR(50), terminal_id VARCHAR(20), tran_code VARCHAR(5), message_type VARCHAR(6))


BULK
       INSERT 
           #temp_tlv_table 
           		FROM  'C:\temp\temp_tlv_table_data.csv'
   WITH (

			FIELDTERMINATOR =',',
			ROWTERMINATOR ='\n'

		)
  
  
  
  SELECT 
  '0220',
  'F0020016'+dbo.DecryptPan(c.pan,c.pan_encrypted,'cardstatement')PAN,
  'F0030006'+CONVERT(VARCHAR(25),tran_code)+'0000',
  'F0040012'+REPLICATE('0', 12-LEN(amount))+amount,
  'F0110006'+ (CASE WHEN temp.message_type='0200' THEN TEMP.stan when  temp.message_type='0100' THEN  '1'+ SUBSTRING(TEMP.stan,2, LEN(TEMP.stan))  END),
  'F0140004'+CONVERT(VARCHAR(25),c.expiry_date),
  'F01800047011',
  'F0220003000',
  'F025000200',
  'F0280009C00000000',
  'F0300009C00000000',
  'F0320006012148',
  'F0350037'+ dbo.DecryptPan(c.pan,pan_encrypted,'cardstatement')+ 'D' +c.expiry_date+c.service_restriction_code+'0000000000000',
  'F0370012'+t.retrieval_reference_nr,
  'F0380006'+CONVERT(VARCHAR(25),t.auth_id_rsp),
  'F039000200',
  'F0400003'+CONVERT(VARCHAR(25),c.service_restriction_code),
  'F0410008'+c.terminal_id,
  'F0420015'+c.card_acceptor_id_code,
  'F0430040'+c.card_acceptor_name_loc,
  'F0490003'+tran_currency_code,'F05600041510',
  'F0590010'+RIGHT ('0000000000'+CAST(retrieval_reference_nr+1 AS VARCHAR(12)), 10),
  'F09000420100'+t.system_trace_audit_nr+ substring ((select REPLACE ((select CONVERT(char(6), datetime_tran_local, 012)+CONVERT(char(10), datetime_tran_local, 108)),':','')),3,10)+'0000001214800000012148',
  'F0950042'+CONVERT(VARCHAR(50),REPLICATE('0', 12-LEN(amount))+amount+REPLICATE('0', 12-LEN(amount)))+CONVERT(VARCHAR(50),amount)+'C00000000C00000000',
  'F1230015'+c.pos_card_data_input_ability+'10101'+c.pos_card_data_input_mode+'04344101',
  'P00200320220:'+(CASE WHEN temp.message_type='0200' THEN TEMP.stan when  temp.message_type='0100' THEN  '1'+ SUBSTRING(TEMP.stan,2, LEN(TEMP.stan))  END)+':'+substring ((select REPLACE ((select CONVERT(char(6), getdate(), 012)+CONVERT(char(10), getdate(), 108)),':','')),3,10)+':'+substring (c.pan,13,4)+substring (c.pan,1,5),
  'P006000211',
  'P01100320100:'+t.system_trace_audit_nr+':'+substring ((select REPLACE ((select CONVERT(char(6), t.datetime_tran_local, 012)+CONVERT(char(10), t.datetime_tran_local, 108)),':','')),3,10)+':'+substring (c.pan,13,4)+substring (c.pan,1,5),'P0130017012340000001  566'
  ,'P0260012'+c.source_node_name

  
  FROM #temp_tlv_table temp 
  join post_tran t 
  ON 
  (  (  t.system_trace_audit_nr = temp.stan)
   OR (   t.system_trace_audit_nr = '1'+ SUBSTRING(temp.stan,2, LEN(temp.stan))))
 AND t.rsp_code_rsp in ('00','05','57','43','12')
and t.tran_postilion_originated =0
and t.tran_reversed = 0
AND t.message_type in ('0100','0200')

  join post_tran_cust c
on t.post_tran_cust_id = c.post_tran_cust_id 
AND temp.terminal_id =	c.terminal_id
and right (temp.pan,4) = right (c.pan,4)