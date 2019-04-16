

SELECT   OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME], 
         I.[NAME] AS [INDEX NAME], 
         USER_SEEKS, 
         USER_SCANS, 
         USER_LOOKUPS, 
         USER_UPDATES 
         into #temp_indexes
FROM     SYS.DM_DB_INDEX_USAGE_STATS AS S 
         INNER JOIN SYS.INDEXES AS I 
           ON I.[OBJECT_ID] = S.[OBJECT_ID] 
              AND I.INDEX_ID = S.INDEX_ID 
WHERE    OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1 

SELECT ' DROP INDEX '+[INDEX NAME] +' ON   '+[OBJECT NAME], * FROM  #temp_indexes  WHERE  user_seeks = 0  AND user_scans  = 0 AND user_lookups = 0  
AND  [INDEX NAME] is not null


