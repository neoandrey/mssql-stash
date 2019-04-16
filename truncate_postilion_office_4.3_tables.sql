Truncate table extract_tran;
 
print 'extract_tran truncated';
go
truncate table recon_match_equal;
 
print 'recon_match_equal truncated';
go
truncate table recon_match_not_equal;
 
print 'recon_match_not_equal truncated';
go
truncate table recon_post_only;
 
print 'recon_post_only truncated';
go
ALTER TABLE [dbo].[extract_tran] DROP CONSTRAINT [fk_extract_tran_3]
 
print 'extract_tran constraint dropped'
GO
ALTER TABLE [dbo].[recon_match_equal] DROP CONSTRAINT [fk_recon_match_equal_2]
 
print 'recon_match_equal constraint dropped'
GO
ALTER TABLE [dbo].[recon_match_not_equal] DROP CONSTRAINT [fk_recon_match_not_equal_2]
 
print 'recon_match_not_equal constraint dropped'
GO
ALTER TABLE [dbo].[recon_post_only] DROP CONSTRAINT [fk_recon_post_only_3]
 
print 'recon_post_only constraint dropped'
GO
truncate table post_tran
 
print 'post_tran truncated'
go
ALTER TABLE [dbo].[post_tran] DROP CONSTRAINT [fk_post_tran_1]
GO
truncate table post_tran_cust
 
print 'post_tran_cust truncated'
go
ALTER TABLE [dbo].[post_tran] WITH CHECK ADD CONSTRAINT [fk_post_tran_1] FOREIGN KEY([post_tran_cust_id])
 
REFERENCES [dbo].[post_tran_cust] ([post_tran_cust_id])
GO
ALTER TABLE [dbo].[post_tran] CHECK CONSTRAINT [fk_post_tran_1]
GO
ALTER TABLE [dbo].[recon_post_only] WITH CHECK ADD CONSTRAINT [fk_recon_post_only_3] FOREIGN KEY([post_tran_id])
 
REFERENCES [dbo].[post_tran] ([post_tran_id])
GO
ALTER TABLE [dbo].[recon_post_only] CHECK CONSTRAINT [fk_recon_post_only_3]
 
print 'recon_post_only constraint recretaed'
GO
 
ALTER TABLE [dbo].[recon_match_not_equal] WITH CHECK ADD CONSTRAINT [fk_recon_match_not_equal_2] FOREIGN KEY([post_tran_id])
 
REFERENCES [dbo].[post_tran] ([post_tran_id])
GO
ALTER TABLE [dbo].[recon_match_not_equal] CHECK CONSTRAINT [fk_recon_match_not_equal_2]
 
print 'recon_match_not_equal constraint recreated'
GO
 
ALTER TABLE [dbo].[recon_match_equal] WITH CHECK ADD CONSTRAINT [fk_recon_match_equal_2] FOREIGN KEY([post_tran_id])
 
REFERENCES [dbo].[post_tran] ([post_tran_id])
GO
ALTER TABLE [dbo].[recon_match_equal] CHECK CONSTRAINT [fk_recon_match_equal_2]
 
print 'recon_match_equal constraint recreated'
GO
 
ALTER TABLE [dbo].[extract_tran] WITH CHECK ADD CONSTRAINT [fk_extract_tran_3] FOREIGN KEY([post_tran_id])
 
REFERENCES [dbo].[post_tran] ([post_tran_id])
GO
ALTER TABLE [dbo].[extract_tran] CHECK CONSTRAINT [fk_extract_tran_3]
 
print 'extract_tran constraint recreated'
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[fk_post_batch_1]') AND parent_object_id = OBJECT_ID(N'[dbo].[post_batch]'))
ALTER TABLE [dbo].[post_batch] DROP CONSTRAINT [fk_post_batch_1]

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[fk_post_online_batch_1]') AND parent_object_id = OBJECT_ID(N'[dbo].[post_online_batch]'))
ALTER TABLE [dbo].[post_online_batch] DROP CONSTRAINT [fk_post_online_batch_1]


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[fk_post_process_run_phase_1]') AND parent_object_id = OBJECT_ID(N'[dbo].[post_process_run_phase]'))
ALTER TABLE [dbo].[post_process_run_phase] DROP CONSTRAINT [fk_post_process_run_phase_1]

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[fk_post_tran_2]') AND parent_object_id = OBJECT_ID(N'[dbo].[post_tran]'))
ALTER TABLE [dbo].[post_tran] DROP CONSTRAINT [fk_post_tran_2]

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[fk_post_process_run_phase_d_1]') AND parent_object_id = OBJECT_ID(N'[dbo].[post_process_run_phase_detail]'))
ALTER TABLE [dbo].[post_process_run_phase_detail] DROP CONSTRAINT [fk_post_process_run_phase_d_1]


truncate table post_online_batch
truncate table [post_settle_entity]
truncate table  post_batch

TRUNCATE TABLE post_normalization_session 
TRUNCATE TABLE post_norm_rtfw_session 
TRUNCATE TABLE  post_process_run 

TRUNCATE TABLE    post_process_run_phase
TRUNCATE TABLE    post_process_run_phase_detail

TRUNCATE TABLE  post_tran_exception

ALTER TABLE [dbo].[post_batch]  WITH CHECK ADD  CONSTRAINT [fk_post_batch_1] FOREIGN KEY([settle_entity_id])
REFERENCES [dbo].[post_settle_entity] ([settle_entity_id])


ALTER TABLE [dbo].[post_batch] CHECK CONSTRAINT [fk_post_batch_1]

ALTER TABLE [dbo].[post_process_run_phase]  WITH CHECK ADD  CONSTRAINT [fk_post_process_run_phase_1] FOREIGN KEY([process_run_id])
REFERENCES [dbo].[post_process_run] ([process_run_id])


ALTER TABLE [dbo].[post_process_run_phase] CHECK CONSTRAINT [fk_post_process_run_phase_1]


ALTER TABLE [dbo].[post_online_batch]  WITH CHECK ADD  CONSTRAINT [fk_post_online_batch_1] FOREIGN KEY([settle_entity_id])
REFERENCES [dbo].[post_settle_entity] ([settle_entity_id])


ALTER TABLE [dbo].[post_online_batch] CHECK CONSTRAINT [fk_post_online_batch_1]



ALTER TABLE [dbo].[post_tran]  WITH CHECK ADD  CONSTRAINT [fk_post_tran_2] FOREIGN KEY([settle_entity_id], [batch_nr])
REFERENCES [dbo].[post_batch] ([settle_entity_id], [batch_nr])


ALTER TABLE [dbo].[post_tran] CHECK CONSTRAINT [fk_post_tran_2]


ALTER TABLE [dbo].[post_process_run_phase_detail]  WITH CHECK ADD  CONSTRAINT [fk_post_process_run_phase_d_1] FOREIGN KEY([process_run_id], [process_run_phase_sequence])
REFERENCES [dbo].[post_process_run_phase] ([process_run_id], [process_run_phase_sequence])


ALTER TABLE [dbo].[post_process_run_phase_detail] CHECK CONSTRAINT [fk_post_process_run_phase_d_1]



ALTER  INDEX ALL ON post_tran REBUILD WITH (STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON,  SORT_IN_TEMPDB = OFF)

ALTER  INDEX ALL ON post_tran_cust REBUILD WITH (STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON,  SORT_IN_TEMPDB = OFF)



EXEC sp_MsforEachTable  'ALTER INDEX ALL ON ? REBUILD'