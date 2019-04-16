 select 
 post_tran_id
 ,postilion_office_arc_non_xml.DBO.fn_rpt_archive_icc_data_req(post_tran_id ,post_tran_cust_id ,tran_nr , retrieval_reference_nr,  system_trace_audit_nr,  @@SERVERNAME,'E:\postilon_office_xml_data\icc_data_req', REPLACE(CONVERT(VARCHAR(10), t.recon_business_date,111),'/', ''), icc_data_req)  icc_data_req
 ,postilion_office_arc_non_xml.DBO.fn_rpt_archive_icc_data_rsp(post_tran_id ,post_tran_cust_id ,tran_nr , retrieval_reference_nr,  system_trace_audit_nr,  @@SERVERNAME,'E:\postilon_office_xml_data\icc_data_rsp',  REPLACE(CONVERT(VARCHAR(10), t.recon_business_date,111),'/', ''), icc_data_req)  icc_data_rsp
 ,postilion_office_arc_non_xml.DBO.fn_rpt_archive_structured_data_req(post_tran_id ,post_tran_cust_id ,tran_nr , retrieval_reference_nr,  system_trace_audit_nr,  @@SERVERNAME,'E:\postilon_office_xml_data\structured_data_req',  REPLACE(CONVERT(VARCHAR(10), t.recon_business_date,111),'/', ''), structured_data_req)  structured_data_req
 ,postilion_office_arc_non_xml.DBO.fn_rpt_archive_structured_data_rsp(post_tran_id ,post_tran_cust_id ,tran_nr , retrieval_reference_nr,  system_trace_audit_nr,  @@SERVERNAME,'E:\postilon_office_xml_data\structured_data_rsp',  REPLACE(CONVERT(VARCHAR(10), t.recon_business_date,111),'/', ''),  structured_data_rsp)   structured_data_rsp
INTO dbo.post_tran_xml_data_ref_201512
 FROM [172.25.10.66].[postilion_office].dbo.post_tran t (Nolock)
  JOIN (SELECT [date] recon_business_date FROM [postilion_office].dbo.[get_dates_in_range]('20151201','20151231'))r
  on
r.recon_business_date = t.recon_business_date
         
         