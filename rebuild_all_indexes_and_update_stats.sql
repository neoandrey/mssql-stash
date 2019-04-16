EXEC sp_MsforEachTable  'ALTER INDEX ALL ON ? REBUILD'

EXEC sp_MsforEachTable  'UPDATE STATISTICS ?   WITH  FULLSCAN'

EXEC sp_updatestats;  