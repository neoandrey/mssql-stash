use postilion_office
--This script will remove all recon data from the Postilion
--Office db. No config table info will be removed


PRINT 'Cleaning Postilion Office Recon tables'
GO


--There may be recon plug-in specific info to remove
--Change the table name extension to the specific plug-in
PRINT 'Cleaning plug-in specific tables'


--DELETE FROM external_tran_postbridge
--GO


--DELETE FROM external_file_postbridge
--GO


-- Recon tables
PRINT 'Cleaning table recon_external_only'


DELETE FROM recon_external_only
GO


PRINT 'Cleaning table recon_match_equal'


DELETE FROM recon_match_equal
GO


PRINT 'Cleaning table recon_match_not_equal'


DELETE FROM recon_match_not_equal
GO


PRINT 'Cleaning table recon_post_only'


DELETE FROM recon_post_only
GO


PRINT 'Cleaning table recon_session'


DELETE FROM recon_session
GO


PRINT 'Done'
GO


