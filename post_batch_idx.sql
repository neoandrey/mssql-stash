
USE [postilion_office]
GO

CREATE NONCLUSTERED INDEX [post_batch_idx]
ON [dbo].[post_batch] ([datetime_end])
INCLUDE ([settle_entity_id],[settle_date])

GO

/*



USE [postilion_office]
GO

CREATE NONCLUSTERED INDEX [post_batch_idx]
ON [dbo].[post_batch] ([datetime_end],[settle_entity_id],[settle_date])
GO




*/