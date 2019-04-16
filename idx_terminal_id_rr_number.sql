USE [postilion_office]
GO
CREATE NONCLUSTERED INDEX [idx_terminal_id_rr_number]
ON [dbo].[tbl_xls_settlement] ([terminal_id],[rr_number])
