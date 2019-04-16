/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [post_tran_id]
      ,[post_tran_cust_id]
      ,[tran_nr]
      ,[system_trace_audit_nr]
      ,[retrieval_reference_nr]
      ,[recon_business_date]
      , CASE WHEN [icc_data_req] IS NOT NULL THEN master.dbo.readTextData([icc_data_req], '') ELSE NULL END [icc_data_req]
      ,CASE WHEN [icc_data_rsp] IS NOT NULL THEN master.dbo.readTextData([icc_data_rsp], '') ELSE NULL END [icc_data_rsp]
      ,CASE WHEN [structured_data_req] IS NOT NULL THEN master.dbo.readTextData([structured_data_req], '') ELSE NULL END [structured_data_req]
      ,CASE WHEN [structured_data_rsp] IS NOT NULL THEN  master.dbo.readTextData([structured_data_rsp], '') ELSE NULL END [structured_data_rsp]
  FROM [postilion_office_super_2016_xml_data].[dbo].[post_tran_xml_arch_201602]  (nolock)
