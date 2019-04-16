SET IDENTITY_INSERT sstl_coa_w ON

DELETE FROM sstl_coa_w


INSERT INTO sstl_coa_w (config_set_id,coa_id,name,description,type,config_state)


 select config_set_id,coa_id,name,description,type,config_state from [172.25.10.65].[postilion_office].dbo.sstl_coa_w
 
 SET IDENTITY_INSERT sstl_coa_w off
 
 
 
 DELETE FROM spst_aggregation
 
 
 
 
 INSERT INTO spst_aggregation
 
 
 
 
  select * from [172.25.10.65].[postilion_office].dbo.spst_aggregation
 
 
 spst_aggregation
 spst_proc_ent
 
 spst_proc_ent_fltr_grp
 
 sstl_coa
 sstl_tran_ident_def
sstl_coa_w

INSERT INTO spst_plugin 
SELECT * FROM [172.25.10.65].[POSTILION_OFFICE].dbo.[spst_plugin] WHERE plugin_id  not in (SELECT plugin_id FROM [POSTILION_OFFICE].dbo.[spst_plugin])