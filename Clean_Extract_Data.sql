use postilion_office
-- This script will remove extract data from the Postilion
-- Office db. No config info will be removed


PRINT 'Cleaning Posttilion Office Extract tables'
GO


--Extract tables


PRINT 'Cleaning table extract_tran'


DELETE FROM extract_tran
GO


PRINT 'Cleaning table extract_session'


DELETE FROM extract_session
GO


PRINT 'Done'
GO


